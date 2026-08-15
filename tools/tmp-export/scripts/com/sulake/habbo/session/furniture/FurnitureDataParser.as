package com.sulake.habbo.session.furniture
{
   import com.sulake.core.Core;
   import com.sulake.core.assets.AssetLibrary;
   import com.sulake.core.assets.AssetLoaderStruct;
   import com.sulake.core.assets.ISoundAsset;
   import com.sulake.core.assets.loaders.AssetLoaderEvent;
   import com.sulake.core.localization.ICoreLocalizationManager;
   import com.sulake.core.runtime.events.EventDispatcherWrapper;
   import com.sulake.core.utils.Map;
   import com.sulake.habbo.utils.HabboWebTools;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class FurnitureDataParser extends EventDispatcherWrapper
   {
      
      public static const READY:String = "FDP_furniture_data_ready";
      
      private static const MAX_DOWNLOAD_RETRIES:int = 2;
      
      private var _floorItems:Map;
      
      private var _wallItems:Map;
      
      private var UnknownVarFromFurnitureDataParser_Map_1:Map;
      
      private var UnknownVarFromFurnitureDataParser_Map_2:Map;
      
      private var _localization:ICoreLocalizationManager;
      
      private var UnknownVarFromFurnitureDataParser_AssetLibrary_1:AssetLibrary;
      
      private var UnknownVarFromFurnitureDataParser_Boolean_1:Boolean;
      
      private var UnknownVarFromFurnitureDataParser_String_1:String;
      
      private var _downloadRetriesLeft:int;
      
      public function FurnitureDataParser(param1:Map, param2:Map, param3:Map, param4:Map, param5:ICoreLocalizationManager, param6:Boolean = true)
      {
         super();
         _floorItems = param1;
         _wallItems = param2;
         UnknownVarFromFurnitureDataParser_Map_1 = param3;
         UnknownVarFromFurnitureDataParser_Map_2 = param4;
         _localization = param5;
         UnknownVarFromFurnitureDataParser_AssetLibrary_1 = new AssetLibrary("FurniDataParserAssetLib");
         UnknownVarFromFurnitureDataParser_Boolean_1 = param6;
      }
      
      private static function appendRetryParam(param1:String, param2:int) : String
      {
         if(param1.indexOf("?") > 0)
         {
            return param1 + "&retry=" + param2;
         }
         return param1 + "?retry=" + param2;
      }
      
      private static function removePatternFrom(param1:Array, param2:Object) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] == param2)
            {
               param1.splice(_loc3_,1);
               _loc3_--;
            }
            _loc3_++;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(UnknownVarFromFurnitureDataParser_AssetLibrary_1)
         {
            UnknownVarFromFurnitureDataParser_AssetLibrary_1.dispose();
            UnknownVarFromFurnitureDataParser_AssetLibrary_1 = null;
         }
         _localization = null;
         _floorItems = null;
         _wallItems = null;
         UnknownVarFromFurnitureDataParser_Map_1 = null;
         UnknownVarFromFurnitureDataParser_Map_2 = null;
      }
      
      public function loadData(param1:String) : void
      {
         UnknownVarFromFurnitureDataParser_String_1 = param1;
         _downloadRetriesLeft = 2;
         requestData(param1);
      }
      
      private function requestData(param1:String) : void
      {
         var _loc2_:ISoundAsset = null;
         var _loc4_:ISoundAsset = UnknownVarFromFurnitureDataParser_AssetLibrary_1.getAssetByName("furnidata");
         if(_loc4_ != null)
         {
            _loc2_ = UnknownVarFromFurnitureDataParser_AssetLibrary_1.removeAsset(_loc4_);
            if(_loc2_ != null)
            {
               _loc2_.dispose();
            }
         }
         var _loc3_:AssetLoaderStruct = UnknownVarFromFurnitureDataParser_AssetLibrary_1.loadAssetFromFile("furnidata",new URLRequest(param1),"text/plain");
         _loc3_.addEventListener("AssetLoaderEventComplete",parseFurnitureData);
         _loc3_.addEventListener("AssetLoaderEventError",furnitureDataError);
      }
      
      private function removeLoaderListeners(param1:AssetLoaderStruct) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.removeEventListener("AssetLoaderEventComplete",parseFurnitureData);
         param1.removeEventListener("AssetLoaderEventError",furnitureDataError);
      }
      
      private function retryLoadIfPossible() : Boolean
      {
         if(UnknownVarFromFurnitureDataParser_String_1 == null || _downloadRetriesLeft <= 0)
         {
            return false;
         }
         var _loc1_:String = appendRetryParam(UnknownVarFromFurnitureDataParser_String_1,_downloadRetriesLeft);
         _downloadRetriesLeft--;
         requestData(_loc1_);
         return true;
      }
      
      private function onMalformedData(param1:int) : void
      {
         if(retryLoadIfPossible())
         {
            return;
         }
         HabboWebTools.logEventLog("furnituredata malformed data " + param1);
         Core.error("XML furni data was malformed",UnknownVarFromFurnitureDataParser_Boolean_1,12);
      }
      
      private function parseFurnitureData(param1:AssetLoaderEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:ByteArray = null;
         var _loc4_:AssetLoaderStruct = param1.target as AssetLoaderStruct;
         removeLoaderListeners(_loc4_);
         if(_loc4_ == null)
         {
            onMalformedData(param1.status);
            return;
         }
         if(_loc4_.assetLoader == null || _loc4_.assetLoader.content == null)
         {
            onMalformedData(param1.status);
            return;
         }
         if(_loc4_.assetLoader.content is ByteArray)
         {
            _loc3_ = _loc4_.assetLoader.content as ByteArray;
            _loc3_.position = 0;
            _loc2_ = _loc3_.readUTFBytes(_loc3_.length);
         }
         else
         {
            _loc2_ = _loc4_.assetLoader.content as String;
         }
         if(_loc2_ == null || _loc2_.length == 0)
         {
            onMalformedData(param1.status);
            return;
         }
         var _loc5_:String = _loc2_.replace(/^\s+/,"");
         if(_loc5_.charAt(0) == "<")
         {
            if(!parseXmlFormat(_loc5_))
            {
               onMalformedData(param1.status);
            }
         }
         else
         {
            parseLingoFormat(_loc2_);
         }
      }
      
      private function parseXmlFormat(param1:String) : Boolean
      {
         var _loc5_:XML = null;
         var _loc2_:XMLList = null;
         var _loc3_:* = null;
         var _loc4_:FurnitureData = null;
         try
         {
            _loc5_ = new XML(param1);
         }
         catch(e:Error)
         {
            return false;
         }
         if(_loc5_ == null)
         {
            return false;
         }
         _loc2_ = _loc5_.roomitemtypes;
         for each(_loc3_ in _loc2_.furnitype)
         {
            _loc4_ = parseFloorItem(_loc3_);
            storeItem(_loc4_);
            registerFurnitureLocalization(_loc4_);
         }
         _loc2_ = _loc5_.wallitemtypes;
         for each(_loc3_ in _loc2_.furnitype)
         {
            _loc4_ = parseWallItem(_loc3_);
            storeItem(_loc4_);
            registerFurnitureLocalization(_loc4_);
         }
         dispatchEvent(new Event("FDP_furniture_data_ready"));
         return true;
      }
      
      private function parseFloorItem(param1:XML) : FurnitureData
      {
         var _loc6_:String = null;
         var _loc11_:int = parseInt(param1.@id);
         var _loc15_:Array = [];
         for each(var _loc9_ in param1.partcolors.color)
         {
            _loc6_ = _loc9_;
            if(_loc6_.charAt(0) == "#")
            {
               _loc6_ = _loc6_.replace("#","");
               _loc15_.push(parseInt(_loc6_,16));
            }
            else
            {
               _loc15_.push(-parseInt(_loc6_));
            }
         }
         var _loc3_:String = param1.@classname;
         var _loc12_:Array = _loc3_.split("*");
         var _loc7_:String = _loc12_[0];
         var _loc2_:int = _loc12_.length > 1 ? parseInt(_loc12_[1]) : 0;
         var _loc13_:* = _loc12_.length > 1;
         var _loc14_:int = int(param1.specialtype);
         var _loc4_:String = param1.category.length() > 0 ? String(param1.category) : String(param1.@category);
         var _loc8_:* = param1.canputstuffon == "1";
         var _loc16_:Number = Number(param1.height);
         var _loc5_:Boolean = param1.recyclable.length() == 0 || param1.recyclable == "1";
         return new FurnitureData("s",_loc11_,_loc3_,_loc7_,param1.name,"",param1.revision,param1.xdim,param1.ydim,0,_loc15_,_loc13_,_loc2_,param1.adurl,param1.offerid,param1.buyout == "1",param1.rentofferid,param1.rentbuyout == "1",param1.bc == "1",param1.customparams,_loc14_,_loc4_,param1.canstandon == "1",param1.cansiton == "1",param1.canlayon == "1",_loc8_,_loc16_,param1.excludeddynamic == "1",param1.furniline,param1.bcofferid,param1.tradeable == "1",_loc5_);
      }
      
      private function parseWallItem(param1:XML) : FurnitureData
      {
         var _loc4_:int = parseInt(param1.@id);
         var _loc2_:Boolean = param1.recyclable.length() == 0 || param1.recyclable == "1";
         return new FurnitureData("i",_loc4_,param1.@classname,param1.@classname,param1.name,"",param1.revision,0,0,0,null,false,0,param1.adurl,param1.offerid,param1.buyout == "1",param1.rentofferid,param1.rentbuyout == "1",param1.bc == "1",null,param1.specialtype,param1.category.length() > 0 ? String(param1.category) : String(param1.@category),false,false,false,false,0,param1.excludeddynamic == "1",param1.furniline,param1.bcofferid,param1.tradeable == "1",_loc2_);
      }
      
      private function parseLingoFormat(param1:String) : void
      {
         var _loc5_:Array = null;
         var _loc29_:Array = null;
         var _loc9_:String = null;
         var _loc19_:int = 0;
         var _loc3_:String = null;
         var _loc37_:Array = null;
         var _loc8_:String = null;
         var _loc23_:int = 0;
         var _loc38_:* = false;
         var _loc30_:int = 0;
         var _loc22_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc41_:Array = null;
         var _loc32_:Array = null;
         var _loc39_:int = 0;
         var _loc26_:String = null;
         var _loc10_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc33_:int = 0;
         var _loc20_:* = false;
         var _loc34_:int = 0;
         var _loc2_:* = false;
         var _loc24_:String = null;
         var _loc40_:int = 0;
         var _loc31_:* = false;
         var _loc13_:* = false;
         var _loc25_:* = false;
         var _loc11_:* = false;
         var _loc36_:* = false;
         var _loc4_:* = false;
         var _loc14_:FurnitureData = null;
         var _loc15_:RegExp = /\n\r{1,}|\n{1,}|\r{1,}/gm;
         var _loc12_:RegExp = /^\s+|\s+$/g;
         var _loc35_:RegExp = /\[+?((.)*?)\]/g;
         var _loc28_:Array = param1.split(_loc15_);
         var _loc21_:int = 0;
         for each(var _loc18_ in _loc28_)
         {
            _loc5_ = _loc18_.match(_loc35_);
            for each(var _loc27_ in _loc5_)
            {
               _loc27_ = _loc27_.replace(/\[{1,}/gm,"");
               _loc27_ = _loc27_.replace(/\]{1,}/gm,"");
               _loc29_ = _loc27_.split("\"");
               removePatternFrom(_loc29_,", ");
               removePatternFrom(_loc29_,",");
               _loc29_.splice(0,1);
               _loc29_.splice(_loc29_.length - 1,1);
               if(_loc29_.length < 18)
               {
                  Core.error("Lingo furni data was malformed: " + param1,true,12);
                  return;
               }
               _loc9_ = _loc29_[0];
               _loc19_ = parseInt(_loc29_[1]);
               _loc3_ = String(_loc29_[2]);
               _loc37_ = _loc3_.split("*");
               _loc8_ = _loc37_[0];
               _loc23_ = _loc37_.length > 1 ? parseInt(_loc37_[1]) : 0;
               _loc38_ = _loc37_.length > 1;
               _loc30_ = parseInt(_loc29_[3]);
               _loc22_ = parseInt(_loc29_[4]);
               _loc16_ = parseInt(_loc29_[5]);
               _loc17_ = parseInt(_loc29_[6]);
               _loc41_ = [];
               _loc32_ = _loc29_[7].split(",");
               _loc39_ = 0;
               while(_loc39_ < _loc32_.length)
               {
                  _loc26_ = _loc32_[_loc39_];
                  if(_loc26_.charAt(0) == "#")
                  {
                     _loc26_ = _loc26_.replace("#","");
                     _loc41_.push(parseInt(_loc26_,16));
                  }
                  else
                  {
                     _loc41_.push(-parseInt(_loc26_));
                  }
                  _loc39_++;
               }
               _loc10_ = _loc29_[8];
               _loc6_ = _loc29_[9];
               _loc7_ = _loc29_[10];
               _loc33_ = parseInt(_loc29_[11]);
               _loc20_ = _loc29_[12] == "true";
               _loc34_ = parseInt(_loc29_[13]);
               _loc2_ = _loc29_[14] == "true";
               _loc24_ = _loc29_[15];
               _loc40_ = parseInt(_loc29_[16]);
               _loc31_ = _loc29_[17] == "true";
               _loc36_ = false;
               _loc4_ = _loc9_ == "i";
               if(_loc4_)
               {
                  _loc13_ = false;
                  _loc25_ = false;
                  _loc11_ = false;
                  if(_loc29_.length >= 19)
                  {
                     _loc36_ = _loc29_[18] == "1";
                  }
               }
               else
               {
                  _loc13_ = _loc29_[18] == "1";
                  _loc25_ = _loc29_[19] == "1";
                  _loc11_ = _loc29_[20] == "1";
                  if(_loc29_.length >= 22)
                  {
                     _loc36_ = _loc29_[21] == "1";
                  }
               }
               _loc14_ = new FurnitureData(_loc9_,_loc19_,_loc3_,_loc8_,_loc10_,"",_loc30_,_loc22_,_loc16_,_loc17_,_loc41_,_loc38_,_loc23_,_loc7_,_loc33_,_loc20_,_loc34_,_loc2_,_loc31_,_loc24_,_loc40_,"",_loc13_,_loc25_,_loc11_,false,_loc17_,_loc36_,"",-1,true,true);
               storeItem(_loc14_);
               registerFurnitureLocalization(_loc14_);
            }
            _loc21_++;
         }
         dispatchEvent(new Event("FDP_furniture_data_ready"));
      }
      
      private function storeItem(param1:FurnitureData) : void
      {
         var _loc3_:Map = null;
         if(param1.type == "s")
         {
            _floorItems.add(param1.id,param1);
            _loc3_ = UnknownVarFromFurnitureDataParser_Map_1;
         }
         else if(param1.type == "i")
         {
            _wallItems.add(param1.id,param1);
            _loc3_ = UnknownVarFromFurnitureDataParser_Map_2;
         }
         var _loc2_:Array = _loc3_[param1.className];
         if(_loc2_ == null)
         {
            _loc2_ = [];
            _loc3_.add(param1.className,_loc2_);
         }
         _loc2_[param1.colourIndex] = param1.id;
      }
      
      private function furnitureDataError(param1:AssetLoaderEvent) : void
      {
         var _loc2_:AssetLoaderStruct = param1.target as AssetLoaderStruct;
         removeLoaderListeners(_loc2_);
         if(retryLoadIfPossible())
         {
            return;
         }
         HabboWebTools.logEventLog("furnituredata download error " + param1.status);
         Core.error("Could not download furnidata definition",UnknownVarFromFurnitureDataParser_Boolean_1,12);
      }
      
      private function registerFurnitureLocalization(param1:FurnitureData) : void
      {
         if(_localization != null)
         {
            if(param1.type == "s")
            {
               _localization.updateLocalization("roomItem.name." + param1.id,param1.localizedName);
               _localization.updateLocalization("roomItem.desc." + param1.id,param1.description);
            }
            else if(param1.type == "i")
            {
               _localization.updateLocalization("wallItem.name." + param1.id,param1.localizedName);
               _localization.updateLocalization("wallItem.desc." + param1.id,param1.description);
            }
         }
      }
   }
}

