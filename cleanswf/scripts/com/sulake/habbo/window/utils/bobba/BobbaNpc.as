package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.communication.messages.outgoing.room.engine.MoveAvatarMessageComposer;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.display.Stage;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BobbaNpc
   {
      
      private static const MIN_DELAY_MS:int = 1;
      
      private static const DEFAULT_DELAY_MS:int = 200;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _picker:BobbaTilePicker;
      
      private var _timer:Timer;
      
      private var _tileX:int;
      
      private var _tileY:int;
      
      private var _picking:Boolean;
      
      public function BobbaNpc(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _picker = new BobbaTilePicker(windowManager);
         _timer = new Timer(DEFAULT_DELAY_MS);
         _timer.addEventListener(TimerEvent.TIMER,onTick);
         _picking = false;
         _tileX = 0;
         _tileY = 0;
      }
      
      public function get delay() : int
      {
         return int(_timer.delay);
      }
      
      public function get active() : Boolean
      {
         return _picking || _timer.running;
      }
      
      public function toggle() : void
      {
         if(active)
         {
            stop();
            whisper(BobbaI18n.t("alert.npc_off","NPC walk stopped!"));
            return;
         }
         startPick();
      }
      
      public function applyDelayArg(raw:String) : void
      {
         var ms:int = 0;
         BobbaI18n.init();
         if(raw == null || raw == "")
         {
            whisper(BobbaI18n.t("alert.npc_delay_current","NPC delay is {0} ms.").split("{0}").join(String(delay)));
            return;
         }
         ms = int(raw);
         if(ms < MIN_DELAY_MS)
         {
            ms = MIN_DELAY_MS;
         }
         _timer.delay = ms;
         whisper(BobbaI18n.t("alert.npc_delay","NPC delay set to {0} ms.").split("{0}").join(String(delay)));
      }
      
      public function stop() : void
      {
         _picking = false;
         try
         {
            _timer.stop();
         }
         catch(eStop:Error)
         {
         }
         if(_picker != null)
         {
            _picker.stop();
         }
      }
      
      public function dispose() : void
      {
         stop();
         if(_timer != null)
         {
            _timer.removeEventListener(TimerEvent.TIMER,onTick);
            _timer = null;
         }
         if(_picker != null)
         {
            _picker.dispose();
            _picker = null;
         }
         _windowManager = null;
      }
      
      private function startPick() : void
      {
         var stage:Stage = null;
         var customs:* = undefined;
         BobbaI18n.init();
         if(_windowManager == null || _windowManager.roomEngine == null)
         {
            whisper(BobbaI18n.t("alert.npc_noroom","Enter a room first."));
            return;
         }
         customs = _windowManager.LilithCustomsInstance;
         if(customs == null || customs.IsRoomSessionAvailable == false)
         {
            whisper(BobbaI18n.t("alert.npc_noroom","Enter a room first."));
            return;
         }
         try
         {
            stage = _windowManager.context.displayObjectContainer.stage;
         }
         catch(eStage:Error)
         {
            stage = null;
         }
         if(_picker == null || !_picker.startTile(onTile,onAbort,stage))
         {
            whisper(BobbaI18n.t("alert.npc_pickfail","Could not start tile picker."));
            return;
         }
         _picking = true;
         whisper(BobbaI18n.t("alert.npc_pick","Click a tile. Type :npc again to stop."));
      }
      
      private function onTile(x:int, y:int) : void
      {
         _picking = false;
         _tileX = x;
         _tileY = y;
         _timer.start();
         whisper(BobbaI18n.t("alert.npc_on","NPC walking to {0},{1}").split("{0}").join(String(x)).split("{1}").join(String(y)));
         onTick(null);
      }
      
      private function onAbort() : void
      {
         _picking = false;
         whisper(BobbaI18n.t("alert.npc_off","NPC walk stopped!"));
      }
      
      private function onTick(e:TimerEvent) : void
      {
         var customs:* = undefined;
         if(_windowManager == null)
         {
            return;
         }
         customs = _windowManager.LilithCustomsInstance;
         if(customs == null || customs.IsRoomSessionAvailable == false)
         {
            stop();
            return;
         }
         BobbaHotelSend.send(_windowManager,new MoveAvatarMessageComposer(_tileX,_tileY));
      }
      
      private function whisper(text:String) : void
      {
         try
         {
            if(_windowManager != null && _windowManager.LilithCustomsInstance != null)
            {
               _windowManager.LilithCustomsInstance.ShowWhisperAlert(text);
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}
