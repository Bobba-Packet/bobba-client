package com.sulake.habbo.window.utils.bobba
{
   public class BobbaPresetExporter
   {
      
      public static var lastMissingWired:int = 0;
      
      public static var lastWiredCount:int = 0;
      
      public static var lastAdsCount:int = 0;
      
      public static var lastBcCount:int = 0;
      
      public static var lastBindingCount:int = 0;
      
      public function BobbaPresetExporter()
      {
         super();
      }
      
      public static function boundsOf(items:Array) : Object
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var minX:int = 0;
         var minY:int = 0;
         var maxX:int = 0;
         var maxY:int = 0;
         var found:Boolean = false;
         if(items == null)
         {
            return null;
         }
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null)
            {
               if(!found)
               {
                  minX = f.x;
                  minY = f.y;
                  maxX = f.x;
                  maxY = f.y;
                  found = true;
               }
               else
               {
                  if(f.x < minX)
                  {
                     minX = f.x;
                  }
                  if(f.y < minY)
                  {
                     minY = f.y;
                  }
                  if(f.x > maxX)
                  {
                     maxX = f.x;
                  }
                  if(f.y > maxY)
                  {
                     maxY = f.y;
                  }
               }
            }
         }
         if(!found)
         {
            return null;
         }
         return {
            "x0":minX,
            "y0":minY,
            "x1":maxX,
            "y1":maxY
         };
      }
      
      public static function missingWiredIds(items:Array, x0:int, y0:int, x1:int, y1:int) : Array
      {
         var swap:int = 0;
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var id:int = 0;
         var seen:Object = {};
         var out:Array = [];
         if(x0 > x1)
         {
            swap = x0;
            x0 = x1;
            x1 = swap;
         }
         if(y0 > y1)
         {
            swap = y0;
            y0 = y1;
            y1 = swap;
         }
         if(items != null)
         {
            for(i = 0; i < items.length; i++)
            {
               f = items[i] as BobbaPresetFurni;
               if(f != null && isWiredClass(f.className) && f.x >= x0 && f.x <= x1 && f.y >= y0 && f.y <= y1)
               {
                  id = f.id;
                  if(id != 0 && !seen[id] && !BobbaWiredCache.hasId(id))
                  {
                     seen[id] = true;
                     out.push(id);
                  }
               }
            }
         }
         return out;
      }
      
      public static function hasVariableRefs(items:Array, x0:int, y0:int, x1:int, y1:int) : Boolean
      {
         var swap:int = 0;
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var cached:BobbaPresetWired = null;
         if(x0 > x1)
         {
            swap = x0;
            x0 = x1;
            x1 = swap;
         }
         if(y0 > y1)
         {
            swap = y0;
            y0 = y1;
            y1 = swap;
         }
         if(items == null)
         {
            return false;
         }
         for(i = 0; i < items.length; i++)
         {
            f = items[i] as BobbaPresetFurni;
            if(f != null && f.x >= x0 && f.x <= x1 && f.y >= y0 && f.y <= y1)
            {
               if(f.className != null && f.className.indexOf("wf_var_") == 0)
               {
                  return true;
               }
               cached = BobbaWiredCache.getById(f.id);
               if(cached != null && cached.variableIds != null && cached.variableIds.length > 0)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function exportRect(items:Array, x0:int, y0:int, x1:int, y1:int, windowManager:* = null) : BobbaPresetConfig
      {
         var swap:int = 0;
         var collected:Array = [];
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var copy:BobbaPresetFurni = null;
         var lowestZ:Number = 0;
         var zSet:Boolean = false;
         var counts:Object = {};
         var n:int = 0;
         var key:String = "";
         var hotelToNorm:Object = {};
         var furniByNorm:Object = {};
         var cfg:BobbaPresetConfig = null;
         lastMissingWired = 0;
         lastWiredCount = 0;
         lastAdsCount = 0;
         lastBcCount = 0;
         lastBindingCount = 0;
         if(x0 > x1)
         {
            swap = x0;
            x0 = x1;
            x1 = swap;
         }
         if(y0 > y1)
         {
            swap = y0;
            y0 = y1;
            y1 = swap;
         }
         if(items != null)
         {
            for(i = 0; i < items.length; i++)
            {
               f = items[i] as BobbaPresetFurni;
               if(f != null && f.x >= x0 && f.x <= x1 && f.y >= y0 && f.y <= y1)
               {
                  copy = cloneFurni(f);
                  copy.hotelId = f.id;
                  collected.push(copy);
               }
            }
         }
         collected.sort(compareFurni);
         for(i = 0; i < collected.length; i++)
         {
            copy = collected[i] as BobbaPresetFurni;
            if(copy != null)
            {
               if(!zSet || copy.z < lowestZ)
               {
                  lowestZ = copy.z;
                  zSet = true;
               }
            }
         }
         if(!zSet)
         {
            lowestZ = 0;
         }
         for(i = 0; i < collected.length; i++)
         {
            copy = collected[i] as BobbaPresetFurni;
            if(copy != null)
            {
               hotelToNorm[copy.hotelId] = i + 1;
               copy.id = i + 1;
               copy.x -= x0;
               copy.y -= y0;
               copy.z -= lowestZ;
               key = copy.className != null ? copy.className : "";
               n = int(counts[key]);
               counts[key] = n + 1;
               copy.name = key + "[" + n + "]";
               if(isWiredClass(key))
               {
                  copy.state = null;
               }
               copy.bc = false;
               if(copy.hotelId >= BobbaRoomSnapshot.BC_ID_MIN)
               {
                  copy.bc = true;
               }
               else if(windowManager != null && BobbaAvailability.bcOfferId(windowManager,key) > 0)
               {
                  copy.bc = true;
               }
               if(copy.bc)
               {
                  lastBcCount++;
               }
               furniByNorm[copy.id] = copy;
            }
         }
         cfg = new BobbaPresetConfig();
         cfg.furniture = collected;
         if(BobbaPresetsSettings.exportWired)
         {
            attachWired(cfg,collected,hotelToNorm,furniByNorm,x0,y0,lowestZ);
         }
         attachAds(cfg,collected);
         return cfg;
      }
      
      private static function attachWired(cfg:BobbaPresetConfig, collected:Array, hotelToNorm:Object, furniByNorm:Object, x0:int, y0:int, lowestZ:Number) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var cached:BobbaPresetWired = null;
         var mapped:BobbaPresetWired = null;
         var bucket:String = "";
         var list:Array = null;
         if(cfg == null || cfg.wired == null)
         {
            return;
         }
         for(i = 0; i < collected.length; i++)
         {
            f = collected[i] as BobbaPresetFurni;
            if(f != null && isWiredClass(f.className))
            {
               cached = BobbaWiredCache.getById(f.hotelId);
               if(cached == null)
               {
                  lastMissingWired++;
               }
               else
               {
                  mapped = remapWired(cached,f.id,hotelToNorm);
                  bucket = kindBucket(mapped.kind,f.className);
                  if(bucket == "variables")
                  {
                     fillVariableId(mapped);
                  }
                  if(needsBinding(f.className))
                  {
                     addBindings(cfg,mapped,hotelToNorm,furniByNorm,x0,y0,lowestZ);
                     mapped.config = "";
                  }
                  list = cfg.wired[bucket] as Array;
                  if(list == null)
                  {
                     list = [];
                     cfg.wired[bucket] = list;
                  }
                  list.push(mapped.toObject());
                  lastWiredCount++;
               }
            }
         }
         attachVarMap(cfg);
      }
      
      private static function fillVariableId(w:BobbaPresetWired) : void
      {
         var vid:String = "";
         var name:String = "";
         if(w == null)
         {
            return;
         }
         name = w.config != null ? w.config : "";
         if(w.extra != null && w.extra.variableId != null)
         {
            vid = String(w.extra.variableId);
         }
         if((vid == null || vid.length == 0) && name.length > 0)
         {
            vid = BobbaWiredCache.lookupName(name);
         }
         if((vid == null || vid.length == 0) && w.variableIds != null)
         {
            vid = firstUserVarId(w.variableIds);
         }
         if(vid != null && vid.length > 0)
         {
            w.extra = w.extra != null ? w.extra : {};
            w.extra.variableId = vid;
         }
      }
      
      private static function firstUserVarId(ids:Array) : String
      {
         var i:int = 0;
         var raw:String = "";
         if(ids == null)
         {
            return "";
         }
         for(i = 0; i < ids.length; i++)
         {
            raw = String(ids[i]);
            if(raw != null && raw.length > 0 && raw != "0" && raw.indexOf("-") != 0 && raw.indexOf("~") != 0)
            {
               return raw;
            }
         }
         return "";
      }
      
      private static function attachVarMap(cfg:BobbaPresetConfig) : void
      {
         var map:Object = null;
         var list:Array = null;
         var i:int = 0;
         var raw:Object = null;
         var name:String = "";
         var vid:String = "";
         if(cfg == null || cfg.wired == null)
         {
            return;
         }
         map = BobbaWiredCache.userCreatedMap();
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
                  if((vid == null || vid.length == 0) && name.length > 0 && map[name] != null)
                  {
                     vid = String(map[name]);
                     raw.variableId = vid;
                  }
                  if(name.length > 0 && vid != null && vid.length > 0)
                  {
                     map[name] = vid;
                  }
               }
            }
         }
         cfg.wired.variables_map = map;
      }
      
      private static function remapWired(src:BobbaPresetWired, newId:int, hotelToNorm:Object) : BobbaPresetWired
      {
         var w:BobbaPresetWired = src.clone();
         w.wiredId = newId;
         w.items = remapIds(src.items,hotelToNorm);
         w.secondItems = remapIds(src.secondItems,hotelToNorm);
         return w;
      }
      
      private static function remapIds(ids:Array, hotelToNorm:Object) : Array
      {
         var out:Array = [];
         var i:int = 0;
         var hotel:int = 0;
         var mapped:* = undefined;
         if(ids == null)
         {
            return out;
         }
         for(i = 0; i < ids.length; i++)
         {
            hotel = int(ids[i]);
            mapped = hotelToNorm[hotel];
            if(mapped != null)
            {
               out.push(int(mapped));
            }
         }
         return out;
      }
      
      private static function attachAds(cfg:BobbaPresetConfig, collected:Array) : void
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var ads:BobbaPresetAds = null;
         if(cfg == null)
         {
            return;
         }
         if(cfg.adsBackgrounds == null)
         {
            cfg.adsBackgrounds = [];
         }
         for(i = 0; i < collected.length; i++)
         {
            f = collected[i] as BobbaPresetFurni;
            if(f != null && f.className == "ads_background" && f.adsImageUrl != null)
            {
               ads = new BobbaPresetAds();
               ads.furniId = f.id;
               ads.imageUrl = f.adsImageUrl;
               ads.offsetX = f.adsOffsetX != null ? f.adsOffsetX : "0";
               ads.offsetY = f.adsOffsetY != null ? f.adsOffsetY : "0";
               ads.offsetZ = f.adsOffsetZ != null ? f.adsOffsetZ : "0";
               cfg.adsBackgrounds.push(ads.toObject());
               lastAdsCount++;
            }
         }
      }
      
      private static function kindBucket(kind:String, className:String) : String
      {
         if(kind == "trigger" || kind == "condition" || kind == "effect" || kind == "addon" || kind == "selector" || kind == "variable")
         {
            if(kind == "effect")
            {
               return "effects";
            }
            if(kind == "variable")
            {
               return "variables";
            }
            return kind + "s";
         }
         if(className != null)
         {
            if(className.indexOf("wf_trg_") == 0)
            {
               return "triggers";
            }
            if(className.indexOf("wf_cnd_") == 0)
            {
               return "conditions";
            }
            if(className.indexOf("wf_act_") == 0)
            {
               return "effects";
            }
            if(className.indexOf("wf_xtra_") == 0)
            {
               return "addons";
            }
            if(className.indexOf("wf_slc_") == 0)
            {
               return "selectors";
            }
            if(className.indexOf("wf_var_") == 0)
            {
               return "variables";
            }
         }
         return "triggers";
      }
      
      private static function needsBinding(className:String) : Boolean
      {
         if(className == null)
         {
            return false;
         }
         return className.indexOf("wf_act_match_to_sshot") == 0 || className.indexOf("wf_cnd_match_snapshot") == 0 || className.indexOf("wf_cnd_not_match_snap") == 0 || className.indexOf("wf_trg_stuff_state") == 0;
      }
      
      private static function addBindings(cfg:BobbaPresetConfig, wired:BobbaPresetWired, hotelToNorm:Object, furniByNorm:Object, x0:int, y0:int, lowestZ:Number) : void
      {
         var parsed:Array = null;
         var i:int = 0;
         var row:Object = null;
         var hotel:int = 0;
         var mapped:* = undefined;
         var furni:BobbaPresetFurni = null;
         var loc:Object = null;
         var zOff:int = int(Math.round(lowestZ * 100));
         if(wired == null)
         {
            return;
         }
         if(cfg.bindings == null)
         {
            cfg.bindings = [];
         }
         parsed = parseConfigBindings(wired.config,wired.wiredId);
         if(parsed.length > 0)
         {
            for(i = 0; i < parsed.length; i++)
            {
               row = parsed[i] as Object;
               if(row != null)
               {
                  hotel = int(row.furniId);
                  mapped = hotelToNorm[hotel];
                  if(mapped != null)
                  {
                     row.furniId = int(mapped);
                     row.wiredId = wired.wiredId;
                     loc = row.location as Object;
                     if(loc != null)
                     {
                        loc.x = int(loc.x) - x0;
                        loc.y = int(loc.y) - y0;
                     }
                     if(row.hasOwnProperty("altitude"))
                     {
                        row.altitude = int(row.altitude) - zOff;
                     }
                     cfg.bindings.push(row);
                     lastBindingCount++;
                  }
               }
            }
            return;
         }
         if(wired.items == null)
         {
            return;
         }
         for(i = 0; i < wired.items.length; i++)
         {
            furni = furniByNorm[int(wired.items[i])] as BobbaPresetFurni;
            if(furni != null)
            {
               row = fallbackBinding(wired,furni);
               if(row != null)
               {
                  cfg.bindings.push(row);
                  lastBindingCount++;
               }
            }
         }
      }
      
      private static function parseConfigBindings(config:String, wiredId:int) : Array
      {
         var out:Array = [];
         var chunks:Array = null;
         var c:int = 0;
         var fields:Array = null;
         var row:Object = null;
         var part:String = "";
         var sep:String = ",";
         if(config == null || config.length == 0)
         {
            return out;
         }
         if(config.indexOf(",") < 0 && config.indexOf(":") >= 0)
         {
            sep = ":";
         }
         else if(config.indexOf(",") < 0)
         {
            return out;
         }
         chunks = config.split(";");
         for(c = 0; c < chunks.length; c++)
         {
            part = String(chunks[c]);
            if(part != null && part.length > 0)
            {
               fields = part.split(sep);
               if(fields.length >= 5)
               {
                  row = {
                     "furniId":int(fields[0]),
                     "wiredId":wiredId
                  };
                  if(String(fields[1]) != "N")
                  {
                     row.state = String(fields[1]);
                  }
                  if(String(fields[2]) != "N")
                  {
                     row.rotation = facing(int(fields[2]));
                  }
                  if(String(fields[3]) != "N" && String(fields[4]) != "N")
                  {
                     row.location = {
                        "x":int(fields[3]),
                        "y":int(fields[4])
                     };
                  }
                  if(fields.length >= 6 && String(fields[5]) != "N")
                  {
                     row.altitude = int(fields[5]);
                  }
                  out.push(row);
               }
            }
         }
         return out;
      }
      
      private static function facing(raw:int) : int
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
      
      private static function fallbackBinding(wired:BobbaPresetWired, furni:BobbaPresetFurni) : Object
      {
         var opts:Array = null;
         var bindState:Boolean = true;
         var bindDir:Boolean = true;
         var bindPos:Boolean = true;
         var bindAlt:Boolean = true;
         var row:Object = null;
         if(wired == null || furni == null)
         {
            return null;
         }
         opts = wired.options;
         if(opts != null && opts.length >= 4)
         {
            bindState = int(opts[0]) == 1;
            bindDir = int(opts[1]) == 1;
            bindPos = int(opts[2]) == 1;
            bindAlt = int(opts[3]) == 1;
         }
         if(!bindState && !bindDir && !bindPos && !bindAlt)
         {
            return null;
         }
         row = {
            "furniId":furni.id,
            "wiredId":wired.wiredId
         };
         if(bindPos)
         {
            row.location = {
               "x":furni.x,
               "y":furni.y
            };
         }
         if(bindDir)
         {
            row.rotation = furni.rotation;
         }
         if(bindAlt)
         {
            row.altitude = int(Math.round(furni.z * 100));
         }
         if(bindState && furni.state != null && furni.state.length > 0)
         {
            row.state = furni.state;
         }
         return row;
      }
      
      private static function cloneFurni(src:BobbaPresetFurni) : BobbaPresetFurni
      {
         var copy:BobbaPresetFurni = BobbaPresetFurni.fromObject(src != null ? src.toObject() : null);
         if(src != null && copy != null)
         {
            copy.hotelId = src.hotelId;
            copy.adsImageUrl = src.adsImageUrl;
            copy.adsOffsetX = src.adsOffsetX;
            copy.adsOffsetY = src.adsOffsetY;
            copy.adsOffsetZ = src.adsOffsetZ;
            copy.bc = src.bc;
         }
         return copy;
      }
      
      public static function isWiredClass(className:String) : Boolean
      {
         if(className == null || className.length < 7)
         {
            return false;
         }
         return className.indexOf("wf_trg_") == 0 || className.indexOf("wf_cnd_") == 0 || className.indexOf("wf_act_") == 0 || className.indexOf("wf_xtra_") == 0 || className.indexOf("wf_slc_") == 0 || className.indexOf("wf_var_") == 0;
      }
      
      private static function compareFurni(a:Object, b:Object) : int
      {
         var fa:BobbaPresetFurni = a as BobbaPresetFurni;
         var fb:BobbaPresetFurni = b as BobbaPresetFurni;
         if(fa == null || fb == null)
         {
            return 0;
         }
         if(fa.y != fb.y)
         {
            return fa.y - fb.y;
         }
         if(fa.x != fb.x)
         {
            return fa.x - fb.x;
         }
         return fa.id - fb.id;
      }
   }
}
