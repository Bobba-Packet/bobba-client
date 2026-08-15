package com.sulake.habbo.window.utils.bobba
{
   public class BobbaPresetAds
   {
      
      public var furniId:int;
      
      public var imageUrl:String;
      
      public var offsetX:String;
      
      public var offsetY:String;
      
      public var offsetZ:String;
      
      public function BobbaPresetAds()
      {
         super();
         furniId = 0;
         imageUrl = "";
         offsetX = "0";
         offsetY = "0";
         offsetZ = "0";
      }
      
      public static function fromObject(o:Object) : BobbaPresetAds
      {
         var a:BobbaPresetAds = new BobbaPresetAds();
         if(o == null)
         {
            return a;
         }
         a.furniId = int(o.furniId);
         a.imageUrl = o.imageUrl != null ? String(o.imageUrl) : "";
         a.offsetX = o.offsetX != null ? String(o.offsetX) : "0";
         a.offsetY = o.offsetY != null ? String(o.offsetY) : "0";
         a.offsetZ = o.offsetZ != null ? String(o.offsetZ) : "0";
         return a;
      }
      
      public function toObject() : Object
      {
         return {
            "furniId":furniId,
            "imageUrl":(imageUrl != null ? imageUrl : ""),
            "offsetX":(offsetX != null ? offsetX : "0"),
            "offsetY":(offsetY != null ? offsetY : "0"),
            "offsetZ":(offsetZ != null ? offsetZ : "0")
         };
      }
   }
}
