package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.utils.FontEnum;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.ITextFieldWindow;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   
   public class BobbaCommandAutocomplete
   {
      
      private static const COLOR_FADED:uint = 6710886;
      
      private static const FONT_SIZE:int = 12;
      
      private static const FONT_NAME:String = "Ubuntu";
      
      private static const TEXT_GUTTER:Number = 2;
      
      private static const OFFSET_X:Number = -1;
            
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _ghost:TextField;
      
      private var _measure:TextField;
      
      private var _matches:Array;
      
      private var _commands:Array;
      
      private var _selectedIndex:int;
      
      private var _active:Boolean;
      
      private var _prefixLength:int;
      
      private var _lastPrefix:String;
      
      public function BobbaCommandAutocomplete(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _matches = [];
         _commands = [];
         _selectedIndex = 0;
         _active = false;
         _prefixLength = 0;
         _lastPrefix = "";
      }
      
      public function setCommands(commands:Array) : void
      {
         _commands = commands != null ? commands : [];
      }
      
      public function update(input:ITextFieldWindow) : void
      {
         var text:String = null;
         var firstToken:String = null;
         var spaceIndex:int = 0;
         if(input == null)
         {
            hide();
            return;
         }
         text = input.text;
         if(text == null || text.indexOf(":") != 0)
         {
            hide();
            return;
         }
         spaceIndex = text.indexOf(" ");
         if(spaceIndex >= 0)
         {
            hide();
            return;
         }
         firstToken = text.toLowerCase();
         _prefixLength = text.length;
         if(firstToken != _lastPrefix)
         {
            resetSelection();
            _lastPrefix = firstToken;
         }
         _matches = collectMatches(firstToken);
         if(_matches.length == 0)
         {
            hide();
            return;
         }
         if(_selectedIndex >= _matches.length)
         {
            _selectedIndex = _matches.length - 1;
         }
         if(_selectedIndex < 0)
         {
            _selectedIndex = 0;
         }
         refreshGhost(input);
      }
      
      public function hide() : void
      {
         _active = false;
         _matches = [];
         _selectedIndex = 0;
         _prefixLength = 0;
         _lastPrefix = "";
         if(_ghost != null)
         {
            _ghost.text = "";
            _ghost.visible = false;
            if(_ghost.parent != null)
            {
               _ghost.parent.removeChild(_ghost);
            }
         }
      }
      
      public function handleKeyDown(keyCode:int, input:ITextFieldWindow) : Boolean
      {
         if(input == null)
         {
            return false;
         }
         if(keyCode == Keyboard.TAB)
         {
            if(!_active || _matches.length == 0)
            {
               return false;
            }
            applySelection(input);
            return true;
         }
         if(keyCode == Keyboard.ESCAPE)
         {
            if(_active)
            {
               hide();
               return true;
            }
            return false;
         }
         if(!_active || _matches.length == 0)
         {
            return false;
         }
         if(keyCode == Keyboard.DOWN)
         {
            if(_selectedIndex < _matches.length - 1)
            {
               _selectedIndex++;
               refreshGhost(input);
            }
            restoreCaret(input);
            return true;
         }
         if(keyCode == Keyboard.UP)
         {
            if(_selectedIndex > 0)
            {
               _selectedIndex--;
               refreshGhost(input);
            }
            restoreCaret(input);
            return true;
         }
         return false;
      }
      
      public function handleKeyUp(keyCode:int, input:ITextFieldWindow) : Boolean
      {
         return false;
      }
      
      public function resetSelection() : void
      {
         _selectedIndex = 0;
      }
      
      private function collectMatches(prefix:String) : Array
      {
         var matches:Array = [];
         var command:String = null;
         var lower:String = null;
         for each(command in _commands)
         {
            if(command == null || command == "")
            {
               continue;
            }
            lower = String(command).toLowerCase();
            if(lower.indexOf(prefix) == 0)
            {
               matches.push(lower);
            }
         }
         matches.sort(Array.CASEINSENSITIVE);
         return matches;
      }
      
      private function ensureGhost() : void
      {
         if(_ghost != null)
         {
            return;
         }
         _measure = createField(false);
         _ghost = createField(true);
      }
      
      private function createField(visibleField:Boolean) : TextField
      {
         var field:TextField = new TextField();
         var fmt:TextFormat = new TextFormat();
         fmt.size = FONT_SIZE;
         fmt.color = COLOR_FADED;
         if(FontEnum.isEmbeddedFont(FONT_NAME))
         {
            fmt.font = FONT_NAME;
            field.embedFonts = true;
            field.antiAliasType = "advanced";
            field.gridFitType = "pixel";
         }
         else
         {
            fmt.font = "Verdana";
         }
         field.defaultTextFormat = fmt;
         field.autoSize = TextFieldAutoSize.LEFT;
         field.selectable = false;
         field.mouseEnabled = false;
         field.multiline = false;
         field.wordWrap = false;
         field.background = false;
         field.border = false;
         if(visibleField)
         {
            field.alpha = 0.7;
         }
         else
         {
            field.visible = false;
         }
         return field;
      }
      
      private function refreshGhost(input:ITextFieldWindow) : void
      {
         var prefix:String = null;
         var command:String = null;
         var suffix:String = null;
         var host:DisplayObjectContainer = null;
         var origin:Point = null;
         var prefixWidth:Number = NaN;
         var fmt:TextFormat = null;
         if(input == null || _matches.length == 0)
         {
            hide();
            return;
         }
         prefix = input.text;
         command = String(_matches[_selectedIndex]);
         if(command.length <= prefix.length)
         {
            hide();
            return;
         }
         suffix = command.substring(prefix.length);
         if(suffix == null || suffix == "")
         {
            hide();
            return;
         }
         host = getHost();
         if(host == null)
         {
            hide();
            return;
         }
         ensureGhost();
         if(_ghost == null || _measure == null)
         {
            hide();
            return;
         }
         fmt = copyInputFormat(input);
         _measure.defaultTextFormat = fmt;
         _measure.setTextFormat(fmt);
         _measure.text = prefix;
         prefixWidth = _measure.textWidth;
         _ghost.defaultTextFormat = fmt;
         _ghost.setTextFormat(fmt);
         _ghost.text = suffix;
         origin = getInputStagePos(input);
         _ghost.x = origin.x + TEXT_GUTTER + prefixWidth + OFFSET_X;
         _ghost.y = origin.y;
         _ghost.visible = true;
         if(_ghost.parent != host)
         {
            if(_ghost.parent != null)
            {
               _ghost.parent.removeChild(_ghost);
            }
            host.addChild(_ghost);
         }
         else
         {
            host.addChild(_ghost);
         }
         _active = true;
      }
      
      private function copyInputFormat(input:ITextFieldWindow) : TextFormat
      {
         var fmt:TextFormat = null;
         var copied:TextFormat = new TextFormat();
         copied.size = FONT_SIZE;
         copied.color = COLOR_FADED;
         copied.font = FONT_NAME;
         copied.italic = false;
         copied.bold = false;
         try
         {
            fmt = input.defaultTextFormat;
            if(fmt == null)
            {
               fmt = input.getTextFormat();
            }
         }
         catch(formatErr:Error)
         {
            fmt = null;
         }
         if(fmt != null)
         {
            if(fmt.font != null)
            {
               copied.font = fmt.font;
            }
            if(fmt.size != null)
            {
               copied.size = fmt.size;
            }
            if(fmt.bold != null)
            {
               copied.bold = fmt.bold;
            }
         }
         copied.color = COLOR_FADED;
         copied.italic = false;
         return copied;
      }
      
      private function getInputStagePos(input:ITextFieldWindow) : Point
      {
         var pos:Point = new Point(0,0);
         var cur:IWindowModel = input as IWindowModel;
         while(cur != null)
         {
            pos.x += cur.x;
            pos.y += cur.y;
            try
            {
               cur = cur.parent as IWindowModel;
            }
            catch(walkErr:Error)
            {
               break;
            }
         }
         return pos;
      }
      
      private function getHost() : DisplayObjectContainer
      {
         var container:DisplayObjectContainer = null;
         try
         {
            container = _windowManager.context.displayObjectContainer;
            if(container != null && container.stage != null)
            {
               return container.stage;
            }
            return container;
         }
         catch(hostErr:Error)
         {
         }
         return null;
      }
      
      private function applySelection(input:ITextFieldWindow) : void
      {
         var command:String = null;
         var caret:int = 0;
         if(!_active || _matches.length == 0 || input == null)
         {
            return;
         }
         command = String(_matches[_selectedIndex]);
         if(command == null || command.length == 0)
         {
            return;
         }
         input.text = command + " ";
         caret = input.text.length;
         input.setSelection(caret,caret);
         _lastPrefix = "";
         _prefixLength = caret;
      }
      
      private function restoreCaret(input:ITextFieldWindow) : void
      {
         var caret:int = 0;
         if(input == null)
         {
            return;
         }
         caret = _prefixLength;
         if(caret < 0)
         {
            caret = 0;
         }
         if(caret > input.text.length)
         {
            caret = input.text.length;
         }
         input.setSelection(caret,caret);
      }
   }
}
