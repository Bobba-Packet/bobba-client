package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.utils.FontEnum;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   
   public class BobbaPresetsView extends Sprite
   {
      
      public static const VIEW_W:int = 420;
      
      public static const VIEW_H:int = 448;
      
      private static const FONT_REGULAR:String = "Ubuntu";
      
      private static const FONT_BOLD:String = "Ubuntu bold";
      
      private static const COLOR_GREEN:uint = 0x31A342;
      
      private static const COLOR_AMBER:uint = 0xC9A227;
      
      private static const COLOR_RED:uint = 0xC0392B;
      
      private static const COLOR_GREY:uint = 0x6E6E6E;
      
      private static const TAB_Y:int = 8;
      
      private static const TAB_H:int = 22;
      
      private static const LIST_X:int = 12;
      
      private static const LIST_Y:int = 38;
      
      private static const LIST_W:int = 240;
      
      private static const LIST_H:int = 220;
      
      private static const ROW_H:int = 22;
      
      private static const PREVIEW_X:int = 260;
      
      private static const PREVIEW_W:int = 148;
      
      private static const BTN_Y:int = 268;
      
      private static const READY_Y:int = 314;
      
      private static const LOG_Y:int = 338;
      
      private var _controller:BobbaPresetsController;
      
      private var _tab:int = 0;
      
      private var _listNames:Array;
      
      private var _selectedName:String = "";
      
      private var _listHolder:Sprite;
      
      private var _listScroll:int = 0;
      
      private var _previewTitle:TextField;
      
      private var _previewDim:TextField;
      
      private var _previewCounts:TextField;
      
      private var _previewReady:TextField;
      
      private var _logField:TextField;
      
      private var _placeholder:TextField;
      
      private var _dotRoom:Sprite;
      
      private var _dotInv:Sprite;
      
      private var _dotStack:Sprite;
      
      private var _dotRights:Sprite;
      
      private var _exportBtn:Sprite;
      
      private var _exportLabel:TextField;
      
      private var _folderBtn:Sprite;
      
      private var _checkBtn:Sprite;
      
      private var _importBtn:Sprite;
      
      private var _nameHolder:Sprite;
      
      private var _nameInput:TextField;
      
      private var _mode:int = 0;
      
      private var _settingsHolder:Sprite;
      
      private var _toggleBuilder:TextField;
      
      private var _toggleIncomplete:TextField;
      
      private var _toggleWired:TextField;
      
      private var _toggleBcWired:TextField;
      
      private var _stackInput:TextField;
      
      private var _placeLabel:TextField;
      
      private var _moveLabel:TextField;
      
      private var _postName:TextField;
      
      private var _postId:TextField;
      
      private var _postList:Sprite;
      
      private var _hudField:TextField;
      
      public function BobbaPresetsView(controller:BobbaPresetsController)
      {
         super();
         _controller = controller;
         _listNames = [];
         mouseEnabled = true;
         mouseChildren = true;
         graphics.beginFill(0x000000,1);
         graphics.drawRect(0,0,VIEW_W,VIEW_H);
         graphics.endFill();
         buildTabs();
         buildLibraryChrome();
         try
         {
            buildSettings();
         }
         catch(setErr:Error)
         {
            Logger.log("[BobbaPresets] settings ui failed",setErr.message);
         }
         buildButtons();
         buildNameRow();
         buildReady();
         buildLog();
         buildHud();
         showTab(0);
         addEventListener(MouseEvent.MOUSE_WHEEL,onListWheel);
      }
      
      public function dispose() : void
      {
         removeEventListener(MouseEvent.MOUSE_WHEEL,onListWheel);
         if(_listHolder != null)
         {
            _listHolder.scrollRect = null;
         }
         while(numChildren > 0)
         {
            removeChildAt(0);
         }
         _controller = null;
         _listNames = null;
         _listHolder = null;
         _previewTitle = null;
         _previewDim = null;
         _previewCounts = null;
         _previewReady = null;
         _logField = null;
         _placeholder = null;
         _dotRoom = null;
         _dotInv = null;
         _dotStack = null;
         _dotRights = null;
         _exportBtn = null;
         _exportLabel = null;
         _folderBtn = null;
         _checkBtn = null;
         _importBtn = null;
         _nameHolder = null;
         _nameInput = null;
         _settingsHolder = null;
         _toggleBuilder = null;
         _toggleIncomplete = null;
         _toggleWired = null;
         _toggleBcWired = null;
         _stackInput = null;
         _placeLabel = null;
         _moveLabel = null;
         _postName = null;
         _postId = null;
         _postList = null;
         _hudField = null;
      }
      
      public function setList(names:Array, selected:String) : void
      {
         _listNames = names != null ? names : [];
         _selectedName = selected != null ? selected : "";
         redrawList();
      }
      
      public function setPreview(name:String, cfg:BobbaPresetConfig) : void
      {
         var n:String = name != null && name.length > 0 ? name : "—";
         _previewTitle.text = n;
         if(cfg == null)
         {
            _previewDim.text = "";
            _previewCounts.text = "";
            _previewReady.text = BobbaI18n.t("presets.preview.notReady","Not ready");
            fitPreviewText();
            return;
         }
         _previewDim.text = BobbaI18n.format("presets.preview.dim",cfg.dimX(),cfg.dimY());
         _previewCounts.text = BobbaI18n.format("presets.preview.counts",cfg.furniCount(),cfg.wiredCount());
         _previewReady.text = BobbaI18n.t("presets.preview.ready","Ready to import");
         fitPreviewText();
      }
      
      public function setReady(room:Boolean, invState:int, stack:Boolean, rights:Boolean) : void
      {
         paintDot(_dotRoom,room ? COLOR_GREEN : COLOR_RED);
         if(invState == BobbaAvailability.STATE_READY)
         {
            paintDot(_dotInv,COLOR_GREEN);
         }
         else if(invState == BobbaAvailability.STATE_LOADING)
         {
            paintDot(_dotInv,COLOR_AMBER);
         }
         else
         {
            paintDot(_dotInv,COLOR_RED);
         }
         paintDot(_dotStack,stack ? COLOR_GREEN : (room ? COLOR_RED : COLOR_GREY));
         paintDot(_dotRights,rights ? COLOR_GREEN : (room ? COLOR_RED : COLOR_GREY));
      }
      
      public function setImportEnabled(on:Boolean) : void
      {
         if(_importBtn == null)
         {
            return;
         }
         _importBtn.alpha = on ? 1 : 0.45;
      }
      
      public function setSettings(data:Object) : void
      {
         var posts:Array = null;
         var i:int = 0;
         var row:Object = null;
         var line:Sprite = null;
         var tf:TextField = null;
         if(_toggleBuilder == null)
         {
            return;
         }
         _toggleBuilder.text = mark(data != null && data.builder == true) + " " + BobbaI18n.t("presets.settings.builder","Enable builder import");
         _toggleIncomplete.text = mark(data != null && data.incomplete == true) + " " + BobbaI18n.t("presets.settings.allowIncomplete","Allow incomplete builds");
         _toggleWired.text = mark(data == null || data.wired != false) + " " + BobbaI18n.t("presets.settings.includeWired","Include wired");
         _toggleBcWired.text = mark(data != null && data.bcWired == true) + " " + BobbaI18n.t("presets.settings.bcWired","Use Builders Club furniture");
         fitText(_toggleBuilder);
         fitText(_toggleIncomplete);
         fitText(_toggleWired);
         fitText(_toggleBcWired);
         if(_stackInput != null && stage != null && stage.focus != _stackInput)
         {
            _stackInput.text = data != null && data.stack != null ? String(data.stack) : BobbaPresetsSettings.DEFAULT_STACK;
         }
         if(_placeLabel != null)
         {
            _placeLabel.text = BobbaI18n.format("presets.settings.placeMs",data != null ? int(data.placeMs) : BobbaPresetsSettings.DEFAULT_PLACE_MS);
            fitText(_placeLabel);
         }
         if(_moveLabel != null)
         {
            _moveLabel.text = BobbaI18n.format("presets.settings.moveMs",data != null ? int(data.moveMs) : BobbaPresetsSettings.DEFAULT_MOVE_MS);
            fitText(_moveLabel);
         }
         if(_postList == null)
         {
            return;
         }
         while(_postList.numChildren > 0)
         {
            _postList.removeChildAt(0);
         }
         posts = data != null ? data.posts as Array : null;
         if(posts == null)
         {
            posts = [];
         }
         for(i = 0; i < posts.length && i < 4; i++)
         {
            row = posts[i] as Object;
            if(row != null)
            {
               line = new Sprite();
               line.y = i * 18;
               line.buttonMode = true;
               line.useHandCursor = true;
               line.mouseChildren = false;
               line.name = String(row.name);
               tf = createText(String(row.name) + " -> " + int(row.id) + "  [x]",10,0xD8D4D3,false,380);
               line.addChild(tf);
               line.addEventListener(MouseEvent.CLICK,onPostRemove);
               _postList.addChild(line);
            }
         }
      }
      
      public function setLog(lines:Array) : void
      {
         var text:String = "";
         var i:int = 0;
         if(lines != null)
         {
            for(i = 0; i < lines.length; i++)
            {
               if(i > 0)
               {
                  text += "\n";
               }
               text += String(lines[i]);
            }
         }
         _logField.text = text;
      }
      
      public function setHud(label:String, current:int, total:int) : void
      {
         if(_hudField == null)
         {
            return;
         }
         if(total <= 0 || label == null || label.length == 0)
         {
            _hudField.visible = false;
            _hudField.text = "";
            return;
         }
         _hudField.visible = true;
         _hudField.text = label + "  " + current + "/" + total;
         fitText(_hudField);
      }
      
      public function setMode(mode:int, rect:Object) : void
      {
         var picking:Boolean = mode == BobbaPresetsController.MODE_PICK || mode == BobbaPresetsController.MODE_ROOT;
         var naming:Boolean = mode == BobbaPresetsController.MODE_NAME;
         var running:Boolean = mode == BobbaPresetsController.MODE_RUN;
         _mode = mode;
         if(_exportLabel != null)
         {
            _exportLabel.text = picking || naming || running ? BobbaI18n.t("presets.action.abort","Abort") : BobbaI18n.t("presets.action.exportSelection","Export selection");
            fitText(_exportLabel);
         }
         if(_exportBtn != null)
         {
            _exportBtn.visible = !naming;
         }
         if(_folderBtn != null)
         {
            _folderBtn.visible = !naming && !running;
            _checkBtn.visible = !naming && !running;
            _importBtn.visible = !naming && !running;
         }
         if(_settingsHolder != null && naming)
         {
            _settingsHolder.visible = false;
         }
         if(_nameHolder != null)
         {
            _nameHolder.visible = naming;
            if(naming && _nameInput != null)
            {
               _nameInput.text = "";
               if(_nameInput.stage != null)
               {
                  _nameInput.stage.focus = _nameInput;
               }
            }
         }
      }
      
      private function buildTabs() : void
      {
         addTab(0,BobbaI18n.t("presets.tab.library","Library"),12);
         addTab(3,BobbaI18n.t("presets.tab.settings","Settings"),90);
      }
      
      private function addTab(id:int, label:String, x:int) : void
      {
         var tab:Sprite = new Sprite();
         tab.x = x;
         tab.y = TAB_Y;
         tab.buttonMode = true;
         tab.useHandCursor = true;
         tab.mouseChildren = false;
         drawTab(tab,label,id == _tab);
         tab.addEventListener(MouseEvent.CLICK,onTabClick);
         tab.name = "tab_" + id;
         addChild(tab);
      }
      
      private function drawTab(tab:Sprite, label:String, active:Boolean) : void
      {
         var tf:TextField = null;
         tab.graphics.clear();
         while(tab.numChildren > 0)
         {
            tab.removeChildAt(0);
         }
         tab.graphics.beginFill(active ? 0x2A2A2A : 0x141414,1);
         tab.graphics.lineStyle(1,active ? 0x31A342 : 0x333333,1);
         tab.graphics.drawRect(0,0,72,TAB_H);
         tab.graphics.endFill();
         tf = createText(label,11,0xFFFFFF,active,72);
         tf.y = 3;
         tab.addChild(tf);
      }
      
      private function onTabClick(e:MouseEvent) : void
      {
         var tab:Sprite = e.currentTarget as Sprite;
         var id:int = 0;
         if(tab == null)
         {
            return;
         }
         id = int(tab.name.split("_")[1]);
         showTab(id);
      }
      
      private function showTab(id:int) : void
      {
         var i:int = 0;
         var child:Sprite = null;
         var label:String = "";
         _tab = id;
         for(i = 0; i < numChildren; i++)
         {
            child = getChildAt(i) as Sprite;
            if(child != null && child.name != null && child.name.indexOf("tab_") == 0)
            {
               if(child.name == "tab_0")
               {
                  label = BobbaI18n.t("presets.tab.library","Library");
               }
               else
               {
                  label = BobbaI18n.t("presets.tab.settings","Settings");
               }
               drawTab(child,label,child.name == "tab_" + id);
            }
         }
         if(_listHolder != null)
         {
            _listHolder.visible = id == 0;
         }
         if(_previewTitle != null)
         {
            _previewTitle.visible = id == 0;
            _previewDim.visible = id == 0;
            _previewCounts.visible = id == 0;
            _previewReady.visible = id == 0;
         }
         if(_placeholder != null)
         {
            _placeholder.visible = false;
         }
         if(_settingsHolder != null)
         {
            _settingsHolder.visible = id == 3;
         }
      }
      
      private function buildLibraryChrome() : void
      {
         graphics.lineStyle(1,0x333333,1);
         graphics.drawRect(LIST_X,LIST_Y,LIST_W,LIST_H);
         graphics.drawRect(PREVIEW_X,LIST_Y,PREVIEW_W,LIST_H);
         _listHolder = new Sprite();
         _listHolder.x = LIST_X;
         _listHolder.y = LIST_Y;
         _listHolder.mouseEnabled = true;
         _listHolder.mouseChildren = true;
         addChild(_listHolder);
         _previewTitle = createText("—",13,0xFFFFFF,true,PREVIEW_W - 12);
         _previewTitle.x = PREVIEW_X + 6;
         _previewTitle.y = LIST_Y + 8;
         addChild(_previewTitle);
         _previewDim = createText("",11,0xD8D4D3,false,PREVIEW_W - 12);
         _previewDim.x = PREVIEW_X + 6;
         _previewDim.y = LIST_Y + 32;
         addChild(_previewDim);
         _previewCounts = createText("",11,0xD8D4D3,false,PREVIEW_W - 12);
         _previewCounts.x = PREVIEW_X + 6;
         _previewCounts.y = LIST_Y + 50;
         addChild(_previewCounts);
         _previewReady = createText("",11,0x6E6E6E,false,PREVIEW_W - 12);
         _previewReady.x = PREVIEW_X + 6;
         _previewReady.y = LIST_Y + 72;
         addChild(_previewReady);
         _placeholder = createText("",12,0xD8D4D3,false,VIEW_W - 24);
         _placeholder.x = 12;
         _placeholder.y = LIST_Y + 8;
         _placeholder.visible = false;
         addChild(_placeholder);
      }
      
      private function redrawList() : void
      {
         var i:int = 0;
         var name:String = null;
         var row:Sprite = null;
         var tf:TextField = null;
         var selected:Boolean = false;
         if(_listHolder == null)
         {
            return;
         }
         while(_listHolder.numChildren > 0)
         {
            _listHolder.removeChildAt(0);
         }
         _listHolder.graphics.clear();
         _listHolder.graphics.beginFill(0x000000,1);
         _listHolder.graphics.drawRect(0,0,LIST_W,Math.max(LIST_H,_listNames.length * ROW_H));
         _listHolder.graphics.endFill();
         for(i = 0; i < _listNames.length; i++)
         {
            name = String(_listNames[i]);
            selected = name == _selectedName;
            row = new Sprite();
            row.y = i * ROW_H;
            row.graphics.beginFill(selected ? 0x2A2A2A : 0x000000,1);
            row.graphics.drawRect(0,0,LIST_W,ROW_H);
            row.graphics.endFill();
            tf = createText(name,12,0xFFFFFF,selected,LIST_W - 8);
            tf.x = 6;
            tf.y = 3;
            row.addChild(tf);
            row.buttonMode = true;
            row.useHandCursor = true;
            row.mouseChildren = false;
            row.name = name;
            row.addEventListener(MouseEvent.CLICK,onListClick);
            _listHolder.addChild(row);
         }
         applyListScroll();
      }
      
      private function applyListScroll() : void
      {
         var max:int = 0;
         if(_listHolder == null)
         {
            return;
         }
         max = _listNames != null ? _listNames.length * ROW_H - LIST_H : 0;
         if(max < 0)
         {
            max = 0;
         }
         if(_listScroll > max)
         {
            _listScroll = max;
         }
         if(_listScroll < 0)
         {
            _listScroll = 0;
         }
         _listHolder.scrollRect = new Rectangle(0,_listScroll,LIST_W,LIST_H);
      }
      
      private function onListWheel(e:MouseEvent) : void
      {
         if(e == null || _tab != 0 || _listHolder == null || _listHolder.visible != true)
         {
            return;
         }
         if(mouseX < LIST_X || mouseX > LIST_X + LIST_W || mouseY < LIST_Y || mouseY > LIST_Y + LIST_H)
         {
            return;
         }
         _listScroll -= e.delta * ROW_H;
         applyListScroll();
      }
      
      private function onListClick(e:MouseEvent) : void
      {
         var row:Sprite = e.currentTarget as Sprite;
         if(row == null || _controller == null)
         {
            return;
         }
         _controller.selectPreset(row.name);
      }
      
      private function buildButtons() : void
      {
         _exportBtn = addBtn(BobbaI18n.t("presets.action.exportSelection","Export selection"),12,BTN_Y,onExport);
         _exportLabel = _exportBtn.getChildAt(0) as TextField;
         _folderBtn = addBtn(BobbaI18n.t("presets.action.openFolder","Open folder"),216,BTN_Y,onFolder);
         _checkBtn = addBtn(BobbaI18n.t("presets.action.checkItems","Check items"),12,BTN_Y + 24,onCheck);
         _importBtn = addBtn(BobbaI18n.t("presets.action.importHere","Import here"),216,BTN_Y + 24,onImport);
      }
      
      private function buildNameRow() : void
      {
         var saveBtn:Sprite = null;
         var hint:TextField = null;
         var tf:TextField = null;
         _nameHolder = new Sprite();
         _nameHolder.x = 12;
         _nameHolder.y = BTN_Y;
         _nameHolder.visible = false;
         hint = createText(BobbaI18n.t("presets.overlay.name","Name this preset"),11,0xD8D4D3,false,396);
         hint.y = -16;
         _nameHolder.addChild(hint);
         _nameInput = createText("",12,0xFFFFFF,false,276);
         _nameInput.mouseEnabled = true;
         _nameInput.selectable = true;
         _nameInput.type = "input";
         _nameInput.border = true;
         _nameInput.borderColor = 0x444444;
         _nameInput.background = true;
         _nameInput.backgroundColor = 0x1A1A1A;
         _nameInput.maxChars = 32;
         _nameInput.height = 22;
         _nameInput.addEventListener(KeyboardEvent.KEY_DOWN,onNameKey);
         _nameHolder.addChild(_nameInput);
         saveBtn = new Sprite();
         saveBtn.x = 288;
         saveBtn.y = 0;
         saveBtn.buttonMode = true;
         saveBtn.useHandCursor = true;
         saveBtn.mouseChildren = false;
         saveBtn.graphics.beginFill(0x1A1A1A,1);
         saveBtn.graphics.lineStyle(1,0x444444,1);
         saveBtn.graphics.drawRect(0,0,108,22);
         saveBtn.graphics.endFill();
         tf = createText(BobbaI18n.t("presets.action.save","Save"),11,0xFFFFFF,false,108);
         tf.y = 3;
         saveBtn.addChild(tf);
         saveBtn.addEventListener(MouseEvent.CLICK,onNameSave);
         _nameHolder.addChild(saveBtn);
         saveBtn = new Sprite();
         saveBtn.x = 0;
         saveBtn.y = 24;
         saveBtn.buttonMode = true;
         saveBtn.useHandCursor = true;
         saveBtn.mouseChildren = false;
         saveBtn.graphics.beginFill(0x1A1A1A,1);
         saveBtn.graphics.lineStyle(1,0x444444,1);
         saveBtn.graphics.drawRect(0,0,192,22);
         saveBtn.graphics.endFill();
         tf = createText(BobbaI18n.t("presets.action.abort","Abort"),11,0xFFFFFF,false,192);
         tf.y = 3;
         saveBtn.addChild(tf);
         saveBtn.addEventListener(MouseEvent.CLICK,onNameAbort);
         _nameHolder.addChild(saveBtn);
         addChild(_nameHolder);
      }
      
      private function addBtn(label:String, x:int, y:int, handler:Function) : Sprite
      {
         var btn:Sprite = new Sprite();
         btn.x = x;
         btn.y = y;
         btn.buttonMode = true;
         btn.useHandCursor = true;
         btn.mouseChildren = false;
         btn.graphics.beginFill(0x1A1A1A,1);
         btn.graphics.lineStyle(1,0x444444,1);
         btn.graphics.drawRect(0,0,192,22);
         btn.graphics.endFill();
         var tf:TextField = createText(label,11,0xFFFFFF,false,192);
         tf.y = 3;
         btn.addChild(tf);
         btn.addEventListener(MouseEvent.CLICK,handler);
         addChild(btn);
         return btn;
      }
      
      private function onExport(e:MouseEvent) : void
      {
         if(_controller == null)
         {
            return;
         }
         if(_mode == BobbaPresetsController.MODE_PICK || _mode == BobbaPresetsController.MODE_NAME || _mode == BobbaPresetsController.MODE_ROOT || _mode == BobbaPresetsController.MODE_RUN)
         {
            _controller.abort();
            return;
         }
         _controller.startExportSelection();
      }
      
      private function onNameSave(e:MouseEvent) : void
      {
         submitName();
      }
      
      private function onNameAbort(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.abort();
         }
      }
      
      private function onNameKey(e:KeyboardEvent) : void
      {
         if(e != null && e.keyCode == Keyboard.ENTER)
         {
            submitName();
         }
      }
      
      private function submitName() : void
      {
         if(_controller == null || _nameInput == null)
         {
            return;
         }
         _controller.confirmName(_nameInput.text);
      }
      
      private function onFolder(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.openFolder();
         }
      }
      
      private function onCheck(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.checkItems();
         }
      }
      
      private function onImport(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.startImport();
         }
      }
      
      private function buildReady() : void
      {
         _dotRoom = addReady(12,READY_Y,BobbaI18n.t("presets.ready.room","Room"));
         _dotInv = addReady(110,READY_Y,BobbaI18n.t("presets.ready.inventory","Inventory"));
         _dotStack = addReady(220,READY_Y,BobbaI18n.t("presets.ready.stackTile","Stack tile"));
         _dotRights = addReady(330,READY_Y,BobbaI18n.t("presets.ready.rights","Rights"));
      }
      
      private function addReady(x:int, y:int, label:String) : Sprite
      {
         var wrap:Sprite = new Sprite();
         wrap.x = x;
         wrap.y = y;
         wrap.mouseEnabled = false;
         var dot:Sprite = new Sprite();
         dot.y = 4;
         wrap.addChild(dot);
         var tf:TextField = createText(label,10,0xD8D4D3,false,80);
         tf.x = 12;
         wrap.addChild(tf);
         addChild(wrap);
         paintDot(dot,COLOR_GREY);
         return dot;
      }
      
      private function paintDot(dot:Sprite, color:uint) : void
      {
         if(dot == null)
         {
            return;
         }
         dot.graphics.clear();
         dot.graphics.beginFill(color,1);
         dot.graphics.drawCircle(3,3,3);
         dot.graphics.endFill();
      }
      
      private function buildLog() : void
      {
         graphics.lineStyle(1,0x333333,1);
         graphics.drawRect(12,LOG_Y,396,96);
         _logField = createText("",10,0xD8D4D3,false,384);
         _logField.x = 18;
         _logField.y = LOG_Y + 22;
         _logField.height = 68;
         _logField.multiline = true;
         _logField.wordWrap = true;
         addChild(_logField);
      }
      
      private function buildHud() : void
      {
         _hudField = createText("",11,0x31A342,true,384);
         _hudField.x = 18;
         _hudField.y = LOG_Y + 4;
         _hudField.visible = false;
         addChild(_hudField);
      }
      
      private function buildSettings() : void
      {
         var y:int = 4;
         var addBtn:Sprite = null;
         var minusP:Sprite = null;
         var plusP:Sprite = null;
         var minusM:Sprite = null;
         var plusM:Sprite = null;
         var stackLbl:TextField = null;
         var postLbl:TextField = null;
         _settingsHolder = new Sprite();
         _settingsHolder.x = LIST_X;
         _settingsHolder.y = LIST_Y;
         _settingsHolder.visible = false;
         _settingsHolder.graphics.beginFill(0x000000,1);
         _settingsHolder.graphics.drawRect(0,0,396,LIST_H);
         _settingsHolder.graphics.endFill();
         _toggleBuilder = createText("",11,0xFFFFFF,false,380);
         _toggleBuilder.y = y;
         _toggleBuilder.mouseEnabled = true;
         _toggleBuilder.addEventListener(MouseEvent.CLICK,onToggleBuilder);
         _settingsHolder.addChild(_toggleBuilder);
         y += 20;
         _toggleIncomplete = createText("",11,0xFFFFFF,false,380);
         _toggleIncomplete.y = y;
         _toggleIncomplete.mouseEnabled = true;
         _toggleIncomplete.addEventListener(MouseEvent.CLICK,onToggleIncomplete);
         _settingsHolder.addChild(_toggleIncomplete);
         y += 20;
         _toggleWired = createText("",11,0xFFFFFF,false,380);
         _toggleWired.y = y;
         _toggleWired.mouseEnabled = true;
         _toggleWired.addEventListener(MouseEvent.CLICK,onToggleWired);
         _settingsHolder.addChild(_toggleWired);
         y += 20;
         _toggleBcWired = createText("",11,0xFFFFFF,false,380);
         _toggleBcWired.y = y;
         _toggleBcWired.mouseEnabled = true;
         _toggleBcWired.addEventListener(MouseEvent.CLICK,onToggleBcWired);
         _settingsHolder.addChild(_toggleBcWired);
         y += 22;
         stackLbl = createText(BobbaI18n.t("presets.settings.stackClass","Stack tile class"),10,0xD8D4D3,false,140);
         stackLbl.y = y + 2;
         _settingsHolder.addChild(stackLbl);
         _stackInput = createText(BobbaPresetsSettings.DEFAULT_STACK,11,0xFFFFFF,false,240);
         _stackInput.x = 148;
         _stackInput.y = y;
         _stackInput.mouseEnabled = true;
         _stackInput.selectable = true;
         _stackInput.type = "input";
         _stackInput.border = true;
         _stackInput.borderColor = 0x444444;
         _stackInput.background = true;
         _stackInput.backgroundColor = 0x1A1A1A;
         _stackInput.addEventListener(KeyboardEvent.KEY_DOWN,onStackKey);
         _stackInput.addEventListener("focusOut",onStackBlur);
         _settingsHolder.addChild(_stackInput);
         y += 24;
         _placeLabel = createText("",11,0xFFFFFF,false,160);
         _placeLabel.y = y + 2;
         _settingsHolder.addChild(_placeLabel);
         minusP = stepperBtn("-",168,y,onPlaceMinus);
         plusP = stepperBtn("+",196,y,onPlacePlus);
         _settingsHolder.addChild(minusP);
         _settingsHolder.addChild(plusP);
         _moveLabel = createText("",11,0xFFFFFF,false,160);
         _moveLabel.x = 232;
         _moveLabel.y = y + 2;
         _settingsHolder.addChild(_moveLabel);
         minusM = stepperBtn("-",360,y,onMoveMinus);
         plusM = stepperBtn("+",384,y,onMovePlus);
         _settingsHolder.addChild(minusM);
         _settingsHolder.addChild(plusM);
         y += 24;
         postLbl = createText(BobbaI18n.t("presets.settings.post","Use existing furni (name + room id)"),10,0xD8D4D3,false,380);
         postLbl.y = y;
         _settingsHolder.addChild(postLbl);
         y += 16;
         _postName = createText("",11,0xFFFFFF,false,180);
         _postName.y = y;
         _postName.mouseEnabled = true;
         _postName.selectable = true;
         _postName.type = "input";
         _postName.border = true;
         _postName.borderColor = 0x444444;
         _postName.background = true;
         _postName.backgroundColor = 0x1A1A1A;
         _settingsHolder.addChild(_postName);
         _postId = createText("",11,0xFFFFFF,false,70);
         _postId.x = 188;
         _postId.y = y;
         _postId.mouseEnabled = true;
         _postId.selectable = true;
         _postId.type = "input";
         _postId.border = true;
         _postId.borderColor = 0x444444;
         _postId.background = true;
         _postId.backgroundColor = 0x1A1A1A;
         _settingsHolder.addChild(_postId);
         addBtn = stepperBtn(BobbaI18n.t("presets.action.add","Add"),266,y,onPostAdd);
         _settingsHolder.addChild(addBtn);
         y += 24;
         _postList = new Sprite();
         _postList.y = y;
         _settingsHolder.addChild(_postList);
         addChild(_settingsHolder);
      }
      
      private function stepperBtn(label:String, x:int, y:int, handler:Function) : Sprite
      {
         var btn:Sprite = new Sprite();
         var tf:TextField = null;
         btn.x = x;
         btn.y = y;
         btn.buttonMode = true;
         btn.useHandCursor = true;
         btn.mouseChildren = false;
         btn.graphics.beginFill(0x1A1A1A,1);
         btn.graphics.lineStyle(1,0x444444,1);
         btn.graphics.drawRect(0,0,label.length > 1 ? 80 : 24,20);
         btn.graphics.endFill();
         tf = createText(label,11,0xFFFFFF,false,label.length > 1 ? 80 : 24);
         tf.y = 2;
         btn.addChild(tf);
         btn.addEventListener(MouseEvent.CLICK,handler);
         return btn;
      }
      
      private function mark(on:Boolean) : String
      {
         return on ? "[x]" : "[ ]";
      }
      
      private function onToggleBuilder(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.toggleSetting("builder");
         }
      }
      
      private function onToggleIncomplete(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.toggleSetting("incomplete");
         }
      }
      
      private function onToggleWired(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.toggleSetting("wired");
         }
      }
      
      private function onToggleBcWired(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.toggleSetting("bcWired");
         }
      }
      
      private function onPlaceMinus(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.nudgePlace(-10);
         }
      }
      
      private function onPlacePlus(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.nudgePlace(10);
         }
      }
      
      private function onMoveMinus(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.nudgeMove(-10);
         }
      }
      
      private function onMovePlus(e:MouseEvent) : void
      {
         if(_controller != null)
         {
            _controller.nudgeMove(10);
         }
      }
      
      private function onStackKey(e:KeyboardEvent) : void
      {
         if(e != null && e.keyCode == Keyboard.ENTER)
         {
            commitStack();
         }
      }
      
      private function onStackBlur(e:*) : void
      {
         commitStack();
      }
      
      private function commitStack() : void
      {
         if(_controller != null && _stackInput != null)
         {
            _controller.setStackClass(_stackInput.text);
         }
      }
      
      private function onPostAdd(e:MouseEvent) : void
      {
         if(_controller != null && _postName != null && _postId != null)
         {
            _controller.addPost(_postName.text,_postId.text);
            _postName.text = "";
            _postId.text = "";
         }
      }
      
      private function onPostRemove(e:MouseEvent) : void
      {
         var line:Sprite = e != null ? e.currentTarget as Sprite : null;
         if(_controller != null && line != null)
         {
            _controller.removePost(line.name);
         }
      }
      
      private function createText(textValue:String, size:int, color:uint, bold:Boolean, width:Number) : TextField
      {
         var field:TextField = new TextField();
         field.selectable = false;
         field.multiline = false;
         field.wordWrap = false;
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
         field.text = textValue != null && textValue.length > 0 ? textValue : "Ag";
         field.height = int(field.textHeight + 8);
         if(field.height < size + 10)
         {
            field.height = size + 10;
         }
         field.text = textValue != null ? textValue : "";
         return field;
      }
      
      private function fitPreviewText() : void
      {
         fitText(_previewTitle);
         fitText(_previewDim);
         fitText(_previewCounts);
         fitText(_previewReady);
      }
      
      private function fitText(field:TextField) : void
      {
         var h:int = 0;
         if(field == null)
         {
            return;
         }
         h = int(field.textHeight + 8);
         if(h < 16)
         {
            h = 16;
         }
         field.height = h;
      }
   }
}
