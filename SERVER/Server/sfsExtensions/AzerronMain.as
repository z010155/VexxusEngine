#include "Util.as"
#include "TargetUtil.as"
#include "TaskHandler.as"
#include "ChatCommandHandler.as"
#include "RequestHandler.as"
#include "Zone.as"
#include "Items.as"
#include "Combat.as"
#include "Quests.as"

var _scheduler = Packages.it.gotoandplay.smartfoxserver.util.scheduling

var scheduler;
var database;
var zone;

// CONSTANTS
var MEMBER = 2;
var MOD = 3;
var STAFF = 4;
var ADMIN = 5;


var STATE = {
	idle:0, 
	rest:1, 
	combat:2
};
var PERMISSIONS = {
	Broadcast: STAFF, 
	Kick: MOD, 
	Ban: MOD, 
	Give: MOD,
	Mute: MOD
};
				   
var MAX_ROOM_USERS = 10;
var MAX_LEVEL = 60;
var SAVE_GOLD_CHANCE = 25;
var RESPAWN_TIMER = 9.5;

var xpRate = 1;
var goldRate = 1;

var GLOBALS = {DEFAULT_MAP:"forest"};

var BUILD_HASH = "48ddd1dd784db04d5afc91e477ccd412";

//----------------
var tasks = {}
var taskHandler = new _scheduler.ITaskHandler(tasks)

var assetList = "template:Gamefiles/Templates/Template1.swf,icons_common:Gamefiles/UI/Icons/Common.swf,icons_abilities:Gamefiles/UI/Icons/Abilities.swf,spell_effects:Gamefiles/Animations/SpellEffects/Effects1.swf:true";

//access 0: banned
//access 1: normal player
//access 2: member
//access 3: mod
//access 4: staff
//access 5: admin

function init(){
	database = _server.getDatabaseManager();
	zone = _server.getCurrentZone();
	
	scheduler = new _scheduler.Scheduler()
	scheduler.startService()
	
	tasks.count = 0;
	tasks.doTask = handleTasks;
	
	cacheDB();
	
	var task = newTask({cmd:"restLoop"});
	addTask(task, 3.5, true);
};
function destroy(){
	delete database;
	delete zone;
	scheduler.destroy(null);
};

function handleInternalEvent(evt){
	if(evt.name == "loginRequest"){
			var error = ""
			var ban = false;
			var nick = evt["nick"]
			var pass = evt["pass"]
			var chan = evt["chan"]
			var hash = nick.split("-")[0]
			nick = nick.replace(hash + "-", "").toLowerCase();
			if(hash != BUILD_HASH){
				_server.sendResponse({cmd:"loginResponse", err:"outdated"}, -1, null, chan, "json");
				return;
			}
			if(nick.length < 3 || pass.length < 6){
				return;
			}
			if(zone.getUserByName(nick) == null){
				var obj = _server.loginUser(nick, pass, chan)
				var user = _server.getUserByChannel(chan)
				var info = new Object;
				info.cmd = "loginResponse";
				
				if (obj.success == false){
					error = obj.error;
				} else {  
					_server.sendRoomList(user);
					var sql = "SELECT id, username, password, email, access, gold, xp, level, classId, armorId, weaponId, gender, inventorySlots, lastZone, lastRoom, quests FROM characters WHERE username='" + _server.escapeQuotes(nick) + "'";
					var list = query(sql);
					
					if (list[0] != null) {
						
						var row = list[0];
						
						var password = _server.md5(pass);
						
						if(password == String(row.password)){
							if(Number(row.access) > 0){
								var access = Number(row.access);
								var level = row.level;
								var hp = getLevelHP(level);
								var mp = 100;
								var gold = Number(row.gold);
								var xp = Number(row.xp);
								var gender = row.gender;
								var quests  = row.quests;
								
								var wepId = row.weaponId;
								var armorId = row.armorId;
								
								var classItemId = Number(row.classId);
								var classId;
								if(Number(classItemId) > 0){
									var classData = getItemById(classItemId);
									classId = Number(classData.itemData);
								} else {
									classId = 0;
								}
								
								
								var melee_defense = 1;
								var magic_defense = 1;
								var strength = 1;
								
								
								
								
								user.properties.put("id", Number(row.id));
								user.properties.put("iSlots", Number(row.inventorySlots));
								user.properties.put("gold", gold);
								user.properties.put("xp", xp);
								user.properties.put("level", level);
								user.properties.put("quests", quests);
								user.properties.put("questObj", "");
								user.properties.put("activeQuests", "");
								user.properties.put("access", access);
								user.properties.put("lastPacketTime", -1)
								user.properties.put("packetCount", 0)
								
								user.properties.put("gender", gender);
								user.properties.put("wepId", wepId);
								user.properties.put("armorId", armorId);
								user.properties.put("classItemId", classItemId);
								
								user.properties.put("lZone", row.lastZone);
								user.properties.put("lRoom", row.lastRoom);
								
								user.properties.put("y", 0);
								user.properties.put("x", 0);
								user.properties.put("room", "");
								
								user.properties.put("hp", hp);
								user.properties.put("hpmax", hp);
								user.properties.put("mp", mp);
								user.properties.put("mpmax", mp);
								user.properties.put("class", classId);
								user.properties.put("pvp", false);
								
								user.properties.put("melee_defense", melee_defense);
								user.properties.put("state", STATE.idle);
								user.properties.put("target", -1);
								user.properties.put("cd1", -1);
								user.properties.put("cd2", -1);
								user.properties.put("cd3", -1);
								user.properties.put("cd4", -1);
								user.properties.put("cd5", -1);
								
								parseClass(user.properties.get("class"));
								
								info.gold = gold; 
								info.access = access;
								info.xp = xp;
								info.id = user.getUserId();
								info.gender = gender;
								info.weapon = getItemFileById(wepId);
								info.armor = getItemFileById(armorId);
								info.hp = hp;
								info.level = level;
								info.abilities = getClassAbilityInfo(user.properties.get("class"));
								info.assets = assetList;
								
							} else {
								error = "banned";
								ban = true;
							}
						} else {
							error = "badpass";
						}
					} else {
						error = "baduser";
					}
					if (error != ""){
						info.err = error
					}
				}
				_server.sendResponse(info, -1, null, chan, "json");
				if(ban){
					_server.kickUser(user, 1, "BAN");
				}
			} else {
				trace("DOUBLE LOGIN ERROR -----");
				_server.kickUser(zone.getUserByName(nick), 0, "DOUBLE_LOGON");
				_server.sendResponse({cmd:"loginResponse", err:"double"}, -1, null, chan, "json");
			}
			 
	} else if(evt.name == "userLost"){
		if(evt.roomIds[0] != null){
			handleUserLogout(evt.user);
			userLeftRoom(evt.user, zone.getRoom(evt.roomIds[0]));
		}
	} else if(evt.name == "userExit"){
		if(evt.room != null){
			handleUserLogout(evt.user);
			userLeftRoom(evt.user, evt.room);
		}
	}
};
