package  {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.util.File;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.filters.GlowFilter;
	import flash.system.ApplicationDomain;
	
	public class World extends MovieClip {
		
		private const canTargetSelf:Boolean = false;
		
		public var map:MovieClip;
		public var mapAppD:ApplicationDomain;
		public var cell:MovieClip;
		public var playerUnit:Unit;
		public var users:Object = {};
		public var userUnits:Array = [];
		public var enemies:Object = {};
		public var enemyUnits:Array = [];
		public var currentRoom:String = "";
		public var defaultRoom:String;
		public var gotoPad:String;
		public var armorCache:Object;
		public var weaponCache:Object;
		public var nextRoomPad:String;
		
		private var speed:Number;
		private var initComplete:Boolean = false;
		private var movementPads:Array;
		private var barrierBlocks:Array;
		
		private var keyDownLeft:Boolean = false;
		private var keyDownRight:Boolean = false;
		private var keyDownUp:Boolean = false;
		private var keyDownDown:Boolean = false;
		private var stoppedMove:Boolean = false;
		private var sendPosTimer:Timer;
		private var props:Array
		private var spawnPads:Array;
		
		private var lastSentX:int;
		private var lastSentY:int;
		
		private var enemyFileList:Array;
		private var enemyFiles:Object;
		private var dynamicEnemyIds:Array;
		private var __target:Unit;
		private var selectedTargetGlowEnemy:GlowFilter = new GlowFilter(0xCC0000,0.6,3,3,5);
		private var selectedTargetGlowPlayer:GlowFilter = new GlowFilter(0xCCCCCC,0.6,3,3,5);
		private var autoAttackTimer:Timer = new Timer(1000);
		private var lastJoinZone:Number = -1;
		
		
		public var isPvPZone:Boolean = false;
		
		private static var _instance:World;
		
		public function World() {
			_instance = this;
			sendPosTimer = new Timer(250);
			Main.STAGE.addEventListener(Event.DEACTIVATE, stageLostFocus);
			autoAttackTimer.addEventListener(TimerEvent.TIMER, autoAttack);
		}
		public function destroy(){
			Main.STAGE.removeEventListener(Event.DEACTIVATE, stageLostFocus);
			this.disableMovement();
			disableSorting();
			if(target != null && target.hasEventListener("Update")){
				target.removeEventListener("Update", targetUpdate)
			}
			if(playerUnit != null && playerUnit.hasEventListener("Update")){
				playerUnit.removeEventListener("Update", playerInfoUpdated);
			}
			if(autoAttackTimer.hasEventListener(TimerEvent.TIMER)){
				autoAttackTimer.removeEventListener(TimerEvent.TIMER, autoAttack);
			}
			_instance = null;
		}
		public function reset(_map:MovieClip){
			if(playerUnit != null && playerUnit.hasEventListener("Update")){
				playerUnit.removeEventListener("Update", playerInfoUpdated);
			}
			disableMovement();
			disableSorting();
			if(this.cell != null){
				this.map.removeChild(cell);
			}
			if(this.map != null){
				this.removeChild(map);
			}
			clearZone();
			armorCache = new Object();
			weaponCache = new Object();
			cell = null;
			userUnits = [];
			users = {};
			enemyUnits = [];
			enemies = {};
			movementPads = [];
			barrierBlocks = [];
			props = [];
			dynamicEnemyIds = [];
			
			
			playerUnit = new Unit(ClientInfo.data.health, ClientInfo.data.maxHealth);
			playerUnit.gender = ClientInfo.data.gender;
			playerUnit.access = ClientInfo.data.access;
			playerUnit.isPlayer = true;
			playerUnit.displayName = ClientInfo.data.name;
			playerUnit.id = ClientInfo.data.id;
			playerUnit.addEventListener("Update", playerInfoUpdated);
			if(ClientInfo.data.weaponAD != null){
				playerUnit.displayWeapon(ClientInfo.data.weaponAD, true);
			}
			if(ClientInfo.data.armorAD != null){
				playerUnit.displayArmor(ClientInfo.data.armorAD, true);
			}
			
			
			map = _map;
			
			if(map.hasOwnProperty("world")){
				map.world = this;
			} 
			if(map.hasOwnProperty("music")){
				Main.soundChannel = map.music.play();
			} 
			this.addChild(map);
		}
		public function gotoZone(name:String, pad:String = "", room:String = ""){
			Server.instance.enterZone(name, pad, room);
		}
		public function gotoRoom(roomName:String, padName:String = "", direction:String = ""){
			if(padName == ""){
				padName = "padSpawn";
			}
			disableMovement();
			disableSorting();
			clearProps();
			movementPads = [];
			props = [];
			spawnPads = [];
			barrierBlocks = [];
			target = null;
			map.gotoAndStop(roomName);
			
			if(map.hasOwnProperty("cell")){
				cell = map.cell;
			} else {
				throw new Error("Map did not contain cell!");
			}

			
			if(map.hasOwnProperty("size")){
				playerUnit.size = map.size;
			}
			if(map.hasOwnProperty("speed")){
				
				playerUnit.speed = map.speed;
			}
			speed = playerUnit.speed;
			
			var i:int;
			for(i = 0; i < map.numChildren; i++){
				if(map.getChildAt(i) is MovieClip){
					if(MovieClip(map.getChildAt(i)).hasOwnProperty("roomName") && MovieClip(map.getChildAt(i)).hasOwnProperty("padName")){
						movementPads.push(MovieClip(map.getChildAt(i)));
					} else if(MovieClip(map.getChildAt(i)).hasOwnProperty("barrier")){
						barrierBlocks.push(MovieClip(map.getChildAt(i)));
					} else if(MovieClip(map.getChildAt(i)).hasOwnProperty("zoneName")){
						movementPads.push(MovieClip(map.getChildAt(i)));
					} else if(MovieClip(map.getChildAt(i)).hasOwnProperty("isProp")){
						props.push(MovieClip(map.getChildAt(i)));
					} else if(MovieClip(map.getChildAt(i)).hasOwnProperty("isSpawnPad")){
						spawnPads.push(MovieClip(map.getChildAt(i)));
					}
					
				}
			}
			playerUnit.killMove();
			var pad:MovieClip = MovieClip(map.getChildByName(padName));
			if(pad != null){
				playerUnit.pos = pad;
			} else if(spawnPads.length > 0){
				playerUnit.pos = spawnPads[0];
			} else {
				playerUnit.x = Main.STAGE_WIDTH / 2;
				playerUnit.y = Main.STAGE_HEIGHT / 2;
			}
			if(direction != "" && direction != "normal"){
				playerUnit.direction = direction;
			}
			
			playerUnit.id = ClientInfo.data.id;
			cell.addChild(playerUnit);
			currentRoom = roomName;
			displayRoom();
			if(initComplete == true){
				Server.instance.sendPos(playerUnit.x, playerUnit.y, playerUnit.dirAsInt, this.currentRoom);
			}
			enableMovement();
			enableSorting();
			UI.instance.showPlayerFrame();
		}
		private function sendPosNow(e:TimerEvent){
			if(e != null){
				var newX:int = Math.round(playerUnit.x)
				var newY:int = Math.round(playerUnit.y)
				if(lastSentX != 0){
					
					if(Math.abs(lastSentX - newX) < 70 && lastSentX != newX){
						if(lastSentX < newX){
							newX += 200;
						} else {
							newX -= 200;
						}
					}
					if(Math.abs(lastSentY - newY) < 70 && lastSentY != newY){
						if(lastSentY < newY){
							newY += 100;
						} else {
							newY -= 100;
						}
					}
				}
				Server.instance.sendPos(newX, newY, playerUnit.dirAsInt);
				lastSentX = Math.round(playerUnit.x);
				lastSentY = Math.round(playerUnit.y);
			}
		}
		public function enableMovement(){
			Main.STAGE.stage.focus = Main.STAGE.stage;
			this.addEventListener(Event.ENTER_FRAME, update);
			Main.STAGE.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownH);
			Main.STAGE.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpH);
			sendPosTimer.stop();
			sendPosTimer.reset();
			sendPosTimer.addEventListener(TimerEvent.TIMER, sendPosNow);
			if(playerUnit != null && playerUnit.model.currentFrameLabel == playerUnit._runAnimation){
				playerUnit.playIdle();
			}
		}
		public function disableMovement(){
			Main.STAGE.stage.focus = Main.STAGE.stage;
			this.removeEventListener(Event.ENTER_FRAME, update);
			Main.STAGE.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownH);
			Main.STAGE.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpH);
			sendPosTimer.stop();
			sendPosTimer.reset();
			sendPosTimer.removeEventListener(TimerEvent.TIMER, sendPosNow);
			if(playerUnit != null && playerUnit.model.currentFrameLabel == playerUnit._runAnimation){
				playerUnit.playIdle();
			}
		}
		
		private function update(e:Event):void {
			if(Main.STAGE.stage.focus != Chatbox.instance.txtInput){
				if (keyDownLeft && !keyDownRight) {
					playerUnit.x -= playerUnit.speed;
					playerUnit.direction = "left";
				}
				if (keyDownRight && !keyDownLeft) {
					playerUnit.x += playerUnit.speed;
					playerUnit.direction = "right";
				}
				if (keyDownUp && !keyDownDown) {
					playerUnit.y -= playerUnit.speed;
				}
				if (keyDownDown && !keyDownUp) {
					playerUnit.y += playerUnit.speed;
				}
				if((keyDownLeft && !keyDownRight) || (keyDownRight && !keyDownLeft) || (keyDownUp && !keyDownDown) || (keyDownDown && !keyDownUp)){
					stopAutoAttack();
					if(playerUnit.model.currentLabel != playerUnit._runAnimation){
						playerUnit.playRun();
						stoppedMove = false;
						sendPosTimer.stop();
						sendPosTimer.reset();
						sendPosTimer.start();
					}
					if(playerUnit.isMoving){
						playerUnit.killMove();
						stoppedMove = false;
					}
					for(var i:int = 0; i < movementPads.length; i++){
						if(playerUnit.feet.getRect(cell).intersects(movementPads[i].getRect(cell))){
							if(!movementPads[i].hasOwnProperty("zoneName") || movementPads[i].zoneName.length < 1){
								this.gotoRoom(movementPads[i].roomName, movementPads[i].padName);
							} else {
								if(movementPads[i].zoneName != ""){
									if(canChangeZone){
										cancelMoving();
										disableMovement();
										var mP:String = "";
										var mR:String = "";
										
										if(movementPads[i].roomName != null){
											mR = movementPads[i].roomName;
										}
										if(movementPads[i].padName != null){
											mP = movementPads[i].padName;
										}
										Server.instance.enterZone(movementPads[i].zoneName,mP, mR);
									}
								}
							}
						}
					}
					
				} else if(stoppedMove == false){
					playerUnit.playIdle();
					playerUnit.x = Math.round(playerUnit.x);
					playerUnit.y = Math.round(playerUnit.y);
					
					endMove();
				}
			}
		}
		private function sortLoop(e:Event){
			var i:int;
			for(i = 0; i < barrierBlocks.length; i++){
				collisionCheck(playerUnit.feet, MovieClip(barrierBlocks[i]), cell);
			}
			for(var v:int = 0; v < this.userUnits.length; v++){
				for(i = 0; i < barrierBlocks.length; i++){
					collisionCheck(userUnits[v].feet, MovieClip(barrierBlocks[i]), cell);
				}
			}
			sortRoom();
		}
		private function enableSorting(){
			addEventListener(Event.ENTER_FRAME, sortLoop);
		}
		private function disableSorting(){
			removeEventListener(Event.ENTER_FRAME, sortLoop);
		}
		private function onKeyDownH(e:KeyboardEvent){
			if(Main.STAGE.stage.focus != Chatbox.instance.txtInput){
				switch(e.keyCode){
					case Keyboard.LEFT:
					case Keyboard.A:
						keyDownLeft = true;
					break;
					
					case Keyboard.RIGHT:
					case Keyboard.D:
						keyDownRight = true;
					break;
					
					case Keyboard.UP:
					case Keyboard.W:
						keyDownUp = true;
					break;
					
					case Keyboard.DOWN:
					case Keyboard.S:
						keyDownDown = true;
					break;
				}
			}
		}
		private function onKeyUpH(e:KeyboardEvent){
			if(Main.STAGE.stage.focus != Chatbox.instance.txtInput){
				UI.instance.closeClickMenu();
				switch(e.keyCode){
					case Keyboard.LEFT:
					case Keyboard.A:
						keyDownLeft = false;
					break;
					
					case Keyboard.RIGHT:
					case Keyboard.D:
						keyDownRight = false;
					break;
					
					case Keyboard.UP:
					case Keyboard.W:
						keyDownUp = false;
					break;
					
					case Keyboard.DOWN:
					case Keyboard.S:
						keyDownDown = false;
					break;
					case Keyboard.B:
						UI.instance.showInventory();
					break;
					case Keyboard.L:
						UI.instance.showQuestLog();
					break;
					case Keyboard.M:
						UI.instance.showMap();
					break;
					case Keyboard.T:
						UI.instance.showMenu();
					break;
					case Keyboard.NUMBER_1:
						this.startAutoAttack();
					break;
					case Keyboard.NUMBER_2:
						Game.useAbility(2);
					break;
					case Keyboard.NUMBER_3:
						Game.useAbility(3);
					break;
					case Keyboard.NUMBER_4:
						Game.useAbility(4);
					break;
					case Keyboard.NUMBER_5:
						Game.useAbility(5);
					break;
					case Keyboard.TAB:
						this.getRandomEnemyTarget();
					break;
				}
			}
		}
		public function handleMovePacket(data:*){
			if(users["user_"+String(data[1])] == null){
				return;
			}
			var id:int = Number(data[1]);
			if(data[5]){
				var room:String = data[5];
			}
			var x:Number = data[2];
			var y:Number = data[3];
			
			users["user_"+String(data[1])].x = x;
			users["user_"+String(data[1])].y = y;
			users["user_"+String(data[1])].dir = data[4];
			
			
			if(room){
				users["user_"+String(data[1])].room = room;
				if(room == currentRoom){
					if(this.getUserUnitByName(users["user_"+String(data[1])].name) == null){
						displayUserUnit(id, users["user_" + String(data[1])].name);
					}
				} else {
					destroyUserUnit(id);
				}
			} else {
				if(users["user_"+String(id)].room == currentRoom){
					var u:Unit = getUserUnitById(id);
					if(u != null){
						u.moveTo(x, y);
						u.addEventListener("MoveComplete", moveCompleteAutoDir);
					}
				} else {
					destroyUserUnit(id);
				}
			}
		}
		private function moveCompleteAutoDir(e:Event){
			var unit:Unit = e.target as Unit;
			unit.direction = Number(users["user_"+unit.id].dir);
			if (e.target.hasEventListener("MoveComplete")) {
				try {
					e.target.removeEventListener("MoveComplete", moveCompleteAutoDir);
				} catch (e:Error) {}
			}
		}
		
		
		public function handleStopMovePacket(data:*){
			var id:int = Number(data[1]);
			var x:Number = data[2];
			var y:Number = data[3];
			
			users["user_"+String(data[1])].x = x;
			users["user_"+String(data[1])].y = y;
			users["user_"+String(data[1])].dir = data[4];
			
			
			if(users["user_"+String(id)].room == currentRoom){
				var u:Unit = getUserUnitById(id);
				u.moveTo(x, y);
				u.addEventListener("MoveComplete", moveEnd);
			} else {
				destroyUserUnit(id);
			}
		}
		private function moveEnd(e:Event){
			var unit:Unit = e.target as Unit;
			unit.direction = Number(users["user_"+unit.id].dir);
			unit.playIdle();
			if (e.target.hasEventListener("MoveComplete")) {
				try {
					e.target.removeEventListener("MoveComplete", moveEnd);
				} catch (e:Error) {}
			}
		}
		
		public function teleportUnit(id:int, x:int, y:int){
			var unit:Unit;
			if(id != ClientInfo.data.id){
				unit = getUserUnitById(id);
			} else {
				unit = playerUnit;
			}
			unit.point = new Point(x, y);
			unit.model.addChild(new TeleportEffect());
		}
		
		
		
		
		
		
		//--------------------- USER SECTION ---------------------------------
		public function handleUserLeave(data:*){
			var id:int = data[1];
			destroyUserUnit(id);
			delete users["user_"+String(id)];
			if(UI.instance.roomListIsActive){
				UI.instance.showRoomList();
			}
		}
		public function handleUserEnter(data:*){
			var name:String = data.user.name;
			var id:int = Number(data.user.id);
			addUser(data.user);

			
			if(users["user_"+id].room == currentRoom){
				displayUserUnit(id, name);
			}
			//trace("User "+name+" Entered in room: " + users["user_"+id].room);  
			if(UI.instance.roomListIsActive){
				UI.instance.showRoomList();
			}
		}
		
		public function addUser(data:*){
			var user:Object = {};
			var id:int = data.id;
			var name:String = data.name;
			var x:Number = data.x;
			var y:Number = data.y;
			var room:String = data.room;
			var dir:int = data.dir;
			var gender:int = data.gen;
			var wep:String = data.wep;
			var arm:String = data.arm;
			var health:int = data.hp;
			var maxhealth:int = data.hpm;
			var access:int = data.acc;
			var level:int = data.lvl;
			
			//---------------------------
			user.id = id;
			user.name = name;
			user.x = x;
			user.y = y;
			user.room = room;
			user.dir = dir;
			user.gender = gender;
			user.wep = wep;
			user.arm = arm;
			user.health = health;
			user.maxhealth = maxhealth;
			user.access = access;
			user.level = level;
			//---------------------------
			
			
			users["user_"+id] = user;
		}
		public function displayUserUnit(id:int, name:String){
			if(users["user_"+String(id)] != null){
				var hp:int = users["user_"+String(id)].health;
				var hpM:int = users["user_"+String(id)].maxhealth;
				var unit:Unit = new Unit(hp, hpM);
				unit.isPlayer = true;
				unit.name = "user_"+String(id);
				unit.id = id;
				unit.access = users["user_"+String(id)].access;
				unit.level = users["user_"+String(id)].level;
				unit.displayName = name;
				unit.gender = Number(users["user_"+String(id)].gender);
				unit.x = users["user_"+String(id)].x;
				unit.y = users["user_"+String(id)].y;
				var wepInfo:Array = users["user_"+String(id)].wep.split(",");
				var armInfo:Array = users["user_"+String(id)].arm.split(",");
				
				unit.loadWeapon(wepInfo[0], wepInfo[1]);
				unit.loadArmor(armInfo[0], armInfo[1]);
				
				if(map.hasOwnProperty("size")){
					unit.size = map.size;
				}
				if(map.hasOwnProperty("speed")){
					unit.speed = map.speed;
				}
				if(unit.health < 1){
					unit.playDeathAnimation(false);
				}
				
				unit.direction = users["user_"+String(id)].dir;
				userUnits.push(unit);
				cell.addChild(unit);
			}
		}
		public function destroyUserUnit(id:int){
			var unit:Unit = getUserUnitById(id);
			if(unit != null){
				if (unit.hasEventListener("MoveComplete")) {
					try {
						unit.removeEventListener("MoveComplete", moveCompleteAutoDir);
					} catch (e:Error) {}
				}
				cell.removeChild(unit);
				unit.destroy();
				userUnits.splice(userUnits.indexOf(unit), 1);
			}
		}
		public function getUserUnitById(id:int):Unit{
			if(id == ClientInfo.data.id){
				return playerUnit;
			}
			return MovieClip(cell.getChildByName("user_"+String(id))) as Unit;
		}
		public function getUserUnitByName(name:String):Unit{
			name = name.toLowerCase();
			if(name == playerUnit.displayName.toLowerCase()){
				return playerUnit;
			}
			for(var i:int = 0; i < userUnits.length; i++){
				if(userUnits[i].displayName.toLowerCase() == name){
					return userUnits[i];
				}
			}
			return null;
		}
		
		//--------------------------------------------------------------------
		
		//-------------------- ENEMY SECTION ---------------------------------
		
		public function addEnemy(data:Object){
			var enemy:Object = {};
			var id:int = data.id;
			enemy.id = id;
			enemy.name = data.name;
			enemy.hpMax = data.hpMax;
			enemy.hp = data.hp;
			enemy.pad = data.pad;
			enemy.room = data.room;
			enemy.file = data.file;
			enemy.linkage = data.linkage;
			enemy.level = data.level;
			enemy.type = data.type;
			enemy.inCombat = data.inC;
			
			
			enemies[""+id] = enemy;
			
			if(enemyFileList.indexOf(data.file) == -1){
				enemyFileList.push(data.file);
			}
		}
		public function displayEnemyUnit(id:int){
			if(enemies[String(id)] != null){
				var hp:int = enemies[String(id)].hp;
				var hpM:int = enemies[String(id)].hpMax;
				var unit:Unit = new Unit(hp, hpM);
				unit.isPlayer = false;
				unit.name = String(id);
				unit.id = id;
				unit.level = enemies[String(id)].level;
				unit.displayName = enemies[String(id)].name;
				unit.type = enemies[String(id)].type;
				unit.inCombat = enemies[String(id)].inCombat;
				if(enemies[String(id)].pad.indexOf(",") == -1){
					var pad:MovieClip = MovieClip(map.getChildByName("mobPad" + enemies[String(id)].pad));
					if(pad != null){
						unit.pos = pad;
					}
				} else {
					unit.x = Number(enemies[String(id)].pad.split(",")[0]);
					unit.y = Number(enemies[String(id)].pad.split(",")[1]);
				}
				var file:String = enemies[String(id)].file;
				if(enemyFiles.hasOwnProperty(file)){
					unit.model = Utils.getAssetFromApplicationDomain(enemyFiles[file], enemies[String(id)].linkage);
					unit.portrait = Utils.getAssetFromApplicationDomain(enemyFiles[file], enemies[String(id)].linkage + "_Portrait")
				} else {
					return;
				}
				
				if(map.hasOwnProperty("size")){
					unit.size = map.size;
				} else {
					unit.size = Game.DEFAULT_SIZE;
				}
				enemyUnits.push(unit);
				cell.addChild(unit);
				if(unit.health < 1){
					unit.alpha = 0;
				}
			}
		}
		public function destroyEnemyUnit(id:int){
			var unit:Unit = getEnemyUnitById(id);
			if(unit != null){
				if (unit.hasEventListener("MoveComplete")) {
					try {
						unit.removeEventListener("MoveComplete", moveCompleteAutoDir);
					} catch (e:Error) {}
				}
				cell.removeChild(unit);
				unit.destroy();
				enemyUnits.splice(enemyUnits.indexOf(unit), 1);
			}
		}
		
		public function getEnemyUnitById(id:int):Unit{
			return MovieClip(cell.getChildByName(String(id))) as Unit;
		}
		
		
		public function loadNextEnemyFile(){
			if(enemyFileList.length > 0){
				var file:File = new File(Game.ENEMY_URL + enemyFileList[0], nextEnemyFileLoaded, null, nextEnemyFileLoaded);
			} else {
				displayRoom();
				LoadingScreen.instance.hide();
			}
		}
		private function nextEnemyFileLoaded(e:Event){
			if(e.target != null){
				enemyFiles[enemyFileList[0]] = e.target.applicationDomain;
			}
			enemyFileList.shift();
			loadNextEnemyFile();
		}
		
		public function spawnMob(data:Object){
			addEnemy(data);
			dynamicEnemyIds.push(data.id as int);
			enemyFileList.push(data.file)
			var file:File = new File(Game.ENEMY_URL + enemyFileList[0], spawnFileLoaded, null, spawnFileFailed);
		}
		private function spawnFileLoaded(e:Event){
			if(e.target != null){
				enemyFiles[enemyFileList[0]] = e.target.applicationDomain;
			}
			enemyFileList.shift();
			var id:int = dynamicEnemyIds[0];
			if(enemies[""+id].room == this.currentRoom){
				displayEnemyUnit(id);
			}
			dynamicEnemyIds.shift();
			if(enemyFileList.length > 0){
				
			}
		}
		private function spawnFileFailed(){
			
		}
		//--------------------------------------------------------------------
		
		public function handleZoneData(data:*){
			var i:int = 0;
			users = {};
			userUnits = [];
			enemyUnits = [];
			enemyFileList = [];
			enemyFiles = {};
			for(i = 0; i < data.users.length; i++){
				users["user_"+data.users[i].id] = {};
				addUser(data.users[i])
			}
			for(i = 0; i < data.enemies.length; i++){
				//Utils.dumpObject(data.enemies[i]);
				enemies[""+data.enemies[i].id] = {};
				addEnemy(data.enemies[i]);
			}
			this.isPvPZone = data.isPvP;
			//trace("Enemy File List:",enemyFileList);
			loadNextEnemyFile();
		}
		
		
		public function displayRoom(){
			while(userUnits.length > 0){
				cell.removeChild(userUnits[0]);
				userUnits.shift();
			}
			userUnits = [];
			while(enemyUnits.length > 0){
				cell.removeChild(enemyUnits[0]);
				enemyUnits.shift();
			}
			enemyUnits = [];
			var name:String
			for (name in users){
				if(users[name].room == this.currentRoom){
					displayUserUnit(users[name].id, users[name].name);
				}
			}
			for (name in enemies){
				if(enemies[name].room == this.currentRoom){
					displayEnemyUnit(enemies[name].id);
				}
			}
			for(var i:int = 0; i < props.length; i++){
				cell.addChild(props[i]);
			}
			
			sortRoom();
		}
		public function clearZone(){
			while(userUnits.length > 0){
				cell.removeChild(userUnits[0]);
				userUnits.shift();
			}
			while(enemyUnits.length > 0){
				cell.removeChild(enemyUnits[0]);
				enemyUnits.shift();
			}
			clearProps();
			var name:String
			for (name in users){
				delete users[name];
			}
			for (name in enemies){
				delete enemies[name];
			}
			userUnits = [];
			users = {};
			
			enemyUnits = [];
			enemies = {};
		}
		
		
		
		public function changeEquip(id:int, type:String, data:String){
			var unit:Unit = this.getUserUnitById(id);
			switch(type){
				case 'wep':
					if(!unit.isClient){
						users["user_"+String(id)].wep = data;
					}
					if(unit != null){
						unit.loadWeapon(data.split(",")[0], data.split(",")[1]);
					}
				break;
				case 'arm': //armor
					if(!unit.isClient){
						users["user_"+String(id)].arm = data;
					}
					if(unit != null){
						unit.loadArmor(data.split(",")[0], data.split(",")[1]);
					}
				break;
			}
		}
		
		public function loadMap(url:String, room:String = "", pad:String = "") {
			Main.stopSound();
			LoadingScreen.instance.text = "Loading...";
			LoadingScreen.instance.show();
			initComplete = false;
			defaultRoom = room;
			gotoPad = pad;
			var loader:File = new File(url,loadMapComplete,updateHandler,failedHandler);
			function updateHandler(percent) {
				//trace(percent + " Loaded!");
				LoadingScreen.instance.percent = percent;
			}
			function failedHandler(percent) {
				trace("Fatal Error: Failed To Load Map!");
			}
		}
		private function loadMapComplete(e:Event) {
			//trace("Finished Loading!");
			reset(e.currentTarget.content);
			mapAppD = e.target.applicationDomain;
			if(defaultRoom != "" && Utils.frameLabelExists(map, defaultRoom)){
				gotoRoom(defaultRoom, gotoPad);
			} else {
				if (map.hasOwnProperty("defaultRoom")) {
					gotoRoom(map.defaultRoom, gotoPad)
				} else if(Utils.frameLabelExists(map, "Default")){
					gotoRoom("Default", gotoPad)
				} else {
					Console.log.log("Map Room Not Specified and there is no Default room!", true);
				}
			}
			var obj:Object = {};
			obj.x = playerUnit.x;
			obj.y = playerUnit.y;
			obj.room = currentRoom;
			obj.dir = playerUnit.dirAsInt;
			Server.instance.sendXt("initZone", obj);
			initComplete = true;
		}
		
		private function stageLostFocus(e:Event){
			this.keyDownDown = false;
			this.keyDownUp = false;
			this.keyDownLeft = false;
			this.keyDownRight = false;
			
			if(playerUnit != null && stoppedMove == false){
				playerUnit.playIdle();
				sendPosTimer.stop();
				sendPosTimer.reset();
				stoppedMove = true;
				Server.instance.sendStoppedMove(Math.round(playerUnit.x), Math.round(playerUnit.y), playerUnit.dirAsInt);
			}
		}
		public function playEmote(id:int, anim:String, lookAtTarget:Boolean = false){
			var unit:Unit = this.getUserUnitById(id);
			if(unit != null && unit.health > 0){
				unit.playAnim(anim, true);
				if(lookAtTarget && target != null){
					unit.lookAt(target);
				}
			}
		}
		public function cancelMoving(){
			stoppedMove = false;
			this.keyDownDown = false;
			this.keyDownUp = false;
			this.keyDownLeft = false;
			this.keyDownRight = false;
			
			if(playerUnit.currentAnimation == playerUnit._runAnimation){
				playerUnit.playIdle();
			}
			endMove();
		}
		private function endMove(){
			sendPosTimer.stop();
			sendPosTimer.reset();
			stoppedMove = true;
			Server.instance.sendStoppedMove(Math.round(playerUnit.x), Math.round(playerUnit.y), playerUnit.dirAsInt);
		}
		public function getFirstPlayerInRange(range:int):Unit{
			for(var i:int = 0; i < userUnits.length; i++){
				if(Utils.getDistance(playerUnit, userUnits[i]) <= range){
					return userUnits[i];
				}
			}
			return null;
			
		}
		
		public static function get instance():World{
			if(_instance){
				return _instance;
			}
			return null;
			
		}
		public function killUnit(unit:Unit){
			if(unit == null){
				return;
			}
			unit.playDeathAnimation();
			unit.resetActionQueue();
			
			unit.health = 0;
			if(unit == playerUnit){
				Game.PlayerDeath();
				this.keyDownDown = false;
				this.keyDownLeft = false;
				this.keyDownRight = false;
				this.keyDownUp = false;
			}
			if(target == unit){
				target = null;
			}
			unit.makeNonInteractive();
		}
		
		public function respawnUnit(unit:Unit){
			if(unit == null){
				return;
			}
			if(unit.isPlayer == false){
				var pad:MovieClip = MovieClip(map.getChildByName("mobPad" + enemies[String(unit.id)].pad));
				if(pad != null){
					unit.pos = pad;
				}
			}
			unit.playIdle();
			unit.health = unit.maxHealth;
			unit.alpha = 1;
			unit.makeInteractive();
		}
		
		private function collisionCheck(weakClip:MovieClip, strongClip:MovieClip, masterBase:MovieClip, tolerance:uint = 5, overlap:Number = 0):uint{
			var strongRect:Rectangle = strongClip.getRect(masterBase);
			var weakRect:Rectangle = weakClip.getRect(masterBase);
			var overlapRect:Rectangle = strongRect.intersection(weakRect);
			var moveClip:MovieClip = weakClip;
			if(weakClip == playerUnit.feet){
				moveClip = playerUnit;
			}
			if(overlapRect.width <= tolerance && overlapRect.height <= tolerance){
				return 0;
			}
			if(overlapRect.width > overlapRect.height){
				if(weakRect.y < strongRect.y){
					weakRect.y -= overlapRect.height - overlap;
					moveClip.y -= overlapRect.height - overlap;
					return 2;
				}
				else{
					weakRect.y += overlapRect.height - overlap;
					moveClip.y += overlapRect.height - overlap;
					return 8;
				}
			}
			else{
				if(weakRect.x < strongRect.x){
					weakRect.x -= overlapRect.width - overlap;
					moveClip.x -= overlapRect.width - overlap;
					return 6;
				}
				else{
					weakRect.x += overlapRect.width - overlap;
					moveClip.x += overlapRect.width - overlap;
					return 4;
				}
			}
		}
		
		public function sortRoom () {
			var container:MovieClip = this.cell;
			var i:int;
			var childList:Array = new Array();
			i = container.numChildren;
			while (i--) {
				childList[i] = container.getChildAt(i);
			}
			childList.sortOn ("y", Array.NUMERIC);
			i = container.numChildren;
			while (i--) {
				if (childList[i] != container.getChildAt(i)) {
					container.setChildIndex (childList[i], i);
				}
			}
		}
		public function clearProps(){
			if(props != null){
				while(props.length > 0){
					cell.removeChild(props[0]);
					props.shift();
				}
			}
		}
		public function get target():Unit{
			return __target;
		}
		public function set target(e:Unit){
			if(e != playerUnit || canTargetSelf == true){
				if(target != null && target.hasEventListener("Update")){
					target.model.filters = [];
					target.removeEventListener("Update", targetUpdate)
				}
				stopAutoAttack();
				__target = e;
				if(e != null){
					UI.instance.showTargetFrame();
					if(target.isPlayer){
						target.model.filters = [selectedTargetGlowPlayer];
					} else {
						target.model.filters = [selectedTargetGlowEnemy];
					}
					
					target.addEventListener("Update", targetUpdate)
				} else {
					UI.instance.hideTargetFrame();
				}
			}
		}
		private function targetUpdate(e:Event){
			UI.instance.updateTargetFrame();
		}
		private function playerInfoUpdated(e:Event){
			UI.instance.updatePlayerFrame();
		}
		public function openNPC(linkage:String, npcInMap:MovieClip = null){
			var npc:MovieClip = Utils.getAssetFromApplicationDomain(mapAppD, linkage);
			var window:MovieClip = Utils.getAssetFromApplicationDomain(mapAppD, linkage+"_UI");
			UI.instance.showNpcUI();
			UI.instance.npcUI.show(npc, window, npcInMap);
			
		}
		public function getRandomEnemyTarget(){
			var i:int = 0;
			var list:Array = [];
			for(i = 0; i < enemyUnits.length; i++){
				if(enemyUnits[i].health > 0){
					enemyUnits[i].distanceFromPlayer = Utils.getDistance(playerUnit, enemyUnits[i]);
					list.push(enemyUnits[i]);
				}
			}
			list.sortOn("distanceFromPlayer", Array.NUMERIC);
			target = list[0];
		}
		public function getEnemiesInRange(range:Number):Array{
			var i:int = 0;
			var targets:Array = [];
			for(i = 0; i < enemyUnits.length; i++){
				if(Utils.getDistance(playerUnit, enemyUnits[i]) <= range && enemyUnits[i].health > 0){
					targets.push(enemyUnits[i]);
				}
			}
			return targets;
		}
		public function convertArrayOfUnitsToArrayOfIds(a:Array):Array{
			var nA:Array = [];
			for(var i:int = 0; i < a.length; i++){
				nA.push(a[i].id);
			}
			
			return nA;
		}
		
		public function handleEnemyAction(data:Array){
			// 1: cmd, 2: enemy id, 3+: params
			var actionCmd:int = data[1];
			var enemyId:int = data[2];
			var enemyUnit:Unit = getEnemyUnitById(enemyId);
			
			var targetId:int;
			var targetUnit:Unit;
			var action:Object;
			var damage:int;
			var animationId:int;
			
			switch(actionCmd){
				case 1: //attack
					//1, enemy id, target id, damage, animation id
					targetId = data[3];
					damage = data[4];
					animationId = data[5];
					if(users["user_"+targetId] != null){
						users["user_"+targetId].health -= Number(damage);
					}
					
					if(enemyUnit != null){
						targetUnit = getUserUnitById(targetId);
						
						if(targetUnit != null && targetUnit.health > 0){
							targetUnit.damage(damage)
							
							action = {};
							action.name = "aiAttack";
							action.target = targetUnit;
							action.animation = animationId;
							enemyUnit.queueAction(action);
						}
					}
				break;
				case 2: //return to spawn
					if(enemyUnit != null){
						enemyUnit.resetActionQueue();
						action = {};
						action.name = "aiReturnToSpawn";
						enemyUnit.queueAction(action);
						enemyUnit.health = enemyUnit.maxHealth;
					}
				break;
			}
			
		}
		
		public function get isAutoAttacking():Boolean {
			return autoAttackTimer.running;
		}
		public function autoAttack(e:TimerEvent){
			if(target != null && playerUnit.health > 0){
				Game.useAbility(1);
			} else {
				autoAttackTimer.stop();
			}
		}
		public function startAutoAttack() {
			if(autoAttackTimer.running == false){
				Game.useAbility(1);
				autoAttackTimer.start();
			}
		}
		public function openShop(id:int){
			Server.instance.loadShop(id);
		}
		private function stopAutoAttack(){
			autoAttackTimer.stop();
		}
		private function get canChangeZone():Boolean {
			
			var currentTime:Number = new Date().time;
			if(lastJoinZone != -1){
				if((currentTime - lastJoinZone) >= (Game.ZONE_CHANGE_COOLDOWN * 1000)){
					lastJoinZone = currentTime;
					return true;
				}
			} else {
				lastJoinZone = currentTime;
				return true;
			}
			return false;
		}
		public function handleSpellEffects(casterId:int, targetId:int, targetIsPlayer:Boolean, effects:String){
			var effectsAr:Array = effects.split(",");
			var s:Array;
			var unit:Unit;
			var caster:Unit
			for(var i:int = 0; i < effectsAr.length; i++){
				if(effectsAr[i].indexOf(":") != -1){
					s = effectsAr[i].split(":")
						caster = getUserUnitById(casterId);
					if(s[0] == "t"){
						if(targetIsPlayer){
							unit = getUserUnitById(targetId);
						} else {
							unit = getEnemyUnitById(targetId);
						}
					} else if(s[0] == "c"){
						unit = getUserUnitById(casterId);
					}
					if(unit != null){
						handleSpellEffect(unit, s[1], caster);
					}
				}
			}
		}
		public function handleSpellEffect(unit:Unit, effectId:int, caster:Unit = null){
			var isProjectile:Boolean = Utils.spellEffectIsProjectile(effectId.toString());
			var effect = Utils.getSpellEffectAsset(effectId.toString());
			if(isProjectile){
				unit.displaySpellEffect(effect, true, caster);
			} else {
				unit.displaySpellEffect(effect);
			}
		}
		public function getPlayerListAsString():String{
			var e:String = playerUnit.displayName;
			for (var key:String in users) {
				e += ", "+ Utils.capitalize(users[key].name);
			}
			return e;
		}
		public function npcQuestList(id:int){
			Server.instance.getQuestList(id);
		}
		public function cacheArmor(file:String, appD:ApplicationDomain){
			armorCache[file] = appD;
		}
		public function getCachedArmor(file:String):ApplicationDomain{
			return armorCache[file];
		}
		
		public function cacheWeapon(file:String, appD:ApplicationDomain){
			weaponCache[file] = appD;
		}
		public function getCachedWeapon(file:String):ApplicationDomain{
			return weaponCache[file];
		}
	}
	
}
