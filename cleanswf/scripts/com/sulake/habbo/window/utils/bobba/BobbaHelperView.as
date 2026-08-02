package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.utils.FontEnum;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   
   public class BobbaHelperView extends Sprite
   {
      
      public static const VIEW_W:int = 378;
      
      public static const VIEW_H:int = 394;
      
      private static const LOGO_PATH:String = "bobba-client-logo-splash.png";
      
      private static const CHECKBOX_PATH:String = "checkbox.png";
      
      private static const FLOWER_PATH:String = "bobba-flower.png";
      
      private static const DISCORD_BTN_PATH:String = "bobba-discord-btn.png";
      
      private static const SETTINGS_BTN_PATH:String = "bobba-settings-btn.png";
      
      private static const DISCORD_URL:String = "https://discord.gg/J6xRBwp5Yf";
      
      private static const FONT_REGULAR:String = "Ubuntu";
      
      private static const FONT_BOLD:String = "Ubuntu bold";
      
      private static const GREEN:uint = 0x31A342;
      
      private static const LOGO_SCALE:int = 1;
      
      private static const FLOWER_SCALE:int = 1;
      
      private static const CHECK_SCALE:int = 1;
      
      private static const LOGO_X:Number = 27;
      
      private static const LOGO_Y:Number = 16;
      
      private static const TEXT_X:Number = 177;
      
      private static const TEXT_RIGHT_PAD:Number = 14;
      
      private static const HEADLINE_Y:Number = 27;
      
      private static const HEADLINE_SIZE:int = 15;
      
      private static const SUBTITLE_SIZE:int = 12;
      
      private static const VERSION_SIZE:int = 10;
      
      private static const SUBTITLE_GAP:Number = 3;
      
      private static const VERSION_GAP:Number = 4;
      
      private static const CHECK_SIZE:Number = 18 * CHECK_SCALE;
      
      private static const CHECK_LABEL_GAP:Number = 4;
      
      private static const COL_LEFT_X:Number = 22;
      
      private static const COL_RIGHT_X:Number = 199;
      
      private static const EXTRA_LEFT_X:Number = 70;
      
      private static const COL_WIDTH:Number = 195;
      
      private static const OPTION_SIZE:int = 12;
      
      private static const TITLE_SIZE:int = 13;
      
      private static const TITLE_TO_ROW:Number = 22;
      
      private static const ROW_SPACING:Number = 24;
      
      private static const SECTION1_Y:Number = 128;
      
      private static const SECTION2_Y:Number = 203;
      
      private static const EXTRA_Y:Number = 298;
      
      private static const BUTTON_Y:Number = 352;
      
      private static const DISCORD_X:Number = 70;
      
      private static const SETTINGS_X:Number = 199;
      
      private static const FLOWER_X:Number = 15;
      
      private static const STATE_NORMAL:int = 0;
      
      private static const STATE_HOVER:int = 1;
      
      private static const STATE_CLICK:int = 2;
      
      private static const STATUS_TAG_PAD_X:Number = 8;
      
      private static const STATUS_TAG_PAD_Y:Number = 3;
      
      private static const STATUS_DOT:Number = 6;
      
      private static const COLOR_ONLINE:uint = 0x31A342;
      
      private static const COLOR_OFFLINE:uint = 0x6E6E6E;
      
      private static const COLOR_BUSY:uint = 0xC9A227;
      
      private static const COLOR_ERROR:uint = 0xC0392B;
      
      private var _controller:*;
      
      private var _checkOff:BitmapData;
      
      private var _checkOn:BitmapData;
      
      private var _boxByRow:Dictionary;
      
      private var _keyByRow:Dictionary;
      
      private var _actionByRow:Dictionary;
      
      private var _btnFrames:Dictionary;
      
      private var _btnBmp:Dictionary;
      
      private var _btnPressed:Dictionary;
      
      private var _statusTag:Sprite;
      
      private var _statusDot:Sprite;
      
      private var _statusLabel:TextField;
      
      private var _backendStatus:String = "disconnected";
      
      private var _backendDetail:String = "";
      
      public function BobbaHelperView(controller:*)
      {
         super();
         _controller = controller;
         _boxByRow = new Dictionary();
         _keyByRow = new Dictionary();
         _actionByRow = new Dictionary();
         _btnFrames = new Dictionary();
         _btnBmp = new Dictionary();
         _btnPressed = new Dictionary();
         mouseEnabled = true;
         mouseChildren = true;
         drawBackground();
         buildCopy();
         loadButtons();
         loadLogo();
         loadCheckbox();
         loadFlower();
      }
      
      public function setBackendStatus(status:String, detail:String = "") : void
      {
         _backendStatus = status != null ? status : "disconnected";
         _backendDetail = detail != null ? detail : "";
         redrawStatusTag();
      }
      
      public function dispose() : void
      {
         while(numChildren > 0)
         {
            removeChildAt(0);
         }
         _controller = null;
         _boxByRow = null;
         _keyByRow = null;
         _actionByRow = null;
         _btnFrames = null;
         _btnBmp = null;
         _btnPressed = null;
         _checkOff = null;
         _checkOn = null;
         _statusTag = null;
         _statusDot = null;
         _statusLabel = null;
      }
      
      private function drawBackground() : void
      {
         graphics.beginFill(0x000000,1);
         graphics.drawRect(0,0,VIEW_W,VIEW_H);
         graphics.endFill();
      }
      
      private function buildCopy() : void
      {
         var copyWidth:Number = VIEW_W - TEXT_X - TEXT_RIGHT_PAD;
         var headline:TextField = createText("Customize a sua experiência de jogo",HEADLINE_SIZE,0xFFFFFF,true,copyWidth);
         headline.x = TEXT_X;
         headline.y = HEADLINE_Y;
         addChild(headline);
         var subtitle:TextField = createText("Utilize esse menu interativo para fazer as configurações iniciais :)",SUBTITLE_SIZE,0xD8D4D3,false,copyWidth);
         subtitle.x = TEXT_X;
         subtitle.y = Math.round(headline.y + headline.height + SUBTITLE_GAP);
         addChild(subtitle);
         var versionField:TextField = createText("Versão 0.1.0",VERSION_SIZE,0x6E6E6E,false,copyWidth);
         versionField.multiline = false;
         versionField.wordWrap = false;
         versionField.autoSize = TextFieldAutoSize.LEFT;
         versionField.width = versionField.textWidth + 8;
         versionField.x = TEXT_X;
         versionField.y = Math.round(subtitle.y + subtitle.height + VERSION_GAP);
         addChild(versionField);
         buildStatusTag(Math.round(versionField.x + versionField.width + 8),versionField.y - 1);
         setBackendStatus(_backendStatus,_backendDetail);
      }
      
      private function buildStatusTag(x:Number, y:Number) : void
      {
         _statusTag = new Sprite();
         _statusTag.x = Math.round(x);
         _statusTag.y = Math.round(y);
         _statusTag.mouseEnabled = false;
         _statusTag.mouseChildren = false;
         _statusDot = new Sprite();
         _statusDot.x = STATUS_TAG_PAD_X;
         _statusDot.y = STATUS_TAG_PAD_Y + 3;
         _statusTag.addChild(_statusDot);
         _statusLabel = createText("Offline",VERSION_SIZE,0xEAE6E5,true,80);
         _statusLabel.x = STATUS_TAG_PAD_X + STATUS_DOT + 5;
         _statusLabel.y = STATUS_TAG_PAD_Y - 1;
         _statusTag.addChild(_statusLabel);
         addChild(_statusTag);
      }
      
      private function redrawStatusTag() : void
      {
         var color:uint = COLOR_OFFLINE;
         var label:String = "Offline";
         var tagW:Number = 0;
         var tagH:Number = 0;
         if(_statusTag == null || _statusLabel == null || _statusDot == null)
         {
            return;
         }
         if(_backendStatus == "connected")
         {
            color = COLOR_ONLINE;
            label = "Online";
         }
         else if(_backendStatus == "connecting" || _backendStatus == "handshake")
         {
            color = COLOR_BUSY;
            label = "Offline";
         }
         else
         {
            color = COLOR_OFFLINE;
            label = "Offline";
         }
         _statusLabel.textColor = 0xEAE6E5;
         _statusLabel.text = label;
         _statusLabel.width = _statusLabel.textWidth + 4;
         _statusLabel.height = _statusLabel.textHeight + 4;
         _statusDot.graphics.clear();
         _statusDot.graphics.beginFill(color,1);
         _statusDot.graphics.drawCircle(STATUS_DOT * 0.5,STATUS_DOT * 0.5,STATUS_DOT * 0.5);
         _statusDot.graphics.endFill();
         tagW = Math.ceil(_statusLabel.x + _statusLabel.width + STATUS_TAG_PAD_X);
         tagH = Math.ceil(Math.max(STATUS_DOT + STATUS_TAG_PAD_Y * 2,_statusLabel.height + STATUS_TAG_PAD_Y));
         _statusTag.graphics.clear();
         _statusTag.graphics.beginFill(color,0.22);
         _statusTag.graphics.lineStyle(1,color,0.9);
         _statusTag.graphics.drawRoundRect(0,0,tagW,tagH,8,8);
         _statusTag.graphics.endFill();
      }
      
      private function loadButtons() : void
      {
         loadImage(DISCORD_BTN_PATH,onDiscordBtnLoaded);
         loadImage(SETTINGS_BTN_PATH,onSettingsBtnLoaded);
      }
      
      private function onDiscordBtnLoaded(evt:Event) : void
      {
         addLoadedSpriteButton(evt,DISCORD_X,BUTTON_Y,onDiscordClick);
      }
      
      private function onSettingsBtnLoaded(evt:Event) : void
      {
         addLoadedSpriteButton(evt,SETTINGS_X,BUTTON_Y,null);
      }
      
      private function addLoadedSpriteButton(evt:Event, x:Number, y:Number, clickHandler:Function) : void
      {
         var bmp:Bitmap = null;
         var loader:Loader = null;
         var frames:Array = null;
         try
         {
            loader = evt.target.loader as Loader;
            bmp = loader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            frames = sliceButtonSheet(bmp.bitmapData);
            if(frames == null || frames.length < 3)
            {
               return;
            }
            addSpriteButton(frames,x,y,clickHandler);
         }
         catch(errBtn:Error)
         {
         }
      }
      
      private function sliceButtonSheet(full:BitmapData) : Array
      {
         var frameW:int = int(full.width / 3);
         var frames:Array = [];
         var i:int = 0;
         var frame:BitmapData = null;
         while(i < 3)
         {
            frame = new BitmapData(frameW,full.height,true,0);
            frame.copyPixels(full,new Rectangle(i * frameW,0,frameW,full.height),new Point(0,0));
            frames.push(frame);
            i++;
         }
         return frames;
      }
      
      private function addSpriteButton(frames:Array, x:Number, y:Number, clickHandler:Function) : void
      {
         var btn:Sprite = new Sprite();
         var bmp:Bitmap = placePixelArt(new Bitmap(frames[STATE_NORMAL] as BitmapData),0,0,1);
         btn.addChild(bmp);
         btn.x = Math.round(x);
         btn.y = Math.round(y);
         btn.buttonMode = true;
         btn.useHandCursor = true;
         btn.mouseChildren = false;
         _btnFrames[btn] = frames;
         _btnBmp[btn] = bmp;
         _btnPressed[btn] = false;
         btn.addEventListener(MouseEvent.ROLL_OVER,onSpriteBtnOver);
         btn.addEventListener(MouseEvent.ROLL_OUT,onSpriteBtnOut);
         btn.addEventListener(MouseEvent.MOUSE_DOWN,onSpriteBtnDown);
         btn.addEventListener(MouseEvent.MOUSE_UP,onSpriteBtnUp);
         if(clickHandler != null)
         {
            btn.addEventListener(MouseEvent.CLICK,clickHandler);
         }
         addChild(btn);
      }
      
      private function setSpriteBtnState(btn:Sprite, state:int) : void
      {
         var frames:Array = null;
         var bmp:Bitmap = null;
         if(btn == null || _btnFrames == null || _btnBmp == null)
         {
            return;
         }
         frames = _btnFrames[btn] as Array;
         bmp = _btnBmp[btn] as Bitmap;
         if(frames == null || bmp == null || state < 0 || state >= frames.length)
         {
            return;
         }
         bmp.bitmapData = frames[state] as BitmapData;
      }
      
      private function onSpriteBtnOver(e:MouseEvent) : void
      {
         var btn:Sprite = e.currentTarget as Sprite;
         if(btn == null)
         {
            return;
         }
         if(_btnPressed[btn] == true)
         {
            setSpriteBtnState(btn,STATE_CLICK);
         }
         else
         {
            setSpriteBtnState(btn,STATE_HOVER);
         }
      }
      
      private function onSpriteBtnOut(e:MouseEvent) : void
      {
         var btn:Sprite = e.currentTarget as Sprite;
         if(btn == null)
         {
            return;
         }
         _btnPressed[btn] = false;
         setSpriteBtnState(btn,STATE_NORMAL);
      }
      
      private function onSpriteBtnDown(e:MouseEvent) : void
      {
         var btn:Sprite = e.currentTarget as Sprite;
         if(btn == null)
         {
            return;
         }
         _btnPressed[btn] = true;
         setSpriteBtnState(btn,STATE_CLICK);
      }
      
      private function onSpriteBtnUp(e:MouseEvent) : void
      {
         var btn:Sprite = e.currentTarget as Sprite;
         if(btn == null)
         {
            return;
         }
         _btnPressed[btn] = false;
         setSpriteBtnState(btn,STATE_HOVER);
      }
      
      private function onDiscordClick(e:MouseEvent) : void
      {
         try
         {
            navigateToURL(new URLRequest(DISCORD_URL),"_blank");
         }
         catch(errNav:Error)
         {
         }
      }
      
      private function createText(textValue:String, size:int, color:uint, bold:Boolean, width:Number) : TextField
      {
         var field:TextField = new TextField();
         field.selectable = false;
         field.multiline = true;
         field.wordWrap = true;
         field.mouseEnabled = false;
         field.width = width;
         field.autoSize = TextFieldAutoSize.NONE;
         var fmt:TextFormat = new TextFormat();
         var fontName:String = bold ? FONT_BOLD : FONT_REGULAR;
         if(FontEnum.isEmbeddedFont(fontName))
         {
            fmt.font = fontName;
            fmt.bold = false;
            field.embedFonts = true;
            field.antiAliasType = "advanced";
            field.gridFitType = "pixel";
            field.sharpness = 100;
            field.thickness = 0;
         }
         else
         {
            fmt.font = "Verdana";
            fmt.bold = bold;
         }
         fmt.size = size;
         fmt.color = color;
         fmt.leading = 2;
         field.defaultTextFormat = fmt;
         field.text = textValue;
         field.height = field.textHeight + 6;
         return field;
      }
      
      private function loadImage(relativePath:String, onComplete:Function) : void
      {
         var url:String = BobbaPack.resolveUrl(relativePath);
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener("complete",onComplete);
         loader.contentLoaderInfo.addEventListener("ioError",onAssetError);
         try
         {
            loader.load(new URLRequest(url));
         }
         catch(errLoad:Error)
         {
         }
      }
      
      private function loadLogo() : void
      {
         loadImage(LOGO_PATH,onLogoLoaded);
      }
      
      private function onLogoLoaded(evt:Event) : void
      {
         var bmp:Bitmap = null;
         var loader:Loader = null;
         try
         {
            loader = evt.target.loader as Loader;
            bmp = loader.content as Bitmap;
            if(bmp == null)
            {
               return;
            }
            addChildAt(placePixelArt(bmp,LOGO_X,LOGO_Y,LOGO_SCALE),0);
         }
         catch(errLogo:Error)
         {
         }
      }
      
      private function placePixelArt(bmp:Bitmap, x:Number, y:Number, scale:int) : Bitmap
      {
         bmp.smoothing = false;
         bmp.pixelSnapping = PixelSnapping.ALWAYS;
         bmp.scaleX = scale;
         bmp.scaleY = scale;
         bmp.x = Math.round(x);
         bmp.y = Math.round(y);
         return bmp;
      }
      
      private function loadFlower() : void
      {
         loadImage(FLOWER_PATH,onFlowerLoaded);
      }
      
      private function onFlowerLoaded(evt:Event) : void
      {
         var bmp:Bitmap = null;
         var loader:Loader = null;
         try
         {
            loader = evt.target.loader as Loader;
            bmp = loader.content as Bitmap;
            if(bmp == null)
            {
               return;
            }
            addChild(placePixelArt(bmp,FLOWER_X,VIEW_H - bmp.height * FLOWER_SCALE,FLOWER_SCALE));
         }
         catch(errFlower:Error)
         {
         }
      }
      
      private function loadCheckbox() : void
      {
         loadImage(CHECKBOX_PATH,onCheckboxLoaded);
      }
      
      private function onCheckboxLoaded(evt:Event) : void
      {
         var bmp:Bitmap = null;
         var full:BitmapData = null;
         var half:int = 0;
         var loader:Loader = null;
         try
         {
            loader = evt.target.loader as Loader;
            bmp = loader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            full = bmp.bitmapData;
            half = int(full.width / 2);
            _checkOff = new BitmapData(half,full.height,true,0);
            _checkOff.copyPixels(full,new Rectangle(0,0,half,full.height),new Point(0,0));
            _checkOn = new BitmapData(half,full.height,true,0);
            _checkOn.copyPixels(full,new Rectangle(half,0,half,full.height),new Point(0,0));
            buildSections();
         }
         catch(errCheck:Error)
         {
         }
      }
      
      private function buildSections() : void
      {
         addSectionTitle("Funções de usuário",COL_LEFT_X,SECTION1_Y);
         addToggleRow("afk","Anti AFK",COL_LEFT_X,SECTION1_Y + TITLE_TO_ROW);
         addToggleRow("autodrop","Auto drop",COL_LEFT_X,SECTION1_Y + TITLE_TO_ROW + ROW_SPACING);
         addToggleRow("turnblock","Bloquear giro",COL_RIGHT_X,SECTION1_Y + TITLE_TO_ROW);
         addSectionTitle("Qualidade de vida",COL_LEFT_X,SECTION2_Y);
         addToggleRow("groupchat","Chat em grupo",COL_LEFT_X,SECTION2_Y + TITLE_TO_ROW);
         addToggleRow("disable67","Desativar 67",COL_LEFT_X,SECTION2_Y + TITLE_TO_ROW + ROW_SPACING);
         addToggleRow("disablehabbicons","Desativar Habbicons",COL_LEFT_X,SECTION2_Y + TITLE_TO_ROW + ROW_SPACING * 2);
         addToggleRow("groupwhisper","Sussurro em grupo",COL_RIGHT_X,SECTION2_Y + TITLE_TO_ROW);
         addToggleRow("movewallitem","Mover item de parede",COL_RIGHT_X,SECTION2_Y + TITLE_TO_ROW + ROW_SPACING);
         addSectionTitle("Extra",EXTRA_LEFT_X,EXTRA_Y);
         addActionRow("Traxmachine",EXTRA_LEFT_X,EXTRA_Y + TITLE_TO_ROW,null,"traxmachine");
         addToggleRow("bobbalooks","Ver visuais Bobba",COL_RIGHT_X,EXTRA_Y + TITLE_TO_ROW);
      }
      
      private function addSectionTitle(titleText:String, x:Number, y:Number) : void
      {
         var title:TextField = createText(titleText,TITLE_SIZE,0xFFFFFF,true,VIEW_W - x - 14);
         title.x = x;
         title.y = y;
         addChild(title);
      }
      
      private function makeRow(labelText:String, x:Number, y:Number, on:Boolean, greenWord:String) : Sprite
      {
         var idx:int = 0;
         var greenFmt:TextFormat = null;
         var row:Sprite = new Sprite();
         var box:Bitmap = placePixelArt(new Bitmap(on ? _checkOn : _checkOff),0,0,CHECK_SCALE);
         row.addChild(box);
         var label:TextField = createText(labelText,OPTION_SIZE,0xFFFFFF,false,COL_WIDTH - CHECK_SIZE - CHECK_LABEL_GAP);
         if(greenWord != null)
         {
            idx = labelText.indexOf(greenWord);
            if(idx >= 0)
            {
               greenFmt = new TextFormat();
               greenFmt.color = GREEN;
               label.setTextFormat(greenFmt,idx,idx + greenWord.length);
            }
         }
         label.x = CHECK_SIZE + CHECK_LABEL_GAP;
         label.y = Math.round((CHECK_SIZE - label.height) / 2);
         row.addChild(label);
         row.x = x;
         row.y = y;
         row.buttonMode = true;
         row.useHandCursor = true;
         row.mouseChildren = false;
         _boxByRow[row] = box;
         addChild(row);
         return row;
      }
      
      private function addToggleRow(key:String, labelText:String, x:Number, y:Number) : void
      {
         var selected:Boolean = false;
         if(_controller != null)
         {
            selected = _controller.GetBobbaToggle(key) == true;
         }
         var row:Sprite = makeRow(labelText,x,y,selected,null);
         row.addEventListener(MouseEvent.CLICK,onRowClick);
         _keyByRow[row] = key;
      }
      
      private function addActionRow(labelText:String, x:Number, y:Number, greenWord:String, action:String = null) : void
      {
         var row:Sprite = makeRow(labelText,x,y,true,greenWord);
         if(action != null && action.length > 0)
         {
            row.buttonMode = true;
            row.mouseChildren = false;
            row.addEventListener(MouseEvent.CLICK,onActionRowClick);
            _actionByRow[row] = action;
         }
      }
      
      private function onActionRowClick(e:MouseEvent) : void
      {
         var row:Sprite = null;
         var action:String = null;
         try
         {
            row = e.currentTarget as Sprite;
            if(row == null || _controller == null || _actionByRow == null)
            {
               return;
            }
            action = _actionByRow[row] as String;
            if(action == "traxmachine")
            {
               if(_controller.WindowManager != null)
               {
                  _controller.WindowManager.displayTraxMachine();
               }
            }
         }
         catch(errAction:Error)
         {
         }
      }
      
      public function refresh() : void
      {
         var rowKey:Object = null;
         var box:Bitmap = null;
         var key:String = null;
         var selected:Boolean = false;
         if(_keyByRow == null || _controller == null)
         {
            redrawStatusTag();
            return;
         }
         for(rowKey in _keyByRow)
         {
            key = _keyByRow[rowKey] as String;
            box = _boxByRow[rowKey] as Bitmap;
            if(box != null && _checkOff != null)
            {
               selected = _controller.GetBobbaToggle(key) == true;
               box.bitmapData = selected ? _checkOn : _checkOff;
            }
         }
         redrawStatusTag();
      }
      
      private function onRowClick(e:MouseEvent) : void
      {
         var row:Sprite = null;
         var key:String = null;
         var box:Bitmap = null;
         var newValue:Boolean = false;
         try
         {
            row = e.currentTarget as Sprite;
            if(row == null || _controller == null)
            {
               return;
            }
            key = _keyByRow[row] as String;
            box = _boxByRow[row] as Bitmap;
            newValue = !(_controller.GetBobbaToggle(key) == true);
            _controller.SetBobbaToggle(key,newValue);
            if(box != null)
            {
               box.bitmapData = newValue ? _checkOn : _checkOff;
            }
         }
         catch(errClick:Error)
         {
         }
      }
      
      private function onAssetError(evt:Event) : void
      {
      }
   }
}
