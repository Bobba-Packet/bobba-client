package com.sulake.habbo.room
{
   import com.sulake.core.assets.BitmapDataAsset;
   import com.sulake.core.assets.IAssetLibraryCollection;
   import com.sulake.core.communication.connection.IConnection;
   import com.sulake.core.communication.messages.IMessageComposer;
   import com.sulake.core.runtime.Component;
   import com.sulake.core.runtime.ComponentDependency;
   import com.sulake.core.runtime.IComponent_1;
   import com.sulake.core.runtime.IComponent_2;
   import com.sulake.core.runtime.IProfiler_1;
   import com.sulake.core.utils.Map;
   import com.sulake.core.utils.PlayerVersionCheck;
   import com.sulake.core.utils.Set;
   import com.sulake.core.utils.images.PNGEncoder;
   import com.sulake.habbo.advertisement.IAdManager;
   import com.sulake.habbo.advertisement.events.AdEvent;
   import com.sulake.habbo.avatar.pets.PetCustomPart;
   import com.sulake.habbo.avatar.pets.PetFigureData;
   import com.sulake.habbo.catalog.IHabboCatalog;
   import com.sulake.habbo.communication.IHabboCommunicationManager;
   import com.sulake.habbo.communication.messages.outgoing.camera.RenderRoomMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.camera.RenderRoomThumbnailMessageComposer;
   import com.sulake.habbo.communication.messages.parser.room.engine.AreaHideMessageData;
   import com.sulake.habbo.game.IHabboGameManager;
   import com.sulake.habbo.room.events.RoomEngineAreaHideStateWidgetEvent;
   import com.sulake.habbo.room.events.RoomEngineDragWithMouseEvent;
   import com.sulake.habbo.room.events.RoomEngineEvent;
   import com.sulake.habbo.room.events.RoomEngineHSLColorEnableEvent;
   import com.sulake.habbo.room.events.RoomEngineObjectEvent;
   import com.sulake.habbo.room.events.RoomEngineRoomColorEvent;
   import com.sulake.habbo.room.events.RoomEngineUseProductEvent;
   import com.sulake.habbo.room.events.RoomToObjectOwnAvatarMoveEvent;
   import com.sulake.habbo.room.messages.RoomObjectAvatarBlockedUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarCarryObjectUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarChatUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarDanceUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarDirectionUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarEffectUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarExperienceUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarExpressionUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarFigureUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarFlatControlUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarGestureUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarGuideStatusUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarHabbiconUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarMutedUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarOwnMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarPetGestureUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarPlayerValueUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarPlayingGameMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarPostureUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarSignUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarSleepUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarTypingUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectAvatarUseObjectUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectDataUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectFurniIconUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectGroupBadgeUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectHeightUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectItemDataUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectModelDataUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectMoveUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomAdUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomColorUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomFloorHoleUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomMaskUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomPlanePropertyUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomPlaneVisibilityUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectRoomUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectTileCursorUpdateMessage;
   import com.sulake.habbo.room.messages.RoomObjectUpdateStateMessage;
   import com.sulake.habbo.room.object.RoomObjectUserTypes;
   import com.sulake.habbo.room.object.RoomPlaneParser;
   import com.sulake.habbo.room.object.data.LegacyStuffData;
   import com.sulake.habbo.room.object.data.UnknownHabboRoomObjectData1;
   import com.sulake.habbo.room.utils.FurniStackingHeightMap;
   import com.sulake.habbo.room.utils.FurnitureData;
   import com.sulake.habbo.room.utils.LegacyWallGeometry;
   import com.sulake.habbo.room.utils.RoomAreaSelectionManager;
   import com.sulake.habbo.room.utils.RoomCamera;
   import com.sulake.habbo.room.utils.RoomData;
   import com.sulake.habbo.room.utils.RoomInstanceData;
   import com.sulake.habbo.room.utils.RoomObjectBadgeImageAssetListener;
   import com.sulake.habbo.room.utils.RoomObjectFurniIconImageAssetListener;
   import com.sulake.habbo.room.utils.SelectedRoomObjectData;
   import com.sulake.habbo.room.utils.SpriteDataCollector;
   import com.sulake.habbo.room.utils.TileObjectMap;
   import com.sulake.habbo.roomevents.IHabboUserDefinedRoomEvents;
   import com.sulake.habbo.session.IRoomSession;
   import com.sulake.habbo.session.IRoomSessionManager;
   import com.sulake.habbo.session.ISessionDataManager;
   import com.sulake.habbo.session.IUserData;
   import com.sulake.habbo.session.events.BadgeImageReadyEvent;
   import com.sulake.habbo.session.events.FurniIconImageReadyEvent;
   import com.sulake.habbo.session.events.RoomSessionEvent;
   import com.sulake.habbo.toolbar.IHabboToolbar;
   import com.sulake.habbo.toolbar.events.HabboToolbarEvent;
   import com.sulake.habbo.tracking.IHabboTracking;
   import com.sulake.habbo.utils.FurniId;
   import com.sulake.habbo.window.IHabboWindowManagerComponent;
   import com.sulake.iid.*;
   import com.sulake.room.IRoomInstance;
   import com.sulake.room.IRoomManager;
   import com.sulake.room.IRoomManagerListener;
   import com.sulake.room.IRoomObjectFactory;
   import com.sulake.room.RoomInstance;
   import com.sulake.room.events.RoomObjectEvent;
   import com.sulake.room.events.RoomObjectMouseEvent;
   import com.sulake.room.messages.RoomObjectUpdateMessage;
   import com.sulake.room.object.*;
   import com.sulake.room.object.logic.IRoomObjectEventHandler;
   import com.sulake.room.object.visualization.IRoomObjectSpriteVisualization;
   import com.sulake.room.object.visualization.IRoomObjectVisualization;
   import com.sulake.room.renderer.IRoomRenderer;
   import com.sulake.room.renderer.IRoomRendererFactory;
   import com.sulake.room.renderer.IRoomRenderingCanvas;
   import com.sulake.room.utils.IRoomGeometry;
   import com.sulake.room.utils.IVector3d;
   import com.sulake.room.utils.NumberBank;
   import com.sulake.room.utils.RoomEnterEffect;
   import com.sulake.room.utils.RoomGeometry;
   import com.sulake.room.utils.UnknownRoomUtils1;
   import com.sulake.room.utils.Vector3d;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.FileReference;
   import flash.ui.Mouse;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   [SecureSWF(rename="true")]
   public class RoomEngine extends Component implements IRoomEngine, IRoomManagerListener, IRoomEngine_4, IRoomEngine_2, IProfiler_1, IRoomEngine_3
   {
      
      public static const SETUP_WITHOUT_TOOLBAR:uint = 1;
      
      public static const UnknownConstFromHabboAvatarEditorManager_Uint_2:uint = 2;
      
      public static const SETUP_WITHOUT_GAME_MANAGER:uint = 4;
      
      public static const UnknownConstFromHabboAvatarEditorManager_Uint_3:uint = 5;
      
      private static const ROOM_TEMP_ID:String = "temporary_room";
      
      public static const OBJECT_ID_ROOM:int = -1;
      
      private static const OBJECT_TYPE_ROOM:String = "room";
      
      private static const OBJECT_ID_ROOM_HIGHLIGHTER:int = -2;
      
      private static const OBJECT_TYPE_ROOM_HIGHLIGHTER:String = "tile_cursor";
      
      private static const UnknownConstFromRoomEngine_Int_1:int = -3;
      
      private static const UnknownConstFromRoomEngine_String_1:String = "selection_arrow";
      
      private static const UnknownConstFromRoomEngine_String_2:String = "overlay";
      
      private static const UnknownConstFromRoomEngine_String_3:String = "object_icon_sprite";
      
      private static const ROOM_DRAG_THRESHOLD:int = 15;
      
      private static const UnknownConstFromRoomEngine_Int_2:int = 30;
      
      private var _communication:IHabboCommunicationManager = null;
      
      private var _roomRendererFactory:IRoomRendererFactory = null;
      
      private var _roomManager:IRoomManager = null;
      
      private var _roomObjectFactory:IRoomObjectFactory = null;
      
      private var _visualizationFactory:IRoomObjectVisualizationFactory = null;
      
      private var _adManager:IAdManager = null;
      
      private var _sessionDataManager:ISessionDataManager = null;
      
      private var _roomSessionManager:IRoomSessionManager = null;
      
      private var _habboTracking:IHabboTracking = null;
      
      private var _toolbar:IHabboToolbar = null;
      
      private var _catalog:IHabboCatalog = null;
      
      private var _windowManager:IHabboWindowManagerComponent;
      
      private var _roomEvents:IHabboUserDefinedRoomEvents;
      
      private var _eventHandler:RoomObjectEventHandler = null;
      
      private var UnknownVarFromRoomEngine_RoomMessageHandler_1:RoomMessageHandler = null;
      
      private var _roomContentLoader:RoomContentLoader = null;
      
      private var UnknownVarFromRoomEngine_Boolean_1:Boolean = false;
      
      private var UnknownVarFromRoomEngine_NumberBank_1:NumberBank;
      
      private var UnknownVarFromRoomEngine_Map_1:Map;
      
      private var UnknownVarFromRoomEngine_NumberBank_2:NumberBank;
      
      private var UnknownVarFromRoomEngine_Map_2:Map;
      
      private var _isInitialized:Boolean = false;
      
      protected var _activeRoomId:int = 0;
      
      private var UnknownVarFromRoomEngine_Int_1:int = -1;
      
      private var UnknownVarFromRoomEngine_Int_2:int = 0;
      
      private var UnknownVarFromRoomEngine_Int_3:int = 0;
      
      private var UnknownVarFromRoomEngine_Boolean_2:Boolean = false;
      
      private var UnknownVarFromRoomEngine_Boolean_3:Boolean = false;
      
      private var UnknownVarFromRoomEngine_Int_4:int = 0;
      
      private var UnknownVarFromRoomEngine_Int_5:int = 0;
      
      private var _roomDraggingAlwaysCenters:Boolean = false;
      
      private var UnknownVarFromRoomEngine_Map_3:Map = null;
      
      private var UnknownVarFromRoomEngine_Map_4:Map = null;
      
      private var _skipFurnitureCreationForNextFrame:Boolean = false;
      
      private var _mouseCursorUpdate:Boolean;
      
      private var UnknownVarFromRoomEngine_Map_5:Map = null;
      
      private var UnknownVarFromRoomEngine_Map_6:Map = null;
      
      private var _gameManager:IHabboGameManager;
      
      private var _isGameMode:Boolean;
      
      private var _playerUnderCursor:int = -1;
      
      private var _mouseEventsDisabledAboveY:int = 0;
      
      private var _mouseEventsDisabledLeftToX:int = 0;
      
      private var UnknownVarFromRoomEngine_Map_7:Map = null;
      
      private var _clickThroughUsers:Set = null;
      
      private var UnknownVarFromRoomEngine_Set_1:Set = null;
      
      private var UnknownVarFromRoomEngine_Boolean_4:Boolean = true;
      
      private var _isMoveBlocked:Boolean = false;
      
      private var _areaSelectionManager:RoomAreaSelectionManager;
      
      public function RoomEngine(param1:IComponent_2, param2:uint = 0)
      {
         super(param1,param2);
      }
      
      public static function furniIconListenerKey(param1:Boolean, param2:int, param3:String) : String
      {
         return (param1 ? "1" : "0") + "-" + param2 + "-" + param3;
      }
      
      public function get mouseEventsDisabledAboveY() : int
      {
         return _mouseEventsDisabledAboveY;
      }
      
      public function set mouseEventsDisabledAboveY(param1:int) : void
      {
         _mouseEventsDisabledAboveY = param1;
      }
      
      public function get mouseEventsDisabledLeftToX() : int
      {
         return _mouseEventsDisabledLeftToX;
      }
      
      public function set mouseEventsDisabledLeftToX(param1:int) : void
      {
         _mouseEventsDisabledLeftToX = param1;
      }
      
      public function setMouseEventsDisabledRect(param1:String, param2:Rectangle) : void
      {
         if(UnknownVarFromRoomEngine_Map_7 == null || param1 == null || param1.length == 0)
         {
            return;
         }
         if(param2 == null || param2.isEmpty())
         {
            UnknownVarFromRoomEngine_Map_7.remove(param1);
            return;
         }
         var _loc3_:Rectangle = param2.clone();
         if(UnknownVarFromRoomEngine_Map_7.hasKey(param1))
         {
            UnknownVarFromRoomEngine_Map_7.replace(param1,_loc3_);
         }
         else
         {
            UnknownVarFromRoomEngine_Map_7.add(param1,_loc3_);
         }
      }
      
      public function removeMouseEventsDisabledRect(param1:String) : void
      {
         if(UnknownVarFromRoomEngine_Map_7 == null || param1 == null || param1.length == 0)
         {
            return;
         }
         UnknownVarFromRoomEngine_Map_7.remove(param1);
      }
      
      public function get isInitialized() : Boolean
      {
         return _isInitialized;
      }
      
      public function get connection() : IConnection
      {
         return _communication != null ? _communication.connection : null;
      }
      
      public function get activeRoomId() : int
      {
         return _activeRoomId;
      }
      
      public function get roomManager() : IRoomManager
      {
         return _roomManager;
      }
      
      public function get configuration() : IComponent_1
      {
         return this;
      }
      
      protected function get eventHandler() : RoomObjectEventHandler
      {
         return _eventHandler;
      }
      
      private function get useOffsetScrolling() : Boolean
      {
         return true;
      }
      
      public function get gameEngine() : IHabboGameManager
      {
         return _gameManager;
      }
      
      override protected function get dependencies() : Vector.<ComponentDependency>
      {
         return super.dependencies.concat(new <ComponentDependency>[new ComponentDependency(new IIDRoomObjectFactory(),function(param1:IRoomObjectFactory):void
         {
            _roomObjectFactory = param1;
         }),new ComponentDependency(new IIDRoomObjectVisualizationFactory(),function(param1:IRoomObjectVisualizationFactory):void
         {
            _visualizationFactory = param1;
         }),new ComponentDependency(new IIDRoomManager(),function(param1:IRoomManager):void
         {
            _roomManager = param1;
         }),new ComponentDependency(new IIDRoomRendererFactory(),function(param1:IRoomRendererFactory):void
         {
            _roomRendererFactory = param1;
         }),new ComponentDependency(new IIDHabboCommunicationManager(),function(param1:IHabboCommunicationManager):void
         {
            _communication = param1;
         },(flags & 5) == 0),new ComponentDependency(new IIDHabboConfigurationManager(),null,true,[{
            "type":"complete",
            "callback":onConfigurationComplete
         }]),new ComponentDependency(new IIDHabboAdManager(),function(param1:IAdManager):void
         {
            _adManager = param1;
         },false,[{
            "type":"AE_ROOM_AD_SHOW",
            "callback":showRoomAd
         },{
            "type":"AE_ROOM_AD_IMAGE_LOADED",
            "callback":onRoomAdImageLoaded
         },{
            "type":"AE_ROOM_AD_IMAGE_LOADING_FAILED",
            "callback":onRoomAdImageLoaded
         }]),new ComponentDependency(new IIDSessionDataManager(),function(param1:ISessionDataManager):void
         {
            _sessionDataManager = param1;
         }),new ComponentDependency(new IIDHabboRoomSessionManager(),function(param1:IRoomSessionManager):void
         {
            _roomSessionManager = param1;
         },false,[{
            "type":"RSE_STARTED",
            "callback":onRoomSessionEvent
         },{
            "type":"RSE_ENDED",
            "callback":onRoomSessionEvent
         }]),new ComponentDependency(new IIDHabboToolbar(),function(param1:IHabboToolbar):void
         {
            _toolbar = param1;
         },false,[{
            "type":"HTE_TOOLBAR_CLICK",
            "callback":onToolbarClicked
         }]),new ComponentDependency(new IIDHabboTracking(),function(param1:IHabboTracking):void
         {
            _habboTracking = param1;
         },false),new ComponentDependency(new IIDHabboCatalog(),function(param1:IHabboCatalog):void
         {
            _catalog = param1;
         },false),new ComponentDependency(new IIDHabboUserDefinedRoomEvents(),function(param1:IHabboUserDefinedRoomEvents):void
         {
            _roomEvents = param1;
         },false),new ComponentDependency(new IIDHabboGameManager(),function(param1:IHabboGameManager):void
         {
            _gameManager = param1;
         },(flags & 4) == 0),new ComponentDependency(new IIDHabboWindowManager(),function(param1:IHabboWindowManagerComponent):void
         {
            _windowManager = param1;
         })]);
      }
      
      override protected function initComponent() : void
      {
         UnknownVarFromRoomEngine_Map_4 = new Map();
         UnknownVarFromRoomEngine_NumberBank_1 = new NumberBank(1000);
         UnknownVarFromRoomEngine_NumberBank_2 = new NumberBank(1000);
         UnknownVarFromRoomEngine_Map_1 = new Map();
         UnknownVarFromRoomEngine_Map_2 = new Map();
         UnknownVarFromRoomEngine_Map_3 = new Map();
         UnknownVarFromRoomEngine_Map_7 = new Map();
         UnknownVarFromRoomEngine_Set_1 = new Set();
         _clickThroughUsers = new Set();
         _eventHandler = createRoomObjectEventHandlerInstance();
         UnknownVarFromRoomEngine_RoomMessageHandler_1 = new RoomMessageHandler(this);
         registerUpdateReceiver(this,1);
         _roomObjectFactory.addObjectEventListener(roomObjectEventHandler);
         _areaSelectionManager = new RoomAreaSelectionManager(this);
      }
      
      private function onConfigurationComplete(param1:Event) : void
      {
         if(_roomContentLoader)
         {
            _roomContentLoader.dispose();
            events.removeEventListener("RCL_LOADER_READY",onContentLoaderReady);
         }
         var _loc2_:DisplayObjectContainer = context.displayObjectContainer;
         var _loc3_:LoaderInfo = _loc2_.loaderInfo;
         _roomContentLoader = new RoomContentLoader(_loc3_.loaderURL);
         _roomContentLoader.initialize(events,this);
         _roomContentLoader.iconAssets = assets;
         _roomContentLoader.iconListener = this;
         _roomContentLoader.visualizationFactory = _visualizationFactory;
         _roomManager.addObjectUpdateCategory(10);
         _roomManager.addObjectUpdateCategory(20);
         _roomManager.addObjectUpdateCategory(100);
         _roomManager.addObjectUpdateCategory(200);
         _roomManager.addObjectUpdateCategory(0);
         _roomManager.setContentLoader(_roomContentLoader);
         if(UnknownVarFromRoomEngine_RoomMessageHandler_1 && _communication)
         {
            UnknownVarFromRoomEngine_RoomMessageHandler_1.connection = _communication.connection;
         }
         _roomDraggingAlwaysCenters = getBoolean("room.dragging.always_center");
         _roomContentLoader.sessionDataManager = _sessionDataManager;
         events.addEventListener("RCL_LOADER_READY",onContentLoaderReady);
      }
      
      protected function createRoomObjectEventHandlerInstance() : RoomObjectEventHandler
      {
         return new RoomObjectEventHandler(this);
      }
      
      override public function dispose() : void
      {
         var _loc2_:int = 0;
         var _loc1_:RoomInstanceData = null;
         if(disposed)
         {
            return;
         }
         removeUpdateReceiver(this);
         if(_areaSelectionManager != null)
         {
            _areaSelectionManager.dispose();
            _areaSelectionManager = null;
         }
         if(UnknownVarFromRoomEngine_NumberBank_1 != null)
         {
            UnknownVarFromRoomEngine_NumberBank_1.dispose();
            UnknownVarFromRoomEngine_NumberBank_1 = null;
         }
         if(UnknownVarFromRoomEngine_NumberBank_2 != null)
         {
            UnknownVarFromRoomEngine_NumberBank_2.dispose();
            UnknownVarFromRoomEngine_NumberBank_2 = null;
         }
         if(UnknownVarFromRoomEngine_Map_1 != null)
         {
            UnknownVarFromRoomEngine_Map_1.dispose();
         }
         if(UnknownVarFromRoomEngine_Map_2 != null)
         {
            UnknownVarFromRoomEngine_Map_2.dispose();
         }
         if(_eventHandler != null)
         {
            _eventHandler.dispose();
            _eventHandler = null;
         }
         if(UnknownVarFromRoomEngine_RoomMessageHandler_1 != null)
         {
            UnknownVarFromRoomEngine_RoomMessageHandler_1.dispose();
            UnknownVarFromRoomEngine_RoomMessageHandler_1 = null;
         }
         if(_roomContentLoader != null)
         {
            _roomContentLoader.dispose();
            _roomContentLoader = null;
         }
         if(UnknownVarFromRoomEngine_Map_3 != null)
         {
            UnknownVarFromRoomEngine_Map_3.dispose();
            UnknownVarFromRoomEngine_Map_3 = null;
         }
         if(UnknownVarFromRoomEngine_Map_7 != null)
         {
            UnknownVarFromRoomEngine_Map_7.dispose();
            UnknownVarFromRoomEngine_Map_7 = null;
         }
         if(UnknownVarFromRoomEngine_Map_4 != null)
         {
            _loc2_ = 0;
            while(_loc2_ < UnknownVarFromRoomEngine_Map_4.length)
            {
               _loc1_ = UnknownVarFromRoomEngine_Map_4.getWithIndex(_loc2_) as RoomInstanceData;
               if(_loc1_ != null)
               {
                  _loc1_.dispose();
               }
               _loc2_++;
            }
            UnknownVarFromRoomEngine_Map_4.dispose();
            UnknownVarFromRoomEngine_Map_4 = null;
         }
         if(UnknownVarFromRoomEngine_Map_5 != null)
         {
            UnknownVarFromRoomEngine_Map_5.dispose();
            UnknownVarFromRoomEngine_Map_5 = null;
         }
         if(UnknownVarFromRoomEngine_Map_6 != null)
         {
            UnknownVarFromRoomEngine_Map_6.dispose();
            UnknownVarFromRoomEngine_Map_6 = null;
         }
         super.dispose();
      }
      
      public function set disableUpdate(param1:Boolean) : void
      {
         if(param1)
         {
            removeUpdateReceiver(this);
         }
         else
         {
            removeUpdateReceiver(this);
            registerUpdateReceiver(this,1);
         }
      }
      
      public function runUpdate() : void
      {
         update(1);
      }
      
      private function getRoomInstanceData(param1:int) : RoomInstanceData
      {
         var _loc2_:String = getRoomIdentifier(param1);
         var _loc3_:RoomInstanceData = null;
         if(UnknownVarFromRoomEngine_Map_4 != null)
         {
            _loc3_ = UnknownVarFromRoomEngine_Map_4.getValue(_loc2_) as RoomInstanceData;
            if(_loc3_ == null)
            {
               _loc3_ = new RoomInstanceData(param1);
               UnknownVarFromRoomEngine_Map_4.add(_loc2_,_loc3_);
            }
         }
         return _loc3_;
      }
      
      public function setFurniStackingHeightMap(param1:int, param2:FurniStackingHeightMap) : void
      {
         var _loc3_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc3_ != null)
         {
            _loc3_.furniStackingHeightMap = param2;
         }
      }
      
      public function getFurniStackingHeightMap(param1:int) : FurniStackingHeightMap
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.furniStackingHeightMap;
         }
         return null;
      }
      
      public function setWorldType(param1:int, param2:String) : void
      {
         var _loc3_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc3_ != null)
         {
            _loc3_.worldType = param2;
         }
      }
      
      public function getWorldType(param1:int) : String
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.worldType;
         }
         return null;
      }
      
      public function getLegacyGeometry(param1:int) : LegacyWallGeometry
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.legacyGeometry;
         }
         return null;
      }
      
      public function getTileObjectMap(param1:int) : TileObjectMap
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.tileObjectMap;
         }
         return null;
      }
      
      private function getActiveRoomCamera() : RoomCamera
      {
         return getRoomCamera(_activeRoomId);
      }
      
      private function getRoomCamera(param1:int) : RoomCamera
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.roomCamera;
         }
         return null;
      }
      
      public function setSelectedObjectData(param1:int, param2:SelectedRoomObjectData) : void
      {
         var _loc3_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc3_ != null)
         {
            _loc3_.selectedObject = param2;
            if(param2 != null)
            {
               _loc3_.placedObject = null;
            }
         }
      }
      
      public function getSelectedObjectData(param1:int) : ISelectedRoomObjectData
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.selectedObject;
         }
         return null;
      }
      
      public function setPlacedObjectData(param1:int, param2:SelectedRoomObjectData) : void
      {
         var _loc3_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc3_ != null)
         {
            _loc3_.placedObject = param2;
         }
      }
      
      public function getPlacedObjectData(param1:int) : ISelectedRoomObjectData
      {
         var _loc2_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc2_ != null)
         {
            return _loc2_.placedObject;
         }
         return null;
      }
      
      public function addObjectUpdateCategory(param1:int) : void
      {
         _roomManager.addObjectUpdateCategory(param1);
      }
      
      public function removeObjectUpdateCategory(param1:int) : void
      {
         _roomManager.removeObjectUpdateCategory(param1);
      }
      
      public function update(param1:uint) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IRoomInstance = null;
         RoomEnterEffect.turnVisualizationOn();
         var _loc2_:IRoomRenderingCanvas = getActiveRoomActiveCanvas();
         if(_loc2_ != null)
         {
            _loc2_.pingMs = _habboTracking != null ? _habboTracking.latencyPingMs : -1;
         }
         if(_roomManager != null)
         {
            createRoomFurniture();
            _roomManager.update(param1);
            _loc3_ = 0;
            while(_loc3_ < _roomManager.getRoomCount())
            {
               _loc4_ = _roomManager.getRoomWithIndex(_loc3_);
               if(_loc4_ != null && _loc4_.getRenderer() != null)
               {
                  _loc4_.getRenderer().update(param1);
               }
               _loc3_++;
            }
            updateRoomCameras(param1);
            if(_mouseCursorUpdate)
            {
               updateMouseCursor();
            }
         }
         RoomEnterEffect.turnVisualizationOff();
      }
      
      private function updateMouseCursor() : void
      {
         _mouseCursorUpdate = false;
         if(_windowManager.LilithCustomsInstance.IsPlayingEnabled)
         {
            Mouse.cursor = "auto";
            return;
         }
         var _loc1_:RoomInstanceData = getRoomInstanceData(_activeRoomId);
         if(_loc1_ && _loc1_.hasButtonMouseCursorOwners())
         {
            Mouse.cursor = "button";
         }
         else
         {
            Mouse.cursor = "auto";
         }
      }
      
      public function requestMouseCursor(param1:String, param2:int, param3:String) : void
      {
         var _loc4_:int = getRoomObjectCategory(param3);
         var _loc5_:* = param1;
         if("ROFCAE_MOUSE_BUTTON" !== _loc5_)
         {
            if(isGameMode && _loc4_ == 100)
            {
               _playerUnderCursor = -1;
            }
            removeButtonMouseCursorOwner(_activeRoomId,_loc4_,param2);
         }
         else
         {
            if(isGameMode && _loc4_ == 100)
            {
               _playerUnderCursor = param2;
            }
            addButtonMouseCursorOwner(_activeRoomId,_loc4_,param2);
         }
      }
      
      private function addButtonMouseCursorOwner(param1:int, param2:int, param3:int) : void
      {
         var _loc5_:String = null;
         var _loc4_:RoomInstanceData = null;
         var _loc6_:IRoomSession = _roomSessionManager.getSession(param1);
         if(param2 != 10 && param2 != 20 || _loc6_ != null && _loc6_.roomControllerLevel >= 1)
         {
            _loc5_ = param2 + "_" + param3;
            _loc4_ = getRoomInstanceData(param1);
            if(_loc4_ != null)
            {
               if(_loc4_.addButtonMouseCursorOwner(_loc5_))
               {
                  _mouseCursorUpdate = true;
               }
            }
         }
      }
      
      private function removeButtonMouseCursorOwner(param1:int, param2:int, param3:int) : void
      {
         var _loc5_:String = null;
         var _loc4_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc4_ != null)
         {
            _loc5_ = param2 + "_" + param3;
            if(_loc4_.removeButtonMouseCursorOwner(_loc5_))
            {
               _mouseCursorUpdate = true;
            }
         }
      }
      
      private function removeButtonMouseCursorOwners(param1:int, param2:int) : void
      {
         var _loc4_:Array = null;
         var _loc5_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc5_ != null)
         {
            _loc4_ = [];
            for each(var _loc3_ in _loc5_.mouseButtonCursorOwners)
            {
               if(_loc3_.indexOf(param2 + "_") == 0)
               {
                  _loc4_.push(_loc3_);
               }
            }
            for each(var _loc6_ in _loc4_)
            {
               if(_loc5_.removeButtonMouseCursorOwner(_loc6_))
               {
                  _mouseCursorUpdate = true;
               }
            }
         }
      }
      
      public function setClickSettings(param1:String, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:Boolean = clickThroughUsers;
         var _loc5_:Boolean = clickThroughFurni;
         if(param2 && !_clickThroughUsers.contains(param1))
         {
            _clickThroughUsers.add(param1);
         }
         else if(!param2 && _clickThroughUsers.contains(param1))
         {
            _clickThroughUsers.remove(param1);
         }
         if(param3 && !UnknownVarFromRoomEngine_Set_1.contains(param1))
         {
            UnknownVarFromRoomEngine_Set_1.add(param1);
         }
         else if(!param3 && UnknownVarFromRoomEngine_Set_1.contains(param1))
         {
            UnknownVarFromRoomEngine_Set_1.remove(param1);
         }
         if(!_loc4_ && param2)
         {
            removeButtonMouseCursorOwners(_activeRoomId,100);
         }
         if(!_loc5_ && param3)
         {
            removeButtonMouseCursorOwners(_activeRoomId,10);
            removeButtonMouseCursorOwners(_activeRoomId,20);
         }
      }
      
      public function get clickThroughUsers() : Boolean
      {
         return !_clickThroughUsers.isEmpty();
      }
      
      public function get clickThroughFurni() : Boolean
      {
         return !UnknownVarFromRoomEngine_Set_1.isEmpty();
      }
      
      public function addFloorHole(param1:int, param2:int) : void
      {
         var _loc8_:IRoomObjectController = null;
         var _loc9_:IRoomObjectController = null;
         var _loc5_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         if(param2 >= 0)
         {
            _loc8_ = getObjectRoom(param1);
            _loc9_ = getObjectFurniture(param1,param2);
            if(_loc9_ != null && _loc9_.getModel() != null && _loc8_ != null && _loc8_.getEventHandler() != null)
            {
               _loc5_ = "RORPFHUM_ADD";
               _loc3_ = int(_loc9_.getLocation().x);
               _loc4_ = int(_loc9_.getLocation().y);
               _loc7_ = int(_loc9_.getModel().getNumber("furniture_size_x"));
               _loc6_ = int(_loc9_.getModel().getNumber("furniture_size_y"));
               _loc8_.getEventHandler().processUpdateMessage(new RoomObjectRoomFloorHoleUpdateMessage(_loc5_,param2,_loc3_,_loc4_,_loc7_,_loc6_));
            }
         }
      }
      
      public function removeFloorHole(param1:int, param2:int) : void
      {
         var _loc4_:IRoomObjectController = null;
         var _loc3_:String = null;
         if(param2 >= 0)
         {
            _loc4_ = getObjectRoom(param1);
            if(_loc4_ != null && _loc4_.getEventHandler() != null)
            {
               _loc3_ = "RORPFHUM_REMOVE";
               _loc4_.getEventHandler().processUpdateMessage(new RoomObjectRoomFloorHoleUpdateMessage(_loc3_,param2));
            }
         }
      }
      
      private function createRoomFurniture() : void
      {
         var _loc6_:int = 0;
         _loc6_ = 4;
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:FurnitureData = null;
         var _loc10_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:RoomInstance = null;
         var _loc5_:int = getTimer();
         var _loc12_:int = 0;
         var _loc11_:Map = UnknownVarFromRoomEngine_Map_4;
         do
         {
            for each(var _loc2_ in _loc11_)
            {
               _loc4_ = 0;
               _loc3_ = null;
               _loc10_ = false;
               _loc7_ = false;
               while(true)
               {
                  _loc3_ = _loc2_.getFurnitureData();
                  if(_loc3_ == null)
                  {
                     break;
                  }
                  _loc10_ = addObjectFurnitureFromData(_loc2_.roomId,_loc3_.id,_loc3_);
                  _loc4_++;
                  if(_loc4_ % 4 == 0)
                  {
                     _loc1_ = getTimer();
                     if(_loc1_ - _loc5_ >= 30 && !_isGameMode)
                     {
                        _loc7_ = true;
                        break;
                     }
                  }
               }
               while(true)
               {
                  _loc3_ = _loc2_.getWallItemData();
                  if(!(!_loc7_ && _loc3_ != null))
                  {
                     break;
                  }
                  _loc10_ = addObjectWallItemFromData(_loc2_.roomId,_loc3_.id,_loc3_);
                  _loc4_++;
                  if(_loc4_ % 4 == 0)
                  {
                     _loc1_ = getTimer();
                     if(_loc1_ - _loc5_ >= 30 && !_isGameMode)
                     {
                        _loc7_ = true;
                        break;
                     }
                  }
               }
               if(_loc10_ && _isGameMode)
               {
                  _loc8_ = getRoomIdentifier(_loc2_.roomId);
                  _loc9_ = _roomManager.getRoom(_loc8_) as RoomInstance;
                  if(!_loc9_.hasUninitializedObjects())
                  {
                     objectsInitialized(_loc8_);
                  }
               }
            }
            return;
         }
         while(!_loc7_);
         
      }
      
      private function updateRoomCameras(param1:uint) : void
      {
         var _loc7_:int = 0;
         var _loc3_:RoomInstanceData = null;
         var _loc6_:RoomCamera = null;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:IRoomObject = null;
         var _loc2_:int = 1;
         _loc7_ = 0;
         while(_loc7_ < UnknownVarFromRoomEngine_Map_4.length)
         {
            _loc3_ = UnknownVarFromRoomEngine_Map_4.getWithIndex(_loc7_) as RoomInstanceData;
            _loc6_ = null;
            _loc8_ = 0;
            if(_loc3_ != null)
            {
               _loc6_ = _loc3_.roomCamera;
               _loc8_ = _loc3_.roomId;
            }
            if(_loc6_ != null)
            {
               _loc5_ = _loc6_.targetId;
               _loc4_ = _loc6_.targetCategory;
               _loc9_ = getRoomObject(_loc8_,_loc5_,_loc4_);
               if(_loc9_ != null)
               {
                  if(_loc8_ != _activeRoomId || !UnknownVarFromRoomEngine_Boolean_2)
                  {
                     updateRoomCamera(_loc8_,_loc2_,_loc9_.getLocation(),param1);
                  }
               }
            }
            _loc7_++;
         }
      }
      
      public function getRoomGeometry(param1:int) : RoomGeometry
      {
         var _loc2_:IRoomRenderingCanvas = getRoomCanvas(param1,1);
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.geometry as RoomGeometry;
      }
      
      public function updateRoomCamera(param1:int, param2:int, param3:IVector3d, param4:uint) : void
      {
         var _loc46_:Number = NaN;
         var _loc18_:Rectangle = null;
         var _loc26_:int = 0;
         var _loc25_:int = 0;
         var _loc41_:Rectangle = null;
         var _loc6_:Vector3d = null;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc34_:Point = null;
         var _loc17_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc12_:Matrix = null;
         var _loc36_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:Point = null;
         var _loc44_:Boolean = false;
         var _loc43_:Boolean = false;
         var _loc24_:Boolean = false;
         var _loc23_:Boolean = false;
         var _loc14_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc39_:Point = null;
         var _loc29_:Vector3d = null;
         var _loc30_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         var _loc7_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc30_ == null || _loc7_ == null || _loc30_.scale != 1)
         {
            return;
         }
         var _loc45_:RoomGeometry = _loc30_.geometry as RoomGeometry;
         var _loc11_:RoomCamera = _loc7_.roomCamera;
         var _loc35_:IRoomInstance = getRoom(param1);
         if(_loc45_ != null && _loc11_ != null && _loc35_ != null)
         {
            _loc46_ = Math.floor(param3.z) + 1;
            _loc18_ = getRoomCanvasRectangle(param1,param2);
            if(_loc18_ != null)
            {
               _loc26_ = Math.round(_loc18_.width);
               _loc25_ = Math.round(_loc18_.height);
               _loc41_ = getActiveRoomBoundingRectangle(param2);
               if(_loc41_ != null && (_loc41_.right < 0 || _loc41_.bottom < 0 || _loc41_.left >= _loc26_ || _loc41_.top >= _loc25_))
               {
                  _loc11_.reset();
               }
               if(_loc11_.screenWd != _loc26_ || _loc11_.screenHt != _loc25_ || _loc11_.scale != _loc45_.scale || _loc11_.geometryUpdateId != _loc45_.updateId || !Vector3d.isEqual(param3,_loc11_.targetObjectLoc) || _loc11_.isMoving)
               {
                  _loc11_.targetObjectLoc = param3;
                  _loc6_ = new Vector3d();
                  _loc6_.assign(param3);
                  _loc6_.x = Math.round(_loc6_.x);
                  _loc6_.y = Math.round(_loc6_.y);
                  _loc31_ = _loc35_.getNumber("room_min_x") - 0.5;
                  _loc32_ = _loc35_.getNumber("room_min_y") - 0.5;
                  _loc9_ = _loc35_.getNumber("room_max_x") + 0.5;
                  _loc27_ = _loc35_.getNumber("room_max_y") + 0.5;
                  _loc22_ = Math.round((_loc31_ + _loc9_) / 2);
                  _loc21_ = Math.round((_loc32_ + _loc27_) / 2);
                  _loc19_ = 2;
                  _loc34_ = new Point(_loc6_.x - _loc22_,_loc6_.y - _loc21_);
                  _loc17_ = _loc45_.scale / Math.sqrt(2);
                  _loc20_ = _loc17_ / 2;
                  _loc12_ = new Matrix();
                  _loc12_.rotate(-(_loc45_.direction.x + 90) / 180 * 3.141592653589793);
                  _loc34_ = _loc12_.transformPoint(_loc34_);
                  _loc34_.y = _loc34_.y * (_loc20_ / _loc17_);
                  _loc36_ = _loc18_.width / 2 / _loc17_ - 1;
                  _loc38_ = _loc18_.height / 2 / _loc20_ - 1;
                  _loc42_ = 0;
                  _loc40_ = 0;
                  _loc10_ = 0;
                  _loc8_ = 0;
                  _loc5_ = _loc45_.getScreenPoint(new Vector3d(_loc22_,_loc21_,_loc19_));
                  if(!_loc5_)
                  {
                     return;
                  }
                  _loc5_.x += Math.round(_loc18_.width / 2);
                  _loc5_.y += Math.round(_loc18_.height / 2);
                  if(_loc41_ == null)
                  {
                     _loc45_.adjustLocation(new Vector3d(0,0),25);
                     return;
                  }
                  _loc41_.offset(-_loc30_.screenOffsetX,-_loc30_.screenOffsetY);
                  if(!(_loc41_.width > 1 && _loc41_.height > 1))
                  {
                     _loc45_.adjustLocation(new Vector3d(-30,-30),25);
                     return;
                  }
                  _loc42_ = (_loc41_.left - _loc5_.x - _loc45_.scale * 0.25) / _loc17_;
                  _loc10_ = (_loc41_.right - _loc5_.x + _loc45_.scale * 0.25) / _loc17_;
                  _loc40_ = (_loc41_.top - _loc5_.y - _loc45_.scale * 0.5) / _loc20_;
                  _loc8_ = (_loc41_.bottom - _loc5_.y + _loc45_.scale * 0.5) / _loc20_;
                  _loc44_ = false;
                  _loc43_ = false;
                  _loc24_ = false;
                  _loc23_ = false;
                  _loc14_ = Math.round((_loc10_ - _loc42_) * _loc17_);
                  if(_loc14_ < _loc18_.width)
                  {
                     _loc46_ = 2;
                     _loc34_.x = (_loc10_ + _loc42_) / 2;
                     _loc24_ = true;
                  }
                  else
                  {
                     if(_loc34_.x > _loc10_ - _loc36_)
                     {
                        _loc34_.x = _loc10_ - _loc36_;
                        _loc44_ = true;
                     }
                     if(_loc34_.x < _loc42_ + _loc36_)
                     {
                        _loc34_.x = _loc42_ + _loc36_;
                        _loc44_ = true;
                     }
                  }
                  _loc13_ = Math.round((_loc8_ - _loc40_) * _loc20_);
                  if(_loc13_ < _loc18_.height)
                  {
                     _loc46_ = 2;
                     _loc34_.y = (_loc8_ + _loc40_) / 2;
                     _loc23_ = true;
                  }
                  else
                  {
                     if(_loc34_.y > _loc8_ - _loc38_)
                     {
                        _loc34_.y = _loc8_ - _loc38_;
                        _loc43_ = true;
                     }
                     if(_loc34_.y < _loc40_ + _loc38_)
                     {
                        _loc34_.y = _loc40_ + _loc38_;
                        _loc43_ = true;
                     }
                     if(_loc43_)
                     {
                        _loc34_.y /= _loc20_ / _loc17_;
                     }
                  }
                  _loc12_.invert();
                  _loc34_ = _loc12_.transformPoint(_loc34_);
                  _loc34_.x = _loc34_.x + _loc22_;
                  _loc34_.y += _loc21_;
                  _loc33_ = 0.35;
                  _loc37_ = 0.2;
                  _loc28_ = 0.2;
                  _loc15_ = 10;
                  _loc16_ = 10;
                  if(_loc28_ * _loc26_ > 100)
                  {
                     _loc28_ = 100 / _loc26_;
                  }
                  if(_loc33_ * _loc25_ > 150)
                  {
                     _loc33_ = 150 / _loc25_;
                  }
                  if(_loc37_ * _loc25_ > 150)
                  {
                     _loc37_ = 150 / _loc25_;
                  }
                  if(_loc11_.limitedLocationX && _loc11_.screenWd == _loc26_ && _loc11_.screenHt == _loc25_)
                  {
                     _loc28_ = 0;
                  }
                  if(_loc11_.limitedLocationY && _loc11_.screenWd == _loc26_ && _loc11_.screenHt == _loc25_)
                  {
                     _loc33_ = 0;
                     _loc37_ = 0;
                  }
                  _loc18_.right *= 1 - _loc28_ * 2;
                  _loc18_.bottom *= 1 - (_loc33_ + _loc37_);
                  if(_loc18_.right < _loc15_)
                  {
                     _loc18_.right = _loc15_;
                  }
                  if(_loc18_.bottom < _loc16_)
                  {
                     _loc18_.bottom = _loc16_;
                  }
                  if(_loc33_ + _loc37_ > 0)
                  {
                     _loc18_.offset(-_loc18_.width / 2,-_loc18_.height * (_loc37_ / (_loc33_ + _loc37_)));
                  }
                  else
                  {
                     _loc18_.offset(-_loc18_.width / 2,-_loc18_.height / 2);
                  }
                  _loc5_ = _loc45_.getScreenPoint(_loc6_);
                  if(!_loc5_)
                  {
                     return;
                  }
                  _loc5_.x += _loc30_.screenOffsetX;
                  _loc5_.y += _loc30_.screenOffsetY;
                  _loc6_.z = _loc46_;
                  _loc6_.x = Math.round(_loc34_.x * 2) / 2;
                  _loc6_.y = Math.round(_loc34_.y * 2) / 2;
                  if(_loc11_.location == null)
                  {
                     _loc45_.location = _loc6_;
                     if(useOffsetScrolling)
                     {
                        _loc11_.initializeLocation(new Vector3d(0,0,0));
                     }
                     else
                     {
                        _loc11_.initializeLocation(_loc6_);
                     }
                  }
                  _loc39_ = _loc45_.getScreenPoint(_loc6_);
                  _loc29_ = new Vector3d(0,0,0);
                  if(_loc39_ != null)
                  {
                     _loc29_.x = _loc39_.x;
                     _loc29_.y = _loc39_.y;
                  }
                  if((_loc5_.x < _loc18_.left || _loc5_.x > _loc18_.right) && !_loc11_.centeredLocX || (_loc5_.y < _loc18_.top || _loc5_.y > _loc18_.bottom) && !_loc11_.centeredLocY || _loc24_ && !_loc11_.centeredLocX && _loc11_.screenWd != _loc26_ || _loc23_ && !_loc11_.centeredLocY && _loc11_.screenHt != _loc25_ || (_loc11_.roomWd != _loc41_.width || _loc11_.roomHt != _loc41_.height) || (_loc11_.screenWd != _loc26_ || _loc11_.screenHt != _loc25_))
                  {
                     _loc11_.limitedLocationX = _loc44_;
                     _loc11_.limitedLocationY = _loc43_;
                     if(useOffsetScrolling)
                     {
                        _loc11_.target = _loc29_;
                     }
                     else
                     {
                        _loc11_.target = _loc6_;
                     }
                  }
                  else
                  {
                     if(!_loc44_)
                     {
                        _loc11_.limitedLocationX = false;
                     }
                     if(!_loc43_)
                     {
                        _loc11_.limitedLocationY = false;
                     }
                  }
                  _loc11_.centeredLocX = _loc24_;
                  _loc11_.centeredLocY = _loc23_;
                  _loc11_.screenWd = _loc26_;
                  _loc11_.screenHt = _loc25_;
                  _loc11_.scale = _loc45_.scale;
                  _loc11_.geometryUpdateId = _loc45_.updateId;
                  _loc11_.roomWd = _loc41_.width;
                  _loc11_.roomHt = _loc41_.height;
                  if(!_sessionDataManager.isRoomCameraFollowDisabled)
                  {
                     if(useOffsetScrolling)
                     {
                        _loc11_.update(param4,8);
                     }
                     else
                     {
                        _loc11_.update(param4,0.5);
                     }
                  }
                  if(useOffsetScrolling)
                  {
                     _loc30_.screenOffsetX = -_loc11_.location.x;
                     _loc30_.screenOffsetY = -_loc11_.location.y;
                  }
                  else
                  {
                     _loc45_.adjustLocation(_loc11_.location,25);
                  }
               }
               else
               {
                  _loc11_.limitedLocationX = false;
                  _loc11_.limitedLocationY = false;
                  _loc11_.centeredLocX = false;
                  _loc11_.centeredLocY = false;
               }
            }
         }
      }
      
      private function onContentLoaderReady(param1:Event) : void
      {
         UnknownVarFromRoomEngine_Boolean_1 = true;
         _roomManager.initialize(<nothing/>,this);
      }
      
      private function onRoomSessionEvent(param1:RoomSessionEvent) : void
      {
         switch(param1.type)
         {
            case "RSE_STARTED":
               if(UnknownVarFromRoomEngine_RoomMessageHandler_1)
               {
                  UnknownVarFromRoomEngine_RoomMessageHandler_1.setCurrentRoom(param1.session.roomId);
               }
               if(_eventHandler)
               {
                  _eventHandler.enterNewRoom();
               }
               break;
            case "RSE_ENDED":
               if(UnknownVarFromRoomEngine_RoomMessageHandler_1)
               {
                  UnknownVarFromRoomEngine_RoomMessageHandler_1.resetCurrentRoom();
                  disposeRoom(param1.session.roomId);
               }
         }
      }
      
      private function onToolbarClicked(param1:HabboToolbarEvent) : void
      {
         var _loc2_:RoomCamera = null;
         if(param1.iconId == "HTIE_ICON_MEMENU")
         {
            _loc2_ = getActiveRoomCamera();
            if(_loc2_)
            {
               _loc2_.activateFollowing(cameraFollowDuration);
               _loc2_.reset();
            }
         }
      }
      
      public function roomManagerInitialized(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc2_:RoomData = null;
         if(param1)
         {
            _isInitialized = true;
            events.dispatchEvent(new RoomEngineEvent("REE_ENGINE_INITIALIZED",0));
            _loc3_ = 0;
            while(_loc3_ < UnknownVarFromRoomEngine_Map_3.length)
            {
               _loc2_ = UnknownVarFromRoomEngine_Map_3.getWithIndex(_loc3_) as RoomData;
               if(_loc2_ != null)
               {
                  initializeRoom(_loc2_.roomId,_loc2_.data);
               }
               _loc3_++;
            }
         }
         else
         {
            Logger.log("[RoomEngine] Failed to initialize manager");
         }
      }
      
      public function setActiveRoom(param1:int) : void
      {
         _activeRoomId = param1;
      }
      
      public function getRoomIdentifier(param1:int) : String
      {
         return String(param1);
      }
      
      private function getRoomId(param1:String) : int
      {
         var _loc2_:Array = null;
         if(param1 != null)
         {
            _loc2_ = param1.split("_");
            if(_loc2_.length > 0)
            {
               return _loc2_[0];
            }
         }
         return -1;
      }
      
      public function getRoomNumberValue(param1:int, param2:String) : Number
      {
         var _loc3_:IRoomInstance = getRoom(param1);
         if(_loc3_ != null)
         {
            if(!_loc3_.hasValueForName(param2))
            {
               return NaN;
            }
            return _loc3_.getNumber(param2);
         }
         return NaN;
      }
      
      public function getRoomStringValue(param1:int, param2:String) : String
      {
         var _loc3_:IRoomInstance = getRoom(param1);
         if(_loc3_ != null)
         {
            return _loc3_.getString(param2);
         }
         return null;
      }
      
      public function setIsPlayingGame(param1:int, param2:Boolean) : void
      {
         param2 = _windowManager.LilithCustomsInstance.IsPlayingEnabled;
         var _loc3_:int = 0;
         var _loc4_:IRoomInstance = getRoom(param1);
         if(_loc4_ != null)
         {
            _loc3_ = param2 ? 1 : 0;
            _loc4_.setNumber("is_playing_game",_loc3_);
            if(_loc3_ == 0)
            {
               events.dispatchEvent(new RoomEngineEvent("REE_NORMAL_MODE",param1));
            }
            else
            {
               events.dispatchEvent(new RoomEngineEvent("REE_GAME_MODE",param1));
            }
         }
      }
      
      public function leaveSpectate() : void
      {
         events.dispatchEvent(new RoomEngineEvent("REE_ENTRANCE_AFTER_SPECTATE",_activeRoomId));
      }
      
      public function setHanditemControlBlocked(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IRoomInstance = getRoom(param1);
         if(_loc4_ != null)
         {
            _loc3_ = param2 ? 1 : 0;
            _loc4_.setNumber("handitem_control_blocked",_loc3_);
         }
      }
      
      public function setChooserDisabled(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IRoomInstance = getRoom(param1);
         if(_loc4_ != null)
         {
            _loc3_ = param2 ? 1 : 0;
            _loc4_.setNumber("chooser_disabled",_loc3_);
         }
      }
      
      public function setFreeFurniMovementsMode(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IRoomInstance = getRoom(param1);
         if(_loc4_ != null)
         {
            _loc3_ = param2 ? 1 : 0;
            _loc4_.setNumber("free_furni_movements_mode",_loc3_);
         }
      }
      
      public function setInvisibleFurni(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IRoomInstance = getRoom(param1);
         if(_loc4_ != null)
         {
            _loc3_ = param2 ? 1 : 0;
            _loc4_.setNumber("invisible_furni",_loc3_);
            updateInvisibleFurniForRoom(param1,param2);
         }
      }
      
      private function updateInvisibleFurniForRoom(param1:int, param2:Boolean) : void
      {
         updateInvisibleFurniForObjects(getRoomObjects(param1,10),param2);
         updateInvisibleFurniForObjects(getRoomObjects(param1,20),param2);
      }
      
      private function updateInvisibleFurniForObjects(param1:Array, param2:Boolean) : void
      {
         var _loc3_:IRoomObjectController = null;
         var _loc4_:IRoomObjectModelController = null;
         if(param1 == null)
         {
            return;
         }
         var _loc5_:int = param2 ? 1 : 0;
         for each(var _loc6_ in param1)
         {
            _loc3_ = _loc6_ as IRoomObjectController;
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.getModelController();
               if(_loc4_ != null)
               {
                  _loc4_.setNumber("furniture_invisible_layer",_loc5_);
               }
            }
         }
      }
      
      public function getIsPlayingGame(param1:int) : Boolean
      {
         var _loc2_:Number = NaN;
         if(param1 == _activeRoomId && _roomEvents.isGameMode)
         {
            return true;
         }
         var _loc3_:IRoomInstance = getRoom(param1);
         if(_loc3_ != null)
         {
            _loc2_ = _loc3_.getNumber("is_playing_game");
            if(_loc2_ > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isRoomVariableActive(param1:int, param2:String) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:IRoomInstance = getRoom(param1);
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.getNumber(param2);
            if(_loc3_ > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getActiveRoomIsPlayingGame() : Boolean
      {
         return getIsPlayingGame(_activeRoomId);
      }
      
      public function get activeRoomHasHanditemControlBlocked() : Boolean
      {
         return isRoomVariableActive(_activeRoomId,"handitem_control_blocked");
      }
      
      public function get activeRoomHasChooserDisabled() : Boolean
      {
         return isRoomVariableActive(_activeRoomId,"chooser_disabled");
      }
      
      public function get activeRoomHasFreeFurniMovementsMode() : Boolean
      {
         return isRoomVariableActive(_activeRoomId,"free_furni_movements_mode");
      }
      
      public function getRoom(param1:int) : IRoomInstance
      {
         if(!_isInitialized)
         {
            return null;
         }
         var _loc2_:String = getRoomIdentifier(param1);
         return _roomManager.getRoom(_loc2_);
      }
      
      public function initializeRoom(param1:int, param2:XML, param3:IVector3d = null, param4:Vector.<IAreaHideInfo> = null) : void
      {
         var _loc5_:String = getRoomIdentifier(param1);
         var _loc8_:RoomData = null;
         var _loc9_:String = "111";
         var _loc10_:String = "201";
         var _loc7_:String = "1";
         if(!_isInitialized)
         {
            _loc8_ = UnknownVarFromRoomEngine_Map_3.remove(_loc5_);
            if(_loc8_ != null)
            {
               _loc9_ = _loc8_.floorType;
               _loc10_ = _loc8_.wallType;
               _loc7_ = _loc8_.landscapeType;
               if(!param3)
               {
                  param3 = _loc8_.cameraInitPosition;
               }
            }
            _loc8_ = new RoomData(param1,param2);
            _loc8_.floorType = _loc9_;
            _loc8_.wallType = _loc10_;
            _loc8_.landscapeType = _loc7_;
            _loc8_.cameraInitPosition = param3;
            UnknownVarFromRoomEngine_Map_3.add(_loc5_,_loc8_);
            Logger.log("Room Engine not initilized yet, can not create room. Room data stored for later initialization.");
            return;
         }
         if(param2 == null)
         {
            Logger.log("Room property messages received before floor height map, will initialize when floor height map received.");
            return;
         }
         _loc8_ = UnknownVarFromRoomEngine_Map_3.remove(_loc5_);
         if(_loc8_ != null)
         {
            if(_loc8_.floorType != null && _loc8_.floorType.length > 0)
            {
               _loc9_ = _loc8_.floorType;
            }
            if(_loc8_.wallType != null && _loc8_.wallType.length > 0)
            {
               _loc10_ = _loc8_.wallType;
            }
            if(_loc8_.landscapeType != null && _loc8_.landscapeType.length > 0)
            {
               _loc7_ = _loc8_.landscapeType;
            }
            if(_loc8_.cameraInitPosition != null)
            {
               param3 = _loc8_.cameraInitPosition;
            }
         }
         var _loc11_:IRoomInstance = createRoom(_loc5_,param2,_loc9_,_loc10_,_loc7_,param3);
         if(param4 != null)
         {
            for each(var _loc6_ in param4)
            {
               updateAreaHide(param1,_loc6_.furniId,_loc6_.on,_loc6_.rootX,_loc6_.rootY,_loc6_.width,_loc6_.length,_loc6_.invert);
            }
         }
         if(_loc11_ == null)
         {
            return;
         }
         events.dispatchEvent(new RoomEngineEvent("REE_INITIALIZED",param1));
         setIsPlayingGame(param1,false);
      }
      
      private function createRoom(param1:String, param2:XML, param3:String, param4:String, param5:String, param6:IVector3d) : IRoomInstance
      {
         var _loc24_:int = 0;
         var _loc11_:XML = null;
         var _loc26_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc22_:RoomObjectRoomUpdateMessage = null;
         var _loc17_:XMLList = null;
         var _loc27_:Array = null;
         var _loc10_:RoomObjectRoomMaskUpdateMessage = null;
         var _loc20_:int = 0;
         var _loc7_:XML = null;
         var _loc16_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc18_:String = null;
         var _loc21_:String = null;
         var _loc19_:Vector3d = null;
         if(!_isInitialized)
         {
            return null;
         }
         var _loc23_:IRoomInstance = _roomManager.createRoom(param1,param2);
         if(_loc23_ == null)
         {
            return null;
         }
         var _loc28_:int = 0;
         var _loc29_:IRoomObjectController = null;
         var _loc15_:Number = 1;
         _loc29_ = _loc23_.createRoomObject(-1,"room",_loc28_) as IRoomObjectController;
         _loc23_.setNumber("room_is_public",0,true);
         _loc23_.setNumber("room_z_scale",_loc15_,true);
         if(param2 != null)
         {
            _loc24_ = 0;
            if(param2.dimensions.length() == 1)
            {
               _loc11_ = param2.dimensions[0];
               _loc26_ = Number(_loc11_.@minX);
               _loc9_ = Number(_loc11_.@maxX);
               _loc25_ = Number(_loc11_.@minY);
               _loc8_ = Number(_loc11_.@maxY);
               _loc23_.setNumber("room_min_x",_loc26_);
               _loc23_.setNumber("room_max_x",_loc9_);
               _loc23_.setNumber("room_min_y",_loc25_);
               _loc23_.setNumber("room_max_y",_loc8_);
               _loc24_ += _loc26_ * 423 + _loc9_ * 671 + _loc25_ * 913 + _loc8_ * 7509;
               if(_loc29_ != null && _loc29_.getModelController() != null)
               {
                  _loc29_.getModelController().setNumber("room_random_seed",_loc24_,true);
               }
            }
            if(param6 != null)
            {
               _loc23_.setNumber("camera_init_x",param6.x);
               _loc23_.setNumber("camera_init_y",param6.y);
               _loc23_.setNumber("camera_init_z",param6.z);
            }
         }
         if(_loc29_ != null && _loc29_.getEventHandler() != null)
         {
            _loc29_.getEventHandler().initialize(param2);
            _loc22_ = null;
            if(param3 != null)
            {
               _loc22_ = new RoomObjectRoomUpdateMessage("RORUM_ROOM_FLOOR_UPDATE",param3);
               _loc29_.getEventHandler().processUpdateMessage(_loc22_);
               _loc23_.setString("room_floor_type",param3);
            }
            if(param4 != null)
            {
               _loc22_ = new RoomObjectRoomUpdateMessage("RORUM_ROOM_WALL_UPDATE",param4);
               _loc29_.getEventHandler().processUpdateMessage(_loc22_);
               _loc23_.setString("room_wall_type",param4);
            }
            if(param5 != null)
            {
               _loc22_ = new RoomObjectRoomUpdateMessage("RORUM_ROOM_LANDSCAPE_UPDATE",param5);
               _loc29_.getEventHandler().processUpdateMessage(_loc22_);
               _loc23_.setString("room_landscape_type",param5);
            }
            if(param2 != null)
            {
               if(param2.doors.door.length() > 0)
               {
                  _loc17_ = param2.doors.door;
                  _loc27_ = ["x","y","z","dir"];
                  _loc10_ = null;
                  _loc20_ = 0;
                  while(_loc20_ < _loc17_.length())
                  {
                     _loc7_ = _loc17_[_loc20_];
                     if(UnknownRoomUtils1.checkRequiredAttributes(_loc7_,_loc27_))
                     {
                        _loc16_ = Number(_loc7_.@x);
                        _loc14_ = Number(_loc7_.@y);
                        _loc13_ = Number(_loc7_.@z);
                        _loc12_ = Number(_loc7_.@dir);
                        _loc18_ = "door";
                        _loc21_ = "door_" + _loc20_;
                        _loc19_ = new Vector3d(_loc16_,_loc14_,_loc13_);
                        _loc10_ = new RoomObjectRoomMaskUpdateMessage("RORMUM_ADD_MASK",_loc21_,_loc18_,_loc19_,"hole");
                        _loc29_.getEventHandler().processUpdateMessage(_loc10_);
                        if(_loc12_ == 90 || _loc12_ == 180)
                        {
                           if(_loc12_ == 90)
                           {
                              _loc23_.setNumber("room_door_x",_loc16_ - 0.5,true);
                              _loc23_.setNumber("room_door_y",_loc14_,true);
                           }
                           if(_loc12_ == 180)
                           {
                              _loc23_.setNumber("room_door_x",_loc16_,true);
                              _loc23_.setNumber("room_door_y",_loc14_ - 0.5,true);
                           }
                           _loc23_.setNumber("room_door_z",_loc13_,true);
                           _loc23_.setNumber("room_door_dir",_loc12_,true);
                        }
                     }
                     _loc20_++;
                  }
               }
            }
         }
         _loc23_.createRoomObject(-2,"tile_cursor",200);
         if(!getBoolean("avatar.widget.enabled"))
         {
            _loc23_.createRoomObject(-3,"selection_arrow",200);
         }
         return _loc23_;
      }
      
      public function getObjectRoom(param1:int) : IRoomObjectController
      {
         return getObject(getRoomIdentifier(param1),-1,0);
      }
      
      public function updateObjectRoom(param1:int, param2:String = null, param3:String = null, param4:String = null, param5:Boolean = false) : Boolean
      {
         var _loc6_:String = null;
         var _loc8_:RoomData = null;
         var _loc10_:IRoomObjectController = getObjectRoom(param1);
         var _loc7_:IRoomInstance = getRoom(param1);
         if(_loc10_ == null)
         {
            _loc6_ = getRoomIdentifier(param1);
            _loc8_ = UnknownVarFromRoomEngine_Map_3.getValue(_loc6_);
            if(_loc8_ == null)
            {
               _loc8_ = new RoomData(param1,null);
               UnknownVarFromRoomEngine_Map_3.add(_loc6_,_loc8_);
            }
            if(param2 != null)
            {
               _loc8_.floorType = param2;
            }
            if(param3 != null)
            {
               _loc8_.wallType = param3;
            }
            if(param4 != null)
            {
               _loc8_.landscapeType = param4;
            }
            return true;
         }
         if(_loc10_.getEventHandler() == null)
         {
            return false;
         }
         var _loc9_:RoomObjectRoomUpdateMessage = null;
         if(param2 != null)
         {
            if(_loc7_ != null && !param5)
            {
               _loc7_.setString("room_floor_type",param2);
            }
            _loc9_ = new RoomObjectRoomUpdateMessage("RORUM_ROOM_FLOOR_UPDATE",param2);
            _loc10_.getEventHandler().processUpdateMessage(_loc9_);
         }
         if(param3 != null)
         {
            if(_loc7_ != null && !param5)
            {
               _loc7_.setString("room_wall_type",param3);
            }
            _loc9_ = new RoomObjectRoomUpdateMessage("RORUM_ROOM_WALL_UPDATE",param3);
            _loc10_.getEventHandler().processUpdateMessage(_loc9_);
         }
         if(param4 != null)
         {
            if(_loc7_ != null && !param5)
            {
               _loc7_.setString("room_landscape_type",param4);
            }
            _loc9_ = new RoomObjectRoomUpdateMessage("RORUM_ROOM_LANDSCAPE_UPDATE",param4);
            _loc10_.getEventHandler().processUpdateMessage(_loc9_);
         }
         return true;
      }
      
      public function updateObjectRoomColor(param1:int, param2:uint, param3:int, param4:Boolean) : Boolean
      {
         var _loc6_:IRoomObjectController = getObjectRoom(param1);
         if(_loc6_ == null || _loc6_.getEventHandler() == null)
         {
            return false;
         }
         var _loc5_:RoomObjectRoomColorUpdateMessage = null;
         _loc5_ = new RoomObjectRoomColorUpdateMessage("RORCUM_BACKGROUND_COLOR",param2,param3,param4);
         _loc6_.getEventHandler().processUpdateMessage(_loc5_);
         events.dispatchEvent(new RoomEngineRoomColorEvent(param1,param2,param3,param4));
         return true;
      }
      
      public function updateObjectRoomBackgroundColor(param1:int, param2:Boolean, param3:int, param4:int, param5:int) : Boolean
      {
         var _loc6_:IRoomObjectController = getObjectRoom(param1);
         if(_loc6_ == null || _loc6_.getEventHandler() == null)
         {
            return false;
         }
         events.dispatchEvent(new RoomEngineHSLColorEnableEvent("ROHSLCEE_ROOM_BACKGROUND_COLOR",param1,param2,param3,param4,param5));
         return true;
      }
      
      public function updateObjectRoomVisibilities(param1:int, param2:Boolean, param3:Boolean = true) : Boolean
      {
         var _loc4_:IRoomObjectController = getObjectRoom(param1);
         if(_loc4_ == null || _loc4_.getEventHandler() == null)
         {
            return false;
         }
         var _loc5_:RoomObjectRoomPlaneVisibilityUpdateMessage = null;
         _loc5_ = new RoomObjectRoomPlaneVisibilityUpdateMessage("RORPVUM_WALL_VISIBILITY",param2);
         _loc4_.getEventHandler().processUpdateMessage(_loc5_);
         _loc5_ = new RoomObjectRoomPlaneVisibilityUpdateMessage("RORPVUM_FLOOR_VISIBILITY",param3);
         _loc4_.getEventHandler().processUpdateMessage(_loc5_);
         return true;
      }
      
      public function updateObjectRoomPlaneThicknesses(param1:int, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:IRoomObjectController = getObjectRoom(param1);
         if(_loc4_ == null || _loc4_.getEventHandler() == null)
         {
            return false;
         }
         var _loc5_:RoomObjectRoomPlanePropertyUpdateMessage = null;
         _loc5_ = new RoomObjectRoomPlanePropertyUpdateMessage("RORPPUM_WALL_THICKNESS",param2);
         _loc4_.getEventHandler().processUpdateMessage(_loc5_);
         _loc5_ = new RoomObjectRoomPlanePropertyUpdateMessage("RORPVUM_FLOOR_THICKNESS",param3);
         _loc4_.getEventHandler().processUpdateMessage(_loc5_);
         return true;
      }
      
      public function updateAreaHide(param1:int, param2:int, param3:Boolean, param4:int, param5:int, param6:int, param7:int, param8:Boolean) : Boolean
      {
         var _loc10_:RoomObjectRoomFloorHoleUpdateMessage = null;
         var _loc9_:RoomEngineAreaHideStateWidgetEvent = new RoomEngineAreaHideStateWidgetEvent(param1,param2,10,param3);
         events.dispatchEvent(_loc9_);
         var _loc11_:IRoomObjectController = getObjectRoom(param1);
         if(_loc11_ == null || _loc11_.getEventHandler() == null)
         {
            return false;
         }
         if(param3)
         {
            _loc10_ = new RoomObjectRoomFloorHoleUpdateMessage("RORPFHUM_ADD",param2,param4,param5,param6,param7,param8);
         }
         else
         {
            _loc10_ = new RoomObjectRoomFloorHoleUpdateMessage("RORPFHUM_REMOVE",param2);
         }
         _loc11_.getEventHandler().processUpdateMessage(_loc10_);
         return true;
      }
      
      public function disposeRoom(param1:int) : void
      {
         var _loc2_:String = getRoomIdentifier(param1);
         _roomManager.disposeRoom(_loc2_);
         var _loc3_:RoomInstanceData = UnknownVarFromRoomEngine_Map_4.remove(_loc2_);
         if(_loc3_ != null)
         {
            _loc3_.dispose();
         }
         events.dispatchEvent(new RoomEngineEvent("REE_DISPOSED",param1));
      }
      
      public function setOwnUserId(param1:int, param2:int) : void
      {
         var _loc3_:IRoomSession = _roomSessionManager.getSession(param1);
         if(_loc3_)
         {
            _loc3_.ownUserRoomId = param2;
         }
         var _loc4_:RoomCamera = getRoomCamera(param1);
         if(_loc4_ != null)
         {
            _loc4_.targetId = param2;
            _loc4_.targetCategory = 100;
            _loc4_.activateFollowing(cameraFollowDuration);
         }
      }
      
      public function createRoomCanvas(param1:int, param2:int, param3:int, param4:int, param5:int) : DisplayObject
      {
         var _loc17_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Vector3d = null;
         var _loc15_:Vector3d = null;
         var _loc8_:Sprite = null;
         var _loc11_:String = getRoomIdentifier(param1);
         var _loc9_:IRoomInstance = _roomManager.getRoom(_loc11_);
         if(_loc9_ == null)
         {
            return null;
         }
         var _loc6_:IRoomRenderer = _loc9_.getRenderer() as IRoomRenderer;
         if(_loc6_ == null)
         {
            _loc6_ = _roomRendererFactory.createRenderer();
         }
         if(_loc6_ == null)
         {
            return null;
         }
         _loc6_.roomObjectVariableAccurateZ = "object_accurate_z_value";
         _loc9_.setRenderer(_loc6_);
         var _loc7_:IRoomRenderingCanvas = _loc6_.createCanvas(param2,param3,param4,param5);
         if(_loc7_ == null)
         {
            return null;
         }
         _loc7_.mouseListener = _eventHandler;
         if(_loc7_.geometry != null)
         {
            _loc7_.geometry.z_scale = _loc9_.getNumber("room_z_scale");
         }
         if(_loc7_.geometry != null)
         {
            _loc17_ = _loc9_.getNumber("room_door_x");
            _loc16_ = _loc9_.getNumber("room_door_y");
            _loc14_ = _loc9_.getNumber("room_door_z");
            _loc12_ = _loc9_.getNumber("room_door_dir");
            _loc13_ = new Vector3d(_loc17_,_loc16_,_loc14_);
            _loc15_ = null;
            if(_loc12_ == 90)
            {
               _loc15_ = new Vector3d(-2000,0,0);
            }
            if(_loc12_ == 180)
            {
               _loc15_ = new Vector3d(0,-2000,0);
            }
            _loc7_.geometry.setDisplacement(_loc13_,_loc15_);
         }
         var _loc10_:Sprite = _loc7_.displayObject as Sprite;
         if(_loc10_ != null)
         {
            _loc8_ = new Sprite();
            _loc8_.name = "overlay";
            _loc8_.mouseEnabled = false;
            _loc10_.addChild(_loc8_);
         }
         return _loc10_;
      }
      
      public function setRoomCanvasScale(param1:int, param2:int, param3:Number, param4:Point = null, param5:Point = null, param6:Boolean = false, param7:Boolean = false, param8:Boolean = false) : void
      {
         if(!getBoolean("zoom.enabled"))
         {
            return;
         }
         if(!param7)
         {
            param3 = param6 ? -1 : (param3 < 1 ? 0.5 : Math.floor(param3));
         }
         var _loc9_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc9_ != null)
         {
            _loc9_.setScale(param3,param4,param5,param8);
            syncRoomCameraLocationToCanvasOffset(param1,_loc9_);
            events.dispatchEvent(new RoomEngineEvent("REE_ROOM_ZOOMED",param1));
         }
      }
      
      public function getRoomCanvasScale(param1:int = -1000, param2:int = -1) : Number
      {
         if(param1 == -1000)
         {
            param1 = _activeRoomId;
         }
         if(param2 == -1)
         {
            param2 = UnknownVarFromRoomEngine_Int_1;
         }
         var _loc3_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc3_ == null)
         {
            return 1;
         }
         return _loc3_.scale;
      }
      
      public function getRoomCanvas(param1:int, param2:int) : IRoomRenderingCanvas
      {
         var _loc3_:String = getRoomIdentifier(param1);
         var _loc6_:IRoomInstance = _roomManager.getRoom(_loc3_);
         if(_loc6_ == null)
         {
            return null;
         }
         var _loc4_:IRoomRenderer = _loc6_.getRenderer() as IRoomRenderer;
         if(_loc4_ == null)
         {
            return null;
         }
         return _loc4_.getCanvas(param2);
      }
      
      public function modifyRoomCanvas(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc5_ == null)
         {
            return false;
         }
         _loc5_.initialize(param3,param4);
         return true;
      }
      
      public function setRoomCanvasMask(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc4_ == null)
         {
            return;
         }
         _loc4_.useMask = param3;
      }
      
      private function getRoomCanvasRectangle(param1:int, param2:int) : Rectangle
      {
         var _loc3_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc3_ == null)
         {
            return null;
         }
         return new Rectangle(0,0,_loc3_.width,_loc3_.height);
      }
      
      public function getRoomCanvasGeometry(param1:int, param2:int = -1) : IRoomGeometry
      {
         if(param2 == -1)
         {
            param2 = UnknownVarFromRoomEngine_Int_1;
         }
         var _loc3_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc3_ == null)
         {
            return null;
         }
         return _loc3_.geometry;
      }
      
      public function getRoomCanvasScreenOffset(param1:int, param2:int = -1) : Point
      {
         if(param2 == -1)
         {
            param2 = UnknownVarFromRoomEngine_Int_1;
         }
         var _loc3_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc3_ == null)
         {
            return null;
         }
         return new Point(_loc3_.screenOffsetX,_loc3_.screenOffsetY);
      }
      
      public function setRoomCanvasScreenOffset(param1:int, param2:int, param3:Point) : Boolean
      {
         var _loc4_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(_loc4_ == null || param3 == null)
         {
            return false;
         }
         _loc4_.screenOffsetX = param3.x;
         _loc4_.screenOffsetY = param3.y;
         return true;
      }
      
      public function snapshotRoomCanvasToBitmap(param1:int, param2:int, param3:BitmapData, param4:Matrix, param5:Boolean) : Boolean
      {
         var _loc7_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(!_loc7_)
         {
            return false;
         }
         var _loc6_:DisplayObject = _loc7_.displayObject;
         if(!_loc6_)
         {
            return false;
         }
         param3.draw(_loc6_,param4,null,null,null,param5);
         return true;
      }
      
      private function handleRoomDragging(param1:IRoomRenderingCanvas, param2:int, param3:int, param4:String, param5:Boolean, param6:Boolean, param7:Boolean) : Boolean
      {
         var _loc10_:RoomInstanceData = null;
         var _loc11_:RoomCamera = null;
         if(_isGameMode)
         {
            return false;
         }
         if(_areaSelectionManager.areaSelectionState == RoomAreaSelectionManager.SELECTING)
         {
            UnknownVarFromRoomEngine_Boolean_2 = false;
            UnknownVarFromRoomEngine_Boolean_3 = false;
            return false;
         }
         var _loc9_:int = param2 - UnknownVarFromRoomEngine_Int_2;
         var _loc8_:int = param3 - UnknownVarFromRoomEngine_Int_3;
         if(param4 == "mouseDown")
         {
            if(!param5 && !param6 && !param7 && !isDecorateMode)
            {
               UnknownVarFromRoomEngine_Boolean_2 = true;
               UnknownVarFromRoomEngine_Boolean_3 = false;
               UnknownVarFromRoomEngine_Int_4 = UnknownVarFromRoomEngine_Int_2;
               UnknownVarFromRoomEngine_Int_5 = UnknownVarFromRoomEngine_Int_3;
            }
         }
         else if(param4 == "mouseUp")
         {
            if(UnknownVarFromRoomEngine_Boolean_2)
            {
               UnknownVarFromRoomEngine_Boolean_2 = false;
               if(UnknownVarFromRoomEngine_Boolean_3)
               {
                  _loc10_ = getRoomInstanceData(_activeRoomId);
                  if(_loc10_ != null)
                  {
                     _loc11_ = _loc10_.roomCamera;
                     if(_loc11_ != null)
                     {
                        if(useOffsetScrolling)
                        {
                           if(!_loc11_.isMoving)
                           {
                              _loc11_.centeredLocX = false;
                              _loc11_.centeredLocY = false;
                           }
                           _loc11_.resetLocation(new Vector3d(-normalizeScreenOffsetForScale(param1.screenOffsetX,param1.width,param1.scale),-normalizeScreenOffsetForScale(param1.screenOffsetY,param1.height,param1.scale)));
                        }
                        if(_roomDraggingAlwaysCenters)
                        {
                           _loc11_.reset();
                        }
                     }
                  }
                  events.dispatchEvent(new RoomEngineDragWithMouseEvent("REDWME_DRAG_END",_activeRoomId));
               }
            }
         }
         else if(param4 == "mouseMove")
         {
            if(UnknownVarFromRoomEngine_Boolean_2)
            {
               if(!UnknownVarFromRoomEngine_Boolean_3)
               {
                  _loc9_ = param2 - UnknownVarFromRoomEngine_Int_4;
                  _loc8_ = param3 - UnknownVarFromRoomEngine_Int_5;
                  if(_loc9_ <= -15 || _loc9_ >= 15 || _loc8_ <= -15 || _loc8_ >= 15)
                  {
                     UnknownVarFromRoomEngine_Boolean_3 = true;
                     events.dispatchEvent(new RoomEngineDragWithMouseEvent("REDWME_DRAG_START",_activeRoomId));
                  }
                  _loc9_ = 0;
                  _loc8_ = 0;
               }
               if(_loc9_ != 0 || _loc8_ != 0)
               {
                  param1.screenOffsetX += _loc9_;
                  param1.screenOffsetY += _loc8_;
                  if(!UnknownVarFromRoomEngine_Boolean_3)
                  {
                     events.dispatchEvent(new RoomEngineDragWithMouseEvent("REDWME_DRAG_START",_activeRoomId));
                  }
                  UnknownVarFromRoomEngine_Boolean_3 = true;
               }
            }
         }
         else if(param4 == "click" || param4 == "doubleClick")
         {
            UnknownVarFromRoomEngine_Boolean_2 = false;
            if(UnknownVarFromRoomEngine_Boolean_3)
            {
               UnknownVarFromRoomEngine_Boolean_3 = false;
               return true;
            }
         }
         return false;
      }
      
      private function normalizeScreenOffsetForScale(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param3 == 0 || param3 == 1)
         {
            return param1;
         }
         var _loc4_:Number = param2 / param3;
         var _loc5_:Number = _loc4_ / 2;
         return _loc5_ - (_loc5_ - param1) / param3;
      }
      
      private function syncRoomCameraLocationToCanvasOffset(param1:int, param2:IRoomRenderingCanvas) : void
      {
         if(!useOffsetScrolling || param2 == null || param2.scale <= 0)
         {
            return;
         }
         var _loc3_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc3_ == null || _loc3_.roomCamera == null)
         {
            return;
         }
         _loc3_.roomCamera.resetLocation(new Vector3d(-normalizeScreenOffsetForScale(param2.screenOffsetX,param2.width,param2.scale),-normalizeScreenOffsetForScale(param2.screenOffsetY,param2.height,param2.scale)));
      }
      
      public function handleRoomCanvasMouseEvent(param1:int, param2:int, param3:int, param4:String, param5:Boolean, param6:Boolean, param7:Boolean, param8:Boolean) : void
      {
         var _loc12_:Number = NaN;
         var _loc10_:Sprite = null;
         var _loc11_:Sprite = null;
         var _loc15_:Rectangle = null;
         var _loc14_:String = null;
         var _loc13_:RoomObjectEvent = null;
         if(!UnknownVarFromRoomEngine_Boolean_2)
         {
            if(_mouseEventsDisabledAboveY > 0 && param3 < _mouseEventsDisabledAboveY)
            {
               return;
            }
            if(_mouseEventsDisabledLeftToX > 0 && param2 < _mouseEventsDisabledLeftToX)
            {
               return;
            }
            if(isMouseEventDisabledByRect(param2,param3))
            {
               return;
            }
         }
         var _loc9_:IRoomRenderingCanvas = getRoomCanvas(_activeRoomId,param1);
         if(_loc9_ != null)
         {
            if(param4 == "click" && param6 && param5)
            {
               _loc12_ = Number(param7 ? _loc9_.scale >> 1 : (_loc9_.scale < 1 ? 1 : _loc9_.scale << 1));
               setRoomCanvasScale(activeRoomId,UnknownVarFromRoomEngine_Int_1,_loc12_,new Point(param2,param3));
               return;
            }
            _loc10_ = getOverlaySprite(_loc9_);
            _loc11_ = getOverlayIconSprite(_loc10_,"object_icon_sprite");
            if(_loc11_ != null)
            {
               _loc15_ = _loc11_.getRect(_loc11_);
               _loc11_.x = param2 - _loc15_.width / 2;
               _loc11_.y = param3 - _loc15_.height / 2;
            }
            if(param4 == "click" && _areaSelectionManager.finishSelecting())
            {
               _areaSelectionManager.finishSelecting();
            }
            else if(!handleRoomDragging(_loc9_,param2,param3,param4,param5,param6,param7))
            {
               if(!_loc9_.handleMouseEvent(param2,param3,param4,param5,param6,param7,param8))
               {
                  _loc14_ = "";
                  if(param4 == "click")
                  {
                     if(events != null)
                     {
                        events.dispatchEvent(new RoomEngineObjectEvent("REOE_DESELECTED",_activeRoomId,-1,-2));
                     }
                     _loc14_ = "ROE_MOUSE_CLICK";
                  }
                  else if(param4 == "mouseMove")
                  {
                     _loc14_ = "ROE_MOUSE_MOVE";
                  }
                  else if(param4 == "mouseDown")
                  {
                     _loc14_ = "ROE_MOUSE_DOWN";
                  }
                  if(_eventHandler != null)
                  {
                     _loc13_ = new RoomObjectMouseEvent(_loc14_,getRoomObject(_activeRoomId,-1,0),null,param5);
                     _eventHandler.handleRoomObjectEvent(_loc13_,_activeRoomId);
                  }
               }
            }
            UnknownVarFromRoomEngine_Int_1 = param1;
            UnknownVarFromRoomEngine_Int_2 = param2;
            UnknownVarFromRoomEngine_Int_3 = param3;
         }
      }
      
      private function getOverlaySprite(param1:IRoomRenderingCanvas) : Sprite
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:Sprite = param1.displayObject as Sprite;
         if(_loc3_ == null)
         {
            return null;
         }
         return _loc3_.getChildByName("overlay") as Sprite;
      }
      
      private function addOverlayIconSprite(param1:Sprite, param2:String, param3:BitmapData) : Sprite
      {
         if(param1 == null || param3 == null)
         {
            return null;
         }
         var _loc5_:Sprite = getOverlayIconSprite(param1,param2);
         if(_loc5_ != null)
         {
            return null;
         }
         _loc5_ = new Sprite();
         _loc5_.name = param2;
         _loc5_.mouseEnabled = false;
         var _loc4_:Bitmap = new Bitmap(param3);
         _loc5_.addChild(_loc4_);
         param1.addChild(_loc5_);
         return _loc5_;
      }
      
      private function removeOverlayIconSprite(param1:Sprite, param2:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:Sprite = null;
         var _loc3_:Bitmap = null;
         if(param1 == null)
         {
            return false;
         }
         _loc5_ = param1.numChildren - 1;
         while(_loc5_ >= 0)
         {
            _loc4_ = param1.getChildAt(_loc5_) as Sprite;
            if(_loc4_ != null)
            {
               if(_loc4_.name == param2)
               {
                  param1.removeChildAt(_loc5_);
                  _loc3_ = _loc4_.getChildAt(0) as Bitmap;
                  if(_loc3_ != null && _loc3_.bitmapData != null)
                  {
                     _loc3_.bitmapData.dispose();
                     _loc3_.bitmapData = null;
                  }
                  return true;
               }
            }
            _loc5_--;
         }
         return false;
      }
      
      private function getOverlayIconSprite(param1:Sprite, param2:String) : Sprite
      {
         var _loc4_:int = 0;
         var _loc3_:Sprite = null;
         if(param1 == null)
         {
            return null;
         }
         _loc4_ = param1.numChildren - 1;
         while(_loc4_ >= 0)
         {
            _loc3_ = param1.getChildAt(_loc4_) as Sprite;
            if(_loc3_ != null)
            {
               if(_loc3_.name == param2)
               {
                  return _loc3_;
               }
            }
            _loc4_--;
         }
         return null;
      }
      
      public function setObjectMoverIconSprite(param1:int, param2:int, param3:Boolean, param4:String = null, param5:IStuffData = null, param6:int = -1, param7:int = -1, param8:String = null) : void
      {
         var _loc13_:String = null;
         var _loc12_:int = 0;
         var _loc14_:PetFigureData = null;
         var _loc10_:Sprite = null;
         var _loc11_:Sprite = null;
         var _loc15_:UnknownHabboRoom1 = null;
         if(param3)
         {
            _loc15_ = getRoomObjectImage(_activeRoomId,param1,param2,new Vector3d(),1,null);
         }
         else if(_roomContentLoader != null)
         {
            _loc13_ = null;
            _loc12_ = 0;
            if(param2 == 10)
            {
               _loc13_ = _roomContentLoader.getActiveObjectType(param1);
               _loc12_ = _roomContentLoader.getActiveObjectColorIndex(param1);
            }
            else if(param2 == 20)
            {
               _loc13_ = _roomContentLoader.getWallItemType(param1,param4);
               _loc12_ = _roomContentLoader.getWallItemColorIndex(param1);
            }
            if(param2 == 100)
            {
               _loc13_ = RoomObjectUserTypes.getName(param1);
               if(_loc13_ == "pet")
               {
                  _loc13_ = getPetType(param4);
                  _loc14_ = new PetFigureData(param4);
                  _loc15_ = getPetImage(_loc14_.typeId,_loc14_.paletteId,_loc14_.color,new Vector3d(180),64,null,true,0,_loc14_.customParts,param8);
               }
               else
               {
                  _loc15_ = getGenericRoomObjectImage(_loc13_,param4,new Vector3d(180),1,null,0,null,param5,param6,param7,param8);
               }
            }
            else
            {
               _loc15_ = getGenericRoomObjectImage(_loc13_,String(_loc12_),new Vector3d(),1,null,0,param4,param5,param6,param7,param8);
            }
         }
         if(_loc15_ == null || _loc15_.data == null)
         {
            return;
         }
         var _loc9_:IRoomRenderingCanvas = getActiveRoomActiveCanvas();
         if(_loc9_ != null)
         {
            _loc10_ = getOverlaySprite(_loc9_);
            removeOverlayIconSprite(_loc10_,"object_icon_sprite");
            _loc11_ = addOverlayIconSprite(_loc10_,"object_icon_sprite",_loc15_.data);
            if(_loc11_ != null)
            {
               _loc11_.x = UnknownVarFromRoomEngine_Int_2 - _loc15_.data.width / 2;
               _loc11_.y = UnknownVarFromRoomEngine_Int_3 - _loc15_.data.height / 2;
            }
         }
      }
      
      private function isMouseEventDisabledByRect(param1:int, param2:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Rectangle = null;
         if(UnknownVarFromRoomEngine_Map_7 == null)
         {
            return false;
         }
         _loc4_ = 0;
         while(_loc4_ < UnknownVarFromRoomEngine_Map_7.length)
         {
            _loc3_ = UnknownVarFromRoomEngine_Map_7.getWithIndex(_loc4_) as Rectangle;
            if(_loc3_ != null && _loc3_.contains(param1,param2))
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      public function setObjectMoverIconSpriteVisible(param1:Boolean) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:Sprite = null;
         var _loc2_:IRoomRenderingCanvas = getActiveRoomActiveCanvas();
         if(_loc2_ != null)
         {
            _loc3_ = getOverlaySprite(_loc2_);
            _loc4_ = getOverlayIconSprite(_loc3_,"object_icon_sprite");
            if(_loc4_ != null)
            {
               _loc4_.visible = param1;
            }
         }
      }
      
      public function getObjectMoverIconSpriteVisible() : Boolean
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         var _loc1_:IRoomRenderingCanvas = getActiveRoomActiveCanvas();
         if(_loc1_ != null)
         {
            _loc2_ = getOverlaySprite(_loc1_);
            _loc3_ = getOverlayIconSprite(_loc2_,"object_icon_sprite");
            if(_loc3_ != null)
            {
               return _loc3_.visible;
            }
         }
         return false;
      }
      
      public function removeObjectMoverIconSprite() : void
      {
         var _loc2_:Sprite = null;
         var _loc1_:IRoomRenderingCanvas = getActiveRoomActiveCanvas();
         if(_loc1_ != null)
         {
            _loc2_ = getOverlaySprite(_loc1_);
            removeOverlayIconSprite(_loc2_,"object_icon_sprite");
         }
      }
      
      public function getRoomObjectCount(param1:int, param2:int) : int
      {
         if(!_isInitialized)
         {
            return 0;
         }
         var _loc3_:String = getRoomIdentifier(param1);
         var _loc4_:IRoomInstance = _roomManager.getRoom(_loc3_);
         if(_loc4_ == null)
         {
            return 0;
         }
         return _loc4_.getObjectCount(param2);
      }
      
      public function getRoomObject(param1:int, param2:int, param3:int) : IRoomObject
      {
         if(!_isInitialized)
         {
            return null;
         }
         var _loc4_:String = getRoomIdentifier(param1);
         if(param1 == 0)
         {
            _loc4_ = "temporary_room";
         }
         return getObject(_loc4_,param2,param3);
      }
      
      public function getObjectsByCategory(param1:int) : Array
      {
         var _loc2_:IRoomInstance = null;
         if(_roomManager != null)
         {
            _loc2_ = _roomManager.getRoom(getRoomIdentifier(_activeRoomId));
         }
         if(_loc2_ == null)
         {
            return [];
         }
         return _loc2_.getObjects(param1);
      }
      
      public function getRoomObjectWithIndex(param1:int, param2:int, param3:int) : IRoomObject
      {
         if(!_isInitialized)
         {
            return null;
         }
         var _loc4_:String = getRoomIdentifier(param1);
         var _loc5_:IRoomInstance = _roomManager.getRoom(_loc4_);
         if(_loc5_ == null)
         {
            return null;
         }
         return _loc5_.getObjectWithIndex(param2,param3);
      }
      
      public function getRoomObjects(param1:int, param2:int) : Array
      {
         var _loc3_:String = null;
         var _loc4_:IRoomInstance = null;
         if(_isInitialized)
         {
            _loc3_ = getRoomIdentifier(param1);
            _loc4_ = _roomManager.getRoom(_loc3_);
            if(_loc4_ != null)
            {
               return _loc4_.getObjects(param2);
            }
         }
         return [];
      }
      
      public function modifyRoomObject(param1:int, param2:int, param3:String) : Boolean
      {
         if(_eventHandler != null)
         {
            return _eventHandler.modifyRoomObject(_activeRoomId,param1,param2,param3);
         }
         return false;
      }
      
      public function rotateActiveObjectPreview(param1:Boolean) : Boolean
      {
         if(_eventHandler != null)
         {
            return _eventHandler.rotateActiveObjectPreview(_activeRoomId,param1);
         }
         return false;
      }
      
      public function modifyRoomObjectDataWithMap(param1:int, param2:int, param3:String, param4:Map) : Boolean
      {
         if(_eventHandler != null)
         {
            if(param2 == 10)
            {
               return _eventHandler.modifyRoomObjectData(_activeRoomId,param1,param2,param3,param4);
            }
         }
         return false;
      }
      
      public function modifyRoomObjectData(param1:int, param2:int, param3:String, param4:String) : Boolean
      {
         if(_eventHandler != null)
         {
            if(param2 == 20)
            {
               return _eventHandler.modifyWallItemData(_activeRoomId,param1,param3,param4);
            }
         }
         return false;
      }
      
      public function deleteRoomObject(param1:int, param2:int) : Boolean
      {
         if(_eventHandler != null)
         {
            if(param2 == 20)
            {
               return _eventHandler.deleteWallItem(_activeRoomId,param1);
            }
         }
         return false;
      }
      
      public function initializeRoomObjectInsert(param1:String, param2:int, param3:int, param4:int, param5:String = null, param6:IStuffData = null, param7:int = -1, param8:int = -1, param9:String = null, param10:Boolean = false) : Boolean
      {
         var _loc11_:IRoomInstance = getRoom(_activeRoomId);
         if(_loc11_ == null || _loc11_.getNumber("room_is_public") != 0)
         {
            return false;
         }
         if(_eventHandler != null)
         {
            return _eventHandler.initializeRoomObjectInsert(param1,_activeRoomId,param2,param3,param4,param5,param6,param7,param8,param9,param10);
         }
         return false;
      }
      
      public function cancelRoomObjectInsert() : void
      {
         if(_eventHandler != null)
         {
            _eventHandler.cancelRoomObjectInsert(_activeRoomId);
         }
      }
      
      public function useRoomObjectInActiveRoom(param1:int, param2:int) : Boolean
      {
         var _loc3_:IRoomObjectEventHandler = null;
         var _loc4_:IRoomObject = getRoomObject(_activeRoomId,param1,param2);
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.getMouseHandler() as IRoomObjectEventHandler;
            if(_loc3_ != null)
            {
               _loc3_.useObject();
               return true;
            }
         }
         return false;
      }
      
      private function getRoomObjectAdURL(param1:String) : String
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getRoomObjectAdURL(param1);
         }
         return "";
      }
      
      public function setRoomObjectAlias(param1:String, param2:String) : void
      {
         if(_roomContentLoader != null)
         {
            _roomContentLoader.setRoomObjectAlias(param1,param2);
         }
      }
      
      public function getRoomObjectCategory(param1:String) : int
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getObjectCategory(param1);
         }
         return -2;
      }
      
      public function getFurnitureType(param1:int) : String
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getActiveObjectType(param1);
         }
         return "";
      }
      
      public function getFurnitureTypeId(param1:String) : int
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getActiveObjectTypeId(param1);
         }
         return 0;
      }
      
      public function getWallItemType(param1:int, param2:String = null) : String
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getWallItemType(param1,param2);
         }
         return "";
      }
      
      public function getPetTypeId(param1:String) : int
      {
         var _loc2_:Array = null;
         var _loc3_:int = -1;
         if(param1 != null)
         {
            _loc2_ = param1.split(" ");
            if(_loc2_.length > 1)
            {
               _loc3_ = parseInt(_loc2_[0]);
            }
         }
         return _loc3_;
      }
      
      private function getPetType(param1:String) : String
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(param1 != null)
         {
            _loc2_ = param1.split(" ");
            if(_loc2_.length > 1)
            {
               _loc3_ = parseInt(_loc2_[0]);
               if(_roomContentLoader != null)
               {
                  return _roomContentLoader.getPetType(_loc3_);
               }
               return "pet";
            }
         }
         return null;
      }
      
      public function getPetColor(param1:int, param2:int) : PetColorResult
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getPetColor(param1,param2);
         }
         return null;
      }
      
      public function getPetColorsByTag(param1:int, param2:String) : Array
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getPetColorsByTag(param1,param2);
         }
         return null;
      }
      
      public function getPetLayerIdForTag(param1:int, param2:String) : int
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getPetLayerIdForTag(param1,param2);
         }
         return -1;
      }
      
      public function getPetDefaultPalette(param1:int, param2:String) : PetColorResult
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getPetDefaultPalette(param1,param2);
         }
         return null;
      }
      
      private function getFurnitureColorIndex(param1:int) : int
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getActiveObjectColorIndex(param1);
         }
         return 0;
      }
      
      private function getWallItemColorIndex(param1:int) : int
      {
         if(_roomContentLoader != null)
         {
            return _roomContentLoader.getWallItemColorIndex(param1);
         }
         return 0;
      }
      
      public function getSelectionArrow(param1:int) : IRoomObjectController
      {
         return getObject(getRoomIdentifier(param1),-3,200);
      }
      
      public function getTileCursor(param1:int) : IRoomObjectController
      {
         return getObject(getRoomIdentifier(param1),-2,200);
      }
      
      public function setTileCursorState(param1:int, param2:int) : void
      {
         var _loc4_:RoomObjectDataUpdateMessage = null;
         var _loc3_:IRoomObjectController = getTileCursor(param1);
         if(_loc3_ != null && _loc3_.getEventHandler() != null)
         {
            _loc4_ = new RoomObjectDataUpdateMessage(param2,null);
            _loc3_.getEventHandler().processUpdateMessage(_loc4_);
         }
      }
      
      public function toggleTileCursorVisibility(param1:int, param2:Boolean) : void
      {
         var _loc4_:RoomObjectTileCursorUpdateMessage = null;
         var _loc3_:IRoomObjectController = getTileCursor(param1);
         if(_loc3_ != null && _loc3_.getEventHandler() != null)
         {
            _loc4_ = new RoomObjectTileCursorUpdateMessage(null,0,param2,"",true);
            _loc3_.getEventHandler().processUpdateMessage(_loc4_);
         }
      }
      
      public function addObjectFurniture(param1:int, param2:int, param3:int, param4:IVector3d, param5:IVector3d, param6:int, param7:IStuffData, param8:Number = NaN, param9:int = -1, param10:int = 0, param11:int = 0, param12:String = "", param13:Boolean = true, param14:Boolean = true, param15:Number = -1) : Boolean
      {
         var _loc17_:FurnitureData = null;
         var _loc16_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc16_ != null)
         {
            _loc17_ = new FurnitureData(param2,param3,null,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15);
            _loc16_.addFurnitureData(_loc17_);
         }
         return true;
      }
      
      public function addObjectFurnitureByName(param1:int, param2:int, param3:String, param4:IVector3d, param5:IVector3d, param6:int, param7:IStuffData, param8:Number = NaN) : Boolean
      {
         var _loc10_:FurnitureData = null;
         var _loc9_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc9_ != null)
         {
            _loc10_ = new FurnitureData(param2,0,param3,param4,param5,param6,param7,param8,0);
            _loc9_.addFurnitureData(_loc10_);
         }
         return true;
      }
      
      private function addObjectFurnitureFromData(param1:int, param2:int, param3:FurnitureData) : Boolean
      {
         var _loc4_:RoomInstanceData = null;
         if(param3 == null)
         {
            _loc4_ = getRoomInstanceData(param1);
            if(_loc4_ != null)
            {
               param3 = _loc4_.getFurnitureDataWithId(param2);
            }
         }
         if(param3 == null)
         {
            return false;
         }
         var _loc6_:Boolean = false;
         var _loc9_:String = param3.type;
         if(_loc9_ == null)
         {
            _loc9_ = getFurnitureType(param3.typeId);
            _loc6_ = true;
         }
         var _loc7_:int = getFurnitureColorIndex(param3.typeId);
         var _loc8_:String = getRoomObjectAdURL(_loc9_);
         if(_loc9_ == null)
         {
            _loc9_ = "";
         }
         if(_windowManager.LilithCustomsInstance.OnAddFurniture(param3,_loc9_) == false)
         {
            return false;
         }
         var _loc10_:IRoomObjectController = createObjectFurniture(param1,param2,_loc9_);
         if(_loc10_ == null)
         {
            return false;
         }
         if(_loc10_ != null && _loc10_.getModelController() != null && _loc6_)
         {
            _loc10_.getModelController().setNumber("furniture_color",_loc7_,true);
            _loc10_.getModelController().setNumber("furniture_type_id",param3.typeId,true);
            _loc10_.getModelController().setString("furniture_ad_url",_loc8_,true);
            _loc10_.getModelController().setNumber("furniture_real_room_object",param3.realRoomObject ? 1 : 0,false);
            _loc10_.getModelController().setNumber("furniture_expiry_time",param3.expiryTime);
            _loc10_.getModelController().setNumber("furniture_expirty_timestamp",getTimer());
            _loc10_.getModelController().setNumber("furniture_usage_policy",param3.usagePolicy);
            _loc10_.getModelController().setNumber("furniture_owner_id",param3.ownerId);
            _loc10_.getModelController().setString("furniture_owner_name",param3.ownerName);
            _loc10_.getModelController().setNumber("furniture_extra",param3.extra);
         }
         if(!updateObjectFurniture(param1,param2,param3.loc,param3.dir,param3.state,param3.data,param3.extra))
         {
            return false;
         }
         if(param3.sizeZ >= 0)
         {
            if(!updateObjectFurnitureHeight(param1,param2,param3.sizeZ))
            {
               return false;
            }
         }
         if(events != null)
         {
            events.dispatchEvent(new RoomEngineObjectEvent("REOE_ADDED",param1,param2,10));
         }
         var _loc5_:ISelectedRoomObjectData = getPlacedObjectData(param1);
         if(_loc5_ && Math.abs(_loc5_.id) == param2 && _loc5_.category == 10)
         {
            selectRoomObject(param1,param2,10);
         }
         if(_loc10_.isInitialized() && param3.synchronized)
         {
            addObjectToTileMap(param1,_loc10_);
         }
         return true;
      }
      
      public function changeObjectState(param1:int, param2:int, param3:int) : void
      {
         var _loc6_:Number = NaN;
         var _loc5_:int = 0;
         var _loc4_:IStuffData = null;
         var _loc7_:RoomObjectDataUpdateMessage = null;
         var _loc8_:IRoomObjectController = getObject(getRoomIdentifier(param1),param2,param3);
         if(_loc8_ != null && _loc8_.getModelController() != null)
         {
            _loc6_ = Number(_loc8_.getModelController().getNumber("furniture_automatic_state_index"));
            if(isNaN(_loc6_))
            {
               _loc6_ = 1;
            }
            else
            {
               _loc6_ += 1;
            }
            _loc8_.getModelController().setNumber("furniture_automatic_state_index",_loc6_);
            _loc5_ = int(_loc8_.getModel().getNumber("furniture_data_format"));
            _loc4_ = UnknownHabboRoomObjectData1.getStuffDataWrapperForType(_loc5_);
            _loc4_.initializeFromRoomObjectModel(_loc8_.getModel());
            _loc7_ = new RoomObjectDataUpdateMessage(_loc6_,_loc4_);
            if(_loc8_.getEventHandler() != null)
            {
               _loc8_.getEventHandler().processUpdateMessage(_loc7_);
            }
         }
      }
      
      public function changeObjectModelData(param1:int, param2:int, param3:int, param4:String, param5:int) : Boolean
      {
         var _loc6_:RoomObjectModelDataUpdateMessage = null;
         var _loc7_:IRoomObjectController = getObject(getRoomIdentifier(param1),param2,param3);
         if(_loc7_ == null)
         {
            return false;
         }
         if(_loc7_ != null && _loc7_.getEventHandler() != null)
         {
            _loc6_ = new RoomObjectModelDataUpdateMessage(param4,param5);
            _loc7_.getEventHandler().processUpdateMessage(_loc6_);
         }
         return true;
      }
      
      public function updateObjectFurniture(param1:int, param2:int, param3:IVector3d, param4:IVector3d, param5:int, param6:IStuffData, param7:Number = NaN) : Boolean
      {
         var _loc10_:IRoomObjectController = getObjectFurniture(param1,param2);
         if(_loc10_ == null)
         {
            return false;
         }
         var _loc8_:RoomObjectUpdateMessage = new RoomObjectUpdateMessage(param3,param4);
         var _loc9_:RoomObjectDataUpdateMessage = new RoomObjectDataUpdateMessage(param5,param6,param7);
         if(_loc10_ != null && _loc10_.getEventHandler() != null)
         {
            _loc10_.getEventHandler().processUpdateMessage(_loc8_);
            _loc10_.getEventHandler().processUpdateMessage(_loc9_);
            events.dispatchEvent(new RoomEngineObjectEvent("REOE_UPDATED",param1,param2,10));
         }
         return true;
      }
      
      public function updateObjectFurnitureHeight(param1:int, param2:int, param3:Number) : Boolean
      {
         var _loc4_:RoomObjectHeightUpdateMessage = null;
         var _loc5_:IRoomObjectController = getObjectFurniture(param1,param2);
         if(_loc5_ == null)
         {
            return false;
         }
         if(_loc5_ != null && _loc5_.getEventHandler() != null)
         {
            _loc4_ = new RoomObjectHeightUpdateMessage(null,null,param3);
            _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         }
         return true;
      }
      
      public function updateObjectFurnitureLocation(param1:int, param2:int, param3:IVector3d, param4:IVector3d, param5:IVector3d, param6:Number = NaN, param7:Number = NaN, param8:Number = NaN) : Boolean
      {
         var _loc9_:RoomObjectMoveUpdateMessage = null;
         var _loc10_:IRoomObjectController = getObjectFurniture(param1,param2);
         if(_loc10_ == null)
         {
            return false;
         }
         if(_loc10_ != null && _loc10_.getEventHandler() != null)
         {
            _loc9_ = new RoomObjectMoveUpdateMessage(param3,param5,param4,param6,param5 != null,false,param7,param8);
            _loc10_.getEventHandler().processUpdateMessage(_loc9_);
         }
         return true;
      }
      
      public function updateObjectFurnitureExpiryTime(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc4_:IRoomObjectController = getObjectFurniture(param1,param2);
         if(_loc4_ == null)
         {
            return false;
         }
         _loc4_.getModelController().setNumber("furniture_expiry_time",param3);
         _loc4_.getModelController().setNumber("furniture_expirty_timestamp",getTimer());
         return true;
      }
      
      private function createObjectFurniture(param1:int, param2:int, param3:String) : IRoomObjectController
      {
         var _loc4_:int = 10;
         var _loc5_:IRoomObjectController = createObject(getRoomIdentifier(param1),param2,param3,_loc4_);
         applyInvisibleFurniState(param1,_loc5_);
         return _loc5_;
      }
      
      private function getObjectFurniture(param1:int, param2:int) : IRoomObjectController
      {
         return getObject(getRoomIdentifier(param1),param2,10);
      }
      
      public function disposeObjectFurniture(param1:int, param2:int, param3:int = -1, param4:Boolean = false) : void
      {
         var _loc14_:IRoomObject = null;
         var _loc12_:Point = null;
         var _loc9_:IRoomObjectModel = null;
         var _loc10_:* = false;
         var _loc11_:int = 0;
         var _loc7_:String = null;
         var _loc13_:int = 0;
         var _loc8_:IStuffData = null;
         var _loc5_:BitmapData = null;
         var _loc6_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc6_ != null)
         {
            _loc6_.getFurnitureDataWithId(param2);
         }
         if(_sessionDataManager && param3 == _sessionDataManager.userId && !FurniId.isBuilderClubId(param2) && !FurniId.isTempId(param2))
         {
            _loc14_ = getRoomObject(param1,param2,10);
            if(_loc14_)
            {
               _loc12_ = getRoomObjectScreenLocation(param1,param2,10,UnknownVarFromRoomEngine_Int_1);
               if(_loc12_)
               {
                  _loc9_ = _loc14_.getModel();
                  _loc10_ = _loc9_.getNumber("furniture_disable_picking_animation") == 1;
                  if(!_loc10_)
                  {
                     _loc11_ = _loc9_.getNumber("furniture_type_id");
                     _loc7_ = _loc9_.getString("furniture_extras");
                     _loc13_ = _loc9_.getNumber("furniture_data_format");
                     _loc8_ = UnknownHabboRoomObjectData1.getStuffDataWrapperForType(_loc13_);
                     _loc5_ = getFurnitureIcon(_loc11_,null,_loc7_,_loc8_).data;
                     if(_loc5_)
                     {
                        _toolbar.createTransitionToIcon("HTIE_ICON_INVENTORY",_loc5_,_loc12_.x,_loc12_.y);
                     }
                  }
               }
            }
         }
         disposeObject(param1,param2,10);
         removeButtonMouseCursorOwner(param1,10,param2);
         if(param4)
         {
            refreshTileObjectMap(param1,"RoomEngine.disposeObjectFurniture()");
         }
      }
      
      public function addObjectWallItem(param1:int, param2:int, param3:int, param4:IVector3d, param5:IVector3d, param6:int, param7:String, param8:int = 0, param9:int = 0, param10:String = "", param11:int = -1, param12:Boolean = true) : Boolean
      {
         var _loc15_:LegacyStuffData = null;
         var _loc14_:FurnitureData = null;
         var _loc13_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc13_ != null)
         {
            _loc15_ = new LegacyStuffData();
            _loc15_.setString(param7);
            _loc14_ = new FurnitureData(param2,param3,null,param4,param5,param6,_loc15_,NaN,param11,param8,param9,param10,true,param12);
            _loc13_.addWallItemData(_loc14_);
         }
         return true;
      }
      
      private function addObjectWallItemFromData(param1:int, param2:int, param3:FurnitureData) : Boolean
      {
         var _loc4_:RoomInstanceData = null;
         if(param3 == null)
         {
            _loc4_ = getRoomInstanceData(param1);
            if(_loc4_ != null)
            {
               param3 = _loc4_.getWallItemDataWithId(param2);
            }
         }
         if(param3 == null)
         {
            return false;
         }
         var _loc6_:String = "";
         if(param3.data != null)
         {
            _loc6_ = param3.data.getLegacyString();
         }
         var _loc9_:String = getWallItemType(param3.typeId,_loc6_);
         var _loc7_:int = getWallItemColorIndex(param3.typeId);
         var _loc8_:String = getRoomObjectAdURL(_loc9_);
         if(_loc9_ == null)
         {
            _loc9_ = "";
         }
         if(_windowManager.LilithCustomsInstance.OnAddFurniture(param3,_loc9_) == false)
         {
            return false;
         }
         var _loc10_:IRoomObjectController = createObjectWallItem(param1,param2,_loc9_);
         if(_loc10_ == null)
         {
            return false;
         }
         if(_loc10_ != null && _loc10_.getModelController() != null)
         {
            _loc10_.getModelController().setNumber("furniture_color",_loc7_,false);
            _loc10_.getModelController().setNumber("furniture_type_id",param3.typeId,true);
            _loc10_.getModelController().setString("furniture_ad_url",_loc8_,true);
            _loc10_.getModelController().setNumber("furniture_real_room_object",param3.realRoomObject ? 1 : 0,false);
            _loc10_.getModelController().setNumber("object_accurate_z_value",1,true);
            _loc10_.getModelController().setNumber("furniture_usage_policy",param3.usagePolicy);
            _loc10_.getModelController().setNumber("furniture_expiry_time",param3.expiryTime);
            _loc10_.getModelController().setNumber("furniture_expirty_timestamp",getTimer());
            _loc10_.getModelController().setNumber("furniture_owner_id",param3.ownerId);
            _loc10_.getModelController().setString("furniture_owner_name",param3.ownerName);
            _loc10_.getModelController().setNumber("furniture_extra",param3.extra);
         }
         _loc6_ = "";
         if(param3.data != null)
         {
            _loc6_ = param3.data.getLegacyString();
         }
         if(!updateObjectWallItem(param1,param2,param3.loc,param3.dir,param3.state,_loc6_))
         {
            return false;
         }
         if(events != null)
         {
            events.dispatchEvent(new RoomEngineObjectEvent("REOE_ADDED",param1,param2,20));
         }
         var _loc5_:ISelectedRoomObjectData = getPlacedObjectData(param1);
         if(_loc5_ && _loc5_.id == param2 && _loc5_.category == 20)
         {
            selectRoomObject(param1,param2,20);
         }
         return true;
      }
      
      public function updateObjectWallItem(param1:int, param2:int, param3:IVector3d, param4:IVector3d, param5:int, param6:String) : Boolean
      {
         var _loc10_:IRoomObjectController = getObjectWallItem(param1,param2);
         if(_loc10_ == null)
         {
            return false;
         }
         var _loc8_:RoomObjectUpdateMessage = new RoomObjectUpdateMessage(param3,param4);
         var _loc7_:LegacyStuffData = new LegacyStuffData();
         _loc7_.setString(param6);
         var _loc9_:RoomObjectDataUpdateMessage = new RoomObjectDataUpdateMessage(param5,_loc7_);
         if(_loc10_ != null && _loc10_.getEventHandler() != null)
         {
            _loc10_.getEventHandler().processUpdateMessage(_loc8_);
            _loc10_.getEventHandler().processUpdateMessage(_loc9_);
         }
         updateObjectRoomWindow(param1,param2);
         return true;
      }
      
      public function updateObjectWallItemState(param1:int, param2:int, param3:int, param4:String) : Boolean
      {
         var _loc7_:IRoomObjectController = getObjectWallItem(param1,param2);
         if(_loc7_ == null)
         {
            return false;
         }
         var _loc5_:LegacyStuffData = new LegacyStuffData();
         _loc5_.setString(param4);
         var _loc6_:RoomObjectDataUpdateMessage = new RoomObjectDataUpdateMessage(param3,_loc5_);
         if(_loc7_ != null && _loc7_.getEventHandler() != null)
         {
            _loc7_.getEventHandler().processUpdateMessage(_loc6_);
         }
         return true;
      }
      
      public function updateObjectRoomWindow(param1:int, param2:int, param3:Boolean = true) : void
      {
         var _loc5_:String = null;
         var _loc4_:IVector3d = null;
         var _loc7_:String = "20_" + param2;
         var _loc6_:RoomObjectRoomMaskUpdateMessage = null;
         var _loc9_:IRoomObjectController = getObjectWallItem(param1,param2);
         if(_loc9_ != null)
         {
            if(_loc9_.getModel() != null)
            {
               if(_loc9_.getModel().getNumber("furniture_uses_plane_mask") > 0)
               {
                  _loc5_ = _loc9_.getModel().getString("furniture_plane_mask_type");
                  _loc4_ = _loc9_.getLocation();
                  if(param3)
                  {
                     _loc6_ = new RoomObjectRoomMaskUpdateMessage("RORMUM_ADD_MASK",_loc7_,_loc5_,_loc4_);
                  }
                  else
                  {
                     _loc6_ = new RoomObjectRoomMaskUpdateMessage("RORMUM_REMOVE_MASK",_loc7_);
                  }
               }
            }
         }
         else
         {
            _loc6_ = new RoomObjectRoomMaskUpdateMessage("RORMUM_REMOVE_MASK",_loc7_);
         }
         var _loc8_:IRoomObjectController = getObjectRoom(param1);
         if(_loc8_ != null && _loc8_.getEventHandler() != null && _loc6_ != null)
         {
            _loc8_.getEventHandler().processUpdateMessage(_loc6_);
         }
      }
      
      public function updateObjectWallItemData(param1:int, param2:int, param3:String) : Boolean
      {
         var _loc5_:IRoomObjectController = getObjectWallItem(param1,param2);
         if(_loc5_ == null)
         {
            return false;
         }
         var _loc4_:RoomObjectItemDataUpdateMessage = new RoomObjectItemDataUpdateMessage(param3);
         if(_loc5_ != null && _loc5_.getEventHandler() != null)
         {
            _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         }
         return true;
      }
      
      private function createObjectWallItem(param1:int, param2:int, param3:String) : IRoomObjectController
      {
         var _loc4_:int = 20;
         var _loc5_:IRoomObjectController = createObject(getRoomIdentifier(param1),param2,param3,_loc4_);
         applyInvisibleFurniState(param1,_loc5_);
         return _loc5_;
      }
      
      private function applyInvisibleFurniState(param1:int, param2:IRoomObjectController) : void
      {
         if(param2 == null)
         {
            return;
         }
         var _loc3_:IRoomObjectModelController = param2.getModelController();
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Boolean = isRoomVariableActive(param1,"invisible_furni");
         _loc3_.setNumber("furniture_invisible_layer",_loc4_ ? 1 : 0);
      }
      
      private function getObjectWallItem(param1:int, param2:int) : IRoomObjectController
      {
         return getObject(getRoomIdentifier(param1),param2,20);
      }
      
      public function updateObjectWallItemLocation(param1:int, param2:int, param3:IVector3d, param4:IVector3d = null, param5:Number = NaN) : Boolean
      {
         var _loc6_:RoomObjectMoveUpdateMessage = null;
         var _loc7_:IRoomObjectController = getObjectWallItem(param1,param2);
         if(_loc7_ == null)
         {
            return false;
         }
         if(_loc7_.getEventHandler() != null)
         {
            _loc6_ = new RoomObjectMoveUpdateMessage(param3,param4,null,param5,param4 != null);
            _loc7_.getEventHandler().processUpdateMessage(_loc6_);
         }
         updateObjectRoomWindow(param1,param2);
         return true;
      }
      
      public function updateObjectWallItemExpiryTime(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc4_:IRoomObjectController = getObjectWallItem(param1,param2);
         if(_loc4_ == null)
         {
            return false;
         }
         _loc4_.getModelController().setNumber("furniture_expiry_time",param3);
         _loc4_.getModelController().setNumber("furniture_expirty_timestamp",getTimer());
         return true;
      }
      
      public function disposeObjectWallItem(param1:int, param2:int, param3:int = -1) : void
      {
         var _loc10_:IRoomObject = null;
         var _loc6_:Point = null;
         var _loc8_:IRoomObjectModel = null;
         var _loc9_:int = 0;
         var _loc7_:String = null;
         var _loc4_:BitmapData = null;
         var _loc5_:RoomInstanceData = getRoomInstanceData(param1);
         if(_loc5_ != null)
         {
            _loc5_.getWallItemDataWithId(param2);
         }
         if(_sessionDataManager && param3 == _sessionDataManager.userId && !FurniId.isBuilderClubId(param2) && !FurniId.isTempId(param2))
         {
            _loc10_ = getRoomObject(param1,param2,20);
            if(_loc10_ && _loc10_.getType().indexOf("post_it") == -1 && _loc10_.getType().indexOf("external_image_wallitem") == -1)
            {
               _loc6_ = getRoomObjectScreenLocation(param1,param2,20,UnknownVarFromRoomEngine_Int_1);
               _loc8_ = _loc10_.getModel();
               _loc9_ = _loc8_.getNumber("furniture_type_id");
               _loc7_ = _loc8_.getString("furniture_data");
               _loc4_ = getWallItemIcon(_loc9_,null,_loc7_).data;
               if(_toolbar && _loc6_)
               {
                  _toolbar.createTransitionToIcon("HTIE_ICON_INVENTORY",_loc4_,_loc6_.x,_loc6_.y);
               }
            }
         }
         disposeObject(param1,param2,20);
         updateObjectRoomWindow(param1,param2,false);
         removeButtonMouseCursorOwner(param1,20,param2);
      }
      
      public function addObjectUser(param1:int, param2:int, param3:IVector3d, param4:IVector3d, param5:Number, param6:int, param7:String = null) : Boolean
      {
         var _loc10_:RoomObjectUpdateMessage = null;
         var _loc8_:RoomObjectAvatarFigureUpdateMessage = null;
         var _loc9_:RoomObjectAvatarBlockedUpdateMessage = null;
         if(getObjectUser(param1,param2) != null)
         {
            return false;
         }
         var _loc11_:String = RoomObjectUserTypes.getName(param6);
         if(_loc11_ == "pet")
         {
            _loc11_ = getPetType(param7);
         }
         var _loc12_:IRoomObjectController = createObjectUser(param1,param2,_loc11_);
         if(_loc12_ == null)
         {
            return false;
         }
         if(_loc12_ != null && _loc12_.getEventHandler() != null)
         {
            _loc10_ = new RoomObjectAvatarUpdateMessage(fixedUserLocation(param1,param3),null,param4,param5,false,0);
            _loc12_.getEventHandler().processUpdateMessage(_loc10_);
            if(param7 != null)
            {
               _loc8_ = new RoomObjectAvatarFigureUpdateMessage(param7);
               _loc12_.getEventHandler().processUpdateMessage(_loc8_);
            }
            if(_loc11_ == "user" && userIsBlocked(param1,param2))
            {
               _loc9_ = new RoomObjectAvatarBlockedUpdateMessage(true);
               _loc12_.getEventHandler().processUpdateMessage(_loc9_);
            }
         }
         if(events != null)
         {
            events.dispatchEvent(new RoomEngineObjectEvent("REOE_ADDED",param1,param2,100));
         }
         return true;
      }
      
      public function addObjectSnowWar(param1:int, param2:int, param3:IVector3d, param4:int) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:RoomObjectUpdateMessage = null;
         if(param4 == 201)
         {
            _loc5_ = "game_snowball";
         }
         else if(param4 == 202)
         {
            _loc5_ = "game_snowsplash";
         }
         var _loc7_:IRoomObjectController = createObjectSnowWar(param1,param2,_loc5_,param4);
         if(!_loc7_)
         {
            return false;
         }
         if(_loc7_.getEventHandler())
         {
            _loc6_ = new RoomObjectUpdateMessage(param3,null);
            _loc7_.getEventHandler().processUpdateMessage(_loc6_);
         }
         return true;
      }
      
      public function addObjectSnowSplash(param1:int, param2:int, param3:IVector3d) : Boolean
      {
         var _loc4_:RoomObjectUpdateMessage = null;
         _roomManager.addObjectUpdateCategory(202);
         var _loc5_:IRoomObjectController = createObjectSnowWar(param1,param2,"game_snowsplash",202);
         if(!_loc5_)
         {
            return false;
         }
         if(_loc5_.getEventHandler())
         {
            _loc4_ = new RoomObjectUpdateMessage(param3,null);
            _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         }
         return true;
      }
      
      public function updateObjectUser(param1:int, param2:int, param3:IVector3d, param4:IVector3d, param5:Boolean = false, param6:Number = 0, param7:IVector3d = null, param8:Number = NaN, param9:Number = NaN, param10:Boolean = false, param11:Number = NaN) : Boolean
      {
         var _loc13_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc13_ == null || _loc13_.getEventHandler() == null || _loc13_.getModel() == null)
         {
            return false;
         }
         if(param3 == null)
         {
            param3 = _loc13_.getLocation();
         }
         if(param7 == null)
         {
            param7 = _loc13_.getDirection();
         }
         if(isNaN(param8))
         {
            param8 = Number(_loc13_.getModel().getNumber("head_direction"));
         }
         var _loc12_:RoomObjectUpdateMessage = new RoomObjectAvatarUpdateMessage(fixedUserLocation(param1,param3),fixedUserLocation(param1,param4),param7,param8,param5,param6,param9,param10,param11);
         _loc13_.getEventHandler().processUpdateMessage(_loc12_);
         if(roomSessionManager && roomSessionManager.getSession(param1) && param2 == roomSessionManager.getSession(param1).ownUserRoomId)
         {
            _roomObjectFactory.events.dispatchEvent(new RoomToObjectOwnAvatarMoveEvent("ROAME_MOVE_TO",param4));
         }
         return true;
      }
      
      public function updateObjectUserDir(param1:int, param2:int, param3:IVector3d, param4:Number) : Boolean
      {
         var _loc6_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc6_ == null || _loc6_.getEventHandler() == null || _loc6_.getModel() == null)
         {
            return false;
         }
         var _loc5_:RoomObjectUpdateMessage = new RoomObjectAvatarDirectionUpdateMessage(null,param3,param4);
         _loc6_.getEventHandler().processUpdateMessage(_loc5_);
         return true;
      }
      
      public function updateObjectSnowWar(param1:int, param2:int, param3:IVector3d, param4:int) : Boolean
      {
         var _loc5_:IRoomObjectController = getObject(getRoomIdentifier(param1),param2,param4);
         var _loc6_:RoomObjectUpdateMessage = new RoomObjectUpdateMessage(param3,null);
         _loc5_.getEventHandler().processUpdateMessage(_loc6_);
         return true;
      }
      
      public function disposeObjectSnowWar(param1:int, param2:int, param3:int) : void
      {
         disposeObject(param1,param2,param3);
      }
      
      public function updateObjectUserFlatControl(param1:int, param2:int, param3:String) : Boolean
      {
         var _loc5_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc5_ == null || _loc5_.getEventHandler() == null)
         {
            return false;
         }
         var _loc4_:RoomObjectUpdateStateMessage = new RoomObjectAvatarFlatControlUpdateMessage(param3);
         _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         return true;
      }
      
      public function updateObjectUserOwnUserAvatar(param1:int, param2:int) : Boolean
      {
         var _loc3_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc3_ == null || _loc3_.getEventHandler() == null)
         {
            return false;
         }
         var _loc4_:RoomObjectUpdateMessage = new RoomObjectAvatarOwnMessage();
         _loc3_.getEventHandler().processUpdateMessage(_loc4_);
         return true;
      }
      
      public function updateObjectUserBlocked(param1:int, param2:int, param3:Boolean) : Boolean
      {
         var _loc5_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc5_ == null || _loc5_.getEventHandler() == null)
         {
            return false;
         }
         var _loc4_:RoomObjectAvatarBlockedUpdateMessage = new RoomObjectAvatarBlockedUpdateMessage(param3);
         _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         return true;
      }
      
      public function updateObjectUserFigure(param1:int, param2:int, param3:String, param4:String = null, param5:String = null, param6:Boolean = false) : Boolean
      {
         var _loc8_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc8_ == null || _loc8_.getEventHandler() == null)
         {
            return false;
         }
         var _loc7_:RoomObjectUpdateStateMessage = new RoomObjectAvatarFigureUpdateMessage(param3,param4,param5,param6);
         _loc8_.getEventHandler().processUpdateMessage(_loc7_);
         return true;
      }
      
      private function userIsBlocked(param1:int, param2:int) : Boolean
      {
         var _loc3_:IUserData = null;
         var _loc4_:IRoomSession = _roomSessionManager.getSession(param1);
         if(_loc4_ && _loc4_.userDataManager)
         {
            _loc3_ = _loc4_.userDataManager.getUserDataByIndex(param2);
            if(_loc3_ != null && _sessionDataManager.isBlocked(_loc3_.webID))
            {
               return true;
            }
         }
         return false;
      }
      
      public function updateObjectUserAction(param1:int, param2:int, param3:String, param4:int, param5:String = null) : Boolean
      {
         var _loc7_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc7_ == null || _loc7_.getEventHandler() == null)
         {
            return false;
         }
         if(userIsBlocked(param1,param2))
         {
            return false;
         }
         var _loc6_:RoomObjectUpdateStateMessage = null;
         switch(param3)
         {
            case "figure_talk":
               _loc6_ = new RoomObjectAvatarChatUpdateMessage(param4);
               break;
            case "figure_sleep":
               _loc6_ = new RoomObjectAvatarSleepUpdateMessage(param4 != 0);
               break;
            case "figure_is_typing":
               _loc6_ = new RoomObjectAvatarTypingUpdateMessage(param4 != 0);
               break;
            case "figure_is_muted":
               _loc6_ = new RoomObjectAvatarMutedUpdateMessage(param4 != 0);
               break;
            case "figure_carry_object":
               _loc6_ = new RoomObjectAvatarCarryObjectUpdateMessage(param4,param5);
               break;
            case "figure_use_object":
               _loc6_ = new RoomObjectAvatarUseObjectUpdateMessage(param4);
               break;
            case "figure_dance":
               _loc6_ = new RoomObjectAvatarDanceUpdateMessage(param4);
               break;
            case "figure_gained_experience":
               _loc6_ = new RoomObjectAvatarExperienceUpdateMessage(param4);
               break;
            case "figure_number_value":
               _loc6_ = new RoomObjectAvatarPlayerValueUpdateMessage(param4);
               break;
            case "figure_sign":
               _loc6_ = new RoomObjectAvatarSignUpdateMessage(param4);
               break;
            case "figure_expression":
               _loc6_ = new RoomObjectAvatarExpressionUpdateMessage(param4);
               break;
            case "figure_is_playing_game":
               _loc6_ = new RoomObjectAvatarPlayingGameMessage(param4 != 0);
               break;
            case "figure_guide_status":
               _loc6_ = new RoomObjectAvatarGuideStatusUpdateMessage(param4);
               break;
            case "figure_habbicon":
               _loc6_ = new RoomObjectAvatarHabbiconUpdateMessage(param4);
         }
         _loc7_.getEventHandler().processUpdateMessage(_loc6_);
         return true;
      }
      
      public function updateObjectUserPosture(param1:int, param2:int, param3:String, param4:String = "") : Boolean
      {
         var _loc6_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc6_ == null || _loc6_.getEventHandler() == null)
         {
            return false;
         }
         var _loc5_:RoomObjectUpdateStateMessage = new RoomObjectAvatarPostureUpdateMessage(param3,param4);
         _loc6_.getEventHandler().processUpdateMessage(_loc5_);
         return true;
      }
      
      public function updateObjectUserGesture(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc5_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc5_ == null || _loc5_.getEventHandler() == null)
         {
            return false;
         }
         var _loc4_:RoomObjectUpdateStateMessage = new RoomObjectAvatarGestureUpdateMessage(param3);
         _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         return true;
      }
      
      public function updateObjectPetGesture(param1:int, param2:int, param3:String) : Boolean
      {
         var _loc5_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc5_ == null || _loc5_.getEventHandler() == null)
         {
            return false;
         }
         var _loc4_:RoomObjectUpdateStateMessage = new RoomObjectAvatarPetGestureUpdateMessage(param3);
         _loc5_.getEventHandler().processUpdateMessage(_loc4_);
         return true;
      }
      
      public function updateObjectUserEffect(param1:int, param2:int, param3:int, param4:int = 0) : Boolean
      {
         var _loc5_:IRoomObjectController = getObjectUser(param1,param2);
         if(_loc5_ == null || _loc5_.getEventHandler() == null)
         {
            return false;
         }
         _loc5_.getEventHandler().processUpdateMessage(new RoomObjectAvatarEffectUpdateMessage(param3,param4));
         return true;
      }
      
      private function createObjectUser(param1:int, param2:int, param3:String) : IRoomObjectController
      {
         var _loc4_:int = 100;
         return createObject(getRoomIdentifier(param1),param2,param3,_loc4_);
      }
      
      private function createObjectSnowWar(param1:int, param2:int, param3:String, param4:int) : IRoomObjectController
      {
         return createObject(getRoomIdentifier(param1),param2,param3,param4);
      }
      
      private function getObjectUser(param1:int, param2:int) : IRoomObjectController
      {
         return getObject(getRoomIdentifier(param1),param2,100);
      }
      
      public function disposeObjectUser(param1:int, param2:int) : void
      {
         disposeObject(param1,param2,100);
      }
      
      private function createObject(param1:String, param2:int, param3:String, param4:int) : IRoomObjectController
      {
         var _loc5_:IRoomInstance = _roomManager.getRoom(param1);
         if(_loc5_ == null)
         {
            return null;
         }
         var _loc6_:IRoomObjectController = null;
         return _loc5_.createRoomObject(param2,param3,param4) as IRoomObjectController;
      }
      
      private function getObject(param1:String, param2:int, param3:int) : IRoomObjectController
      {
         var _loc4_:IRoomInstance = null;
         if(_roomManager != null)
         {
            _loc4_ = _roomManager.getRoom(param1);
         }
         if(_loc4_ == null)
         {
            return null;
         }
         var _loc5_:IRoomObjectController = null;
         _loc5_ = _loc4_.getObject(param2,param3) as IRoomObjectController;
         if(_loc5_ == null)
         {
            if(param3 == 10)
            {
               addObjectFurnitureFromData(getRoomId(param1),param2,null);
               _loc5_ = _loc4_.getObject(param2,param3) as IRoomObjectController;
            }
            else if(param3 == 20)
            {
               addObjectWallItemFromData(getRoomId(param1),param2,null);
               _loc5_ = _loc4_.getObject(param2,param3) as IRoomObjectController;
            }
         }
         return _loc5_;
      }
      
      private function disposeObject(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:IRoomInstance = null;
         if(_roomManager != null)
         {
            _loc4_ = getRoom(param1);
            if(_loc4_ == null)
            {
               return;
            }
            if(_loc4_.disposeObject(param2,param3))
            {
               if(events != null)
               {
                  events.dispatchEvent(new RoomEngineObjectEvent("REOE_REMOVED",param1,param2,param3));
               }
            }
         }
      }
      
      private function roomObjectEventHandler(param1:RoomObjectEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(_eventHandler != null)
         {
            _loc2_ = getRoomObjectRoomIdentifier(param1.object);
            if(_loc2_ != null)
            {
               _loc3_ = getRoomId(_loc2_);
               _eventHandler.handleRoomObjectEvent(param1,_loc3_);
            }
         }
      }
      
      private function getRoomObjectRoomIdentifier(param1:IRoomObject) : String
      {
         if(param1 != null && param1.getModel() != null)
         {
            return param1.getModel().getString("object_room_id");
         }
         return null;
      }
      
      public function createScreenShot(param1:int, param2:int, param3:String) : void
      {
         var _loc10_:ByteArray = null;
         var _loc7_:FileReference = null;
         var _loc5_:Date = null;
         var _loc6_:String = null;
         var _loc4_:RegExp = /[:\/\\\*\?"<>\|%]/g;
         param3 = param3.replace(_loc4_,"");
         var _loc9_:IRoomRenderingCanvas = getRoomCanvas(param1,param2);
         if(!_loc9_)
         {
            return;
         }
         var _loc8_:BitmapData = _loc9_.takeScreenShot();
         if(PlayerVersionCheck.isVersionAtLeast(11,3))
         {
         }
         if(_loc10_ == null)
         {
            _loc10_ = PNGEncoder.encode(_loc8_);
         }
         try
         {
            _loc7_ = new FileReference();
            _loc7_.save(_loc10_,param3);
         }
         catch(error:Error)
         {
            _loc5_ = new Date();
            _loc6_ = [_loc5_.getFullYear(),_loc5_.getMonth(),_loc5_.getDate()].join("-") + " " + [_loc5_.getHours(),_loc5_.getMinutes(),_loc5_.getSeconds()].join(".");
            param3 = "Habbo " + _loc6_;
            _loc7_ = new FileReference();
            _loc7_.save(_loc10_,param3);
         }
      }
      
      public function purgeRoomContent() : void
      {
         if(_roomContentLoader)
         {
            _roomContentLoader.purge();
         }
      }
      
      public function getFurnitureIconUrl(param1:int) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = "";
         if(_roomContentLoader != null)
         {
            _loc3_ = _roomContentLoader.getActiveObjectType(param1);
            _loc2_ = String(_roomContentLoader.getActiveObjectColorIndex(param1));
         }
         return _roomContentLoader.getObjectUrl(_loc3_,_loc2_);
      }
      
      public function getFurnitureIcon(param1:int, param2:UnknownIHabboRoom1, param3:String = null, param4:IStuffData = null, param5:Boolean = false) : UnknownHabboRoom1
      {
         return getFurnitureImage(param1,new Vector3d(),1,param2,0,param3,-1,-1,param4,param5);
      }
      
      public function getWallItemIconUrl(param1:int, param2:String = null) : String
      {
         var _loc4_:String = null;
         var _loc3_:String = "";
         if(_roomContentLoader != null)
         {
            _loc4_ = _roomContentLoader.getWallItemType(param1,param2);
            _loc3_ = String(_roomContentLoader.getWallItemColorIndex(param1));
         }
         return _roomContentLoader.getObjectUrl(_loc4_,_loc3_);
      }
      
      public function getWallItemIcon(param1:int, param2:UnknownIHabboRoom1, param3:String = null) : UnknownHabboRoom1
      {
         return getWallItemImage(param1,new Vector3d(),1,param2,0,param3);
      }
      
      public function getFurnitureImage(param1:int, param2:IVector3d, param3:int, param4:UnknownIHabboRoom1, param5:uint = 0, param6:String = null, param7:int = -1, param8:int = -1, param9:IStuffData = null, param10:Boolean = false) : UnknownHabboRoom1
      {
         var _loc12_:String = null;
         var _loc11_:String = "";
         if(_roomContentLoader != null)
         {
            _loc12_ = _roomContentLoader.getActiveObjectType(param1);
            _loc11_ = String(_roomContentLoader.getActiveObjectColorIndex(param1));
         }
         if(param3 == 1 && param4 != null && !param10)
         {
            return getGenericRoomObjectThumbnail(_loc12_,_loc11_,param4,param6,param9);
         }
         return getGenericRoomObjectImage(_loc12_,_loc11_,param2,param3,param4,param5,param6,param9,param7,param8);
      }
      
      public function getPetImage(param1:int, param2:int, param3:int, param4:IVector3d, param5:int, param6:UnknownIHabboRoom1, param7:Boolean = true, param8:uint = 0, param9:Array = null, param10:String = null) : UnknownHabboRoom1
      {
         var _loc11_:String = null;
         var _loc13_:String = param1 + " " + param2 + " " + param3.toString(16);
         if(!param7)
         {
            _loc13_ += " head";
         }
         if(param9 != null)
         {
            _loc13_ += " " + param9.length;
            for each(var _loc12_ in param9)
            {
               _loc13_ += " " + _loc12_.layerId + " " + _loc12_.partId + " " + _loc12_.paletteId;
            }
         }
         if(_roomContentLoader != null)
         {
            _loc11_ = _roomContentLoader.getPetType(param1);
         }
         return getGenericRoomObjectImage(_loc11_,_loc13_,param4,param5,param6,param8,null,null,-1,-1,param10);
      }
      
      public function getWallItemImage(param1:int, param2:IVector3d, param3:int, param4:UnknownIHabboRoom1, param5:uint = 0, param6:String = null, param7:int = -1, param8:int = -1) : UnknownHabboRoom1
      {
         var _loc10_:String = null;
         var _loc9_:String = "";
         if(_roomContentLoader != null)
         {
            _loc10_ = _roomContentLoader.getWallItemType(param1,param6);
            _loc9_ = String(_roomContentLoader.getWallItemColorIndex(param1));
         }
         if(param3 == 1 && param4 != null)
         {
            return getGenericRoomObjectThumbnail(_loc10_,_loc9_,param4,param6,null);
         }
         return getGenericRoomObjectImage(_loc10_,_loc9_,param2,param3,param4,param5,param6,null,param7,param8);
      }
      
      public function getRoomImage(param1:String, param2:String, param3:String, param4:int, param5:UnknownIHabboRoom1, param6:String = null) : UnknownHabboRoom1
      {
         if(param1 == null)
         {
            param1 = "";
         }
         if(param2 == null)
         {
            param2 = "";
         }
         if(param3 == null)
         {
            param3 = "";
         }
         var _loc8_:String = "room";
         var _loc7_:String = param1 + "\n" + param2 + "\n" + param3 + "\n";
         if(param6 != null)
         {
            _loc7_ += param6;
         }
         return getGenericRoomObjectImage(_loc8_,_loc7_,new Vector3d(),param4,param5);
      }
      
      public function getRoomObjectImage(param1:int, param2:int, param3:int, param4:IVector3d, param5:int, param6:UnknownIHabboRoom1, param7:uint = 0) : UnknownHabboRoom1
      {
         var _loc9_:String = null;
         var _loc16_:IRoomObject = null;
         var _loc8_:int = 0;
         var _loc10_:String = null;
         var _loc13_:String = "";
         var _loc14_:IStuffData = null;
         var _loc15_:int = -1;
         var _loc12_:String = getRoomIdentifier(param1);
         var _loc11_:IRoomInstance = _roomManager.getRoom(_loc12_);
         if(_loc11_ != null)
         {
            _loc16_ = _loc11_.getObject(param2,param3);
            if(_loc16_ != null && _loc16_.getModel() != null)
            {
               _loc10_ = _loc16_.getType();
               _loc15_ = _loc16_.getId();
               switch(param3)
               {
                  case 10:
                  case 20:
                     _loc13_ = String(_loc16_.getModel().getNumber("furniture_color"));
                     _loc9_ = _loc16_.getModel().getString("furniture_extras");
                     _loc8_ = _loc16_.getModel().getNumber("furniture_data_format");
                     if(_loc8_ != 0)
                     {
                        _loc14_ = UnknownHabboRoomObjectData1.getStuffDataWrapperForType(_loc8_);
                        _loc14_.initializeFromRoomObjectModel(_loc16_.getModel());
                     }
                     break;
                  case 100:
                     _loc13_ = _loc16_.getModel().getString("figure");
               }
            }
         }
         return getGenericRoomObjectImage(_loc10_,_loc13_,param4,param5,param6,param7,_loc9_,_loc14_,-1,-1,null,_loc15_);
      }
      
      private function initializeRoomForGettingImage(param1:IRoomObjectController, param2:String) : void
      {
         var _loc3_:Array = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc12_:String = null;
         var _loc4_:String = null;
         var _loc11_:int = 0;
         var _loc5_:RoomPlaneParser = null;
         var _loc14_:int = 0;
         var _loc13_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:RoomObjectRoomMaskUpdateMessage = null;
         var _loc10_:String = null;
         if(param2 != null)
         {
            _loc3_ = param2.split("\n");
            if(_loc3_.length >= 3)
            {
               _loc8_ = _loc3_[0];
               _loc9_ = _loc3_[1];
               _loc12_ = _loc3_[2];
               _loc4_ = _loc3_[3];
               _loc11_ = 6;
               _loc5_ = new RoomPlaneParser();
               _loc5_.initializeTileMap(_loc11_ + 2,_loc11_ + 2);
               _loc14_ = 1;
               while(_loc14_ < 1 + _loc11_)
               {
                  _loc13_ = 1;
                  while(_loc13_ < 1 + _loc11_)
                  {
                     _loc5_.setTileHeight(_loc13_,_loc14_,0);
                     _loc13_++;
                  }
                  _loc14_++;
               }
               _loc5_.wallHeight = _loc11_;
               _loc5_.initializeFromTileData();
               _loc6_ = _loc5_.getXML();
               param1.getEventHandler().initialize(_loc6_);
               param1.getModelController().setString("room_floor_type",_loc8_);
               param1.getModelController().setString("room_wall_type",_loc9_);
               param1.getModelController().setString("room_landscape_type",_loc12_);
               if(_loc4_ != null)
               {
                  _loc7_ = null;
                  _loc10_ = "20_1";
                  _loc7_ = new RoomObjectRoomMaskUpdateMessage("RORMUM_ADD_MASK",_loc10_,_loc4_,new Vector3d(2.5,0.5,2));
                  param1.getEventHandler().processUpdateMessage(_loc7_);
               }
               _loc5_.dispose();
            }
         }
      }
      
      public function getGenericRoomObjectThumbnail(param1:String, param2:String, param3:UnknownIHabboRoom1, param4:String = null, param5:IStuffData = null) : UnknownHabboRoom1
      {
         var _loc6_:AssetCallbackInfo = null;
         var _loc13_:BitmapDataAsset = null;
         var _loc9_:BitmapData = null;
         var _loc8_:UnknownHabboRoom1 = new UnknownHabboRoom1();
         _loc8_.id = -1;
         if(!_isInitialized || param1 == null)
         {
            return _loc8_;
         }
         var _loc7_:IRoomInstance = _roomManager.getRoom("temporary_room");
         if(_loc7_ == null)
         {
            _loc7_ = _roomManager.createRoom("temporary_room",null);
            if(_loc7_ == null)
            {
               return _loc8_;
            }
         }
         var _loc11_:int = UnknownVarFromRoomEngine_NumberBank_2.reserveNumber();
         var _loc12_:int = getRoomObjectCategory(param1);
         if(_loc11_ < 0)
         {
            return _loc8_;
         }
         _loc11_ += 1;
         _loc8_.id = _loc11_;
         _loc8_.data = null;
         var _loc10_:String = [param1,param2].join("_");
         if(!assets.hasAsset(_loc10_) && param3 != null)
         {
            _loc6_ = UnknownVarFromRoomEngine_Map_2.getValue(_loc10_);
            if(_loc6_ == null)
            {
               _loc6_ = new AssetCallbackInfo(_loc11_);
               UnknownVarFromRoomEngine_Map_2.add(_loc10_,_loc6_);
               _roomContentLoader.loadThumbnailContent(_loc11_,param1,param2,null);
            }
            else
            {
               UnknownVarFromRoomEngine_NumberBank_2.freeNumber(_loc11_ - 1);
               _loc8_.id = _loc6_.id;
            }
            _loc6_.listeners.push(param3);
         }
         else
         {
            _loc13_ = assets.getAssetByName(_loc10_) as BitmapDataAsset;
            if(_loc13_ && !_loc13_.disposed)
            {
               _loc9_ = _loc13_.content as BitmapData;
               try
               {
                  if(_loc9_ != null && _loc9_ is BitmapData && _loc9_.width > 0 && _loc9_.height > 0)
                  {
                     _loc8_.data = _loc9_.clone();
                  }
                  else
                  {
                     Logger.log("Could not process thumbnail for icon (disposed?): " + _loc10_);
                  }
               }
               catch(error:Error)
               {
                  Logger.log("Could not process thumbnail for icon: " + _loc10_);
               }
            }
            UnknownVarFromRoomEngine_NumberBank_2.freeNumber(_loc11_ - 1);
            _loc8_.id = 0;
         }
         return _loc8_;
      }
      
      public function getGenericRoomObjectImage(param1:String, param2:String, param3:IVector3d, param4:int, param5:UnknownIHabboRoom1, param6:uint = 0, param7:String = null, param8:IStuffData = null, param9:int = -1, param10:int = -1, param11:String = null, param12:int = -1) : UnknownHabboRoom1
      {
         var _loc18_:PetFigureData = null;
         var _loc23_:RoomObjectDataUpdateMessage = null;
         var _loc15_:int = 0;
         var _loc17_:UnknownHabboRoom1 = new UnknownHabboRoom1();
         _loc17_.id = -1;
         if(!_isInitialized || param1 == null)
         {
            return _loc17_;
         }
         var _loc16_:IRoomInstance = _roomManager.getRoom("temporary_room");
         if(_loc16_ == null)
         {
            _loc16_ = _roomManager.createRoom("temporary_room",null);
            if(_loc16_ == null)
            {
               return _loc17_;
            }
         }
         var _loc21_:int = UnknownVarFromRoomEngine_NumberBank_1.reserveNumber();
         var _loc22_:int = getRoomObjectCategory(param1);
         if(_loc21_ < 0)
         {
            return _loc17_;
         }
         _loc21_ += 1;
         var _loc24_:IRoomObjectController = _loc16_.createRoomObject(_loc21_,param1,_loc22_) as IRoomObjectController;
         if(_loc24_ == null || _loc24_.getModelController() == null || _loc24_.getEventHandler() == null)
         {
            return _loc17_;
         }
         var _loc13_:IRoomObjectModelController = _loc24_.getModelController();
         switch(_loc22_)
         {
            case 10:
            case 20:
               _loc13_.setNumber("furniture_color",int(param2));
               _loc13_.setString("furniture_extras",param7);
               break;
            case 100:
               if(param1 == "user" || param1 == "bot" || param1 == "rentable_bot" || param1 == "pet")
               {
                  _loc13_.setString("figure",param2);
               }
               else
               {
                  _loc18_ = new PetFigureData(param2);
                  _loc13_.setNumber("pet_palette_index",_loc18_.paletteId);
                  _loc13_.setNumber("pet_color",_loc18_.color);
                  if(_loc18_.headOnly)
                  {
                     _loc13_.setNumber("pet_head_only",1);
                  }
                  if(_loc18_.hasCustomParts)
                  {
                     _loc13_.setNumberArray("pet_custom_layer_ids",_loc18_.customLayerIds);
                     _loc13_.setNumberArray("pet_custom_part_ids",_loc18_.customPartIds);
                     _loc13_.setNumberArray("pet_custom_palette_ids",_loc18_.customPaletteIds);
                  }
                  if(param11 != null)
                  {
                     _loc13_.setString("figure_posture",param11);
                  }
               }
               break;
            case 0:
               initializeRoomForGettingImage(_loc24_,param2);
         }
         _loc24_.setDirection(param3);
         _loc24_.setState(param9,0);
         var _loc14_:IRoomObjectSpriteVisualization = null;
         _loc14_ = _loc24_.getVisualization() as IRoomObjectSpriteVisualization;
         if(_loc14_ == null)
         {
            _loc16_.disposeObject(_loc21_,_loc22_);
            return _loc17_;
         }
         if(param9 > -1 || param8)
         {
            if(param8 != null && param8.getLegacyString() != "")
            {
               _loc23_ = new RoomObjectDataUpdateMessage(int(param8.getLegacyString()),param8);
            }
            else
            {
               _loc23_ = new RoomObjectDataUpdateMessage(param9,param8);
            }
            if(_loc24_.getEventHandler() != null)
            {
               _loc24_.getEventHandler().processUpdateMessage(_loc23_);
            }
         }
         var _loc20_:RoomGeometry = new RoomGeometry(param4,new Vector3d(-135,30,0),new Vector3d(11,11,5));
         _loc14_.update(_loc20_,0,true,false);
         if(param10 > 0)
         {
            _loc15_ = 0;
            while(_loc15_ < param10)
            {
               _loc14_.update(_loc20_,0,true,false);
               _loc15_++;
            }
         }
         var _loc19_:BitmapData = _loc14_.getImage(param6,param12);
         _loc17_.data = _loc19_;
         _loc17_.id = _loc21_;
         if(!isRoomObjectContentAvailable(param1) && param5 != null)
         {
            UnknownVarFromRoomEngine_Map_1.add(String(_loc21_),param5);
            _loc13_.setNumber("image_query_scale",param4,true);
         }
         else
         {
            _loc16_.disposeObject(_loc21_,_loc22_);
            UnknownVarFromRoomEngine_NumberBank_1.freeNumber(_loc21_ - 1);
            _loc17_.id = 0;
         }
         _loc20_.dispose();
         return _loc17_;
      }
      
      public function getRoomObjectBoundingRectangle(param1:int, param2:int, param3:int, param4:int) : Rectangle
      {
         var _loc11_:IRoomObject = null;
         var _loc6_:IRoomObjectVisualization = null;
         var _loc5_:Rectangle = null;
         var _loc7_:IRoomRenderingCanvas = null;
         var _loc9_:Number = NaN;
         var _loc8_:Point = null;
         var _loc10_:IRoomGeometry = getRoomCanvasGeometry(param1,param4);
         if(_loc10_ != null)
         {
            _loc11_ = getRoomObject(param1,param2,param3);
            if(_loc11_ != null)
            {
               _loc6_ = _loc11_.getVisualization();
               if(_loc6_ != null)
               {
                  _loc5_ = _loc6_.boundingRectangle;
                  _loc7_ = getRoomCanvas(param1,param4);
                  _loc9_ = _loc7_ ? _loc7_.scale : 1;
                  _loc8_ = _loc10_.getScreenPoint(_loc11_.getLocation());
                  if(_loc8_ != null)
                  {
                     _loc5_.left *= _loc9_;
                     _loc5_.top *= _loc9_;
                     _loc5_.width *= _loc9_;
                     _loc5_.height *= _loc9_;
                     _loc8_.x *= _loc9_;
                     _loc8_.y *= _loc9_;
                     _loc5_.offset(_loc8_.x,_loc8_.y);
                     if(_loc7_ != null)
                     {
                        _loc5_.offset(_loc7_.width / 2 + _loc7_.screenOffsetX,_loc7_.height / 2 + _loc7_.screenOffsetY);
                        return _loc5_;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public function getRoomObjectScreenLocation(param1:int, param2:int, param3:int, param4:int = -1) : Point
      {
         var _loc8_:IRoomObject = null;
         var _loc6_:Point = null;
         var _loc5_:IRoomRenderingCanvas = null;
         if(param4 == -1)
         {
            param4 = UnknownVarFromRoomEngine_Int_1;
         }
         var _loc7_:IRoomGeometry = getRoomCanvasGeometry(param1,param4);
         if(_loc7_ != null)
         {
            _loc8_ = getRoomObject(param1,param2,param3);
            if(_loc8_ != null)
            {
               _loc6_ = _loc7_.getScreenPoint(_loc8_.getLocation());
               if(_loc6_ != null)
               {
                  _loc5_ = getRoomCanvas(param1,param4);
                  if(_loc5_ != null)
                  {
                     _loc6_.x *= _loc5_.scale;
                     _loc6_.y *= _loc5_.scale;
                     _loc6_.offset(_loc5_.width / 2 + _loc5_.screenOffsetX,_loc5_.height / 2 + _loc5_.screenOffsetY);
                  }
                  return _loc6_;
               }
            }
         }
         return null;
      }
      
      public function getActiveRoomBoundingRectangle(param1:int) : Rectangle
      {
         return getRoomObjectBoundingRectangle(_activeRoomId,-1,0,param1);
      }
      
      public function getActiveRoomActiveCanvas() : IRoomRenderingCanvas
      {
         return getRoomCanvas(_activeRoomId,UnknownVarFromRoomEngine_Int_1);
      }
      
      public function isRoomObjectContentAvailable(param1:String) : Boolean
      {
         return _roomManager.isContentAvailable(param1);
      }
      
      public function iconLoaded(param1:int, param2:String, param3:Boolean) : void
      {
         var _loc7_:BitmapDataAsset = null;
         var _loc4_:BitmapData = null;
         if(_roomContentLoader == null)
         {
            return;
         }
         if(param1 == -1)
         {
            return;
         }
         UnknownVarFromRoomEngine_NumberBank_2.freeNumber(param1 - 1);
         var _loc5_:AssetCallbackInfo = UnknownVarFromRoomEngine_Map_2.getValue(param2);
         if(_loc5_ != null)
         {
            if(_loc5_.id != param1)
            {
               return;
            }
            UnknownVarFromRoomEngine_Map_2.remove(param2);
            _loc7_ = assets.getAssetByName(param2) as BitmapDataAsset;
            _loc4_ = _loc7_.content as BitmapData;
            if(_loc7_ && !_loc7_.disposed)
            {
               for each(var _loc6_ in _loc5_.listeners)
               {
                  if(_loc6_ != null)
                  {
                     try
                     {
                        if(_loc4_ != null && _loc4_ is BitmapData && _loc4_.width > 0 && _loc4_.height > 0)
                        {
                           _loc6_.imageReady(param1,_loc4_.clone());
                        }
                        else
                        {
                           Logger.log("Could not load thumbnail for icon (disposed?): " + param2);
                        }
                     }
                     catch(error:Error)
                     {
                        Logger.log("Could not load thumbnail for icon: " + param2);
                        continue;
                     }
                  }
               }
            }
         }
      }
      
      public function contentLoaded(param1:String, param2:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc14_:IRoomObject = null;
         var _loc11_:int = 0;
         var _loc9_:BitmapData = null;
         var _loc4_:IRoomObjectSpriteVisualization = null;
         var _loc7_:Number = NaN;
         var _loc5_:UnknownIHabboRoom1 = null;
         if(!param2)
         {
            Logger.log("[RoomEngine] Failed to load content:  " + param1);
         }
         var _loc8_:IRoomInstance = _roomManager.getRoom("temporary_room");
         if(_loc8_ == null)
         {
            Logger.log("No room instance for " + param1 + " room: " + "temporary_room");
            return;
         }
         if(_roomContentLoader == null)
         {
            return;
         }
         var _loc10_:RoomGeometry = null;
         var _loc13_:* = 0;
         var _loc12_:int = _roomContentLoader.getObjectCategory(param1);
         var _loc3_:int = _loc8_.getObjectCount(_loc12_);
         _loc6_ = _loc3_ - 1;
         while(_loc6_ >= 0)
         {
            _loc14_ = _loc8_.getObjectWithIndex(_loc6_,_loc12_);
            if(_loc14_ != null && _loc14_.getModel() != null && _loc14_.getType() == param1)
            {
               _loc11_ = _loc14_.getId();
               _loc9_ = null;
               _loc4_ = null;
               _loc4_ = _loc14_.getVisualization() as IRoomObjectSpriteVisualization;
               if(_loc4_ != null)
               {
                  _loc7_ = _loc14_.getModel().getNumber("image_query_scale");
                  if(_loc10_ != null && _loc13_ != _loc7_)
                  {
                     _loc10_.dispose();
                     _loc10_ = null;
                  }
                  if(_loc10_ == null)
                  {
                     _loc13_ = _loc7_;
                     _loc10_ = new RoomGeometry(_loc7_,new Vector3d(-135,30,0),new Vector3d(11,11,5));
                  }
                  _loc4_.update(_loc10_,0,true,false);
                  _loc9_ = _loc4_.image;
               }
               _loc8_.disposeObject(_loc11_,_loc12_);
               UnknownVarFromRoomEngine_NumberBank_1.freeNumber(_loc11_ - 1);
               _loc5_ = UnknownVarFromRoomEngine_Map_1.remove(String(_loc11_)) as UnknownIHabboRoom1;
               if(_loc5_ != null)
               {
                  if(_loc9_ != null)
                  {
                     _loc5_.imageReady(_loc11_,_loc9_);
                  }
                  else
                  {
                     _loc5_.imageFailed(_loc11_);
                  }
               }
               else if(_loc9_ != null)
               {
                  _loc9_.dispose();
               }
            }
            _loc6_--;
         }
         if(_loc10_ != null)
         {
            _loc10_.dispose();
         }
      }
      
      public function objectInitialized(param1:String, param2:int, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc4_:IStuffData = null;
         var _loc6_:int = 0;
         var _loc7_:RoomObjectDataUpdateMessage = null;
         var _loc8_:int = getRoomId(param1);
         if(param3 == 20)
         {
            updateObjectRoomWindow(_loc8_,param2);
         }
         var _loc9_:IRoomObjectController = getRoomObject(_loc8_,param2,param3) as IRoomObjectController;
         if(_loc9_ != null && _loc9_.getModel() != null && _loc9_.getEventHandler() != null)
         {
            if(!isNaN(_loc9_.getModel().getNumber("furniture_data_format")))
            {
               _loc5_ = int(_loc9_.getModel().getNumber("furniture_data_format"));
               _loc4_ = UnknownHabboRoomObjectData1.getStuffDataWrapperForType(_loc5_);
               _loc4_.initializeFromRoomObjectModel(_loc9_.getModel());
               _loc6_ = int(_loc9_.getState(0));
               _loc7_ = new RoomObjectDataUpdateMessage(_loc6_,_loc4_);
               _loc9_.getEventHandler().processUpdateMessage(_loc7_);
            }
            if(events != null)
            {
               events.dispatchEvent(new RoomEngineObjectEvent("REOE_CONTENT_UPDATED",_loc8_,param2,param3));
            }
         }
         if(param1 != "temporary_room")
         {
            addObjectToTileMap(_loc8_,_loc9_);
         }
      }
      
      public function objectsInitialized(param1:String) : void
      {
         var _loc2_:int = 0;
         if(events != null)
         {
            _loc2_ = getRoomId(param1);
            events.dispatchEvent(new RoomEngineEvent("REE_OBJECTS_INITIALIZED",_loc2_));
         }
      }
      
      public function selectAvatar(param1:int, param2:int) : void
      {
         if(_eventHandler != null)
         {
            _eventHandler.setSelectedAvatar(param1,param2,true);
         }
      }
      
      public function getSelectedAvatarId() : int
      {
         if(_eventHandler != null)
         {
            return _eventHandler.getSelectedAvatarId();
         }
         return -1;
      }
      
      public function selectRoomObject(param1:int, param2:int, param3:int) : void
      {
         if(_eventHandler == null)
         {
            return;
         }
         _eventHandler.setSelectedObject(param1,param2,param3);
      }
      
      protected function addObjectToTileMap(param1:int, param2:IRoomObject) : void
      {
         var _loc3_:TileObjectMap = getRoomInstanceData(param1).tileObjectMap;
         if(_loc3_)
         {
            _loc3_.addRoomObject(param2);
         }
      }
      
      public function refreshTileObjectMap(param1:int, param2:String) : void
      {
         var _loc3_:TileObjectMap = getRoomInstanceData(param1).tileObjectMap;
         if(_loc3_)
         {
            _loc3_.populate(getRoomObjects(param1,10));
         }
         _eventHandler.recalibrateMovements(param1);
      }
      
      private function showRoomAd(param1:AdEvent) : void
      {
         var _loc3_:IRoomObjectController = null;
         var _loc2_:RoomObjectRoomAdUpdateMessage = null;
         if(_roomContentLoader != null)
         {
            _loc3_ = getObjectRoom(param1.roomId);
            if(_loc3_ == null)
            {
               return;
            }
            _loc2_ = null;
            _loc2_ = new RoomObjectRoomAdUpdateMessage("RORUM_ROOM_AD_ACTIVATE","room_ad_image_asset",param1.clickUrl);
            _loc3_.getEventHandler().processUpdateMessage(_loc2_);
         }
      }
      
      public function requestRoomAdImage(param1:int, param2:int, param3:int, param4:String, param5:String) : void
      {
         if(_adManager != null)
         {
            _adManager.loadRoomAdImage(param1,param2,param3,param4,param5);
         }
      }
      
      private function onRoomAdImageLoaded(param1:AdEvent) : void
      {
         var _loc2_:RoomObjectRoomAdUpdateMessage = null;
         var _loc3_:IRoomObjectController = getObjectRoom(param1.roomId);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:IRoomObjectController = getObjectFurniture(param1.roomId,param1.objectId);
         if(_loc4_ == null || _loc4_.getEventHandler() == null)
         {
            return;
         }
         if(param1.image != null)
         {
            _roomContentLoader.addGraphicAsset(_loc4_.getType(),param1.imageUrl,param1.image,true);
         }
         switch(param1.type)
         {
            case "AE_ROOM_AD_IMAGE_LOADED":
               _loc2_ = new RoomObjectRoomAdUpdateMessage("RORUM_ROOM_BILLBOARD_IMAGE_LOADED",param1.imageUrl,param1.clickUrl,param1.objectId,param1.image);
               break;
            case "AE_ROOM_AD_IMAGE_LOADING_FAILED":
               _loc2_ = new RoomObjectRoomAdUpdateMessage("RORUM_ROOM_BILLBOARD_IMAGE_LOADING_FAILED",param1.imageUrl,param1.clickUrl,param1.objectId,param1.image);
         }
         if(_loc2_ != null)
         {
            _loc4_.getEventHandler().processUpdateMessage(_loc2_);
         }
      }
      
      public function insertContentLibrary(param1:int, param2:int, param3:IAssetLibraryCollection) : Boolean
      {
         return _roomContentLoader.insertObjectContent(param1,param2,param3);
      }
      
      public function setActiveObjectType(param1:int, param2:String) : void
      {
         _roomContentLoader.setActiveObjectType(param1,param2);
      }
      
      override public function purge() : void
      {
         super.purge();
         if(_roomContentLoader)
         {
            _roomContentLoader.purge();
         }
      }
      
      public function requestBadgeImageAsset(param1:int, param2:int, param3:int, param4:String, param5:Boolean = true) : void
      {
         var _loc10_:IRoomInstance = null;
         var _loc6_:Array = null;
         var _loc11_:IRoomObjectController = null;
         if(param1 == 0)
         {
            _loc10_ = _roomManager.getRoom("temporary_room");
            if(_loc10_ != null)
            {
               _loc11_ = _loc10_.getObject(param2,param3) as IRoomObjectController;
            }
         }
         else
         {
            _loc11_ = getObjectFurniture(param1,param2);
         }
         if(_loc11_ == null || _loc11_.getEventHandler() == null)
         {
            return;
         }
         var _loc8_:Function = param5 ? _sessionDataManager.getGroupBadgeAssetName : _sessionDataManager.getBadgeImageAssetName;
         var _loc7_:String = _loc8_.call(null,param4);
         if(!_loc7_)
         {
            _loc7_ = "loading_icon";
            if(!UnknownVarFromRoomEngine_Map_5)
            {
               UnknownVarFromRoomEngine_Map_5 = new Map();
            }
            if(UnknownVarFromRoomEngine_Map_5.length == 0)
            {
               _sessionDataManager.events.addEventListener("BIRE_BADGE_IMAGE_READY",onBadgeLoaded);
            }
            _loc6_ = UnknownVarFromRoomEngine_Map_5.getValue(param4);
            if(_loc6_ == null)
            {
               _loc6_ = [];
            }
            _loc6_.push(new RoomObjectBadgeImageAssetListener(_loc11_,param5));
            UnknownVarFromRoomEngine_Map_5[param4] = _loc6_;
         }
         else
         {
            addBadgeGraphicAssets(_loc11_,param4,param5);
         }
         var _loc9_:RoomObjectGroupBadgeUpdateMessage = new RoomObjectGroupBadgeUpdateMessage(param4,_loc7_);
         if(_loc9_ != null)
         {
            _loc11_.getEventHandler().processUpdateMessage(_loc9_);
         }
      }
      
      private function addBadgeGraphicAssets(param1:IRoomObjectController, param2:String, param3:Boolean = false) : void
      {
         var _loc9_:Function = param3 ? _sessionDataManager.getGroupBadgeAssetName : _sessionDataManager.getBadgeImageAssetName;
         var _loc10_:Function = param3 ? _sessionDataManager.getGroupBadgeSmallAssetName : _sessionDataManager.getBadgeImageSmallAssetName;
         var _loc11_:Function = param3 ? _sessionDataManager.getGroupBadgeImage : _sessionDataManager.getBadgeImage;
         var _loc8_:Function = param3 ? _sessionDataManager.getGroupBadgeSmallImage : _sessionDataManager.getBadgeSmallImage;
         var _loc7_:String = String(_loc9_.call(null,param2));
         var _loc4_:BitmapData = BitmapData(_loc11_.call(null,param2));
         _roomContentLoader.addGraphicAsset(param1.getType(),_loc7_,_loc4_,false);
         var _loc5_:String = String(_loc10_.call(null,param2));
         var _loc6_:BitmapData = _loc8_.call(null,param2);
         if(_loc6_)
         {
            _roomContentLoader.addGraphicAsset(param1.getType(),_loc5_,_loc6_,false);
         }
      }
      
      private function onBadgeLoaded(param1:BadgeImageReadyEvent) : void
      {
         var _loc4_:int = 0;
         var _loc3_:RoomObjectBadgeImageAssetListener = null;
         var _loc5_:Function = null;
         var _loc6_:RoomObjectGroupBadgeUpdateMessage = null;
         var _loc2_:Array = UnknownVarFromRoomEngine_Map_5.getValue(param1.badgeId) as Array;
         if(_loc2_ == null)
         {
            Logger.log("Could not find matching objects for group badge asset request " + param1.badgeId);
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_];
            addBadgeGraphicAssets(_loc3_.object,param1.badgeId,_loc3_.groupBadge);
            _loc5_ = _loc3_.groupBadge ? _sessionDataManager.getGroupBadgeAssetName : _sessionDataManager.getBadgeImageAssetName;
            _loc6_ = new RoomObjectGroupBadgeUpdateMessage(param1.badgeId,String(_loc5_.call(null,param1.badgeId)));
            if(_loc6_ != null && _loc3_.object.getEventHandler() != null)
            {
               _loc3_.object.getEventHandler().processUpdateMessage(_loc6_);
            }
            _loc4_++;
         }
         UnknownVarFromRoomEngine_Map_5.remove(param1.badgeId);
         if(UnknownVarFromRoomEngine_Map_5.length == 0)
         {
            _sessionDataManager.events.removeEventListener("BIRE_BADGE_IMAGE_READY",onBadgeLoaded);
         }
      }
      
      public function requestFurniIconAsset(param1:int, param2:int, param3:int, param4:Boolean, param5:int, param6:String) : void
      {
         var _loc10_:IRoomInstance = null;
         var _loc7_:Array = null;
         var _loc12_:IRoomObjectController = null;
         if(param1 == 0)
         {
            _loc10_ = _roomManager.getRoom("temporary_room");
            if(_loc10_ != null)
            {
               _loc12_ = _loc10_.getObject(param2,param3) as IRoomObjectController;
            }
         }
         else
         {
            _loc12_ = getObjectFurniture(param1,param2);
         }
         if(_loc12_ == null || _loc12_.getEventHandler() == null)
         {
            return;
         }
         var _loc8_:String = _sessionDataManager.getFurniIconImageAssetName(param4,param5,param6);
         var _loc11_:String = furniIconListenerKey(param4,param5,param6);
         if(!_loc8_)
         {
            _loc8_ = "loading_icon";
            if(!UnknownVarFromRoomEngine_Map_6)
            {
               UnknownVarFromRoomEngine_Map_6 = new Map();
            }
            if(UnknownVarFromRoomEngine_Map_6.length == 0)
            {
               _sessionDataManager.events.addEventListener("FIIRE_ICON_READY",onFurniIconLoaded);
            }
            _loc7_ = UnknownVarFromRoomEngine_Map_6.getValue(_loc11_);
            if(_loc7_ == null)
            {
               _loc7_ = [];
            }
            _loc7_.push(new RoomObjectFurniIconImageAssetListener(_loc12_));
            UnknownVarFromRoomEngine_Map_6[_loc11_] = _loc7_;
         }
         else
         {
            addFurniIconGraphicAssets(_loc12_,param4,param5,param6);
         }
         var _loc9_:RoomObjectFurniIconUpdateMessage = new RoomObjectFurniIconUpdateMessage(_loc8_,param4,param5,param6);
         if(_loc9_ != null)
         {
            _loc12_.getEventHandler().processUpdateMessage(_loc9_);
         }
      }
      
      private function addFurniIconGraphicAssets(param1:IRoomObjectController, param2:Boolean, param3:int, param4:String) : void
      {
         var _loc6_:String = _sessionDataManager.getFurniIconImageAssetName(param2,param3,param4);
         var _loc5_:BitmapData = _sessionDataManager.getFurniIconImage(param2,param3,param4);
         _roomContentLoader.addGraphicAsset(param1.getType(),_loc6_,_loc5_,false);
      }
      
      private function onFurniIconLoaded(param1:FurniIconImageReadyEvent) : void
      {
         var _loc4_:int = 0;
         var _loc3_:RoomObjectFurniIconImageAssetListener = null;
         var _loc5_:RoomObjectFurniIconUpdateMessage = null;
         var _loc6_:String = furniIconListenerKey(param1.wallItem,param1.typeId,param1.extra);
         var _loc2_:Array = UnknownVarFromRoomEngine_Map_6.getValue(_loc6_) as Array;
         if(_loc2_ == null)
         {
            Logger.log("Could not find matching objects for furni icon asset request " + _loc6_);
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_];
            addFurniIconGraphicAssets(_loc3_.object,param1.wallItem,param1.typeId,param1.extra);
            _loc5_ = new RoomObjectFurniIconUpdateMessage(param1.assetName,param1.wallItem,param1.typeId,param1.extra);
            if(_loc5_ != null && _loc3_.object.getEventHandler() != null)
            {
               _loc3_.object.getEventHandler().processUpdateMessage(_loc5_);
            }
            _loc4_++;
         }
         UnknownVarFromRoomEngine_Map_6.remove(_loc6_);
         if(UnknownVarFromRoomEngine_Map_6.length == 0)
         {
            _sessionDataManager.events.removeEventListener("FIIRE_ICON_READY",onFurniIconLoaded);
         }
      }
      
      public function get isDecorateMode() : Boolean
      {
         if(!_roomSessionManager)
         {
            return false;
         }
         var _loc1_:IRoomSession = _roomSessionManager.getSession(_activeRoomId);
         return _loc1_ && _loc1_.isUserDecorating;
      }
      
      public function get isGameMode() : Boolean
      {
         return _isGameMode;
      }
      
      public function set isGameMode(param1:Boolean) : void
      {
         _isGameMode = param1;
      }
      
      public function showUseProductSelection(param1:int, param2:int, param3:int = -1) : void
      {
         var _loc5_:int = 0;
         var _loc4_:String = null;
         if(_roomContentLoader != null)
         {
            _loc4_ = _roomContentLoader.getActiveObjectType(param2);
            _loc5_ = getRoomObjectCategory(_loc4_);
            events.dispatchEvent(new RoomEngineUseProductEvent("ROSM_USE_PRODUCT_FROM_INVENTORY",_activeRoomId,param3,_loc5_,param1,param2));
         }
      }
      
      public function setAvatarEffect(param1:int) : void
      {
         if(_sessionDataManager == null || _roomSessionManager == null)
         {
            return;
         }
         var _loc2_:IRoomSession = _roomSessionManager.getSession(_activeRoomId);
         if(_loc2_ == null)
         {
            return;
         }
         updateObjectUserEffect(activeRoomId,_loc2_.ownUserRoomId,param1);
      }
      
      public function setFpsCounterEnabled(param1:Boolean) : void
      {
         if(_sessionDataManager == null || _roomSessionManager == null)
         {
            return;
         }
         var _loc2_:IRoomRenderingCanvas = getActiveRoomActiveCanvas();
         if(_loc2_ != null)
         {
            _loc2_.fpsCounterEnabled = param1;
         }
      }
      
      public function get playerUnderCursor() : int
      {
         return _playerUnderCursor;
      }
      
      public function get roomSessionManager() : IRoomSessionManager
      {
         return _roomSessionManager;
      }
      
      public function get sessionDataManager() : ISessionDataManager
      {
         return _sessionDataManager;
      }
      
      public function get toolbar() : IHabboToolbar
      {
         return _toolbar;
      }
      
      public function get catalog() : IHabboCatalog
      {
         return _catalog;
      }
      
      public function get roomEvents() : IHabboUserDefinedRoomEvents
      {
         return _roomEvents;
      }
      
      private function fixedUserLocation(param1:int, param2:IVector3d) : IVector3d
      {
         if(param2 == null)
         {
            return null;
         }
         var _loc5_:FurniStackingHeightMap = getFurniStackingHeightMap(param1);
         var _loc7_:LegacyWallGeometry = getLegacyGeometry(param1);
         if(_loc5_ == null || _loc7_ == null)
         {
            return param2;
         }
         var _loc6_:Number = param2.z;
         var _loc3_:Number = _loc5_.getTileHeight(param2.x,param2.y);
         var _loc4_:Number = _loc7_.getTileHeight(param2.x,param2.y);
         if(Math.abs(_loc6_ - _loc3_) < 0.02 && Math.abs(_loc3_ - _loc4_) < 0.02)
         {
            _loc6_ = _loc7_.getFloorAltitude(param2.x,param2.y);
         }
         return new Vector3d(param2.x,param2.y,_loc6_);
      }
      
      private function get cameraFollowDuration() : int
      {
         return getBoolean("room.camera.follow_user") ? 1000 : 0;
      }
      
      public function get windowManager() : IHabboWindowManagerComponent
      {
         return _windowManager;
      }
      
      public function getRenderRoomMessage(param1:Rectangle, param2:uint, param3:Boolean = false, param4:Boolean = true, param5:Boolean = false, param6:int = -1) : IMessageComposer
      {
         var _loc8_:IRoomRenderingCanvas = null;
         if(param6 > -1)
         {
            _loc8_ = getRoomCanvas(_activeRoomId,param6);
         }
         else
         {
            _loc8_ = getActiveRoomActiveCanvas();
         }
         if(!_loc8_)
         {
            return null;
         }
         if(param5)
         {
            _loc8_.skipSpriteVisibilityChecking();
         }
         var _loc12_:int = -1;
         if(!param4 && _roomSessionManager.getSession(_activeRoomId) != null)
         {
            _loc12_ = _roomSessionManager.getSession(_activeRoomId).ownUserRoomId;
         }
         var _loc11_:SpriteDataCollector = new SpriteDataCollector();
         var _loc10_:String = _loc11_.getFurniData(param1,_loc8_,this,_loc12_);
         var _loc9_:String = _loc11_.getRoomRenderingModifiers(this);
         var _loc7_:Array = _loc11_.getRoomPlanes(param1,_loc8_,this,param2);
         if(param5)
         {
            _loc8_.resumeSpriteVisibilityChecking();
         }
         if(param3)
         {
            return new RenderRoomThumbnailMessageComposer(_loc7_,_loc10_,_loc9_,_activeRoomId,_sessionDataManager.topSecurityLevel);
         }
         return new RenderRoomMessageComposer(_loc7_,_loc10_,_loc9_,_activeRoomId,_sessionDataManager.topSecurityLevel);
      }
      
      public function get roomContentLoader() : RoomContentLoader
      {
         return _roomContentLoader;
      }
      
      public function isWhereYouClickWhereYouGo() : Boolean
      {
         return UnknownVarFromRoomEngine_Boolean_4 && !isAreaSelectionMode();
      }
      
      public function isAreaSelectionMode() : Boolean
      {
         return _areaSelectionManager.areaSelectionState != RoomAreaSelectionManager.NOT_ACTIVE;
      }
      
      public function setMoveBlocked(param1:Boolean) : void
      {
         _isMoveBlocked = param1;
      }
      
      public function isMoveBlocked() : Boolean
      {
         return _isMoveBlocked;
      }
      
      public function get areaSelectionManager() : IRoomAreaSelectionManager
      {
         return _areaSelectionManager;
      }
   }
}

