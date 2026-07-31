package com.sulake.habbo.window.utils.traxmachine
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   
   public class TraxMachineCatalog
   {
      
      private var _collections:Array;
      
      private var _songs:Array;
      
      private var _loaded:Boolean = false;
      
      private var _lastError:String = "";
      
      public function TraxMachineCatalog()
      {
         super();
         _collections = [];
         _songs = [];
      }
      
      public function get loaded() : Boolean
      {
         return _loaded;
      }
      
      public function get lastError() : String
      {
         return _lastError;
      }
      
      public function get collections() : Array
      {
         return _collections;
      }
      
      public function get songs() : Array
      {
         return _songs;
      }
      
      public static function resolvePackFile(relativePath:String) : File
      {
         var roots:Array = null;
         var root:File = null;
         var file:File = null;
         var i:int = 0;
         try
         {
            roots = [File.applicationDirectory,File.applicationStorageDirectory];
            for(i = 0; i < roots.length; i++)
            {
               root = roots[i] as File;
               if(root == null)
               {
                  continue;
               }
               file = root.resolvePath(relativePath);
               if(file != null && file.exists)
               {
                  return file;
               }
               file = root.resolvePath("local_include/" + relativePath);
               if(file != null && file.exists)
               {
                  return file;
               }
               file = root.resolvePath("traxmachine-pack/" + relativePath.replace(/^traxmachine\//,""));
               if(file != null && file.exists)
               {
                  return file;
               }
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function loadFromPack() : Boolean
      {
         var file:File = null;
         var stream:FileStream = null;
         var bytes:ByteArray = null;
         var json:Object = null;
         var list:Array = null;
         var i:int = 0;
         _lastError = "";
         try
         {
            file = resolvePackFile("traxmachine/catalog.json");
            if(file == null)
            {
               file = resolvePackFile("catalog.json");
            }
            if(file == null || !file.exists)
            {
               _lastError = "catalog.json not found next to HabboAir (tried applicationDirectory + local_include)";
               return false;
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
               _lastError = "catalog.json parse returned null";
               return false;
            }
            _collections = [null];
            list = json.collections as Array;
            if(list == null)
            {
               _lastError = "catalog.json missing collections";
               return false;
            }
            for(i = 0; i < list.length; i++)
            {
               if(list[i] != null)
               {
                  _collections[int(list[i].id)] = list[i];
               }
            }
            _songs = [null];
            list = json.songs as Array;
            if(list == null)
            {
               _lastError = "catalog.json missing songs";
               return false;
            }
            for(i = 0; i < list.length; i++)
            {
               if(list[i] != null)
               {
                  _songs[int(list[i].id)] = list[i];
               }
            }
            _loaded = true;
            return true;
         }
         catch(e:Error)
         {
            _lastError = e.message;
            return false;
         }
         return false;
      }
      
      public function songIdForCollectionClass(collectionId:int, moduleClass:int) : int
      {
         var song:Object = null;
         for each(song in _songs)
         {
            if(song != null && int(song.collectionId) == collectionId && int(song.moduleClass) == moduleClass)
            {
               return int(song.id);
            }
         }
         return 0;
      }
      
      public function getSong(songId:int) : Object
      {
         if(_songs == null || songId < 0 || songId >= _songs.length)
         {
            return null;
         }
         return _songs[songId];
      }
      
      public function getCollection(collectionId:int) : Object
      {
         if(_collections == null || collectionId < 0 || collectionId >= _collections.length)
         {
            return null;
         }
         return _collections[collectionId];
      }
   }
}
