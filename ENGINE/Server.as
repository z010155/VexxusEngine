package  {
	import flash.geom.Point;
	
	public class Server {
		
		import it.gotoandplay.smartfoxserver.SmartFoxClient;
		import it.gotoandplay.smartfoxserver.SFSEvent;
		import flash.events.SecurityErrorEvent;
		import flash.events.IOErrorEvent;
		import flash.display.MovieClip;
		
		public var sfs:SmartFoxClient;
		private var xtName:String = "World";
		private var game:Game;
		
		private var userUsername:String = "admin";
		private var userPassword:String = "testword";
		private var clientInfo:ClientInfo;
		private static var _instance:Server;
		
		
		public function Server(g:Game) {
			if(_instance){
				throw new Error("Server: Called illegal instanciation of singleton! Use instance()");
			}
			_instance = this;
			game = g;
			sfs = new SmartFoxClient();
			
			sfs.defaultZone = "AzerronMMO";
			sfs.smartConnect = false;
			sfs.debug = false;
			
			sfs.addEventListener(SFSEvent.onConnection, onConnection);
			sfs.addEventListener(SFSEvent.onConnectionLost, onConnectionLost);
			sfs.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponse);
			sfs.addEventListener(SFSEvent.onAdminMessage, onAdminMessage);
			sfs.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			sfs.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}		
		public function destroy(){
			sfs.removeEventListener(SFSEvent.onConnection, onConnection);
			sfs.removeEventListener(SFSEvent.onConnectionLost, onConnectionLost);
			sfs.removeEventListener(SFSEvent.onExtensionResponse, onExtensionResponse);
			sfs.removeEventListener(SFSEvent.onAdminMessage, onAdminMessage);
			sfs.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			sfs.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			if(sfs.isConnected){
				sfs.disconnect();
			}
			sfs = null;
			_instance = null;
		}
		public function sendXt(cmd:String, obj:*, type:String = "json"){
			//Console.log.log("Sending Xt Message: " + cmd, true);
			sfs.sendXtMessage(xtName, cmd, obj, type);
		}
		
		
		// ---------------------------------------
		public function getInventory(){
			if(!UI.instance.loadedInventory){
				var obj:Array = [];
				sendXt("getInvent", obj, "str");
				//trace("Inventory request sent!");
			} else {
				UI.instance.openInventory();
			}
		}
		
		public function loadShop(id:int){
			if(UI.instance.activeShopId != id){
				var obj:Array = [];
				obj.push(id);
				sendXt("loadShop", obj, "str");
			}
		}
		public function getQuestList(id:int){
			var obj:Array = [];
			obj.push(id);
			sendXt("getQL", obj, "str");
		}
		public function getQuestData(id:int){
			if(ClientInfo.data.getCachedQuest(id) == null){
				var obj:Array = [];
				obj.push(id);
				sendXt("getQD", obj, "str");
			} else {
				showQuest(ClientInfo.data.getCachedQuest(id));
			}
		}
		

		public function sendPos(x:Number, y:Number, dir:int, room:String = ""){
			var obj:Array = [];
			obj.push(x);
			obj.push(y);
			obj.push(dir);
			if(room != ""){
				obj.push(room);
			}
			sendXt("setPos", obj, "str");
		}
		public function sendStoppedMove(x:Number, y:Number, dir:int){
			var obj:Array = [];
			obj.push(x);
			obj.push(y);
			obj.push(dir);
			sendXt("stopMove", obj, "str");
		}
		public function enterZone(name:String, pad:String = "", room:String = ""){
			var obj:Object = {};
			obj.name = name;
			if(room != ""){
				obj.room = room;
			}
			World.instance.nextRoomPad = pad;
			sendXt("enterZone", obj);
		}
		public function rest(){
			Server.instance.sendXt("rest", [], "str");
		}
		public function respawnMe(){
			Server.instance.sendXt("reSp", [], "str");
		}
		public function buyItem(itemId:int){
			var obj:Array = []
			obj.push(itemId);
			sendXt("buyItem", obj, "str");
		}
		public function sellItem(itemId:int){
			var obj:Array = []
			obj.push(itemId);
			sendXt("sellItem", obj, "str");
		}
		public function useItem(itemId:int){
			var obj:Array = []
			obj.push(itemId);
			sendXt("useItem", obj, "str");
		}
		public function previewItem(itemId:int){
			var obj:Array = []
			obj.push(itemId);
			sendXt("prIt", obj, "str");
		}
		public function duelTarget(){
			if(World.instance.target != null && World.instance.target.isPlayer){
				sendXt("dlRq", [World.instance.target.id], "str");
			}
		}
		public function sendChatMessage(msg:String){
			if (/\S/.test(msg)) {
				var arr:Array = [];
				//msg = Utils.strReplace(msg, "<", "&#60;");
				//msg = Utils.strReplace(msg, ">", "&#62;");
				//msg = Utils.strReplace(msg, '\\', "&#92;");
				//msg = Utils.strReplace(msg, '%', "&#37;");
				
				
				if(msg.length <= Main.MAX_CHAT_MSG_LENGTH){
					arr.push(msg);
				}
				this.sendXt("chat", arr, "str");
			}
		}
		public function completeQuest(id:int){
			var obj:Array = [];
			obj.push(id);
			Server.instance.sendXt("compQ", obj, "str");
		}
		public function startQuest(id:int){
			var obj:Array = [];
			obj.push(id);
			Server.instance.sendXt("stQ", obj, "str");
		}
		public function quitQuest(id:int){
			var obj:Array = [];
			obj.push(id);
			Server.instance.sendXt("quitQ", obj, "str");
		}
		private function showQuest(data:Object){
			var state:int = 0;
			if(ClientInfo.data.hasActiveQuest(data.id)){
				state = 1;
				if(ClientInfo.data.activeQuestIsComplete(data.id)){
					state = 2;
				}
			}
			UI.instance.displayQuest(data, state);
		}
		// ---------------------------------------
		private function reshowServerList(){
			Game.destroyGameSingletons();
			Main.STAGE.displayServerSelect(false);
			LoadingScreen.instance.hide();
		}
		
		private function onExtensionResponse(e:SFSEvent){
			//trace("Ext Response Recieved!")
			var type:String = e.params.type
			var data:Object = e.params.dataObj
			var cmd:String;
			var unit:Unit

			if (type == SmartFoxClient.XTMSG_TYPE_JSON){
				cmd = data.cmd;
				switch(cmd){
					case "loginResponse":
						if(!data.hasOwnProperty("err")){
							/*trace("Login Successfull!");
							trace("MY GOLD : " + data.gold);
							trace("MY ACCESS : " + data.access);
							trace("MY XP : " + data.xp);
							trace("MY ARMOR SWF : " + data.armorSWF);*/
							clientInfo = new ClientInfo();
							ClientInfo.data.name = this.userUsername;
							ClientInfo.data.id = data.id;
							ClientInfo.data.level = data.level;
							ClientInfo.data.gender = data.gender;
							ClientInfo.data.gold = data.gold;
							ClientInfo.data.xp = data.xp;
							ClientInfo.data.weaponData = data.weapon;
							ClientInfo.data.armorData = data.armor;
							ClientInfo.data.health = data.hp;
							ClientInfo.data.maxHealth = data.hp;
							ClientInfo.data.access = data.access;
							ClientInfo.data.abilities = data.abilities;
							game.init(data.assets);
							LoadingScreen.instance.text = "Logged In!";
						} else {
							trace("Login Failed: " + data.err);
							if(data.err == "badpass"){
								LoadingScreen.instance.text = "Incorrect Password!";
								Utils.delayFunction(5, reshowServerList);
							} else if(data.err == "banned"){
								Game.banned = true;
								LoadingScreen.instance.banned();
							} else if(data.err == "outdated"){
								LoadingScreen.instance.text = "Outdated Client! \n Please clear your cache and try again.";
							} else if(data.err == "double"){
								LoadingScreen.instance.text = "Double Login Error! \n Please wait 5 seconds and try again.";
								Utils.delayFunction(5, reshowServerList);
							}
							
						}
					break;
					case 'zoneData':
						World.instance.handleZoneData(data);
					break;
					case 'shopData':
						UI.instance.handleShopData(data);
					break;
					case 'userInvent':
						UI.instance.handleInventoryData(data);
					break;
					case 'rewRec':
						var id = data.id;
						if(UI.instance.inventoryHasId(id)){
							UI.instance.getCachedItemById(id).sN = Number(UI.instance.getCachedItemById(id).sN) + 1;
						} else {
							data.sN = 1;
							UI.instance.inventoryCache.push(data);
						}
						if(UI.instance.windows.currentFrameLabel == "Inventory" || UI.instance.windows.currentFrameLabel == "Shop"){
							UI.instance.openInventory();
						}
						UI.instance.showToast(data);
					break;
					case 'qList':
						UI.instance.displayQuestList(data.quests);
						UI.instance.questLog.questListId = data.id;
					break;
					case 'qData':
						ClientInfo.data.cacheQuest(data.data);
						showQuest(data.data);
					break;
					case 'userJoined':
						World.instance.handleUserEnter(data);
					break;
					case 'chAb': //changed abilities
						ClientInfo.data.abilities = data.d;
						UI.instance.updateAbilityIcons();
					break;
					
					
					case 'eSpn':
						World.instance.spawnMob(data.info);
					break;
					
					default:
					trace("JSON Cmd: " + cmd);
					break;
					
				}
			} else if (type == SmartFoxClient.XTMSG_TYPE_STR){
				cmd = data[0];
				data.splice(1, 1);
				
				var i:int;
				var intCasterId:int;
				var intTargetId:int;
				var bTargetIsPlayer:int;
				var strAnimation:String;
				var strEffects:String;
				var intDamage:int;
				var bFaceTarget:int;
				var bIsHeal:int;
				var targets:Array;
				var fxId;
				
				switch(cmd){
					case 'lvlUp':
						var targetUnit:Unit = World.instance.getUserUnitById(data[1])
						if(targetUnit != null){
							targetUnit.maxHealth = data[2];
							targetUnit.health = data[2];
							targetUnit.displayLevelup();
						}
						if(data[1] == ClientInfo.data.id){
							ClientInfo.data.xp -= ClientInfo.data.xpMax;
							ClientInfo.data.level ++;
							UI.instance.showPlayerFrame();
						} else {
							World.instance.users["user_"+String(data[1])].health = Number(data[2]);
							World.instance.users["user_"+String(data[1])].maxhealth = Number(data[2]);
						}
					break;
					case 'itPr': //item Preview
						UI.instance.showPreviewWindow(data[1], data[2]);
					break;
					case 'xpRec': //exp recieved
						World.instance.playerUnit.displayExp(data[1]);
						ClientInfo.data.xp += Number(data[1]);
					break;
					case 'goRec': //gold recieved
						World.instance.playerUnit.displayGold(data[1]);
						ClientInfo.data.gold += Number(data[1]);
					break;
					case 'qoAdd':
						ClientInfo.data.updateQuestObjective(data[1], data[2]);
					break;
					case 'rfQL':
						ClientInfo.data.removeQuestFromLog(data[1]);
						if(UI.instance.questLog != null){
							switch(UI.instance.questLog.state){
								case 1:
									UI.instance.showQuestLog();
								break;
								case 2:
									Server.instance.getQuestList(UI.instance.questLog.questListId);
								break;
								default:
									UI.instance.showQuestLog();
							}
						}
					break;
					case 'stQR':
						if(data[2] == null){
							UI.instance.questLog.questAcceptResponse(0, false);
						} else {
							UI.instance.questLog.questAcceptResponse(data[1], true);
						}
					break;
					case 'emo':
						if(data[3] == null){
							World.instance.playEmote(data[1], Game.EMOTE_LIBRARY[""+data[2]]);
						} else {
							World.instance.playEmote(data[1], Game.EMOTE_LIBRARY[""+data[2]], data[3]);
						}
					break;
					case 'pos':
						World.instance.handleMovePacket(data);
					break;
					case 'abu': //ability used
						//caster id, target ids and dmg string, targetIsPlayer, animation, effects, faceTarget, isHeal
						intCasterId = data[1];
						targets = data[2].split(",");
						bTargetIsPlayer = data[3];
						strAnimation = data[4];
						strEffects = data[5];
						bFaceTarget = data[6];
					 	bIsHeal = data[7];
						
						//intTargetId = data[2];
						//intDamage = data[6]
						
						World.instance.playEmote(intCasterId, Game.EMOTE_LIBRARY[""+strAnimation], Boolean(bFaceTarget));

						for(i = 0; i < targets.length; i++){
							intTargetId = Number(targets[i].split(":")[0]);
							intDamage = Number(targets[i].split(":")[1]);
							World.instance.handleSpellEffects(intCasterId, intTargetId, Boolean(bTargetIsPlayer), strEffects);
							if(bTargetIsPlayer == 0){
								if(bIsHeal == 0){
									World.instance.enemies[intTargetId].hp -= intDamage;
								} else {
									World.instance.enemies[intTargetId].hp += intDamage;
								}
								
								unit = World.instance.getEnemyUnitById(intTargetId);
							} else {
								if(World.instance.users["user_"+String(data[1])] != null){
									if(bIsHeal == 0){
										World.instance.users["user_"+String(data[1])].health -= intDamage;
									} else {
										World.instance.users["user_"+String(data[1])].health += intDamage;
									}
								}
								
								unit = World.instance.getUserUnitById(intTargetId);
							}
							
							if(unit != null){
								if(bIsHeal == 0){
									unit.damage(intDamage);
								} else {
									unit.heal(intDamage)
								}
							}
						}
					break;
					case 'hl': //quick heal
						
						intTargetId = data[1];
						bTargetIsPlayer = data[2];
						intDamage = data[3]
						
						
						if(bTargetIsPlayer == 0){
							if(World.instance.enemies[intTargetId] != null){
								World.instance.enemies[intTargetId].hp += intDamage;
							}
							unit = World.instance.getEnemyUnitById(intTargetId);
						} else {
							if(World.instance.users["user_"+String(data[1])] != null){
								World.instance.users["user_"+String(data[1])].health += intDamage;
							}
							unit = World.instance.getUserUnitById(intTargetId);
						}
						
						if(unit != null){
							unit.heal(intDamage);
						}
					break;
					case 'dmg': //quick damage
						
						intTargetId = data[1];
						bTargetIsPlayer = data[2];
						intDamage = data[3]
						
						if(bTargetIsPlayer == 0){
							if(World.instance.enemies[intTargetId] != null){
								World.instance.enemies[intTargetId].hp -= intDamage;
							}
							unit = World.instance.getEnemyUnitById(intTargetId);
						} else {
							if(World.instance.users["user_"+String(data[1])] != null){
								World.instance.users["user_"+String(data[1])].health -= intDamage;
							}
							unit = World.instance.getUserUnitById(intTargetId);
						}
						
						if(unit != null){
							unit.damage(intDamage);
						}
					break;
					case 'fx': //quick spell effect
						
						targets = data[1];
						fxId = data[2];
						bTargetIsPlayer[3]
						
						for(i = 0; i < targets.length; i++){
							intTargetId = targets[i]
							
							if(bTargetIsPlayer == 0){
								unit = World.instance.getEnemyUnitById(intTargetId);
							} else {
								unit = World.instance.getUserUnitById(intTargetId);
							}
							if(unit != null){
								World.instance.handleSpellEffect(unit, fxId);
							}
						}
						
						
					break;
					case 'eCU': //enemy combat update
						//state = data[1]
						intTargetId = data[2];
						
						if(World.instance.enemies[intTargetId] != null){
							World.instance.enemies[intTargetId].inCombat = Number(data[1]) == 1;
						}
						unit = World.instance.getEnemyUnitById(intTargetId);
						
						if(unit != null){
							unit.inCombat = Number(data[1]) == 1;
						}
					break;
					case 'cd':
					if(data[2] == null){
						Game.cooldown(data[1]);
					} else {
						Game.cooldown(data[1], false);
					}
					break;
					case 'eHP':
						World.instance.enemies[data[1]].hp = Number(data[2]);
						unit = World.instance.getEnemyUnitById(data[1]);
						if(unit != null){
							unit.health = Number(data[2]);
						}
					break;
					case 'reE':
						World.instance.enemies[data[1]].hp = World.instance.enemies[data[1]].hpMax;
						unit = World.instance.getEnemyUnitById(data[1]);
						if(unit != null){
							if(unit.health < 1){
								World.instance.respawnUnit(unit);
							}
						}
					break;
					case 'eAct':
						World.instance.handleEnemyAction(data as Array);
					break;
					case 'eD':
						if(World.instance.enemies[String(data[1])] != null){
							World.instance.enemies[String(data[1])].hp = 0;
						}
						World.instance.killUnit(World.instance.getEnemyUnitById(data[1]));
					break;
					case 'uD':
						if(World.instance.users["user_"+String(data[1])] != null){
							World.instance.users["user_"+String(data[1])].health = 0;
						}
						World.instance.killUnit(World.instance.getUserUnitById(data[1]));
					break;
					case 'reU': // respawn user
						if(Number(data[1]) == ClientInfo.data.id){
							Game.PlayerRevive();
						} else {
							unit = World.instance.getUserUnitById(data[1]);
							if(unit != null){
								World.instance.respawnUnit(unit);
							}
						}
					break;
					case 'stopMove':
						World.instance.handleStopMovePacket(data);
					break;
					case 'useRes': //use Response
						if(data[1] == "wep" || data[1] == "arm" || data[1] == "cla"){
							World.instance.changeEquip(ClientInfo.data.id, data[1], data[2]);
						} else if(data[1] == "tel"){
							UI.instance.removeItemFromInventory(data[2], 1);
							UI.instance.closeWindows();
						} else if(data[1] == "box"){
							UI.instance.removeItemFromInventory(data[2], 1);
						} else {
							//Use response recieved, but unknown command 
						}
					break;
					case 'wepCh': //weapon change
						World.instance.changeEquip(data[1], "wep", data[2]);
					break;
					case 'armCh': //armor change
						trace("armor change");
						World.instance.changeEquip(data[1], "arm", data[2]);
					break;
					case 'zoneResult':
						if(data[1] == "success"){
							if(data[3] == null){
								World.instance.loadMap("Gamefiles/Maps/" + data[2], "", World.instance.nextRoomPad);
							} else {
								World.instance.loadMap("Gamefiles/Maps/" + data[2], data[3], World.instance.nextRoomPad);
							}
							UI.instance.closeWindows();
						}
					break;
					case 'admBC': // admin Broadcast
						Chatbox.instance.postServer(data[3], data[1]);
					break;
					case 'msg':
						data[1] = Utils.capitalize(data[1]);
						Chatbox.instance.postMsg(data[1], data[3], Number(data[2]));
						var u:Unit = World.instance.getUserUnitByName(data[1]);
						if(u != null){
							u.say(data[3]);
						}
					break;
					case 'pm':
						data[1] = Utils.capitalize(data[1]);
						Chatbox.instance.postPM(data[1], data[2]);
					break;
					case 'buyResult':
						if(data[1] == "success"){
							UI.instance.finishedPurchase(true, data[2]);
						} else if(data[1] == "neg"){
							//trace("Not enough currency!");
							UI.instance.finishedPurchase();
						} else if(data[1] == "msr"){
							//trace("Can't Buy Any More!");
							UI.instance.finishedPurchase();
						}
					break;
					case 'sellResult':
						if(data[1] == "suc"){
							UI.instance.removeItemFromInventory(data[3], Number(data[2]), true);
							UI.instance.finishedPurchase();
						} 
					break;
					case 'tele':
						World.instance.teleportUnit(Number(data[1]), data[2], data[3]);
					break;
					case 'userLeft':
						World.instance.handleUserLeave(data);
					break;
					case 'dlRq': //duel request recieved
						UI.instance.showDuelRequest(data[1]);
					break;
					case 'dlDc': //duel decline
						if(data[1].toString() != "1"){
							Chatbox.instance.postMsg("Duel", "request declined!", 6);
						} else {
							Chatbox.instance.postMsg("Duel", "target is already dueling!", 6);
						}
					break;
					case 'dlCa': //duel canceled
						UI.instance.closeDuelRequest(true, data[1]);
					break;
					
					default: 
						trace("STR Cmd: " + cmd);
					break;
				}
			}
			//trace(cmd);
		}
		
		
		public function openConnection(username:String, password:String, ip:String = "127.0.0.1", port:int = 9339){
			if (! sfs.isConnected) {
				this.userUsername = username;
				this.userPassword = password;
				sfs.connect(ip,port);
				LoadingScreen.instance.text = "Connecting...";
			} else {
				Console.log.log("You are already connected!");
				LoadingScreen.instance.text = "Double-Connection Error";
				LoadingScreen.instance.isError = true;
			}
		}
		
		private function onConnection(evt:SFSEvent):void {
			var success:Boolean = evt.params.success;
			if (success) {
				Console.log.log("Connection successfull!");
				LoadingScreen.instance.text = "Entering Zone...";
				sfs.login(sfs.defaultZone, Main.BUILD_HASH+"-"+userUsername, userPassword);
				trace("Sending Login...");
			} else {
				Console.log.log("Connection failed!");
				LoadingScreen.instance.text = "Server Unavailable!";
				LoadingScreen.instance.isError = true;
				Utils.delayFunction(5, reshowServerList);
			}
		}


		private function onConnectionLost(evt:SFSEvent):void {
			Console.log.log("Connection lost!");
			LoadingScreen.instance.percent = 0;
			LoadingScreen.instance.text = "Connection Lost!";
			LoadingScreen.instance.show();
			LoadingScreen.instance.isError = true;
			Game.logout();
			if(Game.banned == false){
				LoadingScreen.instance.hide();
			}
		}
		
		private function onSecurityError(evt:SecurityErrorEvent):void {
			Console.log.log("Security error: " + evt.text);
		}
		
		private function onAdminMessage(e:SFSEvent):void {
			switch(e.params.message){
				case 'BAN':
				LoadingScreen.instance.text = "Banned!";
				LoadingScreen.instance.show();
				LoadingScreen.instance.isError = true;
				break;
			}
		}

		private function onIOError(evt:IOErrorEvent):void {
			Console.log.log("I/O Error: " + evt.text);
		}
		
		public static function get instance():Server{
			if(_instance){
				return _instance;
			}
			return null;
		}
	}
	
}
