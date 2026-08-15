package com.sulake.habbo.inventory.items
{
   import com.sulake.core.utils.Map;
   import com.sulake.core.utils.Set;
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.core.window.components.IStaticBitmapWrapperWindow;
   import com.sulake.core.window.components.ITextWindow;
   import com.sulake.core.window.components.IWidgetWindowController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.inventory.furni.FurniModel;
   import com.sulake.habbo.room.IRoomEngine;
   import com.sulake.habbo.room.IStuffData;
   import com.sulake.habbo.room.UnknownHabboRoom1;
   import com.sulake.habbo.room.UnknownIHabboRoom1;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.sound.ISongInfo;
   import com.sulake.habbo.sound.events.SongInfoReceivedEvent;
   import com.sulake.habbo.window.widgets.IChestItemGridOverlayWidget;
   import com.sulake.habbo.window.widgets.ILimitedItemGridOverlayWidget;
   import com.sulake.habbo.window.widgets.IRarityItemGridOverlayWidget;
   import flash.display.BitmapData;
   
   public class GroupItem implements UnknownIHabboRoom1
   {
      
      private static const THUMB_WINDOW_LAYOUT:String = "inventory_thumb_xml";
      
      private static const THUMB_COLOR_NORMAL:int = 13421772;
      
      private static const THUMB_COLOR_UNSEEN:int = 10275685;
      
      public static const THUMB_BLEND_ITEMS_AVAILABLE:Number = 1;
      
      public static const THUMB_BLEND_ITEMS_NOT_AVAILABLE:Number = 0.2;
      
      protected var _items:Map;
      
      protected var _window:IWindowController_1;
      
      protected var UnknownVarFromGroupItem_FurniModel_1:FurniModel;
      
      private var _type:int;
      
      private var _roomEngine:IRoomEngine;
      
      private var _isLocked:Boolean;
      
      private var _selected:Boolean;
      
      private var _category:int;
      
      private var _stuffData:IStuffData;
      
      private var _extra:Number;
      
      private var _iconCallbackId:int = 0;
      
      private var _iconImage:BitmapData;
      
      private var _previewCallbackId:int;
      
      private var UnknownVarFromGroupItem_Boolean_1:Boolean;
      
      private var UnknownVarFromGroupItem_Boolean_2:Boolean;
      
      private var _holdImageInit:Boolean;
      
      private var _icon:BitmapData;
      
      private var UnknownVarFromGroupItem_IWindowModel_1:IWindowModel;
      
      private var _hasUnseenItems:Boolean;
      
      private var UnknownVarFromGroupItem_Boolean_3:Boolean;
      
      private var _alignment:String = "center";
      
      private var UnknownVarFromGroupItem_Boolean_4:Boolean = false;
      
      private var _name:String = "";
      
      private var _description:String = "";
      
      private var UnknownVarFromGroupItem_Int_1:int = -1;
      
      private var UnknownVarFromGroupItem_Int_2:int = -1;
      
      private var _furniDataCache:IFurnitureData = null;
      
      public function GroupItem(param1:FurniModel, param2:int, param3:int, param4:IRoomEngine, param5:Boolean, param6:IStuffData, param7:Number, param8:BitmapData, param9:Boolean, param10:String)
      {
         super();
         UnknownVarFromGroupItem_FurniModel_1 = param1;
         _type = param2;
         _roomEngine = param4;
         UnknownVarFromGroupItem_Boolean_2 = param5;
         _items = new Map();
         _category = param3;
         _stuffData = param6;
         _extra = param7;
         _alignment = param10;
         _icon = param8;
         _holdImageInit = param9;
         switch(_category - 2)
         {
            case 0:
               _name = UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization("inventory.furni.item.wallpaper.name");
               _description = UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization("inventory.furni.item.wallpaper.desc");
               break;
            case 1:
               _name = UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization("inventory.furni.item.floor.name");
               _description = UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization("inventory.furni.item.floor.desc");
               break;
            case 2:
               _name = UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization("inventory.furni.item.landscape.name");
               _description = UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization("inventory.furni.item.landscape.desc");
         }
         UnknownVarFromGroupItem_FurniModel_1.soundManager.events.addEventListener("SIR_TRAX_SONG_INFO_RECEIVED",onSongInfoReceivedEvent);
      }
      
      public function get isImageInited() : Boolean
      {
         return UnknownVarFromGroupItem_Boolean_4 && UnknownVarFromGroupItem_Boolean_1;
      }
      
      public function get isImageFinished() : Boolean
      {
         return _iconCallbackId == -1;
      }
      
      public function get window() : IWindowController_1
      {
         if(!UnknownVarFromGroupItem_Boolean_4)
         {
            initWindow();
         }
         if(_window == null)
         {
            return null;
         }
         if(_window.disposed)
         {
            return null;
         }
         return _window;
      }
      
      public function get isLocked() : Boolean
      {
         return _isLocked;
      }
      
      public function set isLocked(param1:Boolean) : void
      {
         _isLocked = param1;
      }
      
      public function get isSelected() : Boolean
      {
         return _selected;
      }
      
      public function set isSelected(param1:Boolean) : void
      {
         if(_selected != param1)
         {
            _selected = param1;
            updateSelectionVisual();
         }
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get furniData() : IFurnitureData
      {
         if(_furniDataCache != null)
         {
            return _furniDataCache;
         }
         var _loc1_:FurnitureItem = peek();
         if(_loc1_ == null)
         {
            return null;
         }
         var _loc2_:String = _loc1_.isWallItem ? "i" : "s";
         _furniDataCache = UnknownVarFromGroupItem_FurniModel_1.controller.getFurnitureData(_loc1_.type,_loc2_);
         return _furniDataCache;
      }
      
      public function get iconImage() : BitmapData
      {
         return _iconImage;
      }
      
      public function set iconImage(param1:BitmapData) : void
      {
         _iconImage = param1;
      }
      
      public function get iconCallbackId() : int
      {
         return _iconCallbackId;
      }
      
      public function set iconCallbackId(param1:int) : void
      {
         _iconCallbackId = param1;
      }
      
      public function get previewCallbackId() : int
      {
         return _previewCallbackId;
      }
      
      public function set previewCallbackId(param1:int) : void
      {
         _previewCallbackId = param1;
      }
      
      public function get category() : int
      {
         return _category;
      }
      
      public function get stuffData() : IStuffData
      {
         return _stuffData;
      }
      
      public function get extra() : Number
      {
         return _extra;
      }
      
      public function set showRecyclable(param1:Boolean) : void
      {
         if(UnknownVarFromGroupItem_Boolean_2 != param1)
         {
            UnknownVarFromGroupItem_Boolean_2 = param1;
            updateRecycleStatusVisual();
         }
      }
      
      public function get hasUnseenItems() : Boolean
      {
         return _hasUnseenItems;
      }
      
      public function set hasUnseenItems(param1:Boolean) : void
      {
         if(_hasUnseenItems != param1)
         {
            _hasUnseenItems = param1;
            updateBackgroundVisual();
         }
      }
      
      public function get alignment() : String
      {
         return _alignment;
      }
      
      public function get isWallItem() : Boolean
      {
         var _loc1_:FurnitureItem = getAt(0);
         return _loc1_ ? _loc1_.isWallItem : false;
      }
      
      public function get flatId() : int
      {
         var _loc1_:FurnitureItem = getAt(0);
         return _loc1_ ? _loc1_.flatId : -1;
      }
      
      public function get isGroupable() : Boolean
      {
         var _loc1_:FurnitureItem = getAt(0);
         return _loc1_ ? _loc1_.groupable : true;
      }
      
      public function get isRented() : Boolean
      {
         var _loc1_:FurnitureItem = getAt(0);
         return _loc1_ ? _loc1_.isRented : false;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get description() : String
      {
         return _description;
      }
      
      public function dispose() : void
      {
         if(UnknownVarFromGroupItem_FurniModel_1.soundManager)
         {
            if(UnknownVarFromGroupItem_FurniModel_1.soundManager.events != null)
            {
               UnknownVarFromGroupItem_FurniModel_1.soundManager.events.removeEventListener("SIR_TRAX_SONG_INFO_RECEIVED",onSongInfoReceivedEvent);
            }
         }
         UnknownVarFromGroupItem_FurniModel_1 = null;
         UnknownVarFromGroupItem_IWindowModel_1 = null;
         _roomEngine = null;
         if(_items)
         {
            _items.dispose();
            _items = null;
         }
         _stuffData = null;
         if(_window)
         {
            _window.dispose();
         }
      }
      
      public function removeIntervalProcedure() : void
      {
         if(_window)
         {
            _window.procedure = null;
         }
      }
      
      public function initImage(param1:Boolean = true) : Boolean
      {
         var _loc2_:UnknownHabboRoom1 = null;
         if(_iconImage != null)
         {
            return false;
         }
         if(UnknownVarFromGroupItem_Boolean_1)
         {
            return false;
         }
         if(isWallItem)
         {
            _loc2_ = _roomEngine.getWallItemIcon(_type,this,_stuffData.getLegacyString());
         }
         else
         {
            _loc2_ = _roomEngine.getFurnitureIcon(_type,this,String(_extra),_stuffData);
         }
         if(_loc2_.id > 0)
         {
            if(param1)
            {
               setLoadingImage(_loc2_.data);
            }
            _iconCallbackId = _loc2_.id;
         }
         else
         {
            setFinalImage(_loc2_.data);
            _iconCallbackId = -1;
         }
         UnknownVarFromGroupItem_Boolean_1 = true;
         return _loc2_.id > 0;
      }
      
      public function push(param1:FurnitureItem, param2:Boolean = false) : void
      {
         var _loc3_:FurnitureItem = _items.getValue(param1.id);
         if(_loc3_ == null)
         {
            _items.add(param1.id,param1);
         }
         else
         {
            _loc3_.locked = false;
         }
         updateItemCountVisual();
         updateSelectionVisual();
         updateRentStateVisual();
         if(_name == null || _name.length == 0)
         {
            _name = getFurniItemName();
         }
         if(_description == null || _description.length == 0)
         {
            _description = getFurniItemDesc();
         }
         if(param2 != _hasUnseenItems)
         {
            _hasUnseenItems = param2;
            updateBackgroundVisual();
         }
      }
      
      public function unshift(param1:FurnitureItem) : void
      {
         var _loc2_:FurnitureItem = _items.getValue(param1.id);
         if(_loc2_ == null)
         {
            _items.unshift(param1.id,param1);
         }
         else
         {
            _loc2_.locked = false;
         }
         updateAllThumbDataVisuals();
      }
      
      public function pop() : FurnitureItem
      {
         var _loc1_:FurnitureItem = null;
         if(_items.length > 0)
         {
            _loc1_ = _items.getWithIndex(_items.length - 1) as FurnitureItem;
            _items.remove(_loc1_.id);
         }
         updateAllThumbDataVisuals();
         return _loc1_;
      }
      
      public function peek() : FurnitureItem
      {
         var _loc1_:FurnitureItem = null;
         if(_items.length > 0)
         {
            _loc1_ = _items.getWithIndex(_items.length - 1) as FurnitureItem;
         }
         return _loc1_;
      }
      
      public function getAt(param1:int) : FurnitureItem
      {
         return _items.getWithIndex(param1);
      }
      
      public function getItemsForTrade(param1:int) : Vector.<IFurnitureItem>
      {
         var _loc5_:int = 0;
         var _loc2_:FurnitureItem = null;
         var _loc3_:Vector.<IFurnitureItem> = new Vector.<IFurnitureItem>();
         var _loc6_:IFurnitureItem = getOneForTrade();
         if(_loc6_ == null)
         {
            return _loc3_;
         }
         var _loc4_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < _items.length)
         {
            if(_loc4_ >= param1)
            {
               break;
            }
            _loc2_ = _items.getWithIndex(_loc5_);
            if(!_loc2_.locked && _loc2_.tradeable && _loc2_.type == _loc6_.type)
            {
               _loc4_++;
               _loc3_.push(_loc2_);
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getOneForTrade() : FurnitureItem
      {
         var _loc2_:FurnitureItem = null;
         var _loc3_:int = 0;
         var _loc1_:FurnitureItem = null;
         if(UnknownVarFromGroupItem_Int_2 >= 0 && UnknownVarFromGroupItem_Int_2 < _items.length)
         {
            _loc2_ = _items.getWithIndex(UnknownVarFromGroupItem_Int_2);
            if(!_loc2_.locked && _loc2_.tradeable)
            {
               return _loc2_;
            }
         }
         _loc3_ = 0;
         while(_loc3_ < _items.length)
         {
            _loc1_ = _items.getWithIndex(_loc3_);
            if(!_loc1_.locked && _loc1_.tradeable)
            {
               return _loc1_;
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getOneForRecycle() : FurnitureItem
      {
         var _loc2_:int = 0;
         var _loc1_:FurnitureItem = null;
         _loc2_ = 0;
         while(_loc2_ < _items.length)
         {
            _loc1_ = _items.getWithIndex(_loc2_);
            if(!_loc1_.locked && _loc1_.recyclable)
            {
               addLockTo(_loc1_.id);
               return _loc1_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getOneForSelling() : FurnitureItem
      {
         var _loc2_:int = 0;
         var _loc1_:FurnitureItem = null;
         _loc2_ = 0;
         while(_loc2_ < _items.length)
         {
            _loc1_ = _items.getWithIndex(_loc2_);
            if(!_loc1_.locked && _loc1_.sellable)
            {
               return _loc1_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getFurniIds() : Array
      {
         var _loc2_:Array = [];
         for each(var _loc1_ in _items)
         {
            _loc2_.push(_loc1_.id);
         }
         return _loc2_;
      }
      
      public function getNonRentedFurnitureIds() : Array
      {
         var _loc2_:Array = [];
         for each(var _loc1_ in _items)
         {
            if(!_loc1_.isRented)
            {
               _loc2_.push(_loc1_.id);
            }
         }
         return _loc2_;
      }
      
      public function lockAllSellable() : Vector.<FurnitureItem>
      {
         var _loc2_:Vector.<FurnitureItem> = new Vector.<FurnitureItem>();
         for each(var _loc1_ in _items.getValues())
         {
            if(_loc1_.sellable && !_loc1_.locked)
            {
               _loc1_.locked = true;
               _loc2_.push(_loc1_);
            }
         }
         updateItemCountVisual();
         return _loc2_;
      }
      
      public function removeLocks(param1:Set) : void
      {
         var _loc4_:int = 0;
         var _loc2_:FurnitureItem = null;
         var _loc3_:Boolean = false;
         _loc4_ = 0;
         while(_loc4_ < _items.length)
         {
            _loc2_ = _items.getWithIndex(_loc4_);
            if(param1.contains(_loc2_.id))
            {
               _loc2_.locked = false;
               _loc3_ = true;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            updateItemCountVisual();
            updateRecycleStatusVisual();
         }
      }
      
      public function addLockTo(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:FurnitureItem = null;
         _loc3_ = 0;
         while(_loc3_ < _items.length)
         {
            _loc2_ = _items.getWithIndex(_loc3_);
            if(_loc2_.id == param1)
            {
               _loc2_.locked = true;
               updateItemCountVisual();
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function updateLocks(param1:Array) : void
      {
         var _loc5_:Boolean = false;
         var _loc2_:FurnitureItem = null;
         var _loc4_:* = false;
         var _loc3_:int = _items.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = _items.getWithIndex(_loc3_);
            _loc4_ = param1.indexOf(_loc2_.ref) >= 0;
            if(_loc2_.locked != _loc4_)
            {
               _loc2_.locked = _loc4_;
               _loc5_ = true;
            }
            _loc3_--;
         }
         if(_loc5_)
         {
            updateItemCountVisual();
         }
      }
      
      public function removeLockFrom(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:FurnitureItem = null;
         _loc3_ = 0;
         while(_loc3_ < _items.length)
         {
            _loc2_ = _items.getWithIndex(_loc3_);
            if(_loc2_.id == param1)
            {
               _loc2_.locked = false;
               updateItemCountVisual();
               updateRecycleStatusVisual();
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function removeAllLocks() : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:int = 0;
         var _loc1_:FurnitureItem = null;
         _loc2_ = _items.length - 1;
         while(_loc2_ >= 0)
         {
            _loc1_ = _items.getWithIndex(_loc2_);
            if(_loc1_.locked)
            {
               _loc1_.locked = false;
               _loc3_ = true;
            }
            _loc2_--;
         }
         if(_loc3_)
         {
            updateItemCountVisual();
         }
      }
      
      public function getTotalCount() : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:FurnitureItem = null;
         if(category == 5)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            while(_loc3_ < _items.length)
            {
               _loc1_ = _items.getWithIndex(_loc3_) as FurnitureItem;
               _loc2_ += int(_loc1_.stuffData.getLegacyString());
               _loc3_++;
            }
            return _loc2_;
         }
         return _items.length;
      }
      
      public function getRecyclableCount() : int
      {
         var _loc3_:int = 0;
         var _loc1_:FurnitureItem = null;
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _items.length)
         {
            _loc1_ = _items.getWithIndex(_loc3_) as FurnitureItem;
            if(_loc1_.recyclable && !_loc1_.locked)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getTradeableCount(param1:Boolean = true) : int
      {
         var _loc4_:int = 0;
         var _loc2_:FurnitureItem = null;
         var _loc3_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _items.length)
         {
            _loc2_ = _items.getWithIndex(_loc4_) as FurnitureItem;
            if(_loc2_.tradeable && (!param1 || !_loc2_.locked))
            {
               _loc3_++;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function remove(param1:int) : FurnitureItem
      {
         var _loc2_:FurnitureItem = _items.getValue(param1);
         if(_loc2_)
         {
            _items.remove(param1);
            updateAllThumbDataVisuals();
            return _loc2_;
         }
         return null;
      }
      
      public function getItem(param1:int) : FurnitureItem
      {
         return _items.getValue(param1);
      }
      
      public function replaceItem(param1:int, param2:FurnitureItem) : void
      {
         _items.add(param1,param2);
         updateAllThumbDataVisuals();
      }
      
      public function getMinimumItemsToShowCounter() : int
      {
         return 2;
      }
      
      public function getUnlockedCount() : int
      {
         var _loc1_:FurnitureItem = null;
         var _loc3_:int = 0;
         if(category == 5)
         {
            return getTotalCount();
         }
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _items.length)
         {
            _loc1_ = _items.getWithIndex(_loc3_);
            if(!_loc1_.locked)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function updateAllThumbDataVisuals() : void
      {
         if(_window == null)
         {
            return;
         }
         if(_window.disposed)
         {
            return;
         }
         updateItemImageVisual();
         updateBackgroundVisual();
         updateItemCountVisual();
         updateRecycleStatusVisual();
         updateSelectionVisual();
         updateRentStateVisual();
      }
      
      public function imageReady(param1:int, param2:BitmapData) : void
      {
         if(_window == null)
         {
            return;
         }
         if(_window.disposed)
         {
            return;
         }
         if(_iconCallbackId != param1)
         {
            return;
         }
         _iconImage = param2;
         updateItemImageVisual();
      }
      
      public function imageFailed(param1:int) : void
      {
      }
      
      private function setFinalImage(param1:BitmapData) : void
      {
         _iconImage = param1;
         UnknownVarFromGroupItem_Boolean_1 = true;
         _iconCallbackId = -1;
         updateItemImageVisual();
      }
      
      private function setLoadingImage(param1:BitmapData) : void
      {
         _iconImage = param1;
         UnknownVarFromGroupItem_Boolean_1 = true;
         updateItemImageVisual();
      }
      
      private function updateRentStateVisual() : void
      {
         if(_window == null || Boolean(_window.disposed))
         {
            return;
         }
         var _loc2_:FurnitureItem = getAt(0);
         var _loc1_:IStaticBitmapWrapperWindow = _window.findChildByName("rent_state") as IStaticBitmapWrapperWindow;
         if(!_loc2_ || !isRented)
         {
            _loc1_.visible = false;
            return;
         }
         _loc1_.visible = isRented;
         var _loc3_:int = UnknownVarFromGroupItem_FurniModel_1.controller.getInteger("purchase.rent.warning_duration_seconds",172800);
         _loc1_.assetUri = !_loc2_.hasRentPeriodStarted ? "inventory_thumb_rent_not_started" : (_loc2_.secondsToExpiration < _loc3_ ? "inventory_thumb_rent_ending" : "inventory_thumb_rent_started");
      }
      
      private function updateItemCountVisual() : void
      {
         var _loc4_:ITextWindow = null;
         if(!_window)
         {
            return;
         }
         var _loc5_:int = getUnlockedCount();
         var _loc1_:* = _loc5_ >= getMinimumItemsToShowCounter();
         var _loc3_:IWindowModel = _window.findChildByName("number_container");
         _loc3_.visible = _loc1_;
         if(_loc1_)
         {
            _loc4_ = _window.findChildByName("number") as ITextWindow;
            _loc4_.text = String(_loc5_);
         }
         var _loc2_:IBitmapWrapperController = _window.findChildByName("bitmap") as IBitmapWrapperController;
         if(_loc5_ <= 0)
         {
            _loc2_.blend = 0.2;
         }
         else
         {
            _loc2_.blend = 1;
         }
      }
      
      private function updateBackgroundVisual() : void
      {
         if(!_window)
         {
            return;
         }
         if(!UnknownVarFromGroupItem_IWindowModel_1)
         {
            UnknownVarFromGroupItem_IWindowModel_1 = _window.findChildByTag("BG_COLOR");
         }
         UnknownVarFromGroupItem_IWindowModel_1.color = _hasUnseenItems ? 10275685 : 13421772;
      }
      
      private function updateSelectionVisual() : void
      {
         if(!_window)
         {
            return;
         }
         _window.findChildByName("outline").visible = isSelected;
      }
      
      private function updateRecycleStatusVisual() : void
      {
         if(!_window)
         {
            return;
         }
         var _loc1_:IWindowModel = _window.findChildByName("recyclable_container");
         if(_loc1_)
         {
            _loc1_.visible = UnknownVarFromGroupItem_Boolean_2 && getRecyclableCount() > 0;
         }
      }
      
      private function updateItemImageVisual() : void
      {
         var _loc7_:IWidgetWindowController = null;
         var _loc2_:ILimitedItemGridOverlayWidget = null;
         var _loc8_:IWidgetWindowController = null;
         var _loc1_:IRarityItemGridOverlayWidget = null;
         var _loc5_:IChestItemGridOverlayWidget = null;
         var _loc6_:IStaticBitmapWrapperWindow = null;
         var _loc3_:String = null;
         if(!_window)
         {
            return;
         }
         if(stuffData.uniqueSerialNumber > 0)
         {
            _loc7_ = IWidgetWindowController(_window.findChildByName("unique_item_overlay_container"));
            _loc2_ = ILimitedItemGridOverlayWidget(_loc7_.widget);
            _loc7_.visible = true;
            _loc2_.serialNumber = stuffData.uniqueSerialNumber;
            _loc2_.animated = true;
            _window.findChildByName("unique_item_background_bitmap").visible = true;
         }
         else if(stuffData.rarityLevel >= 0)
         {
            _loc8_ = IWidgetWindowController(_window.findChildByName("rarity_item_overlay_container"));
            _loc1_ = IRarityItemGridOverlayWidget(_loc8_.widget);
            _loc1_.rarityLevel = stuffData.rarityLevel;
            _loc8_.visible = true;
         }
         else if(_category == 25 || _category == 24)
         {
            _loc7_ = IWidgetWindowController(_window.findChildByName("chest_overlay_container"));
            _loc5_ = IChestItemGridOverlayWidget(_loc7_.widget);
            _loc5_.contentsCount = stuffData.contentsCount;
            _loc7_.visible = true;
            _loc6_ = IStaticBitmapWrapperWindow(_window.findChildByName("chest_background_bitmap"));
            _loc3_ = _category == 25 ? "gold" : "brown";
            _loc5_.color = _loc3_;
            _loc6_.assetUri = "chest_overlay_" + _loc3_ + "_background";
            _loc6_.visible = true;
         }
         var _loc4_:IBitmapWrapperController = _window.findChildByName("bitmap") as IBitmapWrapperController;
         if(_loc4_)
         {
            _loc4_.bitmap = _iconImage;
         }
      }
      
      private function itemEventProc(param1:WindowEvent, param2:IWindowModel) : void
      {
         var _loc3_:Boolean = false;
         switch(param1.type)
         {
            case "WME_UP":
               UnknownVarFromGroupItem_Boolean_3 = false;
               UnknownVarFromGroupItem_FurniModel_1.cancelFurniInMover();
               break;
            case "WME_DOWN":
               UnknownVarFromGroupItem_FurniModel_1.removeSelections();
               isSelected = true;
               UnknownVarFromGroupItem_Boolean_3 = true;
               UnknownVarFromGroupItem_FurniModel_1.updateActionView();
               UnknownVarFromGroupItem_FurniModel_1.categorySelection = this;
               break;
            case "WME_OUT":
               if(!UnknownVarFromGroupItem_Boolean_3 || UnknownVarFromGroupItem_FurniModel_1.isTradingOpen)
               {
                  return;
               }
               _loc3_ = UnknownVarFromGroupItem_FurniModel_1.requestSelectedFurniPlacement(true);
               if(_loc3_)
               {
                  UnknownVarFromGroupItem_Boolean_3 = false;
               }
               break;
            case "WME_CLICK":
               UnknownVarFromGroupItem_Boolean_3 = false;
               break;
            case "WME_DOUBLE_CLICK":
               UnknownVarFromGroupItem_FurniModel_1.requestCurrentActionOnSelection();
               UnknownVarFromGroupItem_Boolean_3 = false;
         }
      }
      
      private function initWindow() : void
      {
         createWindow();
         if(_icon != null)
         {
            setFinalImage(_icon);
         }
         else if(!_holdImageInit)
         {
            initImage();
         }
         _window.procedure = itemEventProc;
         _window.name = _roomEngine.getFurnitureType(type) + "." + category;
         if(stuffData && stuffData.getLegacyString() != "")
         {
            _window.name += ".s" + stuffData;
         }
         if(!isNaN(extra))
         {
            _window.name += ".e" + extra;
         }
         updateBackgroundVisual();
         updateItemCountVisual();
         updateItemImageVisual();
         updateRecycleStatusVisual();
         updateSelectionVisual();
         updateRentStateVisual();
         UnknownVarFromGroupItem_Boolean_4 = true;
      }
      
      protected function createWindow() : void
      {
         _window = UnknownVarFromGroupItem_FurniModel_1.createItemWindow("inventory_thumb_xml");
      }
      
      private function getFurniItemName() : String
      {
         var _loc2_:String = null;
         var _loc3_:ISongInfo = null;
         var _loc1_:FurnitureItem = peek();
         if(_loc1_ == null)
         {
            return "";
         }
         switch(_category - 6)
         {
            case 0:
               _loc2_ = "poster_" + _loc1_.stuffData.getLegacyString() + "_name";
               break;
            case 2:
               _loc3_ = UnknownVarFromGroupItem_FurniModel_1.soundManager.musicController.getSongInfo(_loc1_.extra);
               if(_loc3_ != null)
               {
                  return _loc3_.name;
               }
               getSongInfo(_loc1_);
               return "";
               break;
            default:
               if(isWallItem)
               {
                  _loc2_ = "wallItem.name." + _loc1_.type;
                  break;
               }
               _loc2_ = "roomItem.name." + _loc1_.type;
               break;
         }
         return UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization(_loc2_);
      }
      
      public function isNft() : Boolean
      {
         return className.indexOf("nft_") == 0;
      }
      
      public function get className() : String
      {
         var _loc1_:IFurnitureData = furniData;
         if(_loc1_ == null)
         {
            return "";
         }
         return _loc1_.className;
      }
      
      private function getFurniItemDesc() : String
      {
         var _loc2_:String = null;
         var _loc3_:ISongInfo = null;
         var _loc1_:FurnitureItem = peek();
         if(_loc1_ == null)
         {
            return "";
         }
         switch(_category - 6)
         {
            case 0:
               _loc2_ = "poster_" + _loc1_.stuffData.getLegacyString() + "_desc";
               break;
            case 2:
               _loc3_ = UnknownVarFromGroupItem_FurniModel_1.soundManager.musicController.getSongInfo(_loc1_.extra);
               if(_loc3_ != null)
               {
                  return _loc3_.creator;
               }
               getSongInfo(_loc1_);
               return "";
               break;
            default:
               if(isWallItem)
               {
                  _loc2_ = "wallItem.desc." + _loc1_.type;
                  break;
               }
               _loc2_ = "roomItem.desc." + _loc1_.type;
               break;
         }
         return UnknownVarFromGroupItem_FurniModel_1.controller.localization.getLocalization(_loc2_);
      }
      
      private function getSongInfo(param1:FurnitureItem) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ISongInfo = null;
         if(param1 == null)
         {
            return;
         }
         UnknownVarFromGroupItem_Int_1 = -1;
         if(param1 != null)
         {
            if(param1.category == 8)
            {
               _loc2_ = param1.extra;
               _loc3_ = UnknownVarFromGroupItem_FurniModel_1.soundManager.musicController.getSongInfo(_loc2_);
               if(_loc3_ == null)
               {
                  UnknownVarFromGroupItem_FurniModel_1.soundManager.musicController.requestSongInfoWithoutSamples(_loc2_);
                  UnknownVarFromGroupItem_Int_1 = _loc2_;
               }
            }
         }
      }
      
      private function onSongInfoReceivedEvent(param1:SongInfoReceivedEvent) : void
      {
         if(param1.id == UnknownVarFromGroupItem_Int_1)
         {
            UnknownVarFromGroupItem_Int_1 = -1;
            _name = getFurniItemName();
            _description = getFurniItemDesc();
            if(UnknownVarFromGroupItem_FurniModel_1.getSelectedItem() == this)
            {
               UnknownVarFromGroupItem_FurniModel_1.updateActionView();
            }
         }
      }
      
      public function get selectedItemIndex() : int
      {
         if(UnknownVarFromGroupItem_Int_2 >= _items.length)
         {
            UnknownVarFromGroupItem_Int_2 = Math.max(0,_items.length - 1);
         }
         return UnknownVarFromGroupItem_Int_2;
      }
      
      public function set selectedItemIndex(param1:int) : void
      {
         if(param1 >= _items.length)
         {
            param1 = 0;
         }
         UnknownVarFromGroupItem_Int_2 = param1;
      }
   }
}

