package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.core.window.components.IDisplayObjectWrapperController;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.ITextWindow;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.avatar.IAvatarRenderManager;
   import com.sulake.habbo.catalog.IHabboCatalog;
   import com.sulake.habbo.localization.IHabboLocalizationManager;
   import com.sulake.habbo.room.IStuffData;
   import com.sulake.habbo.room.preview.RoomPreviewer;
   import com.sulake.habbo.session.ISessionDataManager;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.room.utils.Vector3d;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
   public class BobbaLegacyPriceDialog
   {
      
      private static const PREVIEW_ROOM_ID:int = 7;
      
      private static const PREVIEW_NONE:int = 0;
      
      private static const PREVIEW_AVATAR:int = 1;
      
      private static const PREVIEW_FLOOR:int = 2;
      
      private static const PREVIEW_WALL:int = 3;
      
      private static const CLOTHING_CATEGORY:int = 23;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _window:IFrameController;
      
      private var _classname:String = "";
      
      private var _furniId:int = 0;
      
      private var _furniType:int = 0;
      
      private var _extraData:String = "";
      
      private var _stuffData:Object = null;
      
      private var _previewer:RoomPreviewer = null;
      
      private var _ownsPreviewer:Boolean = false;
      
      private var _previewUpdateTimer:Timer = null;
      
      private var _previewCanvas:IDisplayObjectWrapperController = null;
      
      private var _previewMode:int = 0;
      
      private var _avatarDir:int = 2;
      
      private var _historyDays:int = 30;
      
      private var _iconLoaders:Array;
      
      private var _rowIcon:BitmapData = null;
      
      public function BobbaLegacyPriceDialog(windowManager:HabboWindowManagerComponent)
      {
         super();
         _windowManager = windowManager;
         _iconLoaders = [];
      }
      
      public function dispose() : void
      {
         disposeIconLoaders();
         disposeRowIcon();
         disposePreviewer();
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
      }
      
      public function open(classname:String, title:String, furniId:int, furniType:int, extraData:String, stuffData:Object, icon:BitmapData) : void
      {
         _classname = classname != null ? classname : "";
         _furniId = furniId;
         _furniType = furniType;
         _extraData = extraData != null ? extraData : "";
         _stuffData = stuffData;
         disposeRowIcon();
         if(icon != null)
         {
            try
            {
               if(icon.width > 0 && icon.height > 0)
               {
                  _rowIcon = icon.clone();
               }
            }
            catch(err:Error)
            {
               _rowIcon = null;
            }
         }
         if(_window == null)
         {
            createWindow();
         }
         if(_window == null)
         {
            return;
         }
         setText("item_name",title != null && title.length > 0 ? title : _classname);
         setText("item_last","…");
         setText("item_average","…");
         setText("item_volume","…");
         setText("item_last_label",BobbaI18n.t("prices.stat.current","Current"));
         setText("item_average_label",BobbaI18n.t("prices.stat.average","Average"));
         setText("item_volume_label",BobbaI18n.t("prices.stat.volume","Offers"));
         setText("item_meta",_classname);
         setText("ext_max_price","");
         setText("ext_min_price","");
         setText("ext_max_qty","");
         setText("ext_min_qty","");
         setText("chart_title","");
         setText("credit_prefix",BobbaI18n.t("prices.credit.prefix","powered by "));
         setText("credit_link","securehabbo.com");
         setText("open_sh_page",BobbaI18n.t("prices.open_page","Open page"));
         clearChart();
         _window.caption = BobbaI18n.t("prices.window_title");
         _window.visible = true;
         _window.activate();
         positionNextToShopWindow();
         paintStatBackgrounds();
         updateDayLabels();
         styleCreditLink();
         loadStatIcons();
         showFurniPreview();
         requestPrice();
      }
      
      public function onBobbaLegacyPrice(data:Object) : void
      {
         if(_window == null || !_window.visible)
         {
            return;
         }
         if(data == null)
         {
            showUnavailable();
            return;
         }
         if(_classname.length > 0 && data.classname != null && String(data.classname).length > 0 && String(data.classname) != _classname)
         {
            return;
         }
         if(!Boolean(data.success))
         {
            showUnavailable();
            return;
         }
         fillResult(data);
      }
      
      private function requestPrice() : void
      {
         var backend:* = null;
         if(_windowManager == null || _classname.length == 0)
         {
            showUnavailable();
            return;
         }
         backend = _windowManager.bobbaBackend;
         if(backend == null || !backend.isConnected)
         {
            showUnavailable();
            return;
         }
         backend.requestLegacyPrice(_classname,_historyDays,true,this);
      }
      
      private function showUnavailable() : void
      {
         setText("item_last","—");
         setText("item_average","—");
         setText("item_volume","—");
         setText("item_meta",BobbaI18n.t("prices.unavailable"));
         setText("ext_max_price",BobbaI18n.t("prices.range.max_price","Max price") + "  —");
         setText("ext_min_price",BobbaI18n.t("prices.range.min_price","Min price") + "  —");
         setText("ext_max_qty",BobbaI18n.t("prices.range.max_qty","Max quantity") + "  —");
         setText("ext_min_qty",BobbaI18n.t("prices.range.min_qty","Min quantity") + "  —");
         setText("chart_title","");
         clearChart();
      }
      
      private function fillResult(data:Object) : void
      {
         var loc:IHabboLocalizationManager = null;
         var lastPrice:int = 0;
         var average:int = 0;
         var quantity:int = 0;
         var meta:String = "";
         loc = _windowManager != null ? _windowManager.localization : null;
         lastPrice = int(data.lastPrice);
         average = int(data.lastAverage);
         quantity = int(data.lastQuantity);
         if(lastPrice > 0)
         {
            setText("item_last",lastPrice.toString());
         }
         else
         {
            setText("item_last","—");
         }
         if(average > 0)
         {
            setText("item_average",average.toString());
         }
         else
         {
            setText("item_average","—");
         }
         if(quantity > 0)
         {
            setText("item_volume",quantity.toString());
         }
         else
         {
            setText("item_volume","—");
         }
         if(data.category != null && String(data.category).length > 0)
         {
            meta = String(data.category);
         }
         setText("item_meta",meta);
         drawHistory(data,loc);
         fillExtremes(data);
      }
      
      private function fillExtremes(data:Object) : void
      {
         var prices:Array = copyHistory(data);
         var qtys:Array = copyQuantities(data);
         var maxPrice:int = 0;
         var minPrice:int = 0;
         var maxQty:int = 0;
         var minQty:int = 0;
         var hasPrice:Boolean = false;
         var hasQty:Boolean = false;
         var i:int = 0;
         var value:int = 0;
         for(i = 0; i < prices.length; i++)
         {
            value = int(prices[i]);
            if(value > 0)
            {
               if(!hasPrice || value > maxPrice)
               {
                  maxPrice = value;
               }
               if(!hasPrice || value < minPrice)
               {
                  minPrice = value;
               }
               hasPrice = true;
            }
         }
         for(i = 0; i < qtys.length; i++)
         {
            value = int(qtys[i]);
            if(!hasQty || value > maxQty)
            {
               maxQty = value;
            }
            if(!hasQty || value < minQty)
            {
               minQty = value;
            }
            hasQty = true;
         }
         setExtreme("ext_max_price","prices.range.max_price","Max price",hasPrice ? maxPrice : -1);
         setExtreme("ext_min_price","prices.range.min_price","Min price",hasPrice ? minPrice : -1);
         setExtreme("ext_max_qty","prices.range.max_qty","Max quantity",hasQty ? maxQty : -1);
         setExtreme("ext_min_qty","prices.range.min_qty","Min quantity",hasQty ? minQty : -1);
      }
      
      private function setExtreme(name:String, key:String, fallback:String, value:int) : void
      {
         var label:String = BobbaI18n.t(key,fallback);
         if(value < 0)
         {
            setText(name,label + "  —");
         }
         else
         {
            setText(name,label + "  " + value.toString());
         }
      }
      
      private function drawHistory(data:Object, loc:IHabboLocalizationManager) : void
      {
         var prices:Array = copyHistory(data);
         var bitmap:IBitmapWrapperController = null;
         var drawn:BitmapData = null;
         if(prices.length < 2)
         {
            setText("chart_title",formatLoc(loc,"catalog.marketplace.offer_details.chart_title.not_available",null,null,null,null));
            clearChart();
            return;
         }
         bitmap = _window.findChildByName("chart_bitmap") as IBitmapWrapperController;
         if(bitmap != null)
         {
            bitmap.bitmap = new BitmapData(Math.max(1,bitmap.width),Math.max(1,bitmap.height),true,0);
            drawn = drawPriceChart(prices,_historyDays,Math.max(1,bitmap.width),Math.max(1,bitmap.height));
            bitmap.bitmap.draw(drawn);
            drawn.dispose();
         }
         setText("chart_title",formatLoc(loc,"catalog.marketplace.offer_details.chart_title.price_development","%days%",_historyDays.toString(),null,null));
      }
      
      private function drawPriceChart(prices:Array, days:int, width:int, height:int) : BitmapData
      {
         var canvas:BitmapData = new BitmapData(width,height,true,0);
         var maxPrice:int = 0;
         var i:int = 0;
         var labelW:int = 0;
         var chartW:int = 0;
         var chartH:int = 0;
         var step:Number = 0;
         var gx:Number = 0;
         var gy:Number = 0;
         var tick:int = 0;
         var dayValue:int = 0;
         var label:String = "";
         var tf:TextField = new TextField();
         var fmt:TextFormat = new TextFormat();
         var grid:Shape = new Shape();
         var line:Shape = new Shape();
         var span:int = days > 0 ? days : 30;
         if(prices == null || prices.length < 2 || width < 16 || height < 16)
         {
            return canvas;
         }
         for(i = 0; i < prices.length; i++)
         {
            if(int(prices[i]) > maxPrice)
            {
               maxPrice = int(prices[i]);
            }
         }
         if(maxPrice <= 0)
         {
            maxPrice = 1;
         }
         step = Math.pow(10,maxPrice.toString().length - 1);
         maxPrice = int(Math.ceil(maxPrice / step) * step);
         fmt.font = "Volter";
         fmt.size = 9;
         fmt.color = 6710886;
         tf.embedFonts = true;
         tf.defaultTextFormat = fmt;
         tf.autoSize = "left";
         tf.text = maxPrice.toString();
         canvas.draw(tf);
         labelW = int(tf.textWidth + 6);
         if(labelW < 18)
         {
            labelW = 18;
         }
         chartW = width - labelW - 4;
         chartH = height - 16;
         if(chartW < 8 || chartH < 8)
         {
            return canvas;
         }
         tf.text = "0";
         canvas.draw(tf,new Matrix(1,0,0,1,labelW - tf.textWidth - 4,chartH - tf.textHeight));
         grid.graphics.lineStyle(1,13421772);
         grid.graphics.moveTo(0,0);
         grid.graphics.lineTo(0,chartH);
         i = 0;
         while(i <= 4)
         {
            gy = chartH * i / 4;
            grid.graphics.moveTo(0,gy);
            grid.graphics.lineTo(chartW - 1,gy);
            i++;
         }
         canvas.draw(grid,new Matrix(1,0,0,1,labelW,0));
         line.graphics.lineStyle(2,255);
         for(i = 0; i < prices.length; i++)
         {
            gx = chartW * i / (prices.length - 1);
            gy = chartH - chartH * int(prices[i]) / maxPrice;
            if(i == 0)
            {
               line.graphics.moveTo(gx,gy);
            }
            else
            {
               line.graphics.lineTo(gx,gy);
            }
         }
         canvas.draw(line,new Matrix(1,0,0,1,labelW,0));
         i = 0;
         while(i <= 3)
         {
            tick = i;
            dayValue = int(Math.round(-span * (3 - tick) / 3));
            gx = labelW + chartW * tick / 3;
            if(dayValue == 0)
            {
               label = "0";
            }
            else
            {
               label = dayValue.toString() + "d";
            }
            tf.text = label;
            canvas.draw(tf,new Matrix(1,0,0,1,gx - tf.textWidth / 2,chartH + 1));
            i++;
         }
         return canvas;
      }
      
      private function copyHistory(data:Object) : Array
      {
         var src:* = undefined;
         var out:Array = [];
         var i:int = 0;
         var len:int = 0;
         if(data == null)
         {
            return out;
         }
         src = data.historyPrices;
         if(src == null || src.length == 0)
         {
            src = data.historyAverages;
         }
         if(src == null)
         {
            return out;
         }
         len = int(src.length);
         for(i = 0; i < len; i++)
         {
            out.push(int(src[i]));
         }
         return out;
      }
      
      private function copyQuantities(data:Object) : Array
      {
         var src:* = undefined;
         var out:Array = [];
         var i:int = 0;
         var len:int = 0;
         if(data == null)
         {
            return out;
         }
         src = data.historyQuantities;
         if(src == null)
         {
            return out;
         }
         len = int(src.length);
         for(i = 0; i < len; i++)
         {
            out.push(int(src[i]));
         }
         return out;
      }
      
      private function clearChart() : void
      {
         var bitmap:IBitmapWrapperController = null;
         if(_window == null)
         {
            return;
         }
         bitmap = _window.findChildByName("chart_bitmap") as IBitmapWrapperController;
         if(bitmap != null)
         {
            bitmap.bitmap = new BitmapData(Math.max(1,bitmap.width),Math.max(1,bitmap.height),true,0);
         }
      }
      
      private function showFurniPreview() : void
      {
         var catalog:IHabboCatalog = null;
         var catalogObj:* = undefined;
         var roomEngine:* = undefined;
         var furniData:IFurnitureData = null;
         var productType:String = "";
         var canvas:DisplayObject = null;
         var image:* = undefined;
         _previewMode = PREVIEW_NONE;
         if(_window == null || _windowManager == null || _furniId <= 0)
         {
            showFallbackImage(null);
            showFurniIcon(null);
            return;
         }
         catalog = _windowManager.catalog;
         catalogObj = catalog as Object;
         if(catalogObj == null)
         {
            showFallbackImage(null);
            showFurniIcon(null);
            return;
         }
         try
         {
            roomEngine = catalogObj.roomEngine;
         }
         catch(err:Error)
         {
            roomEngine = null;
         }
         productType = _furniType == 2 ? "i" : "s";
         furniData = catalog.getFurnitureData(_furniId,productType);
         if(ensurePreviewer(roomEngine) && bindPreviewCanvas())
         {
            if(showInRoomPreviewer(furniData,roomEngine))
            {
               setPreviewVisible(true);
               showFurniIcon(roomEngine);
               return;
            }
         }
         image = renderFurniBitmap(roomEngine,64);
         showFallbackImage(image);
         showFurniIcon(roomEngine);
      }
      
      private function ensurePreviewer(roomEngine:*) : Boolean
      {
         var catalog:* = undefined;
         var catalogPreviewer:RoomPreviewer = null;
         if(roomEngine == null)
         {
            return false;
         }
         try
         {
            if(!Boolean(roomEngine.isInitialized))
            {
               return false;
            }
            if(_previewer == null)
            {
               try
               {
                  catalog = _windowManager != null ? _windowManager.catalog : null;
                  if(catalog != null)
                  {
                     catalogPreviewer = catalog.roomPreviewer as RoomPreviewer;
                  }
               }
               catch(errCatalog:Error)
               {
                  catalogPreviewer = null;
               }
               if(catalogPreviewer != null)
               {
                  _previewer = catalogPreviewer;
                  _ownsPreviewer = false;
               }
               else
               {
                  _previewer = new RoomPreviewer(roomEngine,PREVIEW_ROOM_ID);
                  _ownsPreviewer = true;
                  _previewer.createRoomForPreviews();
               }
               _previewer.centerWallItems = true;
               _previewer.addViewOffset = new Point(0,0);
               _previewer.disableUpdate = false;
            }
            preparePreviewRoom();
            return _previewer.isRoomEngineReady;
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] previewer init failed",err.message);
         }
         return false;
      }
      
      private function preparePreviewRoom() : void
      {
         if(_previewer == null)
         {
            return;
         }
         try
         {
            _previewer.updateObjectRoom("110","99999");
            _previewer.updateRoomWallsAndFloorVisibility(true,true);
            _previewer.disableUpdate = false;
         }
         catch(err:Error)
         {
         }
      }
      
      private function bindPreviewCanvas() : Boolean
      {
         var canvas:DisplayObject = null;
         var width:int = 0;
         var height:int = 0;
         if(_window == null || _previewer == null)
         {
            return false;
         }
         _previewCanvas = _window.findChildByName("item_preview") as IDisplayObjectWrapperController;
         if(_previewCanvas == null)
         {
            return false;
         }
         try
         {
            width = Math.max(1,_previewCanvas.width);
            height = Math.max(1,_previewCanvas.height);
            canvas = _previewer.getRoomCanvas(width,height);
            if(canvas == null)
            {
               return false;
            }
            _previewer.modifyRoomCanvas(width,height);
            _previewCanvas.setDisplayObject(canvas);
            _previewCanvas.visible = true;
            _previewer.updatePreviewRoomView(true);
            return true;
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] preview canvas failed",err.message);
         }
         return false;
      }
      
      private function showInRoomPreviewer(furniData:IFurnitureData, roomEngine:*) : Boolean
      {
         var figure:String = "";
         var extra:String = _extraData;
         var direction:Vector3d = new Vector3d(90,0,0);
         var stuff:IStuffData = _stuffData as IStuffData;
         if(_previewer == null)
         {
            return false;
         }
         try
         {
            preparePreviewRoom();
            _previewer.reset(false);
            if(furniData != null && furniData.category == CLOTHING_CATEGORY)
            {
               figure = buildClothingFigure(furniData);
               if(figure != null && figure.length > 0)
               {
                  _previewer.addAvatarIntoRoom(figure,0);
                  _avatarDir = 2;
                  _previewer.updateAvatarDirectionAndLocation(_avatarDir,_avatarDir,null);
                  finishPreviewPlacement(PREVIEW_AVATAR);
                  return true;
               }
            }
            if(_furniType == 2)
            {
               _previewer.addWallItemIntoRoom(_furniId,direction,extra);
               finishPreviewPlacement(PREVIEW_WALL);
               return true;
            }
            _previewer.addFurnitureIntoRoom(_furniId,direction,stuff,extra);
            finishPreviewPlacement(PREVIEW_FLOOR);
            return true;
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] preview add failed",err.message);
            _previewMode = PREVIEW_NONE;
         }
         return false;
      }
      
      private function finishPreviewPlacement(mode:int) : void
      {
         _previewMode = mode;
         if(_previewer == null)
         {
            return;
         }
         try
         {
            _previewer.updateRoomWallsAndFloorVisibility(true,true);
            _previewer.updatePreviewRoomView(true);
            _previewer.updateRoomEngine();
         }
         catch(err:Error)
         {
         }
         startOwnedPreviewUpdates();
      }
      
      private function startOwnedPreviewUpdates() : void
      {
         if(!_ownsPreviewer)
         {
            return;
         }
         if(_previewUpdateTimer == null)
         {
            _previewUpdateTimer = new Timer(50);
            _previewUpdateTimer.addEventListener(TimerEvent.TIMER,onPreviewUpdateTimer);
         }
         if(!_previewUpdateTimer.running)
         {
            _previewUpdateTimer.start();
         }
      }
      
      private function stopOwnedPreviewUpdates() : void
      {
         if(_previewUpdateTimer != null)
         {
            _previewUpdateTimer.stop();
            _previewUpdateTimer.removeEventListener(TimerEvent.TIMER,onPreviewUpdateTimer);
            _previewUpdateTimer = null;
         }
      }
      
      private function onPreviewUpdateTimer(event:TimerEvent) : void
      {
         if(_previewer == null || _previewMode == PREVIEW_NONE)
         {
            return;
         }
         try
         {
            _previewer.updatePreviewRoomView();
         }
         catch(err:Error)
         {
         }
      }
      
      private function buildClothingFigure(furniData:IFurnitureData) : String
      {
         var session:ISessionDataManager = null;
         var renderer:IAvatarRenderManager = null;
         var ids:Vector.<int> = null;
         var parts:Array = null;
         var i:int = 0;
         var setId:int = 0;
         var figure:String = "";
         var gender:String = "";
         var raw:String = "";
         if(_windowManager == null || furniData == null)
         {
            return "";
         }
         session = _windowManager.sessionDataManager;
         renderer = _windowManager.avatarRenderer;
         if(session == null || renderer == null)
         {
            return "";
         }
         figure = session.figure;
         gender = session.gender;
         raw = furniData.customParams;
         if(raw == null || raw.length == 0)
         {
            return "";
         }
         ids = new Vector.<int>();
         parts = raw.split(",");
         for(i = 0; i < parts.length; i++)
         {
            setId = int(parseInt(String(parts[i])));
            if(setId > 0 && renderer.isValidFigureSetForGender(setId,gender))
            {
               ids.push(setId);
            }
         }
         if(ids.length == 0)
         {
            return "";
         }
         try
         {
            return renderer.getFigureStringWithFigureIds(figure,gender,ids);
         }
         catch(err:Error)
         {
         }
         return "";
      }
      
      private function renderFurniBitmap(roomEngine:*, scale:int) : BitmapData
      {
         var result:* = undefined;
         var direction:Vector3d = new Vector3d(90,0,0);
         if(roomEngine == null || _furniId <= 0)
         {
            return null;
         }
         if(scale <= 0)
         {
            scale = 1;
         }
         try
         {
            if(_furniType == 2)
            {
               result = roomEngine.getWallItemImage(_furniId,direction,scale,null,0,_extraData);
            }
            else
            {
               result = roomEngine.getFurnitureImage(_furniId,direction,scale,null,0,_extraData,-1,-1,_stuffData);
            }
            if(result != null && result.data != null)
            {
               return result.data as BitmapData;
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] furni image failed",err.message);
         }
         return null;
      }
      
      private function showFurniIcon(roomEngine:*) : void
      {
         var box:IWindowModel = null;
         var icon:BitmapData = null;
         if(_rowIcon != null)
         {
            icon = _rowIcon;
         }
         else
         {
            icon = renderFurniIcon(roomEngine);
         }
         applyNamedBitmap("item_icon",icon,48,48,false);
         if(_window == null)
         {
            return;
         }
         box = _window.findChildByName("item_icon_box");
         if(box != null)
         {
            box.visible = true;
         }
      }
      
      private function renderFurniIcon(roomEngine:*) : BitmapData
      {
         var result:* = undefined;
         if(roomEngine == null || _furniId <= 0)
         {
            return null;
         }
         try
         {
            if(_furniType == 2)
            {
               result = roomEngine.getWallItemIcon(_furniId,null,_extraData);
            }
            else
            {
               result = roomEngine.getFurnitureIcon(_furniId,null);
            }
            if(result != null && result.data != null)
            {
               return result.data as BitmapData;
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] furni icon failed",err.message);
         }
         return null;
      }
      
      private function disposeRowIcon() : void
      {
         if(_rowIcon != null)
         {
            try
            {
               _rowIcon.dispose();
            }
            catch(err:Error)
            {
            }
            _rowIcon = null;
         }
      }
      
      private function showFallbackImage(image:BitmapData) : void
      {
         var wrapper:IBitmapWrapperController = null;
         var canvas:BitmapData = null;
         var width:int = 0;
         var height:int = 0;
         var dx:int = 0;
         var dy:int = 0;
         setPreviewVisible(false);
         if(_window == null)
         {
            return;
         }
         wrapper = _window.findChildByName("item_image") as IBitmapWrapperController;
         if(wrapper == null)
         {
            return;
         }
         width = wrapper.width > 0 ? int(wrapper.width) : 328;
         height = wrapper.height > 0 ? int(wrapper.height) : 140;
         canvas = new BitmapData(width,height,true,0);
         if(image != null && image.width > 0 && image.height > 0)
         {
            dx = int((width - image.width) / 2);
            dy = int((height - image.height) / 2);
            canvas.copyPixels(image,image.rect,new Point(dx,dy),null,null,true);
         }
         wrapper.bitmap = canvas;
         wrapper.visible = true;
      }
      
      private function setPreviewVisible(live:Boolean) : void
      {
         var wrapper:IBitmapWrapperController = null;
         if(_window == null)
         {
            return;
         }
         if(_previewCanvas == null)
         {
            _previewCanvas = _window.findChildByName("item_preview") as IDisplayObjectWrapperController;
         }
         if(_previewCanvas != null)
         {
            _previewCanvas.visible = live;
         }
         wrapper = _window.findChildByName("item_image") as IBitmapWrapperController;
         if(wrapper != null)
         {
            wrapper.visible = !live;
         }
      }
      
      private function rotatePreview() : void
      {
         if(_previewer == null || _previewMode == PREVIEW_NONE)
         {
            return;
         }
         try
         {
            if(_previewMode == PREVIEW_FLOOR)
            {
               _previewer.rotatePreviewFurniture(true);
            }
            else if(_previewMode == PREVIEW_WALL)
            {
               _previewer.rotatePreviewWallItem();
            }
            else if(_previewMode == PREVIEW_AVATAR)
            {
               _avatarDir = (_avatarDir + 2) % 8;
               _previewer.updateAvatarDirectionAndLocation(_avatarDir,_avatarDir,null);
               _previewer.updatePreviewRoomView(true);
               _previewer.updateRoomEngine();
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function disposePreviewer() : void
      {
         stopOwnedPreviewUpdates();
         if(_previewer != null)
         {
            try
            {
               _previewer.reset(true);
               if(_ownsPreviewer)
               {
                  _previewer.dispose();
               }
               else
               {
                  _previewer.disableUpdate = true;
               }
            }
            catch(err:Error)
            {
            }
            _previewer = null;
         }
         _ownsPreviewer = false;
         _previewCanvas = null;
         _previewMode = PREVIEW_NONE;
      }
      
      private function paintStatBackgrounds() : void
      {
         var fill:uint = getAccentFill();
         fillNamedBitmap("stat_last_bg",106,74,fill);
         fillNamedBitmap("stat_avg_bg",106,74,fill);
         fillNamedBitmap("stat_vol_bg",106,74,fill);
      }
      
      private function getAccentColor() : uint
      {
         var color:uint = 0;
         var customs:* = undefined;
         if(_window != null)
         {
            color = uint(_window.color) & 16777215;
         }
         if(color == 0 || color == 16777215)
         {
            try
            {
               if(_windowManager != null)
               {
                  customs = _windowManager.LilithCustomsInstance;
                  if(customs != null)
                  {
                     color = uint(customs.TitleBarColor) & 16777215;
                  }
               }
            }
            catch(err:Error)
            {
               color = 0;
            }
         }
         if(color == 0)
         {
            color = 2266112;
         }
         return color;
      }
      
      private function getAccentFill() : uint
      {
         return uint(51) << 24 | getAccentColor();
      }
      
      private function fillNamedBitmap(name:String, width:int, height:int, fill:uint) : void
      {
         var wrapper:IBitmapWrapperController = null;
         if(_window == null)
         {
            return;
         }
         wrapper = _window.findChildByName(name) as IBitmapWrapperController;
         if(wrapper == null)
         {
            return;
         }
         wrapper.bitmap = new BitmapData(width,height,true,fill);
         wrapper.visible = true;
      }
      
      private function styleStatTexts() : void
      {
         styleStatText("item_last",true);
         styleStatText("item_average",true);
         styleStatText("item_volume",true);
         styleStatText("item_last_label",false);
         styleStatText("item_average_label",false);
         styleStatText("item_volume_label",false);
      }
      
      private function styleStatText(name:String, bold:Boolean) : void
      {
         var textWin:ITextWindow = null;
         var fmt:TextFormat = null;
         if(_window == null)
         {
            return;
         }
         textWin = _window.findChildByName(name) as ITextWindow;
         if(textWin == null)
         {
            return;
         }
         fmt = textWin.defaultTextFormat;
         if(fmt == null)
         {
            fmt = new TextFormat();
         }
         fmt.align = "center";
         fmt.bold = bold;
         textWin.defaultTextFormat = fmt;
         textWin.setTextFormat(fmt);
      }
      
      private function loadStatIcons() : void
      {
         if(_iconLoaders != null && _iconLoaders.length > 0)
         {
            return;
         }
         _iconLoaders = [];
         loadStatIcon("stat_last_icon","prices/money_bands.png");
         loadStatIcon("stat_avg_icon","prices/duck_coins.png");
         loadStatIcon("stat_vol_icon","prices/lightning_icon.png");
      }
      
      private function loadStatIcon(targetName:String, path:String) : void
      {
         var loader:Loader = null;
         var url:String = null;
         try
         {
            url = BobbaPack.resolveUrl(path);
            if(url == null || url.length == 0)
            {
               return;
            }
            loader = new Loader();
            loader.name = targetName;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onStatIconLoaded);
            loader.contentLoaderInfo.addEventListener("ioError",onStatIconError);
            loader.load(new URLRequest(url));
            _iconLoaders.push(loader);
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] icon load failed",err.message);
         }
      }
      
      private function onStatIconLoaded(e:Event) : void
      {
         var info:LoaderInfo = null;
         var loader:Loader = null;
         var bmp:Bitmap = null;
         try
         {
            info = e.target as LoaderInfo;
            if(info == null)
            {
               return;
            }
            loader = info.loader;
            bmp = info.content as Bitmap;
            if(loader == null || bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            applyNamedBitmap(loader.name,bmp.bitmapData,32,32,false);
         }
         catch(err:Error)
         {
         }
      }
      
      private function onStatIconError(e:Event) : void
      {
      }
      
      private function applyNamedBitmap(name:String, src:BitmapData, width:int, height:int, knockout:Boolean) : void
      {
         var wrapper:IBitmapWrapperController = null;
         var canvas:BitmapData = null;
         var work:BitmapData = null;
         var scale:Number = 1;
         var dw:int = 0;
         var dh:int = 0;
         var matrix:Matrix = null;
         if(_window == null || name == null || name.length == 0)
         {
            return;
         }
         wrapper = _window.findChildByName(name) as IBitmapWrapperController;
         if(wrapper == null)
         {
            return;
         }
         canvas = new BitmapData(width,height,true,knockout ? getAccentFill() : 0);
         if(src != null && src.width > 0 && src.height > 0)
         {
            work = src;
            if(knockout)
            {
               work = src.clone();
               work.threshold(work,work.rect,new Point(0,0),"==",uint(0xFF000000),0);
            }
            if(work.width > width || work.height > height)
            {
               scale = Math.min(width / work.width,height / work.height);
            }
            dw = int(work.width * scale);
            dh = int(work.height * scale);
            matrix = new Matrix();
            matrix.scale(scale,scale);
            matrix.translate(int((width - dw) / 2),int((height - dh) / 2));
            canvas.draw(work,matrix,null,null,null,true);
            if(knockout && work != src)
            {
               work.dispose();
            }
         }
         wrapper.bitmap = canvas;
         wrapper.visible = true;
      }
      
      private function disposeIconLoaders() : void
      {
         var i:int = 0;
         var loader:Loader = null;
         if(_iconLoaders == null)
         {
            return;
         }
         for(i = 0; i < _iconLoaders.length; i++)
         {
            loader = _iconLoaders[i] as Loader;
            if(loader == null)
            {
               continue;
            }
            try
            {
               loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onStatIconLoaded);
               loader.contentLoaderInfo.removeEventListener("ioError",onStatIconError);
            }
            catch(err:Error)
            {
            }
         }
         _iconLoaders = [];
      }
      
      private function setText(name:String, value:String) : void
      {
         var win:IWindowModel = null;
         var textWin:ITextWindow = null;
         if(_window == null)
         {
            return;
         }
         win = _window.findChildByName(name);
         if(win == null)
         {
            return;
         }
         if(value == null)
         {
            value = "";
         }
         textWin = win as ITextWindow;
         if(textWin != null)
         {
            textWin.text = value;
         }
         else
         {
            win.caption = value;
         }
         win.visible = value.length > 0 || name == "item_name" || name == "item_last" || name == "item_average" || name == "item_volume" || name == "item_last_label" || name == "item_average_label" || name == "item_volume_label" || name == "item_icon" || name == "ext_max_price" || name == "ext_min_price" || name == "ext_max_qty" || name == "ext_min_qty" || name == "credit_prefix" || name == "credit_link";
      }
      
      private function formatLoc(loc:IHabboLocalizationManager, key:String, token1:String, value1:String, token2:String, value2:String) : String
      {
         var raw:* = undefined;
         var text:String = "";
         if(loc == null || key == null)
         {
            return value1 != null ? value1 : "";
         }
         raw = loc.getLocalizationRaw(key);
         if(raw != null && raw.raw != null)
         {
            text = String(raw.raw);
         }
         else
         {
            text = loc.getLocalization(key,"");
         }
         if(text == null)
         {
            text = "";
         }
         if(token1 != null && value1 != null)
         {
            text = text.replace(token1,value1);
         }
         if(token2 != null && value2 != null)
         {
            text = text.replace(token2,value2);
         }
         return text;
      }
      
      private function positionNextToShopWindow() : void
      {
         var catalog:* = null;
         var shop:IWindowModel = null;
         var desktop:IWindowModel = null;
         if(_window == null || _windowManager == null)
         {
            return;
         }
         try
         {
            catalog = _windowManager.catalog;
            if(catalog != null && catalog.mainContainer != null)
            {
               shop = catalog.mainContainer as IWindowModel;
            }
            if(shop != null && shop.visible)
            {
               _window.x = int(shop.x + shop.width);
               _window.y = int(shop.y);
               desktop = _window.desktop;
               if(desktop != null)
               {
                  if(_window.x + _window.width > desktop.width)
                  {
                     _window.x = Math.max(0,int(shop.x - _window.width));
                  }
                  if(_window.y + _window.height > desktop.height)
                  {
                     _window.y = Math.max(0,desktop.height - _window.height);
                  }
               }
               return;
            }
         }
         catch(err:Error)
         {
         }
         _window.center();
      }
      
      private function createWindow() : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         try
         {
            layout = <layout name="bobba_legacy_price" width="340" height="534" version="0.1">
					<window>
						<frame x="0" y="0" width="340" height="534" params="33025" style="3" name="bobba_sh_frame" caption="SecureHabbo">
							<children>
								<bitmap x="1" y="3" width="337" height="148" params="16" style="0" name="item_image"/>
								<display_object_wrapper x="1" y="3" width="337" height="148" params="16" style="0" name="item_preview"/>
								<border x="6" y="152" width="52" height="52" params="16" style="3" name="item_icon_box">
									<children>
										<bitmap x="2" y="2" width="48" height="48" params="16" style="0" name="item_icon"/>
									</children>
								</border>
								<text x="64" y="158" width="160" height="18" params="16" style="3" name="item_name">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_bold" type="String"/>
									</variables>
								</text>
								<text x="64" y="178" width="160" height="16" params="16" style="3" name="item_meta">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<button x="228" y="162" width="106" height="28" params="17" style="3" name="open_sh_page" caption="Open page"/>
								<border x="6" y="210" width="106" height="74" params="16" style="3" name="stat_last_box">
									<children>
										<bitmap x="0" y="0" width="106" height="74" params="16" style="0" name="stat_last_bg"/>
										<bitmap x="37" y="4" width="32" height="32" params="16" style="0" name="stat_last_icon"/>
										<text x="4" y="36" width="98" height="18" params="16" style="3" name="item_last">
											<variables>
												<var key="auto_size" value="none" type="String"/>
												<var key="text_style" value="u_bold" type="String"/>
											</variables>
										</text>
										<text x="4" y="54" width="98" height="16" params="16" style="3" name="item_last_label">
											<variables>
												<var key="auto_size" value="none" type="String"/>
												<var key="text_style" value="u_small" type="String"/>
											</variables>
										</text>
									</children>
								</border>
								<border x="117" y="210" width="106" height="74" params="16" style="3" name="stat_avg_box">
									<children>
										<bitmap x="0" y="0" width="106" height="74" params="16" style="0" name="stat_avg_bg"/>
										<bitmap x="37" y="4" width="32" height="32" params="16" style="0" name="stat_avg_icon"/>
										<text x="4" y="36" width="98" height="18" params="16" style="3" name="item_average">
											<variables>
												<var key="auto_size" value="none" type="String"/>
												<var key="text_style" value="u_bold" type="String"/>
											</variables>
										</text>
										<text x="4" y="54" width="98" height="16" params="16" style="3" name="item_average_label">
											<variables>
												<var key="auto_size" value="none" type="String"/>
												<var key="text_style" value="u_small" type="String"/>
											</variables>
										</text>
									</children>
								</border>
								<border x="228" y="210" width="106" height="74" params="16" style="3" name="stat_vol_box">
									<children>
										<bitmap x="0" y="0" width="106" height="74" params="16" style="0" name="stat_vol_bg"/>
										<bitmap x="37" y="4" width="32" height="32" params="16" style="0" name="stat_vol_icon"/>
										<text x="4" y="36" width="98" height="18" params="16" style="3" name="item_volume">
											<variables>
												<var key="auto_size" value="none" type="String"/>
												<var key="text_style" value="u_bold" type="String"/>
											</variables>
										</text>
										<text x="4" y="54" width="98" height="16" params="16" style="3" name="item_volume_label">
											<variables>
												<var key="auto_size" value="none" type="String"/>
												<var key="text_style" value="u_small" type="String"/>
											</variables>
										</text>
									</children>
								</border>
								<text x="8" y="290" width="220" height="16" params="16" style="3" name="chart_title">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="230" y="290" width="20" height="16" params="16" style="3" name="days_txt_30" caption="30">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="250" y="290" width="8" height="16" params="16" style="3" name="days_sep_1" caption="-">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="258" y="290" width="20" height="16" params="16" style="3" name="days_txt_90" caption="90">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="278" y="290" width="8" height="16" params="16" style="3" name="days_sep_2" caption="-">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="286" y="290" width="24" height="16" params="16" style="3" name="days_txt_180" caption="180">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="310" y="290" width="8" height="16" params="16" style="3" name="days_sep_3" caption="-">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="318" y="290" width="24" height="16" params="16" style="3" name="days_txt_365" caption="365">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<bitmap x="230" y="288" width="20" height="18" params="17" style="0" name="days_30"/>
								<bitmap x="258" y="288" width="20" height="18" params="17" style="0" name="days_90"/>
								<bitmap x="286" y="288" width="24" height="18" params="17" style="0" name="days_180"/>
								<bitmap x="318" y="288" width="24" height="18" params="17" style="0" name="days_365"/>
								<bitmap x="4" y="308" width="332" height="118" params="16" style="0" name="chart_bitmap"/>
								<text x="8" y="430" width="160" height="16" params="16" style="3" name="ext_max_price">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="172" y="430" width="160" height="16" params="16" style="3" name="ext_min_price">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="8" y="448" width="160" height="16" params="16" style="3" name="ext_max_qty">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="172" y="448" width="160" height="16" params="16" style="3" name="ext_min_qty">
									<variables>
										<var key="auto_size" value="none" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="8" y="470" width="120" height="16" params="17" style="3" name="credit_prefix">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<text x="128" y="470" width="160" height="16" params="17" style="3" name="credit_link">
									<variables>
										<var key="auto_size" value="left" type="String"/>
										<var key="text_style" value="u_small" type="String"/>
									</variables>
								</text>
								<bitmap x="8" y="468" width="324" height="18" params="17" style="0" name="credit_hit"/>
							</children>
							<variables>
								<var key="margin_left" value="0" type="int"/>
								<var key="margin_top" value="30" type="int"/>
								<var key="margin_right" value="0" type="int"/>
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
            _window.procedure = windowProcedure;
            styleStatTexts();
            paintStatBackgrounds();
            updateDayLabels();
            styleCreditLink();
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] create failed",err.message);
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK")
         {
            if(target.name == "header_button_close")
            {
               if(_window != null)
               {
                  _window.visible = false;
               }
               if(_previewer != null)
               {
                  try
                  {
                     _previewer.reset(true);
                  }
                  catch(err:Error)
                  {
                  }
               }
               return;
            }
            if(target.name == "item_preview" || target.name == "item_image" || target.name == "item_icon" || target.name == "item_icon_box")
            {
               rotatePreview();
               return;
            }
            if(target.name == "days_30" || target.name == "days_txt_30")
            {
               setDayRange(30);
               return;
            }
            if(target.name == "days_90" || target.name == "days_txt_90")
            {
               setDayRange(90);
               return;
            }
            if(target.name == "days_180" || target.name == "days_txt_180")
            {
               setDayRange(180);
               return;
            }
            if(target.name == "days_365" || target.name == "days_txt_365")
            {
               setDayRange(365);
               return;
            }
            if(target.name == "open_sh_page")
            {
               openSecureHabboFurniPage();
               return;
            }
            if(target.name == "credit_hit" || target.name == "credit_link" || target.name == "credit_prefix")
            {
               openSecureHabboSite();
            }
         }
      }
      
      private function setDayRange(days:int) : void
      {
         if(days == _historyDays)
         {
            return;
         }
         _historyDays = days;
         updateDayLabels();
         setText("chart_title",BobbaI18n.t("prices.loading"));
         clearChart();
         requestPrice();
      }
      
      private function updateDayLabels() : void
      {
         colorDayLabel("days_txt_30",30);
         colorDayLabel("days_txt_90",90);
         colorDayLabel("days_txt_180",180);
         colorDayLabel("days_txt_365",365);
         layoutDayRange();
      }
      
      private function layoutDayRange() : void
      {
         var cursor:int = 336;
         var title:IWindowModel = null;
         if(_window == null)
         {
            return;
         }
         cursor = placeDayText("days_txt_365",cursor);
         cursor = placeDayText("days_sep_3",cursor);
         cursor = placeDayText("days_txt_180",cursor);
         cursor = placeDayText("days_sep_2",cursor);
         cursor = placeDayText("days_txt_90",cursor);
         cursor = placeDayText("days_sep_1",cursor);
         cursor = placeDayText("days_txt_30",cursor);
         placeDayHit("days_365","days_txt_365");
         placeDayHit("days_180","days_txt_180");
         placeDayHit("days_90","days_txt_90");
         placeDayHit("days_30","days_txt_30");
         title = _window.findChildByName("chart_title");
         if(title != null)
         {
            title.x = 8;
            title.width = Math.max(80,cursor - 12);
         }
      }
      
      private function placeDayText(name:String, right:int) : int
      {
         var textWin:ITextWindow = null;
         var width:int = 0;
         textWin = _window.findChildByName(name) as ITextWindow;
         if(textWin == null)
         {
            return right;
         }
         textWin.autoSize = "left";
         width = int(Math.ceil(textWin.textWidth + 1));
         if(width < 6)
         {
            width = 6;
         }
         textWin.width = width;
         textWin.height = 16;
         textWin.x = right - width;
         textWin.y = 290;
         textWin.visible = true;
         return textWin.x;
      }
      
      private function placeDayHit(hitName:String, textName:String) : void
      {
         var textWin:IWindowModel = null;
         var hit:IBitmapWrapperController = null;
         var width:int = 0;
         var height:int = 0;
         textWin = _window.findChildByName(textName);
         hit = _window.findChildByName(hitName) as IBitmapWrapperController;
         if(textWin == null || hit == null)
         {
            return;
         }
         width = Math.max(12,textWin.width + 4);
         height = 16;
         hit.x = textWin.x - 2;
         hit.y = 288;
         hit.width = width;
         hit.height = height;
         hit.bitmap = new BitmapData(width,height,true,0);
         hit.visible = true;
         hit.setParamFlag(1,true);
         hit.mouseThreshold = 0;
      }
      
      private function colorDayLabel(name:String, days:int) : void
      {
         var textWin:ITextWindow = null;
         if(_window == null)
         {
            return;
         }
         textWin = _window.findChildByName(name) as ITextWindow;
         if(textWin == null)
         {
            return;
         }
         textWin.setParamFlag(1,true);
         if(_historyDays == days)
         {
            textWin.textColor = getAccentColor();
            textWin.bold = true;
         }
         else
         {
            textWin.textColor = 8947848;
            textWin.bold = false;
         }
      }
      
      private function styleCreditLink() : void
      {
         var prefix:ITextWindow = null;
         var link:ITextWindow = null;
         var hit:IBitmapWrapperController = null;
         var total:int = 0;
         var start:int = 0;
         var width:int = 0;
         if(_window == null)
         {
            return;
         }
         setText("credit_prefix",BobbaI18n.t("prices.credit.prefix","powered by "));
         setText("credit_link","securehabbo.com");
         prefix = _window.findChildByName("credit_prefix") as ITextWindow;
         link = _window.findChildByName("credit_link") as ITextWindow;
         if(prefix != null)
         {
            prefix.autoSize = "left";
            prefix.textColor = 8947848;
            prefix.setParamFlag(1,true);
         }
         if(link != null)
         {
            link.autoSize = "left";
            link.textColor = 2915788;
            link.underline = true;
            link.setParamFlag(1,true);
         }
         if(prefix != null && link != null)
         {
            total = int(prefix.width + link.width);
            start = int((340 - total) / 2);
            if(start < 8)
            {
               start = 8;
            }
            prefix.x = start;
            prefix.y = 470;
            link.x = prefix.x + prefix.width;
            link.y = 470;
            hit = _window.findChildByName("credit_hit") as IBitmapWrapperController;
            if(hit != null)
            {
               width = total + 8;
               hit.x = start - 4;
               hit.y = 468;
               hit.width = width;
               hit.height = 18;
               hit.bitmap = new BitmapData(Math.max(1,width),18,true,0);
               hit.visible = true;
               hit.setParamFlag(1,true);
               hit.mouseThreshold = 0;
            }
         }
      }
      
      private function openSecureHabboSite() : void
      {
         try
         {
            navigateToURL(new URLRequest("https://securehabbo.com"),"_blank");
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] open site failed",err.message);
         }
      }
      
      private function openSecureHabboFurniPage() : void
      {
         var url:String = "";
         if(_classname == null || _classname.length == 0)
         {
            openSecureHabboSite();
            return;
         }
         try
         {
            url = "https://securehabbo.com/legacy/" + encodeURIComponent(_classname) + "?hotel=" + secureHabboHotelCode();
            navigateToURL(new URLRequest(url),"_blank");
         }
         catch(err:Error)
         {
            Logger.log("[BobbaLegacyPrice] open furni page failed",err.message);
         }
      }
      
      private function secureHabboHotelCode() : String
      {
         var hotel:String = "";
         var backend:* = null;
         try
         {
            if(_windowManager != null)
            {
               backend = _windowManager.bobbaBackend;
               if(backend != null)
               {
                  hotel = String(backend.hotelId);
               }
            }
         }
         catch(errBackend:Error)
         {
            hotel = "";
         }
         if(hotel == null || hotel.length == 0)
         {
            hotel = BobbaI18n.hotelId;
         }
         hotel = BobbaBackendClient.canonicalizeHotelId(hotel);
         if(hotel.indexOf("hh") == 0 && hotel.length > 2)
         {
            hotel = hotel.substring(2);
         }
         if(hotel == "us" || hotel == "en")
         {
            return "com";
         }
         if(hotel == "unknown" || hotel.length == 0)
         {
            return "com";
         }
         return hotel;
      }
   }
}
