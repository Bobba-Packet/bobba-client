package com.sulake.habbo.window.utils.bobba
{
   public class BobbaLegacyPriceData
   {
      
      public var success:Boolean = false;
      
      public var classname:String = "";
      
      public var hotel:String = "";
      
      public var name:String = "";
      
      public var lastPrice:int = 0;
      
      public var lastAverage:int = 0;
      
      public var lastQuantity:int = 0;
      
      public var category:String = "";
      
      public var badgeCode:String = "";
      
      public var badgeCountLocal:int = 0;
      
      public var releasePrice:int = 0;
      
      public var historyPrices:Array;
      
      public var historyAverages:Array;
      
      public var historyQuantities:Array;
      
      public var hotels:Array;
      
      public function BobbaLegacyPriceData()
      {
         super();
         historyPrices = [];
         historyAverages = [];
         historyQuantities = [];
         hotels = [];
      }
      
      public function get historyLength() : int
      {
         return historyPrices != null ? int(historyPrices.length) : 0;
      }
      
      public function buildDayOffsets(periodDays:int = 30) : Array
      {
         var offsets:Array = [];
         var len:int = historyLength;
         var span:int = periodDays > 0 ? periodDays : 30;
         var i:int = 0;
         if(len <= 1)
         {
            if(len == 1)
            {
               offsets.push(0);
            }
            return offsets;
         }
         for(i = 0; i < len; i++)
         {
            offsets.push(int(Math.round(-span * (len - 1 - i) / (len - 1))));
         }
         return offsets;
      }
      
      public function hotelsSummary(currentHotel:String = "") : String
      {
         var parts:Array = [];
         var row:Object = null;
         var label:String = null;
         for each(row in hotels)
         {
            if(row == null)
            {
               continue;
            }
            label = String(row.hotel).toUpperCase();
            if(currentHotel != null && currentHotel.length > 0 && String(row.hotel).toLowerCase() == currentHotel.toLowerCase())
            {
               label = "[" + label + "]";
            }
            parts.push(label + ":" + int(row.price));
         }
         return parts.join("  ");
      }
   }
}
