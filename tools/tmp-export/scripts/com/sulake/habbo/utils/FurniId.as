package com.sulake.habbo.utils
{
   public class FurniId
   {
      
      private static const MAX_CLUB_FURNI_ID:int = 2147483647;
      
      private static const UnknownConstFromFurniId_Int_1:int = 2147418112;
      
      private static const MAX_TEMP_FURNI_ID:int = 2147418111;
      
      private static const UnknownConstFromFurniId_Int_2:int = 2147401728;
      
      private static const MAX_NORMAL_FURNI_ID:int = 2147401727;
      
      public function FurniId()
      {
         super();
      }
      
      public static function isBuilderClubId(param1:int) : Boolean
      {
         return param1 >= 2147418112 && param1 <= 2147483647;
      }
      
      public static function isTempId(param1:int) : Boolean
      {
         return param1 >= 2147401728 && param1 <= 2147418111;
      }
      
      public static function isNormalId(param1:int) : Boolean
      {
         return param1 <= 2147401727;
      }
   }
}

