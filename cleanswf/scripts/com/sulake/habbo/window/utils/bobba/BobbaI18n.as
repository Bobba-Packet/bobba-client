package com.sulake.habbo.window.utils.bobba
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.SharedObject;
   import flash.utils.ByteArray;
   
   // Disk-backed Bobba UI strings. hhbr -> pt-BR, hhes -> es, hhfr -> fr, everything else -> en.
   public class BobbaI18n
   {
      
      private static const SOL_NAME:String = "BobbaClient";
      
      private static const LOCALE_EN:String = "en";
      
      private static const LOCALE_PT_BR:String = "pt-BR";
      
      private static const LOCALE_ES:String = "es";
      
      private static const LOCALE_FR:String = "fr";
      
      private static var _loaded:Boolean = false;
      
      private static var _locale:String = LOCALE_EN;
      
      private static var _hotelId:String = "";
      
      private static var _strings:Object = {};
      
      private static var _fallback:Object = {};
      
      public function BobbaI18n()
      {
         super();
      }
      
      public static function get locale() : String
      {
         ensureLoaded();
         return _locale;
      }
      
      public static function get hotelId() : String
      {
         ensureLoaded();
         return _hotelId;
      }
      
      public static function get loaded() : Boolean
      {
         return _loaded;
      }
      
      public static function init() : void
      {
         ensureLoaded();
      }
      
      public static function ensureLoaded() : void
      {
         if(_loaded)
         {
            return;
         }
         _loaded = true;
         _hotelId = readHotelId();
         _locale = localeForHotel(_hotelId);
         _fallback = loadLocaleMap(LOCALE_EN);
         if(_locale == LOCALE_EN)
         {
            _strings = _fallback;
         }
         else
         {
            _strings = loadLocaleMap(_locale);
            if(_strings == null)
            {
               _strings = _fallback;
               _locale = LOCALE_EN;
            }
         }
         if(_fallback == null)
         {
            _fallback = {};
         }
         if(_strings == null)
         {
            _strings = {};
         }
      }
      
      public static function t(key:String, fallback:String = null) : String
      {
         var value:* = undefined;
         ensureLoaded();
         if(key == null || key.length == 0)
         {
            return fallback != null ? fallback : "";
         }
         if(_strings != null && _strings.hasOwnProperty(key))
         {
            value = _strings[key];
            if(value != null)
            {
               return String(value);
            }
         }
         if(_fallback != null && _fallback.hasOwnProperty(key))
         {
            value = _fallback[key];
            if(value != null)
            {
               return String(value);
            }
         }
         if(fallback != null)
         {
            return fallback;
         }
         return key;
      }
      
      public static function format(key:String, a0:* = null, a1:* = null, a2:* = null) : String
      {
         var text:String = t(key);
         if(a0 != null)
         {
            text = text.split("{0}").join(String(a0));
         }
         if(a1 != null)
         {
            text = text.split("{1}").join(String(a1));
         }
         if(a2 != null)
         {
            text = text.split("{2}").join(String(a2));
         }
         return text;
      }
      
      public static function localeForHotel(hotelId:String) : String
      {
         var id:String = BobbaBackendClient.canonicalizeHotelId(hotelId);
         if(id == "hhbr")
         {
            return LOCALE_PT_BR;
         }
         if(id == "hhes")
         {
            return LOCALE_ES;
         }
         if(id == "hhfr")
         {
            return LOCALE_FR;
         }
         return LOCALE_EN;
      }
      
      private static function readHotelId() : String
      {
         var so:SharedObject = null;
         var hotel:String = null;
         var env:String = null;
         try
         {
            so = SharedObject.getLocal(SOL_NAME,"/");
            hotel = so.data.hotelId as String;
            if(hotel != null && hotel.length > 0)
            {
               return BobbaBackendClient.canonicalizeHotelId(hotel);
            }
            env = so.data.hotelEnvironment as String;
            if(env != null && env.length > 0)
            {
               return BobbaBackendClient.hotelIdFromEnvironment(env);
            }
         }
         catch(err:Error)
         {
         }
         return "unknown";
      }
      
      private static function loadLocaleMap(locale:String) : Object
      {
         var file:File = null;
         var stream:FileStream = null;
         var bytes:ByteArray = null;
         var json:Object = null;
         try
         {
            file = BobbaPack.resolvePackFile("i18n/" + locale + ".json");
            if(file == null || !file.exists)
            {
               return null;
            }
            stream = new FileStream();
            stream.open(file,FileMode.READ);
            bytes = new ByteArray();
            stream.readBytes(bytes);
            stream.close();
            bytes.position = 0;
            json = JSON.parse(bytes.readUTFBytes(bytes.length));
            if(json == null)
            {
               return null;
            }
            return json;
         }
         catch(err:Error)
         {
            return null;
         }
         return null;
      }
   }
}
