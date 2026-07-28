package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IDisplayObjectWrapperController;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.geom.Rectangle;
   
   public class BobbaHelperEditor
   {
      
      private static const FRAME_COLOR:uint = 0xff000000;
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_helper";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _window:IFrameController;
      
      private var _canvas:IDisplayObjectWrapperController;
      
      private var _view:BobbaHelperView;
      
      public function BobbaHelperEditor(windowManager:HabboWindowManagerComponent)
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
               if(_view != null)
               {
                  _view.refresh();
               }
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
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _canvas = null;
         _windowManager = null;
      }
      
      private function createWindow() : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         var hdr:IWindowModel = null;
         try
         {
            layout = <layout name="bobba_helper" width="390" height="430" version="0.1">
					<window>
						<frame x="0" y="0" width="390" height="430" params="33025" style="1" name="bobba_helper_frame" caption="Bobba Helper" color="0xff000000">
							<children>
								<display_object_wrapper x="0" y="0" width="378" height="394" params="16" style="0" name="bobba_helper_canvas"/>
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
               alertError("buildFromXML did not return a frame");
               return;
            }
            _window.color = FRAME_COLOR;
            _window.margins.left = 6;
            _window.margins.top = 30;
            _window.margins.right = _window.width - 6;
            _window.margins.bottom = _window.height - 6;
            _window.procedure = windowProcedure;
            _window.center();
            _window.setParamFlag(257,false);
            _window.setParamFlag(32768,true);
            hdr = _window.header as IWindowModel;
            if(hdr != null)
            {
               hdr.setParamFlag(257,true);
               hdr.color = FRAME_COLOR;
            }
            _canvas = _window.findChildByName("bobba_helper_canvas") as IDisplayObjectWrapperController;
            if(_canvas == null)
            {
               alertError("bobba_helper_canvas missing in layout");
               return;
            }
            _canvas.x = 0;
            _canvas.y = 0;
            _canvas.width = _window.content.width;
            _canvas.height = _window.content.height;
            _canvas.setParamFlag(257,false);
            _canvas.setParamFlag(32768,false);
            _view = new BobbaHelperView(_windowManager.LilithCustomsInstance);
            _canvas.setDisplayObject(_view);
            _window.visible = true;
            _window.activate();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
            alertError("createWindow: " + e.name + " #" + e.errorID + " " + e.message);
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
            if(rect.isEmpty())
            {
               removeRoomMouseBlockRect();
               return;
            }
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
      
      private function closeFromView() : void
      {
         visible = false;
      }
      
      private function alertError(msg:String) : void
      {
         if(_windowManager != null)
         {
            _windowManager.simpleAlert("Bobba Helper","Error",msg);
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
   }
}
