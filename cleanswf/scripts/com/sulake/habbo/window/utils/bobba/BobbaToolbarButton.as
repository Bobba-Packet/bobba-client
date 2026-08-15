package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.core.window.components.IDesktopController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.events.WindowMouseEvent;
   import com.sulake.core.window.utils.MouseCursorControl;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   // Skull button on the bottom bar, next to CAMERA. Three-frame sheet: normal | hover | click.
   public class BobbaToolbarButton
   {
      
      private static const MENU_NAME:String = "BOBBA_MENU";
      
      private static const MENU_PATH:String = "bobba_menu.png";
      
      private static const MENU_SIZE:int = 38;
      
      private static const STATE_NORMAL:int = 0;
      
      private static const STATE_HOVER:int = 1;
      
      private static const STATE_CLICK:int = 2;
      
      private var _wm:HabboWindowManagerComponent;
      
      private var _timer:Timer;
      
      private var _region:IWindowController_1;
      
      private var _icon:IBitmapWrapperController;
      
      private var _loader:Loader;
      
      private var _frames:Array;
      
      private var _pressed:Boolean = false;
      
      public function BobbaToolbarButton(windowManager:HabboWindowManagerComponent)
      {
         super();
         _wm = windowManager;
         _timer = new Timer(750);
         _timer.addEventListener("timer",onTick);
         _timer.start();
      }
      
      public function dispose() : void
      {
         if(_timer != null)
         {
            _timer.removeEventListener("timer",onTick);
            _timer.stop();
            _timer = null;
         }
         if(_region != null)
         {
            _region.procedure = null;
            _region = null;
         }
         _icon = null;
         if(_loader != null)
         {
            try
            {
               _loader.contentLoaderInfo.removeEventListener("complete",onLoaded);
               _loader.contentLoaderInfo.removeEventListener("ioError",onLoadError);
            }
            catch(e:Error)
            {
            }
            _loader = null;
         }
         disposeFrames();
         _wm = null;
      }
      
      private function onTick(e:TimerEvent) : void
      {
         try
         {
            tryAttach();
         }
         catch(errTick:Error)
         {
         }
      }
      
      private function tryAttach() : void
      {
         var camera:IWindowController_1 = null;
         var barParent:IWindowController_1 = null;
         var region:IWindowController_1 = null;
         var child:IWindowModel = null;
         var idx:int = 0;
         var i:int = 0;
         var label:String = null;
         if(_icon != null || _wm == null)
         {
            return;
         }
         camera = findCamera();
         if(camera == null)
         {
            return;
         }
         barParent = camera.parent as IWindowController_1;
         if(barParent == null)
         {
            return;
         }
         if(barParent.findChildByName(MENU_NAME) != null)
         {
            if(_timer != null)
            {
               _timer.stop();
            }
            return;
         }
         region = camera.clone() as IWindowController_1;
         if(region == null)
         {
            return;
         }
         region.name = MENU_NAME;
         region.procedure = onRegionEvent;
         region.immediateClickMode = true;
         region.mouseThreshold = 0;
         BobbaI18n.init();
         label = BobbaI18n.t("toolbar.bobba_menu","Bobba Menu");
         region.caption = label;
         try
         {
            region["toolTipCaption"] = label;
         }
         catch(errTip:Error)
         {
         }
         i = 0;
         while(i < region.numChildren)
         {
            child = region.getChildAt(i);
            if(child != null)
            {
               child.visible = false;
               child.ignoreMouseEvents = true;
               child.caption = "";
               try
               {
                  child["toolTipCaption"] = "";
               }
               catch(errChildTip:Error)
               {
               }
            }
            i++;
         }
         _icon = _wm.create("bobba_menu_icon",21,0,0,new Rectangle(0,0,MENU_SIZE,MENU_SIZE),null) as IBitmapWrapperController;
         if(_icon == null)
         {
            region.dispose();
            return;
         }
         _icon.disposesBitmap = false;
         _icon.ignoreMouseEvents = true;
         _icon.mouseThreshold = 0;
         region.addChild(_icon);
         _icon.x = int((region.width - MENU_SIZE) / 2);
         _icon.y = int((region.height - MENU_SIZE) / 2);
         if(region.parent != barParent)
         {
            idx = barParent.getChildIndex(camera);
            if(idx < 0)
            {
               barParent.addChild(region);
            }
            else
            {
               barParent.addChildAt(region,idx + 1);
            }
         }
         else
         {
            idx = barParent.getChildIndex(camera);
            if(idx >= 0)
            {
               barParent.setChildIndex(region,idx + 1);
            }
         }
         _region = region;
         loadSprite();
         if(_timer != null)
         {
            _timer.stop();
         }
      }
      
      private function findCamera() : IWindowController_1
      {
         var i:int = 0;
         var desk:IDesktopController = null;
         var found:IWindowModel = null;
         i = 0;
         while(i < 4)
         {
            desk = _wm.getDesktop(i);
            if(desk != null)
            {
               found = desk.findChildByName("CAMERA");
               if(found != null)
               {
                  return found as IWindowController_1;
               }
            }
            i++;
         }
         return null;
      }
      
      private function loadSprite() : void
      {
         var file:File = null;
         var stream:FileStream = null;
         var bytes:ByteArray = null;
         if(_loader != null)
         {
            try
            {
               _loader.contentLoaderInfo.removeEventListener("complete",onLoaded);
               _loader.contentLoaderInfo.removeEventListener("ioError",onLoadError);
            }
            catch(e:Error)
            {
            }
            _loader = null;
         }
         file = BobbaPack.resolvePackFile(MENU_PATH);
         if(file == null || !file.exists)
         {
            return;
         }
         _loader = new Loader();
         _loader.contentLoaderInfo.addEventListener("complete",onLoaded);
         _loader.contentLoaderInfo.addEventListener("ioError",onLoadError);
         try
         {
            stream = new FileStream();
            stream.open(file,FileMode.READ);
            bytes = new ByteArray();
            stream.readBytes(bytes);
            stream.close();
            _loader.loadBytes(bytes);
         }
         catch(err:Error)
         {
            onLoadError(null);
         }
      }
      
      private function onLoaded(param1:Event) : void
      {
         var sheet:Bitmap = null;
         var src:BitmapData = null;
         var frameW:int = 0;
         var i:int = 0;
         var frame:BitmapData = null;
         if(_loader == null)
         {
            return;
         }
         sheet = _loader.content as Bitmap;
         if(sheet == null || sheet.bitmapData == null)
         {
            return;
         }
         src = sheet.bitmapData;
         frameW = int(src.width / 3);
         if(frameW <= 0 || src.height <= 0)
         {
            return;
         }
         disposeFrames();
         _frames = [];
         i = 0;
         while(i < 3)
         {
            frame = new BitmapData(frameW,src.height,true,0);
            frame.copyPixels(src,new Rectangle(i * frameW,0,frameW,src.height),new Point(0,0));
            _frames.push(frame);
            i++;
         }
         if(_icon != null)
         {
            _icon.width = frameW;
            _icon.height = src.height;
            if(_region != null)
            {
               _icon.x = int((_region.width - frameW) / 2);
               _icon.y = int((_region.height - src.height) / 2);
            }
         }
         setState(STATE_NORMAL);
      }
      
      private function onLoadError(param1:Event) : void
      {
      }
      
      private function setState(state:int) : void
      {
         if(_icon == null || _frames == null || state < 0 || state >= _frames.length)
         {
            return;
         }
         _icon.bitmap = _frames[state] as BitmapData;
         _icon.invalidate();
      }
      
      private function onRegionEvent(param1:WindowEvent, param2:IWindowModel) : void
      {
         var mouse:WindowMouseEvent = param1 as WindowMouseEvent;
         if(mouse == null)
         {
            return;
         }
         if(mouse.type == "WME_CLICK")
         {
            onClick(mouse);
            param1.stopImmediatePropagation();
            return;
         }
         onHover(mouse);
      }
      
      private function onClick(param1:WindowMouseEvent) : void
      {
         try
         {
            if(_wm != null)
            {
               _wm.displayBobbaHelper();
            }
         }
         catch(errOpen:Error)
         {
         }
      }
      
      private function onHover(param1:WindowMouseEvent) : void
      {
         if(param1 == null)
         {
            return;
         }
         switch(param1.type)
         {
            case "WME_OVER":
               MouseCursorControl.type = 2;
               if(_pressed)
               {
                  setState(STATE_CLICK);
               }
               else
               {
                  setState(STATE_HOVER);
               }
               break;
            case "WME_OUT":
               MouseCursorControl.type = 0;
               _pressed = false;
               setState(STATE_NORMAL);
               break;
            case "WME_DOWN":
               _pressed = true;
               setState(STATE_CLICK);
               break;
            case "WME_UP":
               _pressed = false;
               setState(STATE_HOVER);
         }
      }
      
      private function disposeFrames() : void
      {
         var frame:BitmapData = null;
         if(_frames == null)
         {
            return;
         }
         for each(frame in _frames)
         {
            if(frame != null)
            {
               frame.dispose();
            }
         }
         _frames = null;
      }
   }
}
