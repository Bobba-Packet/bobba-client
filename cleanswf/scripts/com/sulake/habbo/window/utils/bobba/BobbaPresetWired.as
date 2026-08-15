package com.sulake.habbo.window.utils.bobba
{
   public class BobbaPresetWired
   {
      
      public var kind:String;
      
      public var wiredId:int;
      
      public var options:Array;
      
      public var config:String;
      
      public var items:Array;
      
      public var secondItems:Array;
      
      public var furniSources:Array;
      
      public var userSources:Array;
      
      public var variableIds:Array;
      
      public var extra:Object;
      
      public function BobbaPresetWired()
      {
         super();
         kind = "";
         wiredId = 0;
         options = [];
         config = "";
         items = [];
         secondItems = [];
         furniSources = [];
         userSources = [];
         variableIds = [];
         extra = null;
      }
      
      public static function fromObject(o:Object) : BobbaPresetWired
      {
         var w:BobbaPresetWired = new BobbaPresetWired();
         if(o == null)
         {
            return w;
         }
         w.kind = o.kind != null ? String(o.kind) : "";
         w.wiredId = int(o.wiredId);
         w.options = copyArr(o.options as Array);
         w.config = o.config != null ? String(o.config) : "";
         w.items = copyArr(o.items as Array);
         w.secondItems = copyArr(o.secondItems as Array);
         w.furniSources = copyArr(o.furniSources as Array);
         w.userSources = copyArr(o.userSources as Array);
         w.variableIds = copyArr(o.variableIds as Array);
         w.extra = mergeExtra(o);
         return w;
      }
      
      public static function copyArr(src:Array) : Array
      {
         var out:Array = [];
         var i:int = 0;
         if(src == null)
         {
            return out;
         }
         for(i = 0; i < src.length; i++)
         {
            out.push(src[i]);
         }
         return out;
      }
      
      public static function mergeExtra(o:Object) : Object
      {
         var extra:Object = {};
         var has:Boolean = false;
         var k:String = null;
         if(o == null)
         {
            return null;
         }
         if(o.extra != null)
         {
            for(k in o.extra)
            {
               extra[k] = o.extra[k];
               has = true;
            }
         }
         if(o.hasOwnProperty("delay"))
         {
            extra.delay = o.delay;
            has = true;
         }
         if(o.hasOwnProperty("quantifier"))
         {
            extra.quantifier = o.quantifier;
            has = true;
         }
         if(o.hasOwnProperty("filter"))
         {
            extra.filter = o.filter;
            has = true;
         }
         if(o.hasOwnProperty("inverse"))
         {
            extra.inverse = o.inverse;
            has = true;
         }
         if(o.hasOwnProperty("variableId") && o.variableId != null && String(o.variableId).length > 0)
         {
            extra.variableId = String(o.variableId);
            has = true;
         }
         return has ? extra : null;
      }
      
      public function clone() : BobbaPresetWired
      {
         var w:BobbaPresetWired = fromObject(toObject());
         w.kind = kind;
         return w;
      }
      
      public function toObject() : Object
      {
         var o:Object = {
            "wiredId":wiredId,
            "options":(options != null ? options : []),
            "config":(config != null ? config : ""),
            "items":(items != null ? items : []),
            "secondItems":(secondItems != null ? secondItems : []),
            "furniSources":(furniSources != null ? furniSources : []),
            "userSources":(userSources != null ? userSources : []),
            "variableIds":(variableIds != null ? variableIds : [])
         };
         if(extra != null)
         {
            if(extra.hasOwnProperty("delay"))
            {
               o.delay = extra.delay;
            }
            if(extra.hasOwnProperty("quantifier"))
            {
               o.quantifier = extra.quantifier;
            }
            if(extra.hasOwnProperty("filter"))
            {
               o.filter = extra.filter;
            }
            if(extra.hasOwnProperty("inverse"))
            {
               o.inverse = extra.inverse;
            }
            if(extra.hasOwnProperty("variableId") && extra.variableId != null && String(extra.variableId).length > 0)
            {
               o.variableId = String(extra.variableId);
            }
         }
         return o;
      }
   }
}
