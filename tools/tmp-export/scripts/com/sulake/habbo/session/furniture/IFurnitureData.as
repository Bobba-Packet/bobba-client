package com.sulake.habbo.session.furniture
{
   public interface IFurnitureData
   {
      
      function get type() : String;
      
      function get id() : int;
      
      function get className() : String;
      
      function get fullName() : String;
      
      function get hasIndexedColor() : Boolean;
      
      function get colourIndex() : int;
      
      function get revision() : int;
      
      function get tileSizeX() : int;
      
      function get tileSizeY() : int;
      
      function get tileSizeZ() : int;
      
      function get colours() : Array;
      
      function get localizedName() : String;
      
      function get description() : String;
      
      function get adUrl() : String;
      
      function get purchaseOfferId() : int;
      
      function get bcOfferId() : int;
      
      function get rentOfferId() : int;
      
      function get customParams() : String;
      
      function get category() : int;
      
      function get furniDataCategory() : String;
      
      function get purchaseCouldBeUsedForBuyout() : Boolean;
      
      function get rentCouldBeUsedForBuyout() : Boolean;
      
      function get availableForBuildersClub() : Boolean;
      
      function get canStandOn() : Boolean;
      
      function get canSitOn() : Boolean;
      
      function get canLayOn() : Boolean;
      
      function get canPutStuffOn() : Boolean;
      
      function get height() : Number;
      
      function get isExternalImageType() : Boolean;
      
      function get excludedFromDynamic() : Boolean;
      
      function get furniLine() : String;
      
      function get tradeable() : Boolean;
      
      function get recyclable() : Boolean;
   }
}

