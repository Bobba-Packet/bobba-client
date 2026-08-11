package com.sulake.habbo.window.utils.bobba
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   public class BobbaWireCodec
   {
      
      public static const HELLO:int = 1;
      
      public static const CHALLENGE:int = 2;
      
      public static const AUTH:int = 3;
      
      public static const AUTH_OK:int = 4;
      
      public static const AUTH_FAIL:int = 5;
      
      public static const UPDATE_PROFILE:int = 10;
      
      public static const HEARTBEAT:int = 11;
      
      public static const HEARTBEAT_ACK:int = 12;
      
      public static const SERVER_MESSAGE:int = 20;
      
      public static const CREATE_GROUP:int = 30;
      
      public static const GROUP_CREATED:int = 31;
      
      public static const LIST_GROUPS:int = 32;
      
      public static const GROUPS_LIST:int = 33;
      
      public static const INVITE_TO_GROUP:int = 34;
      
      public static const INVITE_NOTIFY:int = 35;
      
      public static const RESPOND_INVITE:int = 36;
      
      public static const INVITE_RESOLVED:int = 37;
      
      public static const SEND_GROUP_MESSAGE:int = 38;
      
      public static const GROUP_MESSAGE:int = 39;
      
      public static const OPEN_GROUP:int = 40;
      
      public static const GROUP_HISTORY:int = 41;
      
      public static const GROUP_ERROR:int = 42;
      
      public static const LIST_PENDING_INVITES:int = 43;
      
      public static const PENDING_INVITES:int = 44;
      
      public static const LEAVE_GROUP:int = 45;
      
      public static const GROUP_LEFT:int = 46;
      
      public static const LIST_GROUP_MEMBERS:int = 47;
      
      public static const GROUP_MEMBERS:int = 48;
      
      public static const GROUP_EVENT:int = 49;
      
      public static const MARK_GROUP_READ:int = 50;
      
      public static const SEND_ROOM_WHISPER:int = 60;
      
      public static const ROOM_WHISPER:int = 61;
      
      public static const LOOKUP_BOBBA_USERS:int = 62;
      
      public static const BOBBA_USERS_RESULT:int = 63;
      
      public function BobbaWireCodec()
      {
         super();
      }
      
      public static function encode(id:int, fields:Array) : ByteArray
      {
         var packet:ByteArray = new ByteArray();
         var i:int = 0;
         var value:* = null;
         var total:uint = 0;
         packet.endian = Endian.BIG_ENDIAN;
         packet.writeInt(0);
         packet.writeShort(id);
         for(i = 0; i < fields.length; i++)
         {
            value = fields[i];
            if(value is String)
            {
               packet.writeUTF(value as String);
            }
            else if(value is Boolean)
            {
               packet.writeBoolean(value as Boolean);
            }
            else
            {
               packet.writeInt(int(value));
            }
         }
         total = packet.length;
         packet.position = 0;
         packet.writeInt(total - 4);
         packet.position = total;
         return packet;
      }
      
      public static function split(buffer:ByteArray) : Array
      {
         var packets:Array = [];
         var length:int = 0;
         var body:ByteArray = null;
         var id:int = 0;
         var payload:ByteArray = null;
         var remain:ByteArray = null;
         buffer.endian = Endian.BIG_ENDIAN;
         buffer.position = 0;
         while(buffer.bytesAvailable >= 4)
         {
            length = buffer.readInt();
            if(length < 2 || length > 262144)
            {
               throw new Error("Invalid Bobba packet length");
            }
            if(buffer.bytesAvailable < length)
            {
               buffer.position -= 4;
               break;
            }
            body = new ByteArray();
            body.endian = Endian.BIG_ENDIAN;
            buffer.readBytes(body,0,length);
            body.position = 0;
            id = body.readShort();
            payload = new ByteArray();
            payload.endian = Endian.BIG_ENDIAN;
            if(body.bytesAvailable > 0)
            {
               body.readBytes(payload);
            }
            payload.position = 0;
            packets.push({
               "id":id,
               "payload":payload
            });
         }
         if(buffer.position > 0)
         {
            remain = new ByteArray();
            if(buffer.bytesAvailable > 0)
            {
               buffer.readBytes(remain);
            }
            buffer.length = 0;
            buffer.position = 0;
            if(remain.length > 0)
            {
               buffer.writeBytes(remain);
            }
         }
         return packets;
      }
      
      public static function readString(payload:ByteArray) : String
      {
         payload.endian = Endian.BIG_ENDIAN;
         return payload.readUTF();
      }
      
      public static function readInt(payload:ByteArray) : int
      {
         payload.endian = Endian.BIG_ENDIAN;
         return payload.readInt();
      }
   }
}
