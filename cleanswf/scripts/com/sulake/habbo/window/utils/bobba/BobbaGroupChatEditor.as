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
   import flash.utils.Dictionary;
   
   public class BobbaGroupChatEditor implements IIlluminaInputHandler
   {
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_chat";
      
      private static const MAX_HEADER_HEADS:int = 4;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _chatMsgTemplate:IWidgetWindowController;
      
      private var _headTemplate:IWidgetWindowController;
      
      private var _groupId:String = "";
      
      private var _groupName:String = "";
      
      private var _ownName:String = "";
      
      private var _ownFigure:String = "";
      
      private var _members:Array;
      
      private var _figuresByNick:Dictionary;
      
      private var _headerHeadWidgets:Array;
      
      private var _moreLabel:IWindowModel;
      
      public function BobbaGroupChatEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
         _members = [];
         _figuresByNick = new Dictionary();
         _headerHeadWidgets = [];
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
         _groupName = groupName != null ? groupName : "Chat em grupo";
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
            return;
         }
         for(i = 0; i < messages.length; i++)
         {
            m = messages[i];
            if(m.senderFigure != null && String(m.senderFigure).length > 0)
            {
               rememberFigure(String(m.senderNickname),String(m.senderFigure));
            }
            appendMessage(String(m.senderNickname),String(m.body),int(m.timestamp),m.senderFigure != null ? String(m.senderFigure) : "");
         }
      }
      
      public function appendMessage(sender:String, body:String, timestamp:int, senderFigure:String = "") : void
      {
         var bubble:IWidgetWindowController = null;
         var widget:IIlluminaChatBubbleWidget = null;
         var list:IItemListWindow = null;
         var flipped:Boolean = false;
         var figure:String = "";
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
            bubble = IWidgetWindowController(_chatMsgTemplate.clone());
            widget = IIlluminaChatBubbleWidget(bubble.widget);
            flipped = sender == _ownName;
            figure = resolveFigure(sender);
            if((figure == null || figure.length == 0) && senderFigure != null)
            {
               figure = senderFigure;
            }
            bubble.name = "chat_msg_0";
            widget.figure = figure != null ? figure : "";
            widget.flipped = flipped;
            widget.userName = sender != null ? sender : "";
            widget.userId = flipped ? 1 : 2;
            widget.appendMessage(body);
            list.addListItem(bubble);
            list.scrollV = 1;
            list.arrangeListItems();
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] append failed",err.message);
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
         if(_headTemplate != null)
         {
            _headTemplate.dispose();
            _headTemplate = null;
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
         _moreLabel = null;
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
         var inviteBtn:IWindowModel = null;
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"guide_ongoing") as IFrameController;
            if(_window == null)
            {
               return;
            }
            _chatMsgTemplate = BobbaHabboXml.getXmlWindow(_windowManager,"chat_msg") as IWidgetWindowController;
            _window.procedure = windowProcedure;
            if(_window.findChildByName("visit_button") != null)
            {
               _window.findChildByName("visit_button").visible = false;
            }
            inviteBtn = _window.findChildByName("invite_button");
            if(inviteBtn != null)
            {
               inviteBtn.caption = "Adicionar";
               try
               {
                  inviteBtn["toolTipCaption"] = "Adicionar habbo ao grupo";
               }
               catch(tipErr:Error)
               {
               }
            }
            if(_window.findChildByName("report_link") != null)
            {
               _window.findChildByName("report_link").visible = true;
               _window.findChildByName("report_link").caption = "Ver membros";
               try
               {
                  _window.findChildByName("report_link")["toolTipCaption"] = "Abrir lista de membros do grupo";
               }
               catch(membersTipErr:Error)
               {
               }
            }
            if(_window.findChildByName("close_link") != null)
            {
               _window.findChildByName("close_link").caption = "Sair do grupo";
            }
            clearChatList();
            input = IIlluminaInputWidget(IWidgetWindowController(_window.findChildByName("input_widget")).widget);
            input.submitHandler = this;
            input.emptyMessage = "Digite uma mensagem";
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
         var row:IItemListWindow = null;
         var inviteBtn:IWindowModel = null;
         var i:int = 0;
         var showCount:int = 0;
         var extra:int = 0;
         var head:IWidgetWindowController = null;
         var more:IWindowModel = null;
         var m:Object = null;
         if(_window == null)
         {
            return;
         }
         try
         {
            inviteBtn = _window.findChildByName("invite_button");
            if(inviteBtn == null || inviteBtn.parent == null)
            {
               return;
            }
            row = inviteBtn.parent as IItemListWindow;
            if(row == null)
            {
               return;
            }
            clearHeaderHeads();
            showCount = _members.length > MAX_HEADER_HEADS ? MAX_HEADER_HEADS : _members.length;
            for(i = 0; i < showCount; i++)
            {
               m = _members[i];
               head = buildHeadWidget(resolveFigure(String(m.nickname)));
               if(head == null && m.figure != null)
               {
                  head = buildHeadWidget(String(m.figure));
               }
               if(head != null)
               {
                  head.name = "bobba_member_head_" + i;
                  head.procedure = onHeadClick;
                  row.addListItemAt(head,i);
                  _headerHeadWidgets.push(head);
               }
            }
            extra = _members.length - showCount;
            if(extra > 0)
            {
               more = buildMoreLabel(extra);
               if(more != null)
               {
                  more.name = "bobba_more_members";
                  more.procedure = onHeadClick;
                  row.addListItemAt(more as IWindowController_1,showCount);
                  _moreLabel = more;
               }
            }
            row.arrangeListItems();
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] heads failed",err.message);
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
                        IItemListWindow(head.parent).removeListItem(head);
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
         if(_moreLabel != null)
         {
            try
            {
               if(_moreLabel.parent != null)
               {
                  IItemListWindow(_moreLabel.parent).removeListItem(_moreLabel);
               }
               _moreLabel.dispose();
            }
            catch(errMore:Error)
            {
            }
            _moreLabel = null;
         }
      }
      
      private function ensureHeadTemplate() : void
      {
         var bully:IFrameController = null;
         var list:IItemListWindow = null;
         var row:IWindowController_1 = null;
         var avatar:IWidgetWindowController = null;
         if(_headTemplate != null || _windowManager == null)
         {
            return;
         }
         try
         {
            bully = BobbaHabboXml.getXmlWindow(_windowManager,"bully_report") as IFrameController;
            if(bully == null)
            {
               return;
            }
            list = bully.findChildByName("user_list") as IItemListWindow;
            if(list != null && list.numListItems > 0)
            {
               row = list.getListItemAt(0) as IWindowController_1;
               if(row != null)
               {
                  avatar = row.findChildByName("user_avatar") as IWidgetWindowController;
                  if(avatar != null)
                  {
                     _headTemplate = IWidgetWindowController(avatar.clone());
                  }
               }
            }
            bully.dispose();
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] head template failed",err.message);
            try
            {
               if(bully != null)
               {
                  bully.dispose();
               }
            }
            catch(disposeErr:Error)
            {
            }
         }
      }
      
      private function buildHeadWidget(figure:String) : IWidgetWindowController
      {
         var widget:IWidgetWindowController = null;
         var avatar:IAvatarImageWidget = null;
         ensureHeadTemplate();
         if(_headTemplate == null)
         {
            return null;
         }
         try
         {
            widget = IWidgetWindowController(_headTemplate.clone());
            avatar = IAvatarImageWidget(widget.widget);
            avatar.onlyHead = true;
            avatar.cropped = true;
            avatar.figure = figure != null ? figure : "";
            return widget;
         }
         catch(err:Error)
         {
         }
         return null;
      }
      
      private function buildMoreLabel(extra:int) : IWindowModel
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         var label:IWindowModel = null;
         try
         {
            layout = <layout name="bobba_more_members" width="28" height="30" version="0.1">
                  <window>
                     <label x="0" y="8" width="28" height="16" params="17" style="100" name="bobba_more_members" caption="+0">
                        <variables>
                           <var key="text_style" value="il_border" type="String"/>
                        </variables>
                     </label>
                  </window>
               </layout>;
            built = _windowManager.buildFromXML(layout,1);
            label = built != null ? built.findChildByName("bobba_more_members") : null;
            if(label != null)
            {
               label.caption = "+" + extra;
               return label;
            }
            return built;
         }
         catch(err:Error)
         {
         }
         return null;
      }
      
      private function onHeadClick(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || event.type != "WME_CLICK")
         {
            return;
         }
         if(_controller != null)
         {
            _controller.openMembers(_groupId);
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
            list = IItemListWindow(_window.findChildByName("chat_list"));
            while(list != null && list.numListItems > 0)
            {
               list.removeListItemAt(0);
            }
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
                  _controller.leaveGroup(_groupId);
               }
               return;
            }
            if(target.name == "invite_button")
            {
               if(_controller != null)
               {
                  _controller.openInvite(_groupId);
               }
               return;
            }
            if(target.name == "report_link" || target.name == "bobba_more_members" || target.name.indexOf("bobba_member_head_") == 0)
            {
               if(_controller != null)
               {
                  _controller.openMembers(_groupId);
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
