   package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.communication.messages.outgoing.users.GetExtendedProfileByNameMessageComposer;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   
   public class BobbaGroupChatController
   {
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _backend:BobbaBackendClient;
      
      private var _listEditor:BobbaGroupListEditor;
      
      private var _chatEditor:BobbaGroupChatEditor;
      
      private var _inviteEditor:BobbaGroupInviteEditor;
      
      private var _confirmEditor:BobbaGroupInviteConfirmEditor;
      
      private var _leaveConfirmEditor:BobbaGroupLeaveConfirmEditor;
      
      private var _membersEditor:BobbaGroupMembersEditor;
      
      private var _activeGroupId:String = "";
      
      private var _activeGroupName:String = "";
      
      private var _groups:Array;
      
      private var _pendingInvites:Array;
      
      private var _activeMembers:Array;
      
      public function BobbaGroupChatController(windowManager:HabboWindowManagerComponent, backend:BobbaBackendClient)
      {
         super();
         _windowManager = windowManager;
         _backend = backend;
         _groups = [];
         _pendingInvites = [];
         _activeMembers = [];
         if(_backend != null)
         {
            _backend.setGroupListener(this);
         }
      }
      
      public function dispose() : void
      {
         if(_backend != null)
         {
            _backend.setGroupListener(null);
         }
         if(_listEditor != null)
         {
            _listEditor.dispose();
            _listEditor = null;
         }
         if(_chatEditor != null)
         {
            _chatEditor.dispose();
            _chatEditor = null;
         }
         if(_inviteEditor != null)
         {
            _inviteEditor.dispose();
            _inviteEditor = null;
         }
         if(_confirmEditor != null)
         {
            _confirmEditor.dispose();
            _confirmEditor = null;
         }
         if(_leaveConfirmEditor != null)
         {
            _leaveConfirmEditor.dispose();
            _leaveConfirmEditor = null;
         }
         if(_membersEditor != null)
         {
            _membersEditor.dispose();
            _membersEditor = null;
         }
         _windowManager = null;
         _backend = null;
         _groups = null;
         _pendingInvites = null;
         _activeMembers = null;
      }
      
      public function openList() : void
      {
         if(_listEditor == null)
         {
            _listEditor = new BobbaGroupListEditor(_windowManager,this);
         }
         _listEditor.visible = true;
         refreshList();
         if(_backend != null && _backend.isConnected)
         {
            _backend.listGroups();
            _backend.listPendingInvites();
         }
      }
      
      public function isAnyOpen() : Boolean
      {
         if(_listEditor != null && _listEditor.visible)
         {
            return true;
         }
         if(_chatEditor != null && _chatEditor.visible)
         {
            return true;
         }
         if(_inviteEditor != null && _inviteEditor.visible)
         {
            return true;
         }
         if(_confirmEditor != null && _confirmEditor.visible)
         {
            return true;
         }
         if(_leaveConfirmEditor != null && _leaveConfirmEditor.visible)
         {
            return true;
         }
         if(_membersEditor != null && _membersEditor.visible)
         {
            return true;
         }
         return false;
      }
      
      public function closeAll() : void
      {
         if(_listEditor != null)
         {
            _listEditor.visible = false;
         }
         if(_chatEditor != null)
         {
            _chatEditor.visible = false;
         }
         if(_inviteEditor != null)
         {
            _inviteEditor.visible = false;
         }
         if(_confirmEditor != null)
         {
            _confirmEditor.visible = false;
         }
         if(_leaveConfirmEditor != null)
         {
            _leaveConfirmEditor.visible = false;
         }
         if(_membersEditor != null)
         {
            _membersEditor.visible = false;
         }
      }
      
      public function refreshList() : void
      {
         if(_listEditor != null)
         {
            _listEditor.setGroups(_groups);
            _listEditor.setPendingCount(_pendingInvites != null ? _pendingInvites.length : 0);
         }
      }
      
      public function createGroup(name:String) : void
      {
         if(_backend != null)
         {
            _backend.createGroup(name);
         }
      }
      
      public function openGroup(groupId:String, groupName:String) : void
      {
         _activeGroupId = groupId;
         _activeGroupName = groupName;
         _activeMembers = [];
         clearUnread(groupId);
         if(_chatEditor == null)
         {
            _chatEditor = new BobbaGroupChatEditor(_windowManager,this);
         }
         _chatEditor.visible = true;
         _chatEditor.setGroup(groupId,groupName);
         if(_backend != null)
         {
            _backend.openGroup(groupId);
         }
         syncBarUnread();
         refreshList();
      }
      
      public function openCreate() : void
      {
         if(_inviteEditor == null)
         {
            _inviteEditor = new BobbaGroupInviteEditor(_windowManager,this);
         }
         _inviteEditor.setModeCreate();
         _inviteEditor.visible = true;
      }
      
      public function openInvite(groupId:String = "") : void
      {
         if(groupId == null || groupId.length == 0)
         {
            groupId = _activeGroupId;
         }
         if(groupId == null || groupId.length == 0)
         {
            showError(BobbaI18n.t("group.error.open_group_first"));
            return;
         }
         if(_inviteEditor == null)
         {
            _inviteEditor = new BobbaGroupInviteEditor(_windowManager,this);
         }
         _inviteEditor.setGroup(groupId);
         _inviteEditor.visible = true;
      }
      
      public function openMembers(groupId:String = "") : void
      {
         if(groupId == null || groupId.length == 0)
         {
            groupId = _activeGroupId;
         }
         if(groupId == null || groupId.length == 0)
         {
            showError(BobbaI18n.t("group.error.open_group_first"));
            return;
         }
         if(_membersEditor == null)
         {
            _membersEditor = new BobbaGroupMembersEditor(_windowManager,this);
         }
         _membersEditor.visible = true;
         _membersEditor.setMembers(_activeMembers,_activeGroupName);
         if(_backend != null)
         {
            _backend.listGroupMembers(groupId);
         }
      }
      
      public function openUserProfile(nickname:String) : void
      {
         if(nickname == null || nickname.length == 0 || _windowManager == null)
         {
            return;
         }
         try
         {
            if(_windowManager.communication != null && _windowManager.communication.connection != null)
            {
               _windowManager.communication.connection.send(new GetExtendedProfileByNameMessageComposer(nickname));
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] openUserProfile failed",err.message);
         }
      }
      
      public function confirmLeaveGroup(groupId:String = "", groupName:String = "") : void
      {
         if(groupId == null || groupId.length == 0)
         {
            groupId = _activeGroupId;
         }
         if(groupId == null || groupId.length == 0)
         {
            return;
         }
         if(groupName == null || groupName.length == 0)
         {
            groupName = _activeGroupName;
         }
         if(_leaveConfirmEditor == null)
         {
            _leaveConfirmEditor = new BobbaGroupLeaveConfirmEditor(_windowManager,this);
         }
         _leaveConfirmEditor.visible = true;
         _leaveConfirmEditor.setLeave(groupId,groupName);
      }
      
      public function leaveGroup(groupId:String = "") : void
      {
         if(groupId == null || groupId.length == 0)
         {
            groupId = _activeGroupId;
         }
         if(groupId == null || groupId.length == 0 || _backend == null)
         {
            return;
         }
         _backend.leaveGroup(groupId);
      }
      
      public function sendInvite(groupId:String, nickname:String) : void
      {
         if(_backend != null)
         {
            _backend.inviteToGroup(groupId,nickname);
         }
      }
      
      public function sendChat(body:String) : void
      {
         if(_backend != null && _activeGroupId.length > 0)
         {
            _backend.sendGroupMessage(_activeGroupId,body);
         }
      }
      
      public function respondInvite(inviteId:String, accept:Boolean) : void
      {
         if(_backend != null)
         {
            _backend.respondInvite(inviteId,accept);
         }
      }
      
      public function showPendingInvites() : void
      {
         if(_pendingInvites == null || _pendingInvites.length == 0)
         {
            showError(BobbaI18n.t("group.error.no_pending_invites"));
            return;
         }
         var first:Object = _pendingInvites[0];
         showInviteConfirm(String(first.inviteId),String(first.groupId),String(first.groupName),String(first.fromNickname));
      }
      
      public function showInviteConfirm(inviteId:String, groupId:String, groupName:String, fromNickname:String) : void
      {
         if(_confirmEditor == null)
         {
            _confirmEditor = new BobbaGroupInviteConfirmEditor(_windowManager,this);
         }
         _confirmEditor.visible = true;
         _confirmEditor.setInvite(inviteId,groupId,groupName,fromNickname);
      }
      
      public function showError(message:String) : void
      {
         if(_windowManager != null)
         {
            _windowManager.simpleAlert(BobbaI18n.t("group.title"),BobbaI18n.t("group.alert.warning"),message);
         }
      }
      
      public function onBackendReady() : void
      {
         if(_backend != null)
         {
            _backend.listPendingInvites();
         }
      }
      
      public function onGroupCreated(groupId:String, name:String) : void
      {
         if(_backend != null)
         {
            _backend.listGroups();
         }
         openGroup(groupId,name);
      }
      
      public function onGroupsList(groups:Array) : void
      {
         _groups = groups != null ? groups : [];
         if(_activeGroupId != null && _activeGroupId.length > 0 && _chatEditor != null && _chatEditor.visible)
         {
            clearUnread(_activeGroupId);
         }
         refreshList();
         syncBarUnread();
      }
      
      public function onInviteNotify(inviteId:String, groupId:String, groupName:String, fromNickname:String) : void
      {
         showInviteConfirm(inviteId,groupId,groupName,fromNickname);
         if(_backend != null)
         {
            _backend.listPendingInvites();
         }
      }
      
      public function onInviteResolved(inviteId:String, accepted:Boolean, groupId:String, groupName:String) : void
      {
         if(_confirmEditor != null)
         {
            _confirmEditor.visible = false;
         }
         if(_backend != null)
         {
            _backend.listPendingInvites();
            _backend.listGroups();
         }
         if(accepted)
         {
            openGroup(groupId,groupName);
         }
      }
      
      public function onGroupMessage(groupId:String, messageId:String, senderNickname:String, senderFigure:String, body:String, timestamp:int) : void
      {
         var viewing:Boolean = false;
         var own:Boolean = false;
         var systemMsg:Boolean = false;
         viewing = _chatEditor != null && _chatEditor.visible && _activeGroupId == groupId;
         own = isOwnNickname(senderNickname);
         systemMsg = isSystemBody(body);
         if(viewing)
         {
            if(senderFigure != null && senderFigure.length > 0)
            {
               _chatEditor.rememberFigure(senderNickname,senderFigure);
            }
            _chatEditor.appendChatOrSystem(senderNickname,body,timestamp,senderFigure);
            if(!own && _backend != null)
            {
               _backend.markGroupRead(groupId);
            }
            clearUnread(groupId);
            syncBarUnread();
            refreshList();
            return;
         }
         if(!own && !systemMsg)
         {
            bumpUnread(groupId);
            playIncomingSound();
            refreshList();
            syncBarUnread();
         }
      }
      
      public function onGroupHistory(groupId:String, messages:Array) : void
      {
         if(_chatEditor != null && _activeGroupId == groupId)
         {
            _chatEditor.setHistory(messages);
         }
      }
      
      public function onGroupMembers(groupId:String, members:Array) : void
      {
         if(_activeGroupId != groupId)
         {
            return;
         }
         _activeMembers = members != null ? members : [];
         if(_chatEditor != null)
         {
            _chatEditor.setMembers(_activeMembers);
         }
         if(_membersEditor != null && _membersEditor.visible)
         {
            _membersEditor.setMembers(_activeMembers,_activeGroupName);
         }
      }
      
      public function onGroupLeft(groupId:String, deleted:Boolean) : void
      {
         if(_leaveConfirmEditor != null)
         {
            _leaveConfirmEditor.visible = false;
         }
         if(_activeGroupId == groupId)
         {
            _activeGroupId = "";
            _activeGroupName = "";
            _activeMembers = [];
            if(_chatEditor != null)
            {
               _chatEditor.visible = false;
            }
            if(_membersEditor != null)
            {
               _membersEditor.visible = false;
            }
         }
         if(_backend != null)
         {
            _backend.listGroups();
         }
         showError(deleted ? BobbaI18n.t("group.error.left_deleted") : BobbaI18n.t("group.error.left"));
      }
      
      public function onGroupEvent(groupId:String, eventType:int, actorNickname:String, otherNickname:String) : void
      {
         // Join/leave/invite text is persisted as GroupMessage history rows.
         // GroupEvent only refreshes the member list while the chat is open.
         if(_backend != null && _activeGroupId == groupId)
         {
            if(eventType == 1 || eventType == 2)
            {
               _backend.listGroupMembers(groupId);
               _backend.listGroups();
            }
         }
      }
      
      public function onGroupError(code:int, message:String) : void
      {
         // Code 20 = nickname not linked yet; ignore during connect/profile race.
         if(code == 20)
         {
            return;
         }
         showError(message);
      }
      
      public function onPendingInvites(invites:Array) : void
      {
         _pendingInvites = invites != null ? invites : [];
         refreshList();
      }
      
      private function isOwnNickname(nickname:String) : Boolean
      {
         var own:String = null;
         if(nickname == null || nickname.length == 0)
         {
            return false;
         }
         if(_backend != null && _backend.nickname != null && _backend.nickname.length > 0)
         {
            own = _backend.nickname;
         }
         else if(_windowManager != null && _windowManager.sessionDataManager != null)
         {
            own = _windowManager.sessionDataManager.userName;
         }
         return own != null && own.length > 0 && own == nickname;
      }
      
      private function isSystemBody(body:String) : Boolean
      {
         if(body == null || body.length == 0)
         {
            return false;
         }
         return body.indexOf("\u0001sys:invitation\u0001") == 0 || body.indexOf("\u0001sys:notification\u0001") == 0;
      }
      
      private function bumpUnread(groupId:String) : void
      {
         var i:int = 0;
         var g:Object = null;
         if(groupId == null || _groups == null)
         {
            return;
         }
         for(i = 0; i < _groups.length; i++)
         {
            g = _groups[i];
            if(g != null && String(g.id) == groupId)
            {
               g.unreadCount = int(g.unreadCount) + 1;
               return;
            }
         }
         // Group missing from local cache — refresh from server.
         if(_backend != null)
         {
            _backend.listGroups();
         }
      }
      
      private function clearUnread(groupId:String) : void
      {
         var i:int = 0;
         var g:Object = null;
         if(groupId == null || _groups == null)
         {
            return;
         }
         for(i = 0; i < _groups.length; i++)
         {
            g = _groups[i];
            if(g != null && String(g.id) == groupId)
            {
               g.unreadCount = 0;
               return;
            }
         }
      }
      
      private function syncBarUnread() : void
      {
         var i:int = 0;
         var g:Object = null;
         var hasUnread:Boolean = false;
         if(_groups != null)
         {
            for(i = 0; i < _groups.length; i++)
            {
               g = _groups[i];
               if(g != null && int(g.unreadCount) > 0)
               {
                  hasUnread = true;
                  break;
               }
            }
         }
         if(_windowManager != null)
         {
            _windowManager.setBobbaGroupChatBarUnread(hasUnread);
         }
      }
      
      private function playIncomingSound() : void
      {
         var cat:* = null;
         try
         {
            if(_windowManager == null)
            {
               return;
            }
            cat = _windowManager.catalog;
            if(cat != null && cat.soundManager != null)
            {
               cat.soundManager.playSound("HBST_message_received");
            }
         }
         catch(err:Error)
         {
         }
      }
   }
}
