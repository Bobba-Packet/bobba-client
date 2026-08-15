package com.sulake.habbo.session
{
   import com.sulake.core.assets.IAssetLibraryCollection;
   import com.sulake.core.assets.ISoundAsset;
   import com.sulake.core.assets.XmlAsset;
   import com.sulake.core.communication.messages.IMessageComposer;
   import com.sulake.core.communication.messages.IMessageEvent;
   import com.sulake.core.runtime.Component;
   import com.sulake.core.runtime.ComponentDependency;
   import com.sulake.core.runtime.IComponent_2;
   import com.sulake.core.utils.Map;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.utils.UnknownICoreWindowUtils1;
   import com.sulake.core.window.utils.UnknownICoreWindowUtils2;
   import com.sulake.habbo.communication.IHabboCommunicationManager;
   import com.sulake.habbo.communication.messages.incoming.availability.AvailabilityStatusMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.avatar.ChangeUserNameResultMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.avatar.FigureUpdateEvent;
   import com.sulake.habbo.communication.messages.incoming.handshake.NoobnessLevelMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.handshake.UserObjectEvent;
   import com.sulake.habbo.communication.messages.incoming.handshake.UserRightsMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.mysterybox.MysteryBoxKeysMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.preferences.AccountPreferencesEvent;
   import com.sulake.habbo.communication.messages.incoming.room.engine.UserChangeMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.room.pets.PetRespectFailedEvent;
   import com.sulake.habbo.communication.messages.incoming.room.session.RoomReadyMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.users.AccountSafetyLockStatusChangeMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.users.EmailStatusResultEvent;
   import com.sulake.habbo.communication.messages.incoming.users.InClientLinkMessageEvent;
   import com.sulake.habbo.communication.messages.incoming.users.UserNameChangedMessageEvent;
   import com.sulake.habbo.communication.messages.outgoing.preferences.SetUIFlagsMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.quest.dailytasks.GetDailyTasksComposer;
   import com.sulake.habbo.communication.messages.outgoing.room.chat.ChatMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.room.pets.RespectPetMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.users.GetUserNftChatStylesMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.users.ReplenishRespectMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.users.RespectUserMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.vault.CreditVaultStatusMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.vault.IncomeRewardClaimMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.vault.IncomeRewardStatusMessageComposer;
   import com.sulake.habbo.communication.messages.outgoing.vault.WithdrawCreditVaultMessageComposer;
   import com.sulake.habbo.communication.messages.parser.availability.AvailabilityStatusMessageParser;
   import com.sulake.habbo.communication.messages.parser.avatar.ChangeUserNameResultMessageParser;
   import com.sulake.habbo.communication.messages.parser.chatstyles.UserNftChatStylesMessageEvent;
   import com.sulake.habbo.communication.messages.parser.chatstyles.UserPurchasableChatStyleChangedMessageEvent;
   import com.sulake.habbo.communication.messages.parser.chatstyles.UserPurchasableChatStylesMessageEvent;
   import com.sulake.habbo.communication.messages.parser.handshake.UserObjectMessageParser;
   import com.sulake.habbo.communication.messages.parser.mysterybox.MysteryBoxKeysMessageParser;
   import com.sulake.habbo.communication.messages.parser.preferences.AccountPreferencesParser;
   import com.sulake.habbo.communication.messages.parser.room.session.RoomReadyMessageParser;
   import com.sulake.habbo.communication.messages.parser.users.AccountSafetyLockStatusChangeMessageParser;
   import com.sulake.habbo.communication.messages.parser.users.EmailStatusParser;
   import com.sulake.habbo.communication.messages.parser.users.UserNameChangedMessageParser;
   import com.sulake.habbo.localization.IHabboLocalizationManager;
   import com.sulake.habbo.notifications.IHabboNotifications;
   import com.sulake.habbo.session.events.MysteryBoxKeysUpdateEvent;
   import com.sulake.habbo.session.events.SessionDataPreferencesEvent;
   import com.sulake.habbo.session.events.SessionDataToWidgetEvent;
   import com.sulake.habbo.session.events.UserNameUpdateEvent;
   import com.sulake.habbo.session.furniture.FurnitureDataParser;
   import com.sulake.habbo.session.furniture.IFurnitureData;
   import com.sulake.habbo.session.furniture.UnknownIHabboSessionFurniture1;
   import com.sulake.habbo.session.product.IProductData;
   import com.sulake.habbo.session.product.ProductDataParser;
   import com.sulake.habbo.session.product.UnknownIHabboSessionProduct1;
   import com.sulake.habbo.utils.HabboWebTools;
   import com.sulake.habbo.window.IHabboWindowManagerComponent;
   import com.sulake.habbo.window.LilithCustoms;
   import com.sulake.iid.*;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class SessionDataManager extends Component implements ISessionDataManager
   {
      
      public static const UnknownConstFromHabboAvatarEditorManager_Uint_3:uint = 1;
      
      private var _communication:IHabboCommunicationManager;
      
      private var _windowManager:IHabboWindowManagerComponent;
      
      private var _roomSessionManager:IRoomSessionManager;
      
      private var _notifications:IHabboNotifications;
      
      private var UnknownVarFromSessionDataManager_PerkManager_1:PerkManager;
      
      private var _userId:int;
      
      private var _name:String;
      
      private var _figure:String;
      
      private var _gender:String;
      
      private var _realName:String;
      
      private var UnknownVarFromSessionDataManager_Int_1:int = 0;
      
      private var _respectLeft:int = 0;
      
      private var _respectReplenishesLeft:int = 0;
      
      private var UnknownVarFromSessionDataManager_Int_2:int = 0;
      
      private var _petRespectLeft:int = 0;
      
      private var _nameChangeAllowed:Boolean = true;
      
      private var _nftChatStyles:Vector.<int>;
      
      private var _purchasableChatStyles:Vector.<int>;
      
      private var _systemOpen:Boolean;
      
      private var _systemShutDown:Boolean;
      
      private var UnknownVarFromSessionDataManager_Dictionary_1:Dictionary;
      
      private var UnknownVarFromSessionDataManager_ProductDataParser_1:ProductDataParser;
      
      private var _floorItems:Map;
      
      private var _wallItems:Map;
      
      private var UnknownVarFromSessionDataManager_Map_1:Map;
      
      private var UnknownVarFromSessionDataManager_Map_2:Map;
      
      private var UnknownVarFromSessionDataManager_FurnitureDataParser_1:FurnitureDataParser;
      
      private var UnknownVarFromSessionDataManager_FurnitureDataParser_2:FurnitureDataParser;
      
      private var UnknownVarFromSessionDataManager_BadgeImageManager_1:BadgeImageManager;
      
      private var UnknownVarFromSessionDataManager_FurniIconImageManager_1:FurniIconImageManager;
      
      private var UnknownVarFromSessionDataManager_HabboGroupInfoManager_1:HabboGroupInfoManager;
      
      private var UnknownVarFromSessionDataManager_IgnoredUsersManager_1:IgnoredUsersManager;
      
      private var UnknownVarFromSessionDataManager_BlockedUsersManager_1:BlockedUsersManager;
      
      private var _localization:IHabboLocalizationManager;
      
      private var UnknownVarFromSessionDataManager_Boolean_1:Boolean = false;
      
      private var _productDataListeners:Array;
      
      private var _furniDataListeners:Array;
      
      private var _clubLevel:int;
      
      private var UnknownVarFromSessionDataManager_Int_3:int;
      
      private var _topSecurityLevel:int = 0;
      
      private var UnknownVarFromSessionDataManager_Int_4:int = -1;
      
      private var _isAmbassador:Boolean;
      
      private var _isEmailVerified:Boolean;
      
      private var _isRoomCameraFollowDisabled:Boolean;
      
      private var _uiFlags:int;
      
      private var _accountSafetyLocked:Boolean = false;
      
      private var _mysteryBoxColor:String;
      
      private var _mysteryKeyColor:String;
      
      private var UnknownVarFromSessionDataManager_Boolean_2:Boolean = false;
      
      private var UnknownVarFromSessionDataManager_Boolean_3:Boolean = false;
      
      private var _newFurniDataHash:String = null;
      
      public function SessionDataManager(param1:IComponent_2, param2:uint = 0, param3:IAssetLibraryCollection = null)
      {
         super(param1,param2,param3);
      }
      
      override protected function get dependencies() : Vector.<ComponentDependency>
      {
         return super.dependencies.concat(new <ComponentDependency>[new ComponentDependency(new IIDHabboWindowManager(),function(param1:IHabboWindowManagerComponent):void
         {
            _windowManager = param1;
         },false),new ComponentDependency(new IIDHabboCommunicationManager(),function(param1:IHabboCommunicationManager):void
         {
            _communication = param1;
         },(flags & 1) == 0),new ComponentDependency(new IIDHabboConfigurationManager(),null,true,[{
            "type":"complete",
            "callback":onConfigurationComplete
         }]),new ComponentDependency(new IIDHabboLocalizationManager(),function(param1:IHabboLocalizationManager):void
         {
            _localization = param1;
         }),new ComponentDependency(new IIDHabboRoomSessionManager(),function(param1:IRoomSessionManager):void
         {
            _roomSessionManager = param1;
         },false),new ComponentDependency(new IIDHabboNotifications(),function(param1:IHabboNotifications):void
         {
            _notifications = param1;
         },false)]);
      }
      
      private function onConfigurationComplete(param1:Event) : void
      {
         UnknownVarFromSessionDataManager_Dictionary_1 = new Dictionary();
         _floorItems = new Map();
         _wallItems = new Map();
         UnknownVarFromSessionDataManager_Map_1 = new Map();
         UnknownVarFromSessionDataManager_Map_2 = new Map();
         initFurnitureData();
         initProductData();
         initBadgeImageManager();
         initFurniIconImageManager();
      }
      
      override protected function initComponent() : void
      {
         if(_communication)
         {
            _communication.addHabboConnectionMessageEvent(new AccountSafetyLockStatusChangeMessageEvent(onAccountSafetyLockStatusChanged));
            _communication.addHabboConnectionMessageEvent(new FigureUpdateEvent(onFigureUpdate));
            _communication.addHabboConnectionMessageEvent(new PetRespectFailedEvent(onPetRespectFailed));
            _communication.addHabboConnectionMessageEvent(new UserPurchasableChatStyleChangedMessageEvent(onPurchasableChatStyleChanged));
            _communication.addHabboConnectionMessageEvent(new AvailabilityStatusMessageEvent(onAvailabilityStatus));
            _communication.addHabboConnectionMessageEvent(new UserRightsMessageEvent(onUserRights));
            _communication.addHabboConnectionMessageEvent(new MysteryBoxKeysMessageEvent(onMysteryBoxKeys));
            _communication.addHabboConnectionMessageEvent(new UserNameChangedMessageEvent(onUserNameChange));
            _communication.addHabboConnectionMessageEvent(new UserChangeMessageEvent(onUserChange));
            _communication.addHabboConnectionMessageEvent(new UserObjectEvent(onUserObject));
            _communication.addHabboConnectionMessageEvent(new EmailStatusResultEvent(onEmailStatus));
            _communication.addHabboConnectionMessageEvent(new InClientLinkMessageEvent(onInClientLink));
            _communication.addHabboConnectionMessageEvent(new AccountPreferencesEvent(onAccountPreferences));
            _communication.addHabboConnectionMessageEvent(new RoomReadyMessageEvent(onRoomReady) as IMessageEvent);
            _communication.addHabboConnectionMessageEvent(new UserPurchasableChatStylesMessageEvent(onPurchasableChatStyles));
            _communication.addHabboConnectionMessageEvent(new ChangeUserNameResultMessageEvent(onChangeUserNameResult));
            _communication.addHabboConnectionMessageEvent(new NoobnessLevelMessageEvent(onNoobnessLevelEvent));
            _communication.addHabboConnectionMessageEvent(new UserNftChatStylesMessageEvent(onNftChatStyles));
         }
         UnknownVarFromSessionDataManager_HabboGroupInfoManager_1 = new HabboGroupInfoManager(this);
         UnknownVarFromSessionDataManager_IgnoredUsersManager_1 = new IgnoredUsersManager(this);
         UnknownVarFromSessionDataManager_BlockedUsersManager_1 = new BlockedUsersManager(this);
         UnknownVarFromSessionDataManager_PerkManager_1 = new PerkManager(this);
         _productDataListeners = [];
         _furniDataListeners = [];
         if(_communication)
         {
            initSessionData();
         }
      }
      
      override public function dispose() : void
      {
         if(disposed)
         {
            return;
         }
         if(_floorItems)
         {
            _floorItems.dispose();
            _floorItems = null;
         }
         if(UnknownVarFromSessionDataManager_Map_1)
         {
            UnknownVarFromSessionDataManager_Map_1.dispose();
            UnknownVarFromSessionDataManager_Map_1 = null;
         }
         if(UnknownVarFromSessionDataManager_Map_2)
         {
            UnknownVarFromSessionDataManager_Map_2.dispose();
            UnknownVarFromSessionDataManager_Map_2 = null;
         }
         if(UnknownVarFromSessionDataManager_BlockedUsersManager_1)
         {
            UnknownVarFromSessionDataManager_BlockedUsersManager_1.dispose();
            UnknownVarFromSessionDataManager_BlockedUsersManager_1 = null;
         }
         if(UnknownVarFromSessionDataManager_PerkManager_1)
         {
            UnknownVarFromSessionDataManager_PerkManager_1.dispose();
            UnknownVarFromSessionDataManager_PerkManager_1 = null;
         }
         _furniDataListeners = null;
         if(UnknownVarFromSessionDataManager_FurnitureDataParser_1)
         {
            UnknownVarFromSessionDataManager_FurnitureDataParser_1.dispose();
            UnknownVarFromSessionDataManager_FurnitureDataParser_1 = null;
         }
         if(UnknownVarFromSessionDataManager_FurnitureDataParser_2)
         {
            UnknownVarFromSessionDataManager_FurnitureDataParser_2.removeEventListener("FDP_furniture_data_ready",onFurnitureReady);
            UnknownVarFromSessionDataManager_FurnitureDataParser_2.dispose();
            UnknownVarFromSessionDataManager_FurnitureDataParser_2 = null;
         }
         if(UnknownVarFromSessionDataManager_ProductDataParser_1)
         {
            UnknownVarFromSessionDataManager_ProductDataParser_1.removeEventListener("PDP_product_data_ready",onProductsReady);
            UnknownVarFromSessionDataManager_ProductDataParser_1.dispose();
            UnknownVarFromSessionDataManager_ProductDataParser_1 = null;
         }
         super.dispose();
      }
      
      private function initSessionData() : void
      {
         UnknownVarFromSessionDataManager_IgnoredUsersManager_1.initIgnoreList();
         UnknownVarFromSessionDataManager_BlockedUsersManager_1.initBlockList();
         send(new GetUserNftChatStylesMessageComposer());
         send(new GetDailyTasksComposer());
         getIncomeRewardStatus();
      }
      
      private function initBadgeImageManager() : void
      {
         if(UnknownVarFromSessionDataManager_BadgeImageManager_1 != null)
         {
            return;
         }
         UnknownVarFromSessionDataManager_BadgeImageManager_1 = new BadgeImageManager(assets,events,this);
      }
      
      private function initFurniIconImageManager() : void
      {
         if(UnknownVarFromSessionDataManager_FurniIconImageManager_1 != null)
         {
            return;
         }
         UnknownVarFromSessionDataManager_FurniIconImageManager_1 = new FurniIconImageManager(assets,events,this,this);
      }
      
      private function initFurnitureData(param1:Boolean = true) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc2_:String = null;
         if(UnknownVarFromSessionDataManager_FurnitureDataParser_2)
         {
            UnknownVarFromSessionDataManager_FurnitureDataParser_2.dispose();
            UnknownVarFromSessionDataManager_FurnitureDataParser_2 = null;
         }
         UnknownVarFromSessionDataManager_FurnitureDataParser_2 = new FurnitureDataParser(_floorItems,_wallItems,UnknownVarFromSessionDataManager_Map_1,UnknownVarFromSessionDataManager_Map_2,_localization,param1);
         UnknownVarFromSessionDataManager_FurnitureDataParser_2.addEventListener("FDP_furniture_data_ready",onFurnitureReady);
         if(propertyExists("furnidata.load.url"))
         {
            _loc3_ = getProperty("furnidata.load.url");
            if(_newFurniDataHash != null)
            {
               _loc4_ = int(_loc3_.lastIndexOf("/"));
               _loc2_ = _loc3_.substring(0,_loc4_);
               UnknownVarFromSessionDataManager_FurnitureDataParser_2.loadData(_loc2_ + "/" + _newFurniDataHash);
            }
            else
            {
               UnknownVarFromSessionDataManager_FurnitureDataParser_2.loadData(_loc3_);
            }
         }
      }
      
      private function initProductData() : void
      {
         if(UnknownVarFromSessionDataManager_ProductDataParser_1)
         {
            UnknownVarFromSessionDataManager_ProductDataParser_1.dispose();
            UnknownVarFromSessionDataManager_ProductDataParser_1 = null;
         }
         var _loc1_:String = getProperty("productdata.load.url");
         UnknownVarFromSessionDataManager_ProductDataParser_1 = new ProductDataParser(_loc1_,UnknownVarFromSessionDataManager_Dictionary_1);
         UnknownVarFromSessionDataManager_ProductDataParser_1.addEventListener("PDP_product_data_ready",onProductsReady);
      }
      
      private function onFurnitureReady(param1:Event = null) : void
      {
         UnknownVarFromSessionDataManager_FurnitureDataParser_2.removeEventListener("FDP_furniture_data_ready",onFurnitureReady);
         if(UnknownVarFromSessionDataManager_FurnitureDataParser_1)
         {
            UnknownVarFromSessionDataManager_FurnitureDataParser_1.dispose();
            UnknownVarFromSessionDataManager_FurnitureDataParser_1 = null;
         }
         UnknownVarFromSessionDataManager_FurnitureDataParser_1 = UnknownVarFromSessionDataManager_FurnitureDataParser_2;
         UnknownVarFromSessionDataManager_FurnitureDataParser_2 = null;
         UnknownVarFromSessionDataManager_Boolean_2 = true;
         if(!UnknownVarFromSessionDataManager_Boolean_3)
         {
            UnknownVarFromSessionDataManager_Boolean_3 = true;
            for each(var _loc2_ in _furniDataListeners)
            {
               _loc2_.furniDataReady();
            }
         }
      }
      
      private function onUserRights(param1:IMessageEvent) : void
      {
         var _loc2_:UserRightsMessageEvent = UserRightsMessageEvent(param1);
         _clubLevel = _loc2_.clubLevel != 0 ? 2 : 0;
         UnknownVarFromSessionDataManager_Int_3 = _loc2_.securityLevel;
         _topSecurityLevel = Math.max(_topSecurityLevel,_loc2_.securityLevel);
         _isAmbassador = _loc2_.isAmbassador;
      }
      
      private function onNoobnessLevelEvent(param1:NoobnessLevelMessageEvent) : void
      {
         UnknownVarFromSessionDataManager_Int_4 = param1.noobnessLevel;
         if(UnknownVarFromSessionDataManager_Int_4 != 0)
         {
            context.configuration.setProperty("new.identity","1");
         }
      }
      
      private function onUserObject(param1:IMessageEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:UserObjectEvent = param1 as UserObjectEvent;
         var _loc3_:UserObjectMessageParser = _loc2_.getParser();
         _userId = _loc3_.id;
         _name = _loc3_.name;
         UnknownVarFromSessionDataManager_Int_1 = _loc3_.respectTotal;
         _respectLeft = _loc3_.respectLeft;
         _respectReplenishesLeft = _loc3_.respectReplenishesLeft;
         UnknownVarFromSessionDataManager_Int_2 = _loc3_.maxRespectPerDay;
         _petRespectLeft = _loc3_.petRespectLeft;
         _figure = _loc3_.figure;
         _gender = _loc3_.sex;
         _realName = _loc3_.realName;
         _nameChangeAllowed = _loc3_.nameChangeAllowed;
         _accountSafetyLocked = _loc3_.accountSafetyLocked;
         try
         {
            if(context.displayObjectContainer && propertyExists("environment.id"))
            {
               _loc4_ = getProperty("environment.id");
               _loc4_ = _loc4_.replace("pt","br");
               _loc4_ = _loc4_.replace("en","com");
               context.displayObjectContainer.stage.nativeWindow.title = "HabboAirPlus [" + _loc4_.toUpperCase() + "] | " + _name;
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onUserChange(param1:IMessageEvent) : void
      {
         var _loc2_:UserChangeMessageEvent = param1 as UserChangeMessageEvent;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.id == -1)
         {
            _figure = _loc2_.figure;
            _gender = _loc2_.sex;
         }
      }
      
      private function onFigureUpdate(param1:IMessageEvent) : void
      {
         var _loc2_:FigureUpdateEvent = param1 as FigureUpdateEvent;
         if(_loc2_ == null)
         {
            return;
         }
         _figure = _loc2_.figure;
         _gender = _loc2_.gender;
         HabboWebTools.updateFigure(_figure);
      }
      
      private function onNftChatStyles(param1:IMessageEvent) : void
      {
         var _loc2_:UserNftChatStylesMessageEvent = param1 as UserNftChatStylesMessageEvent;
         if(_loc2_ == null)
         {
            return;
         }
         _nftChatStyles = _loc2_.getParser().chatStyleIds;
      }
      
      private function onPurchasableChatStyles(param1:IMessageEvent) : void
      {
         var _loc2_:UserPurchasableChatStylesMessageEvent = param1 as UserPurchasableChatStylesMessageEvent;
         if(_loc2_ == null)
         {
            return;
         }
         _purchasableChatStyles = _loc2_.getParser().chatStyleIds;
      }
      
      private function onPurchasableChatStyleChanged(param1:IMessageEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:UserPurchasableChatStyleChangedMessageEvent = param1 as UserPurchasableChatStyleChangedMessageEvent;
         if(_loc2_ == null)
         {
            return;
         }
         if(_purchasableChatStyles == null)
         {
            _purchasableChatStyles = new Vector.<int>();
         }
         var _loc3_:int = _loc2_.getParser().styleId;
         if(_loc2_.getParser().added)
         {
            _purchasableChatStyles.push(_loc3_);
         }
         else
         {
            _loc4_ = int(_purchasableChatStyles.indexOf(_loc3_));
            if(_loc4_ != -1)
            {
               _purchasableChatStyles.removeAt(_loc4_);
            }
         }
         events.dispatchEvent(new SessionDataToWidgetEvent("SDTWE_PURCHASABLE_STYLES_UPDATED"));
      }
      
      private function onUserNameChange(param1:IMessageEvent) : void
      {
         var _loc2_:UserNameChangedMessageEvent = param1 as UserNameChangedMessageEvent;
         if(_loc2_ == null || _loc2_.getParser() == null)
         {
            return;
         }
         var _loc3_:UserNameChangedMessageParser = _loc2_.getParser();
         if(_loc3_.webId == _userId)
         {
            _name = _loc3_.newName;
            _nameChangeAllowed = false;
            events.dispatchEvent(new UserNameUpdateEvent(_name));
         }
      }
      
      private function onChangeUserNameResult(param1:ChangeUserNameResultMessageEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:ChangeUserNameResultMessageParser = param1.getParser();
         if(_loc2_.resultCode == ChangeUserNameResultMessageEvent.UnknownVarFromChangeUserNameResultMessageEvent_Int_1)
         {
            try
            {
               if(context.displayObjectContainer && propertyExists("environment.id"))
               {
                  _loc3_ = getProperty("environment.id");
                  _loc3_ = _loc3_.replace("pt","br");
                  _loc3_ = _loc3_.replace("en","com");
                  context.displayObjectContainer.stage.nativeWindow.title = "Habbo " + _loc3_.toUpperCase() + " | " + _loc2_.name;
               }
            }
            catch(e:Error)
            {
            }
            _nameChangeAllowed = false;
            events.dispatchEvent(new UserNameUpdateEvent(_loc2_.name));
         }
      }
      
      private function onMysteryBoxKeys(param1:MysteryBoxKeysMessageEvent) : void
      {
         var _loc2_:MysteryBoxKeysMessageParser = param1.getParser();
         _mysteryBoxColor = _loc2_.boxColor;
         _mysteryKeyColor = _loc2_.keyColor;
         events.dispatchEvent(new MysteryBoxKeysUpdateEvent(_mysteryBoxColor,_mysteryKeyColor));
      }
      
      private function onInClientLink(param1:InClientLinkMessageEvent) : void
      {
         context.createLinkEvent(param1.link);
      }
      
      private function onAccountPreferences(param1:AccountPreferencesEvent) : void
      {
         var _loc2_:AccountPreferencesParser = param1.getParser() as AccountPreferencesParser;
         _isRoomCameraFollowDisabled = _loc2_.roomCameraFollowDisabled;
         _uiFlags = _loc2_.uiFlags;
         events.dispatchEvent(new SessionDataPreferencesEvent(_uiFlags));
      }
      
      private function onEmailStatus(param1:EmailStatusResultEvent) : void
      {
         var _loc2_:EmailStatusParser = param1.getParser() as EmailStatusParser;
         _isEmailVerified = _loc2_.isVerified;
      }
      
      private function onAvailabilityStatus(param1:IMessageEvent) : void
      {
         var _loc2_:AvailabilityStatusMessageParser = (param1 as AvailabilityStatusMessageEvent).getParser();
         if(!_loc6_)
         {
            if(_loc2_ == null)
            {
               if(!_loc7_)
               {
                  return;
               }
               addr90:
               UnknownVarFromSessionDataManager_Boolean_3 = true;
               addr93:
               var _loc5_:int = 0;
               var _loc4_:Array = _furniDataListeners;
               if(!_loc6_)
               {
                  for each(var _loc3_ in _loc4_)
                  {
                     if(!_loc6_)
                     {
                        _loc3_.furniDataReady();
                     }
                  }
               }
               addr89:
            }
            else
            {
               §§push(_loc2_.isOpen);
               if(!_loc7_)
               {
                  _systemOpen = §§pop();
                  if(!_loc7_)
                  {
                     §§push(_loc2_.onShutDown);
                     if(!_loc7_)
                     {
                        _systemShutDown = §§pop();
                        if(!_loc7_)
                        {
                           §§push(UnknownVarFromSessionDataManager_Boolean_2);
                           if(_loc6_)
                           {
                           }
                           addr65:
                           §§pop();
                           if(_loc7_)
                           {
                           }
                        }
                     }
                     addr86:
                     if(§§pop())
                     {
                        if(!_loc6_)
                        {
                           §§goto(addr89);
                        }
                     }
                  }
                  §§goto(addr93);
               }
               if(§§pop())
               {
                  if(!_loc6_)
                  {
                     §§goto(addr65);
                  }
                  addr72:
                  §§push(!§§pop());
                  if(_loc6_)
                  {
                  }
                  §§goto(addr90);
               }
               §§goto(addr86);
            }
            return;
         }
         §§push(UnknownVarFromSessionDataManager_Boolean_3);
         if(!_loc6_)
         {
            §§goto(addr72);
         }
         §§goto(addr86);
      }
      
      private function onPetRespectFailed(param1:PetRespectFailedEvent) : void
      {
         if(param1 == null)
         {
            return;
         }
         _petRespectLeft++;
      }
      
      private function onAccountSafetyLockStatusChanged(param1:AccountSafetyLockStatusChangeMessageEvent) : void
      {
         var _loc2_:AccountSafetyLockStatusChangeMessageParser = param1.getParser();
         _accountSafetyLocked = _loc2_.status == 0;
      }
      
      public function get systemOpen() : Boolean
      {
         return _systemOpen;
      }
      
      public function get systemShutDown() : Boolean
      {
         return _systemShutDown;
      }
      
      public function hasSecurity(param1:int) : Boolean
      {
         return UnknownVarFromSessionDataManager_Int_3 >= param1;
      }
      
      public function get topSecurityLevel() : int
      {
         return _topSecurityLevel;
      }
      
      public function get clubLevel() : int
      {
         return _clubLevel;
      }
      
      public function get hasVip() : Boolean
      {
         return HabboClubLevelEnum.HasVip(_clubLevel);
      }
      
      public function get hasClub() : Boolean
      {
         return HabboClubLevelEnum.HasClub(_clubLevel);
      }
      
      public function get isNoob() : Boolean
      {
         return UnknownVarFromSessionDataManager_Int_4 != 0;
      }
      
      public function get isRealNoob() : Boolean
      {
         return UnknownVarFromSessionDataManager_Int_4 == 2;
      }
      
      public function get userId() : int
      {
         return _userId;
      }
      
      public function get userName() : String
      {
         return _name;
      }
      
      public function get realName() : String
      {
         return _realName;
      }
      
      public function get figure() : String
      {
         return _figure;
      }
      
      public function get isAnyRoomController() : Boolean
      {
         return UnknownVarFromSessionDataManager_Int_3 >= 5;
      }
      
      public function get isAmbassador() : Boolean
      {
         return _isAmbassador;
      }
      
      public function get isEmailVerified() : Boolean
      {
         return _isEmailVerified;
      }
      
      public function setRoomCameraFollowDisabled(param1:Boolean) : void
      {
         _isRoomCameraFollowDisabled = param1;
      }
      
      public function get isRoomCameraFollowDisabled() : Boolean
      {
         return _isRoomCameraFollowDisabled;
      }
      
      public function setFriendBarState(param1:Boolean) : void
      {
         setUIFlag(1,param1);
      }
      
      public function setRoomToolsState(param1:Boolean) : void
      {
         setUIFlag(2,param1);
      }
      
      public function get uiFlags() : int
      {
         return _uiFlags;
      }
      
      private function setUIFlag(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            if(_uiFlags & param1)
            {
               return;
            }
            _uiFlags |= param1;
         }
         else
         {
            if(!(_uiFlags & param1))
            {
               return;
            }
            _uiFlags &= ~param1;
         }
         _communication.connection.send(new SetUIFlagsMessageComposer(_uiFlags));
      }
      
      public function getBadgeImage(param1:String) : BitmapData
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getBadgeImage(param1);
      }
      
      public function getBadgeSmallImage(param1:String) : BitmapData
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getSmallBadgeImage(param1);
      }
      
      public function getBadgeImageAssetName(param1:String) : String
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getBadgeImageAssetName(param1);
      }
      
      public function getBadgeImageSmallAssetName(param1:String) : String
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getSmallScaleBadgeAssetName(param1);
      }
      
      public function requestBadgeImage(param1:String) : BitmapData
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getBadgeImage(param1,"normal_badge",false);
      }
      
      public function getBadgeImageWithInfo(param1:String) : BadgeInfo
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getBadgeImageWithInfo(param1);
      }
      
      private function onAlertClose(param1:UnknownICoreWindowUtils1, param2:WindowEvent) : void
      {
         param1.dispose();
      }
      
      public function getGroupBadgeId(param1:int) : String
      {
         return UnknownVarFromSessionDataManager_HabboGroupInfoManager_1.getBadgeId(param1);
      }
      
      public function send(param1:IMessageComposer) : void
      {
         _communication.connection.send(param1);
      }
      
      public function getGroupBadgeImage(param1:String) : BitmapData
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getBadgeImage(param1,"group_badge");
      }
      
      public function getGroupBadgeSmallImage(param1:String) : BitmapData
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getSmallBadgeImage(param1,"group_badge");
      }
      
      public function getGroupBadgeAssetName(param1:String) : String
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getBadgeImageAssetName(param1,"group_badge");
      }
      
      public function getGroupBadgeSmallAssetName(param1:String) : String
      {
         return UnknownVarFromSessionDataManager_BadgeImageManager_1.getSmallScaleBadgeAssetName(param1,"group_badge");
      }
      
      public function getFurniIconImage(param1:Boolean, param2:int, param3:String) : BitmapData
      {
         return UnknownVarFromSessionDataManager_FurniIconImageManager_1.getFurniIconImage(param1,param2,param3);
      }
      
      public function getFurniIconImageAssetName(param1:Boolean, param2:int, param3:String) : String
      {
         return UnknownVarFromSessionDataManager_FurniIconImageManager_1.getFurniIconImageAssetName(param1,param2,param3);
      }
      
      public function isAccountSafetyLocked() : Boolean
      {
         return _accountSafetyLocked;
      }
      
      public function get communication() : IHabboCommunicationManager
      {
         return _communication;
      }
      
      public function isIgnored(param1:int) : Boolean
      {
         return UnknownVarFromSessionDataManager_IgnoredUsersManager_1.isIgnored(param1);
      }
      
      public function ignoreUser(param1:int) : void
      {
         UnknownVarFromSessionDataManager_IgnoredUsersManager_1.ignoreUser(param1);
      }
      
      public function unignoreUser(param1:int) : void
      {
         UnknownVarFromSessionDataManager_IgnoredUsersManager_1.unignoreUser(param1);
      }
      
      public function isBlocked(param1:int) : Boolean
      {
         return UnknownVarFromSessionDataManager_BlockedUsersManager_1.isBlocked(param1);
      }
      
      public function blockUser(param1:int) : void
      {
         UnknownVarFromSessionDataManager_BlockedUsersManager_1.blockUser(param1);
      }
      
      public function unblockUser(param1:int) : void
      {
         UnknownVarFromSessionDataManager_BlockedUsersManager_1.unblockUser(param1);
      }
      
      public function get respectLeft() : int
      {
         return _respectLeft;
      }
      
      public function get respectReplenishesLeft() : int
      {
         return _respectReplenishesLeft;
      }
      
      public function get petRespectLeft() : int
      {
         return _petRespectLeft;
      }
      
      public function giveRespect(param1:int) : void
      {
         if(param1 >= 0 && _respectLeft > 0)
         {
            send(new RespectUserMessageComposer(param1));
            _respectLeft -= 1;
         }
      }
      
      public function replenishRespect() : void
      {
         send(new ReplenishRespectMessageComposer());
         _respectReplenishesLeft -= 1;
         _respectLeft = UnknownVarFromSessionDataManager_Int_2;
      }
      
      public function giveRespectFailed() : void
      {
         _respectLeft += 1;
      }
      
      public function getCreditVaultStatus() : void
      {
         send(new CreditVaultStatusMessageComposer());
      }
      
      public function getIncomeRewardStatus() : void
      {
         send(new IncomeRewardStatusMessageComposer());
      }
      
      public function withdrawCreditVault() : void
      {
         send(new WithdrawCreditVaultMessageComposer());
      }
      
      public function claimReward(param1:int) : void
      {
         send(new IncomeRewardClaimMessageComposer(param1));
      }
      
      public function givePetRespect(param1:int) : void
      {
         if(param1 >= 0 && _petRespectLeft > 0)
         {
            send(new RespectPetMessageComposer(param1));
            _petRespectLeft -= 1;
         }
      }
      
      public function getProductData(param1:String) : IProductData
      {
         if(!UnknownVarFromSessionDataManager_Boolean_1)
         {
            loadProductData();
         }
         return UnknownVarFromSessionDataManager_Dictionary_1[param1];
      }
      
      public function getFloorItemData(param1:int) : IFurnitureData
      {
         if(_floorItems == null)
         {
            return null;
         }
         return _floorItems.getValue(param1.toString());
      }
      
      public function getFloorItemsDataByCategory(param1:int) : Array
      {
         var _loc2_:Array = [];
         if(_floorItems != null)
         {
            for each(var _loc3_ in _floorItems)
            {
               if(_loc3_.category == param1)
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         return _loc2_;
      }
      
      public function getWallItemData(param1:int) : IFurnitureData
      {
         if(_wallItems == null)
         {
            return null;
         }
         return _wallItems.getValue(param1.toString());
      }
      
      public function getFloorItemDataByName(param1:String, param2:int = 0) : IFurnitureData
      {
         var _loc3_:int = 0;
         if(UnknownVarFromSessionDataManager_Map_1 == null)
         {
            return null;
         }
         var _loc4_:Array = UnknownVarFromSessionDataManager_Map_1.getValue(param1);
         if(_loc4_ != null && param2 <= _loc4_.length - 1)
         {
            _loc3_ = int(_loc4_[param2]);
            return getFloorItemData(_loc3_);
         }
         return null;
      }
      
      public function getWallItemDataByName(param1:String, param2:int = 0) : IFurnitureData
      {
         var _loc3_:int = 0;
         if(UnknownVarFromSessionDataManager_Map_2 == null)
         {
            return null;
         }
         var _loc4_:Array = UnknownVarFromSessionDataManager_Map_2.getValue(param1);
         if(_loc4_ != null && param2 <= _loc4_.length - 1)
         {
            _loc3_ = int(_loc4_[param2]);
            return getWallItemData(_loc3_);
         }
         return null;
      }
      
      public function getAllFloorItemDatas() : Array
      {
         if(_floorItems == null)
         {
            return [];
         }
         return _floorItems.getValues();
      }
      
      public function getAllWallItemDatas() : Array
      {
         if(_wallItems == null)
         {
            return [];
         }
         return _wallItems.getValues();
      }
      
      public function openHabboHomePage(param1:int, param2:String) : void
      {
         var _loc3_:String = null;
         if(propertyExists("link.format.userpage"))
         {
            _loc3_ = getProperty("link.format.userpage");
            _loc3_ = _loc3_.replace("%ID%",String(param1));
            _loc3_ = _loc3_.replace("%username%",param2);
            try
            {
               HabboWebTools.navigateToURL(_loc3_,"habboMain");
            }
            catch(e:Error)
            {
               Logger.log("Error occurred!");
            }
         }
      }
      
      public function pickAllFurniture(param1:int) : void
      {
         var session:IRoomSession;
         var roomId:int = param1;
         if(_roomSessionManager == null || _windowManager == null)
         {
            return;
         }
         session = _roomSessionManager.getSession(roomId);
         if(session == null)
         {
            return;
         }
         if(session.isRoomOwner || isAnyRoomController || session.roomControllerLevel >= 1)
         {
            _windowManager.confirm("${generic.alert.title}","${room.confirm.pick_all}",0,function(param1:UnknownICoreWindowUtils2, param2:WindowEvent):void
            {
               param1.dispose();
               if(param2.type == "WE_OK")
               {
                  sendSpecialCommandMessage(":pickall");
               }
            });
         }
      }
      
      public function resetScores(param1:int) : void
      {
         var session:IRoomSession;
         var roomId:int = param1;
         if(_roomSessionManager == null || _windowManager == null)
         {
            return;
         }
         session = _roomSessionManager.getSession(roomId);
         if(session == null)
         {
            return;
         }
         if(session.isRoomOwner || isAnyRoomController || session.roomControllerLevel >= 1)
         {
            _windowManager.confirm("${generic.alert.title}","${room.confirm.resetscores}",0,function(param1:UnknownICoreWindowUtils2, param2:WindowEvent):void
            {
               param1.dispose();
               if(param2.type == "WE_OK")
               {
                  sendSpecialCommandMessage(":resetscores");
               }
            });
         }
      }
      
      public function ejectAllFurniture(param1:int, param2:String) : void
      {
         var session:IRoomSession;
         var roomId:int = param1;
         var message:String = param2;
         if(_roomSessionManager == null || _windowManager == null)
         {
            return;
         }
         session = _roomSessionManager.getSession(roomId);
         if(session == null)
         {
            return;
         }
         if(session.isRoomOwner || isAnyRoomController || session.roomControllerLevel >= 1)
         {
            _windowManager.confirm("${generic.alert.title}","${room.confirm.eject_all}",0,function(param1:UnknownICoreWindowUtils2, param2:WindowEvent):void
            {
               param1.dispose();
               if(param2.type == "WE_OK")
               {
                  sendSpecialCommandMessage(message);
               }
            });
         }
      }
      
      public function ejectPets(param1:int) : void
      {
         if(_roomSessionManager == null || _windowManager == null)
         {
            return;
         }
         var _loc2_:IRoomSession = _roomSessionManager.getSession(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.isRoomOwner || isAnyRoomController)
         {
            sendSpecialCommandMessage(":ejectpets");
         }
      }
      
      public function pickAllBuilderFurniture(param1:int) : void
      {
         var session:IRoomSession;
         var roomId:int = param1;
         if(_roomSessionManager == null || _windowManager == null)
         {
            return;
         }
         session = _roomSessionManager.getSession(roomId);
         if(session == null)
         {
            return;
         }
         if(session.isRoomOwner || isAnyRoomController || session.roomControllerLevel >= 1)
         {
            _windowManager.confirm("${generic.alert.title}","${room.confirm.pick_all_bc}",0,function(param1:UnknownICoreWindowUtils2, param2:WindowEvent):void
            {
               param1.dispose();
               if(param2.type == "WE_OK")
               {
                  sendSpecialCommandMessage(":pickallbc");
               }
            });
         }
      }
      
      public function loadProductData(param1:UnknownIHabboSessionProduct1 = null) : Boolean
      {
         if(UnknownVarFromSessionDataManager_Boolean_1)
         {
            return true;
         }
         if(param1 && _productDataListeners.indexOf(param1) == -1)
         {
            _productDataListeners.push(param1);
         }
         return false;
      }
      
      public function addProductsReadyEventListener(param1:UnknownIHabboSessionProduct1) : void
      {
         if(UnknownVarFromSessionDataManager_Boolean_1)
         {
            param1.productDataReady();
            return;
         }
         if(param1 && _productDataListeners.indexOf(param1) == -1)
         {
            _productDataListeners.push(param1);
         }
      }
      
      private function onProductsReady(param1:Event) : void
      {
         UnknownVarFromSessionDataManager_ProductDataParser_1.removeEventListener("PDP_product_data_ready",onProductsReady);
         UnknownVarFromSessionDataManager_Boolean_1 = true;
         for each(var _loc2_ in _productDataListeners)
         {
            if(_loc2_ != null && !_loc2_.disposed)
            {
               _loc2_.productDataReady();
            }
         }
         _productDataListeners = [];
      }
      
      private function onRoomReady(param1:IMessageEvent) : void
      {
         var _loc3_:RoomReadyMessageEvent = param1 as RoomReadyMessageEvent;
         if(_loc3_ == null || _loc3_.getParser() == null || param1.connection == null)
         {
            return;
         }
         var _loc2_:RoomReadyMessageParser = _loc3_.getParser();
         HabboWebTools.roomVisited(_loc2_.roomId);
      }
      
      public function sendSpecialCommandMessage(param1:String) : void
      {
         send(new ChatMessageComposer(param1));
      }
      
      public function get roomSessionManager() : IRoomSessionManager
      {
         return _roomSessionManager;
      }
      
      public function get windowManager() : IHabboWindowManagerComponent
      {
         return _windowManager;
      }
      
      public function get gender() : String
      {
         return _gender;
      }
      
      public function set newFurniDataHash(param1:String) : void
      {
         _newFurniDataHash = param1;
      }
      
      public function refreshFurniData() : void
      {
         _floorItems = new Map();
         _wallItems = new Map();
         UnknownVarFromSessionDataManager_Map_1 = new Map();
         UnknownVarFromSessionDataManager_Map_2 = new Map();
         initFurnitureData(false);
      }
      
      public function removeFurniDataListener(param1:UnknownIHabboSessionFurniture1) : void
      {
         if(!_furniDataListeners)
         {
            return;
         }
         var _loc2_:int = int(_furniDataListeners.indexOf(param1));
         if(_loc2_ > -1)
         {
            _furniDataListeners.splice(_loc2_,1);
         }
      }
      
      public function getFurniData(param1:UnknownIHabboSessionFurniture1) : Vector.<IFurnitureData>
      {
         if(_floorItems == null || _floorItems.length == 0)
         {
            if(_furniDataListeners.indexOf(param1) == -1)
            {
               _furniDataListeners.push(param1);
            }
            return null;
         }
         return Vector.<IFurnitureData>(_floorItems.getValues().concat(_wallItems.getValues()));
      }
      
      public function getXmlWindow(param1:String) : IWindowModel
      {
         var _loc4_:ISoundAsset = null;
         var _loc2_:XmlAsset = null;
         var _loc3_:IWindowModel = null;
         try
         {
            _loc4_ = assets.getAssetByName(param1);
            _loc2_ = XmlAsset(_loc4_);
            _loc3_ = _windowManager.buildFromXML(XML(_loc2_.content));
         }
         catch(e:Error)
         {
         }
         return _loc3_;
      }
      
      public function get localization() : IHabboLocalizationManager
      {
         return _localization;
      }
      
      public function get nameChangeAllowed() : Boolean
      {
         return _nameChangeAllowed;
      }
      
      public function get perksReady() : Boolean
      {
         return UnknownVarFromSessionDataManager_PerkManager_1 != null && UnknownVarFromSessionDataManager_PerkManager_1.isReady;
      }
      
      public function isPerkAllowed(param1:String) : Boolean
      {
         return UnknownVarFromSessionDataManager_PerkManager_1.isPerkAllowed(param1);
      }
      
      public function getPerkErrorMessage(param1:String) : String
      {
         return UnknownVarFromSessionDataManager_PerkManager_1.getPerkErrorMessage(param1);
      }
      
      public function get currentTalentTrack() : String
      {
         return getBoolean("talent.track.citizenship.enabled") && !isPerkAllowed("CITIZEN") ? "citizenship" : "helper";
      }
      
      public function get mysteryBoxColor() : String
      {
         return _mysteryBoxColor;
      }
      
      public function get mysteryKeyColor() : String
      {
         return _mysteryKeyColor;
      }
      
      public function hasNftChatStyle(param1:int) : Boolean
      {
         return _nftChatStyles != null && _nftChatStyles.indexOf(param1) != -1;
      }
      
      public function hasPurchasableChatStyle(param1:int) : Boolean
      {
         return _purchasableChatStyles != null && _purchasableChatStyles.indexOf(param1) != -1;
      }
      
      public function get notifications() : IHabboNotifications
      {
         return _notifications;
      }
   }
}

