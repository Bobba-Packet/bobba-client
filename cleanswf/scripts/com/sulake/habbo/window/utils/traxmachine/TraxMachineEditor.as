package com.sulake.habbo.window.utils.traxmachine
{
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IDisplayObjectWrapperController;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.geom.Rectangle;
   
   public class TraxMachineEditor
   {
      
      private static const MOUSE_BLOCK_KEY:String = "traxmachine";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _window:IFrameController;
      
      private var _canvas:IDisplayObjectWrapperController;
      
      private var _assets:TraxMachineAssets;
      
      private var _catalog:TraxMachineCatalog;
      
      private var _player:TraxMachinePlayer;
      
      private var _view:TraxMachineView;
      
      public function TraxMachineEditor(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
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
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         if(_view != null)
         {
            _view.dispose();
            _view = null;
         }
         if(_player != null)
         {
            _player.dispose();
            _player = null;
         }
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _canvas = null;
         _assets = null;
         _catalog = null;
         _windowManager = null;
      }
      
      private function createWindow() : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         var hdr:IWindowModel = null;
         try
         {
            // Canvas must sit at (0,0) inside frame _CONTENT.
            // Style-1 content is already inset by margin_left/right (~6px).
            // Using x="6" + full content width expands _CONTENT past the chrome
            // and eats the right margin (visible as right-edge overflow).
            layout = <layout name="traxmachine" width="589" height="347" version="0.1">
					<window>
						<frame x="0" y="0" width="589" height="347" params="33025" style="1" name="traxmachine_frame" caption="Trax Editor" color="0xff587580">
							<children>
								<display_object_wrapper x="0" y="0" width="577" height="311" params="16" style="0" name="trax_canvas"/>
							</children>
							<variables>
								<var key="margin_left" value="6" type="int"/>
								<var key="margin_top" value="30" type="int"/>
								<var key="margin_right" value="6" type="int"/>
								<var key="margin_bottom" value="6" type="int"/>
							</variables>
						</frame>
					</window>
				</layout>;
            built = _windowManager.buildFromXML(layout,1);
            _window = built as IFrameController;
            if(_window == null)
            {
               alertError("buildFromXML did not return a frame (got " + (built != null ? built.toString() : "null") + ")");
               return;
            }
            // Lilith recolors frames on build; force Trax chrome after that.
            _window.color = 0xff587580;
            // Re-assert classic content insets so child size cannot expand past chrome.
            _window.margins.left = 6;
            _window.margins.top = 30;
            _window.margins.right = _window.width - 6;
            _window.margins.bottom = _window.height - 6;
            _window.procedure = windowProcedure;
            _window.center();
            // Only the Habbo title bar should start window drag.
            _window.setParamFlag(257,false);
            _window.setParamFlag(32768,true);
            hdr = _window.header as IWindowModel;
            if(hdr != null)
            {
               hdr.setParamFlag(257,true);
               hdr.color = 0xff587580;
            }
            _canvas = _window.findChildByName("trax_canvas") as IDisplayObjectWrapperController;
            if(_canvas == null)
            {
               alertError("trax_canvas display_object_wrapper missing in layout");
               return;
            }
            _canvas.x = 0;
            _canvas.y = 0;
            _canvas.width = _window.content.width;
            _canvas.height = _window.content.height;
            _canvas.setParamFlag(257,false);
            _canvas.setParamFlag(32768,false);
            _assets = new TraxMachineAssets();
            _catalog = new TraxMachineCatalog();
            if(!_catalog.loadFromPack())
            {
               alertError("Assets pack missing.\n" + _catalog.lastError + "\nPut folder traxmachine/ next to HabboAir.swf (or in local_include/traxmachine/).");
            }
            _player = new TraxMachinePlayer(_assets,_catalog);
            _assets.loadAll(onAssetsReady);
         }
         catch(e:Error)
         {
            alertError("createWindow: " + e.name + " #" + e.errorID + " " + e.message);
         }
      }
      
      private function onAssetsReady() : void
      {
         try
         {
            if(_window == null || _canvas == null)
            {
               return;
            }
            _view = new TraxMachineView(_assets,_catalog,_player);
            _view.cancelHostDrag = cancelHostDrag;
            _canvas.setDisplayObject(_view);
            _window.visible = true;
            _window.activate();
            updateRoomMouseBlockRect();
            if(_assets != null && !_assets.hasBase)
            {
               alertError("Images folder not found at:\n" + (_assets != null ? _assets.basePath : "?"));
            }
         }
         catch(e:Error)
         {
            alertError("onAssetsReady: " + e.name + " #" + e.errorID + " " + e.message);
         }
      }
      
      private function cancelHostDrag() : void
      {
         try
         {
            if(_window == null)
            {
               return;
            }
            _window.context.getWindowServices().getMouseDraggingService().end(_window);
         }
         catch(e:Error)
         {
         }
      }
      
      private function closeFromView() : void
      {
         if(_player != null)
         {
            _player.stop();
         }
         visible = false;
      }
      
      private function alertError(msg:String) : void
      {
         if(_windowManager != null)
         {
            _windowManager.simpleAlert("Trax Machine","Error",msg);
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK" && target.name == "header_button_close")
         {
            closeFromView();
            return;
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
