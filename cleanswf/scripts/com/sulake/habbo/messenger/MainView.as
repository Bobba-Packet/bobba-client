package com.sulake.habbo.messenger
{
   import com.sulake.core.runtime.IComponentInterfaceQueue;
   import com.sulake.core.utils.ErrorReportStorage;
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IInteractiveWindow;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.components.IRegionWindow;
   import com.sulake.core.window.components.IWidgetWindowController;
   import com.sulake.core.window.components.UnknownICoreWindowComponents8;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.utils.UnknownICoreWindowUtils1;
   import com.sulake.habbo.communication.messages.incoming.friendlist.MessageHistoryEntry;
   import com.sulake.habbo.communication.messages.outgoing.friendlist.FollowFriendMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.friendlist.RemoveFriendMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.friendlist.GetMessengerHistoryComposer;
   import com.sulake.habbo.communication.messages.outgoing.friendlist.SendHabbiconMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.friendlist.SendMsgMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.tracking.EventLogMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.users.GetExtendedProfileMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.users.GetHabboGroupDetailsMessageComposer;
   import com.sulake.habbo.friendlist.UnknownIHabboFriendlist1;
   import com.sulake.habbo.messenger.habbicons.MessengerHabbiconPicker;
   import com.sulake.habbo.window.widgets.IAvatarImageWidget;
   import com.sulake.habbo.window.widgets.IBadgeImageWidget;
   import com.sulake.habbo.window.widgets.IIlluminaChatBubbleWidget;
   import com.sulake.habbo.window.widgets.IIlluminaInputHandler;
   import com.sulake.habbo.window.widgets.IIlluminaInputWidget;
   import com.sulake.habbo.window.widgets.IlluminaChatBubbleMessage;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class MainView implements IComponentInterfaceQueue, IIlluminaInputHandler
   {
      
      private static const HIDDEN:String = "HIDDEN";
      
      private static const NO_CONVERSATION:int = -1;
      
      private static const NOTIFICATION_ICON_WIDTH:int = 55;
      
      private static const SCROLL_TRIGGER_HEIGHT:int = 150;
      
      private static const COMBINE_MESSAGING_THRESHOLD:int = 600000;
      
      private static const UnknownConstFromMainView_Int_1:int = 4;
      
      private static const CHAT_ITEM_RENDER_MAX_BUNDLE_SIZE:int = 3;
      
      private static const CHAT_ITEM_RENDER_MAX_MESSAGES_SIZE:int = 7;
      
      private static const CHAT_ITEM_INITIAL_MULTIPLIER:int = 3;
      
      private static const UnknownConstFromMainView_Int_2:int = 40;
      
      private static const UnknownConstFromMainView_Int_3:int = 4000;
      
      private static const ERROR_MESSAGES:Dictionary = new Dictionary();
      
      ERROR_MESSAGES[3] = "${messenger.error.receivermuted}";
      ERROR_MESSAGES[4] = "${messenger.error.sendermuted}";
      ERROR_MESSAGES[5] = "${messenger.error.offline}";
      ERROR_MESSAGES[6] = "${messenger.error.notfriend}";
      ERROR_MESSAGES[7] = "${messenger.error.busy}";
      ERROR_MESSAGES[8] = "${messenger.error.receiverhasnochat}";
      ERROR_MESSAGES[9] = "${messenger.error.senderhasnochat}";
      ERROR_MESSAGES[10] = "${messenger.error.offline_failed}";
      ERROR_MESSAGES[11] = "${messenger.error.not_group_member}";
      ERROR_MESSAGES[12] = "${messenger.error.not_group_admin}";
      ERROR_MESSAGES[13] = "${messenger.error.sender_im_unavailable}";
      ERROR_MESSAGES[14] = "${messenger.error.recipient_im_unavailable}";
      
      private var _messenger:HabboMessenger;
      
      private var UnknownVarFromMainView_IWindowController_1_1:IWindowController_1;
      
      private var _frame:IWindowController_1;
      
      private var UnknownVarFromMainView_IItemListWindow_1:IItemListWindow;
      
      private var UnknownVarFromMainView_IWindowController_1_2:IWindowController_1;
      
      private var UnknownVarFromMainView_Int_1:int;
      
      private var UnknownVarFromMainView_Boolean_1:Boolean;
      
      private var _chatEntries:Dictionary = new Dictionary();
      
      private var UnknownVarFromMainView_Int_2:int = -1;
      
      private var UnknownVarFromMainView_IWindowController_1_3:IWindowController_1;
      
      private var UnknownVarFromMainView_IWidgetWindowController_1:IWidgetWindowController;
      
      private var UnknownVarFromMainView_IWindowController_1_4:IWindowController_1;
      
      private var UnknownVarFromMainView_IWindowController_1_5:IWindowController_1;
      
      private var UnknownVarFromMainView_IWindowController_1_6:IWindowController_1;
      
      private var UnknownVarFromMainView_Boolean_2:Boolean;
      
      private var UnknownVarFromMainView_MessengerHabbiconPicker_1:MessengerHabbiconPicker;
      
      private var UnknownVarFromMainView_Boolean_3:Boolean = false;
      
      private var UnknownVarFromMainView_Int_3:int = 1;
      
      private var _awaitConfirmationEntries:Dictionary = new Dictionary();
      
      private var UnknownVarFromMainView_Int_4:int;
      
      private var _historyFetchesTimestamps:Dictionary = new Dictionary();
      
      private var UnknownVarFromMainView_Dictionary_1:Dictionary = new Dictionary();
      
      private var _pendingRemoveFriendId:int = 0;
      
      public function MainView(param1:HabboMessenger)
      {
         super();
         _messenger = param1;
         UnknownVarFromMainView_IWindowController_1_1 = _messenger.getXmlWindow("messenger") as IWindowController_1;
         _frame = UnknownVarFromMainView_IWindowController_1_1.getChildByName("frame") as IWindowController_1;
         UnknownVarFromMainView_IWindowController_1_1.visible = false;
         UnknownVarFromMainView_IWindowController_1_1.procedure = messengerWindowProcedure;
         UnknownICoreWindowComponents8(_frame.findChildByName("header_button_close")).style = 102;
         UnknownVarFromMainView_IWindowController_1_2 = _frame.findChildByName("avatar_list") as IWindowController_1;
         UnknownVarFromMainView_IWindowController_1_3 = UnknownVarFromMainView_IWindowController_1_2.getChildAt(0) as IWindowController_1;
         UnknownVarFromMainView_IWindowController_1_2.removeChild(UnknownVarFromMainView_IWindowController_1_3);
         UnknownVarFromMainView_Int_1 = 0;
         UnknownVarFromMainView_IItemListWindow_1 = _frame.findChildByName("conversation") as IItemListWindow;
         UnknownVarFromMainView_IWidgetWindowController_1 = UnknownVarFromMainView_IItemListWindow_1.getListItemByName("msg_normal") as IWidgetWindowController;
         UnknownVarFromMainView_IWindowController_1_4 = UnknownVarFromMainView_IItemListWindow_1.getListItemByName("msg_notification") as IWindowController_1;
         UnknownVarFromMainView_IWindowController_1_5 = UnknownVarFromMainView_IItemListWindow_1.getListItemByName("msg_invitation") as IWindowController_1;
         UnknownVarFromMainView_IWindowController_1_6 = UnknownVarFromMainView_IItemListWindow_1.getListItemByName("msg_info") as IWindowController_1;
         UnknownVarFromMainView_IItemListWindow_1.removeListItems();
         UnknownVarFromMainView_Int_4 = -1;
         IIlluminaInputWidget(IWidgetWindowController(_frame.findChildByName("input_widget")).widget).submitHandler = this;
         setupRemoveFriendButton();
      }
      
      private static function avatarVisible(param1:IWindowModel) : Boolean
      {
         return param1 != null && param1.tags.indexOf("HIDDEN") < 0;
      }
      
      private static function setAvatarVisibilityTag(param1:IWindowModel, param2:Boolean) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc3_:Boolean = avatarVisible(param1);
         if(_loc3_ && !param2)
         {
            param1.tags.push("HIDDEN");
         }
         else if(!_loc3_ && param2)
         {
            param1.tags.splice(param1.tags.indexOf("HIDDEN"),1);
         }
      }
      
      private static function escapeExternalKeys(param1:String) : String
      {
         if(param1.search("\\${") == 0)
         {
            return " " + param1;
         }
         return param1;
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
      
      public function dispose() : void
      {
         if(!disposed)
         {
            UnknownVarFromMainView_IItemListWindow_1 = null;
            UnknownVarFromMainView_IWindowController_1_2 = null;
            if(UnknownVarFromMainView_MessengerHabbiconPicker_1 != null)
            {
               UnknownVarFromMainView_MessengerHabbiconPicker_1.dispose();
               UnknownVarFromMainView_MessengerHabbiconPicker_1 = null;
            }
            if(UnknownVarFromMainView_IWindowController_1_1 != null)
            {
               UnknownVarFromMainView_IWindowController_1_1.dispose();
               UnknownVarFromMainView_IWindowController_1_1 = null;
               _frame = null;
            }
            if(UnknownVarFromMainView_IWidgetWindowController_1 != null)
            {
               UnknownVarFromMainView_IWidgetWindowController_1.dispose();
               UnknownVarFromMainView_IWidgetWindowController_1 = null;
            }
            if(UnknownVarFromMainView_IWindowController_1_4 != null)
            {
               UnknownVarFromMainView_IWindowController_1_4.dispose();
               UnknownVarFromMainView_IWindowController_1_4 = null;
            }
            if(UnknownVarFromMainView_IWindowController_1_5 != null)
            {
               UnknownVarFromMainView_IWindowController_1_5.dispose();
               UnknownVarFromMainView_IWindowController_1_5 = null;
            }
            if(UnknownVarFromMainView_IWindowController_1_6 != null)
            {
               UnknownVarFromMainView_IWindowController_1_6.dispose();
               UnknownVarFromMainView_IWindowController_1_6 = null;
            }
            if(UnknownVarFromMainView_IWindowController_1_3 != null)
            {
               UnknownVarFromMainView_IWindowController_1_3.dispose();
               UnknownVarFromMainView_IWindowController_1_3 = null;
            }
            _chatEntries = null;
            _messenger = null;
            _awaitConfirmationEntries = null;
            _historyFetchesTimestamps = null;
            UnknownVarFromMainView_Dictionary_1 = null;
         }
      }
      
      public function get disposed() : Boolean
      {
         return _messenger == null;
      }
      
      public function get isOpen() : Boolean
      {
         return UnknownVarFromMainView_IWindowController_1_1 != null && Boolean(UnknownVarFromMainView_IWindowController_1_1.visible);
      }
      
      public function toggle() : void
      {
         if(isOpen)
         {
            hide();
         }
         else
         {
            show();
         }
      }
      
      public function show(param1:Boolean = false) : void
      {
         if(param1 || visibleAvatarCount > 0)
         {
            UnknownVarFromMainView_IWindowController_1_1.visible = true;
            UnknownVarFromMainView_IWindowController_1_1.activate();
         }
         if(UnknownVarFromMainView_Int_2 != -1)
         {
            setChatIndicatorVisibility(UnknownVarFromMainView_Int_2,false);
         }
      }
      
      public function hide() : void
      {
         hideHabbiconPicker();
         UnknownVarFromMainView_IWindowController_1_1.visible = false;
      }
      
      public function hideTransientSelectors() : void
      {
         hideHabbiconPicker();
      }
      
      public function startConversation(param1:int, param2:Boolean = true, param3:ChatEntry = null) : void
      {
         var _loc6_:UnknownIHabboFriendlist1 = null;
         var _loc9_:IWindowController_1 = null;
         var _loc5_:IWidgetWindowController = null;
         var _loc8_:IWidgetWindowController = null;
         var _loc7_:IAvatarImageWidget = null;
         var _loc4_:IBadgeImageWidget = null;
         if(!(param1 in _chatEntries))
         {
            _chatEntries[param1] = [];
            if(!UnknownVarFromMainView_Boolean_3)
            {
               recordNotificationMessage(param1,"${messenger.moderationinfo}");
               UnknownVarFromMainView_Boolean_3 = true;
            }
            _loc6_ = _messenger.getFriend(param1,param3);
            if(!_loc6_)
            {
               ErrorReportStorage.addDebugData("Messenger Mainview","User got start conversation request from nonexistent friend, id: " + param1);
               return;
            }
            if(!_loc6_.online)
            {
               recordNotificationMessage(param1,"${messenger.notification.persisted_messages}");
            }
            _loc9_ = UnknownVarFromMainView_IWindowController_1_3.clone() as IWindowController_1;
            setAvatarVisibilityTag(_loc9_,true);
            _loc9_.blend = 0;
            _loc9_.id = param1;
            if(param1 < 0)
            {
               _loc9_.name = String(param1);
            }
            _loc5_ = _loc9_.findChildByName("avatar_image") as IWidgetWindowController;
            _loc8_ = _loc9_.findChildByName("group_badge_image") as IWidgetWindowController;
            if(_loc6_.id > 0)
            {
               _loc7_ = _loc5_.widget as IAvatarImageWidget;
               if(_loc6_ != null)
               {
                  _loc7_.figure = _loc6_.figure;
               }
               _loc8_.visible = false;
               _loc5_.visible = true;
            }
            else
            {
               _loc4_ = _loc8_.widget as IBadgeImageWidget;
               _loc4_.badgeId = _loc6_.figure;
               _loc4_.groupId = _loc6_.id;
               _loc8_.visible = true;
               _loc5_.visible = false;
            }
            IRegionWindow(_loc9_.findChildByName("avatar_click_region")).toolTipCaption = _loc6_.name;
            UnknownVarFromMainView_IWindowController_1_2.addChild(_loc9_);
            refreshAvatarList();
         }
         if(param2 || !isOpen)
         {
            selectConversation(param1);
         }
         refreshChatCount(param2);
      }
      
      public function addConsoleMessage(param1:int, param2:int, param3:String, param4:int, param5:int, param6:String, param7:int, param8:int, param9:String, param10:String) : void
      {
         var _loc11_:IlluminaChatBubbleMessage = createBubbleMessage(param2,param3,param4);
         if(param7 > 0)
         {
            onConfirmOwnChatMessage(param6,_loc11_,param7);
         }
         else
         {
            recordChatMessage(param1,_loc11_,true,param5,param8,param9,param10,param6);
         }
      }
      
      public function addRoomInvite(param1:int, param2:String) : void
      {
         recordInvitationMessage(param1,_messenger.getText("messenger.invitation") + " " + param2,true);
      }
      
      public function setFollowingAllowed(param1:int, param2:Boolean) : void
      {
         if(param1 == UnknownVarFromMainView_Int_2)
         {
            refreshButtons();
         }
      }
      
      public function onInstantMessageError(param1:int, param2:int, param3:String) : void
      {
         var _loc5_:String = null;
         var _loc4_:RegExp = null;
         if(param2 in ERROR_MESSAGES)
         {
            if(param3.length > 0)
            {
               _loc5_ = ERROR_MESSAGES[param2];
               _loc4_ = /[${}]/g;
               _loc5_ = _loc5_.replace(_loc4_,"");
               recordNotificationMessage(param1,_messenger.getText(_loc5_) + ": " + param3);
            }
            else
            {
               recordNotificationMessage(param1,ERROR_MESSAGES[param2]);
            }
         }
      }
      
      public function setOnlineStatus(param1:int, param2:Boolean) : void
      {
         if(param1 in _chatEntries)
         {
            recordInfoMessage(param1,param2 ? "${messenger.notification.online}" : "${messenger.notification.offline}");
         }
      }
      
      private function selectConversation(param1:int) : void
      {
         UnknownVarFromMainView_Int_2 = param1;
         setAvatarVisibilityTag(getAvatarWrapper(param1),true);
         setChatIndicatorVisibility(param1,false);
         refreshConversationList();
         refreshAvatarList();
         var _loc3_:UnknownIHabboFriendlist1 = _messenger.getFriend(UnknownVarFromMainView_Int_2);
         var _loc2_:String = _loc3_ != null ? _loc3_.name : "";
         _frame.findChildByName("separator_label").visible = UnknownVarFromMainView_Int_2 < 0 || _loc3_ != null;
         _messenger.localization.registerParameter("messenger.window.separator","friend_name",_loc2_);
         _messenger.localization.registerParameter("messenger.window.input.default","friend_name",_loc2_);
         refreshRemoveFriendButton();
         _frame.invalidate();
      }
      
      public function hideConversation(param1:int) : void
      {
         var _loc2_:IWindowModel = getAvatarWrapper(param1);
         if(_loc2_ != null)
         {
            setAvatarVisibilityTag(_loc2_,false);
         }
         if(visibleAvatarCount == 0)
         {
            selectConversation(-1);
            hide();
         }
         else
         {
            for each(_loc2_ in UnknownVarFromMainView_IWindowController_1_2.iterator)
            {
               if(avatarVisible(_loc2_))
               {
                  UnknownVarFromMainView_Int_1 = 0;
                  selectConversation(_loc2_.id);
                  break;
               }
            }
         }
         refreshChatCount();
      }
      
      private function refreshChatCount(param1:Boolean = false) : void
      {
         _messenger.localization.registerParameter("messenger.window.title","open_chat_count",visibleAvatarCount.toString());
         _messenger.conversationCountUpdated(visibleAvatarCount,hasUnreadChat && !param1);
      }
      
      private function createBubbleMessage(param1:int, param2:String, param3:int) : IlluminaChatBubbleMessage
      {
         return param1 == 1 ? IlluminaChatBubbleMessage.habbicon(param3) : IlluminaChatBubbleMessage.text(param2);
      }
      
      private function recordChatMessage(param1:int, param2:IlluminaChatBubbleMessage, param3:Boolean, param4:int, param5:int, param6:String, param7:String, param8:String = "", param9:int = 0) : void
      {
         var _loc10_:ChatEntry = null;
         if(param3)
         {
            recordChatEntry(param1,new ChatEntry(2,param1,param2,param4,param5,param6,param7,param8),true);
         }
         else
         {
            _loc10_ = new ChatEntry(1,param1,param2,param4,param5,param6,param7,param8,param9);
            if(param9 > 0)
            {
               _awaitConfirmationEntries[param9] = _loc10_;
            }
            recordChatEntry(param1,_loc10_);
         }
      }
      
      private function onConfirmOwnChatMessage(param1:String, param2:IlluminaChatBubbleMessage, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc8_:Boolean = false;
         var _loc7_:int = 0;
         var _loc10_:IWidgetWindowController = null;
         var _loc6_:IIlluminaChatBubbleWidget = null;
         var _loc9_:int = 0;
         var _loc5_:ChatEntry = _awaitConfirmationEntries[param3];
         if(_loc5_ != null)
         {
            _loc5_.isConfirmed(param2,param1);
            UnknownVarFromMainView_Dictionary_1[param1] = true;
            _loc4_ = UnknownVarFromMainView_IItemListWindow_1.numListItems;
            _loc8_ = false;
            _loc7_ = 0;
            while(_loc7_ < _loc4_ && !_loc8_)
            {
               _loc10_ = UnknownVarFromMainView_IItemListWindow_1.getListItemAt(_loc7_) as IWidgetWindowController;
               if(_loc10_ != null)
               {
                  _loc6_ = _loc10_.widget as IIlluminaChatBubbleWidget;
                  if(_loc6_ != null)
                  {
                     _loc9_ = 0;
                     while(_loc9_ < _loc6_.numMessages)
                     {
                        if(_loc6_.getAwaitingConfirmationId(_loc9_) == param3)
                        {
                           _loc6_.clearAwaitingConfirmationId(_loc9_);
                           _loc6_.setMessage(_loc9_,param2);
                           _loc8_ = true;
                           break;
                        }
                        _loc9_ += 1;
                     }
                  }
               }
               _loc7_ += 1;
            }
            delete _awaitConfirmationEntries[param3];
         }
      }
      
      private function recordNotificationMessage(param1:int, param2:String) : void
      {
         recordChatEntry(param1,new ChatEntry(3,0,IlluminaChatBubbleMessage.text(param2),0));
      }
      
      private function recordInfoMessage(param1:int, param2:String, param3:Boolean = false) : void
      {
         recordChatEntry(param1,new ChatEntry(4,0,IlluminaChatBubbleMessage.text(param2),0),param3);
      }
      
      private function recordInvitationMessage(param1:int, param2:String, param3:Boolean = false) : void
      {
         recordChatEntry(param1,new ChatEntry(5,0,IlluminaChatBubbleMessage.text(param2),0),param3);
      }
      
      private function recordChatEntry(param1:int, param2:ChatEntry, param3:Boolean = false) : void
      {
         if(_messenger == null)
         {
            return;
         }
         if(param2.messageId != "")
         {
            if(param2.messageId in UnknownVarFromMainView_Dictionary_1)
            {
               return;
            }
            UnknownVarFromMainView_Dictionary_1[param2.messageId] = true;
         }
         if(!(param1 in _chatEntries))
         {
            if(param1 <= 0)
            {
               return;
            }
            startConversation(param1,false,param2.type == 2 ? param2 : null);
         }
         var _loc5_:Array = _chatEntries[param1];
         var _loc6_:ChatEntry = _loc5_.length > 0 ? _loc5_[_loc5_.length - 1] : null;
         _loc5_.push(param2);
         var _loc4_:IWindowController_1 = getAvatarWrapper(param1);
         if(_loc4_ != null)
         {
            setAvatarVisibilityTag(_loc4_,true);
            refreshAvatarList();
         }
         if(param1 == UnknownVarFromMainView_Int_2)
         {
            addToConversationAndCombine(param2,_loc6_);
            UnknownVarFromMainView_IItemListWindow_1.arrangeListItems();
            UnknownVarFromMainView_IItemListWindow_1.scrollV = 1;
            if(!isOpen && param3)
            {
               setChatIndicatorVisibility(param1,true);
            }
         }
         else
         {
            if(param3)
            {
               setChatIndicatorVisibility(param1,true);
            }
            if(visibleAvatarCount == 1)
            {
               selectConversation(param1);
            }
         }
         refreshChatCount();
      }
      
      private function shouldCombineWithPreviousEntry(param1:int, param2:ChatEntry, param3:ChatEntry) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Array = _chatEntries[param1];
         if(_loc6_.length > 0)
         {
            param3.sentTimeStamp();
            if(param1 > 0)
            {
               if(param2.type == param3.type && (param2.type == 1 || param2.type == 2) && param2.sentTimeStamp() < param3.sentTimeStamp() + 600000)
               {
                  _loc5_ = true;
               }
            }
            else
            {
               _loc4_ = param2.type == 2 && param3.senderId == param2.senderId;
               if(param2.type == param3.type && (param2.type == 1 || _loc4_) && param2.sentTimeStamp() < param3.sentTimeStamp() + 600000)
               {
                  _loc5_ = true;
               }
            }
         }
         return _loc5_;
      }
      
      private function getAvatarWrapper(param1:int) : IWindowController_1
      {
         return UnknownVarFromMainView_IWindowController_1_2.getChildByID(param1) as IWindowController_1;
      }
      
      private function setChatIndicatorVisibility(param1:int, param2:Boolean) : void
      {
         var _loc3_:IWindowController_1 = getAvatarWrapper(param1);
         if(_loc3_ != null)
         {
            _loc3_.findChildByName("chat_indicator").visible = param2;
         }
      }
      
      private function createChatItem(param1:ChatEntry, param2:Boolean = false) : IWindowModel
      {
         var _loc9_:IWidgetWindowController = null;
         var _loc5_:IIlluminaChatBubbleWidget = null;
         var _loc11_:IWindowController_1 = null;
         var _loc10_:IWindowModel = null;
         var _loc4_:IWindowController_1 = null;
         var _loc6_:IWindowController_1 = null;
         var _loc3_:Boolean = false;
         var _loc7_:UnknownIHabboFriendlist1 = null;
         switch(param1.type - 1)
         {
            case 0:
               _loc9_ = UnknownVarFromMainView_IWidgetWindowController_1.clone() as IWidgetWindowController;
               _loc9_.width = conversationItemWidth;
               _loc5_ = _loc9_.widget as IIlluminaChatBubbleWidget;
               _loc5_.flipped = false;
               _loc5_.appendMessage(param1.message,false,param1.awaitConfirmationId);
               _loc5_.timeStamp = param1.sentTimeStamp();
               _loc5_.figure = _messenger.sessionDataManager.figure;
               _loc5_.userName = _messenger.sessionDataManager.userName;
               _loc7_ = _messenger.getFriend(UnknownVarFromMainView_Int_2);
               if(!param2 && _loc7_ != null && !_loc7_.online && (_loc7_.persistedMessageUser || _loc7_.pocketHabboUser))
               {
                  _loc5_.friendOnlineStatus = false;
               }
               return _loc9_;
            case 1:
               _loc9_ = UnknownVarFromMainView_IWidgetWindowController_1.clone() as IWidgetWindowController;
               _loc9_.width = conversationItemWidth;
               _loc5_ = _loc9_.widget as IIlluminaChatBubbleWidget;
               _loc5_.flipped = true;
               _loc5_.appendMessage(param1.message);
               _loc5_.timeStamp = param1.sentTimeStamp();
               for each(var _loc8_ in UnknownVarFromMainView_IWindowController_1_2.iterator)
               {
                  _loc3_ = _loc8_ != null && _loc8_.id == UnknownVarFromMainView_Int_2;
                  if(!_loc3_ && _loc8_ != null && UnknownVarFromMainView_Int_2 < 0)
                  {
                     _loc3_ = Number(_loc8_.name) == UnknownVarFromMainView_Int_2;
                  }
                  if(_loc3_)
                  {
                     _loc5_.figure = param1.senderFigure;
                     _loc5_.userId = param1.senderId;
                     _loc5_.userName = param1.senderName;
                     break;
                  }
               }
               return _loc9_;
            case 2:
               _loc4_ = UnknownVarFromMainView_IWindowController_1_4.clone() as IWindowController_1;
               _loc4_.findChildByName("content").width = conversationItemWidth - 55;
               _loc4_.findChildByName("content").caption = param1.messageText;
               return _loc4_;
            case 3:
               _loc11_ = UnknownVarFromMainView_IWindowController_1_6.clone() as IWindowController_1;
               _loc10_ = _loc11_.findChildByName("content");
               _loc10_.limits.minWidth = conversationItemWidth;
               _loc10_.limits.maxWidth = conversationItemWidth;
               _loc10_.caption = param1.messageText;
               return _loc11_;
            case 4:
               _loc6_ = UnknownVarFromMainView_IWindowController_1_5.clone() as IWindowController_1;
               _loc6_.findChildByName("content").width = conversationItemWidth - 55;
               _loc6_.findChildByName("content").caption = param1.messageText;
               return _loc6_;
            default:
               return null;
         }
      }
      
      private function appendChatEntry(param1:ChatEntry) : IWindowModel
      {
         var _loc2_:IWindowModel = createChatItem(param1);
         UnknownVarFromMainView_IItemListWindow_1.addListItem(_loc2_);
         return _loc2_;
      }
      
      private function adjustListItemWidths() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IWindowModel = null;
         var _loc3_:IWindowModel = null;
         _loc1_ = 0;
         while(_loc1_ < UnknownVarFromMainView_IItemListWindow_1.numListItems)
         {
            _loc2_ = UnknownVarFromMainView_IItemListWindow_1.getListItemAt(_loc1_);
            switch(_loc2_.name)
            {
               case "msg_normal":
                  break;
               case "msg_notification":
                  IWindowController_1(_loc2_).findChildByName("content").width = conversationItemWidth - 55;
                  break;
               case "msg_info":
                  _loc3_ = IWindowController_1(_loc2_).findChildByName("content");
                  _loc3_.limits.minWidth = conversationItemWidth;
                  _loc3_.limits.maxWidth = conversationItemWidth;
            }
            _loc2_.width = conversationItemWidth;
            _loc1_++;
         }
         UnknownVarFromMainView_IItemListWindow_1.arrangeListItems();
         _frame.invalidate();
      }
      
      private function get conversationItemWidth() : int
      {
         return _frame.width - 27;
      }
      
      private function refreshButtons() : void
      {
         IItemListWindow(_frame.findChildByName("button_strip")).arrangeListItems();
      }
      
      public function loadMessageHistory(param1:int, param2:Array) : void
      {
         var _loc4_:int = 0;
         var _loc7_:ChatEntry = null;
         var _loc5_:Array = [];
         var _loc3_:int = _messenger.sessionDataManager.userId;
         for each(var _loc6_ in param2)
         {
            if(!(_loc6_.messageId in UnknownVarFromMainView_Dictionary_1))
            {
               _loc4_ = _loc6_.senderId;
               _loc7_ = new ChatEntry(_loc4_ == _loc3_ ? 1 : 2,param1,createBubbleMessage(_loc6_.messageType,_loc6_.message,_loc6_.habbiconId),_loc6_.secondsSinceSent,_loc4_,_loc6_.senderName,_loc6_.senderFigure,_loc6_.messageId);
               _loc5_.push(_loc7_);
            }
         }
         if(_loc5_.length == 0)
         {
            return;
         }
         var _loc8_:Array = _chatEntries[param1];
         if(_loc8_ == null)
         {
            _loc8_ = [];
            _chatEntries[param1] = _loc8_;
         }
         _chatEntries[param1] = _loc5_.concat(_loc8_);
         if(param1 == UnknownVarFromMainView_Int_2)
         {
            if(UnknownVarFromMainView_Int_4 != -1)
            {
               UnknownVarFromMainView_Int_4 += _loc5_.length;
            }
            addMissingChatEntries();
         }
      }
      
      private function requestHistory(param1:int) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Array = _chatEntries[param1];
         if(_loc2_ == null)
         {
            return;
         }
         var _loc5_:String = "";
         if(_loc2_.length > 0)
         {
            _loc5_ = _loc2_[0].messageId;
         }
         var _loc3_:int = getTimer();
         if(param1 in _historyFetchesTimestamps)
         {
            _loc4_ = _historyFetchesTimestamps[param1];
            if(_loc4_.messageId == _loc5_ && _loc4_.time + 4000 > _loc3_)
            {
               return;
            }
         }
         _historyFetchesTimestamps[param1] = {
            "messageId":_loc5_,
            "time":_loc3_
         };
         _messenger.send(new GetMessengerHistoryComposer(param1,_loc5_));
      }
      
      private function refreshConversationList() : void
      {
         UnknownVarFromMainView_Boolean_2 = true;
         UnknownVarFromMainView_IItemListWindow_1.destroyListItems();
         UnknownVarFromMainView_Int_4 = -1;
         scrollBack(true);
         UnknownVarFromMainView_IItemListWindow_1.arrangeListItems();
         UnknownVarFromMainView_IItemListWindow_1.scrollV = 1;
         UnknownVarFromMainView_Boolean_2 = false;
      }
      
      private function addToConversationAndCombine(param1:ChatEntry, param2:ChatEntry, param3:Boolean = false) : Boolean
      {
         var _loc5_:int = 0;
         var _loc7_:IWidgetWindowController = null;
         var _loc4_:IIlluminaChatBubbleWidget = null;
         var _loc6_:Boolean = false;
         if(param2 != null && shouldCombineWithPreviousEntry(UnknownVarFromMainView_Int_2,param1,param2))
         {
            _loc5_ = param3 ? 0 : UnknownVarFromMainView_IItemListWindow_1.numListItems - 1;
            if(_loc5_ >= 0)
            {
               _loc7_ = UnknownVarFromMainView_IItemListWindow_1.getListItemAt(_loc5_) as IWidgetWindowController;
               if(_loc7_ != null)
               {
                  _loc4_ = _loc7_.widget as IIlluminaChatBubbleWidget;
                  if(_loc4_ != null)
                  {
                     _loc4_.appendMessage(param1.message,param3,param1.awaitConfirmationId);
                     if(!param3)
                     {
                        _loc4_.timeStamp = param1.sentTimeStamp();
                     }
                     _loc6_ = true;
                  }
               }
            }
         }
         if(!_loc6_)
         {
            if(param3)
            {
               UnknownVarFromMainView_IItemListWindow_1.addListItemAt(createChatItem(param1,true),0);
            }
            else
            {
               appendChatEntry(param1);
            }
         }
         return _loc6_;
      }
      
      private function addMissingChatEntries() : void
      {
         if(-UnknownVarFromMainView_IItemListWindow_1.scrollableRegion.y > 150)
         {
            return;
         }
         UnknownVarFromMainView_Boolean_2 = true;
         var _loc1_:Number = Number(UnknownVarFromMainView_IItemListWindow_1.scrollV);
         var _loc2_:int = int(UnknownVarFromMainView_IItemListWindow_1.scrollableRegion.height);
         scrollBack();
         UnknownVarFromMainView_IItemListWindow_1.arrangeListItems();
         UnknownVarFromMainView_IItemListWindow_1.scrollV = _loc2_ <= UnknownVarFromMainView_IItemListWindow_1.height ? 1 : 1 - _loc2_ * (1 - _loc1_) / UnknownVarFromMainView_IItemListWindow_1.scrollableRegion.height;
         UnknownVarFromMainView_Boolean_2 = false;
      }
      
      private function scrollBack(param1:Boolean = false) : void
      {
         var _loc7_:int = 0;
         var _loc4_:ChatEntry = null;
         var _loc2_:Array = _chatEntries[UnknownVarFromMainView_Int_2];
         if(_loc2_ == null)
         {
            requestHistory(UnknownVarFromMainView_Int_2);
            return;
         }
         var _loc10_:int = int(UnknownVarFromMainView_Int_4 == -1 ? _loc2_.length : UnknownVarFromMainView_Int_4);
         var _loc3_:int = int(param1 ? 3 : 1);
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc6_:int = 0;
         var _loc5_:ChatEntry = UnknownVarFromMainView_Int_4 == -1 ? null : _loc2_[UnknownVarFromMainView_Int_4];
         _loc7_ = _loc10_ - 1;
         while(_loc7_ >= 0)
         {
            _loc4_ = _loc2_[_loc7_];
            if(_loc9_ && !shouldCombineWithPreviousEntry(UnknownVarFromMainView_Int_2,_loc4_,_loc5_))
            {
               break;
            }
            if(!addToConversationAndCombine(_loc4_,_loc5_,true))
            {
               _loc8_ += 1;
            }
            _loc5_ = _loc4_;
            _loc6_ += 1;
            UnknownVarFromMainView_Int_4 = _loc7_;
            if(_loc8_ >= 3 * _loc3_)
            {
               _loc9_ = true;
            }
            if(_loc6_ >= 7 * _loc3_)
            {
               break;
            }
            _loc7_--;
         }
         if(UnknownVarFromMainView_Int_4 < 40)
         {
            requestHistory(UnknownVarFromMainView_Int_2);
         }
      }
      
      private function refreshAvatarList() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         UnknownVarFromMainView_Boolean_1 = false;
         for each(var _loc4_ in UnknownVarFromMainView_IWindowController_1_2.iterator)
         {
            _loc1_ = _loc4_.id == UnknownVarFromMainView_Int_2;
            if(!_loc1_ && _loc4_.name.length > 0)
            {
               _loc1_ = Number(_loc4_.name) == UnknownVarFromMainView_Int_2;
            }
            if(_loc1_)
            {
               setAvatarVisibilityTag(_loc4_,true);
            }
            _loc2_ = avatarVisible(_loc4_);
            if(_loc5_ < UnknownVarFromMainView_Int_1 || !_loc2_ || UnknownVarFromMainView_Boolean_1)
            {
               _loc4_.visible = false;
            }
            else if(_loc3_ + _loc4_.width > UnknownVarFromMainView_IWindowController_1_2.width)
            {
               _loc4_.visible = false;
               UnknownVarFromMainView_Boolean_1 = true;
            }
            else
            {
               _loc4_.visible = true;
               _loc4_.blend = _loc1_ ? 1 : 0;
               _loc4_.x = _loc3_;
               _loc3_ += _loc4_.width;
            }
            if(_loc2_)
            {
               _loc5_++;
            }
         }
         _frame.findChildByName("avatars_scroll_left").visible = UnknownVarFromMainView_Int_1 > 0;
         _frame.findChildByName("avatars_scroll_right").visible = UnknownVarFromMainView_Boolean_1;
      }
      
      private function get visibleAvatarCount() : int
      {
         var _loc1_:int = 0;
         for each(var _loc2_ in UnknownVarFromMainView_IWindowController_1_2.iterator)
         {
            if(avatarVisible(_loc2_))
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function get hasUnreadChat() : Boolean
      {
         var _loc1_:IWindowController_1 = null;
         for each(var _loc2_ in UnknownVarFromMainView_IWindowController_1_2.iterator)
         {
            if(avatarVisible(_loc2_))
            {
               _loc1_ = IWindowController_1(_loc2_);
               if(_loc1_ != null)
               {
                  if(_loc1_.findChildByName("chat_indicator").visible)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private function setupRemoveFriendButton() : void
      {
         var strip:IItemListWindow = null;
         var report:IWindowModel = null;
         var removeBtn:IWindowModel = null;
         var tip:IInteractiveWindow = null;
         var split:int = 0;
         try
         {
            strip = _frame.findChildByName("button_strip") as IItemListWindow;
            report = _frame.findChildByName("report_button");
            if(strip == null || report == null || _frame.findChildByName("remove_friend_button") != null)
            {
               return;
            }
            removeBtn = report.clone();
            removeBtn.name = "remove_friend_button";
            removeBtn.caption = "Remover";
            tip = removeBtn as IInteractiveWindow;
            if(tip != null)
            {
               tip.toolTipCaption = "Remover amigo";
            }
            split = int(report.width / 2);
            if(split < 70)
            {
               split = 70;
            }
            report.limits.minWidth = 0;
            removeBtn.limits.minWidth = 0;
            report.width = split;
            removeBtn.width = split;
            strip.addListItem(removeBtn);
            strip.arrangeListItems();
         }
         catch(err:Error)
         {
            Logger.log("[messenger] remove friend button failed " + err.message);
         }
      }
      
      private function refreshRemoveFriendButton() : void
      {
         var removeBtn:IWindowModel = null;
         try
         {
            removeBtn = _frame.findChildByName("remove_friend_button");
            if(removeBtn != null)
            {
               removeBtn.visible = UnknownVarFromMainView_Int_2 > 0;
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function confirmRemoveFriend() : void
      {
         var friend:UnknownIHabboFriendlist1 = null;
         var name:String = null;
         if(UnknownVarFromMainView_Int_2 <= 0)
         {
            return;
         }
         _pendingRemoveFriendId = UnknownVarFromMainView_Int_2;
         friend = _messenger.getFriend(_pendingRemoveFriendId);
         name = friend != null ? friend.name : "";
         _messenger.windowManager.confirm("Remover amigo",name.length > 0 ? "Tem certeza que deseja remover " + name + " da sua lista de amigos?" : "Tem certeza que deseja remover este amigo?",0x10 | 0x20,onRemoveFriendConfirmation);
      }
      
      private function onRemoveFriendConfirmation(param1:UnknownICoreWindowUtils1, param2:WindowEvent) : void
      {
         var composer:RemoveFriendMessageComposer = null;
         if(param2.type == "WE_OK" && _pendingRemoveFriendId > 0)
         {
            composer = new RemoveFriendMessageComposer();
            composer.addRemovedFriend(_pendingRemoveFriendId);
            _messenger.send(composer);
            hideConversation(_pendingRemoveFriendId);
         }
         _pendingRemoveFriendId = 0;
         param1.dispose();
      }
      
      private function messengerWindowProcedure(param1:WindowEvent, param2:IWindowModel) : void
      {
         var _loc3_:Boolean = false;
         switch(param1.type)
         {
            case "WE_RESIZE":
               if(param2 == _frame)
               {
                  adjustListItemWidths();
                  refreshAvatarList();
                  if(UnknownVarFromMainView_MessengerHabbiconPicker_1 != null && UnknownVarFromMainView_MessengerHabbiconPicker_1.visible)
                  {
                     positionHabbiconPicker();
                  }
               }
               break;
            case "WE_RELOCATED":
               if(param2.name == "_CONTAINER" && !UnknownVarFromMainView_Boolean_2)
               {
                  addMissingChatEntries();
               }
               break;
            case "WME_CLICK":
               _loc3_ = true;
               switch(param2.name)
               {
                  case "avatar_click_region":
                     selectConversation(param2.parent.id);
                     break;
                  case "avatars_scroll_left":
                     if(UnknownVarFromMainView_Int_1 > 0)
                     {
                        UnknownVarFromMainView_Int_1 = UnknownVarFromMainView_Int_1 - 1;
                        refreshAvatarList();
                     }
                     break;
                  case "avatars_scroll_right":
                     if(UnknownVarFromMainView_Boolean_1)
                     {
                        UnknownVarFromMainView_Int_1 = UnknownVarFromMainView_Int_1 + 1;
                        refreshAvatarList();
                     }
                     break;
                  case "close_conversation_button":
                     hideConversation(UnknownVarFromMainView_Int_2);
                     break;
                  case "follow_button":
                     if(UnknownVarFromMainView_Int_2 > 0)
                     {
                        _messenger.send(new FollowFriendMessageComposer(UnknownVarFromMainView_Int_2));
                        _messenger.send(new EventLogMessageComposer("Navigation","IM","go.im"));
                     }
                     else
                     {
                        _messenger.followingToGroupRoom = true;
                        _messenger.send(new GetHabboGroupDetailsMessageComposer(Math.abs(UnknownVarFromMainView_Int_2),false));
                     }
                     break;
                  case "profile_button":
                     if(UnknownVarFromMainView_Int_2 > 0)
                     {
                        _messenger.send(new GetExtendedProfileMessageComposer(UnknownVarFromMainView_Int_2));
                        _messenger.trackGoogle("extendedProfile","messenger_conversation");
                     }
                     else
                     {
                        _messenger.send(new GetHabboGroupDetailsMessageComposer(Math.abs(UnknownVarFromMainView_Int_2),true));
                        _messenger.trackGoogle("extendedProfile","messenger_conversation");
                     }
                     break;
                  case "report_button":
                     _messenger.reportUser(UnknownVarFromMainView_Int_2);
                     break;
                  case "remove_friend_button":
                     confirmRemoveFriend();
                     break;
                  case "habbicon_button":
                     toggleHabbiconPicker();
                     _loc3_ = false;
                     break;
                  case "header_button_close":
                     hide();
               }
               if(_loc3_)
               {
                  hideHabbiconPickerIfOutside(param2);
               }
               break;
            case "WME_CLICK_AWAY":
               hideHabbiconPickerIfOutside(param1.related);
         }
      }
      
      public function onInput(param1:IWidgetWindowController, param2:String) : void
      {
         if(param2 == "")
         {
            return;
         }
         var _loc5_:int = UnknownVarFromMainView_Int_3;
         UnknownVarFromMainView_Int_3 += 1;
         _messenger.send(new SendMsgMessageComposer(UnknownVarFromMainView_Int_2,param2,_loc5_));
         IIlluminaInputWidget(param1.widget).message = "";
         var _loc3_:Array = _chatEntries[UnknownVarFromMainView_Int_2];
         if(_loc3_.length == 0 || _loc3_.length == 1 && ChatEntry(_loc3_[0]).type == 3)
         {
            _messenger.playSendSound();
         }
         var _loc4_:String = _messenger.sessionDataManager.figure;
         var _loc6_:String = _messenger.sessionDataManager.userName;
         var _loc7_:int = _messenger.sessionDataManager.userId;
         recordChatMessage(UnknownVarFromMainView_Int_2,IlluminaChatBubbleMessage.text(escapeExternalKeys(param2)),false,0,_loc7_,_loc6_,_loc4_,"",_loc5_);
      }
      
      private function toggleHabbiconPicker() : void
      {
         ensureHabbiconPicker();
         if(UnknownVarFromMainView_MessengerHabbiconPicker_1.visible)
         {
            UnknownVarFromMainView_MessengerHabbiconPicker_1.hide();
            return;
         }
         UnknownVarFromMainView_MessengerHabbiconPicker_1.show();
         positionHabbiconPicker();
      }
      
      private function ensureHabbiconPicker() : void
      {
         if(UnknownVarFromMainView_MessengerHabbiconPicker_1 != null)
         {
            return;
         }
         var _loc1_:IWindowController_1 = _messenger.getXmlWindow("messenger_habbicon_picker") as IWindowController_1;
         UnknownVarFromMainView_IWindowController_1_1.addChild(_loc1_);
         UnknownVarFromMainView_MessengerHabbiconPicker_1 = new MessengerHabbiconPicker(_loc1_,_messenger.habbiconController,_messenger.localization,_messenger.windowManager,onHabbiconSelected);
      }
      
      private function positionHabbiconPicker() : void
      {
         var _loc3_:Rectangle = new Rectangle();
         var _loc2_:Rectangle = new Rectangle();
         var _loc1_:Point = new Point();
         habbiconButton.getGlobalRectangle(_loc3_);
         inputWidget.getGlobalRectangle(_loc2_);
         UnknownVarFromMainView_IWindowController_1_1.getGlobalPosition(_loc1_);
         UnknownVarFromMainView_MessengerHabbiconPicker_1.setPosition(_loc3_.x - _loc1_.x,_loc2_.y - _loc1_.y - UnknownVarFromMainView_MessengerHabbiconPicker_1.window.height - 4);
      }
      
      private function hideHabbiconPicker() : void
      {
         if(UnknownVarFromMainView_MessengerHabbiconPicker_1 != null)
         {
            UnknownVarFromMainView_MessengerHabbiconPicker_1.hide();
         }
      }
      
      private function hideHabbiconPickerIfOutside(param1:IWindowModel) : void
      {
         if(UnknownVarFromMainView_MessengerHabbiconPicker_1 != null && UnknownVarFromMainView_MessengerHabbiconPicker_1.visible && !isWindowInTree(param1,habbiconButton) && !UnknownVarFromMainView_MessengerHabbiconPicker_1.containsWindow(param1))
         {
            UnknownVarFromMainView_MessengerHabbiconPicker_1.hide();
         }
      }
      
      private function onHabbiconSelected(param1:int, param2:Boolean) : void
      {
         if(UnknownVarFromMainView_Int_2 == -1 || param1 <= 0)
         {
            return;
         }
         var _loc5_:int = UnknownVarFromMainView_Int_3;
         UnknownVarFromMainView_Int_3 += 1;
         _messenger.send(new SendHabbiconMessageComposer(UnknownVarFromMainView_Int_2,param1,_loc5_));
         var _loc3_:Array = _chatEntries[UnknownVarFromMainView_Int_2];
         if(_loc3_.length == 0 || _loc3_.length == 1 && ChatEntry(_loc3_[0]).type == 3)
         {
            _messenger.playSendSound();
         }
         var _loc4_:String = _messenger.sessionDataManager.figure;
         var _loc6_:String = _messenger.sessionDataManager.userName;
         var _loc7_:int = _messenger.sessionDataManager.userId;
         recordChatMessage(UnknownVarFromMainView_Int_2,IlluminaChatBubbleMessage.habbicon(param1),false,0,_loc7_,_loc6_,_loc4_,"",_loc5_);
         if(_messenger.habbiconController != null)
         {
            _messenger.habbiconController.noteHabbiconUsed(param1);
         }
      }
      
      private function get habbiconButton() : IWindowModel
      {
         return _frame.findChildByName("habbicon_button");
      }
      
      private function get inputWidget() : IWindowModel
      {
         return _frame.findChildByName("input_widget");
      }
   }
}

