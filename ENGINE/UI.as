package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class UI extends MovieClip {
		
		private static var _instance:UI;
		public var inventoryCache:Array;
		public var windows:MovieClip;
		private var _activeShopId:int;
		public var loadedInventory:Boolean;
		private var cooldowns:Array = [0,0,0,0,0];
		private var cooldownTimer:Timer = new Timer(250);
		private var roomList:RoomList = new RoomList();
		private var duelRequest:DuelRequest;
		private var clickMenu:ClickMenu;
		private var duelId:int;
		
		
		public function UI() {
			if(_instance){
				throw new Error("Server: Called illegal instanciation of singleton! Use .instance");
			}
			_instance = this;
			visible = false;
			windows = this.windowsMC;
			windows.mouseEnabled = false;
			dead_screen.visible = false;
			this.mouseEnabled = false;
			qTracker.txtTracker.mouseEnabled = false;
			qTracker.mouseChildren = false;
			qTracker.mouseEnabled = false;
			
			windows.addEventListener(MouseEvent.CLICK, windowClickHandler);
			actionbar.addEventListener(MouseEvent.CLICK, actionbarClickHandler);
			actionbar.addEventListener(MouseEvent.MOUSE_OVER, actionbarHoverHandler);
			actionbar.addEventListener(MouseEvent.MOUSE_OUT, actionbarOutHandler);
			cooldownTimer.addEventListener(TimerEvent.TIMER, cooldownTimerTick);
			previewWindow.addEventListener(MouseEvent.MOUSE_DOWN, pWDragDOWN);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpH);
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			inventoryCache = [];
			loadedInventory = false;
			hideTargetFrame();
			for(var i:int = 1; i <= 5; i++){
				MovieClip(actionbar.getChildByName("slot"+i)).txtCooldown.text = "";
				//MovieClip(actionbar)["txtKey"+i].text = i.toString();
				//MovieClip(actionbar)["txtKey"+i].mouseEnabled = false;
			}
			//setupMenuButtons();
			addChild(roomList);
			qTracker.header.gotoAndStop(1);
			visible = true;
		}
		public function destroy(){
			roomList.destroy();
			windows.removeEventListener(MouseEvent.CLICK, windowClickHandler);
			actionbar.removeEventListener(MouseEvent.CLICK, actionbarClickHandler);
			actionbar.removeEventListener(MouseEvent.MOUSE_OVER, actionbarHoverHandler);
			actionbar.removeEventListener(MouseEvent.MOUSE_OUT, actionbarOutHandler);
			cooldownTimer.removeEventListener(TimerEvent.TIMER, cooldownTimerTick);
			previewWindow.removeEventListener(MouseEvent.MOUSE_DOWN, pWDragDOWN);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpH);
			removeEventListener(MouseEvent.CLICK, clickHandler);
			_instance = null;
		}
		public function set isDead(e:Boolean){
			dead_screen.visible = e;
			if(e){
				dead_screen.gotoAndPlay(1);
				Utils.delayFunction(10, gotoRespawn);
			} else {
				dead_screen.gotoAndStop(1);
			}
		}
		private function gotoRespawn(){
			dead_screen.gotoAndStop(243);
		}
		public function get roomListIsActive():Boolean {
			return roomList.visible;
		}
		public function get clickMenuIsActive():Boolean {
			return (clickMenu != null);
		}
		private function pWDragDOWN(e:MouseEvent){
			if(e.target.name == "btnDrag"){
				previewWindow.holder.startDrag();
			}
		}
		function invMouseDownHandler(e:MouseEvent):void
		{
			e.currentTarget.startDrag();
		}
		function invMouseUpHandler(e:MouseEvent):void
		{
			e.currentTarget.stopDrag();
		}
		private function mouseUpH(e:MouseEvent){
			previewWindow.holder.stopDrag();
		}
		private function clickHandler(e:MouseEvent){
			var target:String = e.target.name;
			if(e.target.name == "menuBtn"){
				target = e.target.parent.name;
			}
			switch(target){
				case 'btnMenu':
					showMenu();
				break;
				case 'btnQuestLog':
					showQuestLog();
				break;
				case 'btnMap':
					showMap();
				break;
				case 'btnBags':
					showInventory();
				break;
				case 'btnLogout':
					Game.logout();
				break;
				case 'btnCloseFrame':
					World.instance.target = null;
				break;
				case 'btnRest':
					Server.instance.rest();
				break;
				case 'btnGFXHigh':
					MovieClip(this.parent).setQuality(1);
				break;
				case 'btnGFXMedium':
					MovieClip(this.parent).setQuality(2);
				break;
				case 'btnGFXLow':
					MovieClip(this.parent).setQuality(3);
				break;
				case 'btnToggleSound':
					Main.toggleMute();
				break;
				case 'btnRespawnMe':
					Server.instance.respawnMe();
				break;
				case 'btnFullscreen':
					Main.toggleFullscreen();
				break;
				case 'btnClosePreview':
					closePreviewWindow();
				break;
				case 'targetFrameButton':
					if(World.instance.target != null && World.instance.target.isPlayer){
						UI.instance.showClickMenu("-1", targetFrameMenuH, ["Whisper", "Duel", "Cancel"]);
					}
				break;
				
				case "btnHax":
					//Server.instance.sendXt("a" + 1, [1, 0], "str");
					//Server.instance.sendXt("a" + 1, [[0], 0], "str");
					Server.instance.sendXt("givegold", [10000], "str");
				break;
				case 'btnDuelAccept':
					acceptDuel();
				break;
				case 'btnDuelDecline':
					declineDuel();
				break;
			}
		}
		private function actionbarClickHandler(e:MouseEvent){
			switch(e.target.parent.name){
				case 'slot1':
					World.instance.startAutoAttack();
				break;
				case 'slot2':
					Game.useAbility(2);
				break;
				case 'slot3':
					Game.useAbility(3);
				break;
				case 'slot4':
					Game.useAbility(4);
				break;
				case 'slot5':
					Game.useAbility(5);
				break;
			}
		}
		private function windowClickHandler(e:MouseEvent){
			switch(e.target.name){
				case 'btnClose':
					closeWindows();
				break;
				case 'btnPortal':
					Server.instance.enterZone("portal");
				break;
				
				case 'btnSwamp':
					Server.instance.enterZone("swamp");
				break;
				case 'btnInn':
					Server.instance.enterZone("inn");
				break;
				case 'btnForest':
					Server.instance.enterZone("valthron");
				break;
				case 'btnCastle':
					Server.instance.enterZone("castle");
				break;
				
			}
		}
		public function setupMenuButtons(){
			//menuMC.btnMap.icon.gotoAndStop("map");
			//menuMC.btnMap.txtName.text = "Map";
			
			//menuMC.btnMenu.icon.gotoAndStop("menu");
			//menuMC.btnMenu.txtName.text = "Menu";
			
			//menuMC.btnBags.icon.gotoAndStop("bag");
			//menuMC.btnBags.txtName.text = "Bags";
			
			//menuMC.btnQuestLog.icon.gotoAndStop("quest_log");
			//menuMC.btnQuestLog.txtName.text = "Quests";
		}
		public function actionbarHoverHandler(e:MouseEvent){
			if(e.target.parent.name.indexOf("slot") > -1){
				var id:int = Number(e.target.parent.name.replace("slot", ""));
				var tt:String = Game.getAbilityTooltip(id - 1);
				if(tt.length > 0){
					Tooltip.instance.show(900, 365, tt);
				}
			}
		}
		public function actionbarOutHandler(e:MouseEvent){
			Tooltip.instance.hide();
		}
		private function targetFrameMenuH(d:String, o:String){
			switch(d){
				case 'Duel':
					if(World.instance.target != null && World.instance.target.isPlayer){
						Server.instance.duelTarget();
					}
				break;
				case 'Whisper':
					if(World.instance.target != null && World.instance.target.isPlayer){
						Chatbox.instance.whisperText(World.instance.target.displayName);
					}
				break;
			}
		}
		public function showMap(){
			if(windows.currentLabel != "Map"){
				closeWindows();
				windows.gotoAndStop("Map");
			} else {
				closeWindows();
			}
		}
		public function showMenu(){
			if(windows.currentLabel != "Menu"){
				closeWindows();
				windows.gotoAndStop("Menu");
			} else {
				closeWindows();
			}
		}
		public function closeWindows(){
			closeClickMenu()
			closePreviewWindow();
			if(windows.currentLabel == "Shop"){
				shop.destroy();
			} else if(windows.currentLabel == "Quest"){
				questLog.destroy();
			} else if(windows.currentLabel == "Inventory"){
				inventory.reset();
			}
			windows.gotoAndStop("Blank");
			Main.STAGE.stage.focus = Main.STAGE.stage;
			_activeShopId = 0;
		}
		public static function get instance():UI{
			return _instance;
		}
		public function get activeShopId():int{
			return _activeShopId;
		}
		public function finishedPurchase(success:Boolean = false, id:int = 0){
			if(windows.currentFrameLabel == "Shop"){
				shop.finishedPurchase(success, id);
			}
		}
		public function showToast(data:Object, type:int = 1){
			var toast:ItemRecievedToast;
			toast = new ItemRecievedToast();
			toast.y = (-60 - 25) * toastHolder.numChildren;
			toast.showToast(data);
			toastHolder.addChild(toast);
		}
		public function handleShopData(data:*){
			closeWindows();
			Tooltip.instance.hide();
			windows.gotoAndStop("Shop");
			_activeShopId = data.id;
			shop.reset();
			shop.display(data);
			Server.instance.getInventory();
		}
		public function openInventory(){
			handleInventoryData();
		}
		public function handleInventoryData(data:* = null){
			if(windows.currentFrameLabel != "Shop" && windows.currentFrameLabel != "Inventory"){
				windows.gotoAndStop("Inventory");
			}
			if(data != null){
				this.loadedInventory = true;
				inventoryCache = data.items;
			}
			var inventory:Inventory = this.inventory;
			inventory.reset();
			for(var i:int = 0; i < inventoryCache.length; i++){
				inventory.displayItem(inventoryCache[i])
			}
			inventory.display();
		}
		public function removeItemFromInventory(id:int, stackSize:int, sold:Boolean = false){
			getCachedItemById(id).sN -= stackSize;
			if(sold){
				ClientInfo.data.gold += getCachedItemById(id).sell * stackSize;
			}
			if(Number(getCachedItemById(id).sN) < 1){
				removeItemFromCache(id);
			}
			openInventory();
		}
		public function get inventory():Inventory{
			//windows.getChildByName("inventory_window").addEventListener(MouseEvent.MOUSE_DOWN, invMouseDownHandler);
			//windows.getChildByName("inventory_window").addEventListener(MouseEvent.MOUSE_UP, invMouseUpHandler);
			
			return windows.getChildByName("inventory_window") as Inventory;
		}
		public function get previewWindow():PreviewWindow{
			return getChildByName("itemPreviewWindow") as PreviewWindow;
		}
		public function get shop():Shop{
			return windows.getChildByName("shop_window") as Shop;
		}
		public function get questLog():QuestLog{
			return windows.getChildByName("quest_log") as QuestLog;
		}
		public function get npcUI():NpcUI{
			return windows.getChildByName("npc_UI") as NpcUI;
		}
		
		public function inventoryHasId(id:int):Boolean {
			if(inventoryCache){
				for(var i:int = 0; i < inventoryCache.length; i++){
					if(inventoryCache[i].id == id){
						return true;
					}
				}
			}
			return false;
		}
		public function removeItemFromCache(id:int) {
			if(inventoryCache){
				for(var i:int = 0; i < inventoryCache.length; i++){
					if(inventoryCache[i].id == id){
						inventoryCache.splice(i, 1);
					}
				}
			}
		}
		public function getCachedItemById(id:int):Object{
			if(inventoryCache){
				for(var i:int = 0; i < inventoryCache.length; i++){
					if(inventoryCache[i].id == id){
						return inventoryCache[i];
					}
				}
			}
			return null;
		}
		public function showTargetFrame(){
			hideTargetFrame();
			targetFrame.gotoAndStop(2);
			targetFrame.txtName.text = World.instance.target.displayName;
			targetFrame.txtLevel.text = "" + World.instance.target.level;
			Utils.emptyObject(targetFrame.portrait.base);
			if(World.instance.target.portrait != null){
				World.instance.target.portrait.scaleX = -1;
				targetFrame.portrait.base.addChild(World.instance.target.portrait);
				
			}
			//if(World.instance.target.type != 0){
				//targetFrame.portrait.gotoAndStop(Number(World.instance.target.type) + 1)
			//} show elite portrait if target type is elite (type > 1)
			updateTargetFrame();			
			targetFrame.visible = true;
		}
		public function hideTargetFrame(){
			targetFrame.visible = false;
			targetFrame.portrait.gotoAndStop(1);
		}
		public function updateTargetFrame(){
			targetFrame.hpBar.gotoAndStop(100 - Math.round(World.instance.target.health / World.instance.target.maxHealth * 100));
			targetFrame.rpBar.gotoAndStop(1);
			targetFrame.txtHealth.text = World.instance.target.health + "/" + World.instance.target.maxHealth
		}
		
		public function showPlayerFrame(){
			//playerFrame.btnCloseFrame.visible = false;
			//playerFrame.btnCloseFrame.enabled = false;
			playerFrame.txtName.text = World.instance.playerUnit.displayName;
			txtLevel.text = "Level " + ClientInfo.data.level;
			Utils.emptyObject(playerFrame.portrait.base);
			if(World.instance.playerUnit.portrait != null){
				playerFrame.portrait.base.addChild(World.instance.playerUnit.portrait);
				playerFrame.portrait.scaleX = 1;
				/*playerFrame.portrait.base.width = 229.4 / 2.5;
				playerFrame.portrait.base.height = 339.4 / 2.5;*/
				//trace(playerFrame.portrait.base.x);
				//playerFrame.portrait.base.x = 60;
				//playerFrame.portrait.base.y = 20;
			}
			updatePlayerFrame();			
			playerFrame.visible = true;
		}
		public function updatePlayerFrame(){
			playerFrame.hpBar.gotoAndStop(100 - Math.round(World.instance.playerUnit.health / World.instance.playerUnit.maxHealth * 100));
			playerFrame.rpBar.gotoAndStop(1);
			playerFrame.txtHealth.text = World.instance.playerUnit.health + "/" + World.instance.playerUnit.maxHealth
		}
		public function pushCooldown(num:int, length:Number){
			if(length > Game.GLOBAL_COOLDOWN){
				MovieClip(actionbar.getChildByName("slot"+(num))).cooldownAnimation.gotoAndStop(15);
				cooldowns[num - 1] = length;
				if(cooldownArrayLength == 1){
					cooldownTimer.start();
				}
			} else {
				MovieClip(actionbar.getChildByName("slot"+(num))).cooldownAnimation.gotoAndPlay(1)
			}
		}
		private function get cooldownArrayLength():int{
			var i:int = 0;
			for(var e:int = 0; e < cooldowns.length; e++){
				if(cooldowns[e] > 0){
					i++;
				}
			}
			return i;
		}
		private function cooldownTimerTick(e:TimerEvent){
			if(cooldownArrayLength < 1){
				cooldownTimer.stop();
			}
			for(var i:int = 0; i < cooldowns.length; i++){
				if(cooldowns[i] > 0){
					cooldowns[i] -= .25;
					if(cooldowns[i] < 1){
						cooldowns[i] = 0;
					} else {
						MovieClip(actionbar.getChildByName("slot"+(i+1))).txtCooldown.text = Math.round(cooldowns[i]).toString();
					}
					if(cooldowns[i] < 0.75 && MovieClip(actionbar.getChildByName("slot"+(i+1))).cooldownAnimation.currentFrame == 15){
						MovieClip(actionbar.getChildByName("slot"+(i+1))).cooldownAnimation.play();
					} else {
						MovieClip(actionbar.getChildByName("slot"+(i+1))).cooldownAnimation.gotoAndStop(15);
					}
				} else {
					MovieClip(actionbar.getChildByName("slot"+(i+1))).txtCooldown.text = "";
				}
			}
			
		}
		public function globalCooldown(){
			for(var i:int = 0; i < 5; i++){
				if(MovieClip(actionbar.getChildByName("slot"+(i+1))).cooldownAnimation.currentFrame == 1){
					MovieClip(actionbar.getChildByName("slot"+(i+1))).cooldownAnimation.play();
				}
			}
		}
		public function updateAbilityIcons(){
			actionbar.gotoAndPlay(2);
			for(var i:int = 0; i < 5; i++){
				if(ClientInfo.data.abilities != null && ClientInfo.data.abilities[i] != null){
					var slot:MovieClip = MovieClip(actionbar.getChildByName("slot"+(i+1)));
					Utils.emptyObject(slot.iconHolder);
					slot.iconHolder.mouseChildren = false;
					slot.iconHolder.mouseEnabled = false;
					var newIcon:MovieClip = Utils.getIconAsset(ClientInfo.data.abilities[i].icon);
					newIcon.mouseChildren = false;
					newIcon.mouseEnabled = false;
					slot.iconHolder.addChild(newIcon);
				}
			}
			refreshAbilityAvailability();
		}
		public function refreshAbilityAvailability(){
			for(var i:int = 0; i < 5; i++){
				if(ClientInfo.data.abilities != null && ClientInfo.data.abilities[i] != null){
					var slot:MovieClip = MovieClip(actionbar.getChildByName("slot"+(i+1)));
					if(Number(ClientInfo.data.abilities[i].lvlreq) > ClientInfo.data.level){
						slot.cooldownAnimation.gotoAndStop(10);
					} else {
						if(slot.cooldownAnimation.currentFrame == 10){
							slot.cooldownAnimation.gotoAndStop(1);
						}
					}
					
				}
			}
		}
		public function showNpcUI(){
			windows.gotoAndStop("NpcUI");
			npcUI.reset();
		}
		public function showInventory(){
			if(windows.currentFrameLabel != "Inventory"){
				Server.instance.getInventory();
			} else {
				closeWindows();
			}
		}
		public function showRoomList(){
			roomList.show(World.instance.getPlayerListAsString())
		}
		public function displayQuest(data:Object, state:int){
			if(windows.currentFrameLabel != "Quest"){
				closeWindows();
			}
			windows.gotoAndStop("Quest");
			questLog.displayQuest(data, state);
		}
		public function displayQuestList(data:Object){
			closeWindows();
			windows.gotoAndStop("Quest");
			questLog.displayQuestList(data);
			
		}
		public function showQuestLog(){
			if(windows.currentLabel != "Quest"){
				closeWindows();
				windows.gotoAndStop("Quest");
				questLog.displayQuestLog();
			} else {
				closeWindows();
			}
			
		}
		public function showClickMenu(data:String, func:Function, options:Array, x:Number = -1.1359, y:Number = -1.1359){
			if(clickMenu != null){
				clickMenu.destroy();
			}
			if(x == -1.1359 && y == -1.1359){
				x = Main.STAGE.stage.mouseX;
				y = Main.STAGE.stage.mouseY;
			}
			clickMenu = new ClickMenu(x, y, options, func, data);
		}
		public function destroyClickMenu(){
			clickMenu = null;
		}
		public function closeClickMenu(){
			if(clickMenu != null){
				clickMenu.destroy();
			}
		}
		public function updateQuestTracker(){
			qTracker.txtTracker.text = "";
			//qTracker.txtTracker.text += "\n";
			var quests:Array = ClientInfo.data.getQuestLog();
			
			if(quests.length > 0){
				if(qTracker.header.currentFrame == 1){
					qTracker.header.gotoAndPlay(2);
				}
			} else {
				qTracker.header.gotoAndStop(1);
			}
			
			for(var i:int = 0; i < quests.length; i++){
				var quest:Object = quests[i];
				var objs:Array = quest.objs.split(",");
				
				qTracker.txtTracker.text += quest.name;
				if(ClientInfo.data.activeQuestIsComplete(quest.id)){
					qTracker.txtTracker.text += "\n      Ready for turn in.";
					qTracker.txtTracker.text += "\n";
					continue;
				}
				for(var v:int = 0; v < objs.length; v++){
					var obj:Array = objs[v].split(":");
					var qObj:Array = ClientInfo.data.getQuestObjective(obj[0])
					qTracker.txtTracker.text += "\n      " + qObj[0] +"/"+ qObj[1] +" "+ qObj[2];
					if(Number(qObj[0]) >= Number(qObj[1])){
						qTracker.txtTracker.text += " (Complete)";
					}
				}
				qTracker.txtTracker.text += "\n";
			}
		}
		public function itemMenuHandler(name:String, data:String){
			switch(name){
				case "Sell":
					Server.instance.sellItem(Number(data));
				break;
				
				case "Use":
				case "Equip":
				case "Consume":
					Server.instance.useItem(Number(data));
				break;
				
				case "Preview":
					Server.instance.previewItem(Number(data));
				break;
				
				case "Buy":
					Server.instance.buyItem(Number(data));
					this.shop.startPurchase();
				break;
			}
		}
		public function updateXPBar(){
			xpBar.gotoAndStop(100 - Math.round(ClientInfo.data.xp / ClientInfo.data.xpMax * 100));
			//txtXP.text = ClientInfo.data.xp +"/"+ ClientInfo.data.xpMax
		}
		public function showPreviewWindow(file:String, type:String){
			previewWindow.show(file, type);
		}
		public function closePreviewWindow(){
			previewWindow.close();
		}
		public function closeDuelRequest(b:Boolean = false, i:int = 0){
			if(b == true){
				if(i != duelId){
					return;
				}
			}
			if(duelRequest != null){
				duelRequest.destroy();
			}
		}
		public function removeDuelRequest(){
			removeChild(duelRequest);
			duelRequest = null;
			duelId = -1;
		}
		public function showDuelRequest(id:int){
			if(duelRequest == null){
				closeDuelRequest();
				duelRequest = new DuelRequest();
				addChild(duelRequest);
				duelId = id;
			} else {
				trace("auto declining duel");
				Server.instance.sendXt("dlDc", [id, 1], "str");
			}
		}
		private function acceptDuel(){
			if(duelId != -1){
				Server.instance.sendXt("dlAc", [duelId], "str");
				closeDuelRequest();
			}
		}
		public function declineDuel(){
			if(duelId != -1){
				Server.instance.sendXt("dlDc", [duelId], "str");
				closeDuelRequest();
			}
		}
	}
	
}
