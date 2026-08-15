package com.sulake.habbo.communication.messages.outgoing.room.furniture
{
   import com.sulake.core.communication.messages.IMessageComposer;
   
   [SecureSWF(rename="true")]
   public class SetCustomStackingHeightComposer implements IMessageComposer
   {
      
      private var _messageArray:Array;
      
      public function SetCustomStackingHeightComposer(param1:Array)
      {
         super();
         _messageArray = param1;
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

