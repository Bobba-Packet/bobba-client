package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   
   public class BobbaStackTiles
   {
      
      public function BobbaStackTiles()
      {
         super();
      }
      
      public static function isStackClass(className:String, want:String) : Boolean
      {
         var have:String = className != null ? className : "";
         var need:String = want != null && want.length > 0 ? want : BobbaPresetsSettings.DEFAULT_STACK;
         if(have.length == 0)
         {
            return false;
         }
         return have == need || have.indexOf(need) == 0;
      }
      
      public static function list(windowManager:HabboWindowManagerComponent, className:String = null) : Array
      {
         var out:Array = [];
         var items:Array = BobbaRoomSnapshot.captureAllFloorItems(windowManager);
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var want:String = className != null && className.length > 0 ? className : BobbaPresetsSettings.stackClass;
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null && isStackClass(f.className,want))
            {
               out.push(f);
            }
         }
         return out;
      }
      
      public static function isUnstackable(windowManager:HabboWindowManagerComponent, furni:BobbaPresetFurni) : Boolean
      {
         var data:IFurnitureData = null;
         if(furni == null)
         {
            return false;
         }
         if(furni.className != null && furni.className.indexOf("wf_") == 0)
         {
            return false;
         }
         if(furni.z >= 0.01)
         {
            return false;
         }
         if(windowManager == null || windowManager.sessionDataManager == null || furni.className == null)
         {
            return false;
         }
         try
         {
            data = BobbaAvailability.furniData(windowManager,furni.className);
            if(data != null && data.canStandOn == true && data.canPutStuffOn == true)
            {
               return true;
            }
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public static function needsHeight(furni:BobbaPresetFurni) : Boolean
      {
         return furni != null && furni.z >= 0.01;
      }
      
      public static function tileKey(x:int, y:int) : String
      {
         return x + "|" + y;
      }
      
      public static function markTile(taken:Object, x:int, y:int) : void
      {
         if(taken != null)
         {
            taken[tileKey(x,y)] = true;
         }
      }
      
      public static function isTaken(taken:Object, x:int, y:int) : Boolean
      {
         return taken != null && taken[tileKey(x,y)] == true;
      }
      
      public static function snapshotTaken(windowManager:HabboWindowManagerComponent) : Object
      {
         var taken:Object = {};
         var items:Array = BobbaRoomSnapshot.captureAllFloorItems(windowManager);
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var customs:* = undefined;
         var session:* = undefined;
         var roomId:int = 0;
         var count:int = 0;
         var obj:* = undefined;
         var loc:* = undefined;
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null)
            {
               markTile(taken,f.x,f.y);
            }
         }
         try
         {
            if(windowManager != null && windowManager.roomEngine != null && windowManager.LilithCustomsInstance != null)
            {
               customs = windowManager.LilithCustomsInstance;
               session = customs.RoomSession;
               if(session != null)
               {
                  roomId = int(session.roomId);
                  count = int(windowManager.roomEngine.getRoomObjectCount(roomId,100));
                  for(i = 0; i < count; i++)
                  {
                     obj = windowManager.roomEngine.getRoomObjectWithIndex(roomId,i,100);
                     if(obj != null)
                     {
                        loc = obj.getLocation();
                        if(loc != null)
                        {
                           markTile(taken,int(Math.round(loc.x)),int(Math.round(loc.y)));
                        }
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
         return taken;
      }
      
      public static function findDropTile(windowManager:HabboWindowManagerComponent, stack:BobbaPresetFurni, rootX:int, rootY:int, dimX:int, dimY:int, extraTaken:Object = null) : Object
      {
         var taken:Object = snapshotTaken(windowManager);
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var d:int = 0;
         var r:int = 0;
         var x:int = 0;
         var y:int = 0;
         var k:String = null;
         var w:int = dimX > 0 ? dimX : 1;
         var h:int = dimY > 0 ? dimY : 1;
         var dirs:Array = [[0,-1],[1,0],[0,1],[-1,0],[1,-1],[1,1],[-1,1],[-1,-1]];
         var seeds:Array = [];
         var items:Array = BobbaRoomSnapshot.captureAllFloorItems(windowManager);
         var cx:int = stack != null ? stack.x : rootX;
         var cy:int = stack != null ? stack.y : rootY;
         if(extraTaken != null)
         {
            for(k in extraTaken)
            {
               taken[k] = true;
            }
         }
         for(y = 0; y < h; y++)
         {
            for(x = 0; x < w; x++)
            {
               markTile(taken,rootX + x,rootY + y);
            }
         }
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null)
            {
               seeds.push(f);
            }
         }
         if(stack != null)
         {
            seeds.unshift(stack);
         }
         for(i = 0; i < seeds.length; i++)
         {
            f = seeds[i] as BobbaPresetFurni;
            if(f != null)
            {
               for(d = 0; d < dirs.length; d++)
               {
                  x = f.x + int(dirs[d][0]);
                  y = f.y + int(dirs[d][1]);
                  if(x >= 0 && y >= 0 && !isTaken(taken,x,y))
                  {
                     return {
                        "x":x,
                        "y":y
                     };
                  }
               }
            }
         }
         for(r = 1; r <= 8; r++)
         {
            for(y = cy - r; y <= cy + r; y++)
            {
               for(x = cx - r; x <= cx + r; x++)
               {
                  if((x == cx - r || x == cx + r || y == cy - r || y == cy + r) && x >= 0 && y >= 0 && !isTaken(taken,x,y))
                  {
                     return {
                        "x":x,
                        "y":y
                     };
                  }
               }
            }
         }
         return null;
      }
      
      public static function findPark(windowManager:HabboWindowManagerComponent, rootX:int, rootY:int, dimX:int, dimY:int, stack:BobbaPresetFurni = null) : Object
      {
         return findDropTile(windowManager,stack,rootX,rootY,dimX,dimY);
      }
   }
}
