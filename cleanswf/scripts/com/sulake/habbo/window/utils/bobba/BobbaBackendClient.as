package com.sulake.habbo.window.utils.bobba
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.SharedObject;
   import flash.net.Socket;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public class BobbaBackendClient
   {
      
      public static const STATUS_DISCONNECTED:String = "disconnected";
      
      public static const STATUS_CONNECTING:String = "connecting";
      
      public static const STATUS_HANDSHAKE:String = "handshake";
      
      public static const STATUS_CONNECTED:String = "connected";
      
      public static const STATUS_FAILED:String = "failed";
      
      private static const DEFAULT_HOST:String = "game.bobbapacket.com";
      
      private static const DEFAULT_PORT:int = 3001;
      
      private static const PROTOCOL_VERSION:int = 1;
      
      private static const CLIENT_SECRET:String = "why_4r3-you*r3ading_th15%l0l";
      
      private static const CLIENT_VERSION:String = "1.1.4";
      
      private static const CLIENT_BUILD:String = "BobbaClient-1.1.4";
      
      private static const SOL_NAME:String = "BobbaClient";
      
      private static const HEARTBEAT_MS:int = 30000;
      
      private static const RECONNECT_MS:int = 5000;
      
      private static const PROFILE_POLL_MS:int = 2000;
      
      private var _host:String;
      
      private var _port:int;
      
      private var _socket:Socket;
      
      private var _buffer:ByteArray;
      
      private var _status:String = STATUS_DISCONNECTED;
      
      private var _statusDetail:String = "";
      
      private var _machineId:String = "";
      
      private var _hotelId:String = "";
      
      private var _hotelEnvironment:String = "";
      
      private var _nickname:String = "";
      
      private var _sentNickname:String = "";
      
      private var _sentFigure:String = "";
      
      private var _helloTimestamp:int = 0;
      
      private var _helloNonce:String = "";
      
      private var _authed:Boolean = false;
      
      private var _backendReadyNotified:Boolean = false;
      
      private var _heartbeat:Timer;
      
      private var _reconnect:Timer;
      
      private var _profilePoll:Timer;
      
      private var _windowManager:*;
      
      private var _disposed:Boolean = false;
      
      private var _groupListener:*;
      
      public function BobbaBackendClient(windowManager:*, host:String = null, port:int = 0)
      {
         super();
         _windowManager = windowManager;
         _host = host != null && host.length > 0 ? host : DEFAULT_HOST;
         _port = port > 0 ? port : DEFAULT_PORT;
         _buffer = new ByteArray();
         _machineId = loadOrCreateMachineId();
         refreshHotelFromSol();
         _heartbeat = new Timer(HEARTBEAT_MS);
         _heartbeat.addEventListener(TimerEvent.TIMER,onHeartbeatTimer);
         _reconnect = new Timer(RECONNECT_MS,1);
         _reconnect.addEventListener(TimerEvent.TIMER,onReconnectTimer);
         _profilePoll = new Timer(PROFILE_POLL_MS);
         _profilePoll.addEventListener(TimerEvent.TIMER,onProfilePoll);
      }
      
      public function setGroupListener(listener:*) : void
      {
         _groupListener = listener;
      }
      
      public function get status() : String
      {
         return _status;
      }
      
      public function get statusDetail() : String
      {
         return _statusDetail;
      }
      
      public function get hotelId() : String
      {
         return _hotelId;
      }
      
      public function get nickname() : String
      {
         return _nickname;
      }
      
      public function get isConnected() : Boolean
      {
         return _authed && _socket != null && _socket.connected;
      }
      
      public function start() : void
      {
         if(_disposed)
         {
            return;
         }
         try
         {
            if(_profilePoll != null)
            {
               _profilePoll.start();
            }
            attemptConnect();
         }
         catch(startErr:Error)
         {
            setStatus(STATUS_FAILED,startErr.message);
            scheduleReconnect();
         }
      }
      
      public function dispose() : void
      {
         _disposed = true;
         if(_heartbeat != null)
         {
            _heartbeat.stop();
            _heartbeat.removeEventListener(TimerEvent.TIMER,onHeartbeatTimer);
            _heartbeat = null;
         }
         if(_reconnect != null)
         {
            _reconnect.stop();
            _reconnect.removeEventListener(TimerEvent.TIMER,onReconnectTimer);
            _reconnect = null;
         }
         if(_profilePoll != null)
         {
            _profilePoll.stop();
            _profilePoll.removeEventListener(TimerEvent.TIMER,onProfilePoll);
            _profilePoll = null;
         }
         closeSocket();
         _windowManager = null;
         _groupListener = null;
      }
      
      public function createGroup(name:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.CREATE_GROUP,[name != null ? name : ""]);
      }
      
      public function listGroups() : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.LIST_GROUPS,[]);
      }
      
      public function inviteToGroup(groupId:String, nickname:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.INVITE_TO_GROUP,[groupId != null ? groupId : "",nickname != null ? nickname : ""]);
      }
      
      public function respondInvite(inviteId:String, accept:Boolean) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.RESPOND_INVITE,[inviteId != null ? inviteId : "",accept]);
      }
      
      public function sendGroupMessage(groupId:String, body:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.SEND_GROUP_MESSAGE,[groupId != null ? groupId : "",body != null ? body : ""]);
      }
      
      public function openGroup(groupId:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.OPEN_GROUP,[groupId != null ? groupId : ""]);
      }
      
      public function markGroupRead(groupId:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.MARK_GROUP_READ,[groupId != null ? groupId : ""]);
      }
      
      public function leaveGroup(groupId:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.LEAVE_GROUP,[groupId != null ? groupId : ""]);
      }
      
      public function listGroupMembers(groupId:String) : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.LIST_GROUP_MEMBERS,[groupId != null ? groupId : ""]);
      }
      
      public function listPendingInvites() : void
      {
         if(!_authed)
         {
            return;
         }
         send(BobbaWireCodec.LIST_PENDING_INVITES,[]);
      }
      
      public function updateProfile(nickname:String, hotelId:String = "", hotelEnvironment:String = "", figure:String = "") : void
      {
         try
         {
            if(nickname != null && nickname.length > 0)
            {
               _nickname = nickname;
            }
            if(hotelId != null && hotelId.length > 0)
            {
               _hotelId = canonicalizeHotelId(hotelId);
               persistHotel(_hotelId,_hotelEnvironment);
            }
            if(hotelEnvironment != null && hotelEnvironment.length > 0)
            {
               _hotelEnvironment = hotelEnvironment;
               persistHotel(_hotelId,_hotelEnvironment);
            }
            if(!_authed || _socket == null || !_socket.connected)
            {
               return;
            }
            if(_nickname.length == 0)
            {
               return;
            }
            if(figure == null || figure.length == 0)
            {
               figure = currentFigure();
            }
            if(_nickname == _sentNickname && hotelId.length == 0 && figure == _sentFigure)
            {
               return;
            }
            send(BobbaWireCodec.UPDATE_PROFILE,[_nickname,_hotelId,_hotelEnvironment,figure != null ? figure : ""]);
            _sentNickname = _nickname;
            _sentFigure = figure != null ? figure : "";
            Logger.log("[BobbaBackend] UpdateProfile",_hotelId,_nickname);
            notifyBackendReadyIfLinked();
         }
         catch(profileErr:Error)
         {
            Logger.log("[BobbaBackend] UpdateProfile ignored",profileErr.message);
         }
      }
      
      private function attemptConnect() : void
      {
         if(_disposed || _authed)
         {
            return;
         }
         if(_socket != null)
         {
            return;
         }
         refreshHotelFromSol();
         readSessionIdentity();
         if(_nickname.length == 0)
         {
            setStatus(STATUS_DISCONNECTED,"waiting for habbo nickname");
            return;
         }
         connect();
      }
      
      private function connect() : void
      {
         if(_disposed)
         {
            return;
         }
         try
         {
            refreshHotelFromSol();
            readSessionIdentity();
            if(_nickname.length == 0)
            {
               setStatus(STATUS_CONNECTING,"waiting for habbo nickname");
               return;
            }
            closeSocket();
            setStatus(STATUS_CONNECTING,"tcp " + _host + ":" + _port);
            _buffer = new ByteArray();
            _authed = false;
            _backendReadyNotified = false;
            _sentNickname = "";
            _sentFigure = "";
            _socket = new Socket();
            _socket.addEventListener(Event.CONNECT,onConnect);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA,onSocketData);
            _socket.addEventListener(Event.CLOSE,onSocketClose);
            _socket.addEventListener(IOErrorEvent.IO_ERROR,onSocketError);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketError);
            _socket.connect(_host,_port);
         }
         catch(e:Error)
         {
            setStatus(STATUS_FAILED,e.message);
            closeSocket();
            scheduleReconnect();
         }
      }
      
      private function onConnect(e:Event) : void
      {
         var figure:String = "";
         try
         {
            setStatus(STATUS_HANDSHAKE,"hello");
            _helloTimestamp = int(new Date().time / 1000);
            _helloNonce = BobbaCrypto.randomHex(16);
            if(_hotelId.length == 0)
            {
               _hotelId = "unknown";
            }
            figure = currentFigure();
            send(BobbaWireCodec.HELLO,[PROTOCOL_VERSION,CLIENT_BUILD,CLIENT_VERSION,_machineId,_hotelId,_hotelEnvironment,Capabilities.os,_helloTimestamp,_helloNonce,_nickname,figure]);
         }
         catch(connectErr:Error)
         {
            setStatus(STATUS_FAILED,connectErr.message);
            closeSocket();
            scheduleReconnect();
         }
      }
      
      private function onSocketData(e:ProgressEvent) : void
      {
         var packets:Array = null;
         var i:int = 0;
         var packet:Object = null;
         try
         {
            if(_socket == null)
            {
               return;
            }
            _socket.readBytes(_buffer,_buffer.length);
            packets = BobbaWireCodec.split(_buffer);
            for(i = 0; i < packets.length; i++)
            {
               packet = packets[i];
               handlePacket(int(packet.id),packet.payload as ByteArray);
            }
         }
         catch(err:Error)
         {
            setStatus(STATUS_FAILED,err.message);
            closeSocket();
            scheduleReconnect();
         }
      }
      
      private function handlePacket(id:int, payload:ByteArray) : void
      {
         var challenge:String = null;
         var hmac:String = null;
         var reason:int = 0;
         var message:String = null;
         if(id == BobbaWireCodec.CHALLENGE)
         {
            challenge = BobbaWireCodec.readString(payload);
            hmac = BobbaCrypto.hmacSha256Hex(CLIENT_SECRET,challenge + "|" + _machineId + "|" + _helloTimestamp + "|" + _helloNonce);
            send(BobbaWireCodec.AUTH,[hmac]);
            return;
         }
         if(id == BobbaWireCodec.AUTH_OK)
         {
            _authed = true;
            BobbaWireCodec.readString(payload);
            BobbaWireCodec.readInt(payload);
            BobbaWireCodec.readString(payload);
            BobbaWireCodec.readString(payload);
            setStatus(STATUS_CONNECTED,_hotelId);
            if(_heartbeat != null)
            {
               _heartbeat.start();
            }
            syncNicknameFromSession();
            notifyBackendReadyIfLinked();
            return;
         }
         if(id == BobbaWireCodec.AUTH_FAIL)
         {
            reason = BobbaWireCodec.readInt(payload);
            message = BobbaWireCodec.readString(payload);
            setStatus(STATUS_FAILED,"#" + reason + " " + message);
            closeSocket();
            scheduleReconnect();
            return;
         }
         if(id == BobbaWireCodec.HEARTBEAT_ACK)
         {
            return;
         }
         if(id == BobbaWireCodec.SERVER_MESSAGE)
         {
            message = BobbaWireCodec.readString(payload);
            Logger.log("[BobbaBackend]",message);
            return;
         }
         handleGroupPacket(id,payload);
      }
      
      private function handleGroupPacket(id:int, payload:ByteArray) : void
      {
         var count:int = 0;
         var i:int = 0;
         var groups:Array = null;
         var invites:Array = null;
         var messages:Array = null;
         var members:Array = null;
         var groupId:String = null;
         var inviteId:String = null;
         var accepted:Boolean = false;
         var code:int = 0;
         var errMsg:String = null;
         try
         {
            if(id == BobbaWireCodec.GROUP_CREATED)
            {
               if(_groupListener != null)
               {
                  _groupListener.onGroupCreated(BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload));
               }
               return;
            }
            if(id == BobbaWireCodec.GROUPS_LIST)
            {
               count = BobbaWireCodec.readInt(payload);
               groups = [];
               for(i = 0; i < count; i++)
               {
                  groups.push({
                     "id":BobbaWireCodec.readString(payload),
                     "name":BobbaWireCodec.readString(payload),
                     "memberCount":BobbaWireCodec.readInt(payload),
                     "unreadCount":BobbaWireCodec.readInt(payload)
                  });
               }
               if(_groupListener != null)
               {
                  _groupListener.onGroupsList(groups);
               }
               return;
            }
            if(id == BobbaWireCodec.INVITE_NOTIFY)
            {
               if(_groupListener != null)
               {
                  _groupListener.onInviteNotify(BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload));
               }
               return;
            }
            if(id == BobbaWireCodec.INVITE_RESOLVED)
            {
               inviteId = BobbaWireCodec.readString(payload);
               accepted = payload.readBoolean();
               if(_groupListener != null)
               {
                  _groupListener.onInviteResolved(inviteId,accepted,BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload));
               }
               return;
            }
            if(id == BobbaWireCodec.GROUP_MESSAGE)
            {
               if(_groupListener != null)
               {
                  _groupListener.onGroupMessage(BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readInt(payload));
               }
               return;
            }
            if(id == BobbaWireCodec.GROUP_HISTORY)
            {
               groupId = BobbaWireCodec.readString(payload);
               count = BobbaWireCodec.readInt(payload);
               messages = [];
               for(i = 0; i < count; i++)
               {
                  messages.push({
                     "messageId":BobbaWireCodec.readString(payload),
                     "senderNickname":BobbaWireCodec.readString(payload),
                     "senderFigure":BobbaWireCodec.readString(payload),
                     "body":BobbaWireCodec.readString(payload),
                     "timestamp":BobbaWireCodec.readInt(payload)
                  });
               }
               if(_groupListener != null)
               {
                  _groupListener.onGroupHistory(groupId,messages);
               }
               return;
            }
            if(id == BobbaWireCodec.GROUP_ERROR)
            {
               code = BobbaWireCodec.readInt(payload);
               errMsg = BobbaWireCodec.readString(payload);
               Logger.log("[BobbaBackend] GroupError",code,errMsg);
               if(_groupListener != null)
               {
                  _groupListener.onGroupError(code,errMsg);
               }
               return;
            }
            if(id == BobbaWireCodec.PENDING_INVITES)
            {
               count = BobbaWireCodec.readInt(payload);
               invites = [];
               for(i = 0; i < count; i++)
               {
                  invites.push({
                     "inviteId":BobbaWireCodec.readString(payload),
                     "groupId":BobbaWireCodec.readString(payload),
                     "groupName":BobbaWireCodec.readString(payload),
                     "fromNickname":BobbaWireCodec.readString(payload)
                  });
               }
               if(_groupListener != null)
               {
                  _groupListener.onPendingInvites(invites);
               }
               return;
            }
            if(id == BobbaWireCodec.GROUP_LEFT)
            {
               if(_groupListener != null)
               {
                  _groupListener.onGroupLeft(BobbaWireCodec.readString(payload),payload.readBoolean());
               }
               return;
            }
            if(id == BobbaWireCodec.GROUP_EVENT)
            {
               if(_groupListener != null)
               {
                  _groupListener.onGroupEvent(BobbaWireCodec.readString(payload),BobbaWireCodec.readInt(payload),BobbaWireCodec.readString(payload),BobbaWireCodec.readString(payload));
               }
               return;
            }
            if(id == BobbaWireCodec.GROUP_MEMBERS)
            {
               groupId = BobbaWireCodec.readString(payload);
               count = BobbaWireCodec.readInt(payload);
               members = [];
               for(i = 0; i < count; i++)
               {
                  members.push({
                     "nickname":BobbaWireCodec.readString(payload),
                     "figure":BobbaWireCodec.readString(payload),
                     "role":BobbaWireCodec.readString(payload)
                  });
               }
               if(_groupListener != null)
               {
                  _groupListener.onGroupMembers(groupId,members);
               }
            }
         }
         catch(groupErr:Error)
         {
            Logger.log("[BobbaBackend] group packet error",groupErr.message);
         }
      }
      
      private function onHeartbeatTimer(e:TimerEvent) : void
      {
         if(_authed && _socket != null && _socket.connected)
         {
            send(BobbaWireCodec.HEARTBEAT,[]);
         }
      }
      
      private function onProfilePoll(e:TimerEvent) : void
      {
         try
         {
            if(!_authed)
            {
               attemptConnect();
               return;
            }
            refreshHotelFromSol();
            syncNicknameFromSession();
         }
         catch(pollErr:Error)
         {
         }
      }
      
      private function readSessionIdentity() : void
      {
         var session:* = null;
         var name:String = null;
         if(_windowManager == null)
         {
            return;
         }
         try
         {
            session = _windowManager.sessionDataManager;
            if(session != null)
            {
               name = session.userName;
               if(name != null && name.length > 0)
               {
                  _nickname = name;
               }
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function currentFigure() : String
      {
         try
         {
            if(_windowManager != null && _windowManager.sessionDataManager != null && _windowManager.sessionDataManager.figure != null)
            {
               return _windowManager.sessionDataManager.figure;
            }
         }
         catch(figErr:Error)
         {
         }
         return "";
      }
      
      private function syncNicknameFromSession() : void
      {
         var session:* = null;
         var name:String = null;
         var figure:String = "";
         if(_windowManager == null)
         {
            return;
         }
         try
         {
            session = _windowManager.sessionDataManager;
            if(session != null)
            {
               name = session.userName;
               figure = session.figure != null ? session.figure : "";
               if(name != null && name.length > 0)
               {
                  updateProfile(name,_hotelId,_hotelEnvironment,figure);
               }
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function notifyBackendReadyIfLinked() : void
      {
         if(!_authed || _backendReadyNotified || _nickname.length == 0 || _groupListener == null)
         {
            return;
         }
         _backendReadyNotified = true;
         try
         {
            _groupListener.onBackendReady();
         }
         catch(readyErr:Error)
         {
         }
      }
      
      private function onReconnectTimer(e:TimerEvent) : void
      {
         attemptConnect();
      }
      
      private function onSocketClose(e:Event) : void
      {
         _authed = false;
         if(_heartbeat != null)
         {
            _heartbeat.stop();
         }
         if(!_disposed)
         {
            setStatus(STATUS_DISCONNECTED,"closed");
            scheduleReconnect();
         }
      }
      
      private function onSocketError(e:Event) : void
      {
         _authed = false;
         setStatus(STATUS_FAILED,String(e));
         closeSocket();
         scheduleReconnect();
      }
      
      private function scheduleReconnect() : void
      {
         if(_disposed || _reconnect == null)
         {
            return;
         }
         _reconnect.reset();
         _reconnect.start();
      }
      
      private function send(id:int, fields:Array) : void
      {
         var packet:ByteArray = null;
         try
         {
            if(_socket == null || !_socket.connected)
            {
               return;
            }
            packet = BobbaWireCodec.encode(id,fields);
            _socket.writeBytes(packet);
            _socket.flush();
         }
         catch(sendErr:Error)
         {
            setStatus(STATUS_FAILED,sendErr.message);
            closeSocket();
            scheduleReconnect();
         }
      }
      
      private function closeSocket() : void
      {
         if(_socket == null)
         {
            return;
         }
         try
         {
            _socket.removeEventListener(Event.CONNECT,onConnect);
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA,onSocketData);
            _socket.removeEventListener(Event.CLOSE,onSocketClose);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR,onSocketError);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketError);
            if(_socket.connected)
            {
               _socket.close();
            }
         }
         catch(err:Error)
         {
         }
         _socket = null;
         _authed = false;
      }
      
      private function setStatus(status:String, detail:String = "") : void
      {
         _status = status;
         _statusDetail = detail;
         Logger.log("[BobbaBackend]",status,detail);
      }
      
      private function loadOrCreateMachineId() : String
      {
         var so:SharedObject = null;
         var id:String = null;
         try
         {
            so = SharedObject.getLocal(SOL_NAME,"/");
            id = so.data.machineId as String;
            if(id == null || id.length < 8)
            {
               id = BobbaCrypto.randomHex(16);
               so.data.machineId = id;
               so.flush();
            }
            return id;
         }
         catch(err:Error)
         {
            return BobbaCrypto.randomHex(16);
         }
         return BobbaCrypto.randomHex(16);
      }
      
      private function refreshHotelFromSol() : void
      {
         var so:SharedObject = null;
         var hotel:String = null;
         var env:String = null;
         try
         {
            so = SharedObject.getLocal(SOL_NAME,"/");
            hotel = so.data.hotelId as String;
            env = so.data.hotelEnvironment as String;
            if(hotel != null && hotel.length > 0)
            {
               _hotelId = canonicalizeHotelId(hotel);
            }
            if(env != null)
            {
               _hotelEnvironment = env;
            }
         }
         catch(err:Error)
         {
         }
      }
      
      public static function persistHotel(hotelId:String, hotelEnvironment:String) : void
      {
         var so:SharedObject = null;
         try
         {
            so = SharedObject.getLocal(SOL_NAME,"/");
            so.data.hotelId = canonicalizeHotelId(hotelId);
            so.data.hotelEnvironment = hotelEnvironment;
            so.flush();
         }
         catch(err:Error)
         {
         }
      }
      
      public static function canonicalizeHotelId(hotelId:String) : String
      {
         var value:String = hotelId != null ? hotelId.toLowerCase() : "";
         if(value.length == 0)
         {
            return "unknown";
         }
         if(value.indexOf("hh") == 0)
         {
            return value;
         }
         return "hh" + value;
      }
      
      public static function environmentFromHotelId(hotelId:String) : String
      {
         var raw:String = canonicalizeHotelId(hotelId);
         if(raw.indexOf("hh") == 0)
         {
            raw = raw.substring(2);
         }
         if(raw == "br")
         {
            return "pt";
         }
         if(raw == "us")
         {
            return "en";
         }
         return raw;
      }
      
      public static function hotelIdFromEnvironment(env:String) : String
      {
         var value:String = env != null ? env.toLowerCase() : "";
         if(value == "pt")
         {
            return "hhbr";
         }
         if(value == "en")
         {
            return "hhus";
         }
         if(value.indexOf("hh") == 0)
         {
            return value;
         }
         return "hh" + value;
      }
   }
}
