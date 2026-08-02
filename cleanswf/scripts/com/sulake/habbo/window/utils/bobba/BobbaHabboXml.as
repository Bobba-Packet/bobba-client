package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.utils.ByteArray;
   
   public class BobbaHabboXml
   {
      
      public function BobbaHabboXml()
      {
         super();
      }
      
      public static function getHelp(windowManager:HabboWindowManagerComponent) : *
      {
         var help:* = null;
         try
         {
            if(windowManager != null && windowManager.roomEngine != null && windowManager.roomEngine.toolbar != null && windowManager.roomEngine.toolbar.roomUI != null)
            {
               help = windowManager.roomEngine.toolbar.roomUI.habboHelp;
            }
         }
         catch(err:Error)
         {
            help = null;
         }
         return help;
      }
      
      public static function getXmlWindow(windowManager:HabboWindowManagerComponent, name:String, layer:uint = 1) : *
      {
         var help:* = null;
         var built:* = null;
         var assetClass:Class = null;
         var bytes:ByteArray = null;
         help = getHelp(windowManager);
         if(help != null)
         {
            try
            {
               built = help.getXmlWindow(name,layer);
               if(built != null)
               {
                  return built;
               }
            }
            catch(errHelp:Error)
            {
            }
         }
         if(windowManager == null || name == null || name.length == 0)
         {
            return null;
         }
         try
         {
            assetClass = HabboHelpCom[name + "_xml"] as Class;
            if(assetClass == null)
            {
               return null;
            }
            bytes = new assetClass() as ByteArray;
            if(bytes == null)
            {
               return null;
            }
            bytes.position = 0;
            return windowManager.buildFromXML(XML(bytes.readUTFBytes(bytes.length)),layer);
         }
         catch(errFallback:Error)
         {
            Logger.log("[BobbaHabboXml] load failed",name,errFallback.message);
         }
         return null;
      }
   }
}
