package com.sulake.habbo.session.furniture
{
   public class FurnitureData implements IFurnitureData
   {
      
      public static const UnknownConstFromFurnitureData_String_1:String = "i";
      
      public static const UnknownConstFromFurnitureData_String_2:String = "s";
      
      private var _type:String;
      
      private var _id:int;
      
      private var _className:String;
      
      private var _hasIndexedColor:Boolean;
      
      private var _colourIndex:int;
      
      private var _revision:int;
      
      private var _tileSizeX:int;
      
      private var _tileSizeY:int;
      
      private var _tileSizeZ:int;
      
      private var _colours:Array;
      
      private var _localizedName:String;
      
      private var _description:String;
      
      private var _adUrl:String;
      
      private var _purchaseOfferId:int;
      
      private var _rentOfferId:int;
      
      private var _customParams:String;
      
      private var _category:int;
      
      private var _furniDataCategory:String;
      
      private var _purchaseCouldBeUsedForBuyout:Boolean;
      
      private var _rentCouldBeUsedForBuyout:Boolean;
      
      private var _availableForBuildersClub:Boolean;
      
      private var _fullName:String;
      
      private var _canStandOn:Boolean;
      
      private var _canSitOn:Boolean;
      
      private var _canLayOn:Boolean;
      
      private var _canPutStuffOn:Boolean;
      
      private var _height:Number;
      
      private var _excludedFromDynamic:Boolean;
      
      private var _furniLine:String;
      
      private var _bcOfferId:int;
      
      private var _tradeable:Boolean;
      
      private var _recyclable:Boolean;
      
      public function FurnitureData(param1:String, param2:int, param3:String, param4:String, param5:String, param6:String, param7:int, param8:int, param9:int, param10:int, param11:Array, param12:Boolean, param13:int, param14:String, param15:int, param16:Boolean, param17:int, param18:Boolean, param19:Boolean, param20:String, param21:int, param22:String, param23:Boolean, param24:Boolean, param25:Boolean, param26:Boolean, param27:Number, param28:Boolean, param29:String, param30:int, param31:Boolean, param32:Boolean)
      {
         super();
         _type = param1;
         _id = param2;
         _fullName = param3;
         _className = param4;
         _revision = param7;
         _tileSizeX = param8;
         _tileSizeY = param9;
         _tileSizeZ = param10;
         _colours = param11;
         _hasIndexedColor = param12;
         _colourIndex = param13;
         _localizedName = param5;
         _description = param6;
         _adUrl = param14;
         _purchaseOfferId = param15;
         _purchaseCouldBeUsedForBuyout = param16;
         _rentOfferId = param17;
         _rentCouldBeUsedForBuyout = param18;
         _customParams = param20;
         _category = param21;
         _furniDataCategory = param22;
         _availableForBuildersClub = param19;
         _canStandOn = param23;
         _canSitOn = param24;
         _canLayOn = param25;
         _canPutStuffOn = param26;
         _height = param27;
         _excludedFromDynamic = param28;
         _furniLine = param29;
         _bcOfferId = param30;
         _tradeable = param31;
         _recyclable = param32;
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get className() : String
      {
         return _className;
      }
      
      public function get fullName() : String
      {
         return _fullName;
      }
      
      public function get hasIndexedColor() : Boolean
      {
         return _hasIndexedColor;
      }
      
      public function get colourIndex() : int
      {
         return _colourIndex;
      }
      
      public function get revision() : int
      {
         return _revision;
      }
      
      public function get tileSizeX() : int
      {
         return _tileSizeX;
      }
      
      public function get tileSizeY() : int
      {
         return _tileSizeY;
      }
      
      public function get tileSizeZ() : int
      {
         return _tileSizeZ;
      }
      
      public function get colours() : Array
      {
         return _colours;
      }
      
      public function get localizedName() : String
      {
         return _localizedName;
      }
      
      public function get description() : String
      {
         return _description;
      }
      
      public function get adUrl() : String
      {
         return _adUrl;
      }
      
      public function get purchaseOfferId() : int
      {
         return _purchaseOfferId;
      }
      
      public function get bcOfferId() : int
      {
         return _bcOfferId;
      }
      
      public function get customParams() : String
      {
         return _customParams;
      }
      
      public function get category() : int
      {
         return _category;
      }
      
      public function get furniDataCategory() : String
      {
         return _furniDataCategory;
      }
      
      public function set className(param1:String) : void
      {
         _className = param1;
      }
      
      public function get rentOfferId() : int
      {
         return _rentOfferId;
      }
      
      public function get purchaseCouldBeUsedForBuyout() : Boolean
      {
         return _purchaseCouldBeUsedForBuyout;
      }
      
      public function get rentCouldBeUsedForBuyout() : Boolean
      {
         return _rentCouldBeUsedForBuyout;
      }
      
      public function get availableForBuildersClub() : Boolean
      {
         return _availableForBuildersClub;
      }
      
      public function get canStandOn() : Boolean
      {
         return _canStandOn;
      }
      
      public function get canSitOn() : Boolean
      {
         return _canSitOn;
      }
      
      public function get canLayOn() : Boolean
      {
         return _canLayOn;
      }
      
      public function get canPutStuffOn() : Boolean
      {
         return _canPutStuffOn;
      }
      
      public function get height() : Number
      {
         return _height;
      }
      
      public function get isExternalImageType() : Boolean
      {
         return _className.indexOf("external_image") != -1;
      }
      
      public function get excludedFromDynamic() : Boolean
      {
         return _excludedFromDynamic;
      }
      
      public function get furniLine() : String
      {
         return _furniLine;
      }
      
      public function get tradeable() : Boolean
      {
         return _tradeable;
      }
      
      public function get recyclable() : Boolean
      {
         return _recyclable;
      }
   }
}

