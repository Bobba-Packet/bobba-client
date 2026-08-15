package com.sulake.habbo.window.utils.bobba
{
   public class BobbaPresetConfig
   {
      
      public var furniture:Array;
      
      public var wired:Object;
      
      public var bindings:Array;
      
      public var adsBackgrounds:Array;
      
      public function BobbaPresetConfig()
      {
         super();
         furniture = [];
         wired = emptyWired();
         bindings = [];
         adsBackgrounds = [];
      }
      
      public static function emptyWired() : Object
      {
         return {
            "conditions":[],
            "effects":[],
            "triggers":[],
            "addons":[],
            "selectors":[],
            "variables":[],
            "variables_map":{}
         };
      }
      
      public static function fromObject(o:Object) : BobbaPresetConfig
      {
         var cfg:BobbaPresetConfig = new BobbaPresetConfig();
         var list:Array = null;
         var i:int = 0;
         if(o == null)
         {
            return cfg;
         }
         list = o.furni as Array;
         if(list != null)
         {
            cfg.furniture = [];
            for(i = 0; i < list.length; i++)
            {
               cfg.furniture.push(BobbaPresetFurni.fromObject(list[i] as Object));
            }
         }
         if(o.wired != null)
         {
            cfg.wired = o.wired;
            if(cfg.wired.conditions == null)
            {
               cfg.wired.conditions = [];
            }
            if(cfg.wired.effects == null)
            {
               cfg.wired.effects = [];
            }
            if(cfg.wired.triggers == null)
            {
               cfg.wired.triggers = [];
            }
            if(cfg.wired.addons == null)
            {
               cfg.wired.addons = [];
            }
            if(cfg.wired.selectors == null)
            {
               cfg.wired.selectors = [];
            }
            if(cfg.wired.variables == null)
            {
               cfg.wired.variables = [];
            }
            if(cfg.wired.variables_map == null)
            {
               cfg.wired.variables_map = {};
            }
         }
         list = o.bindings as Array;
         if(list != null)
         {
            cfg.bindings = list;
         }
         list = o.adsBackgrounds as Array;
         if(list != null)
         {
            cfg.adsBackgrounds = list;
         }
         return cfg;
      }
      
      public static function fromJsonString(s:String) : BobbaPresetConfig
      {
         if(s == null || s.length == 0)
         {
            return new BobbaPresetConfig();
         }
         return fromObject(JSON.parse(s) as Object);
      }
      
      public function toObject() : Object
      {
         var furniObjs:Array = [];
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         if(furniture != null)
         {
            for(i = 0; i < furniture.length; i++)
            {
               f = furniture[i] as BobbaPresetFurni;
               if(f != null)
               {
                  furniObjs.push(f.toObject());
               }
            }
         }
         return {
            "furni":furniObjs,
            "wired":(wired != null ? wired : emptyWired()),
            "bindings":(bindings != null ? bindings : []),
            "adsBackgrounds":(adsBackgrounds != null ? adsBackgrounds : [])
         };
      }
      
      public function toJsonString() : String
      {
         try
         {
            return JSON.stringify(toObject(),null,2);
         }
         catch(e:Error)
         {
         }
         return JSON.stringify(toObject());
      }
      
      public function furniCount() : int
      {
         return furniture != null ? int(furniture.length) : 0;
      }
      
      public function wiredCount() : int
      {
         var n:int = 0;
         if(wired == null)
         {
            return 0;
         }
         n += countArr(wired.conditions);
         n += countArr(wired.effects);
         n += countArr(wired.triggers);
         n += countArr(wired.addons);
         n += countArr(wired.selectors);
         n += countArr(wired.variables);
         return n;
      }
      
      public function dimX() : int
      {
         return dimAxis(true);
      }
      
      public function dimY() : int
      {
         return dimAxis(false);
      }
      
      private function dimAxis(useX:Boolean) : int
      {
         var i:int = 0;
         var f:BobbaPresetFurni = null;
         var minV:int = 0;
         var maxV:int = 0;
         var v:int = 0;
         if(furniture == null || furniture.length == 0)
         {
            return 0;
         }
         minV = 2147483647;
         maxV = -2147483647;
         for(i = 0; i < furniture.length; i++)
         {
            f = furniture[i] as BobbaPresetFurni;
            if(f != null)
            {
               v = useX ? f.x : f.y;
               if(v < minV)
               {
                  minV = v;
               }
               if(v > maxV)
               {
                  maxV = v;
               }
            }
         }
         if(minV > maxV)
         {
            return 0;
         }
         return maxV - minV + 1;
      }
      
      private function countArr(a:*) : int
      {
         var list:Array = a as Array;
         return list != null ? int(list.length) : 0;
      }
   }
}
