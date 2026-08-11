package com.sulake.habbo.window.utils.bobba
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.text.AntiAliasType;
   import flash.text.GridFitType;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class BobbaGroupWhisperHeaderView extends Sprite
   {
      
      public static const VIEW_W:int = 308;
      
      public static const VIEW_H:int = 52;
      
      private static const FONT_REGULAR:String = "Ubuntu";
      
      private static const FONT_BOLD:String = "Ubuntu bold";
      
      private static const GREEN:uint = 0x31A342;
      
      private static const TEXT_SHADOW:DropShadowFilter = new DropShadowFilter(1,90,0x333333,1,0,0,1,1);
      
      private static const FLOWER_PATH:String = "bobba-flower.png";
      
      private static const FLOWER_CLIP_W:int = 40;
      
      private static const TEXT_GAP:int = 2;
      
      private var _title:TextField;
      
      private var _hint:TextField;
      
      private var _flowerClip:Sprite;
      
      private var _flower:Bitmap;
      
      private var _flowerLoader:Loader;
      
      public function BobbaGroupWhisperHeaderView()
      {
         super();
         mouseEnabled = false;
         mouseChildren = false;
         scrollRect = new Rectangle(0,0,VIEW_W,VIEW_H);
         graphics.beginFill(0x000000,1);
         graphics.drawRect(0,0,VIEW_W,VIEW_H);
         graphics.endFill();
         graphics.lineStyle(1,GREEN,1);
         graphics.moveTo(12,VIEW_H - 1);
         graphics.lineTo(VIEW_W - 12,VIEW_H - 1);
         _title = createText(BobbaI18n.t("groupwhisper.panel.title","Group whisper"),14,0xffffff,true);
         addChild(_title);
         _hint = createText(BobbaI18n.t("groupwhisper.panel.hint","People you are whispering to."),11,0xffffff,false);
         addChild(_hint);
         _flowerClip = new Sprite();
         _flowerClip.mouseEnabled = false;
         _flowerClip.mouseChildren = false;
         _flowerClip.scrollRect = new Rectangle(0,0,FLOWER_CLIP_W,VIEW_H);
         _flowerClip.x = VIEW_W - FLOWER_CLIP_W - 4;
         _flowerClip.y = 0;
         addChild(_flowerClip);
         layoutTexts();
         loadFlower();
      }
      
      public function setHint(text:String) : void
      {
         if(_hint != null)
         {
            _hint.text = text != null ? text : "";
            layoutTexts();
         }
      }
      
      public function dispose() : void
      {
         try
         {
            if(_flowerLoader != null)
            {
               _flowerLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onFlowerLoaded);
               _flowerLoader = null;
            }
         }
         catch(err:Error)
         {
         }
         _title = null;
         _hint = null;
         _flower = null;
         _flowerClip = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      private function layoutTexts() : void
      {
         var textAreaW:int = 0;
         var blockH:Number = 0;
         var startY:int = 0;
         if(_title == null || _hint == null)
         {
            return;
         }
         textAreaW = VIEW_W - FLOWER_CLIP_W - 12;
         _title.wordWrap = false;
         _hint.wordWrap = true;
         _hint.width = Math.max(80,textAreaW - 20);
         blockH = _title.textHeight + TEXT_GAP + _hint.textHeight;
         startY = Math.round((VIEW_H - blockH) / 2);
         if(startY < 2)
         {
            startY = 2;
         }
         _title.y = startY;
         _hint.y = startY + Math.ceil(_title.textHeight) + TEXT_GAP;
         _title.x = Math.round((textAreaW - _title.textWidth) / 2);
         _hint.x = Math.round((textAreaW - Math.min(_hint.textWidth,_hint.width)) / 2);
         if(_title.x < 8)
         {
            _title.x = 8;
         }
         if(_hint.x < 8)
         {
            _hint.x = 8;
         }
      }
      
      private function loadFlower() : void
      {
         try
         {
            _flowerLoader = new Loader();
            _flowerLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onFlowerLoaded);
            _flowerLoader.load(new URLRequest(BobbaPack.resolveUrl(FLOWER_PATH)));
         }
         catch(err:Error)
         {
         }
      }
      
      private function onFlowerLoaded(e:Event) : void
      {
         var bmp:Bitmap = null;
         var data:BitmapData = null;
         try
         {
            bmp = _flowerLoader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null || _flowerClip == null)
            {
               return;
            }
            data = bmp.bitmapData;
            _flower = new Bitmap(data);
            _flower.smoothing = false;
            _flower.pixelSnapping = PixelSnapping.ALWAYS;
            _flower.scaleX = 1;
            _flower.scaleY = 1;
            _flower.x = Math.round((FLOWER_CLIP_W - data.width) / 2);
            _flower.y = 0;
            _flowerClip.addChild(_flower);
         }
         catch(err:Error)
         {
         }
      }
      
      private function createText(value:String, size:int, color:uint, bold:Boolean) : TextField
      {
         var tf:TextField = new TextField();
         var fmt:TextFormat = new TextFormat(bold ? FONT_BOLD : FONT_REGULAR,size,color);
         tf.defaultTextFormat = fmt;
         tf.embedFonts = true;
         tf.antiAliasType = AntiAliasType.ADVANCED;
         tf.gridFitType = GridFitType.PIXEL;
         tf.autoSize = TextFieldAutoSize.LEFT;
         tf.selectable = false;
         tf.mouseEnabled = false;
         tf.filters = [TEXT_SHADOW];
         tf.text = value != null ? value : "";
         return tf;
      }
   }
}
