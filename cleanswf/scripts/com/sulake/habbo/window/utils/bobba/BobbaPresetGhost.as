package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.room.object.data.EmptyStuffData;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.room.utils.Vector3d;
   
   public class BobbaPresetGhost
   {
      
      private static const TEMP_BASE:int = 2147401800;
      
      private static const ALPHA:Number = 0.4;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _cfg:BobbaPresetConfig;
      
      private var _ids:Array;
      
      private var _items:Array;
      
      private var _roomId:int;
      
      private var _spawned:Boolean;
      
      public function BobbaPresetGhost()
      {
         super();
         _ids = [];
         _items = [];
         _spawned = false;
         _roomId = 0;
      }
      
      public function attach(windowManager:HabboWindowManagerComponent, cfg:BobbaPresetConfig) : void
      {
         clear();
         _windowManager = windowManager;
         _cfg = cfg;
      }
      
      public function moveTo(rootX:int, rootY:int) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var obj:* = undefined;
         var model:* = undefined;
         if(_windowManager == null || _cfg == null)
         {
            return;
         }
         _roomId = currentRoomId();
         if(_roomId == 0)
         {
            return;
         }
         if(!_spawned)
         {
            spawn(_roomId,rootX,rootY);
         }
         for(i = 0; i < _ids.length; i++)
         {
            f = _items[i] as BobbaPresetFurni;
            if(f != null)
            {
               obj = _windowManager.roomEngine.getRoomObject(_roomId,int(_ids[i]),10);
               if(obj != null)
               {
                  try
                  {
                     obj.setLocation(new Vector3d(rootX + f.x,rootY + f.y,f.z));
                     obj.setDirection(new Vector3d(f.rotation * 45));
                     model = obj.getModelController();
                     if(model != null)
                     {
                        model.setNumber("furniture_alpha_multiplier",ALPHA);
                        model.setNumber("furniture_real_room_object",0,false);
                     }
                  }
                  catch(eMove:Error)
                  {
                  }
               }
            }
         }
      }
      
      public function clear() : void
      {
         var i:int = 0;
         var id:int = 0;
         if(_windowManager != null && _windowManager.roomEngine != null && _roomId != 0)
         {
            for(i = 0; i < _ids.length; i++)
            {
               id = int(_ids[i]);
               try
               {
                  _windowManager.roomEngine.disposeObjectFurniture(_roomId,id);
               }
               catch(e:Error)
               {
               }
            }
         }
         _ids = [];
         _items = [];
         _spawned = false;
         _roomId = 0;
         _cfg = null;
      }
      
      public function dispose() : void
      {
         clear();
         _windowManager = null;
      }
      
      private function spawn(roomId:int, rootX:int, rootY:int) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var typeId:int = 0;
         var ghostId:int = 0;
         var state:int = 0;
         var loc:Vector3d = null;
         var dir:Vector3d = null;
         var stuff:EmptyStuffData = null;
         if(_cfg == null || _cfg.furniture == null || _windowManager == null || _windowManager.roomEngine == null)
         {
            return;
         }
         _ids = [];
         _items = [];
         for(i = 0; i < _cfg.furniture.length; i++)
         {
            f = _cfg.furniture[i] as BobbaPresetFurni;
            if(f != null && f.className != null && f.className.length > 0)
            {
               typeId = typeIdFor(f.className);
               ghostId = TEMP_BASE + _ids.length;
               state = f.state != null && f.state.length > 0 ? int(f.state) : 0;
               loc = new Vector3d(rootX + f.x,rootY + f.y,f.z);
               dir = new Vector3d(f.rotation * 45);
               stuff = new EmptyStuffData();
               try
               {
                  if(typeId > 0)
                  {
                     _windowManager.roomEngine.addObjectFurniture(roomId,ghostId,typeId,loc,dir,state,stuff,NaN,-1,0,0,"",false,false);
                  }
                  else
                  {
                     _windowManager.roomEngine.addObjectFurnitureByName(roomId,ghostId,f.className,loc,dir,state,stuff);
                  }
                  _ids.push(ghostId);
                  _items.push(f);
               }
               catch(eAdd:Error)
               {
                  Logger.log("[BobbaPresets] ghost add failed",f.className,eAdd.message);
               }
            }
         }
         _spawned = true;
      }
      
      private function typeIdFor(className:String) : int
      {
         var data:IFurnitureData = null;
         try
         {
            if(_windowManager != null && _windowManager.sessionDataManager != null)
            {
               data = BobbaAvailability.furniData(_windowManager,className);
               if(data != null)
               {
                  return int(data.id);
               }
            }
         }
         catch(e:Error)
         {
         }
         return 0;
      }
      
      private function currentRoomId() : int
      {
         var customs:* = undefined;
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null)
            {
               customs = _windowManager.LilithCustomsInstance;
               if(customs.RoomSession != null)
               {
                  return int(customs.RoomSession.roomId);
               }
            }
         }
         catch(e:Error)
         {
         }
         return 0;
      }
   }
}
