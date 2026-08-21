package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class BobbaAvatarLooks
   {
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _applyTimer:Timer;
      
      private var _others:Dictionary;
      
      private var _hotelFigures:Dictionary;
      
      private var _hotelSexes:Dictionary;
      
      private var _lastRoomKey:String;
      
      private var _lastFigure:String;
      
      private var _lastSex:String;
      
      private var _photoSuspended:Boolean;
      
      private var _disposed:Boolean;
      
      public function BobbaAvatarLooks(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _others = new Dictionary();
         _hotelFigures = new Dictionary();
         _hotelSexes = new Dictionary();
         _lastRoomKey = "";
         _lastFigure = "";
         _lastSex = "";
         _photoSuspended = false;
         _disposed = false;
         _applyTimer = new Timer(150);
         _applyTimer.addEventListener(TimerEvent.TIMER,onApplyTimer);
         _applyTimer.start();
         if(_windowManager != null && _windowManager.bobbaBackend != null)
         {
            _windowManager.bobbaBackend.setLookListener(this);
         }
      }
      
      public function keepFigures() : Array
      {
         var out:Array = [];
         var key:* = null;
         var row:* = null;
         if(_lastFigure != null && _lastFigure.length > 0)
         {
            out.push(_lastFigure);
         }
         if(_others != null)
         {
            for(key in _others)
            {
               row = _others[key];
               if(row != null && row.figure != null && String(row.figure).length > 0)
               {
                  out.push(String(row.figure));
               }
            }
         }
         if(_hotelFigures != null)
         {
            for(key in _hotelFigures)
            {
               if(_hotelFigures[key] != null && String(_hotelFigures[key]).length > 0)
               {
                  out.push(String(_hotelFigures[key]));
               }
            }
         }
         return out;
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
            _windowManager.bobbaBackend.setLookListener(null);
         }
         if(_lastFigure.length > 0)
         {
            _lastFigure = "";
            _lastSex = "";
            publishOwnLook();
         }
         restoreOthersToHotel();
         _others = null;
         _hotelFigures = null;
         _hotelSexes = null;
         _windowManager = null;
      }
      
      public function onBackendReady() : void
      {
         _lastRoomKey = "__resync__";
      }
      
      public function onRoomAvatarFigure(nickname:String, figure:String, sex:String, roomKey:String) : void
      {
         var self:String = null;
         var key:String = null;
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
         key = nickname.toLowerCase();
         if(figure == null || figure.length == 0)
         {
            delete _others[key];
            restoreHotelLook(nickname);
            delete _hotelFigures[key];
            delete _hotelSexes[key];
            return;
         }
         captureHotelLook(nickname);
         _others[key] = {
            "nickname":nickname,
            "figure":figure,
            "sex":normalizeSex(sex)
         };
         if(!_photoSuspended && looksEnabled())
         {
            applyToNickname(nickname,figure,normalizeSex(sex));
         }
      }
      
      public function onRoomAvatarFiguresState(roomKey:String, entries:Array) : void
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
         clearOthers(true);
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
            onRoomAvatarFigure(String(row.nickname),String(row.figure),String(row.sex),roomKey);
         }
      }
      
      public function suspendForPhoto() : void
      {
         _photoSuspended = true;
         restoreOthersToHotel();
      }
      
      public function resumeAfterPhoto() : void
      {
         _photoSuspended = false;
         applyVisibilityNow();
      }
      
      public function dropOwnLookAndPublish() : void
      {
         if(_disposed)
         {
            return;
         }
         _lastFigure = "";
         _lastSex = "";
         publishOwnLook();
      }
      
      public function applyVisibilityNow() : void
      {
         var key:String = null;
         var row:Object = null;
         if(_disposed || _photoSuspended)
         {
            return;
         }
         if(!looksEnabled())
         {
            restoreOwnToHotel();
            restoreOthersToHotel();
            return;
         }
         applyOwnSavedLook();
         if(_others == null)
         {
            return;
         }
         for(key in _others)
         {
            row = _others[key];
            if(row != null)
            {
               applyToNickname(String(row.nickname),String(row.figure),String(row.sex));
            }
         }
      }
      
      private function onApplyTimer(e:TimerEvent) : void
      {
         var key:String = null;
         var roomKey:String = null;
         var row:Object = null;
         var own:Object = null;
         if(_disposed)
         {
            return;
         }
         roomKey = currentRoomKey();
         if(roomKey != _lastRoomKey)
         {
            _lastRoomKey = roomKey;
            clearOthers(true);
            if(_windowManager != null && _windowManager.bobbaBackend != null)
            {
               _windowManager.bobbaBackend.syncRoomAvatarFigures(roomKey);
            }
            _lastFigure = "__resync__";
         }
         own = ownBobbaLook();
         if(String(own.figure) != _lastFigure || String(own.sex) != _lastSex)
         {
            _lastFigure = String(own.figure);
            _lastSex = String(own.sex);
            publishOwnLook();
         }
         if(_photoSuspended)
         {
            return;
         }
         if(!looksEnabled())
         {
            restoreOwnToHotel();
            restoreOthersToHotel();
            return;
         }
         applyOwnSavedLook();
         for(key in _others)
         {
            row = _others[key];
            if(row != null)
            {
               applyToNickname(String(row.nickname),String(row.figure),String(row.sex));
            }
         }
      }
      
      private function looksEnabled() : Boolean
      {
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null)
            {
               return _windowManager.LilithCustomsInstance.BobbaLooksEnabled != false;
            }
         }
         catch(visErr:Error)
         {
         }
         return true;
      }
      
      private function ownBobbaLook() : Object
      {
         var customs:* = null;
         var figure:String = "";
         var sex:String = "";
         try
         {
            if(_windowManager != null)
            {
               customs = _windowManager.LilithCustomsInstance;
            }
            if(customs != null)
            {
               if(customs.DevWarUserFigure != null && String(customs.DevWarUserFigure).length > 0)
               {
                  figure = String(customs.DevWarUserFigure);
                  sex = normalizeSex(customs.DevWarUserSex);
               }
               else if(customs.BobbaSavedFigure != null && String(customs.BobbaSavedFigure).length > 0)
               {
                  figure = String(customs.BobbaSavedFigure);
                  sex = normalizeSex(customs.BobbaSavedSex);
               }
            }
         }
         catch(lookErr:Error)
         {
         }
         return {
            "figure":figure,
            "sex":sex
         };
      }
      
      private function applyToNickname(nickname:String, figure:String, sex:String) : void
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
            captureHotelLook(nickname);
            userData.figure = figure;
            userData.sex = sex;
            roomId = int(session.roomId);
            objectId = int(userData.roomObjectId);
            _windowManager.roomEngine.updateObjectUserFigure(roomId,objectId,figure,sex);
         }
         catch(otherErr:Error)
         {
         }
      }
      
      private function captureHotelLook(nickname:String) : void
      {
         var session:* = null;
         var userData:* = null;
         var key:String = nickname != null ? nickname.toLowerCase() : "";
         if(key.length == 0 || _hotelFigures == null || _hotelFigures[key] != null)
         {
            return;
         }
         try
         {
            if(_windowManager == null || _windowManager.LilithCustomsInstance == null || !_windowManager.LilithCustomsInstance.IsRoomSessionAvailable)
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
            _hotelFigures[key] = String(userData.figure != null ? userData.figure : "");
            _hotelSexes[key] = normalizeSex(userData.sex);
         }
         catch(capErr:Error)
         {
         }
      }
      
      private function applyOwnSavedLook() : void
      {
         var own:Object = ownBobbaLook();
         if(own == null || String(own.figure).length == 0)
         {
            return;
         }
         applyOwnFigure(String(own.figure),String(own.sex));
      }
      
      private function restoreOwnToHotel() : void
      {
         var figure:String = "";
         var sex:String = "";
         try
         {
            if(_windowManager != null && _windowManager.sessionDataManager != null)
            {
               figure = String(_windowManager.sessionDataManager.figure != null ? _windowManager.sessionDataManager.figure : "");
               sex = normalizeSex(_windowManager.sessionDataManager.gender);
            }
         }
         catch(ownHotelErr:Error)
         {
         }
         if(figure.length == 0)
         {
            return;
         }
         applyOwnFigure(figure,sex);
      }
      
      private function applyOwnFigure(figure:String, sex:String) : void
      {
         var session:* = null;
         var userData:* = null;
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
            userData = session.userDataManager.getUserDataByIndex(session.ownUserRoomId);
            if(userData == null)
            {
               return;
            }
            userData.figure = figure;
            userData.sex = sex;
            _windowManager.roomEngine.updateObjectUserFigure(int(session.roomId),int(userData.roomObjectId),figure,sex);
         }
         catch(ownErr:Error)
         {
         }
      }
      
      private function restoreHotelLook(nickname:String) : void
      {
         var session:* = null;
         var userData:* = null;
         var key:String = nickname != null ? nickname.toLowerCase() : "";
         var figure:String = "";
         var sex:String = "";
         try
         {
            if(_hotelFigures != null && _hotelFigures[key] != null)
            {
               figure = String(_hotelFigures[key]);
            }
            if(_hotelSexes != null && _hotelSexes[key] != null)
            {
               sex = String(_hotelSexes[key]);
            }
            if(figure.length == 0)
            {
               return;
            }
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
            userData.figure = figure;
            userData.sex = sex;
            _windowManager.roomEngine.updateObjectUserFigure(int(session.roomId),int(userData.roomObjectId),figure,sex);
         }
         catch(restoreErr:Error)
         {
         }
      }
      
      private function restoreOthersToHotel() : void
      {
         var key:String = null;
         var row:Object = null;
         if(_others == null)
         {
            return;
         }
         for(key in _others)
         {
            row = _others[key];
            if(row != null)
            {
               restoreHotelLook(String(row.nickname));
            }
         }
      }
      
      private function publishOwnLook() : void
      {
         var roomKey:String = currentRoomKey();
         if(_windowManager == null || _windowManager.bobbaBackend == null)
         {
            return;
         }
         _windowManager.bobbaBackend.setRoomAvatarFigure(roomKey,_lastFigure == "__resync__" ? "" : _lastFigure,_lastSex);
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
      
      private function clearOthers(restoreHotel:Boolean) : void
      {
         var key:String = null;
         if(_others == null)
         {
            return;
         }
         if(restoreHotel)
         {
            restoreOthersToHotel();
         }
         for(key in _others)
         {
            delete _others[key];
         }
         if(_hotelFigures != null)
         {
            for(key in _hotelFigures)
            {
               delete _hotelFigures[key];
            }
         }
         if(_hotelSexes != null)
         {
            for(key in _hotelSexes)
            {
               delete _hotelSexes[key];
            }
         }
      }
      
      private function normalizeSex(value:*) : String
      {
         var sex:String = value != null ? String(value).toUpperCase() : "";
         if(sex == "M" || sex == "F")
         {
            return sex;
         }
         return "M";
      }
   }
}
