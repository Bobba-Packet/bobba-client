package com.sulake.habbo.ui.widget.chatinput
{
   import com.sulake.core.assets.XmlAsset;
   import com.sulake.core.runtime.IComponent_1;
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.core.window.components.IItemGridWindow;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.components.IRegionWindow;
   import com.sulake.core.window.components.ITextFieldWindow;
   import com.sulake.core.window.components.ITextWindow;
   import com.sulake.core.window.components.UnknownICoreWindowComponents6;
   import com.sulake.core.window.components.UnknownICoreWindowComponents8;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.events.WindowKeyboardEvent;
   import com.sulake.core.window.events.WindowMouseEvent;
   import com.sulake.habbo.catalog.habbicons.IHabbiconController;
   import com.sulake.habbo.communication.messages.parser.habbicons.UnknownHabboCommunicationMessagesParserHabbicons2;
   import com.sulake.habbo.communication.messages.parser.habbicons.UnknownHabboCommunicationMessagesParserHabbicons3;
   import com.sulake.habbo.freeflowchat.IHabboFreeFlowChat;
   import com.sulake.habbo.freeflowchat.style.UnknownIHabboFreeflowchatStyle1;
   import com.sulake.habbo.habbicons.assets.HabbiconAssetManager;
   import com.sulake.habbo.inventory.events.HabboUnseenItemsUpdatedEvent;
   import com.sulake.habbo.session.ISessionDataManager;
   import com.sulake.habbo.ui.widget.chatinput.habbiconselector.HabbiconSelector;
   import com.sulake.habbo.ui.widget.chatinput.styleselector.ChatStyleSelector;
   import com.sulake.habbo.ui.widget.messages.RoomWidgetChatTypingMessage;
   import com.sulake.habbo.utils.UnknownHabboUtils1;
   import com.sulake.room.utils.RoomEnterEffect;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
   public class RoomChatInputView
   {
      
      private static const MARGIN_H:int = 12;
      
      private static const TOOLBAR_EXTRA_H:int = 100;
      
      private static const CHAT_HELP_INTERNAL_CLIENT_LINK:String = "habbopages/chat/commands";
      
      private static const UnknownConstFromRoomChatInputView_String_1:String = "habbicons/open";
      
      private static const COMMANDS_MENU_MIN_HEIGHT:int = 91;
      
      private static const COMMANDS_MENU_MAX_HEIGHT:int = 292;
      
      private static const COMMANDS_TOP_BAR_HEIGHT:int = 42;
      
      private static const COMMANDS_BOTTOM_PADDING:int = 6;
      
      private static const COMMANDS_GRID_COLUMNS:int = 5;
      
      private static const COMMANDS_PLACEHOLDER_SLOTS:int = 20;
      
      private static const COMMANDS_SLOT_EMPTY_COLOR:uint = 4281611316;
      
      private static const COMMANDS_CHAT_BAR_POPUP_OFFSET:int = 55;
      
      private static const COMMANDS_SCREEN_LEFT_BORDER:int = 92;
      
      private var _widget:RoomChatInputWidget;
      
      private var _window:IWindowController_1;
      
      private var UnknownVarFromRoomChatInputView_ITextFieldWindow_1:ITextFieldWindow;
      
      private var UnknownVarFromRoomChatInputView_IWindowModel_1:IWindowModel;
      
      private var UnknownVarFromRoomChatInputView_IWindowModel_2:IWindowModel;
      
      private var UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1:UnknownICoreWindowComponents8;
      
      private var UnknownVarFromRoomChatInputView_IRegionWindow_1:IRegionWindow;
      
      private var UnknownVarFromRoomChatInputView_Boolean_1:Boolean = false;
      
      private var UnknownVarFromRoomChatInputView_IWindowController_1_1:IWindowController_1;
      
      private var _chatStyleMenuContainer:IWindowController_1;
      
      private var UnknownVarFromRoomChatInputView_IWindowController_1_2:IWindowController_1;
      
      private var UnknownVarFromRoomChatInputView_IWindowModel_3:IWindowModel;
      
      private var UnknownVarFromRoomChatInputView_IBitmapWrapperController_1:IBitmapWrapperController;
      
      private var UnknownVarFromRoomChatInputView_BitmapData_1:BitmapData;
      
      private var UnknownVarFromRoomChatInputView_Int_1:int;
      
      private var UnknownVarFromRoomChatInputView_IHabbiconController_1:IHabbiconController;
      
      private var UnknownVarFromRoomChatInputView_Boolean_2:Boolean;
      
      private var UnknownVarFromRoomChatInputView_IWindowController_1_3:IWindowController_1;
      
      private var _chatModeIdShout:String;
      
      private var UnknownVarFromRoomChatInputView_String_1:String;
      
      private var UnknownVarFromRoomChatInputView_String_2:String;
      
      private var UnknownVarFromRoomChatInputView_Boolean_3:Boolean = false;
      
      private var UnknownVarFromRoomChatInputView_TextFormat_1:TextFormat;
      
      private var UnknownVarFromRoomChatInputView_Boolean_4:Boolean = false;
      
      private var UnknownVarFromRoomChatInputView_Boolean_5:Boolean = false;
      
      private var UnknownVarFromRoomChatInputView_Timer_1:Timer;
      
      private var UnknownVarFromRoomChatInputView_Timer_2:Timer;
      
      private var UnknownVarFromRoomChatInputView_Timer_3:Timer;
      
      private var UnknownVarFromRoomChatInputView_String_3:String = "";
      
      private var UnknownVarFromRoomChatInputView_Timer_4:Timer;
      
      private var UnknownVarFromRoomChatInputView_Boolean_6:Boolean = false;
      
      private var UnknownVarFromRoomChatInputView_Timer_5:Timer;
      
      private var UnknownVarFromRoomChatInputView_Int_2:int = 0;
      
      private var UnknownVarFromRoomChatInputView_Timer_6:Timer;
      
      private var UnknownVarFromRoomChatInputView_ChatStyleSelector_1:ChatStyleSelector;
      
      private var UnknownVarFromRoomChatInputView_HabbiconSelector_1:HabbiconSelector;
      
      private var _commandsMenuContainer:IWindowController_1;
      
      private var _commandsMenu:UnknownICoreWindowComponents6;
      
      private var _commandsSectionTemplate:IWindowController_1;
      
      private var _commandsSectionList:IItemListWindow;
      
      public function RoomChatInputView(param1:RoomChatInputWidget)
      {
         var _loc3_:IComponent_1 = null;
         var _loc2_:int = 0;
         super();
         _widget = param1;
         UnknownVarFromRoomChatInputView_String_1 = param1.localizations.getLocalization("widgets.chatinput.mode.whisper",":tell");
         _chatModeIdShout = param1.localizations.getLocalization("widgets.chatinput.mode.shout",":shout");
         UnknownVarFromRoomChatInputView_String_2 = param1.localizations.getLocalization("widgets.chatinput.mode.speak",":speak");
         UnknownVarFromRoomChatInputView_Timer_1 = new Timer(1000,1);
         UnknownVarFromRoomChatInputView_Timer_1.addEventListener("timerComplete",onTypingTimerComplete);
         UnknownVarFromRoomChatInputView_Timer_2 = new Timer(10000,1);
         UnknownVarFromRoomChatInputView_Timer_2.addEventListener("timerComplete",onIdleTimerComplete);
         UnknownVarFromRoomChatInputView_Boolean_6 = Boolean(sessionDataManager.isNoob) || Boolean(sessionDataManager.isRealNoob);
         if(UnknownVarFromRoomChatInputView_Boolean_6)
         {
            _loc3_ = param1.handler.container.config;
            if(_loc3_.getProperty("nux.chat.reminder.shown") != "1")
            {
               _loc2_ = int(_loc3_.getInteger("nux.noob.chat.reminder.delay",240));
               UnknownVarFromRoomChatInputView_Timer_3 = new Timer(_loc2_ * 1000,1);
               UnknownVarFromRoomChatInputView_Timer_3.addEventListener("timerComplete",onNuxIdleTimerComplete);
               UnknownVarFromRoomChatInputView_Timer_3.start();
            }
         }
         UnknownVarFromRoomChatInputView_TextFormat_1 = new TextFormat(null,null,10066329,null,true,false);
         createWindow();
      }
      
      private static function isWindowInTree(param1:IWindowModel, param2:IWindowModel) : Boolean
      {
         while(param1 != null)
         {
            if(param1 == param2)
            {
               return true;
            }
            param1 = param1.parent;
         }
         return false;
      }
      
      public function get window() : IWindowController_1
      {
         return _window;
      }
      
      public function dispose() : void
      {
         if(UnknownVarFromRoomChatInputView_Boolean_6)
         {
            widget.windowManager.hideHint();
            widget.windowManager.unregisterHintWindow("nux_chat_reminder");
         }
         if(_widget && _widget.roomUi && _widget.roomUi.inventory && _widget.roomUi.inventory.events)
         {
            _widget.roomUi.inventory.events.removeEventListener("HUIUE_UNSEEN_ITEMS_CHANGED",onUnseenItemsUpdated);
         }
         unregisterHabbiconButtonListeners();
         unregisterHabbiconAssetsListener();
         clearHabbiconButtonSetIcon();
         _widget = null;
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1)
         {
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.removeEventListener("WME_DOWN",windowMouseEventProcessor);
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.removeEventListener("WKE_KEY_DOWN",windowKeyEventProcessor);
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.removeEventListener("WKE_KEY_UP",keyUpHandler);
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.removeEventListener("WE_CHANGE",onInputChanged);
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.removeEventListener("WME_OVER",onInputHoverRegionMouseEvent);
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.removeEventListener("WME_OUT",onInputHoverRegionMouseEvent);
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1 = null;
         }
         UnknownVarFromRoomChatInputView_IWindowModel_1 = null;
         UnknownVarFromRoomChatInputView_IWindowModel_2 = null;
         if(UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1)
         {
            UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.removeEventListener("WME_CLICK",onHelpButtonMouseEvent);
            UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.removeEventListener("WME_OVER",onHelpButtonMouseEvent);
            UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.removeEventListener("WME_OUT",onHelpButtonMouseEvent);
            UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1 = null;
         }
         if(UnknownVarFromRoomChatInputView_IRegionWindow_1)
         {
            UnknownVarFromRoomChatInputView_IRegionWindow_1.removeEventListener("WME_OVER",onInputHoverRegionMouseEvent);
            UnknownVarFromRoomChatInputView_IRegionWindow_1.removeEventListener("WME_OUT",onInputHoverRegionMouseEvent);
            UnknownVarFromRoomChatInputView_IRegionWindow_1 = null;
         }
         if(UnknownVarFromRoomChatInputView_IWindowModel_3)
         {
            UnknownVarFromRoomChatInputView_IWindowModel_3.removeEventListener("WME_CLICK",onHabbiconButtonMouseEvent);
            UnknownVarFromRoomChatInputView_IWindowModel_3 = null;
         }
         UnknownVarFromRoomChatInputView_IBitmapWrapperController_1 = null;
         UnknownVarFromRoomChatInputView_IWindowController_1_3 = null;
         if(UnknownVarFromRoomChatInputView_HabbiconSelector_1)
         {
            UnknownVarFromRoomChatInputView_HabbiconSelector_1.dispose();
            UnknownVarFromRoomChatInputView_HabbiconSelector_1 = null;
         }
         disposeCommandsSelector();
         if(UnknownVarFromRoomChatInputView_IWindowController_1_1 != null)
         {
            UnknownVarFromRoomChatInputView_IWindowController_1_1.dispose();
            UnknownVarFromRoomChatInputView_IWindowController_1_1 = null;
         }
         if(UnknownVarFromRoomChatInputView_ChatStyleSelector_1 != null)
         {
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.dispose();
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1 = null;
         }
         if(UnknownVarFromRoomChatInputView_Timer_1 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_1.reset();
            UnknownVarFromRoomChatInputView_Timer_1.removeEventListener("timerComplete",onTypingTimerComplete);
            UnknownVarFromRoomChatInputView_Timer_1 = null;
         }
         if(UnknownVarFromRoomChatInputView_Timer_2 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_2.reset();
            UnknownVarFromRoomChatInputView_Timer_2.removeEventListener("timerComplete",onIdleTimerComplete);
            UnknownVarFromRoomChatInputView_Timer_2 = null;
         }
         if(UnknownVarFromRoomChatInputView_Timer_3 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_3.reset();
            UnknownVarFromRoomChatInputView_Timer_3.removeEventListener("timerComplete",onNuxIdleTimerComplete);
            UnknownVarFromRoomChatInputView_Timer_3 = null;
         }
         if(UnknownVarFromRoomChatInputView_Timer_5 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_5.reset();
            UnknownVarFromRoomChatInputView_Timer_5.removeEventListener("timerComplete",onChatReminderTimer);
            UnknownVarFromRoomChatInputView_Timer_5 = null;
         }
         if(UnknownVarFromRoomChatInputView_Timer_4)
         {
            UnknownVarFromRoomChatInputView_Timer_4.reset();
            UnknownVarFromRoomChatInputView_Timer_4.removeEventListener("timerComplete",onRemoveDimmer);
            UnknownVarFromRoomChatInputView_Timer_4 = null;
         }
         if(_window)
         {
            _window.procedure = null;
         }
         if(_window && _window.desktop)
         {
            _window.desktop.removeChild(_window);
         }
      }
      
      public function release() : void
      {
         if(UnknownVarFromRoomChatInputView_Timer_1 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_1.reset();
         }
         if(UnknownVarFromRoomChatInputView_Timer_2 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_2.reset();
         }
         UnknownVarFromRoomChatInputView_Boolean_4 = false;
         UnknownVarFromRoomChatInputView_Boolean_5 = false;
         stopHelpButtonHideTimer();
      }
      
      private function createWindow() : void
      {
         if(UnknownVarFromRoomChatInputView_IWindowController_1_1 != null)
         {
            return;
         }
         var _loc2_:String = "chatinput_window_new";
         var _loc1_:XmlAsset = _widget.assets.getAssetByName(_loc2_) as XmlAsset;
         if(_loc1_ == null || _loc1_.content == null)
         {
            return;
         }
         _window = _widget.windowManager.buildFromXML(_loc1_.content as XML) as IWindowController_1;
         _window.width = _window.desktop.width;
         _window.height = _window.desktop.height;
         _window.invalidate();
         _window.procedure = chatInputWindowProcedure;
         _chatStyleMenuContainer = IWindowController_1(_window.findChildByName("chatstyles_menu"));
         UnknownVarFromRoomChatInputView_IWindowController_1_2 = IWindowController_1(_window.findChildByName("habbicon_menu"));
         UnknownVarFromRoomChatInputView_IWindowController_1_1 = _window.findChildByName("bubblecont") as IWindowController_1;
         UnknownVarFromRoomChatInputView_IWindowController_1_1.tags.push("room_widget_chatinput");
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1 = UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("chat_input") as ITextFieldWindow;
         UnknownVarFromRoomChatInputView_IWindowModel_1 = UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("input_border");
         UnknownVarFromRoomChatInputView_IWindowModel_3 = UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("chat_extra_button");
         UnknownVarFromRoomChatInputView_IBitmapWrapperController_1 = UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("chat_extra_set_icon") as IBitmapWrapperController;
         if(UnknownVarFromRoomChatInputView_IBitmapWrapperController_1)
         {
            UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.visible = false;
         }
         if(UnknownVarFromRoomChatInputView_IWindowModel_3)
         {
            UnknownVarFromRoomChatInputView_IWindowModel_3.visible = habbiconsEnabled();
            UnknownVarFromRoomChatInputView_IWindowModel_3.addEventListener("WME_CLICK",onHabbiconButtonMouseEvent);
         }
         if(_widget.roomUi && _widget.roomUi.inventory && _widget.roomUi.inventory.events)
         {
            _widget.roomUi.inventory.events.addEventListener("HUIUE_UNSEEN_ITEMS_CHANGED",onUnseenItemsUpdated);
         }
         UnknownVarFromRoomChatInputView_IWindowModel_2 = UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("block_text");
         UnknownVarFromRoomChatInputView_IRegionWindow_1 = IRegionWindow(UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("helpbutton_show_hover_region"));
         UnknownVarFromRoomChatInputView_IRegionWindow_1.addEventListener("WME_OVER",onInputHoverRegionMouseEvent);
         UnknownVarFromRoomChatInputView_IRegionWindow_1.addEventListener("WME_OUT",onInputHoverRegionMouseEvent);
         updatePosition();
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.setParamFlag(1,true);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.addEventListener("WME_DOWN",windowMouseEventProcessor);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.addEventListener("WKE_KEY_DOWN",windowKeyEventProcessor);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.addEventListener("WKE_KEY_UP",keyUpHandler);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.addEventListener("WE_CHANGE",onInputChanged);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.addEventListener("WME_OVER",onInputHoverRegionMouseEvent);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.addEventListener("WME_OUT",onInputHoverRegionMouseEvent);
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.toolTipDelay = 0;
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.toolTipIsDynamic = true;
         UnknownVarFromRoomChatInputView_Boolean_3 = true;
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.setTextFormat(UnknownVarFromRoomChatInputView_TextFormat_1);
         UnknownVarFromRoomChatInputView_String_3 = "";
         _window.addEventListener("WE_PARENT_RESIZED",updatePosition);
         _window.addEventListener("WE_PARENT_ADDED",updatePosition);
         createOrUpdateChatStylesView();
         createOrUpdateHabbiconSelector();
         updateHabbiconUnseenCounter();
         createAndAttachDimmerWindow();
         UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1 = UnknownICoreWindowComponents8(_window.findChildByName("helpbutton"));
         UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.addEventListener("WME_CLICK",onHelpButtonMouseEvent);
         UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.addEventListener("WME_OVER",onHelpButtonMouseEvent);
         UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.addEventListener("WME_OUT",onHelpButtonMouseEvent);
         UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.visible = true;
         ensureCommandsSelector();
      }
      
      public function createOrUpdateChatStylesView() : void
      {
         var _loc5_:ISessionDataManager = null;
         var _loc6_:IHabboFreeFlowChat = null;
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         var _loc7_:UnknownIHabboFreeflowchatStyle1 = null;
         if(customChatStylesEnabled() && !_widget.handler.container.roomSession.isGameSession && _widget.handler.container.freeFlowChat != null && _widget.handler.container.freeFlowChat.chatStyleLibrary != null)
         {
            _loc5_ = _widget.handler.container.sessionDataManager;
            _loc6_ = _widget.handler.container.freeFlowChat;
            _loc1_ = [];
            _loc2_ = _widget.roomUi.getProperty("disabled.custom.chat.styles").split(",");
            _loc3_ = Boolean(_loc5_.hasSecurity(4));
            for each(var _loc4_ in _loc6_.chatStyleLibrary.getStyleIds())
            {
               if(Boolean(this.widget.windowManager.LilithCustomsInstance.ShowAllChatBubbles) == true)
               {
                  _loc1_.push(_loc4_);
               }
               else
               {
                  _loc7_ = _loc6_.chatStyleLibrary.getStyle(_loc4_);
                  if(!_loc7_.isSystemStyle)
                  {
                     if(isNftChatStyle(_loc4_))
                     {
                        if(_loc5_.hasNftChatStyle(_loc4_))
                        {
                           _loc1_.push(_loc4_);
                        }
                     }
                     else
                     {
                        if(isStaticStyle(_loc4_) && !_loc7_.purchasable)
                        {
                           if(_loc7_.isStaffOverrideable && _loc3_)
                           {
                              _loc1_.push(_loc4_);
                              continue;
                           }
                           if(_loc7_.isAmbassadorOnly && (_loc3_ || _loc5_.isAmbassador))
                           {
                              _loc1_.push(_loc4_);
                              continue;
                           }
                           if(_loc2_.indexOf(_loc4_.toString()) != -1)
                           {
                              continue;
                           }
                           if(_loc7_.isHcOnly && _loc5_.hasClub)
                           {
                              _loc1_.push(_loc4_);
                              continue;
                           }
                           if(!_loc7_.isHcOnly && !_loc7_.isAmbassadorOnly)
                           {
                              _loc1_.push(_loc4_);
                              continue;
                           }
                        }
                        if(_loc5_.hasPurchasableChatStyle(_loc4_))
                        {
                           _loc1_.push(_loc4_);
                        }
                     }
                  }
               }
            }
            createChatStyleSelectorMenuItems(_loc1_);
         }
         else if(UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("chat_input_container") is IItemListWindow)
         {
            IItemListWindow(UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("chat_input_container")).removeListItemAt(0);
         }
      }
      
      private function isNftChatStyle(param1:int) : Boolean
      {
         return param1 >= 1000 && param1 <= 9999;
      }
      
      private function isPurchasableStyle(param1:int) : Boolean
      {
         return param1 >= 10000 && param1 <= 99999;
      }
      
      private function isStaticStyle(param1:int) : Boolean
      {
         return param1 < 1000;
      }
      
      private function customChatStylesEnabled() : Boolean
      {
         return _widget.roomUi.getBoolean("custom.chat.styles.enabled");
      }
      
      private function createAndAttachDimmerWindow() : void
      {
         var _loc1_:IWindowModel = null;
         if(RoomEnterEffect.isRunning())
         {
            _loc1_ = _widget.windowManager.createWindow("chat_dimmer","",30,1,0x80 | 0x0800 | 1,new Rectangle(0,0,UnknownVarFromRoomChatInputView_IWindowController_1_1.width,UnknownVarFromRoomChatInputView_IWindowController_1_1.height),null,0);
            _loc1_.color = 0;
            _loc1_.blend = 0.3;
            UnknownVarFromRoomChatInputView_IWindowController_1_1.addChild(_loc1_);
            UnknownVarFromRoomChatInputView_IWindowController_1_1.invalidate();
            if(UnknownVarFromRoomChatInputView_Timer_4 == null)
            {
               UnknownVarFromRoomChatInputView_Timer_4 = new Timer(RoomEnterEffect.totalRunningTime,1);
               UnknownVarFromRoomChatInputView_Timer_4.addEventListener("timerComplete",onRemoveDimmer);
               UnknownVarFromRoomChatInputView_Timer_4.start();
            }
         }
      }
      
      private function onRemoveDimmer(param1:TimerEvent) : void
      {
         UnknownVarFromRoomChatInputView_Timer_4.removeEventListener("timerComplete",onRemoveDimmer);
         UnknownVarFromRoomChatInputView_Timer_4 = null;
         var _loc2_:IWindowModel = UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("chat_dimmer");
         if(_loc2_ != null)
         {
            UnknownVarFromRoomChatInputView_IWindowController_1_1.removeChild(_loc2_);
            _widget.windowManager.destroy(_loc2_);
         }
      }
      
      public function updatePosition(param1:WindowEvent = null, param2:int = 10000, param3:int = 10000) : void
      {
         _window.width = _window.desktop.width;
         _window.height = _window.desktop.height;
         var _loc11_:Point = new Point();
         if(!UnknownVarFromRoomChatInputView_IWindowController_1_1)
         {
            return;
         }
         var _loc5_:int = widget.getToolBarWidth();
         var _loc7_:int = widget.getFriendBarWidth();
         var _loc6_:int = _window.desktop.width / 2 - UnknownVarFromRoomChatInputView_IWindowController_1_1.width / 2;
         var _loc8_:* = 0;
         var _loc9_:int = UnknownVarFromRoomChatInputView_IWindowController_1_1.width + 12;
         var _loc4_:* = _window.desktop.width - _loc5_ - _loc7_ > _loc9_;
         if(_loc4_)
         {
            _loc8_ = _loc5_ + 10;
            UnknownVarFromRoomChatInputView_IWindowController_1_1.y = _window.desktop.height - 104;
         }
         else
         {
            _loc8_ = widget.getRoomToolsWidth() + 12;
            UnknownVarFromRoomChatInputView_IWindowController_1_1.y = _window.desktop.height - 160;
         }
         UnknownVarFromRoomChatInputView_IWindowController_1_1.x = Math.max(_loc6_,_loc8_);
         if(UnknownVarFromRoomChatInputView_ChatStyleSelector_1)
         {
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.alignMenuToSelector();
         }
         if(UnknownVarFromRoomChatInputView_HabbiconSelector_1)
         {
            UnknownVarFromRoomChatInputView_HabbiconSelector_1.alignToAnchor();
         }
         alignCommandsSelector();
      }
      
      private function onSend(param1:WindowMouseEvent) : void
      {
         if(!UnknownVarFromRoomChatInputView_Boolean_3)
         {
            sendChatFromInputField();
         }
      }
      
      public function hideFloodBlocking() : void
      {
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.visible = true;
         UnknownVarFromRoomChatInputView_IWindowModel_2.visible = false;
      }
      
      public function showFloodBlocking() : void
      {
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.visible = false;
         UnknownVarFromRoomChatInputView_IWindowModel_2.visible = true;
      }
      
      public function updateBlockText(param1:int) : void
      {
         UnknownVarFromRoomChatInputView_IWindowModel_2.caption = _widget.localizations.registerParameter("chat.input.alert.flood","time",param1.toString());
      }
      
      public function displaySpecialChatMessage(param1:String, param2:String = "") : void
      {
         if(UnknownVarFromRoomChatInputView_IWindowController_1_1 == null || UnknownVarFromRoomChatInputView_ITextFieldWindow_1 == null)
         {
            return;
         }
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.enable();
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.selectable = true;
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text = "";
         setInputFieldFocus();
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text += param1 + " ";
         if(param2.length > 0)
         {
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text += param2 + " ";
         }
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.setSelection(UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text.length,UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text.length);
         UnknownVarFromRoomChatInputView_String_3 = UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text;
      }
      
      private function windowMouseEventProcessor(param1:WindowEvent = null, param2:IWindowModel = null) : void
      {
         setInputFieldFocus();
      }
      
      private function chatInputWindowProcedure(param1:WindowEvent, param2:IWindowModel) : void
      {
         if(param1.type == "WME_CLICK")
         {
            hideSelectorsIfClickOutside(param2);
         }
         else if(param1.type == "WME_CLICK_AWAY")
         {
            hideSelectorsIfClickOutside(param1.related);
         }
      }
      
      private function hideSelectorsIfClickOutside(param1:IWindowModel) : void
      {
         if(UnknownVarFromRoomChatInputView_HabbiconSelector_1 != null && UnknownVarFromRoomChatInputView_HabbiconSelector_1.visible && !isWindowInTree(param1,UnknownVarFromRoomChatInputView_IWindowModel_3) && !UnknownVarFromRoomChatInputView_HabbiconSelector_1.containsWindow(param1))
         {
            UnknownVarFromRoomChatInputView_HabbiconSelector_1.hide();
            updateHabbiconUnseenCounter();
         }
         if(UnknownVarFromRoomChatInputView_ChatStyleSelector_1 != null && UnknownVarFromRoomChatInputView_ChatStyleSelector_1.visible && !UnknownVarFromRoomChatInputView_ChatStyleSelector_1.containsWindow(param1))
         {
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.hide();
         }
         if(_commandsMenu != null && Boolean(_commandsMenu.visible) && !isWindowInTree(param1,UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1) && !isWindowInTree(param1,_commandsMenu))
         {
            hideCommandsSelector();
         }
      }
      
      private function windowKeyEventProcessor(param1:WindowEvent = null, param2:IWindowModel = null) : void
      {
         var _loc7_:* = 0;
         var _loc3_:Boolean = false;
         var _loc6_:WindowKeyboardEvent = null;
         var _loc4_:KeyboardEvent = null;
         var _loc8_:String = null;
         var _loc5_:Array = null;
         if(UnknownVarFromRoomChatInputView_IWindowController_1_1 == null || _widget == null || _widget.floodBlocked)
         {
            return;
         }
         if(anotherFieldHasFocus())
         {
            return;
         }
         setInputFieldFocus();
         if(param1 is WindowKeyboardEvent)
         {
            _loc6_ = param1 as WindowKeyboardEvent;
            _loc7_ = _loc6_.charCode;
            _loc3_ = _loc6_.shiftKey;
         }
         if(param1 is KeyboardEvent)
         {
            _loc4_ = param1 as KeyboardEvent;
            _loc7_ = _loc4_.charCode;
            _loc3_ = _loc4_.shiftKey;
         }
         if(_loc4_ == null && _loc6_ == null)
         {
            return;
         }
         if(_loc7_ == 32)
         {
            checkSpecialKeywordForInput();
         }
         if(_loc7_ == 13)
         {
            sendChatFromInputField(_loc3_);
            setButtonPressedState(true);
         }
         if(_loc7_ == 8)
         {
            if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 != null)
            {
               _loc8_ = UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text;
               _loc5_ = _loc8_.split(" ");
               if(_loc5_[0] == UnknownVarFromRoomChatInputView_String_1 && _loc5_.length == 3 && _loc5_[2] == "")
               {
                  UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text = "";
                  UnknownVarFromRoomChatInputView_String_3 = "";
               }
            }
         }
      }
      
      private function keyUpHandler(param1:WindowKeyboardEvent) : void
      {
         this.widget.windowManager.LilithCustomsInstance.OnChatInputKeyUp(param1);
         if(param1.keyCode == 13)
         {
            setButtonPressedState(false);
         }
      }
      
      private function setButtonPressedState(param1:Boolean) : void
      {
      }
      
      private function onInputChanged(param1:WindowEvent) : void
      {
         var _loc2_:ITextFieldWindow = param1.window as ITextFieldWindow;
         if(_loc2_ == null)
         {
            return;
         }
         UnknownVarFromRoomChatInputView_Timer_2.reset();
         var _loc3_:* = _loc2_.text.length == 0;
         if(_loc3_)
         {
            UnknownVarFromRoomChatInputView_Boolean_4 = false;
            UnknownVarFromRoomChatInputView_Timer_1.start();
         }
         else
         {
            if(_loc2_.text.length > UnknownVarFromRoomChatInputView_String_3.length + 1)
            {
               if(_widget.allowPaste)
               {
                  _widget.setLastPasteTime();
               }
               else
               {
                  _loc2_.text = "";
               }
            }
            UnknownVarFromRoomChatInputView_String_3 = _loc2_.text;
            if(!UnknownVarFromRoomChatInputView_Boolean_4)
            {
               UnknownVarFromRoomChatInputView_Boolean_4 = true;
               UnknownVarFromRoomChatInputView_Timer_1.reset();
               UnknownVarFromRoomChatInputView_Timer_1.start();
            }
            UnknownVarFromRoomChatInputView_Timer_2.start();
            if(UnknownVarFromRoomChatInputView_Timer_3 != null)
            {
               UnknownVarFromRoomChatInputView_Timer_3.reset();
               UnknownVarFromRoomChatInputView_Timer_3 = null;
            }
         }
         if(_loc2_.text.indexOf(":") == 0)
         {
            if(this.UnknownVarFromRoomChatInputView_Boolean_5)
            {
               this.onIdleTimerComplete(null);
            }
            _loc2_.maxChars = 200;
            _loc2_.textBackground = true;
            UnknownVarFromRoomChatInputView_Timer_1.reset();
            UnknownVarFromRoomChatInputView_Boolean_4 = false;
            UnknownVarFromRoomChatInputView_Boolean_5 = false;
         }
         else
         {
            _loc2_.maxChars = 100;
            _loc2_.textBackground = false;
         }
         this.widget.windowManager.LilithCustomsInstance.OnChatInputChanged(_loc2_);
      }
      
      private function checkSpecialKeywordForInput() : void
      {
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 == null || UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text == "")
         {
            return;
         }
         var _loc2_:String = UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text;
         var _loc1_:String = _widget.selectedUserName;
         if(_loc2_ == UnknownVarFromRoomChatInputView_String_1)
         {
            if(_loc1_.length > 0)
            {
               UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text += " " + _widget.selectedUserName;
               UnknownVarFromRoomChatInputView_ITextFieldWindow_1.setSelection(UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text.length,UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text.length);
               UnknownVarFromRoomChatInputView_String_3 = UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text;
            }
         }
      }
      
      private function onIdleTimerComplete(param1:TimerEvent) : void
      {
         if(UnknownVarFromRoomChatInputView_Boolean_4)
         {
            UnknownVarFromRoomChatInputView_Boolean_5 = false;
         }
         UnknownVarFromRoomChatInputView_Boolean_4 = false;
         sendTypingMessage();
      }
      
      private function onNuxIdleTimerComplete(param1:TimerEvent) : void
      {
         if(UnknownVarFromRoomChatInputView_Timer_3 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_3.reset();
            UnknownVarFromRoomChatInputView_Timer_3.removeEventListener("timerComplete",onNuxIdleTimerComplete);
            UnknownVarFromRoomChatInputView_Timer_3 = null;
         }
         highlightChatInput();
      }
      
      private function onTypingTimerComplete(param1:TimerEvent) : void
      {
         if(UnknownVarFromRoomChatInputView_Boolean_4)
         {
            UnknownVarFromRoomChatInputView_Boolean_5 = true;
         }
         sendTypingMessage();
      }
      
      private function sendTypingMessage() : void
      {
         if(_widget == null)
         {
            return;
         }
         if(_widget.messageListener == null)
         {
            return;
         }
         if(_widget.handler == null || _widget.handler.container == null || _widget.handler.container.roomSession == null)
         {
            return;
         }
         if(_widget.floodBlocked)
         {
            return;
         }
         var _loc1_:RoomWidgetChatTypingMessage = new RoomWidgetChatTypingMessage(UnknownVarFromRoomChatInputView_Boolean_4);
         _widget.messageListener.processWidgetMessage(_loc1_);
      }
      
      private function highlightChatInput() : void
      {
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text = widget.localizations.getLocalization("widgets.chatinput.mode.remind.noobie");
         UnknownVarFromRoomChatInputView_Timer_5 = new Timer(500);
         UnknownVarFromRoomChatInputView_Timer_5.addEventListener("timer",onChatReminderTimer);
         UnknownVarFromRoomChatInputView_Timer_5.start();
         widget.windowManager.registerHintWindow("nux_chat_reminder",UnknownVarFromRoomChatInputView_ITextFieldWindow_1);
         widget.windowManager.showHint("nux_chat_reminder");
      }
      
      private function onChatReminderTimer(param1:TimerEvent) : void
      {
         UnknownVarFromRoomChatInputView_Int_2 += 1;
         if(UnknownVarFromRoomChatInputView_Int_2 % 2 != 0)
         {
            _widget.mainWindow.y -= 1;
         }
         else
         {
            _widget.mainWindow.y += 1;
         }
         if(UnknownVarFromRoomChatInputView_Int_2 >= 10)
         {
            UnknownVarFromRoomChatInputView_Timer_5.reset();
            UnknownVarFromRoomChatInputView_Timer_5 = null;
            _widget.mainWindow.y = 0;
            chatBarReminderShown();
         }
      }
      
      private function chatBarReminderShown() : void
      {
         widget.handler.container.config.setProperty("nux.chat.reminder.shown","1");
         if(UnknownVarFromRoomChatInputView_Timer_5 != null)
         {
            UnknownVarFromRoomChatInputView_Timer_5.reset();
         }
         widget.windowManager.hideHint();
         widget.windowManager.unregisterHintWindow("nux_chat_reminder");
      }
      
      private function setInputFieldFocus() : void
      {
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 == null)
         {
            return;
         }
         if(UnknownVarFromRoomChatInputView_Timer_5 != null)
         {
            chatBarReminderShown();
         }
         if(UnknownVarFromRoomChatInputView_Boolean_3)
         {
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text = "";
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.textColor = 0;
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.italic = false;
            UnknownVarFromRoomChatInputView_Boolean_3 = false;
            UnknownVarFromRoomChatInputView_String_3 = "";
         }
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.focus();
      }
      
      public function setInputFieldColor(param1:uint) : void
      {
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 == null)
         {
            return;
         }
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.textColor = param1;
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.defaultTextFormat.color = param1;
      }
      
      private function sendChatFromInputField(param1:Boolean = false) : void
      {
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 == null || UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text == "")
         {
            return;
         }
         this.UnknownVarFromRoomChatInputView_ITextFieldWindow_1.textBackground = false;
         var _loc7_:int = param1 ? 2 : 0;
         var _loc6_:String = UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text;
         var _loc4_:Array = _loc6_.split(" ");
         var _loc2_:String = "";
         var _loc5_:String = "";
         switch(_loc4_[0])
         {
            case UnknownVarFromRoomChatInputView_String_1:
               _loc7_ = 1;
               _loc2_ = _loc4_[1];
               _loc5_ = UnknownVarFromRoomChatInputView_String_1 + " " + _loc2_ + " ";
               _loc4_.shift();
               _loc4_.shift();
               break;
            case _chatModeIdShout:
               _loc7_ = 2;
               _loc4_.shift();
               break;
            case UnknownVarFromRoomChatInputView_String_2:
               _loc7_ = 0;
               _loc4_.shift();
         }
         _loc6_ = _loc4_.join(" ");
         var _loc3_:int = 0;
         if(customChatStylesEnabled() && UnknownVarFromRoomChatInputView_ChatStyleSelector_1 != null)
         {
            _loc3_ = UnknownVarFromRoomChatInputView_ChatStyleSelector_1.selectedStyleId;
         }
         if(_widget != null)
         {
            if(UnknownVarFromRoomChatInputView_Timer_1.running)
            {
               UnknownVarFromRoomChatInputView_Timer_1.reset();
            }
            if(UnknownVarFromRoomChatInputView_Timer_2.running)
            {
               UnknownVarFromRoomChatInputView_Timer_2.reset();
            }
            _widget.sendChat(_loc6_,_loc7_,_loc2_,_loc3_);
            UnknownVarFromRoomChatInputView_Boolean_4 = false;
            if(UnknownVarFromRoomChatInputView_Boolean_5)
            {
               sendTypingMessage();
            }
            UnknownVarFromRoomChatInputView_Boolean_5 = false;
         }
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 != null)
         {
            UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text = _loc5_;
         }
         UnknownVarFromRoomChatInputView_String_3 = _loc5_;
      }
      
      private function anotherFieldHasFocus() : Boolean
      {
         var _loc3_:Stage = null;
         var _loc2_:InteractiveObject = null;
         if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1 != null)
         {
            if(UnknownVarFromRoomChatInputView_ITextFieldWindow_1.focused)
            {
               return false;
            }
         }
         var _loc1_:DisplayObject = UnknownVarFromRoomChatInputView_IWindowController_1_1.context.getDesktopWindow().getDisplayObject();
         if(_loc1_ != null)
         {
            _loc3_ = _loc1_.stage;
            if(_loc3_ != null)
            {
               _loc2_ = _loc3_.focus;
               if(_loc2_ == null)
               {
                  return false;
               }
               if(_loc2_ is TextField)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get sessionDataManager() : ISessionDataManager
      {
         return _widget.handler.container.sessionDataManager;
      }
      
      private function createChatStyleSelectorMenuItems(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         if(!UnknownVarFromRoomChatInputView_ChatStyleSelector_1)
         {
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1 = new ChatStyleSelector(this,IWindowController_1(UnknownVarFromRoomChatInputView_IWindowController_1_1.findChildByName("styles")),sessionDataManager);
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.gridColumns = UnknownHabboUtils1.clamp(param1.length / 6 + 1,4,6);
            _loc4_ = param1.length - 1;
            while(_loc4_ >= 0)
            {
               _loc2_ = int(param1[_loc4_]);
               UnknownVarFromRoomChatInputView_ChatStyleSelector_1.addItem(_loc2_,_widget.handler.container.freeFlowChat.chatStyleLibrary.getStyle(_loc2_).selectorPreview);
               _loc4_--;
            }
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.initSelection();
            var _loc3_:int = int(_widget.handler.container.freeFlowChat.chatFontSizeMode);
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.initFontSizeSelection(_loc3_);
            return;
         }
         UnknownVarFromRoomChatInputView_ChatStyleSelector_1.dispose();
         UnknownVarFromRoomChatInputView_ChatStyleSelector_1 = null;
         createChatStyleSelectorMenuItems(param1);
      }
      
      public function get widget() : RoomChatInputWidget
      {
         return _widget;
      }
      
      public function get chatStyleMenuContainer() : IWindowController_1
      {
         return _chatStyleMenuContainer;
      }
      
      public function getChatInputY() : int
      {
         if(!_window || !_window.findChildByName("chat_input_container"))
         {
            return 0;
         }
         var _loc1_:Point = new Point();
         _window.findChildByName("chat_input_container").getGlobalPosition(_loc1_);
         return _loc1_.y;
      }
      
      public function getChatWindowElements() : Array
      {
         return [UnknownVarFromRoomChatInputView_IWindowController_1_1,UnknownVarFromRoomChatInputView_ITextFieldWindow_1];
      }
      
      private function onHelpButtonMouseEvent(param1:WindowMouseEvent) : void
      {
         if(param1.type == "WME_CLICK")
         {
            hideHabbiconSelector();
            hideChatStyleSelector();
            toggleCommandsSelector();
         }
      }
      
      private function onHabbiconButtonMouseEvent(param1:WindowMouseEvent) : void
      {
         if(!habbiconsEnabled())
         {
            return;
         }
         if(param1.type == "WME_CLICK")
         {
            if(UnknownVarFromRoomChatInputView_HabbiconSelector_1)
            {
               hideChatStyleSelector();
               hideCommandsSelector();
               UnknownVarFromRoomChatInputView_HabbiconSelector_1.toggle();
               updateHabbiconUnseenCounter();
            }
            else
            {
               openHabbiconHub();
            }
         }
      }
      
      private function createOrUpdateHabbiconSelector() : void
      {
         if(!habbiconsEnabled())
         {
            if(UnknownVarFromRoomChatInputView_HabbiconSelector_1)
            {
               UnknownVarFromRoomChatInputView_HabbiconSelector_1.dispose();
               UnknownVarFromRoomChatInputView_HabbiconSelector_1 = null;
            }
            if(UnknownVarFromRoomChatInputView_IWindowController_1_2)
            {
               UnknownVarFromRoomChatInputView_IWindowController_1_2.visible = false;
            }
            unregisterHabbiconButtonListeners();
            unregisterHabbiconAssetsListener();
            clearHabbiconButtonSetIcon();
            return;
         }
         registerHabbiconButtonListeners();
         registerHabbiconAssetsListener();
         if(UnknownVarFromRoomChatInputView_HabbiconSelector_1 == null && UnknownVarFromRoomChatInputView_IWindowModel_3 && UnknownVarFromRoomChatInputView_IWindowController_1_2)
         {
            UnknownVarFromRoomChatInputView_HabbiconSelector_1 = new HabbiconSelector(this,UnknownVarFromRoomChatInputView_IWindowModel_3,UnknownVarFromRoomChatInputView_IWindowController_1_2);
         }
         updateHabbiconUnseenCounter();
         updateHabbiconButtonSetIcon();
      }
      
      public function openHabbiconHub() : void
      {
         if(!habbiconsEnabled())
         {
            return;
         }
         if(habbiconController != null)
         {
            habbiconController.resetUnseenHabbicons();
         }
         updateHabbiconUnseenCounter();
         _widget.roomUi.context.createLinkEvent("habbicons/open");
      }
      
      public function hideHabbiconSelector() : void
      {
         if(UnknownVarFromRoomChatInputView_HabbiconSelector_1)
         {
            UnknownVarFromRoomChatInputView_HabbiconSelector_1.hide();
         }
      }
      
      public function hideChatStyleSelector() : void
      {
         if(UnknownVarFromRoomChatInputView_ChatStyleSelector_1 != null)
         {
            UnknownVarFromRoomChatInputView_ChatStyleSelector_1.hide();
         }
         else if(_chatStyleMenuContainer != null)
         {
            _chatStyleMenuContainer.visible = false;
         }
      }
      
      public function hideTransientSelectors() : void
      {
         hideHabbiconSelector();
         hideChatStyleSelector();
         hideCommandsSelector();
      }
      
      public function insertHabbiconToken(param1:String) : void
      {
         if(!habbiconsEnabled() || UnknownVarFromRoomChatInputView_ITextFieldWindow_1 == null || param1 == null || param1.length == 0)
         {
            return;
         }
         setInputFieldFocus();
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text += param1;
         UnknownVarFromRoomChatInputView_ITextFieldWindow_1.setSelection(UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text.length,UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text.length);
         UnknownVarFromRoomChatInputView_String_3 = UnknownVarFromRoomChatInputView_ITextFieldWindow_1.text;
      }
      
      private function habbiconsEnabled() : Boolean
      {
         return _widget != null && _widget.roomUi != null && _widget.roomUi.getBoolean("habbicons.enabled");
      }
      
      private function onUnseenItemsUpdated(param1:HabboUnseenItemsUpdatedEvent) : void
      {
         updateHabbiconUnseenCounter();
      }
      
      private function registerHabbiconButtonListeners() : void
      {
         var _loc1_:IHabbiconController = habbiconController;
         if(UnknownVarFromRoomChatInputView_IHabbiconController_1 == _loc1_)
         {
            return;
         }
         unregisterHabbiconButtonListeners();
         UnknownVarFromRoomChatInputView_IHabbiconController_1 = _loc1_;
         if(UnknownVarFromRoomChatInputView_IHabbiconController_1 != null)
         {
            UnknownVarFromRoomChatInputView_IHabbiconController_1.addEventListener("hce_owned_habbicons_updated",onHabbiconButtonDataUpdated);
            UnknownVarFromRoomChatInputView_IHabbiconController_1.addEventListener("hce_recent_habbicons_updated",onHabbiconButtonDataUpdated);
         }
      }
      
      private function unregisterHabbiconButtonListeners() : void
      {
         if(UnknownVarFromRoomChatInputView_IHabbiconController_1 == null)
         {
            return;
         }
         UnknownVarFromRoomChatInputView_IHabbiconController_1.removeEventListener("hce_owned_habbicons_updated",onHabbiconButtonDataUpdated);
         UnknownVarFromRoomChatInputView_IHabbiconController_1.removeEventListener("hce_recent_habbicons_updated",onHabbiconButtonDataUpdated);
         UnknownVarFromRoomChatInputView_IHabbiconController_1 = null;
      }
      
      private function registerHabbiconAssetsListener() : void
      {
         if(UnknownVarFromRoomChatInputView_Boolean_2)
         {
            return;
         }
         HabbiconAssetManager.addEventListener("habbicon_assets_loaded",onHabbiconAssetsLoaded);
         UnknownVarFromRoomChatInputView_Boolean_2 = true;
      }
      
      private function unregisterHabbiconAssetsListener() : void
      {
         if(!UnknownVarFromRoomChatInputView_Boolean_2)
         {
            return;
         }
         HabbiconAssetManager.removeEventListener("habbicon_assets_loaded",onHabbiconAssetsLoaded);
         UnknownVarFromRoomChatInputView_Boolean_2 = false;
      }
      
      private function onHabbiconButtonDataUpdated(param1:Event) : void
      {
         updateHabbiconButtonSetIcon();
      }
      
      private function onHabbiconAssetsLoaded(param1:Event) : void
      {
         updateHabbiconButtonSetIcon();
      }
      
      private function updateHabbiconButtonSetIcon() : void
      {
         var _loc2_:int = 0;
         var _loc1_:BitmapData = null;
         if(UnknownVarFromRoomChatInputView_IBitmapWrapperController_1 == null || !habbiconsEnabled())
         {
            clearHabbiconButtonSetIcon();
            return;
         }
         _loc2_ = resolveHabbiconButtonSetIconCollectionId();
         if(_loc2_ <= 0)
         {
            clearHabbiconButtonSetIcon();
            return;
         }
         if(UnknownVarFromRoomChatInputView_Int_1 == _loc2_ && UnknownVarFromRoomChatInputView_BitmapData_1 != null)
         {
            UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.visible = true;
            return;
         }
         _loc1_ = HabbiconAssetManager.getOutlinedCollectionIconBitmap(_loc2_);
         if(_loc1_ == null)
         {
            clearHabbiconButtonSetIcon();
            return;
         }
         setHabbiconButtonSetIconBitmap(_loc2_,_loc1_);
      }
      
      private function setHabbiconButtonSetIconBitmap(param1:int, param2:BitmapData) : void
      {
         var _loc3_:BitmapData = new BitmapData(param2.width,param2.height,true,0);
         _loc3_.copyPixels(param2,param2.rect,new Point(0,0),null,null,true);
         clearHabbiconButtonSetIcon();
         UnknownVarFromRoomChatInputView_Int_1 = param1;
         UnknownVarFromRoomChatInputView_BitmapData_1 = _loc3_;
         UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.bitmap = UnknownVarFromRoomChatInputView_BitmapData_1;
         UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.visible = true;
         UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.invalidate();
      }
      
      private function clearHabbiconButtonSetIcon() : void
      {
         var _loc1_:BitmapData = UnknownVarFromRoomChatInputView_BitmapData_1;
         UnknownVarFromRoomChatInputView_Int_1 = 0;
         UnknownVarFromRoomChatInputView_BitmapData_1 = null;
         if(UnknownVarFromRoomChatInputView_IBitmapWrapperController_1 != null)
         {
            UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.bitmap = null;
            UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.visible = false;
            UnknownVarFromRoomChatInputView_IBitmapWrapperController_1.invalidate();
         }
         if(_loc1_ != null)
         {
            _loc1_.dispose();
         }
      }
      
      private function resolveHabbiconButtonSetIconCollectionId() : int
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc1_:IHabbiconController = habbiconController;
         if(_loc1_ == null || !_loc1_.hasLoadedShopData)
         {
            return 0;
         }
         _loc2_ = _loc1_.recentHabbiconIds;
         if(_loc2_ != null && _loc2_.length > 0)
         {
            _loc3_ = resolveCollectionIdForHabbicon(_loc1_,int(_loc2_[0]));
            if(_loc3_ > 0)
            {
               return _loc3_;
            }
         }
         return resolveDefaultHabbiconButtonCollectionId(_loc1_);
      }
      
      private function resolveCollectionIdForHabbicon(param1:IHabbiconController, param2:int) : int
      {
         var _loc3_:UnknownHabboCommunicationMessagesParserHabbicons2 = null;
         var _loc4_:* = undefined;
         var _loc5_:* = null;
         if(param2 <= 0)
         {
            return 0;
         }
         _loc3_ = param1.tryGetShopItem(param2);
         if(_loc3_ != null && _loc3_.collectionId > 0)
         {
            return _loc3_.collectionId;
         }
         _loc4_ = param1.shopCollections;
         if(_loc4_ == null)
         {
            return 0;
         }
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_ != null && _loc5_.UnknownVarFromUnknownHabboCommunicationMessagesParserHabbicons3_Int_1 == param2)
            {
               return _loc5_.collectionId;
            }
         }
         return 0;
      }
      
      private function resolveDefaultHabbiconButtonCollectionId(param1:IHabbiconController) : int
      {
         var _loc2_:Vector.<UnknownHabboCommunicationMessagesParserHabbicons3> = param1.shopCollections;
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return 0;
         }
         return _loc2_[0].collectionId;
      }
      
      private function updateHabbiconUnseenCounter() : void
      {
         var _loc2_:int = 0;
         var _loc1_:IHabbiconController = null;
         var _loc3_:IWindowController_1 = null;
         var _loc4_:ITextWindow = null;
         if(UnknownVarFromRoomChatInputView_IWindowModel_3 == null || !habbiconsEnabled())
         {
            if(UnknownVarFromRoomChatInputView_IWindowController_1_3 != null)
            {
               UnknownVarFromRoomChatInputView_IWindowController_1_3.visible = false;
            }
            return;
         }
         if(UnknownVarFromRoomChatInputView_HabbiconSelector_1 != null && UnknownVarFromRoomChatInputView_HabbiconSelector_1.visible)
         {
            if(UnknownVarFromRoomChatInputView_IWindowController_1_3 != null)
            {
               UnknownVarFromRoomChatInputView_IWindowController_1_3.visible = false;
            }
            return;
         }
         _loc1_ = habbiconController;
         if(_loc1_ != null)
         {
            _loc2_ = int(_loc1_.unseenHabbiconCount);
         }
         if(UnknownVarFromRoomChatInputView_IWindowController_1_3 == null)
         {
            _loc3_ = UnknownVarFromRoomChatInputView_IWindowModel_3 as IWindowController_1;
            if(_loc3_ == null)
            {
               return;
            }
            UnknownVarFromRoomChatInputView_IWindowController_1_3 = _widget.windowManager.createUnseenItemCounter();
            _loc3_.addChild(UnknownVarFromRoomChatInputView_IWindowController_1_3);
            UnknownVarFromRoomChatInputView_IWindowController_1_3.x = _loc3_.width - UnknownVarFromRoomChatInputView_IWindowController_1_3.width - 2;
            UnknownVarFromRoomChatInputView_IWindowController_1_3.y = 2;
         }
         _loc4_ = UnknownVarFromRoomChatInputView_IWindowController_1_3.findChildByName("count") as ITextWindow;
         if(_loc4_ != null)
         {
            _loc4_.caption = _loc2_.toString();
         }
         UnknownVarFromRoomChatInputView_IWindowController_1_3.visible = _loc2_ > 0;
      }
      
      private function get habbiconController() : IHabbiconController
      {
         return _widget != null && _widget.roomUi != null ? _widget.roomUi.habbiconController : null;
      }
      
      private function onInputHoverRegionMouseEvent(param1:WindowMouseEvent) : void
      {
         if(UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1 != null)
         {
            UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.visible = true;
         }
         stopHelpButtonHideTimer();
      }
      
      private function startHelpButtonHideTimer() : void
      {
         stopHelpButtonHideTimer();
      }
      
      private function onHelpButtonHideTimer(param1:TimerEvent) : void
      {
         if(UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1 != null)
         {
            UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.visible = true;
         }
         stopHelpButtonHideTimer();
      }
      
      private function stopHelpButtonHideTimer() : void
      {
         if(!UnknownVarFromRoomChatInputView_Timer_6)
         {
            return;
         }
         UnknownVarFromRoomChatInputView_Timer_6.stop();
         UnknownVarFromRoomChatInputView_Timer_6.removeEventListener("timer",onHelpButtonHideTimer);
         UnknownVarFromRoomChatInputView_Timer_6 = null;
      }
      
      private function ensureCommandsSelector() : void
      {
         var assets:* = null;
         var built:* = null;
         var searchInput:IWindowModel = null;
         var searchPlaceholder:IWindowModel = null;
         var searchClear:IWindowModel = null;
         var openHub:IWindowModel = null;
         var emptyView:IWindowModel = null;
         var section:IWindowController_1 = null;
         var title:ITextWindow = null;
         var grid:IItemGridWindow = null;
         var slotTemplate:IWindowController_1 = null;
         var slot:IRegionWindow = null;
         var icon:IBitmapWrapperController = null;
         var bg:UnknownICoreWindowComponents6 = null;
         var i:int = 0;
         var rows:int = 0;
         var total:int = 0;
         if(_commandsMenu != null || _window == null || _widget == null || _widget.windowManager == null)
         {
            return;
         }
         assets = _widget.assets;
         if(assets == null || assets.getAssetByName("habbiconselector_menu_xml") == null)
         {
            return;
         }
         if(_commandsMenuContainer == null)
         {
            if(UnknownVarFromRoomChatInputView_IWindowController_1_2 != null)
            {
               _commandsMenuContainer = IWindowController_1(UnknownVarFromRoomChatInputView_IWindowController_1_2.clone());
               _commandsMenuContainer.name = "commands_menu";
               _commandsMenuContainer.visible = true;
               while(_commandsMenuContainer.numChildren > 0)
               {
                  _commandsMenuContainer.removeChildAt(0).dispose();
               }
               _window.addChild(_commandsMenuContainer);
            }
            else
            {
               _commandsMenuContainer = _window;
            }
         }
         built = _widget.windowManager.buildFromXML(XML(assets.getAssetByName("habbiconselector_menu_xml").content));
         if(built == null)
         {
            return;
         }
         _commandsMenu = UnknownICoreWindowComponents6(built);
         _commandsMenu.visible = false;
         _commandsMenuContainer.addChild(_commandsMenu);
         _commandsSectionList = IItemListWindow(_commandsMenu.findChildByName("habbicon_section_list"));
         if(_commandsSectionList == null)
         {
            return;
         }
         _commandsSectionTemplate = IWindowController_1(_commandsSectionList.removeListItem(_commandsSectionList.getListItemByName("habbicon_section_template")));
         searchInput = _commandsMenu.findChildByName("habbicon_search_input");
         searchPlaceholder = _commandsMenu.findChildByName("habbicon_search_placeholder");
         searchClear = _commandsMenu.findChildByName("habbicon_search_clear_button");
         openHub = _commandsMenu.findChildByName("habbicon_open_hub_button");
         emptyView = _commandsMenu.findChildByName("empty_view");
         if(searchInput != null)
         {
            searchInput.visible = false;
         }
         if(searchPlaceholder != null)
         {
            searchPlaceholder.visible = false;
         }
         if(searchClear != null)
         {
            searchClear.visible = false;
         }
         if(openHub != null)
         {
            openHub.visible = false;
         }
         if(emptyView != null)
         {
            emptyView.visible = false;
         }
         if(_commandsSectionTemplate == null)
         {
            return;
         }
         section = IWindowController_1(_commandsSectionTemplate.clone());
         section.visible = true;
         title = ITextWindow(section.findChildByName("section_title"));
         if(title != null)
         {
            title.caption = "Commands";
         }
         grid = IItemGridWindow(section.findChildByName("habbicon_grid"));
         if(grid == null)
         {
            return;
         }
         slotTemplate = grid.getGridItemAt(0) as IWindowController_1;
         grid.removeGridItems();
         rows = Math.max(1,Math.ceil(COMMANDS_PLACEHOLDER_SLOTS / COMMANDS_GRID_COLUMNS));
         total = rows * COMMANDS_GRID_COLUMNS;
         i = 0;
         while(i < total)
         {
            slot = slotTemplate.clone() as IRegionWindow;
            if(slot != null)
            {
               slot.toolTipCaption = "";
               icon = IBitmapWrapperController(slot.findChildByName("habbicon_icon"));
               if(icon != null)
               {
                  if(icon.bitmap)
                  {
                     icon.bitmap.dispose();
                     icon.bitmap = null;
                  }
                  icon.visible = false;
               }
               bg = UnknownICoreWindowComponents6(slot.findChildByName("habbicon_item_bg"));
               if(bg != null)
               {
                  bg.color = COMMANDS_SLOT_EMPTY_COLOR;
               }
               slot.mouseThreshold = 10;
               grid.addGridItem(slot);
            }
            i++;
         }
         grid.height = rows * (slotTemplate != null ? slotTemplate.height + 2 : 44);
         section.height = grid.y + grid.height;
         while(_commandsSectionList.numListItems > 0)
         {
            _commandsSectionList.removeListItemAt(0).dispose();
         }
         _commandsSectionList.addListItem(section);
         _commandsMenu.height = Math.max(COMMANDS_MENU_MIN_HEIGHT,Math.min(COMMANDS_MENU_MAX_HEIGHT,COMMANDS_TOP_BAR_HEIGHT + section.height + COMMANDS_BOTTOM_PADDING));
      }
      
      private function toggleCommandsSelector() : void
      {
         ensureCommandsSelector();
         if(_commandsMenu == null)
         {
            return;
         }
         if(_commandsMenu.visible)
         {
            hideCommandsSelector();
            return;
         }
         _commandsMenu.visible = true;
         alignCommandsSelector();
      }
      
      public function hideCommandsSelector() : void
      {
         if(_commandsMenu != null)
         {
            _commandsMenu.visible = false;
         }
      }
      
      private function alignCommandsSelector() : void
      {
         var anchorRect:Rectangle = null;
         var parent:IWindowController_1 = null;
         var global:Point = null;
         if(_commandsMenu == null || !_commandsMenu.visible || UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1 == null || _commandsMenu.parent == null)
         {
            return;
         }
         anchorRect = new Rectangle();
         UnknownVarFromRoomChatInputView_UnknownICoreWindowComponents8_1.getGlobalRectangle(anchorRect);
         parent = IWindowController_1(_commandsMenu.parent);
         parent.x = anchorRect.x;
         parent.y = anchorRect.bottom - COMMANDS_CHAT_BAR_POPUP_OFFSET - _commandsMenu.height;
         global = new Point();
         parent.getGlobalPosition(global);
         if(global.x < COMMANDS_SCREEN_LEFT_BORDER)
         {
            parent.x += COMMANDS_SCREEN_LEFT_BORDER - global.x;
         }
         if(parent.y < 0)
         {
            parent.y = 0;
         }
      }
      
      private function disposeCommandsSelector() : void
      {
         if(_commandsMenu != null)
         {
            _commandsMenu.dispose();
            _commandsMenu = null;
         }
         _commandsSectionList = null;
         if(_commandsSectionTemplate != null)
         {
            _commandsSectionTemplate.dispose();
            _commandsSectionTemplate = null;
         }
         if(_commandsMenuContainer != null && _commandsMenuContainer != _window)
         {
            _commandsMenuContainer.dispose();
         }
         _commandsMenuContainer = null;
      }
   }
}

