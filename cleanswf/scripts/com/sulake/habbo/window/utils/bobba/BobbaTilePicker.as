package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.habbo.room.IRoomAreaSelectionManager;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class BobbaTilePicker
   {
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _mgr:IRoomAreaSelectionManager;
      
      private var _onRect:Function;
      
      private var _onTile:Function;
      
      private var _onAbort:Function;
      
      private var _stage:Stage;
      
      private var _active:Boolean;
      
      private var _rootMode:Boolean;
      
      private var _dimX:int;
      
      private var _dimY:int;
      
      private var _hoverX:int;
      
      private var _hoverY:int;
      
      private var _hoverOk:Boolean;
      
      private var _timer:Timer;
      
      private var _ignoreUntil:int;
      
      private var _ghost:BobbaPresetGhost;
      
      public function BobbaTilePicker(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _active = false;
         _rootMode = false;
         _hoverOk = false;
         _dimX = 1;
         _dimY = 1;
         _hoverX = 0;
         _hoverY = 0;
         _ignoreUntil = 0;
         _ghost = new BobbaPresetGhost();
      }
      
      public function get active() : Boolean
      {
         return _active;
      }
      
      public function startRect(onRect:Function, onAbort:Function, stage:Stage) : Boolean
      {
         stop();
         if(_windowManager == null || _windowManager.roomEngine == null || onRect == null)
         {
            return false;
         }
         _mgr = _windowManager.roomEngine.areaSelectionManager;
         if(_mgr == null)
         {
            return false;
         }
         _onRect = onRect;
         _onAbort = onAbort;
         _stage = stage;
         _rootMode = false;
         if(_mgr.activate(onAreaSelected,"highlight_blue") != true)
         {
            _mgr = null;
            return false;
         }
         _mgr.startSelecting();
         _active = true;
         hookKey();
         return true;
      }
      
      public function startRoot(cfg:BobbaPresetConfig, onTile:Function, onAbort:Function, stage:Stage) : Boolean
      {
         stop();
         if(_windowManager == null || _windowManager.roomEngine == null || onTile == null || cfg == null)
         {
            return false;
         }
         _onTile = onTile;
         _onAbort = onAbort;
         _stage = stage;
         _rootMode = true;
         _dimX = cfg.dimX() > 0 ? cfg.dimX() : 1;
         _dimY = cfg.dimY() > 0 ? cfg.dimY() : 1;
         _hoverOk = false;
         if(_ghost == null)
         {
            _ghost = new BobbaPresetGhost();
         }
         _ghost.attach(_windowManager,cfg);
         try
         {
            _windowManager.roomEngine.setMoveBlocked(true);
         }
         catch(eBlock:Error)
         {
         }
         _active = true;
         _ignoreUntil = getTimer() + 250;
         hookKey();
         if(_stage != null)
         {
            _stage.addEventListener("click",onStageClick);
         }
         if(_timer == null)
         {
            _timer = new Timer(50,0);
            _timer.addEventListener("timer",onRootTick);
         }
         _timer.start();
         return true;
      }
      
      public function stop() : void
      {
         var mgr:IRoomAreaSelectionManager = _mgr;
         unhookStage();
         stopTimer();
         if(_ghost != null)
         {
            _ghost.clear();
         }
         _onRect = null;
         _onTile = null;
         _onAbort = null;
         _mgr = null;
         _active = false;
         _rootMode = false;
         _hoverOk = false;
         try
         {
            if(_windowManager != null && _windowManager.roomEngine != null)
            {
               _windowManager.roomEngine.setMoveBlocked(false);
            }
         }
         catch(eUnblock:Error)
         {
         }
         if(mgr != null)
         {
            try
            {
               mgr.deactivate();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function dispose() : void
      {
         stop();
         if(_timer != null)
         {
            _timer.removeEventListener("timer",onRootTick);
            _timer = null;
         }
         if(_ghost != null)
         {
            _ghost.dispose();
            _ghost = null;
         }
         _windowManager = null;
         _stage = null;
      }
      
      private function onRootTick(e:*) : void
      {
         var customs:* = undefined;
         var session:* = undefined;
         var roomId:int = 0;
         var cursor:* = undefined;
         var loc:* = undefined;
         var x:int = 0;
         var y:int = 0;
         if(!_rootMode || !_active || _windowManager == null || _windowManager.roomEngine == null)
         {
            return;
         }
         try
         {
            customs = _windowManager.LilithCustomsInstance;
            if(customs == null || customs.RoomSession == null)
            {
               return;
            }
            session = customs.RoomSession;
            roomId = int(session.roomId);
            cursor = _windowManager.roomEngine.getTileCursor(roomId);
            if(cursor == null)
            {
               return;
            }
            loc = cursor.getLocation();
            if(loc == null)
            {
               return;
            }
            x = int(Math.floor(Number(loc.x) + 0.0001));
            y = int(Math.floor(Number(loc.y) + 0.0001));
            _hoverX = x;
            _hoverY = y;
            _hoverOk = true;
            if(_ghost != null)
            {
               _ghost.moveTo(x,y);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function onStageClick(e:MouseEvent) : void
      {
         var cb:Function = null;
         var x:int = 0;
         var y:int = 0;
         if(!_rootMode || !_active || !_hoverOk)
         {
            return;
         }
         if(getTimer() < _ignoreUntil)
         {
            return;
         }
         cb = _onTile;
         x = _hoverX;
         y = _hoverY;
         stop();
         if(cb != null)
         {
            cb(x,y);
         }
      }
      
      private function onAreaSelected(x:int, y:int, w:int, h:int) : void
      {
         var cb:Function = _onRect;
         var abortCb:Function = _onAbort;
         stop();
         if(w < 1 || h < 1)
         {
            if(abortCb != null)
            {
               abortCb();
            }
            return;
         }
         if(cb != null)
         {
            cb(x,y,x + w - 1,y + h - 1);
         }
      }
      
      private function onKey(e:KeyboardEvent) : void
      {
         var abortCb:Function = null;
         if(e == null || e.keyCode != Keyboard.ESCAPE)
         {
            return;
         }
         abortCb = _onAbort;
         stop();
         if(abortCb != null)
         {
            abortCb();
         }
      }
      
      private function hookKey() : void
      {
         if(_stage != null)
         {
            _stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
         }
      }
      
      private function unhookStage() : void
      {
         if(_stage != null)
         {
            _stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKey);
            _stage.removeEventListener("click",onStageClick);
         }
         _stage = null;
      }
      
      private function stopTimer() : void
      {
         if(_timer != null)
         {
            try
            {
               _timer.stop();
            }
            catch(e:Error)
            {
            }
         }
      }
   }
}
