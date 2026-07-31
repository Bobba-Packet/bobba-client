package com.sulake.habbo.window.utils.traxmachine
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.filesystem.File;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class TraxMachineAssets
   {
      
      private var _bitmaps:Dictionary;
      
      private var _pending:int = 0;
      
      private var _onReady:Function;
      
      private var _base:File;
      
      private var _loaders:Dictionary;
      
      public function TraxMachineAssets()
      {
         super();
         _bitmaps = new Dictionary();
         _loaders = new Dictionary();
         _base = TraxMachineCatalog.resolvePackFile("traxmachine/imgs");
         if(_base == null)
         {
            _base = TraxMachineCatalog.resolvePackFile("imgs");
         }
      }
      
      public function get hasBase() : Boolean
      {
         return _base != null && _base.exists;
      }
      
      public function get basePath() : String
      {
         return _base != null ? _base.nativePath : "(missing)";
      }
      
      public function getBitmap(name:String) : BitmapData
      {
         return _bitmaps[name] as BitmapData;
      }
      
      public function soundUrl(fileName:String) : String
      {
         var sounds:File = TraxMachineCatalog.resolvePackFile("traxmachine/sounds/" + fileName);
         if(sounds == null)
         {
            sounds = TraxMachineCatalog.resolvePackFile("sounds/" + fileName);
         }
         return sounds != null ? sounds.url : "";
      }
      
      public function loadAll(onReady:Function) : void
      {
         var names:Array = null;
         var i:int = 0;
         var name:String = null;
         _onReady = onReady;
         if(_base == null || !_base.exists)
         {
            if(_onReady != null)
            {
               names = null;
               var cb:Function = _onReady;
               _onReady = null;
               cb();
            }
            return;
         }
         names = ["cartuchos-list.png","pager-background.png","pager-left.png","pager-right.png","palhetas.png","palheta.png","palheta-header.png","palheta-no-header.png","palheta-piker.png","module.png","00008.png","union.png","agulha.png","play.png","pause.png","stop.png","clear.png","moveLeft.png","moveRight.png","timeline.png","timeline-layer-background.png"];
         for(i = 1; i <= 72; i++)
         {
            names.push((i < 10 ? "0" + i : String(i)) + ".gif");
         }
         _pending = names.length;
         for each(name in names)
         {
            loadOne(name);
         }
      }
      
      private function loadOne(name:String) : void
      {
         var file:File = null;
         var loader:Loader = null;
         try
         {
            file = _base.resolvePath(name);
            if(file == null || !file.exists)
            {
               finishOne();
               return;
            }
            loader = new Loader();
            _loaders[loader.contentLoaderInfo] = name;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
            loader.load(new URLRequest(file.url));
         }
         catch(e:Error)
         {
            finishOne();
         }
      }
      
      private function onLoadComplete(e:Event) : void
      {
         var info:LoaderInfo = null;
         var name:String = null;
         var bmp:Bitmap = null;
         var content:DisplayObject = null;
         var bmd:BitmapData = null;
         try
         {
            info = e.target as LoaderInfo;
            name = _loaders[info] as String;
            if(info != null && info.content != null && name != null)
            {
               bmp = info.content as Bitmap;
               if(bmp != null && bmp.bitmapData != null)
               {
                  _bitmaps[name] = bmp.bitmapData.clone();
               }
               else
               {
                  content = info.content as DisplayObject;
                  if(content != null && content.width > 0 && content.height > 0)
                  {
                     bmd = new BitmapData(Math.ceil(content.width),Math.ceil(content.height),true,0);
                     bmd.draw(content,new Matrix());
                     _bitmaps[name] = bmd;
                  }
               }
            }
         }
         catch(err:Error)
         {
         }
         cleanupLoader(info);
         finishOne();
      }
      
      private function onLoadError(e:IOErrorEvent) : void
      {
         cleanupLoader(e != null ? e.target as LoaderInfo : null);
         finishOne();
      }
      
      private function cleanupLoader(info:LoaderInfo) : void
      {
         if(info == null)
         {
            return;
         }
         try
         {
            info.removeEventListener(Event.COMPLETE,onLoadComplete);
            info.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         }
         catch(e:Error)
         {
         }
         delete _loaders[info];
      }
      
      private function finishOne() : void
      {
         var cb:Function = null;
         _pending--;
         if(_pending <= 0 && _onReady != null)
         {
            cb = _onReady;
            _onReady = null;
            cb();
         }
      }
   }
}
