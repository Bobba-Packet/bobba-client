package com.sulake.habbo.room
{
   public interface IRoomAreaSelectionManager
   {
      
      function activate(param1:Function, param2:String) : Boolean;
      
      function deactivate() : void;
      
      function startSelecting() : void;
      
      function clearHighlight() : void;
      
      function setHighlight(param1:int, param2:int, param3:int, param4:int) : void;
   }
}

