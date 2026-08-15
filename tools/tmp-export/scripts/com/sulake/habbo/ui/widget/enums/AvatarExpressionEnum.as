package com.sulake.habbo.ui.widget.enums
{
   public class AvatarExpressionEnum
   {
      
      public static const NONE:AvatarExpressionEnum = new AvatarExpressionEnum(0);
      
      public static const WAVE:AvatarExpressionEnum = new AvatarExpressionEnum(1);
      
      public static const BLOW:AvatarExpressionEnum = new AvatarExpressionEnum(2);
      
      public static const EXPRESSION_67:AvatarExpressionEnum = new AvatarExpressionEnum(67);
      
      public static const LAUGH:AvatarExpressionEnum = new AvatarExpressionEnum(3);
      
      public static const CRY:AvatarExpressionEnum = new AvatarExpressionEnum(4);
      
      public static const UnknownConstFromAvatarExpressionEnum_AvatarExpressionEnum_1:AvatarExpressionEnum = new AvatarExpressionEnum(5);
      
      public static const JUMP:AvatarExpressionEnum = new AvatarExpressionEnum(6);
      
      public static const RESPECT:AvatarExpressionEnum = new AvatarExpressionEnum(7);
      
      private var _ordinal:int = 0;
      
      public function AvatarExpressionEnum(param1:int)
      {
         super();
         _ordinal = param1;
      }
      
      public function get ordinal() : int
      {
         return _ordinal;
      }
      
      public function equals(param1:AvatarExpressionEnum) : Boolean
      {
         return param1 && param1._ordinal == _ordinal;
      }
   }
}

