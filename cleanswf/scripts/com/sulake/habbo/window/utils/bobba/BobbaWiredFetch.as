package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.communication.messages.outgoing.userdefinedroomevents.OpenMessageComposer;
   import com.sulake.habbo.roomevents.wired_setup.UserDefinedRoomEventsCtrl;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class BobbaWiredFetch
   {
      
      private static const GAP_MS:int = 100;
      
      private static const WAIT_MS:int = 2500;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _ids:Array;
      
      private var _index:int;
      
      private var _sent:Boolean;
      
      private var _waitStart:int;
      
      private var _gapUntil:int;
      
      private var _pass:int;
      
      private var _original:int;
      
      private var _timer:Timer;
      
      private var _busy:Boolean;
      
      private var _cancel:Boolean;
      
      private var _onHud:Function;
      
      private var _onDone:Function;
      
      public function BobbaWiredFetch()
      {
         super();
         _ids = [];
         _busy = false;
         _cancel = false;
      }
      
      public function get busy() : Boolean
      {
         return _busy;
      }
      
      public function start(windowManager:HabboWindowManagerComponent, ids:Array, onHud:Function, onDone:Function) : Boolean
      {
         if(_busy || windowManager == null || ids == null || ids.length == 0)
         {
            return false;
         }
         _windowManager = windowManager;
         _ids = ids.concat();
         _original = _ids.length;
         _index = 0;
         _sent = false;
         _pass = 0;
         _cancel = false;
         _onHud = onHud;
         _onDone = onDone;
         _busy = true;
         _gapUntil = getTimer();
         setSuppress(true);
         if(_timer == null)
         {
            _timer = new Timer(50,0);
            _timer.addEventListener("timer",onTick);
         }
         hud();
         _timer.start();
         return true;
      }
      
      public function cancel() : void
      {
         _cancel = true;
         if(!_busy)
         {
            stopTimer();
            setSuppress(false);
         }
      }
      
      public function dispose() : void
      {
         _onHud = null;
         _onDone = null;
         cancel();
         stopTimer();
         setSuppress(false);
         _busy = false;
         if(_timer != null)
         {
            _timer.removeEventListener("timer",onTick);
            _timer = null;
         }
         _windowManager = null;
         _ids = null;
      }
      
      private function onTick(e:*) : void
      {
         var id:int = 0;
         var now:int = 0;
         var leftover:Array = null;
         if(_cancel)
         {
            finish();
            return;
         }
         if(_index >= _ids.length)
         {
            leftover = stillMissing();
            if(_pass == 0 && leftover.length > 0 && leftover.length <= _original / 2)
            {
               _ids = leftover;
               _index = 0;
               _sent = false;
               _pass = 1;
               _gapUntil = getTimer();
               hud();
               return;
            }
            finish();
            return;
         }
         id = int(_ids[_index]);
         if(id == 0 || BobbaWiredCache.hasId(id))
         {
            _index++;
            _sent = false;
            _gapUntil = getTimer() + GAP_MS;
            hud();
            return;
         }
         now = getTimer();
         if(!_sent)
         {
            if(now < _gapUntil)
            {
               return;
            }
            if(!BobbaHotelSend.send(_windowManager,new OpenMessageComposer(id)))
            {
               Logger.log("[BobbaPresets] wired open failed",id);
               _index++;
               _sent = false;
               _gapUntil = now + GAP_MS;
               hud();
               return;
            }
            _sent = true;
            _waitStart = now;
            return;
         }
         if(now - _waitStart >= WAIT_MS)
         {
            _index++;
            _sent = false;
            _gapUntil = now + GAP_MS;
            hud();
         }
      }
      
      private function stillMissing() : Array
      {
         var out:Array = [];
         var i:int = 0;
         var id:int = 0;
         for(i = 0; i < _ids.length; i++)
         {
            id = int(_ids[i]);
            if(id != 0 && !BobbaWiredCache.hasId(id))
            {
               out.push(id);
            }
         }
         return out;
      }
      
      private function hud() : void
      {
         var n:int = _index;
         if(n > _ids.length)
         {
            n = _ids.length;
         }
         if(_onHud != null)
         {
            _onHud(BobbaI18n.t("presets.hud.fetchWired","Retrieving wired"),n,_original);
         }
      }
      
      private function finish() : void
      {
         var cb:Function = _onDone;
         var ok:Boolean = !_cancel;
         stopTimer();
         setSuppress(false);
         _busy = false;
         _onDone = null;
         if(cb != null)
         {
            cb(ok);
         }
      }
      
      private function stopTimer() : void
      {
         if(_timer != null)
         {
            _timer.stop();
         }
      }
      
      private function setSuppress(value:Boolean) : void
      {
         BobbaWiredCache.fetching = value;
         try
         {
            UserDefinedRoomEventsCtrl.bobbaSkipPrepare = value;
         }
         catch(e:Error)
         {
            Logger.log("[BobbaPresets] wired suppress failed",e.message);
         }
      }
   }
}
