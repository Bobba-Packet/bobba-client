package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.iid.IIDHabboInventory;
   
   public class BobbaAvailability
   {
      
      public static const STATE_NONE:int = 0;
      
      public static const STATE_LOADING:int = 1;
      
      public static const STATE_READY:int = 2;
      
      public static const STATE_FAIL:int = 3;
      
      private static var _inv:* = undefined;
      
      private static var _hooked:Boolean = false;
      
      private static var _requested:Boolean = false;
      
      private static var _onReady:Function = null;
      
      public function BobbaAvailability()
      {
         super();
      }
      
      public static function state(windowManager:HabboWindowManagerComponent) : int
      {
         if(isReady(windowManager))
         {
            return STATE_READY;
         }
         if(_requested)
         {
            return STATE_LOADING;
         }
         return STATE_NONE;
      }
      
      public static function isReady(windowManager:HabboWindowManagerComponent) : Boolean
      {
         var inv:* = undefined;
         var model:* = undefined;
         try
         {
            inv = inventory(windowManager);
            if(inv == null)
            {
               return false;
            }
            model = inv.furniModel;
            if(model != null && model.isListInited() == true)
            {
               return true;
            }
            if(inv.isInventoryCategoryInit != null && inv.isInventoryCategoryInit("furni") == true)
            {
               return true;
            }
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public static function ensureLoaded(windowManager:HabboWindowManagerComponent, onReady:Function = null) : int
      {
         var inv:* = undefined;
         if(onReady != null)
         {
            _onReady = onReady;
         }
         if(isReady(windowManager))
         {
            return STATE_READY;
         }
         inv = inventory(windowManager);
         if(inv == null)
         {
            return STATE_FAIL;
         }
         hookEvents(inv);
         _requested = true;
         try
         {
            inv.checkCategoryInitilization("furni");
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] inventory request failed",e.message);
            return STATE_FAIL;
         }
         if(isReady(windowManager))
         {
            return STATE_READY;
         }
         return STATE_LOADING;
      }
      
      public static function countHave(windowManager:HabboWindowManagerComponent) : Object
      {
         var have:Object = {};
         var inv:* = undefined;
         var model:* = undefined;
         var groups:* = undefined;
         var i:int = 0;
         var group:* = undefined;
         var peek:* = undefined;
         var typeId:int = 0;
         var n:int = 0;
         var className:String = "";
         var data:IFurnitureData = null;
         try
         {
            inv = inventory(windowManager);
            if(inv == null)
            {
               return have;
            }
            model = inv.furniModel;
            if(model == null)
            {
               return have;
            }
            groups = model.furniData;
            if(groups == null)
            {
               return have;
            }
            for(i = 0; i < groups.length; i++)
            {
               group = groups[i];
               if(group != null)
               {
                  peek = null;
                  try
                  {
                     peek = group.peek();
                  }
                  catch(ePeek:Error)
                  {
                     peek = null;
                  }
                  if(peek == null || peek.isWallItem != true)
                  {
                     typeId = int(group.type);
                     n = int(group.getTotalCount());
                     if(n > 0 && typeId > 0)
                     {
                        className = "";
                        if(windowManager != null && windowManager.sessionDataManager != null)
                        {
                           data = windowManager.sessionDataManager.getFloorItemData(typeId);
                           if(data != null && data.className != null)
                           {
                              className = data.className;
                           }
                        }
                        if(className.length == 0)
                        {
                           className = "type:" + typeId;
                        }
                        if(data != null && data.fullName != null && data.fullName.length > 0)
                        {
                           className = data.fullName;
                        }
                        have[className] = int(have[className]) + n;
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] inventory count failed",e.message);
         }
         return have;
      }
      
      public static function furniData(windowManager:HabboWindowManagerComponent, className:String) : IFurnitureData
      {
         var data:IFurnitureData = null;
         var base:String = "";
         var color:int = 0;
         if(className == null || className.length == 0 || windowManager == null || windowManager.sessionDataManager == null)
         {
            return null;
         }
         base = classBase(className);
         color = classColor(className);
         try
         {
            data = windowManager.sessionDataManager.getFloorItemDataByName(base,color);
            if(data != null)
            {
               return data;
            }
            if(color != 0)
            {
               data = windowManager.sessionDataManager.getFloorItemDataByName(base,0);
               if(data != null)
               {
                  return data;
               }
            }
            if(base != className)
            {
               data = windowManager.sessionDataManager.getFloorItemDataByName(className);
               if(data != null)
               {
                  return data;
               }
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public static function classBase(className:String) : String
      {
         var star:int = 0;
         if(className == null)
         {
            return "";
         }
         star = className.indexOf("*");
         if(star > 0)
         {
            return className.substring(0,star);
         }
         return className;
      }
      
      public static function classColor(className:String) : int
      {
         var star:int = 0;
         var rest:String = "";
         var end:int = 0;
         if(className == null)
         {
            return 0;
         }
         star = className.indexOf("*");
         if(star < 0)
         {
            return 0;
         }
         rest = className.substring(star + 1);
         end = rest.indexOf("*");
         if(end > 0)
         {
            rest = rest.substring(0,end);
         }
         return int(rest);
      }
      
      public static function sameClass(have:String, want:String) : Boolean
      {
         if(have == want)
         {
            return true;
         }
         if(have == null || want == null || have.length == 0 || want.length == 0)
         {
            return false;
         }
         if(classBase(have) != classBase(want))
         {
            return false;
         }
         if(want.indexOf("*") < 0 || have.indexOf("*") < 0)
         {
            return true;
         }
         return classColor(have) == classColor(want);
      }
      
      public static function bcOfferId(windowManager:HabboWindowManagerComponent, className:String) : int
      {
         var data:IFurnitureData = furniData(windowManager,className);
         if(data != null && data.bcOfferId > 0)
         {
            return int(data.bcOfferId);
         }
         return 0;
      }
      
      public static function takeId(windowManager:HabboWindowManagerComponent, className:String, used:Object) : int
      {
         var inv:* = undefined;
         var model:* = undefined;
         var groups:* = undefined;
         var i:int = 0;
         var g:int = 0;
         var group:* = undefined;
         var item:* = undefined;
         var id:int = 0;
         var owned:int = 0;
         var rented:int = 0;
         var n:int = 0;
         var typeId:int = 0;
         var data:IFurnitureData = null;
         var have:String = "";
         if(className == null || className.length == 0)
         {
            return 0;
         }
         if(used == null)
         {
            used = {};
         }
         try
         {
            inv = inventory(windowManager);
            if(inv == null)
            {
               return 0;
            }
            model = inv.furniModel;
            if(model == null)
            {
               return 0;
            }
            groups = model.furniData;
            if(groups == null)
            {
               return 0;
            }
            for(i = 0; i < groups.length; i++)
            {
               group = groups[i];
               if(group != null)
               {
                  have = "";
                  data = null;
                  typeId = int(group.type);
                  if(windowManager != null && windowManager.sessionDataManager != null && typeId > 0)
                  {
                     data = windowManager.sessionDataManager.getFloorItemData(typeId);
                     if(data != null)
                     {
                        if(data.fullName != null && data.fullName.length > 0)
                        {
                           have = data.fullName;
                        }
                        else if(data.className != null)
                        {
                           have = data.className;
                        }
                     }
                  }
                  if(sameClass(have,className) || data != null && data.fullName == className)
                  {
                     owned = 0;
                     rented = 0;
                     n = 0;
                     try
                     {
                        n = int(group.getTotalCount());
                     }
                     catch(eN:Error)
                     {
                        n = 0;
                     }
                     for(g = 0; g < n; g++)
                     {
                        item = null;
                        try
                        {
                           item = group.getAt(g);
                        }
                        catch(eAt:Error)
                        {
                           item = null;
                        }
                        if(item != null && item.isWallItem != true && item.locked != true)
                        {
                           id = int(item.id);
                           if(id != 0 && used[id] != true)
                           {
                              if(item.isRented == true)
                              {
                                 if(rented == 0)
                                 {
                                    rented = id;
                                 }
                              }
                              else if(owned == 0)
                              {
                                 owned = id;
                              }
                           }
                        }
                     }
                     if(owned != 0)
                     {
                        used[owned] = true;
                        return owned;
                     }
                     if(rented != 0)
                     {
                        used[rented] = true;
                        return rented;
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] inventory take failed",e.message);
         }
         return 0;
      }
      
      public static function compare(windowManager:HabboWindowManagerComponent, cfg:BobbaPresetConfig, skipNames:Object = null) : Array
      {
         var need:Object = {};
         var have:Object = countHave(windowManager);
         var rows:Array = [];
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var key:String = "";
         var names:Array = [];
         var haveN:int = 0;
         var needN:int = 0;
         if(cfg != null && cfg.furniture != null)
         {
            for(i = 0; i < cfg.furniture.length; i++)
            {
               f = cfg.furniture[i] as BobbaPresetFurni;
                  if(f != null)
                  {
                     if(skipNames == null || f.name == null || !skipNames.hasOwnProperty(f.name))
                     {
                        key = f.className != null ? f.className : "";
                        if(key.length == 0)
                        {
                           key = "unknown";
                        }
                        need[key] = int(need[key]) + 1;
                     }
                  }
            }
         }
         for(key in need)
         {
            names.push(key);
         }
         names.sort();
         for(i = 0; i < names.length; i++)
         {
            key = String(names[i]);
            needN = int(need[key]);
            haveN = int(have[key]);
            if(bcOfferId(windowManager,key) > 0 && haveN < needN)
            {
               haveN = needN;
            }
            rows.push({
               "className":key,
               "have":haveN,
               "need":needN,
               "missing":(haveN < needN ? needN - haveN : 0)
            });
         }
         return rows;
      }
      
      public static function missingCount(rows:Array) : int
      {
         var n:int = 0;
         var i:int = 0;
         var row:Object = null;
         if(rows == null)
         {
            return 0;
         }
         for(i = 0; i < rows.length; i++)
         {
            row = rows[i] as Object;
            if(row != null && int(row.missing) > 0)
            {
               n++;
            }
         }
         return n;
      }
      
      private static function inventory(windowManager:HabboWindowManagerComponent) : *
      {
         if(_inv != null)
         {
            return _inv;
         }
         if(windowManager == null)
         {
            return null;
         }
         try
         {
            _inv = windowManager.queueInterface(new IIDHabboInventory());
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] inventory lookup failed",e.message);
            _inv = null;
         }
         return _inv;
      }
      
      private static function hookEvents(inv:*) : void
      {
         if(_hooked || inv == null || inv.events == null)
         {
            return;
         }
         try
         {
            inv.events.addEventListener("HFLPE_FURNI_LIST_PARSED",onParsed);
            _hooked = true;
         }
         catch(e:Error)
         {
         }
      }
      
      private static function onParsed(e:*) : void
      {
         var cb:Function = _onReady;
         if(cb != null)
         {
            try
            {
               cb();
            }
            catch(err:Error)
            {
            }
         }
      }
   }
}
