package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.assets.BitmapDataAsset;
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IDisplayObjectWrapperController;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.components.ILabelWindow;
   import com.sulake.core.window.components.IWidgetWindowController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.utils.MouseCursorControl;
   import com.sulake.core.window.utils.TextStyleManager;
   import com.sulake.core.window.utils.UnknownCoreWindowUtils3;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.habbo.window.widgets.IAvatarImageWidget;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   
   public class BobbaGroupWhisperEditor
   {
      
      private static const FRAME_COLOR:uint = 0xff000000;
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_whisper";
      
      private static const ROW_PREFIX:String = "whisper_";
      
      private static const FRAME_W:int = 320;
      
      private static const FRAME_H:int = 380;
      
      private static const HEADER_H:int = 52;
      
      private static const ROW_W:int = 257;
      
      private static const LIST_SIDE_PAD:int = 8;
      
      private static const ROW_WIDTH_TRIM:int = 4;
      
      private static const ROW_STYLE_RAISED:uint = 104;
      
      private static const ROW_BG_PATH:String = "illumina_dark_border_raised.png";
      
      private static const RAISED_ASSET_NAME:String = "illumina_light_border_raised_png";
      
      private static const ROW_TEXT_STYLE:String = "bobba_gw_row";
      
      private static const ROW_TEXT_COLOR:uint = 0xffffff;
      
      private static const ROW_ETCHING_COLOR:uint = 0xff333333;
      
      private static const REJECT_NAME:String = "reject";
      
      private static const REJECT_W:int = 16;
      
      private static const REJECT_H:int = 14;
      
      private static const REJECT_RIGHT_PAD:int = 8;
      
      private static const NAME_LEFT:int = 37;
      
      private static const MOUSE_INPUT_FLAG:uint = 1;
      
      private static var _rowTextStyleReady:Boolean = false;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupWhisperController;
      
      private var _window:IFrameController;
      
      private var _headerCanvas:IDisplayObjectWrapperController;
      
      private var _headerView:BobbaGroupWhisperHeaderView;
      
      private var _userList:IItemListWindow;
      
      private var _template:IWindowController_1;
      
      private var _donor:IFrameController;
      
      private var _rejectTemplate:IWindowModel;
      
      private var _rowBgLoader:Loader;
      
      private var _rowBgData:BitmapData;
      
      private var _raisedPatched:Boolean = false;
      
      private var _raisedOriginal:BitmapData;
      
      public function BobbaGroupWhisperEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupWhisperController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
         loadRowBackground();
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
            populateMembers();
         }
         else if(_window != null)
         {
            _window.visible = false;
            removeRoomMouseBlockRect();
         }
      }
      
      public function refresh() : void
      {
         if(_window != null)
         {
            _window.caption = BobbaI18n.t("groupwhisper.panel.title","Group whisper");
         }
         populateMembers();
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         disposeRowBgLoader();
         restoreRaisedAsset();
         if(_rowBgData != null)
         {
            try
            {
               _rowBgData.dispose();
            }
            catch(bgErr:Error)
            {
            }
            _rowBgData = null;
         }
         if(_headerView != null)
         {
            _headerView.dispose();
            _headerView = null;
         }
         if(_template != null)
         {
            _template.dispose();
            _template = null;
         }
         if(_rejectTemplate != null)
         {
            try
            {
               _rejectTemplate.dispose();
            }
            catch(rejectDisposeErr:Error)
            {
            }
            _rejectTemplate = null;
         }
         _userList = null;
         _headerCanvas = null;
         if(_donor != null)
         {
            try
            {
               _donor.dispose();
            }
            catch(donorErr:Error)
            {
            }
            _donor = null;
         }
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
         _controller = null;
      }
      
      private function loadRowBackground() : void
      {
         var url:String = null;
         disposeRowBgLoader();
         try
         {
            url = BobbaPack.resolveUrl(ROW_BG_PATH);
            if(url == null || url.length == 0)
            {
               return;
            }
            _rowBgLoader = new Loader();
            _rowBgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onRowBgLoaded);
            _rowBgLoader.contentLoaderInfo.addEventListener("ioError",onRowBgError);
            _rowBgLoader.load(new URLRequest(url));
         }
         catch(loadErr:Error)
         {
         }
      }
      
      private function onRowBgLoaded(e:Event) : void
      {
         var bmp:Bitmap = null;
         try
         {
            if(_rowBgLoader == null)
            {
               return;
            }
            bmp = _rowBgLoader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            if(_rowBgData != null)
            {
               _rowBgData.dispose();
            }
            _rowBgData = bmp.bitmapData.clone();
            patchRaisedAsset();
            populateMembers();
         }
         catch(err:Error)
         {
         }
         disposeRowBgLoader();
      }
      
      private function onRowBgError(e:Event) : void
      {
         disposeRowBgLoader();
      }
      
      private function disposeRowBgLoader() : void
      {
         try
         {
            if(_rowBgLoader != null)
            {
               _rowBgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onRowBgLoaded);
               _rowBgLoader.contentLoaderInfo.removeEventListener("ioError",onRowBgError);
            }
         }
         catch(err:Error)
         {
         }
         _rowBgLoader = null;
      }
      
      private function patchRaisedAsset() : void
      {
         var asset:* = null;
         var bda:BitmapDataAsset = null;
         var current:BitmapData = null;
         if(_raisedPatched || _rowBgData == null || _windowManager == null || _windowManager.assets == null)
         {
            return;
         }
         try
         {
            asset = _windowManager.assets.getAssetByName(RAISED_ASSET_NAME);
            bda = asset as BitmapDataAsset;
            if(bda == null)
            {
               return;
            }
            current = bda.content as BitmapData;
            if(current != null)
            {
               _raisedOriginal = current.clone();
            }
            bda.setUnknownContent(_rowBgData.clone());
            _raisedPatched = true;
         }
         catch(patchErr:Error)
         {
         }
      }
      
      private function restoreRaisedAsset() : void
      {
         var asset:* = null;
         var bda:BitmapDataAsset = null;
         if(!_raisedPatched || _windowManager == null || _windowManager.assets == null)
         {
            if(_raisedOriginal != null)
            {
               try
               {
                  _raisedOriginal.dispose();
               }
               catch(disposeOrigErr:Error)
               {
               }
               _raisedOriginal = null;
            }
            _raisedPatched = false;
            return;
         }
         try
         {
            asset = _windowManager.assets.getAssetByName(RAISED_ASSET_NAME);
            bda = asset as BitmapDataAsset;
            if(bda != null && _raisedOriginal != null)
            {
               bda.setUnknownContent(_raisedOriginal);
               _raisedOriginal = null;
            }
         }
         catch(restoreErr:Error)
         {
         }
         _raisedPatched = false;
      }
      
      private function styleMemberRow(row:IWindowController_1) : void
      {
         var nameWin:ILabelWindow = null;
         var roomWin:ILabelWindow = null;
         var avatarWin:IWindowModel = null;
         var style:UnknownCoreWindowUtils3 = null;
         if(row == null)
         {
            return;
         }
         try
         {
            if(_raisedPatched || _rowBgData != null)
            {
               patchRaisedAsset();
               row.style = ROW_STYLE_RAISED;
               row.color = 0xffffffff;
            }
            ensureRowTextStyle();
            style = TextStyleManager.getStyle(ROW_TEXT_STYLE);
            nameWin = row.findChildByName("user_name") as ILabelWindow;
            if(nameWin != null)
            {
               if(style != null)
               {
                  nameWin.textStyle = style;
               }
               nameWin.textColor = ROW_TEXT_COLOR;
               nameWin.x = NAME_LEFT;
               nameWin.y = int((row.height - nameWin.height) / 2);
               nameWin.width = Math.max(40,row.width - NAME_LEFT - REJECT_W - REJECT_RIGHT_PAD - 6);
               nameWin.setParamFlag(MOUSE_INPUT_FLAG,true);
               nameWin.mouseThreshold = 0;
               nameWin.procedure = onProfileClick;
            }
            roomWin = row.findChildByName("room_name") as ILabelWindow;
            if(roomWin != null)
            {
               roomWin.caption = "";
               roomWin.visible = false;
            }
            avatarWin = row.findChildByName("user_avatar");
            if(avatarWin != null)
            {
               avatarWin.setParamFlag(MOUSE_INPUT_FLAG,true);
               avatarWin.mouseThreshold = 0;
               avatarWin.procedure = onProfileClick;
            }
         }
         catch(styleErr:Error)
         {
         }
      }
      
      private static function ensureRowTextStyle() : void
      {
         var base:UnknownCoreWindowUtils3 = null;
         var style:UnknownCoreWindowUtils3 = null;
         if(_rowTextStyleReady)
         {
            return;
         }
         try
         {
            base = TextStyleManager.getStyle("il_border");
            if(base != null)
            {
               style = base.clone();
            }
            else
            {
               style = new UnknownCoreWindowUtils3();
               style.fontFamily = "Ubuntu";
               style.fontSize = "12";
            }
            style.color = ROW_TEXT_COLOR;
            style.etchingColor = ROW_ETCHING_COLOR;
            style.etchingPosition = "bottom";
            TextStyleManager.setStyle(ROW_TEXT_STYLE,style);
            _rowTextStyleReady = true;
         }
         catch(styleErr:Error)
         {
         }
      }
      
      private function createWindow() : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         var hdr:IWindowModel = null;
         var content:IWindowController_1 = null;
         var donorList:IItemListWindow = null;
         var first:IWindowController_1 = null;
         var donorParent:IWindowController_1 = null;
         try
         {
            layout = <layout name="bobba_group_whisper" width="320" height="380" version="0.1">
					<window>
						<frame x="0" y="0" width="320" height="380" params="33025" style="1" name="bobba_group_whisper_frame" caption="Group whisper" color="0xff000000">
							<children>
								<display_object_wrapper x="0" y="0" width="308" height="52" params="16" style="0" name="bobba_gw_header"/>
							</children>
							<variables>
								<var key="margin_left" value="6" type="int"/>
								<var key="margin_top" value="30" type="int"/>
								<var key="margin_right" value="6" type="int"/>
								<var key="margin_bottom" value="6" type="int"/>
							</variables>
						</frame>
					</window>
				</layout>;
            built = _windowManager.buildFromXML(layout,1);
            _window = built as IFrameController;
            if(_window == null)
            {
               return;
            }
            _window.caption = BobbaI18n.t("groupwhisper.panel.title","Group whisper");
            _window.color = FRAME_COLOR;
            _window.margins.left = 6;
            _window.margins.top = 30;
            _window.margins.right = _window.width - 6;
            _window.margins.bottom = _window.height - 6;
            _window.procedure = windowProcedure;
            _window.center();
            _window.setParamFlag(257,false);
            _window.setParamFlag(32768,true);
            hdr = _window.header as IWindowModel;
            if(hdr != null)
            {
               hdr.setParamFlag(257,true);
               hdr.color = FRAME_COLOR;
            }
            _headerCanvas = _window.findChildByName("bobba_gw_header") as IDisplayObjectWrapperController;
            if(_headerCanvas == null)
            {
               return;
            }
            _headerCanvas.x = 0;
            _headerCanvas.y = 0;
            _headerCanvas.width = BobbaGroupWhisperHeaderView.VIEW_W;
            _headerCanvas.height = BobbaGroupWhisperHeaderView.VIEW_H;
            _headerCanvas.setParamFlag(257,false);
            _headerCanvas.setParamFlag(32768,false);
            _headerView = new BobbaGroupWhisperHeaderView();
            _headerCanvas.setDisplayObject(_headerView);
            _donor = BobbaHabboXml.getXmlWindow(_windowManager,"bully_report") as IFrameController;
            if(_donor == null)
            {
               return;
            }
            _donor.visible = false;
            if(_donor.findChildByName("submit_button") != null)
            {
               _donor.findChildByName("submit_button").visible = false;
            }
            donorList = _donor.findChildByName("user_list") as IItemListWindow;
            if(donorList == null)
            {
               return;
            }
            donorList.spacing = 4;
            if(donorList.numListItems > 0)
            {
               first = donorList.getListItemAt(0) as IWindowController_1;
               if(first != null)
               {
                  _template = first.clone() as IWindowController_1;
               }
               donorList.removeListItems();
            }
            donorParent = donorList.parent as IWindowController_1;
            if(donorParent != null)
            {
               donorParent.removeChild(donorList);
            }
            content = _window.content as IWindowController_1;
            if(content == null)
            {
               return;
            }
            _userList = donorList;
            _userList.name = "user_list";
            _userList.spacing = 4;
            try
            {
               _userList.scaleToFitItems = true;
               _userList.clipping = false;
               if(_userList.scrollableWindow != null)
               {
                  _userList.scrollableWindow.clipping = false;
               }
            }
            catch(scaleErr:Error)
            {
            }
            _userList.width = Math.max(ROW_W + 8,content.width - LIST_SIDE_PAD * 2 - ROW_WIDTH_TRIM);
            _userList.x = Math.round((content.width - _userList.width) / 2);
            _userList.y = HEADER_H + 4;
            _userList.height = content.height - HEADER_H - 8;
            content.addChild(_userList);
            try
            {
               _donor.dispose();
            }
            catch(disposeDonorErr:Error)
            {
            }
            _donor = null;
            _window.visible = true;
            _window.activate();
            populateMembers();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
         }
      }
      
      private function populateMembers() : void
      {
         var i:int = 0;
         var row:IWindowController_1 = null;
         var nick:String = null;
         var figure:String = null;
         var names:Array = null;
         var hint:String = null;
         var rejectBtn:IWindowModel = null;
         if(_window == null || _template == null || _userList == null)
         {
            return;
         }
         _userList.spacing = 4;
         _userList.removeListItems();
         if(_controller == null)
         {
            return;
         }
         names = _controller.getMembers();
         if(names == null || names.length == 0)
         {
            hint = BobbaI18n.t("groupwhisper.panel.empty","No one in the whisper group.");
            if(_headerView != null)
            {
               _headerView.setHint(hint);
            }
            return;
         }
         hint = BobbaI18n.t("groupwhisper.panel.hint","People you are whispering to.");
         if(_headerView != null)
         {
            _headerView.setHint(hint);
         }
         for(i = 0; i < names.length; i++)
         {
            nick = String(names[i]);
            if(nick == null || nick.length == 0)
            {
               continue;
            }
            row = _template.clone() as IWindowController_1;
            row.name = ROW_PREFIX + nick;
            row.blend = 1;
            row.width = resolveRowWidth();
            row.findChildByName("user_name").caption = nick;
            styleMemberRow(row);
            figure = resolveFigure(nick);
            try
            {
               IAvatarImageWidget(IWidgetWindowController(row.findChildByName("user_avatar")).widget).figure = figure != null ? figure : "";
            }
            catch(figErr:Error)
            {
            }
            rejectBtn = createRejectButton(row);
            if(rejectBtn != null)
            {
               row.addChild(rejectBtn);
            }
            _userList.addListItem(row);
         }
      }
      
      private function ensureRejectTemplate() : IWindowModel
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         if(_rejectTemplate != null)
         {
            return _rejectTemplate;
         }
         if(_windowManager == null)
         {
            return null;
         }
         try
         {
            layout = <layout name="bobba_gw_reject" width="16" height="14" version="0.1">
					<window>
						<container x="0" y="0" width="16" height="14" params="81" style="0" name="reject" background="true">
							<children>
								<icon x="0" y="0" width="16" height="14" params="16" style="9" name="icon" color="0x0ff3333"/>
							</children>
						</container>
					</window>
				</layout>;
            built = _windowManager.buildFromXML(layout,1);
            if(built != null)
            {
               if(built.name == REJECT_NAME)
               {
                  _rejectTemplate = built;
               }
               else
               {
                  _rejectTemplate = built.findChildByName(REJECT_NAME);
                  if(_rejectTemplate == null)
                  {
                     _rejectTemplate = built;
                  }
               }
            }
         }
         catch(rejectTplErr:Error)
         {
            _rejectTemplate = null;
         }
         return _rejectTemplate;
      }
      
      private function createRejectButton(row:IWindowController_1) : IWindowModel
      {
         var tpl:IWindowModel = null;
         var btn:IWindowModel = null;
         var icon:IWindowModel = null;
         var host:IWindowController_1 = null;
         tpl = ensureRejectTemplate();
         if(tpl == null || row == null)
         {
            return null;
         }
         try
         {
            btn = tpl.clone();
            if(btn == null)
            {
               return null;
            }
            btn.name = REJECT_NAME;
            btn.width = REJECT_W;
            btn.height = REJECT_H;
            btn.x = Math.max(0,row.width - REJECT_W - REJECT_RIGHT_PAD);
            btn.y = int((row.height - REJECT_H) / 2);
            btn.visible = true;
            btn.setParamFlag(MOUSE_INPUT_FLAG,true);
            btn.mouseThreshold = 0;
            btn.procedure = onRejectClick;
            host = btn as IWindowController_1;
            if(host != null)
            {
               icon = host.findChildByName("icon");
            }
            if(icon != null)
            {
               icon.setParamFlag(MOUSE_INPUT_FLAG,true);
               icon.mouseThreshold = 0;
               icon.procedure = onRejectClick;
            }
            return btn;
         }
         catch(rejectCloneErr:Error)
         {
         }
         return null;
      }
      
      private function resolveRowWidth() : int
      {
         var inner:IWindowModel = null;
         var width:int = ROW_W;
         if(_userList == null)
         {
            return Math.max(1,width - ROW_WIDTH_TRIM);
         }
         try
         {
            inner = _userList.scrollableWindow;
            if(inner != null && inner.width > 0)
            {
               width = int(inner.width);
            }
            else if(_userList.width > 0)
            {
               width = int(_userList.width);
            }
         }
         catch(widthErr:Error)
         {
            if(_userList.width > 0)
            {
               width = int(_userList.width);
            }
         }
         return Math.max(1,width - ROW_WIDTH_TRIM);
      }
      
      private function resolveFigure(nickname:String) : String
      {
         var session:* = null;
         var userData:* = null;
         try
         {
            if(_windowManager == null || _windowManager.LilithCustomsInstance == null)
            {
               return "";
            }
            if(!_windowManager.LilithCustomsInstance.IsRoomSessionAvailable)
            {
               return "";
            }
            session = _windowManager.LilithCustomsInstance.RoomSession;
            if(session == null || session.userDataManager == null)
            {
               return "";
            }
            userData = session.userDataManager.getUserDataByName(nickname);
            if(userData != null && userData.figure != null)
            {
               return String(userData.figure);
            }
         }
         catch(figErr:Error)
         {
         }
         return "";
      }
      
      private function nicknameFromTarget(target:IWindowModel) : String
      {
         var node:IWindowModel = target;
         while(node != null)
         {
            if(node.name != null && node.name.indexOf(ROW_PREFIX) == 0)
            {
               return node.name.substring(ROW_PREFIX.length);
            }
            try
            {
               node = node.parent as IWindowModel;
            }
            catch(parentErr:Error)
            {
               break;
            }
         }
         return "";
      }
      
      private function onRejectClick(event:WindowEvent, target:IWindowModel) : void
      {
         var nick:String = null;
         if(event == null)
         {
            return;
         }
         if(event.type == "WME_OVER")
         {
            MouseCursorControl.type = 2;
            return;
         }
         if(event.type == "WME_OUT")
         {
            MouseCursorControl.type = 0;
            return;
         }
         if(event.type != "WME_CLICK" || _controller == null)
         {
            return;
         }
         nick = nicknameFromTarget(target);
         if(nick != null && nick.length > 0)
         {
            _controller.remove(nick);
         }
      }
      
      private function onProfileClick(event:WindowEvent, target:IWindowModel) : void
      {
         var nick:String = null;
         if(event == null)
         {
            return;
         }
         if(event.type == "WME_OVER")
         {
            MouseCursorControl.type = 2;
            return;
         }
         if(event.type == "WME_OUT")
         {
            MouseCursorControl.type = 0;
            return;
         }
         if(event.type != "WME_CLICK" || _controller == null)
         {
            return;
         }
         nick = nicknameFromTarget(target);
         if(nick != null && nick.length > 0)
         {
            _controller.openUserProfile(nick);
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK" && target.name == "header_button_close")
         {
            visible = false;
            return;
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
            if(rect.isEmpty())
            {
               removeRoomMouseBlockRect();
               return;
            }
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
