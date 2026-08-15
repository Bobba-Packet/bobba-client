package com.sulake.habbo.window.utils.bobba
{
   import flash.net.SharedObject;
   
   public class BobbaPresetsSettings
   {
      
      private static const SOL_NAME:String = "HabboAirPlus";
      
      private static const KEY_STACK:String = "BobbaPresetsStackTile";
      
      private static const KEY_PLACE:String = "BobbaPresetsRatePlaceMs";
      
      private static const KEY_MOVE:String = "BobbaPresetsRateMoveMs";
      
      private static const KEY_INCOMPLETE:String = "BobbaPresetsAllowIncomplete";
      
      private static const KEY_WIRED:String = "BobbaPresetsExportWired";
      
      private static const KEY_BUILDER:String = "BobbaPresetsBuilderEnabled";
      
      private static const KEY_BC_WIRED:String = "BobbaPresetsBcWired";
      
      private static const KEY_POST:String = "BobbaPresetsPostJson";
      
      public static const DEFAULT_STACK:String = "tile_stackmagic";
      
      public static const DEFAULT_PLACE_MS:int = 150;
      
      public static const DEFAULT_MOVE_MS:int = 60;
      
      public function BobbaPresetsSettings()
      {
         super();
      }
      
      public static function get stackClass() : String
      {
         var v:String = readString(KEY_STACK,DEFAULT_STACK);
         return v != null && v.length > 0 ? v : DEFAULT_STACK;
      }
      
      public static function set stackClass(value:String) : void
      {
         write(KEY_STACK,value != null && value.length > 0 ? value : DEFAULT_STACK);
      }
      
      public static function get placeMs() : int
      {
         return clamp(readInt(KEY_PLACE,DEFAULT_PLACE_MS),10,2000);
      }
      
      public static function set placeMs(value:int) : void
      {
         write(KEY_PLACE,clamp(value,10,2000));
      }
      
      public static function get moveMs() : int
      {
         return clamp(readInt(KEY_MOVE,DEFAULT_MOVE_MS),10,500);
      }
      
      public static function set moveMs(value:int) : void
      {
         write(KEY_MOVE,clamp(value,10,500));
      }
      
      public static function get allowIncomplete() : Boolean
      {
         return readBool(KEY_INCOMPLETE,false);
      }
      
      public static function set allowIncomplete(value:Boolean) : void
      {
         write(KEY_INCOMPLETE,value);
      }
      
      public static function get exportWired() : Boolean
      {
         return readBool(KEY_WIRED,true);
      }
      
      public static function set exportWired(value:Boolean) : void
      {
         write(KEY_WIRED,value);
      }
      
      public static function get builderEnabled() : Boolean
      {
         return readBool(KEY_BUILDER,false);
      }
      
      public static function set builderEnabled(value:Boolean) : void
      {
         write(KEY_BUILDER,value);
      }
      
      public static function get bcWired() : Boolean
      {
         return readBool(KEY_BC_WIRED,false);
      }
      
      public static function set bcWired(value:Boolean) : void
      {
         write(KEY_BC_WIRED,value);
      }
      
      public static function postFor(presetName:String) : Object
      {
         var all:Object = readPostAll();
         var row:Object = null;
         if(presetName == null || presetName.length == 0 || all == null)
         {
            return {};
         }
         row = all[presetName] as Object;
         return row != null ? row : {};
      }
      
      public static function setPost(presetName:String, furniName:String, hotelId:int) : Boolean
      {
         var all:Object = null;
         if(presetName == null || presetName.length == 0 || furniName == null || furniName.length == 0 || hotelId <= 0)
         {
            return false;
         }
         all = readPostAll();
         if(all[presetName] == null)
         {
            all[presetName] = {};
         }
         all[presetName][furniName] = hotelId;
         return writePostAll(all);
      }
      
      public static function clearPost(presetName:String, furniName:String) : Boolean
      {
         var all:Object = null;
         var row:Object = null;
         if(presetName == null || furniName == null)
         {
            return false;
         }
         all = readPostAll();
         row = all[presetName] as Object;
         if(row == null)
         {
            return false;
         }
         delete row[furniName];
         return writePostAll(all);
      }
      
      public static function postCount(presetName:String) : int
      {
         var row:Object = postFor(presetName);
         var n:int = 0;
         var k:String = null;
         for(k in row)
         {
            n++;
         }
         return n;
      }
      
      private static function readPostAll() : Object
      {
         var raw:String = readString(KEY_POST,"");
         var parsed:Object = null;
         if(raw == null || raw.length == 0)
         {
            return {};
         }
         try
         {
            parsed = JSON.parse(raw) as Object;
            if(parsed != null)
            {
               return parsed;
            }
         }
         catch(e:Error)
         {
         }
         return {};
      }
      
      private static function writePostAll(all:Object) : Boolean
      {
         try
         {
            write(KEY_POST,JSON.stringify(all != null ? all : {}));
            return true;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private static function so() : SharedObject
      {
         return SharedObject.getLocal(SOL_NAME,"/");
      }
      
      private static function readString(key:String, fallback:String) : String
      {
         var obj:SharedObject = null;
         try
         {
            obj = so();
            if(obj != null && obj.data != null && obj.data.hasOwnProperty(key) && obj.data[key] != null)
            {
               return String(obj.data[key]);
            }
         }
         catch(e:Error)
         {
         }
         return fallback;
      }
      
      private static function readInt(key:String, fallback:int) : int
      {
         var obj:SharedObject = null;
         try
         {
            obj = so();
            if(obj != null && obj.data != null && obj.data.hasOwnProperty(key))
            {
               return int(obj.data[key]);
            }
         }
         catch(e:Error)
         {
         }
         return fallback;
      }
      
      private static function readBool(key:String, fallback:Boolean) : Boolean
      {
         var obj:SharedObject = null;
         try
         {
            obj = so();
            if(obj != null && obj.data != null && obj.data.hasOwnProperty(key))
            {
               return obj.data[key] == true;
            }
         }
         catch(e:Error)
         {
         }
         return fallback;
      }
      
      private static function write(key:String, value:*) : void
      {
         var obj:SharedObject = null;
         try
         {
            obj = so();
            if(obj != null && obj.data != null)
            {
               obj.data[key] = value;
               obj.flush();
            }
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] settings save failed",e.message);
         }
      }
      
      private static function clamp(n:int, lo:int, hi:int) : int
      {
         if(n < lo)
         {
            return lo;
         }
         if(n > hi)
         {
            return hi;
         }
         return n;
      }
   }
}
