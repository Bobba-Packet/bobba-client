package com.sulake.habbo.communication.messages.outgoing.room.engine
{
   import com.sulake.core.communication.messages.IMessageComposer;
   
   [SecureSWF(rename="true")]
   public class MoveObjectMessageComposer implements IMessageComposer
   {
      
      private var UnknownVarFromMoveObjectMessageComposer_Int_1:int;
      
      private var UnknownVarFromMoveObjectMessageComposer_Int_2:int;
      
      private var UnknownVarFromMoveObjectMessageComposer_Int_3:int;
      
      private var UnknownVarFromMoveObjectMessageComposer_Int_4:int;
      
      public function MoveObjectMessageComposer(param1:int, param2:int, param3:int, param4:int)
      {
         super();
         UnknownVarFromMoveObjectMessageComposer_Int_1 = param1;
         UnknownVarFromMoveObjectMessageComposer_Int_2 = param2;
         UnknownVarFromMoveObjectMessageComposer_Int_3 = param3;
         UnknownVarFromMoveObjectMessageComposer_Int_4 = param4;
      }
      
      public function dispose() : void
      {
      }
      
      public function getMessageArray() : Array
      {
         return [UnknownVarFromMoveObjectMessageComposer_Int_1,UnknownVarFromMoveObjectMessageComposer_Int_2,UnknownVarFromMoveObjectMessageComposer_Int_3,UnknownVarFromMoveObjectMessageComposer_Int_4];
      }
   }
}

