package com.sulake.habbo.inventory.items
{
   import com.sulake.habbo.communication.messages.incoming.inventory.furni.IFurniData;
   import com.sulake.habbo.room.IStuffData;
   import flash.utils.getTimer;
   
   public class FurnitureItem implements IFurnitureItem
   {
      
      private var _expirationTimeStamp:int;
      
      private var _isWallItem:Boolean;
      
      private var _songId:int;
      
      private var _locked:Boolean;
      
      private var _id:int;
      
      private var _ref:int;
      
      private var _category:int;
      
      private var _type:int;
      
      private var _stuffData:IStuffData;
      
      private var _extra:Number;
      
      private var _recyclable:Boolean;
      
      private var _tradeable:Boolean;
      
      private var _groupable:Boolean;
      
      private var _sellable:Boolean;
      
      private var UnknownVarFromFurnitureItem_Int_1:int;
      
      private var _hasRentPeriodStarted:Boolean;
      
      private var _creationDay:int;
      
      private var _creationMonth:int;
      
      private var _creationYear:int;
      
      private var _slotId:String;
      
      private var _isRented:Boolean;
      
      private var _flatId:int;
      
      public function FurnitureItem(param1:IFurniData)
      {
         super();
         _id = param1.itemId;
         _type = param1.itemTypeId;
         _ref = param1.roomItemId;
         _category = param1.category;
         _groupable = param1.isGroupable && !param1.isRented;
         _tradeable = param1.isTradeable;
         _recyclable = param1.isRecyclable;
         _sellable = param1.isSellable;
         _stuffData = param1.stuffData;
         _extra = param1.extra;
         UnknownVarFromFurnitureItem_Int_1 = param1.secondsToExpiration;
         _expirationTimeStamp = param1.expirationTimeStamp;
         _hasRentPeriodStarted = param1.hasRentPeriodStarted;
         _creationDay = param1.creationDay;
         _creationMonth = param1.creationMonth;
         _creationYear = param1.creationYear;
         _slotId = param1.slotId;
         _songId = param1.songId;
         _flatId = param1.flatId;
         _isRented = param1.isRented;
         _isWallItem = param1.isWallItem;
      }
      
      public function get isRented() : Boolean
      {
         return _isRented;
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get ref() : int
      {
         return _ref;
      }
      
      public function get category() : int
      {
         return _category;
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get stuffData() : IStuffData
      {
         return _stuffData;
      }
      
      public function set stuffData(param1:IStuffData) : void
      {
         _stuffData = param1;
      }
      
      public function get extra() : Number
      {
         return _extra;
      }
      
      public function get recyclable() : Boolean
      {
         return _recyclable;
      }
      
      public function get tradeable() : Boolean
      {
         return _tradeable;
      }
      
      public function get groupable() : Boolean
      {
         return _groupable;
      }
      
      public function get sellable() : Boolean
      {
         return _sellable;
      }
      
      public function get secondsToExpiration() : int
      {
         if(UnknownVarFromFurnitureItem_Int_1 == -1)
         {
            return -1;
         }
         var _loc1_:int = -1;
         if(_hasRentPeriodStarted)
         {
            _loc1_ = UnknownVarFromFurnitureItem_Int_1 - (getTimer() - _expirationTimeStamp) / 1000;
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
         }
         else
         {
            _loc1_ = UnknownVarFromFurnitureItem_Int_1;
         }
         return _loc1_;
      }
      
      public function get creationDay() : int
      {
         return _creationDay;
      }
      
      public function get creationMonth() : int
      {
         return _creationMonth;
      }
      
      public function get creationYear() : int
      {
         return _creationYear;
      }
      
      public function get slotId() : String
      {
         return _slotId;
      }
      
      public function get songId() : int
      {
         return _songId;
      }
      
      public function get locked() : Boolean
      {
         return _locked;
      }
      
      public function set locked(param1:Boolean) : void
      {
         _locked = param1;
      }
      
      public function get flatId() : int
      {
         return _flatId;
      }
      
      public function get isWallItem() : Boolean
      {
         return _isWallItem;
      }
      
      public function get hasRentPeriodStarted() : Boolean
      {
         return _hasRentPeriodStarted;
      }
      
      public function get expirationTimeStamp() : int
      {
         return _expirationTimeStamp;
      }
      
      public function update(param1:IFurniData) : void
      {
         _type = param1.itemTypeId;
         _ref = param1.roomItemId;
         _category = param1.category;
         _groupable = param1.isGroupable && !param1.isRented;
         _tradeable = param1.isTradeable;
         _recyclable = param1.isRecyclable;
         _sellable = param1.isSellable;
         _stuffData = param1.stuffData;
         _extra = param1.extra;
         UnknownVarFromFurnitureItem_Int_1 = param1.secondsToExpiration;
         _expirationTimeStamp = param1.expirationTimeStamp;
         _hasRentPeriodStarted = param1.hasRentPeriodStarted;
         _creationDay = param1.creationDay;
         _creationMonth = param1.creationMonth;
         _creationYear = param1.creationYear;
         _slotId = param1.slotId;
         _songId = param1.songId;
         _flatId = param1.flatId;
         _isRented = param1.isRented;
         _isWallItem = param1.isWallItem;
      }
   }
}

