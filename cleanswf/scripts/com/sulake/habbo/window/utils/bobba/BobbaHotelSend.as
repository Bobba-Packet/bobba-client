package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.communication.messages.IMessageComposer;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   
   public class BobbaHotelSend
   {
      
      public function BobbaHotelSend()
      {
         super();
      }
      
      public static function send(windowManager:HabboWindowManagerComponent, composer:IMessageComposer) : Boolean
      {
         if(windowManager == null || composer == null)
         {
            return false;
         }
         try
         {
            if(windowManager.roomEngine != null && windowManager.roomEngine.connection != null)
            {
               windowManager.roomEngine.connection.send(composer);
               return true;
            }
         }
         catch(eRoom:Error)
         {
            Logger.log("[BobbaPresets] roomEngine send failed",eRoom.message);
         }
         try
         {
            if(windowManager.communication != null && windowManager.communication.connection != null)
            {
               windowManager.communication.connection.send(composer);
               return true;
            }
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] send failed",e.message);
         }
         return false;
      }
   }
}
