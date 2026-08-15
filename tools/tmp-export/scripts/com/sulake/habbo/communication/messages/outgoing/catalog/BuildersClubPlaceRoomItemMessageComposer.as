package com.sulake.habbo.communication.messages.outgoing.catalog
{
   import com.sulake.core.communication.messages.IMessageComposer;
   
   [SecureSWF(rename="true")]
   public class BuildersClubPlaceRoomItemMessageComposer implements IMessageComposer
   {
      
      private var _messageArray:Array = [];
      
      public function BuildersClubPlaceRoomItemMessageComposer(param1:int, param2:int, param3:String, param4:int, param5:int, param6:int, param7:Boolean = false)
      {
         super();
         _messageArray = [param1,param2,param3,param4,param5,param6,param7];
      }
      
      public function getMessageArray() : Array
      {
         return _messageArray;
      }
      
      public function dispose() : void
      {
         _messageArray = null;
      }
   }
}

