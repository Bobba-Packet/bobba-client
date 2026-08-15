package com.sulake.habbo.window.utils.bobba
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   
   public class BobbaPresetStore
   {
      
      public static const EXT:String = ".json";
      
      public function BobbaPresetStore()
      {
         super();
      }
      
      public static function dir() : File
      {
         var folder:File = File.applicationStorageDirectory.resolvePath("presets");
         if(!folder.exists)
         {
            folder.createDirectory();
         }
         ensureExamples(folder);
         return folder;
      }
      
      public static function ensureExamples(folder:File = null) : void
      {
         var dest:File = null;
         var src:File = null;
         try
         {
            if(folder == null)
            {
               folder = File.applicationStorageDirectory.resolvePath("presets");
               if(!folder.exists)
               {
                  folder.createDirectory();
               }
            }
            dest = folder.resolvePath("minimal-glow.json");
            if(dest.exists)
            {
               return;
            }
            src = BobbaPack.resolvePackFile("presets/minimal-glow.json");
            if(src != null && src.exists)
            {
               src.copyTo(dest,true);
            }
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] example copy failed",e.message);
         }
      }
      
      public static function validName(name:String) : Boolean
      {
         if(name == null || name.length == 0)
         {
            return false;
         }
         if(name.indexOf("<") >= 0 || name.indexOf(">") >= 0 || name.indexOf(":") >= 0)
         {
            return false;
         }
         if(name.indexOf("\"") >= 0 || name.indexOf("/") >= 0 || name.indexOf("\\") >= 0)
         {
            return false;
         }
         if(name.indexOf("|") >= 0 || name.indexOf("?") >= 0 || name.indexOf("*") >= 0)
         {
            return false;
         }
         return true;
      }
      
      public static function listNames() : Array
      {
         var folder:File = dir();
         var listing:Array = folder.getDirectoryListing();
         var names:Array = [];
         var i:int = 0;
         var f:File = null;
         var n:String = null;
         if(listing == null)
         {
            return names;
         }
         for(i = 0; i < listing.length; i++)
         {
            f = listing[i] as File;
            if(f != null && f.isDirectory == false)
            {
               n = f.name;
               if(n.length > EXT.length && n.substr(n.length - EXT.length).toLowerCase() == EXT)
               {
                  n = n.substr(0,n.length - EXT.length);
                  if(n.length > 0 && n.charAt(0) != "_")
                  {
                     names.push(n);
                  }
               }
            }
         }
         names.sort();
         return names;
      }
      
      public static function load(name:String) : BobbaPresetConfig
      {
         var file:File = null;
         var stream:FileStream = null;
         var raw:String = null;
         if(!validName(name) && name != "_debug")
         {
            return null;
         }
         try
         {
            file = dir().resolvePath(name + EXT);
            if(file == null || !file.exists)
            {
               return null;
            }
            stream = new FileStream();
            stream.open(file,FileMode.READ);
            raw = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();
            return BobbaPresetConfig.fromJsonString(raw);
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] load failed",e.message);
         }
         return null;
      }
      
      public static function save(name:String, cfg:BobbaPresetConfig) : Boolean
      {
         var file:File = null;
         var stream:FileStream = null;
         if(cfg == null)
         {
            return false;
         }
         if(!validName(name) && name != "_debug")
         {
            return false;
         }
         try
         {
            file = dir().resolvePath(name + EXT);
            stream = new FileStream();
            stream.open(file,FileMode.WRITE);
            stream.writeUTFBytes(cfg.toJsonString());
            stream.close();
            return true;
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] save failed",e.message);
         }
         return false;
      }
      
      public static function reveal() : void
      {
         try
         {
            dir().openWithDefaultApplication();
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] reveal failed",e.message);
         }
      }
   }
}
