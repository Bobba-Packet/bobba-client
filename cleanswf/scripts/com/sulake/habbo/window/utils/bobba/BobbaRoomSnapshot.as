package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.utils.Map;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.room.object.IRoomObject;
   import com.sulake.room.object.IRoomObjectModel;
   import com.sulake.room.utils.IVector3d;
   
   public class BobbaRoomSnapshot
   {
      
      public static const FLOOR_CATEGORY:int = 10;
      
      public static const TEMP_ID_MIN:int = 2147401728;
      
      public static const BC_ID_MIN:int = 2147418112;
      
      public static var lastError:String = "";
      
      public function BobbaRoomSnapshot()
      {
         super();
      }
      
      public static function isTempId(id:int) : Boolean
      {
         return id >= TEMP_ID_MIN && id < BC_ID_MIN;
      }
      
      public static function captureAllFloorItems(windowManager:HabboWindowManagerComponent) : Array
      {
         var items:Array = [];
         var customs:* = undefined;
         var session:* = undefined;
         var roomId:int = 0;
         var count:int = 0;
         var i:int = 0;
         var obj:IRoomObject = null;
         var furni:BobbaPresetFurni = null;
         lastError = "";
         try
         {
            if(windowManager == null || windowManager.roomEngine == null)
            {
               lastError = "no roomEngine";
               return items;
            }
            customs = windowManager.LilithCustomsInstance;
            if(customs == null || customs.IsRoomSessionAvailable != true)
            {
               lastError = "no room session";
               return items;
            }
            session = customs.RoomSession;
            if(session == null)
            {
               lastError = "RoomSession null";
               return items;
            }
            roomId = int(session.roomId);
            count = int(windowManager.roomEngine.getRoomObjectCount(roomId,FLOOR_CATEGORY));
            for(i = 0; i < count; i++)
            {
               obj = windowManager.roomEngine.getRoomObjectWithIndex(roomId,i,FLOOR_CATEGORY);
               furni = fromRoomObject(windowManager,obj);
               if(furni != null)
               {
                  items.push(furni);
               }
            }
         }
         catch(e:Error)
         {
            lastError = e.message;
            Logger.log("[BobbaPresets] snapshot failed",e.message);
         }
         return items;
      }
      
      public static function inRoom(windowManager:HabboWindowManagerComponent) : Boolean
      {
         var customs:* = undefined;
         try
         {
            if(windowManager == null || windowManager.LilithCustomsInstance == null)
            {
               return false;
            }
            customs = windowManager.LilithCustomsInstance;
            return customs.IsRoomSessionAvailable == true && customs.RoomSession != null;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public static function hasRights(windowManager:HabboWindowManagerComponent) : Boolean
      {
         var customs:* = undefined;
         var session:* = undefined;
         try
         {
            if(windowManager == null || windowManager.LilithCustomsInstance == null)
            {
               return false;
            }
            customs = windowManager.LilithCustomsInstance;
            if(customs.IsRoomSessionAvailable != true || customs.RoomSession == null)
            {
               return false;
            }
            session = customs.RoomSession;
            if(session.isRoomOwner == true)
            {
               return true;
            }
            return int(session.roomControllerLevel) >= 1;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public static function hasStackTile(windowManager:HabboWindowManagerComponent, className:String = null) : Boolean
      {
         var items:Array = null;
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var want:String = className != null && className.length > 0 ? className : "tile_stackmagic";
         items = captureAllFloorItems(windowManager);
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null && f.className != null)
            {
               if(f.className == want || f.className.indexOf(want) == 0)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private static function fromRoomObject(windowManager:HabboWindowManagerComponent, obj:IRoomObject) : BobbaPresetFurni
      {
         var model:IRoomObjectModel = null;
         var loc:IVector3d = null;
         var dir:IVector3d = null;
         var typeId:int = 0;
         var data:IFurnitureData = null;
         var item:BobbaPresetFurni = null;
         var rot:int = 0;
         if(obj == null)
         {
            return null;
         }
         model = obj.getModel();
         loc = obj.getLocation();
         dir = obj.getDirection();
         item = new BobbaPresetFurni();
         item.id = obj.getId();
         if(isTempId(item.id))
         {
            return null;
         }
         if(model != null && model.hasNumber("furniture_real_room_object") && int(model.getNumber("furniture_real_room_object")) == 0)
         {
            return null;
         }
         item.x = loc != null ? int(Math.round(loc.x)) : 0;
         item.y = loc != null ? int(Math.round(loc.y)) : 0;
         item.z = loc != null ? Number(loc.z) : 0;
         rot = 0;
         if(dir != null)
         {
            rot = int(Math.round(dir.x / 45)) % 8;
            if(rot < 0)
            {
               rot += 8;
            }
         }
         item.rotation = rot;
         typeId = 0;
         if(model != null && model.hasNumber("furniture_type_id"))
         {
            typeId = int(model.getNumber("furniture_type_id"));
         }
         item.className = obj.getType() != null ? obj.getType() : "";
         if(typeId > 0 && windowManager.sessionDataManager != null)
         {
            data = windowManager.sessionDataManager.getFloorItemData(typeId);
            if(data != null)
            {
               if(data.fullName != null && data.fullName.length > 0)
               {
                  item.className = data.fullName;
               }
               else if(data.className != null && data.className.length > 0)
               {
                  item.className = data.className;
               }
            }
         }
         item.state = String(obj.getState(0));
         item.name = item.className;
         readAds(item,model);
         return item;
      }
      
      private static function readAds(item:BobbaPresetFurni, model:IRoomObjectModel) : void
      {
         var map:Map = null;
         var raw:String = null;
         if(item == null || item.className != "ads_background" || model == null)
         {
            return;
         }
         try
         {
            map = model.getStringToStringMap("furniture_data");
            if(map != null && map.length > 0)
            {
               item.adsImageUrl = strOr(map.getValue("imageUrl"),"");
               item.adsOffsetX = strOr(map.getValue("offsetX"),"0");
               item.adsOffsetY = strOr(map.getValue("offsetY"),"0");
               item.adsOffsetZ = strOr(map.getValue("offsetZ"),"0");
               return;
            }
         }
         catch(e1:Error)
         {
         }
         try
         {
            if(model.hasString("furniture_data"))
            {
               raw = model.getString("furniture_data");
               applyAdsRaw(item,raw);
            }
         }
         catch(e2:Error)
         {
         }
      }
      
      private static function applyAdsRaw(item:BobbaPresetFurni, raw:String) : void
      {
         var parts:Array = null;
         var i:int = 0;
         var pair:String = null;
         var eq:int = 0;
         var key:String = null;
         var val:String = null;
         if(item == null || raw == null || raw.length == 0)
         {
            return;
         }
         item.adsImageUrl = "";
         item.adsOffsetX = "0";
         item.adsOffsetY = "0";
         item.adsOffsetZ = "0";
         parts = raw.split("\t");
         if(parts.length < 2)
         {
            parts = raw.split("\u0001");
         }
         for(i = 0; i < parts.length; i++)
         {
            pair = String(parts[i]);
            eq = pair.indexOf("=");
            if(eq > 0)
            {
               key = pair.substr(0,eq);
               val = pair.substr(eq + 1);
               if(key == "imageUrl")
               {
                  item.adsImageUrl = val;
               }
               else if(key == "offsetX")
               {
                  item.adsOffsetX = val;
               }
               else if(key == "offsetY")
               {
                  item.adsOffsetY = val;
               }
               else if(key == "offsetZ")
               {
                  item.adsOffsetZ = val;
               }
            }
         }
      }
      
      private static function strOr(value:*, fallback:String) : String
      {
         if(value == null)
         {
            return fallback;
         }
         return String(value);
      }
   }
}
