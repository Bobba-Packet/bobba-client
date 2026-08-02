package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.components.IWidgetWindowController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.habbo.window.widgets.IIlluminaInputHandler;
   import com.sulake.habbo.window.widgets.IIlluminaInputWidget;
   import flash.geom.Rectangle;
   
   public class BobbaGroupInviteEditor implements IIlluminaInputHandler
   {
      
      private static const MODE_INVITE:int = 0;
      
      private static const MODE_CREATE:int = 1;
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_invite";
      
      private static const INVITE_HELP:String = "Convide seu amigo para o grupo!\nApenas habbos com o Bobba Client conseguem utilizar o chat em grupo. Convide seu amigo para o mundo Bobba.";
      
      private static const CREATE_HELP:String = "Escolha um nome para o novo chat em grupo.";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _groupId:String = "";
      
      private var _mode:int = MODE_INVITE;
      
      public function BobbaGroupInviteEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
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
               applyMode();
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
      
      public function setGroup(groupId:String) : void
      {
         _mode = MODE_INVITE;
         _groupId = groupId != null ? groupId : "";
         applyMode();
      }
      
      public function setModeCreate() : void
      {
         _mode = MODE_CREATE;
         _groupId = "";
         applyMode();
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
         _controller = null;
      }
      
      public function onInput(widget:IWidgetWindowController, message:String) : void
      {
         submit(message);
      }
      
      private function createWindow() : void
      {
         var input:IIlluminaInputWidget = null;
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"user_create") as IFrameController;
            if(_window == null)
            {
               return;
            }
            _window.procedure = windowProcedure;
            input = IIlluminaInputWidget(IWidgetWindowController(_window.findChildByName("input_widget")).widget);
            input.submitHandler = this;
            input.multiline = false;
            input.maxChars = 64;
            applyMode();
            _window.center();
            _window.visible = true;
            _window.activate();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
         }
      }
      
      private function applyMode() : void
      {
         var input:IIlluminaInputWidget = null;
         if(_window == null)
         {
            return;
         }
         try
         {
            input = IIlluminaInputWidget(IWidgetWindowController(_window.findChildByName("input_widget")).widget);
            if(_mode == MODE_CREATE)
            {
               _window.caption = "Criar chat em grupo";
               setHelpText(CREATE_HELP);
               if(_window.findChildByName("create_button") != null)
               {
                  _window.findChildByName("create_button").caption = "Criar";
               }
               if(_window.findChildByName("cancel_link") != null)
               {
                  _window.findChildByName("cancel_link").caption = "Cancelar";
               }
               input.emptyMessage = "Nome do grupo";
               input.message = "";
            }
            else
            {
               _window.caption = "Adicionar ao grupo";
               setHelpText(INVITE_HELP);
               if(_window.findChildByName("create_button") != null)
               {
                  _window.findChildByName("create_button").caption = "Adicionar";
               }
               if(_window.findChildByName("cancel_link") != null)
               {
                  _window.findChildByName("cancel_link").caption = "Cancelar";
               }
               input.emptyMessage = "Apelido do habbo";
               input.message = "";
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function setHelpText(value:String) : void
      {
         var list:IItemListWindow = null;
         var help:IWindowModel = null;
         try
         {
            list = _window.findChildByName("list") as IItemListWindow;
            if(list != null && list.numListItems > 0)
            {
               help = list.getListItemAt(0);
               if(help != null && help.name != "create_error" && help.name != "input_widget")
               {
                  help.caption = value;
               }
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function submit(raw:String) : void
      {
         var value:String = raw != null ? raw : "";
         while(value.length > 0 && (value.charAt(0) == " " || value.charAt(value.length - 1) == " "))
         {
            if(value.charAt(0) == " ")
            {
               value = value.substring(1);
            }
            else
            {
               value = value.substring(0,value.length - 1);
            }
         }
         if(value.length == 0 || _controller == null)
         {
            return;
         }
         if(_mode == MODE_CREATE)
         {
            _controller.createGroup(value);
         }
         else
         {
            _controller.sendInvite(_groupId,value);
         }
         visible = false;
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         var input:IIlluminaInputWidget = null;
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK")
         {
            if(target.name == "header_button_close" || target.name == "cancel_link")
            {
               visible = false;
               return;
            }
            if(target.name == "create_button")
            {
               try
               {
                  input = IIlluminaInputWidget(IWidgetWindowController(_window.findChildByName("input_widget")).widget);
                  submit(input.message);
               }
               catch(err:Error)
               {
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
