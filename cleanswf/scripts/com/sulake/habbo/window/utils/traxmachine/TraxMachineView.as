package com.sulake.habbo.window.utils.traxmachine
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BitmapDataChannel;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   
   public class TraxMachineView extends Sprite
   {
      
      public static const MACHINE_W:int = 577;
      
      public static const MACHINE_H:int = 311;
      
      public static const CONTENT_X:int = 14;
      
      public static const CONTENT_TOP:int = 8;
      
      public static const CELL:int = 21;
      
      public static const CELL_STRIDE:int = 22;
      
      public static const VISIBLE_CELLS:int = 24;
      
      public static const LAYERS:int = 4;
      
      public static const LAYER_H:int = 27;
      
      public static const TL_BORDER:int = 6;
      
      public static const TL_PAD_TOP:int = 6;
      
      public static const TL_PAD_LEFT:int = 12;
      
      public static const TL_PAD_RIGHT:int = 6;
      
      public static const TL_LAYER_W:int = 531;
      
      public static const NEEDLE_H:int = 117;
      
      public static const TIMELINE_PAD_X:int = TL_PAD_LEFT;
      
      public static const TIMELINE_PAD_Y:int = TL_PAD_TOP;
      
      public static const TRACK_PAD_X:int = 1;
      
      public static const TRACK_PAD_Y:int = 2;
      
      private static const LAYER_COLORS:Array = [0x89dc00,0xefb100,0xef00b8,0x00d2dc];
      
      private static const BTN_NORMAL:int = 0;
      
      private static const BTN_ACTIVE:int = 1;
      
      private static const BTN_DISABLED:int = 2;
      
      private var _assets:TraxMachineAssets;
      
      private var _catalog:TraxMachineCatalog;
      
      private var _player:TraxMachinePlayer;
      
      private var _iconButtons:Dictionary;
      
      private var _playAsset:String = "play.png";
      
      public var cancelHostDrag:Function;
      
      private var _cartuchoPage:int = 0;
      
      private var _cartuchoVisible:Vector.<Boolean>;
      
      private var _palhetaCartucho:Vector.<int>;
      
      private var _timeline:Vector.<Vector.<TimelineCell>>;
      
      private var _timelineLen:int = 24;
      
      private var _origem:int = 0;
      
      private var _dragLayer:int = -1;
      
      private var _dragClass:int = -1;
      
      private var _dragGhost:Sprite;
      
      private var _cartuchosList:Sprite;
      
      private var _pagerLabel:TextField;
      
      private var _palhetasRoot:Sprite;
      
      private var _timelineRoot:Sprite;
      
      private var _layersContainer:Sprite;
      
      private var _layerRows:Vector.<Sprite>;
      
      private var _layerTracks:Vector.<Sprite>;
      
      private var _playheadBar:Sprite;
      
      private var _playheadHit:Sprite;
      
      private var _draggingPlayhead:Boolean = false;
      
      private var _moduleFaceMask:BitmapData;
      
      private var _btnPlay:Sprite;
      
      private var _btnStop:Sprite;
      
      private var _btnClear:Sprite;
      
      private var _isPlaying:Boolean = false;
      
      private var _status:TextField;
      
      public function TraxMachineView(assets:TraxMachineAssets, catalog:TraxMachineCatalog, player:TraxMachinePlayer)
      {
         var i:int = 0;
         super();
         _assets = assets;
         _catalog = catalog;
         _player = player;
         _player.onTick = onPlayTick;
         _iconButtons = new Dictionary(true);
         _cartuchoVisible = new Vector.<Boolean>(73,true);
         _palhetaCartucho = new Vector.<int>(4,true);
         for(i = 1; i <= 72; i++)
         {
            _cartuchoVisible[i] = true;
         }
         for(i = 0; i < 4; i++)
         {
            _palhetaCartucho[i] = 0;
         }
         _timeline = new Vector.<Vector.<TimelineCell>>(LAYERS,true);
         for(i = 0; i < LAYERS; i++)
         {
            _timeline[i] = new Vector.<TimelineCell>();
         }
         ensureTimelineLength(_timelineLen);
         build();
         addEventListener(MouseEvent.MOUSE_DOWN,onViewMouseDown,true);
      }
      
      private function onViewMouseDown(e:MouseEvent) : void
      {
         if(cancelHostDrag != null)
         {
            cancelHostDrag();
         }
      }
      
      public function dispose() : void
      {
         if(_moduleFaceMask != null)
         {
            _moduleFaceMask.dispose();
            _moduleFaceMask = null;
         }
         _player = null;
         _assets = null;
         _catalog = null;
         removeChildren();
      }
      
      private function build() : void
      {
         // Match HTML-Trax body fill (#587580); Habbo frame style 1 provides chrome.
         graphics.beginFill(0x587580,1);
         graphics.drawRect(0,0,MACHINE_W,MACHINE_H);
         graphics.endFill();
         buildCartuchos();
         buildPalhetas();
         buildControls();
         buildTimeline();
         _status = makeLabel("",CONTENT_X,MACHINE_H - 18,MACHINE_W - 40,0xffffff);
         addChild(_status);
         setStatus("Trax Machine ready");
         refreshCartuchos();
         refreshPalhetas();
         refreshTimeline();
      }
      
      private function buildCartuchos() : void
      {
         var root:Sprite = new Sprite();
         var listBg:BitmapData = null;
         var pager:Sprite = null;
         var pagerBg:BitmapData = null;
         var left:Sprite = null;
         var right:Sprite = null;
         var listW:int = 139;
         var pagerW:int = 74;
         root.x = CONTENT_X;
         root.y = CONTENT_TOP;
         addChild(root);
         listBg = _assets.getBitmap("cartuchos-list.png");
         if(listBg != null)
         {
            root.addChild(new Bitmap(listBg));
            listW = listBg.width;
         }
         _cartuchosList = new Sprite();
         _cartuchosList.x = 9;
         _cartuchosList.y = 10;
         root.addChild(_cartuchosList);
         pager = new Sprite();
         pagerBg = _assets.getBitmap("pager-background.png");
         if(pagerBg != null)
         {
            pager.addChild(new Bitmap(pagerBg));
            pagerW = pagerBg.width;
         }
         // Center pager under the cartuchos list.
         pager.x = int((listW - pagerW) / 2);
         pager.y = 125;
         left = makeIconButton("pager-left.png",8,4,10,function(e:MouseEvent):void
         {
            moveCartuchoPage(-1);
         });
         right = makeIconButton("pager-right.png",pagerW - 18,4,10,function(e:MouseEvent):void
         {
            moveCartuchoPage(1);
         });
         pager.addChild(left);
         pager.addChild(right);
         _pagerLabel = makeLabel("1/24",18,3,pagerW - 36,0xaaaaaa,TextFormatAlign.CENTER);
         pager.addChild(_pagerLabel);
         root.addChild(pager);
      }
      
      private function buildPalhetas() : void
      {
         _palhetasRoot = new Sprite();
         _palhetasRoot.x = CONTENT_X + 139;
         _palhetasRoot.y = CONTENT_TOP;
         addChild(_palhetasRoot);
         var strip:BitmapData = _assets.getBitmap("palhetas.png");
         if(strip != null)
         {
            _palhetasRoot.addChild(new Bitmap(strip));
         }
         var i:int = 0;
         for(i = 0; i < 4; i++)
         {
            var slot:Sprite = new Sprite();
            slot.name = "palheta_" + i;
            slot.x = 4 + i * 103;
            slot.y = 0;
            var slotBg:BitmapData = _assets.getBitmap("palheta.png");
            if(slotBg != null)
            {
               slot.addChild(new Bitmap(slotBg));
            }
            _palhetasRoot.addChild(slot);
         }
      }
      
      private function buildControls() : void
      {
         var controls:Sprite = new Sprite();
         var contentRight:int = TL_PAD_LEFT + TL_LAYER_W;
         controls.x = CONTENT_X;
         controls.y = CONTENT_TOP + 129;
         addChild(controls);
         // Right-align controls with timeline content (before right pad).
         _btnPlay = makeIconButton("play.png",contentRight - 201,0,56,onPlayClick);
         _btnStop = makeIconButton("stop.png",contentRight - 140,0,56,onStopClick);
         _btnClear = makeIconButton("clear.png",contentRight - 79,0,36,onClearClick);
         var left:Sprite = makeIconButton("moveLeft.png",contentRight - 38,0,19,function(e:MouseEvent):void
         {
            moveTimeline(-1);
         });
         var right:Sprite = makeIconButton("moveRight.png",contentRight - 19,0,19,function(e:MouseEvent):void
         {
            moveTimeline(1);
         });
         controls.addChild(_btnPlay);
         controls.addChild(_btnStop);
         controls.addChild(_btnClear);
         controls.addChild(left);
         controls.addChild(right);
      }
      
      private function buildTimeline() : void
      {
         var i:int = 0;
         var row:Sprite = null;
         var track:Sprite = null;
         var layerBg:BitmapData = null;
         var needle:BitmapData = null;
         var chrome:BitmapData = null;
         var tlSrc:BitmapData = null;
         var layersH:int = LAYERS * LAYER_H;
         var padBottom:int = TL_PAD_TOP + Math.max(0,NEEDLE_H - layersH);
         var tlW:int = TL_PAD_LEFT + TL_LAYER_W + TL_PAD_RIGHT;
         var tlH:int = TL_PAD_TOP + layersH + padBottom;
         _timelineRoot = new Sprite();
         _timelineRoot.x = CONTENT_X;
         _timelineRoot.y = CONTENT_TOP + 154;
         addChild(_timelineRoot);
         // HTML-Trax: background hsl(196,18%,45%) + border-image timeline.png 6
         _timelineRoot.graphics.beginFill(0x5e7c87,1);
         _timelineRoot.graphics.drawRect(TL_BORDER,TL_BORDER,tlW - TL_BORDER * 2,tlH - TL_BORDER * 2);
         _timelineRoot.graphics.endFill();
         tlSrc = _assets.getBitmap("timeline.png");
         if(tlSrc != null)
         {
            chrome = buildBorderImage(tlSrc,TL_BORDER,tlW,tlH);
            _timelineRoot.addChild(new Bitmap(chrome));
         }
         _layersContainer = new Sprite();
         _layersContainer.x = TL_PAD_LEFT;
         _layersContainer.y = TL_PAD_TOP;
         _timelineRoot.addChild(_layersContainer);
         _layerRows = new Vector.<Sprite>(LAYERS,true);
         _layerTracks = new Vector.<Sprite>(LAYERS,true);
         for(i = 0; i < LAYERS; i++)
         {
            row = new Sprite();
            row.y = i * LAYER_H;
            row.name = "layer_" + i;
            layerBg = _assets.getBitmap("timeline-layer-background.png");
            if(layerBg != null)
            {
               row.addChild(new Bitmap(layerBg));
            }
            track = new Sprite();
            track.x = TRACK_PAD_X;
            track.y = TRACK_PAD_Y;
            track.scrollRect = new Rectangle(0,0,VISIBLE_CELLS * CELL_STRIDE,CELL);
            row.addChild(track);
            _layersContainer.addChild(row);
            _layerRows[i] = row;
            _layerTracks[i] = track;
         }
         _playheadBar = new Sprite();
         _playheadBar.mouseEnabled = false;
         _playheadBar.mouseChildren = false;
         needle = _assets.getBitmap("agulha.png");
         if(needle != null)
         {
            _playheadBar.addChild(new Bitmap(needle));
         }
         else
         {
            _playheadBar.graphics.beginFill(0xdcebf0,0.28);
            _playheadBar.graphics.drawRect(3,0,19,LAYERS * LAYER_H + 8);
            _playheadBar.graphics.endFill();
            _playheadBar.graphics.lineStyle(1,0x000000,0.9);
            _playheadBar.graphics.drawRect(2,0,21,LAYERS * LAYER_H + 8);
         }
         // Wider invisible hit target for dragging the needle.
         _playheadHit = new Sprite();
         _playheadHit.buttonMode = true;
         _playheadHit.graphics.beginFill(0xffffff,0);
         _playheadHit.graphics.drawRect(0,0,CELL_STRIDE + 8,LAYERS * LAYER_H + 12);
         _playheadHit.graphics.endFill();
         _playheadHit.addEventListener(MouseEvent.MOUSE_DOWN,onPlayheadDown);
         _timelineRoot.addChild(_playheadBar);
         _timelineRoot.addChild(_playheadHit);
         // Allow scrubbing by dragging anywhere on the timeline surface.
         _timelineRoot.addEventListener(MouseEvent.MOUSE_DOWN,onTimelineScrubDown);
      }
      
      private function buildBorderImage(src:BitmapData, slice:int, w:int, h:int) : BitmapData
      {
         var out:BitmapData = new BitmapData(w,h,true,0);
         var midSrcW:int = src.width - slice * 2;
         var midSrcH:int = src.height - slice * 2;
         var midDstW:int = w - slice * 2;
         var midDstH:int = h - slice * 2;
         if(midSrcW < 1 || midSrcH < 1 || midDstW < 1 || midDstH < 1)
         {
            return out;
         }
         blitScale9Region(src,out,0,0,slice,slice,0,0,slice,slice);
         blitScale9Region(src,out,src.width - slice,0,slice,slice,w - slice,0,slice,slice);
         blitScale9Region(src,out,0,src.height - slice,slice,slice,0,h - slice,slice,slice);
         blitScale9Region(src,out,src.width - slice,src.height - slice,slice,slice,w - slice,h - slice,slice,slice);
         blitScale9Region(src,out,slice,0,midSrcW,slice,slice,0,midDstW,slice);
         blitScale9Region(src,out,slice,src.height - slice,midSrcW,slice,slice,h - slice,midDstW,slice);
         blitScale9Region(src,out,0,slice,slice,midSrcH,0,slice,slice,midDstH);
         blitScale9Region(src,out,src.width - slice,slice,slice,midSrcH,w - slice,slice,slice,midDstH);
         return out;
      }
      
      private function blitScale9Region(src:BitmapData, dst:BitmapData, sx:int, sy:int, sw:int, sh:int, dx:int, dy:int, dw:int, dh:int) : void
      {
         var tmp:BitmapData = null;
         var m:Matrix = null;
         if(sw <= 0 || sh <= 0 || dw <= 0 || dh <= 0)
         {
            return;
         }
         if(sw == dw && sh == dh)
         {
            dst.copyPixels(src,new Rectangle(sx,sy,sw,sh),new Point(dx,dy));
            return;
         }
         tmp = new BitmapData(sw,sh,true,0);
         tmp.copyPixels(src,new Rectangle(sx,sy,sw,sh),new Point(0,0));
         m = new Matrix();
         m.scale(dw / sw,dh / sh);
         m.translate(dx,dy);
         dst.draw(tmp,m,null,null,null,true);
         tmp.dispose();
      }
      
      private function refreshCartuchos() : void
      {
         var visibleIds:Array = [];
         var id:int = 0;
         var start:int = 0;
         var shown:int = 0;
         var y:int = 0;
         var pages:int = 1;
         var col:Object = null;
         var row:Sprite = null;
         var icon:BitmapData = null;
         var label:TextField = null;
         while(_cartuchosList.numChildren > 0)
         {
            _cartuchosList.removeChildAt(0);
         }
         for(id = 1; id <= 72; id++)
         {
            if(_cartuchoVisible[id] && _catalog.getCollection(id) != null)
            {
               visibleIds.push(id);
            }
         }
         pages = Math.max(1,Math.ceil(visibleIds.length / 3));
         if(_cartuchoPage > pages - 1)
         {
            _cartuchoPage = pages - 1;
         }
         start = _cartuchoPage * 3;
         for(shown = 0; shown < 3 && start + shown < visibleIds.length; shown++)
         {
            id = int(visibleIds[start + shown]);
            col = _catalog.getCollection(id);
            row = new Sprite();
            row.y = y;
            row.buttonMode = true;
            row.mouseChildren = false;
            icon = _assets.getBitmap(String(col.gif));
            if(icon != null)
            {
               row.addChild(new Bitmap(icon));
            }
            label = makeLabel(String(col.name),20,0,95,0xffffff);
            label.x = 20;
            label.y = 0;
            row.addChild(label);
            row.addEventListener(MouseEvent.CLICK,cartuchoClickHandler(id));
            _cartuchosList.addChild(row);
            y += 34;
         }
         _pagerLabel.text = (_cartuchoPage + 1) + "/" + pages;
      }
      
      private function cartuchoClickHandler(cartuchoId:int) : Function
      {
         return function(e:MouseEvent):void
         {
            insertCartucho(cartuchoId);
         };
      }
      
      private function countVisibleCartuchos() : int
      {
         var n:int = 0;
         var i:int = 0;
         for(i = 1; i <= 72; i++)
         {
            if(_cartuchoVisible[i])
            {
               n++;
            }
         }
         return n;
      }
      
      private function moveCartuchoPage(dir:int) : void
      {
         var pages:int = Math.max(1,Math.ceil(countVisibleCartuchos() / 3));
         _cartuchoPage += dir;
         if(_cartuchoPage < 0)
         {
            _cartuchoPage = 0;
         }
         if(_cartuchoPage > pages - 1)
         {
            _cartuchoPage = pages - 1;
         }
         refreshCartuchos();
      }
      
      private function insertCartucho(cartuchoId:int) : void
      {
         var slot:int = -1;
         var i:int = 0;
         for(i = 0; i < 4; i++)
         {
            if(_palhetaCartucho[i] == 0)
            {
               slot = i;
               break;
            }
         }
         if(slot < 0)
         {
            setStatus("No empty stylus slot");
            return;
         }
         _palhetaCartucho[slot] = cartuchoId;
         _cartuchoVisible[cartuchoId] = false;
         refreshCartuchos();
         refreshPalhetas();
         var colObj:Object = _catalog.getCollection(cartuchoId);
         setStatus(colObj != null ? "Loaded " + colObj.name : "Loaded cartridge");
      }
      
      private function ejectCartucho(slot:int) : void
      {
         var cartuchoId:int = _palhetaCartucho[slot];
         if(cartuchoId <= 0)
         {
            return;
         }
         clearLayerModules(slot);
         _cartuchoVisible[cartuchoId] = true;
         _palhetaCartucho[slot] = 0;
         refreshCartuchos();
         refreshPalhetas();
         refreshTimeline();
         setStatus("Ejected cartridge");
      }
      
      private function refreshPalhetas() : void
      {
         var i:int = 0;
         var c:int = 0;
         for(i = 0; i < 4; i++)
         {
            var slot:Sprite = _palhetasRoot.getChildByName("palheta_" + i) as Sprite;
            while(slot.numChildren > 1)
            {
               slot.removeChildAt(slot.numChildren - 1);
            }
            var cartuchoId:int = _palhetaCartucho[i];
            var header:Sprite = new Sprite();
            header.y = 0;
            var headerBg:BitmapData = _assets.getBitmap(cartuchoId > 0 ? "palheta-header.png" : "palheta-no-header.png");
            if(headerBg != null)
            {
               header.addChild(new Bitmap(headerBg));
            }
            if(cartuchoId > 0)
            {
               var colObj:Object = _catalog.getCollection(cartuchoId);
               var title:TextField = makeLabel(colObj != null ? String(colObj.name) : ("#" + cartuchoId),0,4,97,0xffffff,TextFormatAlign.CENTER);
               header.addChild(title);
               header.buttonMode = true;
               header.addEventListener(MouseEvent.CLICK,ejectHandler(i));
            }
            slot.addChild(header);
            var piker:Sprite = new Sprite();
            piker.x = 12;
            piker.y = 32;
            var pikerBg:BitmapData = _assets.getBitmap("palheta-piker.png");
            if(pikerBg != null)
            {
               piker.addChild(new Bitmap(pikerBg));
            }
            if(cartuchoId > 0)
            {
               for(c = 1; c <= 9; c++)
               {
                  var mod:Sprite = makeModuleSprite(i + 1,c,"unique");
                  mod.x = 2 + (c - 1) % 3 * 24;
                  mod.y = 2 + int((c - 1) / 3) * 24;
                  mod.buttonMode = true;
                  mod.addEventListener(MouseEvent.MOUSE_DOWN,moduleDragHandler(i + 1,c));
                  mod.addEventListener(MouseEvent.ROLL_OVER,modulePreviewHandler(cartuchoId,c));
                  mod.addEventListener(MouseEvent.ROLL_OUT,function(e:MouseEvent):void
                  {
                     _player.stopPreview();
                  });
                  piker.addChild(mod);
               }
            }
            slot.addChild(piker);
         }
      }
      
      private function ejectHandler(slot:int) : Function
      {
         return function(e:MouseEvent):void
         {
            ejectCartucho(slot);
         };
      }
      
      private function moduleDragHandler(layerColor:int, moduleClass:int) : Function
      {
         return function(e:MouseEvent):void
         {
            e.stopPropagation();
            if(cancelHostDrag != null)
            {
               cancelHostDrag();
            }
            _dragLayer = layerColor;
            _dragClass = moduleClass;
            if(_dragGhost != null && contains(_dragGhost))
            {
               removeChild(_dragGhost);
            }
            _dragGhost = makeModuleSprite(layerColor,moduleClass,"unique");
            _dragGhost.alpha = 0.8;
            _dragGhost.mouseEnabled = false;
            _dragGhost.mouseChildren = false;
            addChild(_dragGhost);
            if(stage != null)
            {
               stage.addEventListener(MouseEvent.MOUSE_MOVE,onDragMove);
               stage.addEventListener(MouseEvent.MOUSE_UP,onDragUp);
            }
            onDragMove(e);
         };
      }
      
      private function modulePreviewHandler(cartuchoId:int, moduleClass:int) : Function
      {
         return function(e:MouseEvent):void
         {
            if(_isPlaying)
            {
               return;
            }
            var songId:int = _catalog.songIdForCollectionClass(cartuchoId,moduleClass);
            if(songId > 0)
            {
               _player.preview(songId);
            }
         };
      }
      
      private function onDragMove(e:MouseEvent) : void
      {
         if(_dragGhost == null)
         {
            return;
         }
         var p:Point = globalToLocal(new Point(e.stageX,e.stageY));
         _dragGhost.x = p.x - 10;
         _dragGhost.y = p.y - 10;
      }
      
      private function onDragUp(e:MouseEvent) : void
      {
         if(stage != null)
         {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,onDragMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP,onDragUp);
         }
         if(_dragGhost != null && contains(_dragGhost))
         {
            removeChild(_dragGhost);
         }
         _dragGhost = null;
         if(e == null || _timelineRoot == null || _layersContainer == null)
         {
            _dragLayer = -1;
            _dragClass = -1;
            return;
         }
         var local:Point = _layersContainer.globalToLocal(new Point(e.stageX,e.stageY));
         var layer:int = int(local.y / LAYER_H);
         var col:int = _origem + int((local.x - TRACK_PAD_X) / CELL_STRIDE);
         if(layer >= 0 && layer < LAYERS && col >= 0 && _dragLayer > 0 && _dragClass > 0)
         {
            placeModule(layer,col,_dragLayer,_dragClass);
         }
         _dragLayer = -1;
         _dragClass = -1;
      }
      
      private function placeModule(layer:int, col:int, color:int, moduleClass:int) : void
      {
         // Song comes from the source piker (color), not the destination layer.
         var cartuchoId:int = color >= 1 && color <= LAYERS ? _palhetaCartucho[color - 1] : 0;
         if(cartuchoId <= 0)
         {
            return;
         }
         var songId:int = _catalog.songIdForCollectionClass(cartuchoId,moduleClass);
         var song:Object = _catalog.getSong(songId);
         if(song == null)
         {
            return;
         }
         var len:int = Math.max(1,Math.ceil(Number(song.length)));
         ensureTimelineLength(col + len + 12);
         var k:int = 0;
         for(k = 0; k < len; k++)
         {
            if(_timeline[layer][col + k] != null)
            {
               setStatus("Not enough free cells");
               return;
            }
         }
         for(k = 0; k < len; k++)
         {
            var cell:TimelineCell = new TimelineCell();
            cell.songId = songId;
            cell.moduleClass = int(song.moduleClass);
            cell.color = color;
            if(len == 1)
            {
               cell.moduleType = "unique";
            }
            else if(k == 0)
            {
               cell.moduleType = "start";
            }
            else if(k == len - 1)
            {
               cell.moduleType = "end";
            }
            else
            {
               cell.moduleType = "middle";
            }
            cell.playSong = k == 0 ? songId : 0;
            _timeline[layer][col + k] = cell;
         }
         refreshTimeline();
         setStatus("Module placed");
      }
      
      private function clearLayerModules(layer:int) : void
      {
         var i:int = 0;
         for(i = 0; i < _timeline[layer].length; i++)
         {
            _timeline[layer][i] = null;
         }
      }
      
      private function ensureTimelineLength(minLen:int) : void
      {
         if(minLen < 24)
         {
            minLen = 24;
         }
         var L:int = 0;
         var i:int = 0;
         for(L = 0; L < LAYERS; L++)
         {
            while(_timeline[L].length < minLen)
            {
               _timeline[L].push(null);
            }
         }
         _timelineLen = minLen;
      }
      
      private function refreshTimeline() : void
      {
         var L:int = 0;
         var c:int = 0;
         var abs:int = 0;
         var cell:TimelineCell = null;
         var track:Sprite = null;
         var mod:Sprite = null;
         for(L = 0; L < LAYERS; L++)
         {
            track = _layerTracks[L];
            while(track.numChildren > 0)
            {
               track.removeChildAt(0);
            }
            for(c = 0; c < VISIBLE_CELLS; c++)
            {
               abs = _origem + c;
               cell = abs < _timeline[L].length ? _timeline[L][abs] : null;
               if(cell == null)
               {
                  continue;
               }
               mod = makeModuleSprite(cell.color,cell.moduleClass,cell.moduleType);
               mod.x = c * CELL_STRIDE + 1;
               mod.y = 0;
               mod.buttonMode = true;
               mod.addEventListener(MouseEvent.CLICK,removeAtHandler(L,abs));
               track.addChild(mod);
            }
         }
         updatePlayheadVisual();
      }
      
      private function removeAtHandler(layer:int, col:int) : Function
      {
         return function(e:MouseEvent):void
         {
            removeModuleAt(layer,col);
         };
      }
      
      private function removeModuleAt(layer:int, col:int) : void
      {
         var cell:TimelineCell = _timeline[layer][col];
         if(cell == null)
         {
            return;
         }
         var start:int = col;
         while(start > 0 && _timeline[layer][start] != null && _timeline[layer][start].moduleType != "start" && _timeline[layer][start].moduleType != "unique")
         {
            start--;
         }
         var i:int = start;
         while(i < _timeline[layer].length && _timeline[layer][i] != null)
         {
            var t:String = _timeline[layer][i].moduleType;
            _timeline[layer][i] = null;
            i++;
            if(t == "end" || t == "unique")
            {
               break;
            }
         }
         refreshTimeline();
      }
      
      private function moveTimeline(dir:int) : void
      {
         _origem += dir;
         if(_origem < 0)
         {
            _origem = 0;
         }
         if(_origem > _timelineLen - VISIBLE_CELLS)
         {
            _origem = Math.max(0,_timelineLen - VISIBLE_CELLS);
         }
         refreshTimeline();
      }
      
      private function onPlayClick(e:MouseEvent) : void
      {
         if(_isPlaying)
         {
            _player.pause();
            _isPlaying = false;
            swapPlayIcon(false);
            setStatus("Paused");
            return;
         }
         _isPlaying = true;
         swapPlayIcon(true);
         _player.playhead = _player.playhead;
         _player.play(onPlayTick);
         setStatus("Playing");
      }
      
      private function onStopClick(e:MouseEvent) : void
      {
         _player.stop();
         _isPlaying = false;
         swapPlayIcon(false);
         updatePlayheadVisual();
         setStatus("Stopped");
      }
      
      private function onClearClick(e:MouseEvent) : void
      {
         var L:int = 0;
         var i:int = 0;
         for(L = 0; L < LAYERS; L++)
         {
            for(i = 0; i < _timeline[L].length; i++)
            {
               _timeline[L][i] = null;
            }
         }
         _player.stop();
         _isPlaying = false;
         swapPlayIcon(false);
         refreshTimeline();
         setStatus("Cleared");
      }
      
      private function swapPlayIcon(toPause:Boolean) : void
      {
         _playAsset = toPause ? "pause.png" : "play.png";
         var meta:Object = _iconButtons[_btnPlay];
         if(meta != null)
         {
            meta.asset = _playAsset;
            paintIconButton(_btnPlay,BTN_NORMAL);
         }
      }
      
      private function onPlayTick(playhead:int) : void
      {
         var L:int = 0;
         var empty:int = 0;
         for(L = 0; L < LAYERS; L++)
         {
            if(playhead >= _timeline[L].length || _timeline[L][playhead] == null)
            {
               empty++;
               continue;
            }
            var cell:TimelineCell = _timeline[L][playhead];
            if(cell.moduleType == "start" || cell.moduleType == "unique")
            {
               _player.triggerLayer(L,cell.playSong > 0 ? cell.playSong : cell.songId,0);
            }
         }
         if(playhead - _origem >= VISIBLE_CELLS - 1)
         {
            moveTimeline(1);
         }
         updatePlayheadVisual();
         if(empty >= LAYERS && playhead > 0)
         {
            var ahead:Boolean = false;
            var a:int = playhead + 1;
            for(L = 0; L < LAYERS; L++)
            {
               for(a = playhead + 1; a < _timeline[L].length; a++)
               {
                  if(_timeline[L][a] != null)
                  {
                     ahead = true;
                     break;
                  }
               }
            }
            if(!ahead)
            {
               onStopClick(null);
               setStatus("Finished");
            }
         }
      }
      
      private function updatePlayheadVisual() : void
      {
         var vis:int = _player.playhead - _origem;
         if(vis < 0)
         {
            vis = 0;
         }
         if(vis > VISIBLE_CELLS - 1)
         {
            vis = VISIBLE_CELLS - 1;
         }
         // Match HTML agulha thumb: 25x117 over the cell column.
         _playheadBar.x = TIMELINE_PAD_X + TRACK_PAD_X + vis * CELL_STRIDE - 1;
         _playheadBar.y = 6;
         if(_playheadHit != null)
         {
            _playheadHit.x = TIMELINE_PAD_X + TRACK_PAD_X + vis * CELL_STRIDE - 3;
            _playheadHit.y = 4;
         }
      }
      
      private function onPlayheadDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(cancelHostDrag != null)
         {
            cancelHostDrag();
         }
         beginPlayheadDrag(e);
      }
      
      private function onTimelineScrubDown(e:MouseEvent) : void
      {
         var t:DisplayObject = e.target as DisplayObject;
         if(t == _playheadHit || t == _playheadBar)
         {
            return;
         }
         // Only scrub when clicking the timeline chrome / empty track, not modules.
         if(e.target is Sprite && (e.target as Sprite).buttonMode)
         {
            return;
         }
         if(cancelHostDrag != null)
         {
            cancelHostDrag();
         }
         beginPlayheadDrag(e);
         scrubPlayheadToMouse(e);
      }
      
      private function beginPlayheadDrag(e:MouseEvent) : void
      {
         _draggingPlayhead = true;
         if(_isPlaying)
         {
            _player.pause();
            _isPlaying = false;
            swapPlayIcon(false);
            setStatus("Paused");
         }
         if(stage != null)
         {
            stage.addEventListener(MouseEvent.MOUSE_MOVE,onPlayheadDragMove);
            stage.addEventListener(MouseEvent.MOUSE_UP,onPlayheadDragUp);
         }
      }
      
      private function onPlayheadDragMove(e:MouseEvent) : void
      {
         if(!_draggingPlayhead)
         {
            return;
         }
         scrubPlayheadToMouse(e);
      }
      
      private function onPlayheadDragUp(e:MouseEvent) : void
      {
         _draggingPlayhead = false;
         if(stage != null)
         {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,onPlayheadDragMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP,onPlayheadDragUp);
         }
      }
      
      private function scrubPlayheadToMouse(e:MouseEvent) : void
      {
         var local:Point = null;
         var vis:int = 0;
         if(_layersContainer == null || e == null)
         {
            return;
         }
         local = _layersContainer.globalToLocal(new Point(e.stageX,e.stageY));
         vis = int((local.x - TRACK_PAD_X + CELL_STRIDE / 2) / CELL_STRIDE);
         if(vis < 0)
         {
            vis = 0;
         }
         if(vis > VISIBLE_CELLS - 1)
         {
            vis = VISIBLE_CELLS - 1;
         }
         _player.playhead = _origem + vis;
         updatePlayheadVisual();
         setStatus("Position " + (_player.playhead + 1));
      }
      
      private function makeModuleSprite(colorIndex:int, moduleClass:int, moduleType:String) : Sprite
      {
         var s:Sprite = new Sprite();
         var sheet:BitmapData = _assets.getBitmap("00008.png");
         var frame:BitmapData = _assets.getBitmap("module.png");
         var unionBd:BitmapData = _assets.getBitmap("union.png");
         var rgb:uint = LAYER_COLORS[(colorIndex >= 1 && colorIndex <= 4 ? colorIndex : 1) - 1];
         var sx:int = 0;
         var slice:BitmapData = null;
         var icon:Bitmap = null;
         var unionBmp:Bitmap = null;
         var face:BitmapData = null;
         var mask:BitmapData = null;
         // Color only the rounded interior (not transparent outer corners of module.png).
         if(frame != null)
         {
            mask = getModuleFaceMask(frame);
            face = new BitmapData(frame.width,frame.height,true,0);
            face.fillRect(face.rect,uint(0xff000000) | rgb);
            face.copyChannel(mask,mask.rect,new Point(0,0),BitmapDataChannel.ALPHA,BitmapDataChannel.ALPHA);
            s.addChild(new Bitmap(face));
            s.addChild(new Bitmap(frame));
         }
         else
         {
            s.graphics.beginFill(rgb,1);
            s.graphics.drawRect(0,0,CELL,CELL);
            s.graphics.endFill();
         }
         if(sheet != null && moduleClass >= 1)
         {
            sx = (moduleClass - 1) * 19;
            if(sx + 19 > sheet.width)
            {
               sx = sheet.width - 19;
            }
            if(sx < 0)
            {
               sx = 0;
            }
            slice = new BitmapData(19,19,true,0);
            slice.copyPixels(sheet,new Rectangle(sx,0,19,19),new Point(0,0));
            icon = new Bitmap(slice);
            icon.x = 1;
            icon.y = 1;
            s.addChild(icon);
         }
         if((moduleType == "middle" || moduleType == "end") && unionBd != null)
         {
            unionBmp = new Bitmap(unionBd);
            unionBmp.x = -2;
            unionBmp.y = 4;
            s.addChild(unionBmp);
            unionBmp.transform.colorTransform = new ColorTransform(((rgb >> 16) & 0xff) / 255,((rgb >> 8) & 0xff) / 255,(rgb & 0xff) / 255,1);
         }
         return s;
      }
      
      private function getModuleFaceMask(frame:BitmapData) : BitmapData
      {
         var w:int = 0;
         var h:int = 0;
         var visited:Vector.<Boolean> = null;
         var queue:Vector.<int> = null;
         var qh:int = 0;
         var qt:int = 0;
         var start:int = 0;
         var x:int = 0;
         var y:int = 0;
         var i:int = 0;
         var nx:int = 0;
         var ny:int = 0;
         var ni:int = 0;
         if(_moduleFaceMask != null)
         {
            return _moduleFaceMask;
         }
         w = frame.width;
         h = frame.height;
         _moduleFaceMask = new BitmapData(w,h,true,0);
         visited = new Vector.<Boolean>(w * h,true);
         queue = new Vector.<int>(w * h,true);
         start = int(h / 2) * w + int(w / 2);
         if((frame.getPixel32(int(w / 2),int(h / 2)) >>> 24) < 128)
         {
            queue[qt++] = start;
            visited[start] = true;
         }
         while(qh < qt)
         {
            i = queue[qh++];
            x = i % w;
            y = int(i / w);
            _moduleFaceMask.setPixel32(x,y,0xffffffff);
            nx = x - 1;
            ny = y;
            ni = ny * w + nx;
            if(nx >= 0 && !visited[ni] && (frame.getPixel32(nx,ny) >>> 24) < 128)
            {
               visited[ni] = true;
               queue[qt++] = ni;
            }
            nx = x + 1;
            ni = ny * w + nx;
            if(nx < w && !visited[ni] && (frame.getPixel32(nx,ny) >>> 24) < 128)
            {
               visited[ni] = true;
               queue[qt++] = ni;
            }
            nx = x;
            ny = y - 1;
            ni = ny * w + nx;
            if(ny >= 0 && !visited[ni] && (frame.getPixel32(nx,ny) >>> 24) < 128)
            {
               visited[ni] = true;
               queue[qt++] = ni;
            }
            ny = y + 1;
            ni = ny * w + nx;
            if(ny < h && !visited[ni] && (frame.getPixel32(nx,ny) >>> 24) < 128)
            {
               visited[ni] = true;
               queue[qt++] = ni;
            }
         }
         return _moduleFaceMask;
      }
      
      private function makeIconButton(assetName:String, x:int, y:int, frameW:int, handler:Function) : Sprite
      {
         var s:Sprite = new Sprite();
         var sheet:BitmapData = _assets.getBitmap(assetName);
         var frameH:int = sheet != null ? sheet.height : 23;
         s.x = x;
         s.y = y;
         s.buttonMode = true;
         s.mouseChildren = false;
         _iconButtons[s] = {
            "asset":assetName,
            "frameW":frameW,
            "frameH":frameH,
            "states":sheet != null ? int(sheet.width / frameW) : 1
         };
         paintIconButton(s,BTN_NORMAL);
         s.addEventListener(MouseEvent.MOUSE_DOWN,onIconButtonDown);
         s.addEventListener(MouseEvent.MOUSE_UP,onIconButtonUp);
         s.addEventListener(MouseEvent.ROLL_OUT,onIconButtonUp);
         s.addEventListener(MouseEvent.CLICK,handler);
         return s;
      }
      
      private function onIconButtonDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(cancelHostDrag != null)
         {
            cancelHostDrag();
         }
         paintIconButton(e.currentTarget as Sprite,BTN_ACTIVE);
      }
      
      private function onIconButtonUp(e:MouseEvent) : void
      {
         paintIconButton(e.currentTarget as Sprite,BTN_NORMAL);
      }
      
      private function paintIconButton(s:Sprite, state:int) : void
      {
         var meta:Object = null;
         var sheet:BitmapData = null;
         var frameW:int = 0;
         var frameH:int = 0;
         var frames:int = 1;
         var useState:int = 0;
         var slice:BitmapData = null;
         if(s == null)
         {
            return;
         }
         meta = _iconButtons[s];
         if(meta == null)
         {
            return;
         }
         while(s.numChildren > 0)
         {
            s.removeChildAt(0);
         }
         sheet = _assets.getBitmap(String(meta.asset));
         frameW = int(meta.frameW);
         frameH = int(meta.frameH);
         frames = Math.max(1,int(meta.states));
         useState = state;
         if(useState >= frames)
         {
            useState = frames - 1;
         }
         if(sheet != null && frameW > 0)
         {
            slice = new BitmapData(frameW,frameH,true,0);
            slice.copyPixels(sheet,new Rectangle(useState * frameW,0,frameW,frameH),new Point(0,0));
            s.addChild(new Bitmap(slice));
         }
         else
         {
            s.graphics.clear();
            s.graphics.beginFill(0x666666);
            s.graphics.drawRect(0,0,frameW > 0 ? frameW : 40,frameH > 0 ? frameH : 20);
            s.graphics.endFill();
         }
      }
      
      private function makeLabel(text:String, x:int, y:int, w:int, color:uint, align:String = "left") : TextField
      {
         var tf:TextField = new TextField();
         var fmt:TextFormat = new TextFormat("Volter",9,color);
         fmt.align = align;
         tf.x = x;
         tf.y = y;
         tf.width = w;
         tf.height = 16;
         tf.selectable = false;
         tf.mouseEnabled = false;
         tf.embedFonts = true;
         tf.antiAliasType = AntiAliasType.NORMAL;
         tf.defaultTextFormat = fmt;
         tf.text = text;
         return tf;
      }
      
      private function setStatus(msg:String) : void
      {
         if(_status != null)
         {
            _status.text = msg;
         }
      }
   }
}
