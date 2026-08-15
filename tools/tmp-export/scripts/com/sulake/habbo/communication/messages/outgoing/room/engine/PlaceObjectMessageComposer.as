package com.sulake.habbo.communication.messages.outgoing.room.engine
{
   import com.sulake.core.communication.messages.IMessageComposer;
   
   [SecureSWF(rename="true")]
   public class PlaceObjectMessageComposer implements IMessageComposer
   {
      
      private var UnknownVarFromPlaceObjectMessageComposer_Int_1:int;
      
      private var UnknownVarFromPlaceObjectMessageComposer_Int_2:int;
      
      private var UnknownVarFromPlaceObjectMessageComposer_String_1:String;
      
      private var UnknownVarFromPlaceObjectMessageComposer_Int_3:int = 0;
      
      private var UnknownVarFromPlaceObjectMessageComposer_Int_4:int = 0;
      
      private var UnknownVarFromPlaceObjectMessageComposer_Int_5:int = 0;
      
      public function PlaceObjectMessageComposer(param1:int, param2:int, param3:String, param4:int, param5:int, param6:int)
      {
         super();
         UnknownVarFromPlaceObjectMessageComposer_Int_1 = param1;
         UnknownVarFromPlaceObjectMessageComposer_Int_2 = param2;
         UnknownVarFromPlaceObjectMessageComposer_String_1 = param3;
         UnknownVarFromPlaceObjectMessageComposer_Int_3 = param4;
         UnknownVarFromPlaceObjectMessageComposer_Int_4 = param5;
         UnknownVarFromPlaceObjectMessageComposer_Int_5 = param6;
      }
      
      public function dispose() : void
      {
      }
      
      public function getMessageArray() : Array
      {
         switch(UnknownVarFromPlaceObjectMessageComposer_Int_2 - 10)
         {
            case 0:
               return [UnknownVarFromPlaceObjectMessageComposer_Int_1 + " " + UnknownVarFromPlaceObjectMessageComposer_Int_3 + " " + UnknownVarFromPlaceObjectMessageComposer_Int_4 + " " + UnknownVarFromPlaceObjectMessageComposer_Int_5];
            case 10:
               return [UnknownVarFromPlaceObjectMessageComposer_Int_1 + " " + UnknownVarFromPlaceObjectMessageComposer_String_1];
            default:
               return [];
         }
      }
   }
}

