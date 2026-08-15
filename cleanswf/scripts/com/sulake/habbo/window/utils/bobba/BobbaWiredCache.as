package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.ActionDefinition;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.ConditionDefinition;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.SelectorDefinition;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.Triggerable;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.WiredFurniActionEvent;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.WiredFurniAddonEvent;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.WiredFurniConditionEvent;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.WiredFurniSelectorEvent;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.WiredFurniTriggerEvent;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.WiredFurniVariableEvent;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.wiredcontext.WiredContext;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.wiredcontext.variables.WiredVariable;
   import com.sulake.habbo.communication.messages.incoming.userdefinedroomevents.wiredmenu.WiredAllVariablesDiffsEvent;
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.wiredmenu.WiredGetAllVariablesDiffsMessageComposer;
   import com.sulake.habbo.communication.messages.parser.userdefinedroomevents.wiredmenu.WiredAllVariablesDiffsMessageParser;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class BobbaWiredCache
   {
      
      private static var _installed:Boolean = false;
      
      private static var _roomHooked:Boolean = false;
      
      private static var _byId:Dictionary = new Dictionary();
      
      private static var _userByName:Object = {};
      
      private static var _allByName:Object = {};
      
      private static var _diffReady:Boolean = false;
      
      private static var _diffWaiting:Boolean = false;
      
      private static var _diffStart:int = 0;
      
      private static var _diffOnDone:Function = null;
      
      private static var _diffTimer:Timer = null;
      
      private static var _diffWindow:HabboWindowManagerComponent = null;
      
      public static var fetching:Boolean = false;
      
      private static const DIFF_WAIT_MS:int = 2500;
      
      public function BobbaWiredCache()
      {
         super();
      }
      
      public static function install(windowManager:HabboWindowManagerComponent) : void
      {
         if(windowManager == null)
         {
            return;
         }
         try
         {
            if(!_installed && windowManager.communication != null)
            {
               windowManager.communication.addHabboConnectionMessageEvent(new WiredFurniTriggerEvent(onTrigger));
               windowManager.communication.addHabboConnectionMessageEvent(new WiredFurniActionEvent(onAction));
               windowManager.communication.addHabboConnectionMessageEvent(new WiredFurniConditionEvent(onCondition));
               windowManager.communication.addHabboConnectionMessageEvent(new WiredFurniAddonEvent(onAddon));
               windowManager.communication.addHabboConnectionMessageEvent(new WiredFurniSelectorEvent(onSelector));
               windowManager.communication.addHabboConnectionMessageEvent(new WiredFurniVariableEvent(onVariable));
               windowManager.communication.addHabboConnectionMessageEvent(new WiredAllVariablesDiffsEvent(onDiffs));
               _installed = true;
            }
            if(!_roomHooked && windowManager.roomEngine != null && windowManager.roomEngine.events != null)
            {
               windowManager.roomEngine.events.addEventListener("REE_INITIALIZED",onRoomReset);
               windowManager.roomEngine.events.addEventListener("REE_DISPOSED",onRoomReset);
               _roomHooked = true;
            }
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] wired cache install failed",e.message);
         }
      }
      
      public static function clear() : void
      {
         _byId = new Dictionary();
      }
      
      public static function put(kind:String, id:int, options:Array, config:String, items:Array, secondItems:Array, furniSources:Array, userSources:Array, variableIds:Array, extra:Object = null) : void
      {
         var w:BobbaPresetWired = new BobbaPresetWired();
         w.kind = kind != null ? kind : "";
         w.wiredId = id;
         w.options = BobbaPresetWired.copyArr(options);
         w.config = config != null ? config : "";
         w.items = BobbaPresetWired.copyArr(items);
         w.secondItems = BobbaPresetWired.copyArr(secondItems);
         w.furniSources = BobbaPresetWired.copyArr(furniSources);
         w.userSources = BobbaPresetWired.copyArr(userSources);
         w.variableIds = BobbaPresetWired.copyArr(variableIds);
         w.extra = extra;
         _byId[id] = w;
      }
      
      public static function getById(id:int) : BobbaPresetWired
      {
         var w:BobbaPresetWired = _byId[id] as BobbaPresetWired;
         return w != null ? w.clone() : null;
      }
      
      public static function hasId(id:int) : Boolean
      {
         return (_byId[id] as BobbaPresetWired) != null;
      }
      
      private static function putFromDef(kind:String, def:Triggerable) : void
      {
         var extra:Object = null;
         var act:ActionDefinition = null;
         var cnd:ConditionDefinition = null;
         var slc:SelectorDefinition = null;
         var vid:String = "";
         if(def == null)
         {
            return;
         }
         extra = null;
         act = def as ActionDefinition;
         if(act != null)
         {
            extra = {"delay":act.delayInPulses};
         }
         cnd = def as ConditionDefinition;
         if(cnd != null)
         {
            extra = {"quantifier":cnd.quantifierCode};
         }
         slc = def as SelectorDefinition;
         if(slc != null)
         {
            extra = {
               "filter":slc.isFilter,
               "inverse":slc.isInvert
            };
         }
         if(kind == "variable")
         {
            vid = variableIdFromDef(def);
            if(vid == null || vid.length == 0)
            {
               vid = lookupName(def.stringParam);
            }
            if(vid != null && vid.length > 0)
            {
               extra = extra != null ? extra : {};
               extra.variableId = vid;
            }
         }
         put(kind,def.id,def.intParams,def.stringParam,def.stuffIds,def.stuffIds2,def.furniSourceTypes,def.userSourceTypes,def.variableIds,extra);
      }
      
      private static function onTrigger(e:WiredFurniTriggerEvent) : void
      {
         try
         {
            if(e != null && e.getParser() != null)
            {
               putFromDef("trigger",e.getParser().def);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private static function onAction(e:WiredFurniActionEvent) : void
      {
         try
         {
            if(e != null && e.getParser() != null)
            {
               putFromDef("effect",e.getParser().def);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private static function onCondition(e:WiredFurniConditionEvent) : void
      {
         try
         {
            if(e != null && e.getParser() != null)
            {
               putFromDef("condition",e.getParser().def);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private static function onAddon(e:WiredFurniAddonEvent) : void
      {
         try
         {
            if(e != null && e.getParser() != null)
            {
               putFromDef("addon",e.getParser().def);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private static function onSelector(e:WiredFurniSelectorEvent) : void
      {
         try
         {
            if(e != null && e.getParser() != null)
            {
               putFromDef("selector",e.getParser().def);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private static function onVariable(e:WiredFurniVariableEvent) : void
      {
         try
         {
            if(e != null && e.getParser() != null)
            {
               putFromDef("variable",e.getParser().def);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private static function onRoomReset(e:*) : void
      {
         clear();
         _userByName = {};
         _allByName = {};
         _diffReady = false;
      }
      
      public static function get diffsReady() : Boolean
      {
         return _diffReady;
      }
      
      public static function lookupName(name:String) : String
      {
         if(name == null || name.length == 0)
         {
            return "";
         }
         if(_allByName[name] != null)
         {
            return String(_allByName[name]);
         }
         if(_userByName[name] != null)
         {
            return String(_userByName[name]);
         }
         return "";
      }
      
      public static function userCreatedMap() : Object
      {
         var out:Object = {};
         var k:String = null;
         for(k in _userByName)
         {
            out[k] = String(_userByName[k]);
         }
         return out;
      }
      
      public static function allNameMap() : Object
      {
         var out:Object = {};
         var k:String = null;
         for(k in _allByName)
         {
            out[k] = String(_allByName[k]);
         }
         return out;
      }
      
      public static function startDiffs(windowManager:HabboWindowManagerComponent, onDone:Function) : Boolean
      {
         if(windowManager == null)
         {
            return false;
         }
         install(windowManager);
         cancelDiffs();
         _diffWindow = windowManager;
         _diffOnDone = onDone;
         _diffReady = false;
         _diffWaiting = true;
         _userByName = {};
         _allByName = {};
         _diffStart = getTimer();
         if(!BobbaHotelSend.send(windowManager,new WiredGetAllVariablesDiffsMessageComposer(null)))
         {
            _diffWaiting = false;
            _diffOnDone = null;
            return false;
         }
         if(_diffTimer == null)
         {
            _diffTimer = new Timer(50,0);
            _diffTimer.addEventListener("timer",onDiffTick);
         }
         _diffTimer.start();
         return true;
      }
      
      public static function cancelDiffs() : void
      {
         _diffWaiting = false;
         _diffOnDone = null;
         if(_diffTimer != null)
         {
            _diffTimer.stop();
         }
      }
      
      private static function onDiffTick(e:*) : void
      {
         var elapsed:int = 0;
         if(!_diffWaiting)
         {
            if(_diffTimer != null)
            {
               _diffTimer.stop();
            }
            return;
         }
         elapsed = getTimer() - _diffStart;
         if(_diffReady || elapsed >= DIFF_WAIT_MS)
         {
            finishDiffs();
         }
      }
      
      private static function finishDiffs() : void
      {
         var cb:Function = _diffOnDone;
         _diffWaiting = false;
         _diffOnDone = null;
         if(_diffTimer != null)
         {
            _diffTimer.stop();
         }
         if(cb != null)
         {
            cb(_diffReady);
         }
      }
      
      private static function onDiffs(e:WiredAllVariablesDiffsEvent) : void
      {
         var parser:WiredAllVariablesDiffsMessageParser = null;
         var dict:Dictionary = null;
         var key:* = undefined;
         var v:WiredVariable = null;
         try
         {
            if(e == null || e.getParser() == null)
            {
               return;
            }
            parser = e.getParser();
            dict = parser.addedOrUpdated;
            if(dict != null)
            {
               for(key in dict)
               {
                  v = key as WiredVariable;
                  rememberVar(v);
               }
            }
            if(parser.isLastChunk)
            {
               _diffReady = true;
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaPresets] wired diffs failed",err.message);
         }
      }
      
      private static function rememberVar(v:WiredVariable) : void
      {
         if(v == null || v.variableName == null || v.variableName.length == 0 || v.variableId == null || v.variableId.length == 0)
         {
            return;
         }
         _allByName[v.variableName] = v.variableId;
         if(v.variableType == 0)
         {
            _userByName[v.variableName] = v.variableId;
         }
      }
      
      private static function variableIdFromDef(def:Triggerable) : String
      {
         var ctx:WiredContext = null;
         var v:WiredVariable = null;
         var name:String = "";
         if(def == null || def.wiredContext == null)
         {
            return "";
         }
         ctx = def.wiredContext;
         name = def.stringParam != null ? def.stringParam : "";
         v = firstContextVar(ctx,name);
         return v != null && v.variableId != null ? v.variableId : "";
      }
      
      private static function firstContextVar(ctx:WiredContext, name:String) : WiredVariable
      {
         var v:WiredVariable = null;
         var list:Array = null;
         if(ctx == null)
         {
            return null;
         }
         if(ctx.furniVariableInfo != null)
         {
            v = ctx.furniVariableInfo.variable;
            if(matchVar(v,name))
            {
               return v;
            }
         }
         if(ctx.userVariableInfo != null)
         {
            v = ctx.userVariableInfo.variable;
            if(matchVar(v,name))
            {
               return v;
            }
         }
         if(ctx.globalVariableInfo != null)
         {
            v = ctx.globalVariableInfo.variable;
            if(matchVar(v,name))
            {
               return v;
            }
         }
         if(ctx.roomVariablesList != null)
         {
            list = ctx.roomVariablesList.variables;
            v = matchInList(list,name);
            if(v != null)
            {
               return v;
            }
         }
         if(ctx.referenceVariablesList != null)
         {
            list = ctx.referenceVariablesList.variables;
            v = matchInList(list,name);
            if(v != null)
            {
               return v;
            }
         }
         return null;
      }
      
      private static function matchInList(list:Array, name:String) : WiredVariable
      {
         var i:int = 0;
         var v:WiredVariable = null;
         if(list == null)
         {
            return null;
         }
         for(i = 0; i < list.length; i++)
         {
            v = list[i] as WiredVariable;
            if(matchVar(v,name))
            {
               return v;
            }
         }
         return null;
      }
      
      private static function matchVar(v:WiredVariable, name:String) : Boolean
      {
         if(v == null || v.variableId == null || v.variableId.length == 0)
         {
            return false;
         }
         if(name == null || name.length == 0)
         {
            return true;
         }
         return v.variableName == name;
      }
   }
}
