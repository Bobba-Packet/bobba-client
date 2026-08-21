package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class BobbaAvatarEffects
   {
      
      public static const NPCKEY_ID:int = 9002;
      
      public static const NPCKEY_LIB:String = "NPCkey";
      
      public static const BOBBAKEY_ID:int = 9001;
      
      public static const BOBBAKEY_LIB:String = "BobbaKey";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _applyTimer:Timer;
      
      private var _ownEffectId:int;
      
      private var _others:Dictionary;
      
      private var _lastRoomKey:String;
      
      private var _photoSuspended:Boolean;
      
      private var _disposed:Boolean;
      
      public function BobbaAvatarEffects(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _ownEffectId = 0;
         _others = new Dictionary();
         _lastRoomKey = "";
         _photoSuspended = false;
         _disposed = false;
         _applyTimer = new Timer(150);
         _applyTimer.addEventListener(TimerEvent.TIMER,onApplyTimer);
         _applyTimer.start();
         if(_windowManager != null && _windowManager.bobbaBackend != null)
         {
            _windowManager.bobbaBackend.setEffectListener(this);
         }
      }
      
      public function dispose() : void
      {
         if(_disposed)
         {
            return;
         }
         _disposed = true;
         if(_applyTimer != null)
         {
            _applyTimer.stop();
            _applyTimer.removeEventListener(TimerEvent.TIMER,onApplyTimer);
            _applyTimer = null;
         }
         if(_windowManager != null && _windowManager.bobbaBackend != null)
         {
            _windowManager.bobbaBackend.setEffectListener(null);
         }
         if(_ownEffectId != 0)
         {
            _ownEffectId = 0;
            publishOwnEffect();
         }
         _others = null;
         _windowManager = null;
      }
      
      public function applyEffect(effectId:int) : void
      {
         if(effectId != 0 && effectId != NPCKEY_ID && effectId != BOBBAKEY_ID)
         {
            return;
         }
         setOwnEffect(effectId);
      }
      
      public function get currentEffectId() : int
      {
         return _ownEffectId;
      }
      
      public function toggleNpcKey() : void
      {
         toggleKeyedEffect(NPCKEY_ID,"alert.npckey_on","NPCkey on. Bobba clients only.","alert.npckey_off","NPCkey off.");
      }
      
      public function toggleBobbaKey() : void
      {
         toggleKeyedEffect(BOBBAKEY_ID,"alert.bobbakey_on","BobbaKey on. Bobba clients only.","alert.bobbakey_off","BobbaKey off.");
      }
      
      private function toggleKeyedEffect(effectId:int, onKey:String, onFallback:String, offKey:String, offFallback:String) : void
      {
         if(_ownEffectId == effectId)
         {
            setOwnEffect(0);
            whisper(BobbaI18n.t(offKey,offFallback));
            return;
         }
         setOwnEffect(effectId);
         whisper(BobbaI18n.t(onKey,onFallback));
      }
      
      public function onBackendReady() : void
      {
         _lastRoomKey = "__resync__";
      }
      
      public function onRoomAvatarEffect(nickname:String, effectId:int, roomKey:String) : void
      {
         var self:String = null;
         if(_disposed || nickname == null || nickname.length == 0)
         {
            return;
         }
         if(roomKey != null && roomKey.length > 0 && currentRoomKey() != roomKey)
         {
            return;
         }
         self = ownNickname();
         if(self.length > 0 && nickname.toLowerCase() == self.toLowerCase())
         {
            return;
         }
         if(effectId == 0)
         {
            delete _others[nickname.toLowerCase()];
            applyToNickname(nickname,0);
            return;
         }
         _others[nickname.toLowerCase()] = {
            "nickname":nickname,
            "effectId":effectId
         };
         if(!_photoSuspended)
         {
            applyToNickname(nickname,effectId);
         }
      }
      
      public function onRoomAvatarEffectsState(roomKey:String, entries:Array) : void
      {
         var i:int = 0;
         var row:Object = null;
         var self:String = ownNickname().toLowerCase();
         if(_disposed)
         {
            return;
         }
         if(roomKey != null && roomKey.length > 0 && currentRoomKey() != roomKey)
         {
            return;
         }
         clearOthers();
         if(entries == null)
         {
            return;
         }
         for(i = 0; i < entries.length; i++)
         {
            row = entries[i];
            if(row == null || row.nickname == null)
            {
               continue;
            }
            if(self.length > 0 && String(row.nickname).toLowerCase() == self)
            {
               continue;
            }
            onRoomAvatarEffect(String(row.nickname),int(row.effectId),roomKey);
         }
      }
      
      public function suspendForPhoto() : void
      {
         var key:String = null;
         _photoSuspended = true;
         applyOwnVisual(0);
         if(_others == null)
         {
            return;
         }
         for(key in _others)
         {
            if(_others[key] != null)
            {
               applyToNickname(String(_others[key].nickname),0);
            }
         }
      }
      
      public function resumeAfterPhoto() : void
      {
         var key:String = null;
         _photoSuspended = false;
         if(_disposed)
         {
            return;
         }
         applyOwn();
         if(_others == null)
         {
            return;
         }
         for(key in _others)
         {
            if(_others[key] != null)
            {
               applyToNickname(String(_others[key].nickname),int(_others[key].effectId));
            }
         }
      }
      
      private function setOwnEffect(effectId:int) : void
      {
         var customs:* = null;
         _ownEffectId = effectId;
         try
         {
            if(_windowManager != null)
            {
               customs = _windowManager.LilithCustomsInstance;
               if(customs != null)
               {
                  customs.UserCustomFx = 0;
                  if(customs.UserCustomFxTimer != null)
                  {
                     customs.UserCustomFxTimer.stop();
                  }
               }
            }
         }
         catch(fxErr:Error)
         {
         }
         try
         {
            if(_windowManager != null && _windowManager.roomEngine != null)
            {
               _windowManager.roomEngine.setAvatarEffect(_ownEffectId);
            }
         }
         catch(applyErr:Error)
         {
         }
         publishOwnEffect();
      }
      
      private function onApplyTimer(e:TimerEvent) : void
      {
         var key:String = null;
         var roomKey:String = null;
         var nick:String = null;
         if(_disposed)
         {
            return;
         }
         roomKey = currentRoomKey();
         if(roomKey != _lastRoomKey)
         {
            _lastRoomKey = roomKey;
            clearOthers();
            if(_windowManager != null && _windowManager.bobbaBackend != null)
            {
               _windowManager.bobbaBackend.syncRoomAvatarEffects(roomKey);
            }
            publishOwnEffect();
         }
         if(_photoSuspended)
         {
            return;
         }
         applyOwn();
         for(key in _others)
         {
            if(_others[key] != null)
            {
               nick = String(_others[key].nickname);
               applyToNickname(nick,int(_others[key].effectId));
            }
         }
      }
      
      private function applyOwn() : void
      {
         if(_ownEffectId == 0)
         {
            return;
         }
         applyOwnVisual(_ownEffectId);
      }
      
      private function applyOwnVisual(effectId:int) : void
      {
         try
         {
            if(_windowManager == null || _windowManager.roomEngine == null)
            {
               return;
            }
            _windowManager.roomEngine.setAvatarEffect(effectId);
         }
         catch(applyErr:Error)
         {
         }
      }
      
      private function applyToNickname(nickname:String, effectId:int) : void
      {
         var session:* = null;
         var userData:* = null;
         var roomId:int = 0;
         var objectId:int = 0;
         try
         {
            if(_windowManager == null || _windowManager.roomEngine == null || _windowManager.LilithCustomsInstance == null)
            {
               return;
            }
            if(!_windowManager.LilithCustomsInstance.IsRoomSessionAvailable)
            {
               return;
            }
            session = _windowManager.LilithCustomsInstance.RoomSession;
            if(session == null || session.userDataManager == null)
            {
               return;
            }
            userData = session.userDataManager.getUserDataByName(nickname);
            if(userData == null)
            {
               return;
            }
            roomId = int(session.roomId);
            objectId = int(userData.roomObjectId);
            _windowManager.roomEngine.updateObjectUserEffect(roomId,objectId,effectId);
         }
         catch(otherErr:Error)
         {
         }
      }
      
      private function publishOwnEffect() : void
      {
         var roomKey:String = currentRoomKey();
         if(_windowManager == null || _windowManager.bobbaBackend == null)
         {
            return;
         }
         _windowManager.bobbaBackend.setRoomAvatarEffect(roomKey,_ownEffectId);
      }
      
      private function currentRoomKey() : String
      {
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null && _windowManager.LilithCustomsInstance.IsRoomSessionAvailable)
            {
               if(_windowManager.LilithCustomsInstance.RoomSession != null)
               {
                  return String(_windowManager.LilithCustomsInstance.RoomSession.roomId);
               }
            }
         }
         catch(roomErr:Error)
         {
         }
         return "";
      }
      
      private function ownNickname() : String
      {
         try
         {
            if(_windowManager != null && _windowManager.bobbaBackend != null && _windowManager.bobbaBackend.nickname != null)
            {
               return _windowManager.bobbaBackend.nickname;
            }
            if(_windowManager != null && _windowManager.sessionDataManager != null && _windowManager.sessionDataManager.userName != null)
            {
               return _windowManager.sessionDataManager.userName;
            }
         }
         catch(nameErr:Error)
         {
         }
         return "";
      }
      
      private function clearOthers() : void
      {
         var key:String = null;
         if(_others == null)
         {
            return;
         }
         for(key in _others)
         {
            delete _others[key];
         }
      }
      
      private function whisper(message:String) : void
      {
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null)
            {
               _windowManager.LilithCustomsInstance.ShowWhisperAlert(message);
            }
         }
         catch(whisperErr:Error)
         {
         }
      }
   }
}
