package com.sulake.habbo.window.utils.bobba
{
   public class BobbaPresetFurni
   {
      
      public var id:int;
      
      public var className:String;
      
      public var name:String;
      
      public var x:int;
      
      public var y:int;
      
      public var z:Number;
      
      public var rotation:int;
      
      public var state:String;
      
      public var hotelId:int;
      
      public var adsImageUrl:String;
      
      public var adsOffsetX:String;
      
      public var adsOffsetY:String;
      
      public var adsOffsetZ:String;
      
      public var bc:Boolean;
      
      public function BobbaPresetFurni()
      {
         super();
         id = 0;
         className = "";
         name = "";
         x = 0;
         y = 0;
         z = 0;
         rotation = 0;
         state = null;
         hotelId = 0;
         adsImageUrl = null;
         adsOffsetX = null;
         adsOffsetY = null;
         adsOffsetZ = null;
         bc = false;
      }
      
      public static function fromObject(o:Object) : BobbaPresetFurni
      {
         var loc:Object = null;
         var item:BobbaPresetFurni = new BobbaPresetFurni();
         if(o == null)
         {
            return item;
         }
         item.id = int(o.id);
         item.className = o.className != null ? String(o.className) : "";
         item.name = o.name != null ? String(o.name) : "";
         loc = o.location as Object;
         if(loc != null)
         {
            item.x = int(loc.x);
            item.y = int(loc.y);
            item.z = Number(loc.z);
         }
         item.rotation = int(o.rotation);
         if(o.hasOwnProperty("state") && o.state != null)
         {
            item.state = String(o.state);
         }
         item.bc = o.hasOwnProperty("bc") && o.bc == true;
         return item;
      }
      
      public function toObject() : Object
      {
         var loc:Object = {
            "x":x,
            "y":y,
            "z":z
         };
         var o:Object = {
            "id":id,
            "className":className != null ? className : "",
            "name":name != null ? name : "",
            "location":loc,
            "rotation":rotation
         };
         if(state != null && state.length > 0)
         {
            o.state = state;
         }
         if(bc)
         {
            o.bc = true;
         }
         return o;
      }
   }
}
