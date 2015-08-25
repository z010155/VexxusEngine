package {

	import flash.display.MovieClip;
	import flash.events.*;
	import com.util.File;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import flash.system.ApplicationDomain;
	import flash.system.*;
	import flash.geom.Point;

	public class Game {

		private var stage:MovieClip;
		public static const MELEE_RANGE:int = 65;
		public static const DEFAULT_SIZE:int = 24;
		public static const WEAPON_URL:String = "Gamefiles/Items/Weapons/";
		public static const ARMOR_URL:String = "Gamefiles/Items/Armors/";
		public static const ENEMY_URL:String = "Gamefiles/Enemies/";
		public static const ENEMY_ANIMATION_LIBRARY:Object = {1: "Attack1", 2:"Attack2", 3:"Attack3", 4:"Attack4"}
		public static const EMOTE_LIBRARY:Object = {1: "Attack"}
		public static const GLOBAL_COOLDOWN:Number = 1;
		public static const ZONE_CHANGE_COOLDOWN:Number = 2.5;
		public static var latency:Number = 0.25;
		public static var banned:Boolean = false;
		
		private var assets:Array = [];
		public var server:Server;
		public var sfs:SmartFoxClient;
		public var world:World;	
		public var ui:MovieClip;
		public static var lastGlobalCooldownTime:Number = 0;
		
		public function Game() {
			stage = Main.STAGE;
			server = new Server(this);
			sfs = server.sfs;
			world = new World();
			Main.STAGE.gotoAndStop("Game");
		}
		public function handleLogin(){
			var i:int = 0;
			var wepFile:File = new File(Game.WEAPON_URL + ClientInfo.data.weaponFile, wepLoadComplete, null, wepOnFailure);
			var armFile:File = new File(Game.ARMOR_URL + ClientInfo.data.genderToString.toLowerCase() + "/" + ClientInfo.data.armorFile, armLoadComplete, null, armOnFailure);
			
			
			function wepLoadComplete(e:Event){
				i++;
				ClientInfo.data.weaponAD = e.target.applicationDomain
				if(i == 2){
					Server.instance.enterZone("default");
				}
			}
			function wepOnFailure(e:Event){
				i++;
				if(i == 2){
					trace("Error loading weapon asset!");
					Server.instance.enterZone("default");
				}
			}
			
			
			function armLoadComplete(e:Event){
				i++;
				ClientInfo.data.armorAD = e.target.applicationDomain
				if(i == 2){
					Server.instance.enterZone("default");
				}
			}
			function armOnFailure(e:Event){
				i++;
				if(i == 2){
					trace("Error loading armor asset!");
					Server.instance.enterZone("default");
				}
			}
		}
		public function init(assetList:String){
			if(Main.assets["template"] != null){
				initFull();
			} else {
				assets = [];
				var assetListAr:Array = assetList.split(",");
				for(var i:int = 0; i < assetListAr.length; i++){
					var e:Array = assetListAr[i].split(":");
					var a:Array = [];
					if(e.length == 3){
						a.push(e[0]);
						a.push(e[1]);
						a.push(e[2] == "true");
					} else {
						a.push(e[0]);
						a.push(e[1]);
					}
					assets.push(a);
				}
				loadAssets();
			}
		}
		private function initFull(){
			stage.worldHolder.addChild(world);
			ui = UI.instance;
			handleLogin();
			UI.instance.updateAbilityIcons();
		}
		private function loadAssets(){
			if(assets.length > 0){
				var asset:File = new File(assets[0][1], loadAssetComplete, null, loadAssetFailed);
			} else {
				initFull();
			}
		}
		private function loadAssetFailed(e:Event){
			trace(assets[0][0] + " failed to load!");
			assets.shift();
			loadAssets();
		}
		private function loadAssetComplete(e:Event){
			Main.assets[assets[0][0]] = e.target.applicationDomain;
			if(assets[0][2] != null && assets[0][2] == true){
				Main.assets[assets[0][0]+"_file"] = e.target.content;
			}
			assets.shift();
			loadAssets();
		}
		
		public static function PlayerDeath(){
			UI.instance.isDead = true;
			World.instance.disableMovement();
		}
		public static function PlayerRevive(){
			UI.instance.isDead = false;
			World.instance.enableMovement();
			World.instance.respawnUnit(World.instance.playerUnit);
		}
		public static function logout(){
			destroyGameSingletons();
			Main.STAGE.completeLogout();
		}
		public static function destroyGameSingletons(){
			World.instance.destroy();
			Server.instance.destroy();
			if(ClientInfo.data != null){
				ClientInfo.data.destroy();
			}
			if(Tooltip.instance != null){
				Tooltip.instance.destroy();
			}
			if(Chatbox.instance != null){
				Chatbox.instance.destroy();
			}
			if(UI.instance != null){
				UI.instance.destroy();
			}
			if(Console.log != null){
				Console.log.destroy();
			}
		}
		
		public static function useAbility(abilityNumber:int){
			if(ClientInfo.data.abilities[abilityNumber - 1] != null){
				var currentTime:Number = new Date().time;
				if((currentTime - lastGlobalCooldownTime) > (Game.GLOBAL_COOLDOWN-latency) * 1000 || abilityNumber == 1){
					var ability:Object = ClientInfo.data.abilities[abilityNumber - 1];
					ability.isFriendly = Number(ability.friendly);
					
					if(ability.lastUseTime == null || (currentTime - ability.lastUseTime) > ((ability.cd-latency) * 1000)){
						var range:Number = Game.MELEE_RANGE;
						var point:Point;
						var targets:Array = [];
						var i:int;
						if(Number(ability.range) != -1){
							range = Number(ability.range);
						}
						
						
						if(ability.isFriendly == 1){
							if(ability.maxTgt == 0 || (ability.minTgt < 1 && (World.instance.target == null || World.instance.target.isPlayer == false || World.instance.isPvPZone))){
								targets.push(World.instance.playerUnit);
							}
							
						}
						if(World.instance.target != null && ability.maxTgt != 0 && targets.length < ability.maxTgt){
							targets.push(World.instance.target);
						}
						
						if(Number(ability.friendly) != 1 && ability.maxTgt > 1){
							var e:Array = World.instance.getEnemiesInRange(ability.range);
							for(i = 0; i < e.length; i++){
								if(targets.length < ability.maxTgt){
									if(targets.indexOf(e[i]) == -1){
										targets.push(e[i]);
									}
								} else {
									break;
								}
							}
						} //push multiple target ids into targets
						
						
						if((targets.length <= ability.maxTgt && targets.length >= ability.minTgt) || (targets[0] == World.instance.playerUnit && ability.maxTgt == 0)){
							for(i = 0; i < targets.length; i++){
								if(Utils.getDistance(World.instance.playerUnit, targets[i]) > range){
									if(i == 0){
										if(targets[i] != null){
											point = targets[i].getMeleeRangePos(World.instance.playerUnit);
											World.instance.playerUnit.autoIdle = true;
											World.instance.playerUnit.moveTo(point.x, point.y);
											Server.instance.sendStoppedMove(point.x, point.y, World.instance.playerUnit.dirAsInt);
										}
									}
									return;
								}
							}
							//targets all in range
							if(targets[0] != null){
								if(ability.isFriendly == 1 && targets[0].isPlayer == false){ //if spell is friendly but target is not
									//trace("Aborting: Spell is Friendly But Target Is Not!")
									return; //cancel
								} else if(ability.isFriendly == 0 && targets[0].isPlayer == true && !World.instance.isPvPZone){ //if spell is not friendly and target is player and zone is not PvP enabled
									//trace("Aborting: Spell is not friendly and target is a player in a non-PvP zone!");
									return; //cancel
								} else {
									trace("Combat sending: " + abilityNumber, World.instance.convertArrayOfUnitsToArrayOfIds(targets), int(targets[0].isPlayer));
									Server.instance.sendXt("a" + abilityNumber, [World.instance.convertArrayOfUnitsToArrayOfIds(targets), int(targets[0].isPlayer)], "str");
								}
							}
						}
					}
				}
			}
		}
		public static function cooldown(intAbilityNumber:int, gcd:Boolean = true){
			var ability:Object = ClientInfo.data.abilities[intAbilityNumber - 1];
			if(ability != null){
				var currentTime:Number = new Date().time;
				ability.lastUseTime = currentTime;
				UI.instance.pushCooldown(intAbilityNumber, ability.cd);
				if(gcd){
					lastGlobalCooldownTime = currentTime;
					UI.instance.globalCooldown();
				}
				
			}
		}
		public static function getAbilityTooltip(id:int):String{
			if(ClientInfo.data.abilities[id] != null){
				var t:String = "";
				t += ClientInfo.data.abilities[id].name + "\n";
				if(Number(ClientInfo.data.abilities[id].lvlreq) > ClientInfo.data.level){
					t += "<font color='#CC0000'>Level " + ClientInfo.data.abilities[id].lvlreq + " required!</font>" + "\n";
				}
				if(ClientInfo.data.abilities[id].rpCost > 0){
					t += ClientInfo.data.abilities[id].rpCost + " " + Game.getResourceTypeById(ClientInfo.data.abilities[id].rpType) + "\n";
				}
				if(ClientInfo.data.abilities[id].cd > Game.GLOBAL_COOLDOWN){
					t += ClientInfo.data.abilities[id].cd + " second cooldown \n";
				}
				t += ClientInfo.data.abilities[id].desc + "\n";
				
				return t;
			}
			return "";
		}
		public static function getResourceTypeById(id:int):String{
			switch(id){
				case 0:
					return "Health";
				break;
				case 1:
					return "Mana";
				break;
				case 2:
					return "Rage";
				break;
				case 3:
					return "Energy";
				break;
			}
			return "Unknown";
		}
		
	}

}