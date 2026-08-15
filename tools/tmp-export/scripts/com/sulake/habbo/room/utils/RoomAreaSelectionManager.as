package com.sulake.habbo.room.utils
{
   import com.sulake.habbo.room.IRoomAreaSelectionManager;
   import com.sulake.habbo.room.IRoomEngine;
   import com.sulake.habbo.room.events.RoomEngineObjectEvent;
   import com.sulake.habbo.room.events.RoomObjectTileMouseEvent;
   import com.sulake.habbo.room.object.visualization.furniture.FurnitureVisualization;
   import com.sulake.habbo.room.object.visualization.room.RoomVisualization;
   import com.sulake.room.object.IRoomObject;
   import flash.filters.ColorMatrixFilter;
   
   public class RoomAreaSelectionManager implements IRoomAreaSelectionManager
   {
      
      public static var NOT_ACTIVE:int = 0;
      
      public static var NOT_SELECTING_AREA:int = 1;
      
      public static var AWAITING_MOUSE_DOWN:int = 2;
      
      public static var SELECTING:int = 3;
      
      private static const HIGHLIGHT_FILTERS:Object = createHighlightFilters();
      
      private var _roomEngine:IRoomEngine;
      
      private var _areaSelectionState:int = NOT_ACTIVE;
      
      private var UnknownVarFromRoomAreaSelectionManager_Int_1:int = 0;
      
      private var UnknownVarFromRoomAreaSelectionManager_Int_2:int = 0;
      
      private var UnknownVarFromRoomAreaSelectionManager_Int_3:int = 0;
      
      private var UnknownVarFromRoomAreaSelectionManager_Int_4:int = 0;
      
      private var _highlightRootX:int = 0;
      
      private var _highlightRootY:int = 0;
      
      private var _highlightWidth:int = 0;
      
      private var _highlightHeight:int = 0;
      
      private var _callback:Function;
      
      private var _highlightType:String = "highlight_brighten";
      
      public function RoomAreaSelectionManager(param1:IRoomEngine)
      {
         super();
         _roomEngine = param1;
         _roomEngine.events.addEventListener("REOE_ADDED",onRoomObjectAdded);
      }
      
      private static function createHighlightFilters() : Object
      {
         var _loc3_:Object = {};
         var _loc4_:Array = [1.5,0,0,0,0,0,1.5,0,0,20,0,0,1.5,0,20,0,0,0,1,0];
         var _loc2_:Array = [1.05,0,0,0,0,0,1.3,0,0,8,0,0,1.8,0,20,0,0,0,1,0];
         var _loc1_:Array = [0.55,0,0,0,-10,0,0.55,0,0,-10,0,0,0.55,0,-10,0,0,0,1,0];
         _loc3_["highlight_brighten"] = [new ColorMatrixFilter(_loc4_)];
         _loc3_["highlight_blue"] = [new ColorMatrixFilter(_loc2_)];
         _loc3_["highlight_darken"] = [new ColorMatrixFilter(_loc1_)];
         return _loc3_;
      }
      
      private function getAllFurnis() : Array
      {
         return _roomEngine.getObjectsByCategory(20).concat(_roomEngine.getObjectsByCategory(10));
      }
      
      public function startSelecting() : void
      {
         if(_areaSelectionState == NOT_SELECTING_AREA)
         {
            clearHighlightSilent();
            _areaSelectionState = AWAITING_MOUSE_DOWN;
            _roomEngine.setMoveBlocked(true);
         }
      }
      
      public function handleTileMouseEvent(param1:RoomObjectTileMouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:Boolean = _areaSelectionState == AWAITING_MOUSE_DOWN && param1.type == "ROE_MOUSE_DOWN";
         if(param1.shiftKey && _areaSelectionState == NOT_SELECTING_AREA && param1.type == "ROE_MOUSE_DOWN")
         {
            startSelecting();
            _loc3_ = true;
         }
         if(_loc3_)
         {
            _areaSelectionState = SELECTING;
            UnknownVarFromRoomAreaSelectionManager_Int_1 = param1.tileXAsInt;
            UnknownVarFromRoomAreaSelectionManager_Int_2 = param1.tileYAsInt;
            UnknownVarFromRoomAreaSelectionManager_Int_3 = param1.tileXAsInt;
            UnknownVarFromRoomAreaSelectionManager_Int_4 = param1.tileYAsInt;
            setHighlight(UnknownVarFromRoomAreaSelectionManager_Int_1,UnknownVarFromRoomAreaSelectionManager_Int_2,1,1);
         }
         else if(_areaSelectionState == SELECTING && param1.type == "ROE_MOUSE_MOVE")
         {
            if(param1.tileXAsInt != UnknownVarFromRoomAreaSelectionManager_Int_3 || param1.tileYAsInt != UnknownVarFromRoomAreaSelectionManager_Int_4)
            {
               UnknownVarFromRoomAreaSelectionManager_Int_3 = param1.tileXAsInt;
               UnknownVarFromRoomAreaSelectionManager_Int_4 = param1.tileYAsInt;
               if(UnknownVarFromRoomAreaSelectionManager_Int_3 > UnknownVarFromRoomAreaSelectionManager_Int_1)
               {
                  _loc4_ = UnknownVarFromRoomAreaSelectionManager_Int_1;
                  _loc2_ = UnknownVarFromRoomAreaSelectionManager_Int_3 - UnknownVarFromRoomAreaSelectionManager_Int_1 + 1;
               }
               else
               {
                  _loc4_ = UnknownVarFromRoomAreaSelectionManager_Int_3;
                  _loc2_ = UnknownVarFromRoomAreaSelectionManager_Int_1 - UnknownVarFromRoomAreaSelectionManager_Int_3 + 1;
               }
               if(UnknownVarFromRoomAreaSelectionManager_Int_4 > UnknownVarFromRoomAreaSelectionManager_Int_2)
               {
                  _loc5_ = UnknownVarFromRoomAreaSelectionManager_Int_2;
                  _loc6_ = UnknownVarFromRoomAreaSelectionManager_Int_4 - UnknownVarFromRoomAreaSelectionManager_Int_2 + 1;
               }
               else
               {
                  _loc5_ = UnknownVarFromRoomAreaSelectionManager_Int_4;
                  _loc6_ = UnknownVarFromRoomAreaSelectionManager_Int_2 - UnknownVarFromRoomAreaSelectionManager_Int_4 + 1;
               }
               setHighlight(_loc4_,_loc5_,_loc2_,_loc6_);
            }
         }
      }
      
      public function finishSelecting() : Boolean
      {
         if(_areaSelectionState == SELECTING)
         {
            _areaSelectionState = NOT_SELECTING_AREA;
            _roomEngine.setMoveBlocked(false);
            if(_callback != null)
            {
               _callback(_highlightRootX,_highlightRootY,_highlightWidth,_highlightHeight);
            }
            return true;
         }
         return false;
      }
      
      private function clearHighlightSilent() : void
      {
         var _loc1_:RoomVisualization = null;
         var _loc2_:IRoomObject = _roomEngine.getRoomObject(_roomEngine.activeRoomId,-1,0);
         if(_loc2_ != null)
         {
            _loc1_ = _loc2_.getVisualization() as RoomVisualization;
            _loc1_.clearHighlightArea();
         }
      }
      
      public function clearHighlight() : void
      {
         if(_areaSelectionState == NOT_ACTIVE)
         {
            return;
         }
         clearHighlightSilent();
         _areaSelectionState = NOT_SELECTING_AREA;
         _roomEngine.setMoveBlocked(false);
         if(_callback != null)
         {
            _callback(0,0,0,0);
         }
      }
      
      public function setHighlight(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:RoomVisualization = null;
         if(_areaSelectionState == NOT_ACTIVE)
         {
            return;
         }
         _highlightRootX = param1;
         _highlightRootY = param2;
         _highlightWidth = param3;
         _highlightHeight = param4;
         var _loc6_:IRoomObject = _roomEngine.getRoomObject(_roomEngine.activeRoomId,-1,0);
         if(_loc6_ != null)
         {
            _loc5_ = _loc6_.getVisualization() as RoomVisualization;
            _loc5_.initializeHighlightArea(param1,param2,param3,param4,HIGHLIGHT_FILTERS[_highlightType]);
         }
      }
      
      public function activate(param1:Function, param2:String) : Boolean
      {
         var _loc3_:FurnitureVisualization = null;
         if(_areaSelectionState != NOT_ACTIVE)
         {
            return false;
         }
         _callback = param1;
         _highlightType = param2;
         for each(var _loc4_ in getAllFurnis())
         {
            _loc3_ = _loc4_.getVisualization() as FurnitureVisualization;
            if(_loc3_ != null)
            {
               _loc3_.lookThrough = true;
            }
         }
         _areaSelectionState = NOT_SELECTING_AREA;
         return true;
      }
      
      public function deactivate() : void
      {
         var _loc1_:FurnitureVisualization = null;
         if(_areaSelectionState == NOT_ACTIVE)
         {
            return;
         }
         _callback = null;
         for each(var _loc2_ in getAllFurnis())
         {
            _loc1_ = _loc2_.getVisualization() as FurnitureVisualization;
            if(_loc1_ != null)
            {
               _loc1_.lookThrough = false;
            }
         }
         clearHighlight();
         _areaSelectionState = NOT_ACTIVE;
      }
      
      private function onRoomObjectAdded(param1:RoomEngineObjectEvent) : void
      {
         var _loc2_:FurnitureVisualization = null;
         if(_areaSelectionState == NOT_ACTIVE)
         {
            return;
         }
         if(param1.type != "REOE_ADDED")
         {
            return;
         }
         if(param1.roomId != _roomEngine.activeRoomId)
         {
            return;
         }
         if(param1.category != 10 && param1.category != 20)
         {
            return;
         }
         var _loc3_:IRoomObject = _roomEngine.getRoomObject(param1.roomId,param1.objectId,param1.category);
         if(_loc3_)
         {
            _loc2_ = _loc3_.getVisualization() as FurnitureVisualization;
            if(_loc2_ != null)
            {
               _loc2_.lookThrough = true;
            }
         }
      }
      
      public function get areaSelectionState() : int
      {
         return _areaSelectionState;
      }
      
      public function dispose() : void
      {
         deactivate();
         _roomEngine.events.removeEventListener("REOE_ADDED",onRoomObjectAdded);
      }
   }
}

