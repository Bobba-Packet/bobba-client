package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.utils.Map;
   import com.sulake.habbo.communication.messages.outgoing.catalog.BuildersClubPlaceRoomItemMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.room.engine.MoveObjectMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.room.engine.PlaceObjectMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.room.engine.SetObjectDataMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.room.furniture.SetCustomStackingHeightComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.ApplySnapshotMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.UpdateActionMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.UpdateAddonMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.UpdateConditionMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.UpdateSelectorMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.UpdateTriggerMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.UpdateVariableMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.wiredmenu.WiredSetObjectVariableValueMessageComposer;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class BobbaPresetImporter
   {
      
      private static const FLOOR:int = 10;
      
      private static const PLACE_TIMEOUT:int = 4000;
      
      private static const WIRED_MS:int = 300;
      
      private static const BIND_MS:int = 60;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _onLog:Function;
      
      private var _onHud:Function;
      
      private var _onDone:Function;
      
      private var _timer:Timer;
      
      private var _steps:Array;
      
      private var _index:int;
      
      private var _cancel:Boolean;
      
      private var _busy:Boolean;
      
      private var _waiting:Boolean;
      
      private var _waitKind:String;
      
      private var _waitStart:int;
      
      private var _minWait:int;
      
      private var _expectX:int;
      
      private var _expectY:int;
      
      private var _expectClass:String;
      
      private var _expectPreset:int;
      
      private var _known:Object;
      
      private var _realIds:Object;
      
      private var _homes:Array;
      
      private var _total:int;
      
      private var _stage:String;
      
      private var _placeAttempts:int;
      
      private var _placedCount:int;
      
      private var _varIdMap:Object;
      
      private var _oldNameToId:Object;
      
      private var _rootX:int;
      
      private var _rootY:int;
      
      private var _stackHotel:int;
      
      private var _bindUndos:Array;
      
      private var _bindings:Array;
      
      public function BobbaPresetImporter()
      {
         super();
         _steps = [];
         _known = {};
         _realIds = {};
         _homes = [];
         _varIdMap = {};
         _oldNameToId = {};
         _bindUndos = [];
         _bindings = [];
         _cancel = false;
         _busy = false;
         _waiting = false;
      }
      
      public function get busy() : Boolean
      {
         return _busy;
      }
      
      public function start(windowManager:HabboWindowManagerComponent, cfg:BobbaPresetConfig, name:String, rootX:int, rootY:int, onLog:Function, onHud:Function, onDone:Function) : Boolean
      {
         var stacks:Array = null;
         var main:BobbaPresetFurni = null;
         var skip:Object = null;
         if(_busy)
         {
            return false;
         }
         _windowManager = windowManager;
         _onLog = onLog;
         _onHud = onHud;
         _onDone = onDone;
         _cancel = false;
         _waiting = false;
         _index = 0;
         _realIds = {};
         _known = snapshotIds();
         _homes = [];
         _stage = "stackables";
         _placeAttempts = 0;
         _placedCount = 0;
         _varIdMap = {};
         _oldNameToId = {};
         _bindUndos = [];
         _bindings = cfg != null && cfg.bindings != null ? cfg.bindings : [];
         _rootX = rootX;
         _rootY = rootY;
         skip = BobbaPresetsSettings.postFor(name);
         applyPosts(cfg,skip);
         stacks = BobbaStackTiles.list(windowManager,BobbaPresetsSettings.stackClass);
         if(stacks.length == 0)
         {
            say(BobbaI18n.t("presets.log.noStackTile","Place a stack tile first"));
            return false;
         }
         main = stacks[0] as BobbaPresetFurni;
         _stackHotel = main != null ? main.id : 0;
         rememberHomes(stacks);
         collectOldVars(cfg);
         buildSteps(cfg,skip,rootX,rootY,main);
         _total = countWork();
         _busy = true;
         if(_timer == null)
         {
            _timer = new Timer(10,0);
            _timer.addEventListener("timer",onTick);
         }
         hud(_stage,0,_total);
         _timer.start();
         return true;
      }
      
      public function cancel() : void
      {
         _cancel = true;
         BobbaWiredCache.cancelDiffs();
         if(!_busy)
         {
            stopTimer();
         }
      }
      
      public function dispose() : void
      {
         cancel();
         stopTimer();
         if(_timer != null)
         {
            _timer.removeEventListener("timer",onTick);
            _timer = null;
         }
         _windowManager = null;
         _onLog = null;
         _onHud = null;
         _onDone = null;
         _steps = null;
         _known = null;
         _realIds = null;
         _homes = null;
         _varIdMap = null;
         _oldNameToId = null;
         _bindUndos = null;
         _bindings = null;
      }
      
      private function applyPosts(cfg:BobbaPresetConfig, skip:Object) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         if(cfg == null || cfg.furniture == null || skip == null)
         {
            return;
         }
         for(i = 0; i < cfg.furniture.length; i++)
         {
            f = cfg.furniture[i] as BobbaPresetFurni;
            if(f != null && f.name != null && skip.hasOwnProperty(f.name))
            {
               _realIds[f.id] = int(skip[f.name]);
            }
         }
      }
      
      private function rememberHomes(stacks:Array) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         for(i = 0; i < stacks.length; i++)
         {
            f = stacks[i] as BobbaPresetFurni;
            if(f != null)
            {
               _homes.push({
                  "id":f.id,
                  "x":f.x,
                  "y":f.y,
                  "rot":f.rotation
               });
            }
         }
      }
      
      private function collectOldVars(cfg:BobbaPresetConfig) : void
      {
         var map:Object = null;
         var k:String = null;
         var list:Array = null;
         var i:int = 0;
         var raw:Object = null;
         var name:String = "";
         var vid:String = "";
         var ids:Array = null;
         var j:int = 0;
         _oldNameToId = {};
         if(cfg == null || cfg.wired == null)
         {
            return;
         }
         map = cfg.wired.variables_map as Object;
         if(map != null)
         {
            for(k in map)
            {
               if(k != null && k.length > 0 && map[k] != null)
               {
                  _oldNameToId[k] = String(map[k]);
               }
            }
         }
         list = cfg.wired.variables as Array;
         if(list != null)
         {
            for(i = 0; i < list.length; i++)
            {
               raw = list[i] as Object;
               if(raw != null)
               {
                  name = raw.config != null ? String(raw.config) : "";
                  vid = raw.variableId != null ? String(raw.variableId) : "";
                  if((vid == null || vid.length == 0) && raw.variableIds != null)
                  {
                     ids = raw.variableIds as Array;
                     for(j = 0; j < ids.length; j++)
                     {
                        vid = String(ids[j]);
                        if(vid != null && vid.length > 0 && vid != "0" && vid.indexOf("-") != 0 && vid.indexOf("~") != 0)
                        {
                           break;
                        }
                        vid = "";
                     }
                  }
                  if(name.length > 0 && vid != null && vid.length > 0)
                  {
                     _oldNameToId[name] = vid;
                  }
               }
            }
         }
      }
      
      private function buildSteps(cfg:BobbaPresetConfig, skip:Object, rootX:int, rootY:int, main:BobbaPresetFurni) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var toPlace:Array = [];
         var ads:Array = [];
         var src:Object = null;
         var used:Object = {};
         var destX:int = 0;
         var destY:int = 0;
         var tileX:int = main != null ? main.x : rootX;
         var tileY:int = main != null ? main.y : rootY;
         _steps = [];
         if(cfg == null || cfg.furniture == null)
         {
            pushHud("done");
            return;
         }
         for(i = 0; i < cfg.furniture.length; i++)
         {
            f = cfg.furniture[i] as BobbaPresetFurni;
            if(f != null)
            {
               if(skip == null || f.name == null || !skip.hasOwnProperty(f.name))
               {
                  toPlace.push(f);
               }
               if(f.className == "ads_background")
               {
                  ads.push(f);
               }
            }
         }
         pushHud("stackables");
         for(i = 0; i < toPlace.length; i++)
         {
            f = toPlace[i] as BobbaPresetFurni;
            src = takeSource(f,used);
            if(src != null)
            {
               destX = rootX + f.x;
               destY = rootY + f.y;
               if(main != null && (tileX != destX || tileY != destY))
               {
                  _steps.push({
                     "kind":"MOVE",
                     "hotel":main.id,
                     "x":destX,
                     "y":destY,
                     "rot":main.rotation
                  });
                  tileX = destX;
                  tileY = destY;
               }
               _steps.push({
                  "kind":"HEIGHT",
                  "hotel":main != null ? main.id : 0,
                  "z":Math.round(f.z * 100)
               });
               _steps.push({
                  "kind":"PLACE",
                  "preset":f.id,
                  "inv":int(src.inv),
                  "offer":int(src.offer),
                  "x":destX,
                  "y":destY,
                  "rot":f.rotation,
                  "className":f.className
               });
               if(f.state != null && f.state.length > 0)
               {
                  _steps.push({
                     "kind":"STATE",
                     "preset":f.id,
                     "state":f.state
                  });
               }
            }
            else if(!BobbaPresetsSettings.allowIncomplete)
            {
               _steps.push({"kind":"FAIL","text":BobbaI18n.t("presets.log.missingItems","Missing furniture — check items")});
               return;
            }
         }
         if(ads.length > 0)
         {
            pushHud("ads");
            for(i = 0; i < ads.length; i++)
            {
               f = ads[i] as BobbaPresetFurni;
               _steps.push({
                  "kind":"ADS",
                  "preset":f.id,
                  "image":f.adsImageUrl,
                  "ox":f.adsOffsetX,
                  "oy":f.adsOffsetY,
                  "oz":f.adsOffsetZ
               });
            }
         }
         pushWireds(cfg);
         pushHud("done");
         for(i = 0; i < _homes.length; i++)
         {
            _steps.push({
               "kind":"MOVE",
               "hotel":int(_homes[i].id),
               "x":int(_homes[i].x),
               "y":int(_homes[i].y),
               "rot":int(_homes[i].rot)
            });
         }
         _steps.push({"kind":"FINISH"});
      }
      
      private function takeSource(f:BobbaPresetFurni, used:Object) : Object
      {
         var offer:int = 0;
         var invId:int = 0;
         if(f == null)
         {
            return null;
         }
         offer = BobbaAvailability.bcOfferId(_windowManager,f.className);
         if(BobbaPresetsSettings.bcWired && offer > 0)
         {
            return {
               "inv":0,
               "offer":offer
            };
         }
         invId = BobbaAvailability.takeId(_windowManager,f.className,used);
         if(invId != 0)
         {
            return {
               "inv":invId,
               "offer":0
            };
         }
         if(offer > 0)
         {
            return {
               "inv":0,
               "offer":offer
            };
         }
         return null;
      }
      
      private function pushWireds(cfg:BobbaPresetConfig) : void
      {
         var buckets:Array = ["variables","conditions","effects","triggers","addons","selectors"];
         var b:int = 0;
         var i:int = 0;
         var list:Array = null;
         var raw:Object = null;
         var w:BobbaPresetWired = null;
         if(cfg == null || cfg.wired == null || cfg.wiredCount() < 1)
         {
            return;
         }
         pushHud("wired");
         for(b = 0; b < buckets.length; b++)
         {
            list = cfg.wired[String(buckets[b])] as Array;
            if(list != null)
            {
               for(i = 0; i < list.length; i++)
               {
                  raw = list[i] as Object;
                  w = BobbaPresetWired.fromObject(raw);
                  if(w != null && w.wiredId != 0)
                  {
                     pushWiredSave(w,String(buckets[b]));
                  }
               }
            }
            if(String(buckets[b]) == "variables" && needsVarSync(cfg))
            {
               _steps.push({"kind":"VARS"});
            }
         }
      }
      
      private function pushWiredSave(w:BobbaPresetWired, bucket:String) : void
      {
         var list:Array = null;
         if(w == null)
         {
            return;
         }
         list = bindingsFor(w.wiredId);
         if(list.length > 0)
         {
            _steps.push({
               "kind":"BIND_POSE",
               "bindings":list
            });
         }
         _steps.push({
            "kind":"WIRED",
            "need":w.wiredId,
            "bucket":bucket,
            "wired":w
         });
         if(list.length > 0)
         {
            _steps.push({
               "kind":"BIND_SNAP",
               "need":w.wiredId
            });
            _steps.push({"kind":"BIND_RESTORE"});
         }
      }
      
      private function bindingsFor(wiredId:int) : Array
      {
         var out:Array = [];
         var i:int = 0;
         var row:Object = null;
         if(_bindings == null)
         {
            return out;
         }
         for(i = 0; i < _bindings.length; i++)
         {
            row = _bindings[i] as Object;
            if(row != null && int(row.wiredId) == wiredId)
            {
               out.push(row);
            }
         }
         return out;
      }
      
      private function needsVarSync(cfg:BobbaPresetConfig) : Boolean
      {
         var buckets:Array = ["variables","conditions","effects","triggers","addons","selectors"];
         var b:int = 0;
         var i:int = 0;
         var k:String = null;
         var list:Array = null;
         var raw:Object = null;
         var ids:Array = null;
         if(cfg == null || cfg.wired == null)
         {
            return false;
         }
         if(_oldNameToId != null)
         {
            for(k in _oldNameToId)
            {
               return true;
            }
         }
         for(b = 0; b < buckets.length; b++)
         {
            list = cfg.wired[String(buckets[b])] as Array;
            if(list != null)
            {
               for(i = 0; i < list.length; i++)
               {
                  raw = list[i] as Object;
                  if(raw != null)
                  {
                     ids = raw.variableIds as Array;
                     if(ids != null && ids.length > 0)
                     {
                        return true;
                     }
                  }
               }
            }
         }
         return false;
      }
      
      private function pushHud(stage:String) : void
      {
         _steps.push({
            "kind":"HUD",
            "stage":stage
         });
      }
      
      private function countWork() : int
      {
         var n:int = 0;
         var i:int = 0;
         var s:Object = null;
         for(i = 0; i < _steps.length; i++)
         {
            s = _steps[i] as Object;
            if(s != null && s.bind != true && (s.kind == "PLACE" || s.kind == "MOVE" || s.kind == "HEIGHT" || s.kind == "WIRED" || s.kind == "BIND_POSE" || s.kind == "BIND_SNAP" || s.kind == "BIND_RESTORE"))
            {
               n++;
            }
         }
         return n;
      }
      
      private function onTick(e:*) : void
      {
         var elapsed:int = 0;
         var found:int = 0;
         if(_cancel)
         {
            finish(false,BobbaI18n.t("presets.log.aborted","Aborted"));
            return;
         }
         if(_waiting)
         {
            elapsed = getTimer() - _waitStart;
            if(_waitKind == "PLACE")
            {
               found = findNew(_expectX,_expectY,_expectClass);
               if(found > 0 && elapsed >= _minWait)
               {
                  _realIds[_expectPreset] = found;
                  _known[found] = true;
                  _placedCount++;
                  _waiting = false;
                  _index++;
               }
               else if(elapsed >= PLACE_TIMEOUT)
               {
                  say(BobbaI18n.format("presets.log.placeWait",_expectClass));
                  if(!BobbaPresetsSettings.allowIncomplete)
                  {
                     finish(false,BobbaI18n.t("presets.log.placeFail","Could not place furniture"));
                     return;
                  }
                  _waiting = false;
                  _index++;
               }
            }
            else if(_waitKind == "VARS")
            {
               if((BobbaWiredCache.diffsReady && elapsed >= _minWait) || elapsed >= 2500)
               {
                  buildVarIdMap();
                  _waiting = false;
                  _index++;
               }
            }
            else if(elapsed >= _minWait)
            {
               _waiting = false;
               _index++;
            }
            return;
         }
         runNext();
      }
      
      private function runNext() : void
      {
         var step:Object = null;
         var hotel:int = 0;
         var z:int = 0;
         var map:Map = null;
         var st:int = 0;
         if(_index >= _steps.length)
         {
            finishPlaced();
            return;
         }
         step = _steps[_index] as Object;
         if(step == null)
         {
            _index++;
            return;
         }
         if(step.kind == "HUD")
         {
            _stage = String(step.stage);
            hud(_stage,workDone(),_total);
            _index++;
            return;
         }
         if(step.kind == "FAIL")
         {
            finish(false,String(step.text));
            return;
         }
         if(step.kind == "FINISH")
         {
            finishPlaced();
            return;
         }
         if(step.kind == "VARS")
         {
            hud("vars",workDone(),_total);
            say(BobbaI18n.t("presets.log.varsSync","Reading wired variables"));
            if(!BobbaWiredCache.startDiffs(_windowManager,null))
            {
               buildVarIdMap();
               _index++;
               return;
            }
            _waiting = true;
            _waitKind = "VARS";
            _waitStart = getTimer();
            _minWait = 400;
            return;
         }
         if(step.kind == "PLACE")
         {
            if(!sendPlace(step))
            {
               finish(false,BobbaI18n.t("presets.log.sendFail","Could not send place"));
               return;
            }
            _expectX = int(step.x);
            _expectY = int(step.y);
            _expectClass = String(step.className);
            _expectPreset = int(step.preset);
            _waiting = true;
            _waitKind = "PLACE";
            _waitStart = getTimer();
            _minWait = BobbaPresetsSettings.placeMs;
            hud(_stage,workDone(),_total);
            return;
         }
         hotel = resolveHotel(step);
         if(step.hasOwnProperty("need") && placedId(int(step.need)) == 0)
         {
            _index++;
            return;
         }
         if(step.kind == "MOVE")
         {
            if(hotel > 0)
            {
               BobbaHotelSend.send(_windowManager,new MoveObjectMessageComposer(hotel,int(step.x),int(step.y),int(step.rot)));
            }
            waitDelay(stepWait(step,BobbaPresetsSettings.moveMs));
            hud(_stage,workDone(),_total);
            return;
         }
         if(step.kind == "HEIGHT")
         {
            hotel = resolveHotel(step);
            z = int(step.z);
            if(hotel > 0)
            {
               BobbaHotelSend.send(_windowManager,new SetCustomStackingHeightComposer([hotel,z]));
            }
            waitDelay(stepWait(step,BobbaPresetsSettings.placeMs));
            return;
         }
         if(step.kind == "ADS")
         {
            hotel = resolveHotel(step);
            if(hotel > 0)
            {
               map = new Map();
               map.add("imageUrl",step.image != null ? String(step.image) : "");
               map.add("offsetX",step.ox != null ? String(step.ox) : "0");
               map.add("offsetY",step.oy != null ? String(step.oy) : "0");
               map.add("offsetZ",step.oz != null ? String(step.oz) : "0");
               BobbaHotelSend.send(_windowManager,new SetObjectDataMessageComposer(hotel,map));
            }
            waitDelay(100);
            return;
         }
         if(step.kind == "STATE")
         {
            hotel = resolveHotel(step);
            st = int(step.state);
            if(hotel > 0)
            {
               BobbaHotelSend.send(_windowManager,new WiredSetObjectVariableValueMessageComposer(0,hotel,"-110",st,0));
            }
            waitDelay(stepWait(step,BobbaPresetsSettings.moveMs));
            return;
         }
         if(step.kind == "WIRED")
         {
            sendWired(step);
            waitDelay(WIRED_MS);
            hud(_stage,workDone(),_total);
            return;
         }
         if(step.kind == "BIND_SNAP")
         {
            hotel = placedId(int(step.need));
            if(hotel != 0)
            {
               Logger.log("[BobbaPresets] apply snapshot",hotel);
               say(BobbaI18n.format("presets.log.bindSnap",hotel));
               BobbaHotelSend.send(_windowManager,new ApplySnapshotMessageComposer(hotel));
            }
            waitDelay(WIRED_MS);
            hud(_stage,workDone(),_total);
            return;
         }
         if(step.kind == "BIND_POSE")
         {
            expandBindPose(step);
            hud(_stage,workDone(),_total);
            _index++;
            return;
         }
         if(step.kind == "BIND_RESTORE")
         {
            expandBindRestore();
            hud(_stage,workDone(),_total);
            _index++;
            return;
         }
         if(step.kind == "BIND_SETTLE")
         {
            waitDelay(WIRED_MS);
            return;
         }
         _index++;
      }
      
      private function sendPlace(step:Object) : Boolean
      {
         var inv:int = 0;
         var offer:int = 0;
         if(step == null)
         {
            return false;
         }
         offer = int(step.offer);
         if(offer > 0)
         {
            _placeAttempts++;
            Logger.log("[BobbaPresets] bc place",offer,int(step.x),int(step.y),int(step.rot),String(step.className));
            say(BobbaI18n.format("presets.log.placing",step.className,int(step.x),int(step.y)));
            return BobbaHotelSend.send(_windowManager,new BuildersClubPlaceRoomItemMessageComposer(-1,offer,"",int(step.x),int(step.y),int(step.rot),true));
         }
         inv = int(step.inv);
         if(inv == 0)
         {
            return false;
         }
         _placeAttempts++;
         Logger.log("[BobbaPresets] place",inv,int(step.x),int(step.y),int(step.rot),String(step.className));
         say(BobbaI18n.format("presets.log.placing",step.className,int(step.x),int(step.y)));
         return BobbaHotelSend.send(_windowManager,new PlaceObjectMessageComposer(inv,FLOOR,"",int(step.x),int(step.y),int(step.rot)));
      }
      
      private function sendWired(step:Object) : void
      {
         var w:BobbaPresetWired = null;
         var hotel:int = 0;
         var bucket:String = "";
         var options:Array = null;
         var items:Array = null;
         var items2:Array = null;
         var vars:Array = null;
         var furniSrc:Array = null;
         var userSrc:Array = null;
         var cfg:String = "";
         var delay:int = 0;
         var quant:int = 0;
         var filter:Boolean = false;
         var inverse:Boolean = false;
         if(step == null)
         {
            return;
         }
         w = step.wired as BobbaPresetWired;
         hotel = placedId(int(step.need));
         bucket = step.bucket != null ? String(step.bucket) : "";
         if(w == null || hotel == 0)
         {
            return;
         }
         options = copyInts(w.options);
         items = remapIds(w.items);
         items2 = remapIds(w.secondItems);
         vars = remapVarIds(w.variableIds);
         furniSrc = copyInts(w.furniSources);
         userSrc = copyInts(w.userSources);
         cfg = w.config != null ? w.config : "";
         if(bindingsFor(w.wiredId).length > 0)
         {
            cfg = "";
         }
         if(w.extra != null)
         {
            if(w.extra.hasOwnProperty("delay"))
            {
               delay = int(w.extra.delay);
            }
            if(w.extra.hasOwnProperty("quantifier"))
            {
               quant = int(w.extra.quantifier);
            }
            if(w.extra.filter == true)
            {
               filter = true;
            }
            if(w.extra.inverse == true)
            {
               inverse = true;
            }
         }
         Logger.log("[BobbaPresets] wired",bucket,hotel);
         say(BobbaI18n.format("presets.log.wiredSave",bucket,hotel));
         if(bucket == "effects")
         {
            BobbaHotelSend.send(_windowManager,new UpdateActionMessageComposer(hotel,options,vars,cfg,items,items2,delay,furniSrc,userSrc));
         }
         else if(bucket == "conditions")
         {
            BobbaHotelSend.send(_windowManager,new UpdateConditionMessageComposer(hotel,options,vars,cfg,items,items2,quant,furniSrc,userSrc));
         }
         else if(bucket == "triggers")
         {
            BobbaHotelSend.send(_windowManager,new UpdateTriggerMessageComposer(hotel,options,vars,cfg,items,items2,furniSrc,userSrc));
         }
         else if(bucket == "addons")
         {
            BobbaHotelSend.send(_windowManager,new UpdateAddonMessageComposer(hotel,options,vars,cfg,items,items2,furniSrc,userSrc));
         }
         else if(bucket == "selectors")
         {
            BobbaHotelSend.send(_windowManager,new UpdateSelectorMessageComposer(hotel,options,vars,cfg,items,items2,filter,inverse,furniSrc,userSrc));
         }
         else if(bucket == "variables")
         {
            BobbaHotelSend.send(_windowManager,new UpdateVariableMessageComposer(hotel,options,vars,cfg,items,items2,furniSrc,userSrc));
         }
      }
      
      private function remapIds(ids:Array) : Array
      {
         var out:Array = [];
         var i:int = 0;
         var mapped:int = 0;
         if(ids == null)
         {
            return out;
         }
         for(i = 0; i < ids.length; i++)
         {
            mapped = placedId(int(ids[i]));
            if(mapped != 0)
            {
               out.push(mapped);
            }
         }
         return out;
      }
      
      private function remapVarIds(ids:Array) : Array
      {
         var out:Array = [];
         var i:int = 0;
         var raw:String = "";
         var mapped:String = "";
         if(ids == null)
         {
            return out;
         }
         for(i = 0; i < ids.length; i++)
         {
            raw = String(ids[i]);
            if(raw == "0" || raw.indexOf("-") == 0 || raw.indexOf("~") == 0)
            {
               out.push(raw);
            }
            else if(_varIdMap != null && _varIdMap[raw] != null)
            {
               mapped = String(_varIdMap[raw]);
               out.push(mapped.length > 0 ? mapped : raw);
            }
            else
            {
               out.push(raw);
            }
         }
         return out;
      }
      
      private function buildVarIdMap() : void
      {
         var live:Object = null;
         var name:String = null;
         var oldId:String = "";
         var newId:String = "";
         _varIdMap = {};
         live = BobbaWiredCache.allNameMap();
         if(_oldNameToId != null)
         {
            for(name in _oldNameToId)
            {
               oldId = String(_oldNameToId[name]);
               newId = live != null && live[name] != null ? String(live[name]) : "";
               if(oldId.length > 0 && newId.length > 0)
               {
                  _varIdMap[oldId] = newId;
               }
            }
         }
      }
      
      private function copyInts(src:Array) : Array
      {
         var out:Array = [];
         var i:int = 0;
         if(src == null)
         {
            return out;
         }
         for(i = 0; i < src.length; i++)
         {
            out.push(int(src[i]));
         }
         return out;
      }
      
      private function finishPlaced() : void
      {
         if(_placeAttempts > 0 && _placedCount == 0)
         {
            finish(false,BobbaI18n.t("presets.log.placeFail","Could not place furniture"));
            return;
         }
         finish(true,"");
      }
      
      private function resolveHotel(step:Object) : int
      {
         if(step == null)
         {
            return 0;
         }
         if(step.hasOwnProperty("hotel") && int(step.hotel) > 0)
         {
            return int(step.hotel);
         }
         if(step.hasOwnProperty("preset") && _realIds.hasOwnProperty(int(step.preset)))
         {
            return int(_realIds[int(step.preset)]);
         }
         return 0;
      }
      
      private function waitDelay(ms:int) : void
      {
         _waiting = true;
         _waitKind = "DELAY";
         _waitStart = getTimer();
         _minWait = ms > 0 ? ms : 10;
      }
      
      private function stepWait(step:Object, fallback:int) : int
      {
         if(step != null && step.hasOwnProperty("wait"))
         {
            return int(step.wait);
         }
         return fallback;
      }
      
      private function bindWait() : int
      {
         var ms:int = BobbaPresetsSettings.moveMs;
         if(ms < BIND_MS)
         {
            return BIND_MS;
         }
         return ms;
      }
      
      private function insertSteps(at:int, extra:Array) : void
      {
         var i:int = 0;
         if(extra == null || extra.length == 0)
         {
            return;
         }
         if(at < 0)
         {
            at = 0;
         }
         if(at > _steps.length)
         {
            at = _steps.length;
         }
         for(i = extra.length - 1; i >= 0; i--)
         {
            _steps.splice(at,0,extra[i]);
         }
      }
      
      private function expandBindPose(step:Object) : void
      {
         var list:Array = null;
         var extra:Array = [];
         var i:int = 0;
         var b:Object = null;
         var hotel:int = 0;
         var cur:BobbaPresetFurni = null;
         var loc:Object = null;
         var tx:int = 0;
         var ty:int = 0;
         var tr:int = 0;
         var tz:int = 0;
         var needMove:Boolean = false;
         var wait:int = bindWait();
         _bindUndos = [];
         list = step != null ? step.bindings as Array : null;
         if(list == null)
         {
            return;
         }
         for(i = 0; i < list.length; i++)
         {
            b = list[i] as Object;
            if(b != null)
            {
               hotel = placedId(int(b.furniId));
               cur = furniByHotel(hotel);
               if(hotel == 0 || cur == null)
               {
                  Logger.log("[BobbaPresets] bind skip",int(b.furniId),hotel);
               }
               else
               {
                  loc = b.location as Object;
                  needMove = loc != null || b.hasOwnProperty("rotation") || b.hasOwnProperty("altitude");
                  if(isNumericState(b.state != null ? String(b.state) : ""))
                  {
                     extra.push({
                        "kind":"STATE",
                        "hotel":hotel,
                        "state":int(b.state),
                        "wait":wait,
                        "bind":true
                     });
                  }
                  if(needMove)
                  {
                     _bindUndos.push({
                        "id":hotel,
                        "x":cur.x,
                        "y":cur.y,
                        "rot":cur.rotation,
                        "z":int(Math.round(cur.z * 100))
                     });
                     tx = loc != null ? _rootX + int(loc.x) : cur.x;
                     ty = loc != null ? _rootY + int(loc.y) : cur.y;
                     tr = b.hasOwnProperty("rotation") ? facing(int(b.rotation)) : cur.rotation;
                     tz = b.hasOwnProperty("altitude") ? int(b.altitude) : int(Math.round(cur.z * 100));
                     extra.push({
                        "kind":"MOVE",
                        "hotel":_stackHotel,
                        "x":tx,
                        "y":ty,
                        "rot":0,
                        "wait":wait,
                        "bind":true
                     });
                     extra.push({
                        "kind":"HEIGHT",
                        "hotel":_stackHotel,
                        "z":tz,
                        "wait":wait,
                        "bind":true
                     });
                     extra.push({
                        "kind":"MOVE",
                        "hotel":hotel,
                        "x":tx,
                        "y":ty,
                        "rot":tr,
                        "wait":wait,
                        "bind":true
                     });
                  }
               }
            }
         }
         if(extra.length > 0)
         {
            extra.push({"kind":"BIND_SETTLE","bind":true});
            insertSteps(_index + 1,extra);
            Logger.log("[BobbaPresets] bind pose",list.length,_bindUndos.length);
            say(BobbaI18n.format("presets.log.bindPose",_bindUndos.length));
         }
      }
      
      private function expandBindRestore() : void
      {
         var extra:Array = [];
         var i:int = 0;
         var u:Object = null;
         var wait:int = bindWait();
         if(_bindUndos == null)
         {
            return;
         }
         for(i = 0; i < _bindUndos.length; i++)
         {
            u = _bindUndos[i] as Object;
            if(u != null && int(u.id) != 0)
            {
               extra.push({
                  "kind":"MOVE",
                  "hotel":_stackHotel,
                  "x":int(u.x),
                  "y":int(u.y),
                  "rot":0,
                  "wait":wait,
                  "bind":true
               });
               extra.push({
                  "kind":"HEIGHT",
                  "hotel":_stackHotel,
                  "z":int(u.z),
                  "wait":wait,
                  "bind":true
               });
               extra.push({
                  "kind":"MOVE",
                  "hotel":int(u.id),
                  "x":int(u.x),
                  "y":int(u.y),
                  "rot":int(u.rot),
                  "wait":wait,
                  "bind":true
               });
            }
         }
         _bindUndos = [];
         if(extra.length > 0)
         {
            extra.push({"kind":"BIND_SETTLE","bind":true});
            insertSteps(_index + 1,extra);
         }
      }
      
      private function facing(raw:int) : int
      {
         var rot:int = raw;
         if(rot >= 8)
         {
            rot = int(Math.round(rot / 45)) % 8;
         }
         if(rot < 0)
         {
            rot += 8;
         }
         return rot;
      }
      
      private function isNumericState(s:String) : Boolean
      {
         var i:int = 0;
         var c:int = 0;
         if(s == null || s.length == 0)
         {
            return false;
         }
         for(i = 0; i < s.length; i++)
         {
            c = int(s.charCodeAt(i));
            if(c < 48 || c > 57)
            {
               return false;
            }
         }
         return true;
      }
      
      private function furniByHotel(id:int) : BobbaPresetFurni
      {
         var items:Array = null;
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         if(id == 0)
         {
            return null;
         }
         items = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null && f.id == id)
            {
               return f;
            }
         }
         return null;
      }
      
      private function snapshotIds() : Object
      {
         var out:Object = {};
         var items:Array = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null)
            {
               out[f.id] = true;
            }
         }
         return out;
      }
      
      private function findNew(x:int, y:int, className:String) : int
      {
         var items:Array = BobbaRoomSnapshot.captureAllFloorItems(_windowManager);
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var atTile:int = 0;
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null && !BobbaRoomSnapshot.isTempId(f.id) && _known[f.id] != true)
            {
               if(f.x == x && f.y == y)
               {
                  if(className == null || className.length == 0 || BobbaAvailability.sameClass(f.className,className))
                  {
                     return f.id;
                  }
                  if(atTile == 0)
                  {
                     atTile = f.id;
                  }
               }
            }
         }
         return atTile;
      }
      
      private function placedId(preset:int) : int
      {
         if(_realIds != null && _realIds.hasOwnProperty(preset))
         {
            return int(_realIds[preset]);
         }
         if(_realIds != null && _realIds.hasOwnProperty(String(preset)))
         {
            return int(_realIds[String(preset)]);
         }
         return 0;
      }
      
      private function workDone() : int
      {
         var n:int = 0;
         var i:int = 0;
         var s:Object = null;
         for(i = 0; i < _index && i < _steps.length; i++)
         {
            s = _steps[i] as Object;
            if(s != null && s.bind != true && (s.kind == "PLACE" || s.kind == "MOVE" || s.kind == "HEIGHT" || s.kind == "WIRED" || s.kind == "BIND_POSE" || s.kind == "BIND_SNAP" || s.kind == "BIND_RESTORE"))
            {
               n++;
            }
         }
         return n;
      }
      
      private function hud(stage:String, current:int, total:int) : void
      {
         var key:String = "presets.hud." + stage;
         var label:String = BobbaI18n.t(key,stage);
         if(_onHud != null)
         {
            _onHud(label,current,total);
         }
      }
      
      private function say(text:String) : void
      {
         if(_onLog != null && text != null && text.length > 0)
         {
            _onLog(text);
         }
      }
      
      private function finish(ok:Boolean, err:String) : void
      {
         var cb:Function = _onDone;
         stopTimer();
         _busy = false;
         _waiting = false;
         hud("done",_total,_total);
         if(!ok)
         {
            say(err);
         }
         if(cb != null)
         {
            cb(ok);
         }
      }
      
      private function stopTimer() : void
      {
         if(_timer != null)
         {
            try
            {
               _timer.stop();
            }
            catch(e:Error)
            {
            }
         }
      }
   }
}
