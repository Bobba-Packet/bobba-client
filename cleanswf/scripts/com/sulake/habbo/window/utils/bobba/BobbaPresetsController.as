package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   
   public class BobbaPresetsController
   {
      
      public static const MODE_IDLE:int = 0;
      
      public static const MODE_PICK:int = 1;
      
      public static const MODE_NAME:int = 2;
      
      public static const MODE_ROOT:int = 3;
      
      public static const MODE_RUN:int = 4;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _view:BobbaPresetsView;
      
      private var _picker:BobbaTilePicker;
      
      private var _selectedName:String;
      
      private var _selectedConfig:BobbaPresetConfig;
      
      private var _logLines:Array;
      
      private var _mode:int;
      
      private var _pendingRect:Object;
      
      private var _host:BobbaPresetsEditor;
      
      private var _pendingCheck:Boolean;
      
      private var _pendingName:String;
      
      private var _importer:BobbaPresetImporter;
      
      private var _fetcher:BobbaWiredFetch;
      
      public function BobbaPresetsController(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _picker = new BobbaTilePicker(windowManager);
         _importer = null;
         _fetcher = null;
         _selectedName = "";
         _pendingName = "";
         _selectedConfig = null;
         _logLines = [];
         _mode = MODE_IDLE;
         _pendingRect = null;
         _pendingCheck = false;
      }
      
      public function get windowManager() : HabboWindowManagerComponent
      {
         return _windowManager;
      }
      
      public function get selectedName() : String
      {
         return _selectedName;
      }
      
      public function get selectedConfig() : BobbaPresetConfig
      {
         return _selectedConfig;
      }
      
      public function get mode() : int
      {
         return _mode;
      }
      
      public function attachView(view:BobbaPresetsView) : void
      {
         _view = view;
         refresh();
      }
      
      public function attachHost(host:BobbaPresetsEditor) : void
      {
         _host = host;
      }
      
      public function dispose() : void
      {
         if(_fetcher != null)
         {
            _fetcher.dispose();
            _fetcher = null;
         }
         abortSilent();
         if(_importer != null)
         {
            _importer.dispose();
            _importer = null;
         }
         if(_picker != null)
         {
            _picker.dispose();
            _picker = null;
         }
         _view = null;
         _host = null;
         _windowManager = null;
         _selectedConfig = null;
         _logLines = null;
         _pendingRect = null;
      }
      
      public function refresh() : void
      {
         if(_view == null)
         {
            return;
         }
         _view.setList(BobbaPresetStore.listNames(),_selectedName);
         _view.setPreview(_selectedName,_selectedConfig);
         _view.setReady(BobbaRoomSnapshot.inRoom(_windowManager),BobbaAvailability.state(_windowManager),BobbaRoomSnapshot.inRoom(_windowManager) && BobbaRoomSnapshot.hasStackTile(_windowManager,BobbaPresetsSettings.stackClass),BobbaRoomSnapshot.hasRights(_windowManager));
         _view.setLog(_logLines);
         _view.setMode(_mode,_pendingRect);
         _view.setSettings(settingsSnapshot());
         _view.setImportEnabled(BobbaPresetsSettings.builderEnabled && _mode == MODE_IDLE);
      }
      
      public function selectPreset(name:String) : void
      {
         if(_mode != MODE_IDLE)
         {
            logLine(BobbaI18n.t("presets.log.busy","Finish or abort first"));
            refresh();
            return;
         }
         _selectedName = name != null ? name : "";
         _selectedConfig = null;
         if(_selectedName.length > 0)
         {
            _selectedConfig = BobbaPresetStore.load(_selectedName);
            if(_selectedConfig == null)
            {
               logLine(BobbaI18n.t("presets.log.noPreset","Could not load preset"));
            }
         }
         refresh();
      }
      
      public function startExportSelection() : void
      {
         var stage:* = undefined;
         if(_mode != MODE_IDLE)
         {
            logLine(BobbaI18n.t("presets.log.busy","Finish or abort first"));
            refresh();
            return;
         }
         if(!BobbaRoomSnapshot.inRoom(_windowManager))
         {
            logLine(BobbaI18n.t("presets.log.noRoom","Enter a room first"));
            refresh();
            return;
         }
         stage = _view != null ? _view.stage : null;
         if(_picker == null || !_picker.startRect(onRectPicked,onPickAborted,stage))
         {
            logLine(BobbaI18n.t("presets.log.pickFailed","Could not start tile picker"));
            refresh();
            return;
         }
         _mode = MODE_PICK;
         logLine(BobbaI18n.t("presets.overlay.corner1","Click and drag on the room. Esc cancels."));
         setHostVisible(false);
         refresh();
      }
      
      public function startExportAll() : void
      {
         var items:Array = null;
         var box:Object = null;
         if(_mode != MODE_IDLE)
         {
            logLine(BobbaI18n.t("presets.log.busy","Finish or abort first"));
            refresh();
            return;
         }
         if(!BobbaRoomSnapshot.inRoom(_windowManager))
         {
            logLine(BobbaI18n.t("presets.log.noRoom","Enter a room first"));
            refresh();
            return;
         }
         items = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
         box = BobbaPresetExporter.boundsOf(items);
         if(box == null)
         {
            logLine(BobbaI18n.t("presets.log.emptyRect","No furniture in that rectangle"));
            refresh();
            return;
         }
         _pendingRect = box;
         _mode = MODE_NAME;
         logLine(BobbaI18n.t("presets.log.exportAll","Copying full room"));
         logLine(BobbaI18n.format("presets.overlay.corner2",int(box.x1) - int(box.x0) + 1,int(box.y1) - int(box.y0) + 1));
         logLine(BobbaI18n.t("presets.overlay.name","Name this preset"));
         refresh();
      }
      
      public function confirmName(name:String) : void
      {
         var items:Array = null;
         var missing:Array = null;
         if(_mode != MODE_NAME || _pendingRect == null)
         {
            return;
         }
         if(!BobbaPresetStore.validName(name) || name == "_debug")
         {
            logLine(BobbaI18n.t("presets.log.badName","Invalid name"));
            refresh();
            return;
         }
         if(!BobbaRoomSnapshot.inRoom(_windowManager))
         {
            logLine(BobbaI18n.t("presets.log.noRoom","Enter a room first"));
            abortSilent();
            refresh();
            return;
         }
         _pendingName = name;
         items = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
         if(BobbaPresetsSettings.exportWired)
         {
            missing = BobbaPresetExporter.missingWiredIds(items,int(_pendingRect.x0),int(_pendingRect.y0),int(_pendingRect.x1),int(_pendingRect.y1));
            if(missing != null && missing.length > 0)
            {
               _mode = MODE_RUN;
               logLine(BobbaI18n.format("presets.log.fetchWired",missing.length));
               refresh();
               if(_fetcher == null)
               {
                  _fetcher = new BobbaWiredFetch();
               }
               if(_fetcher.start(_windowManager,missing,onImportHud,onFetchDone))
               {
                  return;
               }
            }
         }
         maybeDiffsThenExport();
      }
      
      private function maybeDiffsThenExport() : void
      {
         var items:Array = null;
         if(BobbaPresetsSettings.exportWired && _pendingRect != null)
         {
            items = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
            if(BobbaPresetExporter.hasVariableRefs(items,int(_pendingRect.x0),int(_pendingRect.y0),int(_pendingRect.x1),int(_pendingRect.y1)))
            {
               _mode = MODE_RUN;
               if(_view != null)
               {
                  _view.setHud(BobbaI18n.t("presets.hud.vars","Reading variables"),0,1);
               }
               if(BobbaWiredCache.startDiffs(_windowManager,onDiffsDone))
               {
                  return;
               }
            }
         }
         finishExport();
      }
      
      private function onDiffsDone(ok:Boolean) : void
      {
         if(_view != null)
         {
            _view.setHud("",0,0);
         }
         finishExport();
      }
      
      private function finishExport() : void
      {
         var items:Array = null;
         var cfg:BobbaPresetConfig = null;
         var n:int = 0;
         var name:String = _pendingName;
         if(_pendingRect == null || name == null || name.length == 0)
         {
            abortSilent();
            refresh();
            return;
         }
         if(!BobbaRoomSnapshot.inRoom(_windowManager))
         {
            logLine(BobbaI18n.t("presets.log.noRoom","Enter a room first"));
            abortSilent();
            refresh();
            return;
         }
         items = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
         cfg = BobbaPresetExporter.exportRect(items,int(_pendingRect.x0),int(_pendingRect.y0),int(_pendingRect.x1),int(_pendingRect.y1),_windowManager);
         n = cfg != null ? int(cfg.furniCount()) : 0;
         if(n == 0)
         {
            logLine(BobbaI18n.t("presets.log.emptyRect","No furniture in that rectangle"));
            abortSilent();
            refresh();
            return;
         }
         if(!BobbaPresetStore.save(name,cfg))
         {
            logLine(BobbaI18n.t("presets.log.saveFailed","Save failed"));
            _mode = MODE_IDLE;
            _pendingRect = null;
            _pendingName = "";
            if(_view != null)
            {
               _view.setHud("",0,0);
            }
            refresh();
            return;
         }
         _selectedName = name;
         _selectedConfig = cfg;
         _mode = MODE_IDLE;
         _pendingRect = null;
         _pendingName = "";
         if(_view != null)
         {
            _view.setHud("",0,0);
         }
         logLine(BobbaI18n.format("presets.log.exported",name,n));
         if(BobbaPresetExporter.lastWiredCount > 0)
         {
            logLine(BobbaI18n.format("presets.log.wiredCached",BobbaPresetExporter.lastWiredCount));
         }
         if(BobbaPresetExporter.lastMissingWired > 0)
         {
            logLine(BobbaI18n.format("presets.log.wiredMissing",BobbaPresetExporter.lastMissingWired));
         }
         if(BobbaPresetExporter.lastBindingCount > 0)
         {
            logLine(BobbaI18n.format("presets.log.bindingsCached",BobbaPresetExporter.lastBindingCount));
         }
         if(BobbaPresetExporter.lastAdsCount > 0)
         {
            logLine(BobbaI18n.format("presets.log.adsCached",BobbaPresetExporter.lastAdsCount));
         }
         if(BobbaPresetExporter.lastBcCount > 0)
         {
            logLine(BobbaI18n.format("presets.log.bcMarked",BobbaPresetExporter.lastBcCount));
         }
         if(cfg != null && cfg.wired != null && cfg.wired.variables_map != null && countKeys(cfg.wired.variables_map) > 0)
         {
            logLine(BobbaI18n.format("presets.log.varsMapped",countKeys(cfg.wired.variables_map)));
         }
         refresh();
      }
      
      private function countKeys(o:Object) : int
      {
         var n:int = 0;
         var k:String = null;
         if(o == null)
         {
            return 0;
         }
         for(k in o)
         {
            n++;
         }
         return n;
      }
      
      private function onFetchDone(ok:Boolean) : void
      {
         if(_view != null)
         {
            _view.setHud("",0,0);
         }
         if(!ok)
         {
            abortSilent();
            logLine(BobbaI18n.t("presets.log.aborted","Aborted"));
            setHostVisible(true);
            refresh();
            return;
         }
         maybeDiffsThenExport();
      }
      
      public function abort() : void
      {
         if(_mode == MODE_IDLE)
         {
            return;
         }
         if(_fetcher != null && _fetcher.busy)
         {
            _fetcher.cancel();
            return;
         }
         if(_importer != null && _importer.busy)
         {
            _importer.cancel();
            return;
         }
         abortSilent();
         logLine(BobbaI18n.t("presets.log.aborted","Aborted"));
         setHostVisible(true);
         refresh();
      }
      
      public function dumpDebug() : void
      {
         startExportAll();
      }
      
      public function openFolder() : void
      {
         BobbaPresetStore.reveal();
         logLine(BobbaI18n.t("presets.log.folder","Opened presets folder"));
         refresh();
      }
      
      public function checkItems() : void
      {
         var st:int = 0;
         if(_selectedConfig == null || _selectedName == null || _selectedName.length == 0)
         {
            logLine(BobbaI18n.t("presets.log.noPreset","Select a preset first"));
            refresh();
            return;
         }
         _pendingCheck = true;
         st = BobbaAvailability.ensureLoaded(_windowManager,onInventoryReady);
         if(st == BobbaAvailability.STATE_LOADING)
         {
            logLine(BobbaI18n.t("presets.log.invLoading","Loading inventory..."));
            refresh();
            return;
         }
         if(st == BobbaAvailability.STATE_FAIL)
         {
            _pendingCheck = false;
            logLine(BobbaI18n.t("presets.log.invFailed","Could not read inventory"));
            refresh();
            return;
         }
         finishCheck();
      }
      
      public function startImport() : void
      {
         var stage:* = undefined;
         if(!prepareImport())
         {
            return;
         }
         stage = _view != null ? _view.stage : null;
         if(_picker == null || !_picker.startRoot(_selectedConfig,onRootTile,onPickAborted,stage))
         {
            logLine(BobbaI18n.t("presets.log.pickFailed","Could not start tile picker"));
            refresh();
            return;
         }
         _mode = MODE_ROOT;
         logLine(BobbaI18n.format("presets.overlay.root",_selectedConfig.dimX(),_selectedConfig.dimY()));
         setHostVisible(false);
         refresh();
      }
      
      public function startImportAt(x:int, y:int) : void
      {
         if(!prepareImport())
         {
            return;
         }
         beginImport(x,y);
      }
      
      private function prepareImport() : Boolean
      {
         var rows:Array = null;
         var missingN:int = 0;
         if(_mode != MODE_IDLE)
         {
            logLine(BobbaI18n.t("presets.log.busy","Finish or abort first"));
            refresh();
            return false;
         }
         if(!BobbaPresetsSettings.builderEnabled)
         {
            logLine(BobbaI18n.t("presets.log.builderOff","Enable builder import in Settings first"));
            refresh();
            return false;
         }
         if(_selectedConfig == null || _selectedName == null || _selectedName.length == 0)
         {
            logLine(BobbaI18n.t("presets.log.noPreset","Select a preset first"));
            refresh();
            return false;
         }
         if(!BobbaRoomSnapshot.inRoom(_windowManager))
         {
            logLine(BobbaI18n.t("presets.log.noRoom","Enter a room first"));
            refresh();
            return false;
         }
         if(!BobbaRoomSnapshot.hasRights(_windowManager))
         {
            logLine(BobbaI18n.t("presets.log.noRights","Need room rights"));
            refresh();
            return false;
         }
         if(!BobbaRoomSnapshot.hasStackTile(_windowManager,BobbaPresetsSettings.stackClass))
         {
            logLine(BobbaI18n.t("presets.log.noStackTile","Place a stack tile first"));
            refresh();
            return false;
         }
         BobbaAvailability.ensureLoaded(_windowManager,onInventoryReady);
         if(BobbaAvailability.isReady(_windowManager))
         {
            rows = BobbaAvailability.compare(_windowManager,_selectedConfig,BobbaPresetsSettings.postFor(_selectedName));
            missingN = BobbaAvailability.missingCount(rows);
            if(missingN > 0 && !BobbaPresetsSettings.allowIncomplete)
            {
               logLine(BobbaI18n.t("presets.log.missingItems","Missing furniture — check items"));
               refresh();
               return false;
            }
         }
         return true;
      }
      
      private function beginImport(rootX:int, rootY:int) : void
      {
         if(_importer == null)
         {
            _importer = new BobbaPresetImporter();
         }
         _mode = MODE_RUN;
         setHostVisible(true);
         logLine(BobbaI18n.format("presets.log.importing",_selectedName,rootX,rootY));
         refresh();
         if(!_importer.start(_windowManager,_selectedConfig,_selectedName,rootX,rootY,onImportLog,onImportHud,onImportDone))
         {
            _mode = MODE_IDLE;
            refresh();
         }
      }
      
      private function onRootTile(x:int, y:int) : void
      {
         beginImport(x,y);
      }
      
      private function onImportLog(text:String) : void
      {
         logLine(text);
         refresh();
      }
      
      private function onImportHud(label:String, current:int, total:int) : void
      {
         if(_view != null)
         {
            _view.setHud(label,current,total);
         }
      }
      
      private function onImportDone(ok:Boolean) : void
      {
         _mode = MODE_IDLE;
         if(ok)
         {
            logLine(BobbaI18n.format("presets.log.imported",_selectedName));
         }
         if(_view != null)
         {
            _view.setHud("",0,0);
         }
         setHostVisible(true);
         refresh();
      }
      
      public function settingsSnapshot() : Object
      {
         var posts:Array = [];
         var row:Object = BobbaPresetsSettings.postFor(_selectedName);
         var k:String = null;
         var names:Array = [];
         var i:int = 0;
         for(k in row)
         {
            names.push(k);
         }
         names.sort();
         for(i = 0; i < names.length; i++)
         {
            k = String(names[i]);
            posts.push({
               "name":k,
               "id":int(row[k])
            });
         }
         return {
            "stack":BobbaPresetsSettings.stackClass,
            "placeMs":BobbaPresetsSettings.placeMs,
            "moveMs":BobbaPresetsSettings.moveMs,
            "incomplete":BobbaPresetsSettings.allowIncomplete,
            "builder":BobbaPresetsSettings.builderEnabled,
            "wired":BobbaPresetsSettings.exportWired,
            "bcWired":BobbaPresetsSettings.bcWired,
            "posts":posts,
            "preset":_selectedName
         };
      }
      
      public function toggleSetting(key:String) : void
      {
         if(key == "builder")
         {
            BobbaPresetsSettings.builderEnabled = !BobbaPresetsSettings.builderEnabled;
         }
         else if(key == "incomplete")
         {
            BobbaPresetsSettings.allowIncomplete = !BobbaPresetsSettings.allowIncomplete;
         }
         else if(key == "wired")
         {
            BobbaPresetsSettings.exportWired = !BobbaPresetsSettings.exportWired;
         }
         else if(key == "bcWired")
         {
            BobbaPresetsSettings.bcWired = !BobbaPresetsSettings.bcWired;
         }
         refresh();
      }
      
      public function setStackClass(value:String) : void
      {
         BobbaPresetsSettings.stackClass = value;
         refresh();
      }
      
      public function nudgePlace(delta:int) : void
      {
         BobbaPresetsSettings.placeMs = BobbaPresetsSettings.placeMs + delta;
         refresh();
      }
      
      public function nudgeMove(delta:int) : void
      {
         BobbaPresetsSettings.moveMs = BobbaPresetsSettings.moveMs + delta;
         refresh();
      }
      
      public function addPost(furniName:String, idText:String) : void
      {
         var id:int = 0;
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var found:Boolean = false;
         if(_selectedName == null || _selectedName.length == 0 || _selectedConfig == null)
         {
            logLine(BobbaI18n.t("presets.log.noPreset","Select a preset first"));
            refresh();
            return;
         }
         if(furniName == null || furniName.length == 0)
         {
            logLine(BobbaI18n.t("presets.log.postBad","Need a furniture name and a room id"));
            refresh();
            return;
         }
         id = int(idText);
         if(id <= 0)
         {
            logLine(BobbaI18n.t("presets.log.postBad","Need a furniture name and a room id"));
            refresh();
            return;
         }
         if(_selectedConfig.furniture != null)
         {
            for(i = 0; i < _selectedConfig.furniture.length; i++)
            {
               f = _selectedConfig.furniture[i] as BobbaPresetFurni;
               if(f != null && f.name == furniName)
               {
                  found = true;
                  break;
               }
            }
         }
         if(!found)
         {
            logLine(BobbaI18n.format("presets.log.postUnknown",furniName));
            refresh();
            return;
         }
         if(BobbaPresetsSettings.setPost(_selectedName,furniName,id))
         {
            logLine(BobbaI18n.format("presets.log.postAdded",furniName,id));
         }
         refresh();
      }
      
      public function removePost(furniName:String) : void
      {
         if(_selectedName == null || furniName == null)
         {
            return;
         }
         BobbaPresetsSettings.clearPost(_selectedName,furniName);
         refresh();
      }
      
      private function onInventoryReady() : void
      {
         if(_pendingCheck)
         {
            finishCheck();
            return;
         }
         refresh();
      }
      
      private function finishCheck() : void
      {
         var rows:Array = null;
         var missingN:int = 0;
         var i:int = 0;
         var row:Object = null;
         var bits:Array = null;
         var shown:int = 0;
         var skipN:int = 0;
         _pendingCheck = false;
         if(_selectedConfig == null)
         {
            refresh();
            return;
         }
         rows = BobbaAvailability.compare(_windowManager,_selectedConfig,BobbaPresetsSettings.postFor(_selectedName));
         skipN = BobbaPresetsSettings.postCount(_selectedName);
         if(skipN > 0)
         {
            logLine(BobbaI18n.format("presets.log.postSkip",skipN));
         }
         missingN = BobbaAvailability.missingCount(rows);
         if(rows.length == 0)
         {
            logLine(BobbaI18n.format("presets.log.checkOk",0));
            refresh();
            return;
         }
         if(missingN == 0)
         {
            logLine(BobbaI18n.format("presets.log.checkOk",rows.length));
         }
         else
         {
            bits = [];
            shown = 0;
            for(i = 0; i < rows.length; i++)
            {
               row = rows[i] as Object;
               if(row != null && int(row.missing) > 0)
               {
                  bits.push(String(row.className) + " (" + int(row.have) + "/" + int(row.need) + ")");
                  shown++;
                  if(shown >= 4)
                  {
                     break;
                  }
               }
            }
            if(missingN > shown)
            {
               bits.push("+" + (missingN - shown));
            }
            logLine(BobbaI18n.format("presets.log.checkMissing",missingN,bits.join(", ")));
         }
         if(rows.length <= 4)
         {
            for(i = 0; i < rows.length; i++)
            {
               row = rows[i] as Object;
               if(row != null)
               {
                  logLine(BobbaI18n.format("presets.log.checkRow",row.className,int(row.have),int(row.need)));
               }
            }
         }
         refresh();
      }
      
      private function onRectPicked(x0:int, y0:int, x1:int, y1:int) : void
      {
         _pendingRect = {
            "x0":x0,
            "y0":y0,
            "x1":x1,
            "y1":y1
         };
         _mode = MODE_NAME;
         logLine(BobbaI18n.format("presets.overlay.corner2",x1 - x0 + 1,y1 - y0 + 1));
         logLine(BobbaI18n.t("presets.overlay.name","Name this preset"));
         setHostVisible(true);
         refresh();
      }
      
      private function onPickAborted() : void
      {
         if(_mode == MODE_PICK || _mode == MODE_ROOT)
         {
            abort();
         }
      }
      
      private function abortSilent() : void
      {
         BobbaWiredCache.cancelDiffs();
         if(_fetcher != null && _fetcher.busy)
         {
            _fetcher.cancel();
         }
         if(_importer != null && _importer.busy)
         {
            _importer.cancel();
         }
         if(_picker != null)
         {
            _picker.stop();
         }
         _mode = MODE_IDLE;
         _pendingRect = null;
         _pendingName = "";
         if(_view != null)
         {
            _view.setHud("",0,0);
         }
      }
      
      private function setHostVisible(value:Boolean) : void
      {
         if(_host != null)
         {
            _host.visible = value;
         }
      }
      
      private function logLine(text:String) : void
      {
         if(_logLines == null)
         {
            _logLines = [];
         }
         _logLines.push(text != null ? text : "");
         while(_logLines.length > 8)
         {
            _logLines.shift();
         }
      }
   }
}
