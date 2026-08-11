package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.communication.messages.outgoing.users.GetExtendedProfileByNameMessageComposer;
   import com.sulake.habbo.freeflowchat.HabboFreeFlowChat;
   import com.sulake.habbo.freeflowchat.data.ChatItem;
   import com.sulake.habbo.session.events.RoomSessionChatEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class BobbaGroupWhisperController
   {
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _backend:BobbaBackendClient;
      
      private var _editor:BobbaGroupWhisperEditor;
      
      private var _members:Array;
      
      private var _lastLocalBody:String = "";
      
      private var _bobbaUsers:Dictionary;
      
      private var _pendingLookup:Dictionary;
      
      private var _menuRefreshHandler:Function;
      
      private var _menuRefreshName:String = "";
      
      public function BobbaGroupWhisperController(windowManager:HabboWindowManagerComponent, backend:BobbaBackendClient)
      {
         super();
         _windowManager = windowManager;
         _backend = backend;
         _members = [];
         _bobbaUsers = new Dictionary();
         _pendingLookup = new Dictionary();
         if(_backend != null)
         {
            _backend.setWhisperListener(this);
         }
      }
      
      public function dispose() : void
      {
         if(_backend != null)
         {
            _backend.setWhisperListener(null);
         }
         if(_editor != null)
         {
            _editor.dispose();
            _editor = null;
         }
         _members = null;
         _bobbaUsers = null;
         _pendingLookup = null;
         _menuRefreshHandler = null;
         _windowManager = null;
         _backend = null;
      }
      
      public function getMembers() : Array
      {
         return _members != null ? _members.concat() : [];
      }
      
      public function hasMembers() : Boolean
      {
         return _members != null && _members.length > 0;
      }
      
      public function isMember(name:String) : Boolean
      {
         return indexOfName(name) >= 0;
      }
      
      public function isBobbaUser(name:String) : Boolean
      {
         var key:String = null;
         if(name == null || name.length == 0 || _bobbaUsers == null)
         {
            return false;
         }
         key = name.toLowerCase();
         return _bobbaUsers[key] == true;
      }
      
      public function setMenuRefreshHandler(handler:Function, name:String) : void
      {
         _menuRefreshHandler = handler;
         _menuRefreshName = name != null ? name : "";
      }
      
      public function clearMenuRefreshHandler() : void
      {
         _menuRefreshHandler = null;
         _menuRefreshName = "";
      }
      
      public function requestBobbaUserCheck(name:String) : void
      {
         var key:String = null;
         if(name == null || name.length == 0)
         {
            return;
         }
         if(_backend == null || !_backend.isConnected)
         {
            return;
         }
         key = name.toLowerCase();
         if(_bobbaUsers != null && _bobbaUsers[key] != undefined)
         {
            return;
         }
         if(_pendingLookup != null && _pendingLookup[key] == true)
         {
            return;
         }
         if(_pendingLookup != null)
         {
            _pendingLookup[key] = true;
         }
         _backend.lookupBobbaUsers(name);
      }
      
      public function onBobbaUsersResult(results:Array) : void
      {
         var i:int = 0;
         var row:Object = null;
         var nick:String = null;
         var key:String = null;
         var registered:Boolean = false;
         var refresh:Boolean = false;
         if(_bobbaUsers == null)
         {
            return;
         }
         if(results == null)
         {
            return;
         }
         for(i = 0; i < results.length; i++)
         {
            row = results[i];
            if(row == null)
            {
               continue;
            }
            nick = String(row.nickname);
            if(nick == null || nick.length == 0)
            {
               continue;
            }
            key = nick.toLowerCase();
            registered = row.registered == true;
            _bobbaUsers[key] = registered;
            if(_pendingLookup != null)
            {
               delete _pendingLookup[key];
            }
            if(_menuRefreshName != null && _menuRefreshName.toLowerCase() == key)
            {
               refresh = true;
            }
         }
         if(refresh && _menuRefreshHandler != null)
         {
            try
            {
               _menuRefreshHandler();
            }
            catch(refreshErr:Error)
            {
            }
         }
      }
      
      public function toggle(name:String) : Boolean
      {
         var idx:int = 0;
         if(name == null || name.length == 0)
         {
            return false;
         }
         if(_windowManager != null && _windowManager.LilithCustomsInstance != null && !_windowManager.LilithCustomsInstance.BobbaGroupWhisperEnabled)
         {
            alert(BobbaI18n.t("groupwhisper.alert.disabled","Enable Group whisper in :bobba first."));
            return false;
         }
         idx = indexOfName(name);
         if(idx >= 0)
         {
            _members.splice(idx,1);
            syncUi();
            return false;
         }
         if(!isBobbaUser(name))
         {
            requestBobbaUserCheck(name);
            alert(BobbaI18n.t("groupwhisper.alert.not_bobba","That Habbo is not using Bobba Client."));
            return false;
         }
         _members.push(name);
         syncUi();
         fillChatPrefix();
         return true;
      }
      
      public function remove(name:String) : void
      {
         var idx:int = indexOfName(name);
         if(idx < 0)
         {
            return;
         }
         _members.splice(idx,1);
         syncUi();
      }
      
      public function openUserProfile(nickname:String) : void
      {
         if(nickname == null || nickname.length == 0 || _windowManager == null)
         {
            return;
         }
         try
         {
            if(_windowManager.communication != null && _windowManager.communication.connection != null)
            {
               _windowManager.communication.connection.send(new GetExtendedProfileByNameMessageComposer(nickname));
            }
         }
         catch(err:Error)
         {
         }
      }
      
      public function clear() : void
      {
         if(_members != null)
         {
            _members.length = 0;
         }
         _lastLocalBody = "";
         if(_editor != null)
         {
            _editor.visible = false;
         }
      }
      
      private function fillChatPrefix() : void
      {
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null)
            {
               _windowManager.LilithCustomsInstance.fillGroupWhisperChatPrefix();
            }
         }
         catch(fillErr:Error)
         {
         }
      }
      
      public function send(body:String) : Boolean
      {
         var csv:String = null;
         if(_windowManager != null && _windowManager.LilithCustomsInstance != null && !_windowManager.LilithCustomsInstance.BobbaGroupWhisperEnabled)
         {
            alert(BobbaI18n.t("groupwhisper.alert.disabled","Enable Group whisper in :bobba first."));
            return false;
         }
         if(body == null || body.length == 0)
         {
            return false;
         }
         if(_members == null || _members.length == 0)
         {
            alert(BobbaI18n.t("groupwhisper.alert.empty","Add people with Sussurro em grupo on the avatar menu."));
            return false;
         }
         if(_backend == null || !_backend.isConnected)
         {
            alert(BobbaI18n.t("groupwhisper.alert.offline","Bobba backend is offline."));
            return false;
         }
         csv = _members.join(",");
         _lastLocalBody = body;
         _backend.sendRoomWhisper(body,csv);
         showBubbleForNickname(ownNickname(),body);
         return true;
      }
      
      public function onRoomWhisper(senderNickname:String, senderFigure:String, body:String, timestamp:int) : void
      {
         var own:String = null;
         if(body == null || body.length == 0)
         {
            return;
         }
         own = ownNickname();
         if(own != null && senderNickname != null && own.toLowerCase() == senderNickname.toLowerCase())
         {
            if(_lastLocalBody != null && _lastLocalBody == body)
            {
               _lastLocalBody = "";
               return;
            }
         }
         showBubbleForNickname(senderNickname,body);
      }
      
      private function syncUi() : void
      {
         if(_members == null || _members.length == 0)
         {
            if(_editor != null)
            {
               _editor.visible = false;
            }
            return;
         }
         ensureEditor();
         if(_editor != null)
         {
            _editor.visible = true;
            _editor.refresh();
         }
      }
      
      private function ensureEditor() : void
      {
         if(_editor != null || _windowManager == null)
         {
            return;
         }
         try
         {
            BobbaI18n.init();
            _editor = new BobbaGroupWhisperEditor(_windowManager,this);
         }
         catch(e:Error)
         {
         }
      }
      
      private function indexOfName(name:String) : int
      {
         var i:int = 0;
         var key:String = null;
         if(_members == null || name == null)
         {
            return -1;
         }
         key = name.toLowerCase();
         for(i = 0; i < _members.length; i++)
         {
            if(String(_members[i]).toLowerCase() == key)
            {
               return i;
            }
         }
         return -1;
      }
      
      private function ownNickname() : String
      {
         try
         {
            if(_backend != null && _backend.nickname != null && _backend.nickname.length > 0)
            {
               return _backend.nickname;
            }
            if(_windowManager != null && _windowManager.sessionDataManager != null)
            {
               return _windowManager.sessionDataManager.userName;
            }
         }
         catch(err:Error)
         {
         }
         return "";
      }
      
      private function showBubbleForNickname(nickname:String, body:String) : void
      {
         var session:* = null;
         var userData:* = null;
         var roomId:int = 0;
         var groupLabel:String = null;
         var displayName:String = null;
         var evt:RoomSessionChatEvent = null;
         var ffc:HabboFreeFlowChat = null;
         var roomObj:* = null;
         var location:* = null;
         var figure:String = null;
         try
         {
            if(_windowManager == null || _windowManager.roomEngine == null || _windowManager.LilithCustomsInstance == null)
            {
               return;
            }
            if(!_windowManager.LilithCustomsInstance.IsRoomSessionAvailable)
            {
               return;
            }
            session = _windowManager.LilithCustomsInstance.RoomSession;
            if(session == null || session.userDataManager == null)
            {
               return;
            }
            if(nickname == null || nickname.length == 0)
            {
               return;
            }
            userData = session.userDataManager.getUserDataByName(nickname);
            if(userData == null)
            {
               return;
            }
            roomId = int(userData.roomObjectId);
            BobbaI18n.init();
            groupLabel = BobbaI18n.t("groupwhisper.bubble.group","group");
            displayName = nickname + "(" + groupLabel + ")";
            evt = new RoomSessionChatEvent("RSCE_CHAT_EVENT",session,roomId,body,1,0,null);
            evt = _windowManager.LilithCustomsInstance.OnRoomChat(evt);
            if(evt == null || evt.session == null)
            {
               return;
            }
            ffc = _windowManager.freeFlowChat as HabboFreeFlowChat;
            if(ffc != null)
            {
               roomObj = _windowManager.roomEngine.getRoomObject(session.roomId,roomId,100);
               if(roomObj != null)
               {
                  location = roomObj.getLocation();
               }
               figure = userData.figure != null ? String(userData.figure) : null;
               ffc.insertChat(new ChatItem(evt,getTimer(),location,0,null,null,figure,displayName));
               return;
            }
            _windowManager.roomEngine.roomSessionManager.events.dispatchEvent(new RoomSessionChatEvent("RSCE_CHAT_EVENT",session,roomId,body,1,0,null));
         }
         catch(bubbleErr:Error)
         {
         }
      }
      
      private function alert(message:String) : void
      {
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null)
            {
               _windowManager.LilithCustomsInstance.ShowWhisperAlert(message);
            }
         }
         catch(alertErr:Error)
         {
         }
      }
   }
}
