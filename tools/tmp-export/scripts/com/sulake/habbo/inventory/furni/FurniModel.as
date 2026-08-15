package com.sulake.habbo.inventory.furni
{
   import com.sulake.core.assets.IAssetLibraryCollection;
   import com.sulake.core.assets.ISoundAsset;
   import com.sulake.core.assets.XmlAsset;
   import com.sulake.core.communication.connection.IConnection;
   import com.sulake.core.utils.Map;
   import com.sulake.core.utils.Set;
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.components.ITextFieldWindow;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.utils.UnknownICoreWindowUtils1;
   import com.sulake.habbo.catalog.IHabboCatalog;
   import com.sulake.habbo.communication.IHabboCommunicationManager;
   import com.sulake.habbo.communication.messages.incoming.inventory.furni.FurniData;
   import com.sulake.habbo.communication.messages.outgoing.inventory.furni.RequestFurniInventoryComposer;
   import com.sulake.habbo.communication.messages.outgoing.inventory.furni.RequestFurniInventoryWhenNotInRoomComposer;
   import com.sulake.habbo.communication.messages.outgoing.inventory.furni.RequestRoomPropertySet;
   import com.sulake.habbo.communication.messages.outgoing.room.session.OpenFlatConnectionMessageComposer;
   import com.sulake.habbo.inventory.HabboInventory;
   import com.sulake.habbo.inventory.IInventoryModel;
   import com.sulake.habbo.inventory.IUnseenItemTracker;
   import com.sulake.habbo.inventory.events.HabboInventoryCategoryInitializeEvent;
   import com.sulake.habbo.inventory.items.CreditTradingItem;
   import com.sulake.habbo.inventory.items.FurnitureItem;
   import com.sulake.habbo.inventory.items.GroupItem;
   import com.sulake.habbo.inventory.items.IFurnitureItem;
   import com.sulake.habbo.inventory.marketplace.MarketplaceModel;
   import com.sulake.habbo.inventory.recycler.RecyclerModel;
   import com.sulake.habbo.inventory.trading.ITradingModel;
   import com.sulake.habbo.localization.IHabboLocalizationManager;
   import com.sulake.habbo.room.IRoomEngine;
   import com.sulake.habbo.room.IStuffData;
   import com.sulake.habbo.room.events.RoomEngineObjectPlacedEvent;
   import com.sulake.habbo.room.object.data.LegacyStuffData;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.sound.IHabboSoundManagerFlash10;
   import com.sulake.habbo.window.IHabboWindowManagerComponent;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class FurniModel implements IInventoryModel
   {
      
      private static const IMAGE_UPDATE_DELAY_MS:int = 50;
      
      private var _controller:HabboInventory;
      
      private var UnknownVarFromFurniModel_FurniView_1:FurniView;
      
      private var _furniData:Vector.<GroupItem>;
      
      private var _assets:IAssetLibraryCollection;
      
      private var _windowManager:IHabboWindowManagerComponent;
      
      private var _roomEngine:IRoomEngine;
      
      private var _communication:IHabboCommunicationManager;
      
      private var _soundManager:IHabboSoundManagerFlash10;
      
      private var _disposed:Boolean = false;
      
      private var UnknownVarFromFurniModel_Int_1:int = -1;
      
      private var UnknownVarFromFurniModel_Boolean_1:Boolean;
      
      private var UnknownVarFromFurniModel_Timer_1:Timer;
      
      private var _isListInited:Boolean;
      
      private var _catalog:IHabboCatalog;
      
      private var _thumbWindowTemplates:Dictionary;
      
      private var _localization:IHabboLocalizationManager;
      
      private var UnknownVarFromFurniModel_Array_1:Array;
      
      private var _showingRentedFurni:Boolean;
      
      private var UnknownVarFromFurniModel_Dictionary_1:Dictionary;
      
      private var UnknownVarFromFurniModel_String_1:String;
      
      private var _imageUpdateCumulativeTime:int = 0;
      
      private var _roomItemToSelect:FurnitureItem = null;
      
      private var _isInRoom:Boolean = false;
      
      private var _showingNfts:Boolean = true;
      
      public function FurniModel(param1:HabboInventory, param2:MarketplaceModel, param3:IHabboWindowManagerComponent, param4:IHabboCommunicationManager, param5:IAssetLibraryCollection, param6:IRoomEngine, param7:IHabboCatalog, param8:IHabboSoundManagerFlash10, param9:IHabboLocalizationManager)
      {
         super();
         _controller = param1;
         _communication = param4;
         _windowManager = param3;
         _assets = param5;
         _roomEngine = param6;
         _roomEngine.events.addEventListener("REOE_PLACED",onObjectPlaced);
         _catalog = param7;
         _soundManager = param8;
         _localization = param9;
         _thumbWindowTemplates = new Dictionary();
         UnknownVarFromFurniModel_Array_1 = _controller.getProperty("catalog.preview.alignment.bottom").split(",");
         UnknownVarFromFurniModel_Timer_1 = new Timer(50);
         UnknownVarFromFurniModel_Timer_1.addEventListener("timer",onImageUpdateTimerEvent);
         UnknownVarFromFurniModel_Dictionary_1 = new Dictionary();
         UnknownVarFromFurniModel_Dictionary_1["furni"] = null;
         UnknownVarFromFurniModel_Dictionary_1["rentables"] = null;
         clearFurniList();
         UnknownVarFromFurniModel_FurniView_1 = new FurniView(this,param2,_windowManager,_assets,_roomEngine);
      }
      
      private static function arrayToSet(param1:Array) : Dictionary
      {
         var _loc2_:Dictionary = new Dictionary();
         for each(var _loc3_ in param1)
         {
            _loc2_[_loc3_] = true;
         }
         return _loc2_;
      }
      
      public function get disposed() : Boolean
      {
         return _disposed;
      }
      
      public function get controller() : HabboInventory
      {
         return _controller;
      }
      
      public function get localization() : IHabboLocalizationManager
      {
         return _localization;
      }
      
      public function get isTradingOpen() : Boolean
      {
         return _controller.getSubCategoryViewId() == "trading" || _controller.getSubCategoryViewId() == "wired_trading";
      }
      
      public function get isPrivateRoom() : Boolean
      {
         if(!_controller || !_controller.roomSession)
         {
            return false;
         }
         return _controller.roomSession.isPrivateRoom;
      }
      
      public function get furniData() : Vector.<GroupItem>
      {
         return _furniData;
      }
      
      public function get soundManager() : IHabboSoundManagerFlash10
      {
         return _soundManager;
      }
      
      public function get showingRentedFurni() : Boolean
      {
         return _showingRentedFurni;
      }
      
      public function set categorySelection(param1:GroupItem) : void
      {
         UnknownVarFromFurniModel_Dictionary_1[UnknownVarFromFurniModel_String_1] = param1;
      }
      
      public function dispose() : void
      {
         if(!_disposed)
         {
            _controller = null;
            if(_furniData != null)
            {
               _furniData = null;
            }
            if(UnknownVarFromFurniModel_FurniView_1 != null)
            {
               UnknownVarFromFurniModel_FurniView_1.dispose();
               UnknownVarFromFurniModel_FurniView_1 = null;
            }
            if(_roomEngine != null)
            {
               if(_roomEngine.events != null)
               {
                  _roomEngine.events.removeEventListener("REOE_PLACED",onObjectPlaced);
               }
               _roomEngine = null;
            }
            _communication = null;
            _assets = null;
            _windowManager = null;
            _catalog = null;
            _soundManager = null;
            _localization = null;
            if(UnknownVarFromFurniModel_Timer_1 != null)
            {
               UnknownVarFromFurniModel_Timer_1.removeEventListener("timer",onImageUpdateTimerEvent);
               UnknownVarFromFurniModel_Timer_1.stop();
               UnknownVarFromFurniModel_Timer_1 = null;
            }
            for each(var _loc1_ in _thumbWindowTemplates)
            {
               if(_loc1_ != null)
               {
                  _loc1_.dispose();
               }
            }
            _thumbWindowTemplates = null;
            _disposed = true;
         }
      }
      
      public function createItemWindow(param1:*) : IWindowController_1
      {
         var _loc4_:ISoundAsset = null;
         var _loc2_:XmlAsset = null;
         var _loc3_:XML = null;
         if(_thumbWindowTemplates[param1] == null)
         {
            _loc4_ = _assets.getAssetByName(param1);
            _loc2_ = XmlAsset(_loc4_);
            _loc3_ = XML(_loc2_.content);
            _thumbWindowTemplates[param1] = _windowManager.buildFromXML(_loc3_) as IWindowController_1;
         }
         return _thumbWindowTemplates[param1].clone();
      }
      
      public function insertFurniture(param1:Map) : void
      {
         var _loc2_:FurnitureItem = null;
         var _loc4_:FurniData = null;
         var _loc7_:int = 0;
         var _loc11_:int = 0;
         var _loc14_:HabboInventoryCategoryInitializeEvent = null;
         var _loc5_:Boolean = _controller.setInventoryCategoryInit("furni");
         var _loc12_:Dictionary = getAllStripIds();
         var _loc9_:Array = param1.getKeys();
         var _loc10_:Dictionary = arrayToSet(_loc9_);
         var _loc3_:Vector.<int> = new Vector.<int>(0);
         var _loc13_:Vector.<int> = new Vector.<int>(0);
         for each(var _loc6_ in _loc9_)
         {
            if(!(_loc6_ in _loc12_))
            {
               _loc3_.push(_loc6_);
            }
         }
         for(_loc11_ in _loc12_)
         {
            if(!(_loc11_ in _loc10_))
            {
               _loc13_.push(_loc11_);
            }
         }
         var _loc8_:* = _loc12_.length == 0;
         for each(_loc11_ in _loc13_)
         {
            removeFurni(_loc11_);
         }
         for each(_loc11_ in _loc3_)
         {
            _loc4_ = FurniData(param1.getValue(_loc11_));
            _loc2_ = new FurnitureItem(_loc4_);
            addOrUpdateItem(_loc2_,true);
         }
         if(!_loc8_)
         {
            if(_loc3_.length > 0)
            {
               updateItemLocks();
            }
         }
         setListInitialized();
         UnknownVarFromFurniModel_FurniView_1.addItems(_furniData);
         if(_loc8_)
         {
            selectFirstItem();
         }
         else if(getSelectedItem() == null)
         {
            selectFirstItem();
         }
         setViewToState();
         initListImages();
         if(_loc5_)
         {
            _loc14_ = new HabboInventoryCategoryInitializeEvent("furni");
            _controller.events.dispatchEvent(_loc14_);
         }
      }
      
      public function isListInited() : Boolean
      {
         return _isListInited;
      }
      
      public function setListInitialized() : void
      {
         _isListInited = true;
      }
      
      public function createGroupItem(param1:int, param2:int, param3:IStuffData, param4:Number = NaN, param5:Boolean = false) : GroupItem
      {
         var _loc8_:BitmapData = null;
         var _loc7_:ISoundAsset = null;
         if(param2 == 2)
         {
            _loc7_ = _windowManager.assets.getAssetByName("inventory_furni_icon_wallpaper");
            if(_loc7_ != null)
            {
               _loc8_ = (_loc7_.content as BitmapData).clone();
            }
         }
         else if(param2 == 3)
         {
            _loc7_ = _windowManager.assets.getAssetByName("inventory_furni_icon_floor");
            if(_loc7_ != null)
            {
               _loc8_ = (_loc7_.content as BitmapData).clone();
            }
         }
         else if(param2 == 4)
         {
            _loc7_ = _windowManager.assets.getAssetByName("inventory_furni_icon_landscape");
            if(_loc7_ != null)
            {
               _loc8_ = (_loc7_.content as BitmapData).clone();
            }
         }
         var _loc9_:String = "center";
         var _loc6_:String = _roomEngine.getFurnitureType(param1);
         if(UnknownVarFromFurniModel_Array_1.indexOf(_loc6_) > -1)
         {
            _loc9_ = "bottom";
         }
         return new GroupItem(this,param1,param2,_roomEngine,_controller.recyclerModel.running,param3,param4,_loc8_,param5,_loc9_);
      }
      
      public function createCreditGroupItem(param1:int) : GroupItem
      {
         return new CreditTradingItem(this,_windowManager.assets,_roomEngine,param1);
      }
      
      public function requestInitialization() : void
      {
         var _loc1_:IConnection = _communication.connection;
         if(_loc1_ != null)
         {
            if(_isInRoom)
            {
               _loc1_.send(new RequestFurniInventoryComposer());
            }
            else
            {
               _loc1_.send(new RequestFurniInventoryWhenNotInRoomComposer());
            }
         }
      }
      
      public function categorySwitch(param1:String) : void
      {
         if(_controller.isVisible)
         {
            Logger.log("FurniMode.categorySwitch: " + param1);
            switch(param1)
            {
               case "furni":
               case "rentables":
                  UnknownVarFromFurniModel_String_1 = param1;
                  _showingRentedFurni = UnknownVarFromFurniModel_String_1 == "rentables";
                  UnknownVarFromFurniModel_FurniView_1.resetFilters(param1);
                  updateCategorySelection();
                  updateItemLocks();
            }
         }
      }
      
      public function getWindowContainer() : IWindowController_1
      {
         _controller.checkCategoryInitilization("marketplace");
         return UnknownVarFromFurniModel_FurniView_1.getWindowContainer();
      }
      
      public function closingInventoryView() : void
      {
         if(UnknownVarFromFurniModel_FurniView_1.isVisible)
         {
            resetUnseenItems();
         }
      }
      
      public function updateItemLocks() : void
      {
         var _loc2_:* = null;
         var _loc3_:Array = [];
         var _loc1_:ITradingModel = _controller.activeTradingModel;
         if(_loc1_ != null)
         {
            _loc3_ = _loc3_.concat(_loc1_.getOwnItemIdsInTrade());
         }
         var _loc5_:RecyclerModel = _controller.recyclerModel;
         if(_loc5_ != null)
         {
            _loc3_ = _loc3_.concat(_loc5_.getOwnItemsInRecycler());
         }
         var _loc4_:MarketplaceModel = _controller.marketplaceModel;
         if(_loc4_ != null)
         {
            _loc3_ = _loc3_.concat(_loc4_.getOfferItemRefs());
         }
         if(_loc3_.length == 0)
         {
            removeAllLocks();
            return;
         }
         for each(_loc2_ in _furniData)
         {
            _loc2_.updateLocks(_loc3_);
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function lockAllSellable(param1:GroupItem) : Vector.<FurnitureItem>
      {
         var _loc2_:Vector.<FurnitureItem> = param1.lockAllSellable();
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
         return _loc2_;
      }
      
      public function removeLockFrom(param1:int) : void
      {
         var _loc2_:* = null;
         for each(_loc2_ in _furniData)
         {
            _loc2_.removeLockFrom(param1);
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function removeLocksFor(param1:GroupItem, param2:Set) : void
      {
         param1.removeLocks(param2);
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function showRecyclable(param1:Boolean) : void
      {
         var _loc2_:* = null;
         for each(_loc2_ in _furniData)
         {
            _loc2_.showRecyclable = param1;
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function clearFurniList() : void
      {
         _furniData = new Vector.<GroupItem>(0);
         if(UnknownVarFromFurniModel_FurniView_1 != null)
         {
            UnknownVarFromFurniModel_FurniView_1.clearViews();
         }
      }
      
      public function removeUnseenFurniCounter(param1:int) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc6_:IUnseenItemTracker = _controller.unseenItemTracker;
         if(_loc6_ == null)
         {
            return false;
         }
         var _loc4_:GroupItem = getItemById(param1);
         if(_loc4_ == null)
         {
            return false;
         }
         if(UnknownVarFromFurniModel_String_1 == "rentables")
         {
            _loc3_ = 2;
         }
         else
         {
            _loc3_ = 1;
         }
         var _loc5_:Boolean = _controller.unseenItemTracker.isUnseen(_loc3_,param1);
         if(_loc5_)
         {
            _loc2_ = _loc6_.removeUnseen(_loc3_,param1);
         }
         if(_loc2_)
         {
            _loc6_.resetCategoryIfEmpty(_loc3_);
         }
         return _loc2_;
      }
      
      public function getItemWithStripId(param1:int) : GroupItem
      {
         var _loc2_:IFurnitureItem = null;
         for each(var _loc3_ in _furniData)
         {
            _loc2_ = _loc3_.getItem(param1);
            if(_loc2_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function getGroupItemByItemTypeId(param1:int, param2:Boolean) : GroupItem
      {
         for each(var _loc3_ in _furniData)
         {
            if(_loc3_.type == param1 && param2 == _loc3_.isWallItem)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function addOrUpdateItem(param1:FurnitureItem, param2:Boolean) : GroupItem
      {
         var _loc3_:GroupItem = null;
         if(!param1.groupable && param1.category != 19 && param1.category != 24 && param1.category != 25)
         {
            _loc3_ = addOrUpdateNonGroupableItem(param1,param2);
         }
         else
         {
            _loc3_ = addOrUpdateGroupableItem(param1,param2);
         }
         if(!param2)
         {
            _loc3_.hasUnseenItems = true;
         }
         if(_loc3_.isSelected)
         {
            UnknownVarFromFurniModel_FurniView_1.updateActionView();
         }
         _catalog.itemAddedToInventory(param1.type,param1.id,param1.category);
         _catalog.collectorHub.itemAddedToInventory(param1.type,param1.id,param1.isWallItem);
         return _loc3_;
      }
      
      public function setViewToState() : void
      {
         UnknownVarFromFurniModel_FurniView_1.setViewToState();
      }
      
      public function removeFurni(param1:int) : GroupItem
      {
         var _loc3_:GroupItem = null;
         var _loc4_:int = 0;
         var _loc2_:IFurnitureItem = null;
         _loc4_ = 0;
         while(_loc4_ < _furniData.length)
         {
            _loc3_ = _furniData[_loc4_] as GroupItem;
            _loc2_ = _loc3_.remove(param1);
            if(_loc2_)
            {
               if(_loc3_.getTotalCount() <= 0)
               {
                  _furniData.splice(_loc4_,1);
                  if(UnknownVarFromFurniModel_FurniView_1 && UnknownVarFromFurniModel_FurniView_1.grid)
                  {
                     UnknownVarFromFurniModel_FurniView_1.grid.itemWasUpdated(_loc3_);
                  }
                  if(_loc3_.isSelected)
                  {
                     selectFirstItem();
                  }
                  _loc3_.dispose();
               }
               else
               {
                  UnknownVarFromFurniModel_FurniView_1.updateActionView();
               }
               UnknownVarFromFurniModel_FurniView_1.setViewToState();
               _catalog.collectorHub.itemRemovedFromInventory(_loc2_.type,_loc2_.id,_loc2_.isWallItem);
               return _loc3_;
            }
            _loc4_++;
         }
         return null;
      }
      
      public function removeFurnis(param1:Vector.<int>) : Boolean
      {
         var _loc3_:GroupItem = null;
         var _loc8_:int = 0;
         var _loc2_:IFurnitureItem = null;
         var _loc5_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc6_:Boolean = false;
         for each(var _loc4_ in param1)
         {
            _loc8_ = 0;
            while(_loc8_ < _furniData.length)
            {
               _loc3_ = _furniData[_loc8_] as GroupItem;
               _loc2_ = _loc3_.remove(_loc4_);
               if(_loc2_)
               {
                  _loc5_ = true;
                  if(_loc3_.getTotalCount() <= 0)
                  {
                     _furniData.splice(_loc8_,1);
                     if(UnknownVarFromFurniModel_FurniView_1 && UnknownVarFromFurniModel_FurniView_1.grid)
                     {
                        UnknownVarFromFurniModel_FurniView_1.grid.itemWasUpdated(_loc3_);
                     }
                     if(_loc3_.isSelected)
                     {
                        _loc6_ = true;
                     }
                     _loc3_.dispose();
                  }
                  else
                  {
                     _loc7_ = true;
                  }
                  _catalog.collectorHub.itemRemovedFromInventory(_loc2_.type,_loc2_.id,_loc2_.isWallItem);
               }
               _loc8_++;
            }
         }
         if(_loc5_)
         {
            if(_loc6_)
            {
               selectFirstItem();
            }
            if(_loc7_)
            {
               UnknownVarFromFurniModel_FurniView_1.updateActionView();
            }
            UnknownVarFromFurniModel_FurniView_1.setViewToState();
         }
         return _loc5_;
      }
      
      public function updatePostItCount(param1:int, param2:int) : void
      {
         var _loc3_:FurnitureItem = null;
         var _loc5_:LegacyStuffData = null;
         for each(var _loc4_ in _furniData)
         {
            _loc3_ = _loc4_.getItem(param1) as FurnitureItem;
            if(_loc3_ != null)
            {
               _loc5_ = _loc3_.stuffData as LegacyStuffData;
               _loc5_.setString(String(param2));
               _loc3_.stuffData = _loc5_;
               _loc4_.replaceItem(param1,_loc3_);
            }
         }
      }
      
      public function selectFirstItem() : void
      {
         var _loc2_:IWindowController_1 = UnknownVarFromFurniModel_FurniView_1.getFirstThumb();
         if(_loc2_ == null)
         {
            return;
         }
         for each(var _loc1_ in _furniData)
         {
            if(_loc1_.window == _loc2_)
            {
               _loc1_.isSelected = true;
               _loc1_.selectedItemIndex = -1;
               break;
            }
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function displayItemInfo(param1:GroupItem) : void
      {
         if(UnknownVarFromFurniModel_FurniView_1 && !UnknownVarFromFurniModel_FurniView_1.disposed)
         {
            UnknownVarFromFurniModel_FurniView_1.displayItemInfo(param1);
         }
      }
      
      public function getSelectedItem() : GroupItem
      {
         for each(var _loc1_ in _furniData)
         {
            if(_loc1_.isSelected)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      public function removeSelections() : void
      {
         for each(var _loc1_ in _furniData)
         {
            _loc1_.isSelected = false;
         }
      }
      
      public function canUserOfferToTrade() : Boolean
      {
         return _controller.canUserOfferToTrade();
      }
      
      public function removeAllLocks() : void
      {
         for each(var _loc1_ in _furniData)
         {
            _loc1_.removeAllLocks();
         }
         if(UnknownVarFromFurniModel_FurniView_1 != null)
         {
            UnknownVarFromFurniModel_FurniView_1.updateActionView();
         }
      }
      
      public function cancelFurniInMover() : void
      {
         if(UnknownVarFromFurniModel_Int_1 > -1)
         {
            _roomEngine.cancelRoomObjectInsert();
            UnknownVarFromFurniModel_Boolean_1 = false;
            UnknownVarFromFurniModel_Int_1 = -1;
         }
      }
      
      public function requestSelectedFurniPlacement(param1:Boolean = false, param2:Boolean = true) : Boolean
      {
         var _loc4_:GroupItem = getSelectedItem();
         if(_loc4_ == null)
         {
            return false;
         }
         if(_loc4_.getUnlockedCount() == 0)
         {
            return false;
         }
         if(_loc4_.selectedItemIndex < 0 && param2)
         {
            _loc4_.selectedItemIndex = _loc4_.getTotalCount() - 1;
         }
         var _loc3_:FurnitureItem = _loc4_.getAt(_loc4_.selectedItemIndex);
         if(_loc3_ == null)
         {
            return false;
         }
         if(_loc3_.isRented && _loc3_.flatId > -1)
         {
            return false;
         }
         if(_loc3_.category == 3 || _loc3_.category == 2 || _loc3_.category == 4)
         {
            if(param1)
            {
               return false;
            }
            _communication.connection.send(new RequestRoomPropertySet(_loc3_.id));
         }
         else
         {
            requestSelectedFurniToMover(_loc3_);
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
         return true;
      }
      
      public function requestSelectedFurniToTrading(param1:int = 1, param2:ITextFieldWindow = null) : void
      {
         var itemsInTrade:Vector.<IFurnitureItem>;
         var coreItem:IFurnitureItem;
         var itemIds:Vector.<int>;
         var furnitureItem:IFurnitureItem;
         var trading:ITradingModel;
         var ownItemCount:int;
         var itemsToTrade:int = param1;
         var offerInTradingCount:ITextFieldWindow = param2;
         var groupItem:GroupItem = getSelectedItem();
         if(groupItem == null)
         {
            return;
         }
         itemsInTrade = groupItem.getItemsForTrade(itemsToTrade);
         if(itemsInTrade.length == 0)
         {
            return;
         }
         coreItem = null;
         itemIds = new Vector.<int>();
         for each(furnitureItem in itemsInTrade)
         {
            itemIds.push(furnitureItem.id);
            if(coreItem == null)
            {
               coreItem = furnitureItem;
            }
         }
         if(coreItem == null)
         {
            return;
         }
         trading = _controller.activeTradingModel;
         if(trading != null)
         {
            ownItemCount = int(trading.getOwnItemIdsInTrade().length);
            if(ownItemCount + itemIds.length <= 1500)
            {
               if(offerInTradingCount != null)
               {
                  offerInTradingCount.caption = String(itemIds.length);
               }
               trading.requestAddItemsToTrading(itemIds,coreItem.isWallItem,coreItem.type,coreItem.category,coreItem.groupable,coreItem.stuffData);
            }
            else
            {
               if(offerInTradingCount != null)
               {
                  offerInTradingCount.caption = "1";
               }
               _windowManager.alert("${trading.items.too_many_items.title}","${trading.items.too_many_items.desc}",0,function(param1:UnknownICoreWindowUtils1, param2:WindowEvent):void
               {
                  param1.dispose();
               });
            }
         }
         else if(offerInTradingCount != null)
         {
            offerInTradingCount.caption = "1";
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function gotoRoom() : void
      {
         var _loc2_:GroupItem = getSelectedItem();
         if(_loc2_ == null)
         {
            return;
         }
         var _loc1_:FurnitureItem = _loc2_.peek();
         if(_loc1_ == null)
         {
            return;
         }
         if(_communication == null)
         {
            return;
         }
         var _loc3_:IConnection = _communication.connection;
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.send(new OpenFlatConnectionMessageComposer(_loc1_.flatId));
         _roomItemToSelect = _loc1_;
      }
      
      public function requestSelectedFurniSelling() : void
      {
         var _loc1_:GroupItem = getSelectedItem();
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_.getOneForSelling() == null)
         {
            return;
         }
         var _loc2_:MarketplaceModel = _controller.marketplaceModel;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.startOfferMaking(_loc1_);
      }
      
      public function requestSelectedFurniToRecycler() : IFurnitureItem
      {
         var _loc2_:GroupItem = getSelectedItem();
         if(_loc2_ == null)
         {
            return null;
         }
         var _loc1_:IFurnitureItem = _loc2_.getOneForRecycle();
         if(_loc1_ == null)
         {
            return null;
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
         return _loc1_;
      }
      
      public function requestCurrentActionOnSelection() : void
      {
         if(_controller.recyclerModel.running)
         {
            _controller.recycleSelectedFurni();
         }
         else if(isTradingOpen)
         {
            requestSelectedFurniToTrading();
         }
         else
         {
            requestSelectedFurniPlacement(false);
         }
      }
      
      public function requestClose() : void
      {
         _controller.closeView();
      }
      
      public function showUseProductSelection() : void
      {
         var _loc1_:IFurnitureItem = null;
         var _loc2_:GroupItem = getSelectedItem();
         if(_loc2_ != null && _loc2_.peek() != null)
         {
            _loc1_ = _loc2_.peek();
            if(_loc1_)
            {
               _roomEngine.showUseProductSelection(_loc1_.ref,_loc1_.type);
            }
         }
      }
      
      public function subCategorySwitch(param1:String) : void
      {
         switch(param1)
         {
            case "wired_trading":
               cancelFurniInMover();
               if(UnknownVarFromFurniModel_FurniView_1 != null)
               {
                  UnknownVarFromFurniModel_FurniView_1.resetFilterOption();
                  UnknownVarFromFurniModel_FurniView_1.updateActionView();
               }
               break;
            case "trading":
               cancelFurniInMover();
               if(UnknownVarFromFurniModel_FurniView_1 != null && _showingNfts && controller.web3tradeEnabled)
               {
                  _showingNfts = false;
                  UnknownVarFromFurniModel_FurniView_1.updateGridFilters();
               }
               if(UnknownVarFromFurniModel_FurniView_1 != null)
               {
                  UnknownVarFromFurniModel_FurniView_1.updateActionView();
               }
               break;
            case "empty":
               removeAllLocks();
               if(UnknownVarFromFurniModel_FurniView_1 != null && !_showingNfts && controller.web3tradeEnabled)
               {
                  _showingNfts = true;
                  UnknownVarFromFurniModel_FurniView_1.updateGridFilters();
               }
               if(UnknownVarFromFurniModel_FurniView_1 != null)
               {
                  UnknownVarFromFurniModel_FurniView_1.updateActionView();
               }
         }
      }
      
      public function get showingNfts() : Boolean
      {
         return _showingNfts;
      }
      
      public function updateActionView() : void
      {
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function updateView() : void
      {
         if(UnknownVarFromFurniModel_FurniView_1 != null)
         {
            UnknownVarFromFurniModel_FurniView_1.updateActionView();
            UnknownVarFromFurniModel_FurniView_1.updateGridFilters();
         }
      }
      
      public function resetUnseenItems() : void
      {
         if(!UnknownVarFromFurniModel_FurniView_1)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(UnknownVarFromFurniModel_String_1 == "rentables")
         {
            _controller.unseenItemTracker.resetCategory(2);
            _loc2_ = true;
         }
         else
         {
            _controller.unseenItemTracker.resetCategory(1);
         }
         for each(var _loc1_ in _furniData)
         {
            if(_loc1_.hasUnseenItems && _loc1_.isRented == _loc2_)
            {
               _loc1_.hasUnseenItems = false;
            }
         }
         _controller.updateUnseenItemCounts();
      }
      
      public function updateUnseenItemsThumbs(param1:Vector.<GroupItem> = null, param2:Boolean = true) : void
      {
         var _loc14_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         if(!UnknownVarFromFurniModel_FurniView_1 || !UnknownVarFromFurniModel_FurniView_1.grid)
         {
            return;
         }
         var _loc8_:Array = _controller.unseenItemTracker.getIds(1);
         var _loc9_:Array = _controller.unseenItemTracker.getIds(2);
         var _loc15_:Set = new Set();
         for each(_loc14_ in _loc8_)
         {
            _loc15_.add(_loc14_);
         }
         for each(_loc14_ in _loc9_)
         {
            _loc15_.add(_loc14_);
         }
         if(_loc15_.length == 0)
         {
            return;
         }
         var _loc11_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc10_:Vector.<GroupItem> = param1 == null ? _furniData : param1;
         for each(_loc4_ in _loc10_)
         {
            _loc6_.length = 0;
            _loc7_.length = 0;
            _loc3_ = _loc4_.getFurniIds();
            _loc12_ = false;
            _loc13_ = false;
            for each(_loc5_ in _loc3_)
            {
               if(_loc15_.contains(_loc5_))
               {
                  _loc12_ = true;
                  if(!_controller.unseenItemTracker.isUnseenItemMovedToTop(1,_loc5_))
                  {
                     _loc13_ = true;
                     _loc6_.push(_loc5_);
                  }
                  if(!_controller.unseenItemTracker.isUnseenItemMovedToTop(2,_loc5_))
                  {
                     _loc13_ = true;
                     _loc7_.push(_loc5_);
                  }
                  break;
               }
            }
            if(!(!_loc12_ || _loc4_.hasUnseenItems && !_loc13_))
            {
               _loc4_.hasUnseenItems = true;
               _loc11_.push(_loc4_);
               if(_loc13_)
               {
                  moveItemToTop(_loc4_);
                  _controller.unseenItemTracker.setUnseenItemMovedToTop(1,_loc6_);
                  _controller.unseenItemTracker.setUnseenItemMovedToTop(2,_loc7_);
               }
            }
         }
         if(_loc11_.length > 0 && param2)
         {
            UnknownVarFromFurniModel_FurniView_1.grid.itemsWereUpdated(_loc11_);
         }
      }
      
      public function extendRentPeriod() : void
      {
         var _loc2_:GroupItem = getSelectedItem();
         if(_loc2_ == null)
         {
            return;
         }
         var _loc1_:FurnitureItem = _loc2_.peek();
         if(_loc1_ == null)
         {
            return;
         }
         var _loc3_:IFurnitureData = _controller.getFurnitureData(_loc1_.type,_loc1_.isWallItem ? "i" : "s");
         _catalog.openRentConfirmationWindow(_loc3_,false,-1,_loc1_.id);
      }
      
      public function buyRentedItem() : void
      {
         var _loc2_:GroupItem = getSelectedItem();
         if(_loc2_ == null)
         {
            return;
         }
         var _loc1_:FurnitureItem = _loc2_.peek();
         if(_loc1_ == null)
         {
            return;
         }
         var _loc3_:IFurnitureData = _controller.getFurnitureData(_loc1_.type,_loc1_.isWallItem ? "i" : "s");
         _catalog.openRentConfirmationWindow(_loc3_,true,-1,_loc1_.id);
      }
      
      private function addItemToTop(param1:GroupItem) : void
      {
         _furniData.unshift(param1);
      }
      
      private function addItemToBottom(param1:GroupItem) : void
      {
         _furniData.push(param1);
      }
      
      private function removeItem(param1:GroupItem) : void
      {
         var _loc2_:int = int(_furniData.indexOf(param1));
         if(_loc2_ > -1)
         {
            _furniData.splice(_loc2_,1);
         }
      }
      
      private function moveItemToTop(param1:GroupItem) : void
      {
         removeItem(param1);
         addItemToTop(param1);
      }
      
      private function getAllStripIds() : Dictionary
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Dictionary = new Dictionary();
         for each(var _loc2_ in _furniData)
         {
            _loc4_ = _loc2_.getTotalCount();
            if(_loc2_.category == 5)
            {
               _loc4_ = 1;
            }
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               _loc1_[_loc2_.getAt(_loc3_).id] = true;
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      private function initListImages() : void
      {
         var _loc1_:* = null;
         if(!UnknownVarFromFurniModel_Timer_1.running)
         {
            UnknownVarFromFurniModel_Timer_1.start();
         }
         if(UnknownVarFromFurniModel_FurniView_1 && UnknownVarFromFurniModel_FurniView_1.currentPageItems)
         {
            for each(_loc1_ in UnknownVarFromFurniModel_FurniView_1.currentPageItems)
            {
               if(!_loc1_.isImageInited)
               {
                  if(_loc1_.initImage(false))
                  {
                     break;
                  }
               }
            }
         }
      }
      
      private function getItemById(param1:int) : GroupItem
      {
         for each(var _loc2_ in _furniData)
         {
            if(_loc2_.getItem(param1) !== null)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function isUnseen(param1:FurnitureItem) : Boolean
      {
         var _loc2_:int = 0;
         if(param1.isRented)
         {
            _loc2_ = 2;
         }
         else
         {
            _loc2_ = 1;
         }
         return _controller.unseenItemTracker.isUnseen(_loc2_,param1.id);
      }
      
      private function addOrUpdateNonGroupableItem(param1:FurnitureItem, param2:Boolean) : GroupItem
      {
         var _loc3_:GroupItem = null;
         var _loc4_:Vector.<GroupItem> = new Vector.<GroupItem>(0);
         for each(_loc3_ in _furniData)
         {
            if(_loc3_.type == param1.type)
            {
               _loc4_.push(_loc3_);
            }
         }
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.getItem(param1.id) != null)
            {
               return _loc3_;
            }
         }
         var _loc5_:Boolean = isUnseen(param1);
         _loc3_ = createGroupItem(param1.type,param1.category,param1.stuffData,param1.extra,param2);
         _loc3_.push(param1,_loc5_);
         if(_loc5_)
         {
            _loc3_.hasUnseenItems = true;
            addItemToTop(_loc3_);
         }
         else
         {
            addItemToBottom(_loc3_);
         }
         if(UnknownVarFromFurniModel_FurniView_1 && UnknownVarFromFurniModel_FurniView_1.grid)
         {
            UnknownVarFromFurniModel_FurniView_1.grid.itemWasUpdated(_loc3_);
         }
         return _loc3_;
      }
      
      private function addOrUpdateGroupableItem(param1:FurnitureItem, param2:Boolean) : GroupItem
      {
         var _loc5_:* = null;
         var _loc3_:int = 0;
         var _loc6_:Boolean = isUnseen(param1);
         for each(var _loc4_ in _furniData)
         {
            if(_loc4_.type == param1.type && _loc4_.isWallItem == param1.isWallItem)
            {
               _loc3_ = param1.category;
               if(_loc3_ == 19)
               {
                  if(_loc4_.stuffData.rarityLevel == param1.stuffData.rarityLevel)
                  {
                     _loc5_ = _loc4_;
                     break;
                  }
               }
               else if(_loc3_ == 25 || _loc3_ == 24)
               {
                  if(_loc4_.stuffData.contentsCount == 0 && param1.stuffData.contentsCount == 0 && _loc4_.stuffData.chestName == "" && param1.stuffData.chestName == "")
                  {
                     _loc5_ = _loc4_;
                  }
               }
               else if(_loc4_.isGroupable)
               {
                  if(_loc3_ == 6)
                  {
                     if(_loc4_.stuffData.getLegacyString() == param1.stuffData.getLegacyString())
                     {
                        _loc5_ = _loc4_;
                        break;
                     }
                  }
                  else
                  {
                     if(_loc3_ != 17)
                     {
                        _loc5_ = _loc4_;
                        break;
                     }
                     if(param1.stuffData.compare(_loc4_.stuffData))
                     {
                        _loc5_ = _loc4_;
                        break;
                     }
                  }
               }
            }
         }
         if(_loc5_)
         {
            _loc5_.push(param1,_loc6_);
            if(_loc6_)
            {
               _loc5_.hasUnseenItems = true;
               moveItemToTop(_loc5_);
            }
            if(UnknownVarFromFurniModel_FurniView_1 && UnknownVarFromFurniModel_FurniView_1.grid)
            {
               UnknownVarFromFurniModel_FurniView_1.grid.itemWasUpdated(_loc5_);
            }
            return _loc5_;
         }
         _loc4_ = createGroupItem(param1.type,param1.category,param1.stuffData,param1.extra,param2);
         _loc4_.push(param1,_loc6_);
         if(_loc6_)
         {
            _loc4_.hasUnseenItems = true;
            addItemToTop(_loc4_);
         }
         else
         {
            addItemToBottom(_loc4_);
         }
         if(UnknownVarFromFurniModel_FurniView_1 && UnknownVarFromFurniModel_FurniView_1.grid)
         {
            UnknownVarFromFurniModel_FurniView_1.grid.itemWasUpdated(_loc4_);
         }
         return _loc4_;
      }
      
      private function requestSelectedFurniToMover(param1:FurnitureItem) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         if(param1.isWallItem)
         {
            _loc3_ = 20;
         }
         else
         {
            _loc3_ = 10;
         }
         if(param1.category == 6 || isExternalImageItem(param1))
         {
            _loc2_ = _roomEngine.initializeRoomObjectInsert("inventory",param1.id,_loc3_,param1.type,param1.stuffData.getLegacyString(),null,-1,-1,null,true);
         }
         else
         {
            _loc2_ = _roomEngine.initializeRoomObjectInsert("inventory",param1.id,_loc3_,param1.type,param1.extra.toString(),param1.stuffData,param1.stuffData.state,-1,null,true);
         }
         if(_loc2_)
         {
            UnknownVarFromFurniModel_Int_1 = param1.ref;
            if(!_controller.recyclerModel.running)
            {
               requestClose();
            }
            UnknownVarFromFurniModel_Boolean_1 = true;
         }
      }
      
      private function attemptPlaceNextFurni() : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:FurnitureItem = null;
         var _loc1_:* = false;
         var _loc3_:GroupItem = getSelectedItem();
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:* = -1;
         if(_loc3_.category == 5)
         {
            if(_loc3_.getTotalCount() > 1)
            {
               _loc4_ = 0;
            }
         }
         else
         {
            _loc6_ = _loc3_.selectedItemIndex;
            _loc5_ = _loc6_ - 1;
            while(_loc5_ >= 0)
            {
               _loc2_ = _loc3_.getAt(_loc5_);
               if(_loc2_ && !_loc2_.locked)
               {
                  _loc4_ = _loc5_;
                  break;
               }
               _loc5_ -= 1;
            }
         }
         if(_loc4_ != -1)
         {
            _loc3_.selectedItemIndex = _loc4_;
            _loc1_ = !requestSelectedFurniPlacement(false);
         }
         else
         {
            _loc1_ = true;
         }
         if(_loc1_)
         {
            _loc3_.selectedItemIndex = -1;
            cancelFurniInMover();
            _controller.showView();
         }
      }
      
      private function isExternalImageItem(param1:FurnitureItem) : Boolean
      {
         var _loc2_:IFurnitureData = _catalog.getFurnitureData(param1.type,"i");
         return _loc2_ && _loc2_.isExternalImageType;
      }
      
      private function updateCategorySelection() : void
      {
         var _loc2_:int = 0;
         removeSelections();
         var _loc1_:GroupItem = UnknownVarFromFurniModel_Dictionary_1[UnknownVarFromFurniModel_String_1];
         if(_loc1_ != null)
         {
            _loc2_ = int(_furniData.indexOf(_loc1_));
            if(_loc2_ > -1)
            {
               _loc1_.isSelected = true;
               _loc1_.selectedItemIndex = -1;
            }
         }
         else
         {
            selectFirstItem();
         }
         UnknownVarFromFurniModel_FurniView_1.updateActionView();
      }
      
      public function onObjectPlaced(param1:Event) : void
      {
         var _loc2_:RoomEngineObjectPlacedEvent = param1 as RoomEngineObjectPlacedEvent;
         if(_loc2_ == null)
         {
            return;
         }
         if(UnknownVarFromFurniModel_Boolean_1 && param1.type == "REOE_PLACED")
         {
            UnknownVarFromFurniModel_Boolean_1 = false;
            if(!_loc2_.placedInRoom)
            {
               _controller.showView();
               cancelFurniInMover();
            }
            else if(UnknownVarFromFurniModel_String_1 == "rentables")
            {
               _controller.showView();
            }
            else if(_loc2_.placedInRoom && (_loc2_.placedOnFloor && -_loc2_.objectId == UnknownVarFromFurniModel_Int_1) || _loc2_.placedOnWall && _loc2_.objectId == UnknownVarFromFurniModel_Int_1)
            {
               attemptPlaceNextFurni();
            }
         }
      }
      
      private function onImageUpdateTimerEvent(param1:TimerEvent) : void
      {
         var _loc5_:* = undefined;
         var _loc3_:FurnitureItem = null;
         initListImages();
         _imageUpdateCumulativeTime += 50;
         if(_imageUpdateCumulativeTime >= 200)
         {
            _loc5_ = new Vector.<int>(0);
            for each(var _loc2_ in _furniData)
            {
               _loc3_ = _loc2_.getAt(0);
               if(_loc3_ && _loc3_.isRented && _loc3_.hasRentPeriodStarted && _loc3_.secondsToExpiration <= 0)
               {
                  _loc5_.push(_loc3_.id);
               }
            }
            for each(var _loc4_ in _loc5_)
            {
               removeFurni(_loc4_);
            }
            if(_loc5_.length > 0)
            {
               UnknownVarFromFurniModel_FurniView_1.updateGridFilters();
            }
            UnknownVarFromFurniModel_FurniView_1.updateRentedItem();
            _imageUpdateCumulativeTime = 0;
         }
      }
      
      public function roomEntered() : void
      {
         var _loc1_:int = 0;
         _isInRoom = true;
         if(_roomItemToSelect == null)
         {
            return;
         }
         if(_roomEngine != null)
         {
            _loc1_ = _roomItemToSelect.isWallItem ? 20 : 10;
            _roomEngine.selectRoomObject(_roomItemToSelect.flatId,Math.abs(_roomItemToSelect.id),_loc1_);
         }
         _roomItemToSelect = null;
      }
      
      public function roomLeft() : void
      {
         _isInRoom = false;
      }
      
      public function selectItemById(param1:String) : void
      {
         var _loc2_:GroupItem = getItemById(-int(param1));
         if(_loc2_ != null)
         {
            categorySelection = _loc2_;
         }
      }
   }
}

