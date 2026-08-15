package com.sulake.habbo.catalog.viewer
{
   import com.sulake.core.runtime.IComponentInterfaceQueue;
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.habbo.avatar.UnknownIHabboAvatar1;
   import com.sulake.habbo.catalog.UnknownIHabboCatalog1;
   import com.sulake.habbo.room.IStuffData;
   import com.sulake.habbo.room.UnknownIHabboRoom1;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.session.product.IProductData;
   import flash.display.BitmapData;
   
   public interface IProduct extends UnknownIHabboRoom1, IComponentInterfaceQueue
   {
      
      function get productType() : String;
      
      function get productClassId() : int;
      
      function set extraParam(param1:String) : void;
      
      function get extraParam() : String;
      
      function get productCount() : int;
      
      function get productData() : IProductData;
      
      function get furnitureData() : IFurnitureData;
      
      function get isUniqueLimitedItem() : Boolean;
      
      function get isColorable() : Boolean;
      
      function get uniqueLimitedItemSeriesSize() : int;
      
      function get uniqueLimitedItemsLeft() : int;
      
      function set uniqueLimitedItemsLeft(param1:int) : void;
      
      function initIcon(param1:IProductContainer, param2:UnknownIHabboRoom1 = null, param3:UnknownIHabboAvatar1 = null, param4:UnknownIHabboCatalog1 = null, param5:IBitmapWrapperController = null, param6:IStuffData = null, param7:Function = null) : BitmapData;
      
      function set view(param1:IWindowController_1) : void;
      
      function set grid(param1:IItemGrid) : void;
   }
}

