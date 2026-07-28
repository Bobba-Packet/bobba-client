package com.sulake.habbo.window.utils.bobba
{
   import flash.filesystem.File;
   
   public class BobbaPack
   {
      
      public static const PACK_NAME:String = "bobba";
      
      public function BobbaPack()
      {
         super();
      }
      
      public static function resolvePackFile(relativePath:String) : File
      {
         var path:String = relativePath;
         if(path.indexOf(PACK_NAME + "/") != 0 && path.indexOf(PACK_NAME + "\\") != 0)
         {
            if(path.indexOf("/") < 0 && path.indexOf("\\") < 0)
            {
               path = PACK_NAME + "/" + path;
            }
            else if(path.indexOf(PACK_NAME) != 0)
            {
               path = PACK_NAME + "/" + path;
            }
         }
         var stripped:String = path;
         if(stripped.indexOf(PACK_NAME + "/") == 0)
         {
            stripped = stripped.substring(PACK_NAME.length + 1);
         }
         var roots:Array = [File.applicationDirectory,File.applicationStorageDirectory];
         var i:int = 0;
         var root:File = null;
         var candidate:File = null;
         var variants:Array = null;
         var v:int = 0;
         for(i = 0; i < roots.length; i++)
         {
            root = roots[i] as File;
            if(root == null || !root.exists)
            {
               continue;
            }
            variants = [path,"local_include/" + path,"brand-pack/" + stripped,PACK_NAME + "-pack/" + stripped];
            for(v = 0; v < variants.length; v++)
            {
               candidate = root.resolvePath(variants[v]);
               if(candidate.exists)
               {
                  return candidate;
               }
            }
         }
         return File.applicationDirectory.resolvePath(path);
      }
      
      public static function resolveUrl(relativePath:String) : String
      {
         var file:File = resolvePackFile(relativePath);
         return file.url;
      }
   }
}
