package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.components.IWidgetWindowController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.habbo.window.widgets.IAvatarImageWidget;
   import com.sulake.habbo.window.widgets.IIlluminaChatBubbleWidget;
   import com.sulake.habbo.window.widgets.IIlluminaInputHandler;
   import com.sulake.habbo.window.widgets.IIlluminaInputWidget;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class BobbaGroupChatEditor implements IIlluminaInputHandler
   {
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_chat";
      
      private static const HEAD_SIZE:int = 35;
      
      private static const HEAD_GAP:int = 2;
      
      private static const HEAD_OFFSET_Y:int = 5;
      
      private static const SCROLL_W:int = 15;
      
      private static const AVATAR_LIST_X:int = 16;
      
      private static const AVATAR_LIST_W:int = 248;
      
      private static const SCROLL_RIGHT_X:int = 265;
      
      private static const HEADS_Y:int = 0;
      
      private static const HEADS_H:int = 40;
      
      private static const LINKS_Y:int = 42;
      
      private static const SEPARATOR_Y:int = 60;
      
      private static const CHAT_Y:int = 61;
      
      private static const CHAT_H:int = 160;
      
      /** Must match bobba-client-backend SYS_*_PREFIX. */
      private static const SYS_INVITATION_PREFIX:String = "\u0001sys:invitation\u0001";
      
      private static const SYS_NOTIFICATION_PREFIX:String = "\u0001sys:notification\u0001";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _chatMsgTemplate:IWidgetWindowController;
      
      private var _systemMsgTemplate:IWindowController_1;
      
      private var _invitationMsgTemplate:IWindowController_1;
      
      private var _notificationMsgTemplate:IWindowController_1;
      
      private var _avatarTileTemplate:IWindowController_1;
      
      private var _groupId:String = "";
      
      private var _groupName:String = "";
      
      private var _ownName:String = "";
      
      private var _ownFigure:String = "";
      
      private var _members:Array;
      
      private var _figuresByNick:Dictionary;
      
      private var _headerHeadWidgets:Array;
      
      private var _addLink:IWindowModel;
      
      private var _avatarList:IWindowController_1;
      
      private var _scrollLeft:IWindowModel;
      
      private var _scrollRight:IWindowModel;
      
      private var _avatarScrollIndex:int = 0;
      
      private var _avatarOverflow:Boolean = false;
      
      public function BobbaGroupChatEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
         _members = [];
         _figuresByNick = new Dictionary();
         _headerHeadWidgets = [];
         _avatarScrollIndex = 0;
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
      
      public function setGroup(groupId:String, groupName:String) : void
      {
         _groupId = groupId != null ? groupId : "";
         _groupName = groupName != null ? groupName : BobbaI18n.t("group.chat.default_title");
         refreshOwnUser();
         _members = [];
         _figuresByNick = new Dictionary();
         if(_window != null)
         {
            _window.caption = _groupName;
            clearChatList();
            refreshHeaderHeads();
         }
      }
      
      public function setMembers(members:Array) : void
      {
         var i:int = 0;
         var m:Object = null;
         var nick:String = null;
         var fig:String = null;
         _members = members != null ? members : [];
         for(i = 0; i < _members.length; i++)
         {
            m = _members[i];
            nick = String(m.nickname);
            fig = m.figure != null ? String(m.figure) : "";
            if(fig.length > 0)
            {
               _figuresByNick[nick] = fig;
            }
         }
         refreshHeaderHeads();
      }
      
      public function rememberFigure(nickname:String, figure:String) : void
      {
         if(nickname == null || nickname.length == 0 || figure == null || figure.length == 0)
         {
            return;
         }
         if(_figuresByNick == null)
         {
            _figuresByNick = new Dictionary();
         }
         _figuresByNick[nickname] = figure;
      }
      
      public function setHistory(messages:Array) : void
      {
         var i:int = 0;
         var m:Object = null;
         clearChatList();
         if(messages == null)
         {
            scrollChatListToBottom();
            return;
         }
         for(i = 0; i < messages.length; i++)
         {
            m = messages[i];
            if(m.senderFigure != null && String(m.senderFigure).length > 0)
            {
               rememberFigure(String(m.senderNickname),String(m.senderFigure));
            }
            appendChatOrSystem(String(m.senderNickname),String(m.body),int(m.timestamp),m.senderFigure != null ? String(m.senderFigure) : "");
         }
         scrollChatListToBottom();
      }
      
      public function appendChatOrSystem(sender:String, body:String, timestamp:int, senderFigure:String = "") : void
      {
         if(body != null && body.indexOf(SYS_INVITATION_PREFIX) == 0)
         {
            appendSystemMessage(body.substr(SYS_INVITATION_PREFIX.length),"invitation");
            return;
         }
         if(body != null && body.indexOf(SYS_NOTIFICATION_PREFIX) == 0)
         {
            appendSystemMessage(body.substr(SYS_NOTIFICATION_PREFIX.length),"notification");
            return;
         }
         appendMessage(sender,body,timestamp,senderFigure);
      }
      
      public function appendMessage(sender:String, body:String, timestamp:int, senderFigure:String = "") : void
      {
         var bubble:IWidgetWindowController = null;
         var widget:IIlluminaChatBubbleWidget = null;
         var list:IItemListWindow = null;
         var flipped:Boolean = false;
         var figure:String = "";
         var nick:String = sender != null ? sender : "";
         if(_window == null || _chatMsgTemplate == null)
         {
            return;
         }
         try
         {
            if(senderFigure != null && senderFigure.length > 0)
            {
               rememberFigure(sender,senderFigure);
            }
            list = IItemListWindow(_window.findChildByName("chat_list"));
            bubble = getLastChatBubble(list);
            if(bubble != null && bubble.name == "chat_msg_0")
            {
               widget = bubble.widget as IIlluminaChatBubbleWidget;
               if(widget != null && widget.userName == nick)
               {
                  widget.appendMessage(body);
                  hideChatTypingIndicator(list);
                  scrollChatListToBottom(list);
                  return;
               }
            }
            bubble = IWidgetWindowController(_chatMsgTemplate.clone());
            widget = IIlluminaChatBubbleWidget(bubble.widget);
            flipped = nick == _ownName;
            figure = resolveFigure(nick);
            if((figure == null || figure.length == 0) && senderFigure != null)
            {
               figure = senderFigure;
            }
            bubble.name = "chat_msg_0";
            widget.figure = figure != null ? figure : "";
            widget.flipped = flipped;
            widget.userName = nick;
            widget.userId = flipped ? 1 : 2;
            widget.appendMessage(body);
            addItemAndScrollChatList(list,bubble);
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] append failed",err.message);
         }
      }
      
      public function appendSystemMessage(text:String, kind:String = "notification") : void
      {
         var note:IWindowController_1 = null;
         var content:IWindowModel = null;
         var list:IItemListWindow = null;
         var template:IWindowController_1 = null;
         var chatWidth:int = 270;
         if(_window == null || text == null || text.length == 0)
         {
            return;
         }
         try
         {
            ensureMessengerAlertTemplates();
            list = IItemListWindow(_window.findChildByName("chat_list"));
            if(list == null)
            {
               return;
            }
            if(kind == "invitation")
            {
               template = _invitationMsgTemplate;
            }
            else
            {
               template = _notificationMsgTemplate;
            }
            if(template == null)
            {
               template = _systemMsgTemplate;
            }
            if(template != null)
            {
               note = template.clone() as IWindowController_1;
            }
            if(note == null)
            {
               note = buildFallbackSystemMessage(text);
            }
            else
            {
               content = note.findChildByName("content");
               if(list.width > 0)
               {
                  chatWidth = int(list.width);
               }
               if(content != null)
               {
                  content.width = chatWidth - 55;
                  content.caption = text;
               }
               else
               {
                  note.caption = text;
               }
               note.width = chatWidth;
            }
            if(note == null)
            {
               return;
            }
            note.name = kind == "invitation" ? "msg_invitation" : "msg_notification";
            addItemAndScrollChatList(list,note);
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] system msg failed",err.message);
         }
      }
      
      public function clearMessages() : void
      {
         clearChatList();
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         clearHeaderHeads();
         if(_avatarTileTemplate != null)
         {
            _avatarTileTemplate.dispose();
            _avatarTileTemplate = null;
         }
         if(_systemMsgTemplate != null)
         {
            _systemMsgTemplate.dispose();
            _systemMsgTemplate = null;
         }
         if(_invitationMsgTemplate != null)
         {
            _invitationMsgTemplate.dispose();
            _invitationMsgTemplate = null;
         }
         if(_notificationMsgTemplate != null)
         {
            _notificationMsgTemplate.dispose();
            _notificationMsgTemplate = null;
         }
         if(_chatMsgTemplate != null)
         {
            _chatMsgTemplate.dispose();
            _chatMsgTemplate = null;
         }
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
         _controller = null;
         _members = null;
         _figuresByNick = null;
         _headerHeadWidgets = null;
         _addLink = null;
         _avatarList = null;
         _scrollLeft = null;
         _scrollRight = null;
      }
      
      public function onInput(widget:IWidgetWindowController, message:String) : void
      {
         if(_controller != null && message != null && message.length > 0)
         {
            _controller.sendChat(message);
         }
         try
         {
            IIlluminaInputWidget(IWidgetWindowController(_window.findChildByName("input_widget")).widget).message = "";
         }
         catch(err:Error)
         {
         }
      }
      
      private function createWindow() : void
      {
         var input:IIlluminaInputWidget = null;
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"guide_ongoing") as IFrameController;
            if(_window == null)
            {
               return;
            }
            _chatMsgTemplate = BobbaHabboXml.getXmlWindow(_windowManager,"chat_msg") as IWidgetWindowController;
            ensureMessengerAlertTemplates();
            _window.procedure = windowProcedure;
            setupHeaderChrome();
            if(_window.findChildByName("close_link") != null)
            {
               _window.findChildByName("close_link").caption = BobbaI18n.t("group.chat.leave");
            }
            clearChatList();
            input = IIlluminaInputWidget(IWidgetWindowController(_window.findChildByName("input_widget")).widget);
            input.submitHandler = this;
            input.emptyMessage = BobbaI18n.t("group.chat.input_placeholder");
            input.maxChars = 500;
            refreshOwnUser();
            if(_groupName.length > 0)
            {
               _window.caption = _groupName;
            }
            refreshHeaderHeads();
            _window.center();
            _window.visible = true;
            _window.activate();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
            Logger.log("[BobbaGroupChat] create failed",e.message);
         }
      }
      
      private function setupHeaderChrome() : void
      {
         var visitBtn:IWindowModel = null;
         var inviteBtn:IWindowModel = null;
         var stockRow:IWindowModel = null;
         var membersLink:IWindowModel = null;
         var chatList:IWindowModel = null;
         var content:IWindowController_1 = null;
         var child:IWindowModel = null;
         var i:int = 0;
         var layout:XML = null;
         var built:IWindowModel = null;
         try
         {
            visitBtn = _window.findChildByName("visit_button");
            inviteBtn = _window.findChildByName("invite_button");
            membersLink = _window.findChildByName("report_link");
            if(inviteBtn != null)
            {
               stockRow = inviteBtn.parent;
            }
            else if(visitBtn != null)
            {
               stockRow = visitBtn.parent;
            }
            if(visitBtn != null)
            {
               try
               {
                  if(stockRow is IItemListWindow)
                  {
                     IItemListWindow(stockRow).removeListItem(visitBtn as IWindowController_1);
                  }
               }
               catch(visitRemErr:Error)
               {
               }
               visitBtn.dispose();
            }
            if(inviteBtn != null)
            {
               try
               {
                  if(stockRow is IItemListWindow)
                  {
                     IItemListWindow(stockRow).removeListItem(inviteBtn as IWindowController_1);
                  }
               }
               catch(inviteRemErr:Error)
               {
               }
               inviteBtn.dispose();
            }
            if(stockRow != null)
            {
               stockRow.visible = false;
            }
            buildAvatarListChrome();
            layout = <layout name="bobba_add_link" width="90" height="16" version="0.1">
                  <window>
                     <link x="0" y="0" width="90" height="16" params="1" style="100" name="add_link" caption="Add" treshold="0">
                        <variables>
                           <var key="auto_size" value="left" type="String"/>
                           <var key="mouse_wheel_enabled" value="false" type="Boolean"/>
                           <var key="underline" value="true" type="Boolean"/>
                           <var key="spacing" value="0" type="Number"/>
                           <var key="leading" value="0" type="Number"/>
                        </variables>
                     </link>
                  </window>
               </layout>;
            built = _windowManager.buildFromXML(layout,1);
            _addLink = built != null ? built.findChildByName("add_link") : null;
            if(_addLink == null)
            {
               _addLink = built;
            }
            if(_addLink != null)
            {
               _addLink.name = "add_link";
               _addLink.caption = BobbaI18n.t("group.chat.add");
               _addLink.x = 10;
               _addLink.y = LINKS_Y;
               if(_window.content != null)
               {
                  _window.content.addChild(_addLink);
               }
               else
               {
                  _window.addChild(_addLink);
               }
            }
            if(membersLink != null)
            {
               membersLink.visible = true;
               membersLink.caption = BobbaI18n.t("group.chat.members");
               membersLink.x = 170;
               membersLink.y = LINKS_Y;
               try
               {
                  membersLink["toolTipCaption"] = BobbaI18n.t("group.chat.members_tooltip");
               }
               catch(membersTipErr:Error)
               {
               }
            }
            chatList = _window.findChildByName("chat_list");
            if(chatList != null)
            {
               chatList.y = CHAT_Y;
               chatList.height = CHAT_H;
            }
            content = _window.content;
            if(content != null)
            {
               for(i = 0; i < content.numChildren; i++)
               {
                  child = content.getChildAt(i);
                  if(child != null && child.name != "chat_list" && child.name != "report_link" && child.name != "add_link" && child.name != "avatar_list" && child.name != "avatars_scroll_left" && child.name != "avatars_scroll_right")
                  {
                     if(child.y >= 35 && child.y <= 40 && child.height <= 4)
                     {
                        child.y = SEPARATOR_Y;
                     }
                  }
               }
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] header chrome failed",err.message);
         }
      }
      
      private function buildAvatarListChrome() : void
      {
         var messenger:* = null;
         var frame:IWindowController_1 = null;
         var listSrc:IWindowController_1 = null;
         var leftSrc:IWindowModel = null;
         var rightSrc:IWindowModel = null;
         var parent:IWindowController_1 = null;
         try
         {
            parent = _window.content != null ? _window.content : _window as IWindowController_1;
            messenger = loadMessengerWindow();
            if(messenger != null)
            {
               frame = messenger.findChildByName("frame") as IWindowController_1;
               if(frame == null)
               {
                  frame = messenger as IWindowController_1;
               }
               if(frame != null)
               {
                  listSrc = frame.findChildByName("avatar_list") as IWindowController_1;
                  leftSrc = frame.findChildByName("avatars_scroll_left");
                  rightSrc = frame.findChildByName("avatars_scroll_right");
                  if(listSrc != null && listSrc.numChildren > 0)
                  {
                     _avatarTileTemplate = listSrc.getChildAt(0).clone() as IWindowController_1;
                     _avatarList = listSrc.clone() as IWindowController_1;
                  }
                  if(leftSrc != null)
                  {
                     _scrollLeft = leftSrc.clone();
                  }
                  if(rightSrc != null)
                  {
                     _scrollRight = rightSrc.clone();
                  }
               }
               try
               {
                  messenger.dispose();
               }
               catch(disposeMessengerErr:Error)
               {
               }
            }
            if(_avatarList != null)
            {
               while(_avatarList.numChildren > 0)
               {
                  _avatarList.removeChildAt(0).dispose();
               }
               _avatarList.name = "avatar_list";
               _avatarList.x = AVATAR_LIST_X;
               _avatarList.y = HEADS_Y;
               _avatarList.width = AVATAR_LIST_W;
               _avatarList.height = HEADS_H;
               parent.addChild(_avatarList);
            }
            if(_scrollLeft != null)
            {
               _scrollLeft.name = "avatars_scroll_left";
               _scrollLeft.x = 0;
               _scrollLeft.y = HEADS_Y;
               _scrollLeft.visible = false;
               parent.addChild(_scrollLeft);
            }
            if(_scrollRight != null)
            {
               _scrollRight.name = "avatars_scroll_right";
               _scrollRight.x = SCROLL_RIGHT_X;
               _scrollRight.y = HEADS_Y;
               _scrollRight.visible = false;
               parent.addChild(_scrollRight);
            }
            if(_avatarTileTemplate == null)
            {
               ensureAvatarTileTemplate();
            }
            if(_avatarList == null)
            {
               ensureFallbackAvatarList(parent);
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] avatar list chrome failed",err.message);
            try
            {
               if(messenger != null)
               {
                  messenger.dispose();
               }
            }
            catch(cleanupErr:Error)
            {
            }
            ensureFallbackAvatarList(parent);
         }
      }
      
      private function loadMessengerWindow() : *
      {
         var assetClass:Class = null;
         var bytes:ByteArray = null;
         var built:* = null;
         try
         {
            assetClass = HabboMessengerCom.messenger_xml as Class;
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
            built = _windowManager.buildFromXML(XML(bytes.readUTFBytes(bytes.length)),1);
            return built;
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] messenger xml failed",err.message);
         }
         return null;
      }
      
      private function ensureFallbackAvatarList(parent:IWindowController_1) : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         if(parent == null)
         {
            return;
         }
         try
         {
            if(_avatarList == null)
            {
               layout = <layout name="bobba_avatar_list" width="248" height="40" version="0.1">
                     <window>
                        <container x="0" y="0" width="248" height="40" params="144" style="103" name="avatar_list"/>
                     </window>
                  </layout>;
               built = _windowManager.buildFromXML(layout,1);
               _avatarList = built as IWindowController_1;
               if(_avatarList == null && built != null)
               {
                  _avatarList = built.findChildByName("avatar_list") as IWindowController_1;
               }
               if(_avatarList != null)
               {
                  _avatarList.name = "avatar_list";
                  _avatarList.x = AVATAR_LIST_X;
                  _avatarList.y = HEADS_Y;
                  _avatarList.width = AVATAR_LIST_W;
                  _avatarList.height = HEADS_H;
                  parent.addChild(_avatarList);
               }
            }
            if(_scrollLeft == null)
            {
               layout = <layout name="bobba_avatars_scroll_left" width="15" height="35" version="0.1">
                     <window>
                        <region x="0" y="0" width="15" height="35" params="17" style="100" name="avatars_scroll_left" treshold="0">
                           <children>
                              <static_bitmap x="7" y="0" width="8" height="35" params="16" style="100">
                                 <variables>
                                    <var key="asset_uri" value="help_habboway_prev" type="String"/>
                                    <var key="pivot_point" value="center left" type="String"/>
                                    <var key="stretched_x" value="false" type="Boolean"/>
                                    <var key="stretched_y" value="false" type="Boolean"/>
                                 </variables>
                              </static_bitmap>
                           </children>
                        </region>
                     </window>
                  </layout>;
               built = _windowManager.buildFromXML(layout,1);
               _scrollLeft = built != null ? built.findChildByName("avatars_scroll_left") : built;
               if(_scrollLeft != null)
               {
                  _scrollLeft.name = "avatars_scroll_left";
                  _scrollLeft.x = 0;
                  _scrollLeft.y = HEADS_Y;
                  _scrollLeft.visible = false;
                  parent.addChild(_scrollLeft);
               }
            }
            if(_scrollRight == null)
            {
               layout = <layout name="bobba_avatars_scroll_right" width="15" height="35" version="0.1">
                     <window>
                        <region x="0" y="0" width="15" height="35" params="81" style="100" name="avatars_scroll_right" treshold="0">
                           <children>
                              <static_bitmap x="1" y="0" width="8" height="35" params="16" style="100">
                                 <variables>
                                    <var key="asset_uri" value="help_habboway_next" type="String"/>
                                    <var key="pivot_point" value="center left" type="String"/>
                                    <var key="stretched_x" value="false" type="Boolean"/>
                                    <var key="stretched_y" value="false" type="Boolean"/>
                                 </variables>
                              </static_bitmap>
                           </children>
                        </region>
                     </window>
                  </layout>;
               built = _windowManager.buildFromXML(layout,1);
               _scrollRight = built != null ? built.findChildByName("avatars_scroll_right") : built;
               if(_scrollRight != null)
               {
                  _scrollRight.name = "avatars_scroll_right";
                  _scrollRight.x = SCROLL_RIGHT_X;
                  _scrollRight.y = HEADS_Y;
                  _scrollRight.visible = false;
                  parent.addChild(_scrollRight);
               }
            }
            if(_avatarTileTemplate == null)
            {
               ensureAvatarTileTemplate();
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] fallback avatar list failed",err.message);
         }
      }
      
      private function ensureMessengerAlertTemplates() : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         if((_invitationMsgTemplate != null && _notificationMsgTemplate != null) || _windowManager == null)
         {
            return;
         }
         try
         {
            if(_invitationMsgTemplate == null)
            {
               layout = <layout name="bobba_msg_invitation" width="255" height="50" version="0.1">
                     <window>
                        <border x="0" y="0" width="255" height="50" params="147472" style="105" name="msg_invitation" color="0x0d1efde">
                           <children>
                              <static_bitmap x="0" y="0" width="50" height="50" params="16" style="100">
                                 <variables>
                                    <var key="asset_uri" value="messenger_notification_icon" type="String"/>
                                    <var key="pivot_point" value="center" type="String"/>
                                    <var key="stretched_x" value="false" type="Boolean"/>
                                    <var key="stretched_y" value="false" type="Boolean"/>
                                 </variables>
                              </static_bitmap>
                              <text x="50" y="15" width="205" height="20" params="3088" style="100" name="content">
                                 <variables>
                                    <var key="auto_size" value="left" type="String"/>
                                    <var key="margin_top" value="7" type="int"/>
                                    <var key="margin_bottom" value="9" type="int"/>
                                    <var key="mouse_wheel_enabled" value="false" type="Boolean"/>
                                    <var key="multiline" value="true" type="Boolean"/>
                                    <var key="word_wrap" value="true" type="Boolean"/>
                                    <var key="spacing" value="0" type="Number"/>
                                    <var key="leading" value="0" type="Number"/>
                                 </variables>
                              </text>
                           </children>
                        </border>
                     </window>
                  </layout>;
               built = _windowManager.buildFromXML(layout,1);
               if(built != null)
               {
                  _invitationMsgTemplate = built as IWindowController_1;
                  if(_invitationMsgTemplate == null || _invitationMsgTemplate.name != "msg_invitation")
                  {
                     _invitationMsgTemplate = built.findChildByName("msg_invitation") as IWindowController_1;
                  }
               }
            }
            if(_notificationMsgTemplate == null)
            {
               layout = <layout name="bobba_msg_notification" width="255" height="50" version="0.1">
                     <window>
                        <border x="0" y="0" width="255" height="50" params="147472" style="105" name="msg_notification">
                           <children>
                              <static_bitmap x="0" y="0" width="50" height="50" params="16" style="100">
                                 <variables>
                                    <var key="asset_uri" value="messenger_caution" type="String"/>
                                    <var key="pivot_point" value="center" type="String"/>
                                    <var key="stretched_x" value="false" type="Boolean"/>
                                    <var key="stretched_y" value="false" type="Boolean"/>
                                 </variables>
                              </static_bitmap>
                              <text x="50" y="15" width="205" height="20" params="3088" style="100" name="content">
                                 <variables>
                                    <var key="auto_size" value="left" type="String"/>
                                    <var key="margin_top" value="7" type="int"/>
                                    <var key="margin_bottom" value="9" type="int"/>
                                    <var key="mouse_wheel_enabled" value="false" type="Boolean"/>
                                    <var key="multiline" value="true" type="Boolean"/>
                                    <var key="word_wrap" value="true" type="Boolean"/>
                                    <var key="spacing" value="0" type="Number"/>
                                    <var key="leading" value="0" type="Number"/>
                                 </variables>
                              </text>
                           </children>
                        </border>
                     </window>
                  </layout>;
               built = _windowManager.buildFromXML(layout,1);
               if(built != null)
               {
                  _notificationMsgTemplate = built as IWindowController_1;
                  if(_notificationMsgTemplate == null || _notificationMsgTemplate.name != "msg_notification")
                  {
                     _notificationMsgTemplate = built.findChildByName("msg_notification") as IWindowController_1;
                  }
               }
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] alert templates failed",err.message);
         }
         if(_notificationMsgTemplate == null)
         {
            try
            {
               built = BobbaHabboXml.getXmlWindow(_windowManager,"chat_msg_notification");
               if(built != null)
               {
                  _systemMsgTemplate = built as IWindowController_1;
                  _notificationMsgTemplate = _systemMsgTemplate;
               }
            }
            catch(fallbackErr:Error)
            {
            }
         }
      }
      
      private function ensureSystemMsgTemplate() : void
      {
         ensureMessengerAlertTemplates();
      }
      
      private function buildFallbackSystemMessage(text:String) : IWindowController_1
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         try
         {
            layout = <layout name="bobba_system_msg" width="260" height="20" version="0.1">
                  <window>
                     <label x="0" y="2" width="260" height="16" params="16" style="100" name="content" caption="">
                        <variables>
                           <var key="auto_size" value="center" type="String"/>
                           <var key="text_color" value="0x555555" type="hex"/>
                        </variables>
                     </label>
                  </window>
               </layout>;
            built = _windowManager.buildFromXML(layout,1);
            if(built != null)
            {
               if(built.findChildByName("content") != null)
               {
                  built.findChildByName("content").caption = text;
               }
               return built as IWindowController_1;
            }
         }
         catch(err:Error)
         {
         }
         return null;
      }
      
      private function resolveFigure(nickname:String) : String
      {
         var fig:String = null;
         if(nickname == _ownName && _ownFigure != null && _ownFigure.length > 0)
         {
            return _ownFigure;
         }
         if(_figuresByNick != null)
         {
            fig = _figuresByNick[nickname] as String;
            if(fig != null && fig.length > 0)
            {
               return fig;
            }
         }
         return "";
      }
      
      private function refreshHeaderHeads() : void
      {
         var i:int = 0;
         var tile:IWindowController_1 = null;
         var m:Object = null;
         var figure:String = null;
         if(_window == null || _avatarList == null)
         {
            return;
         }
         try
         {
            clearHeaderHeads();
            _avatarScrollIndex = 0;
            for(i = 0; i < _members.length; i++)
            {
               m = _members[i];
               figure = resolveFigure(String(m.nickname));
               if((figure == null || figure.length == 0) && m.figure != null)
               {
                  figure = String(m.figure);
               }
               tile = buildAvatarTile(figure);
               if(tile != null)
               {
                  tile.name = "bobba_member_head_" + i;
                  tile.procedure = onHeadClick;
                  try
                  {
                     if(tile.findChildByName("avatar_click_region") != null)
                     {
                        tile.findChildByName("avatar_click_region")["toolTipCaption"] = String(m.nickname);
                     }
                  }
                  catch(tipErr:Error)
                  {
                  }
                  _avatarList.addChild(tile);
                  _headerHeadWidgets.push(tile);
               }
            }
            layoutAvatarList();
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] heads failed",err.message);
         }
      }
      
      private function layoutAvatarList() : void
      {
         var i:int = 0;
         var tile:IWindowModel = null;
         var xPos:int = 0;
         var index:int = 0;
         var tileW:int = HEAD_SIZE;
         _avatarOverflow = false;
         if(_avatarList == null)
         {
            return;
         }
         for(i = 0; i < _headerHeadWidgets.length; i++)
         {
            tile = _headerHeadWidgets[i] as IWindowModel;
            if(tile == null)
            {
               continue;
            }
            tileW = tile.width > 0 ? int(tile.width) : HEAD_SIZE;
            if(index < _avatarScrollIndex)
            {
               tile.visible = false;
            }
            else if(xPos + tileW > _avatarList.width)
            {
               tile.visible = false;
               _avatarOverflow = true;
            }
            else
            {
               tile.visible = true;
               tile.x = xPos;
               tile.y = HEAD_OFFSET_Y;
               tile.blend = 1;
               xPos += tileW + HEAD_GAP;
            }
            index++;
         }
         if(_scrollLeft != null)
         {
            _scrollLeft.visible = _avatarScrollIndex > 0;
         }
         if(_scrollRight != null)
         {
            _scrollRight.visible = _avatarOverflow;
         }
      }
      
      private function clearHeaderHeads() : void
      {
         var i:int = 0;
         var head:IWindowModel = null;
         if(_headerHeadWidgets != null)
         {
            for(i = 0; i < _headerHeadWidgets.length; i++)
            {
               head = _headerHeadWidgets[i] as IWindowModel;
               if(head != null)
               {
                  try
                  {
                     if(head.parent != null)
                     {
                        IWindowController_1(head.parent).removeChild(head);
                     }
                     head.dispose();
                  }
                  catch(err:Error)
                  {
                  }
               }
            }
            _headerHeadWidgets = [];
         }
      }
      
      private function ensureAvatarTileTemplate() : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         if(_avatarTileTemplate != null || _windowManager == null)
         {
            return;
         }
         try
         {
            // Exact messenger_1_xml avatar tile (35x35 border + sh head offset).
            layout = <layout name="bobba_avatar_tile" width="35" height="35" version="0.1">
                  <window>
                     <border x="0" y="0" width="35" height="35" params="16" style="102" name="bobba_avatar_tile">
                        <children>
                           <widget x="-3" y="-14" width="45" height="72" params="16" style="100" name="avatar_image">
                              <variables>
                                 <var key="widget_type" value="avatar_image" type="String"/>
                                 <var key="avatar_image:scale" value="sh" type="String"/>
                                 <var key="avatar_image:only_head" value="true" type="Boolean"/>
                              </variables>
                           </widget>
                           <static_bitmap x="19" y="6" width="13" height="12" params="16" style="100" name="chat_indicator" visible="false">
                              <variables>
                                 <var key="asset_uri" value="common_chat_indicator" type="String"/>
                              </variables>
                           </static_bitmap>
                           <region x="0" y="0" width="35" height="35" params="17" style="100" name="avatar_click_region" treshold="0"/>
                        </children>
                     </border>
                  </window>
               </layout>;
            built = _windowManager.buildFromXML(layout,1);
            _avatarTileTemplate = built as IWindowController_1;
            if(_avatarTileTemplate == null && built != null)
            {
               _avatarTileTemplate = built.findChildByName("bobba_avatar_tile") as IWindowController_1;
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] avatar tile template failed",err.message);
         }
      }
      
      private function buildAvatarTile(figure:String) : IWindowController_1
      {
         var tile:IWindowController_1 = null;
         var avatarWidget:IWidgetWindowController = null;
         var avatar:IAvatarImageWidget = null;
         var indicator:IWindowModel = null;
         ensureAvatarTileTemplate();
         if(_avatarTileTemplate == null)
         {
            return null;
         }
         try
         {
            tile = _avatarTileTemplate.clone() as IWindowController_1;
            if(tile == null)
            {
               return null;
            }
            avatarWidget = tile.findChildByName("avatar_image") as IWidgetWindowController;
            if(avatarWidget != null)
            {
               avatarWidget.visible = true;
               avatar = IAvatarImageWidget(avatarWidget.widget);
               // Messenger centering: scale sh + widget offset (-3,-14), not cropped.
               avatar.scale = "sh";
               avatar.onlyHead = true;
               avatar.cropped = false;
               avatar.figure = figure != null ? figure : "";
            }
            indicator = tile.findChildByName("chat_indicator");
            if(indicator != null)
            {
               indicator.visible = false;
            }
            if(tile.findChildByName("group_badge_image") != null)
            {
               tile.findChildByName("group_badge_image").visible = false;
            }
            return tile;
         }
         catch(err:Error)
         {
         }
         return null;
      }
      
      private function onHeadClick(event:WindowEvent, target:IWindowModel) : void
      {
         var nick:String = null;
         if(event == null || event.type != "WME_CLICK")
         {
            return;
         }
         nick = nicknameFromHeadTarget(target);
         if(nick.length > 0 && _controller != null)
         {
            _controller.openUserProfile(nick);
         }
      }
      
      private function nicknameFromHeadTarget(target:IWindowModel) : String
      {
         var node:IWindowModel = target;
         var index:int = 0;
         var prefix:String = "bobba_member_head_";
         while(node != null)
         {
            if(node.name != null && node.name.indexOf(prefix) == 0)
            {
               index = int(node.name.substring(prefix.length));
               if(_members != null && index >= 0 && index < _members.length && _members[index] != null)
               {
                  return String(_members[index].nickname);
               }
               return "";
            }
            node = node.parent;
         }
         return "";
      }
      
      private function getChatList() : IItemListWindow
      {
         if(_window == null)
         {
            return null;
         }
         try
         {
            return IItemListWindow(_window.findChildByName("chat_list"));
         }
         catch(err:Error)
         {
         }
         return null;
      }
      
      private function getLastChatBubble(list:IItemListWindow = null) : IWidgetWindowController
      {
         if(list == null)
         {
            list = getChatList();
         }
         if(list == null || list.numListItems < 2)
         {
            return null;
         }
         try
         {
            // Last item is the guide_ongoing typing/spacer row.
            return list.getListItemAt(list.numListItems - 2) as IWidgetWindowController;
         }
         catch(err:Error)
         {
         }
         return null;
      }
      
      private function addItemAndScrollChatList(list:IItemListWindow, item:IWindowModel) : void
      {
         if(list == null || item == null)
         {
            return;
         }
         // guide_ongoing keeps a trailing typing/spacer row; insert above it.
         if(list.numListItems > 0)
         {
            list.addListItemAt(item,list.numListItems - 1);
         }
         else
         {
            list.addListItem(item);
         }
         hideChatTypingIndicator(list);
         scrollChatListToBottom(list);
      }
      
      private function scrollChatListToBottom(list:IItemListWindow = null) : void
      {
         if(list == null)
         {
            list = getChatList();
         }
         if(list == null)
         {
            return;
         }
         try
         {
            list.arrangeListItems();
            list.scrollV = 1;
         }
         catch(err:Error)
         {
         }
      }
      
      private function hideChatTypingIndicator(list:IItemListWindow) : void
      {
         var spacer:IWindowModel = null;
         if(list == null || list.numListItems < 1)
         {
            return;
         }
         try
         {
            spacer = list.getListItemAt(list.numListItems - 1);
            if(spacer != null)
            {
               spacer.blend = 0;
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function clearChatList() : void
      {
         var list:IItemListWindow = null;
         if(_window == null)
         {
            return;
         }
         try
         {
            list = getChatList();
            while(list != null && list.numListItems > 1)
            {
               list.removeListItemAt(0);
            }
            hideChatTypingIndicator(list);
            scrollChatListToBottom(list);
         }
         catch(err:Error)
         {
         }
      }
      
      private function refreshOwnUser() : void
      {
         try
         {
            if(_windowManager != null && _windowManager.sessionDataManager != null)
            {
               _ownName = _windowManager.sessionDataManager.userName;
               _ownFigure = _windowManager.sessionDataManager.figure;
            }
         }
         catch(err:Error)
         {
            _ownName = "";
            _ownFigure = "";
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         var nick:String = null;
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK")
         {
            if(target.name == "header_button_close")
            {
               visible = false;
               return;
            }
            if(target.name == "close_link")
            {
               if(_controller != null)
               {
                  _controller.confirmLeaveGroup(_groupId,_groupName);
               }
               return;
            }
            if(target.name == "avatars_scroll_left")
            {
               if(_avatarScrollIndex > 0)
               {
                  _avatarScrollIndex--;
                  layoutAvatarList();
               }
               return;
            }
            if(target.name == "avatars_scroll_right")
            {
               if(_avatarOverflow)
               {
                  _avatarScrollIndex++;
                  layoutAvatarList();
               }
               return;
            }
            if(target.name == "add_link")
            {
               if(_controller != null)
               {
                  _controller.openInvite(_groupId);
               }
               return;
            }
            if(target.name == "report_link")
            {
               if(_controller != null)
               {
                  _controller.openMembers(_groupId);
               }
               return;
            }
            if(target.name == "avatar_click_region" || target.name.indexOf("bobba_member_head_") == 0)
            {
               nick = nicknameFromHeadTarget(target);
               if(nick.length > 0 && _controller != null)
               {
                  _controller.openUserProfile(nick);
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
