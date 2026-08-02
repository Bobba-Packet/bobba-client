package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.IStaticBitmapWrapperWindow;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   
   public class BobbaGroupInviteConfirmEditor
   {
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_invite_confirm";
      
      private static const ART_PATH:String = "group-chat.png";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _inviteId:String = "";
      
      private var _artBitmap:IBitmapWrapperController;
      
      private var _artLoader:Loader;
      
      public function BobbaGroupInviteConfirmEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
      }
      
      public function get visible() : Boolean
      {
         return _window != null && Boolean(_window.visible);
      }
      
      public function set visible(value:Boolean) : void
      {
         if(value)
         {
            if(_window == null)
            {
               createWindow();
            }
            else
            {
               _window.visible = true;
               _window.activate();
               updateRoomMouseBlockRect();
            }
         }
         else if(_window != null)
         {
            _window.visible = false;
            removeRoomMouseBlockRect();
         }
      }
      
      public function setInvite(inviteId:String, groupId:String, groupName:String, fromNickname:String) : void
      {
         _inviteId = inviteId != null ? inviteId : "";
         if(_window == null)
         {
            createWindow();
         }
         if(_window == null)
         {
            return;
         }
         try
         {
            _window.caption = "Convite de grupo";
            if(_window.findChildByName("request_title") != null)
            {
               _window.findChildByName("request_title").caption = "Entrar no chat em grupo?";
            }
            if(_window.findChildByName("request_type") != null)
            {
               _window.findChildByName("request_type").caption = "De " + fromNickname;
            }
            if(_window.findChildByName("request_description") != null)
            {
               _window.findChildByName("request_description").caption = fromNickname + " convidou você para \"" + groupName + "\". Aceite para entrar.";
            }
            if(_window.findChildByName("skip_link") != null)
            {
               _window.findChildByName("skip_link").caption = "Recusar";
            }
            if(_window.findChildByName("accept_button") != null)
            {
               _window.findChildByName("accept_button").caption = "Aceitar";
            }
            if(_window.findChildByName("countdown") != null)
            {
               _window.findChildByName("countdown").visible = false;
               if(_window.findChildByName("countdown").parent != null)
               {
                  _window.findChildByName("countdown").parent.visible = false;
               }
            }
            applyGroupChatArt();
         }
         catch(err:Error)
         {
         }
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         disposeArtLoader();
         if(_artBitmap != null)
         {
            _artBitmap.dispose();
            _artBitmap = null;
         }
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
         _controller = null;
      }
      
      private function createWindow() : void
      {
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"guide_accept") as IFrameController;
            if(_window == null)
            {
               return;
            }
            _window.procedure = windowProcedure;
            applyGroupChatArt();
            _window.center();
            _window.visible = true;
            _window.activate();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
         }
      }
      
      private function applyGroupChatArt() : void
      {
         var i:int = 0;
         var child:IWindowModel = null;
         var stock:IStaticBitmapWrapperWindow = null;
         var layout:XML = null;
         var built:IWindowModel = null;
         if(_window == null || _windowManager == null)
         {
            return;
         }
         try
         {
            for(i = 0; i < _window.numChildren; i++)
            {
               child = _window.getChildAt(i);
               stock = child as IStaticBitmapWrapperWindow;
               if(stock != null && stock.assetUri != null && stock.assetUri.indexOf("guide_accept") >= 0)
               {
                  stock.visible = false;
                  if(_artBitmap == null)
                  {
                     layout = <layout name="bobba_group_invite_art" width="70" height="80" version="0.1">
                           <window>
                              <bitmap x="0" y="0" width="70" height="80" params="16" style="100" name="bobba_group_invite_art">
                                 <variables>
                                    <var key="pivot_point" value="bottom center" type="String"/>
                                    <var key="stretched_x" value="false" type="Boolean"/>
                                    <var key="stretched_y" value="false" type="Boolean"/>
                                    <var key="fit_size_to_contents" value="true" type="Boolean"/>
                                 </variables>
                              </bitmap>
                           </window>
                        </layout>;
                     built = _windowManager.buildFromXML(layout,1);
                     _artBitmap = built as IBitmapWrapperController;
                     if(_artBitmap == null && built != null)
                     {
                        _artBitmap = built.findChildByName("bobba_group_invite_art") as IBitmapWrapperController;
                     }
                     if(_artBitmap != null)
                     {
                        _artBitmap.x = stock.x;
                        _artBitmap.y = stock.y;
                        _window.addChild(_artBitmap);
                     }
                  }
                  loadGroupChatArt();
                  return;
               }
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] invite art failed",err.message);
         }
      }
      
      private function loadGroupChatArt() : void
      {
         var url:String = null;
         disposeArtLoader();
         try
         {
            url = BobbaPack.resolveUrl(ART_PATH);
            _artLoader = new Loader();
            _artLoader.contentLoaderInfo.addEventListener("complete",onGroupChatArtLoaded);
            _artLoader.contentLoaderInfo.addEventListener("ioError",onGroupChatArtError);
            _artLoader.load(new URLRequest(url));
         }
         catch(err:Error)
         {
         }
      }
      
      private function onGroupChatArtLoaded(evt:Event) : void
      {
         var bmp:Bitmap = null;
         var data:BitmapData = null;
         try
         {
            if(_artLoader == null || _artBitmap == null)
            {
               return;
            }
            bmp = _artLoader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            data = bmp.bitmapData.clone();
            _artBitmap.bitmap = data;
            _artBitmap.visible = true;
         }
         catch(err:Error)
         {
         }
         disposeArtLoader();
      }
      
      private function onGroupChatArtError(evt:Event) : void
      {
         Logger.log("[BobbaGroupChat] invite art load error");
         disposeArtLoader();
      }
      
      private function disposeArtLoader() : void
      {
         if(_artLoader != null)
         {
            try
            {
               _artLoader.contentLoaderInfo.removeEventListener("complete",onGroupChatArtLoaded);
               _artLoader.contentLoaderInfo.removeEventListener("ioError",onGroupChatArtError);
               _artLoader.unload();
            }
            catch(err:Error)
            {
            }
            _artLoader = null;
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK")
         {
            if(target.name == "header_button_close" || target.name == "skip_link")
            {
               if(_controller != null && target.name == "skip_link")
               {
                  _controller.respondInvite(_inviteId,false);
               }
               visible = false;
               return;
            }
            if(target.name == "accept_button")
            {
               if(_controller != null)
               {
                  _controller.respondInvite(_inviteId,true);
               }
               return;
            }
         }
         if(event.type == "WE_RELOCATED" || event.type == "WE_RESIZED" || event.type == "WME_UP")
         {
            updateRoomMouseBlockRect();
         }
      }
      
      private function updateRoomMouseBlockRect() : void
      {
         var rect:Rectangle = null;
         try
         {
            if(_window == null || !_window.visible || _windowManager == null || _windowManager.roomEngine == null)
            {
               removeRoomMouseBlockRect();
               return;
            }
            rect = new Rectangle();
            _window.getGlobalRectangle(rect);
            _windowManager.roomEngine.setMouseEventsDisabledRect(MOUSE_BLOCK_KEY,rect);
         }
         catch(errBlock:Error)
         {
         }
      }
      
      private function removeRoomMouseBlockRect() : void
      {
         try
         {
            if(_windowManager != null && _windowManager.roomEngine != null)
            {
               _windowManager.roomEngine.removeMouseEventsDisabledRect(MOUSE_BLOCK_KEY);
            }
         }
         catch(errRemove:Error)
         {
         }
      }
   }
}
