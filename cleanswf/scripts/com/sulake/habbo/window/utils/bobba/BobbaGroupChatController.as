package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   
   public class BobbaGroupChatController
   {
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _backend:BobbaBackendClient;
      
      private var _listEditor:BobbaGroupListEditor;
      
      private var _chatEditor:BobbaGroupChatEditor;
      
      private var _inviteEditor:BobbaGroupInviteEditor;
      
      private var _confirmEditor:BobbaGroupInviteConfirmEditor;
      
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
            showError("Abra um grupo primeiro");
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
            showError("Abra um grupo primeiro");
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
            showError("Nenhum convite pendente");
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
            _windowManager.simpleAlert("Chat em grupo","Aviso",message);
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
         refreshList();
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
         if(_chatEditor != null && _activeGroupId == groupId)
         {
            if(senderFigure != null && senderFigure.length > 0)
            {
               _chatEditor.rememberFigure(senderNickname,senderFigure);
            }
            _chatEditor.appendMessage(senderNickname,body,timestamp,senderFigure);
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
         showError(deleted ? "Você saiu e o grupo foi encerrado." : "Você saiu do grupo.");
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
   }
}
