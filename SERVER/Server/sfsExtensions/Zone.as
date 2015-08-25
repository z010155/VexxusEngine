var cachedZones = {};
var cachedEnemies = {};

function requestEnterZone(user, name, mapRoom, id){
	if(user.properties.get("zone") == name){
		return;
	}
	if(id == null){
		id = -1;
	}
	var zone = getZoneByName(name);
	if(zone != null){
		var swfURL = zone.swfURL;
		var access = Number(zone.access);
		if(Number(user.properties.get("access")) >= access){
			var obj = [];
			obj.push("zoneResult"); 
			obj.push("success"); 
			obj.push(swfURL); 
			if(mapRoom != null){
				obj.push(mapRoom);
			}
			_server.sendResponse(obj, -1, null, [user], "str");
			user.properties.put("nextZone", name);
			user.properties.put("nextZoneId", id);
		} else {
			//trace("Access Too Low!");
		}
	}
}
function joinZone(user, zoneName, id){
	var room;
	if(zoneName){
		//join specific zone
		if(id != null && id != -1){
			room = getAvailableRoom(zoneName, user, id);
		} else {
			room = getAvailableRoom(zoneName, user);
		}
	} else {
		room = getAvailableRoom(GLOBALS.DEFAULT_MAP, user);
	}
	var rIdToLeave = -1;
	var newId = room.getId();
	if(user.getRoomsConnected()[0] != null){
		rIdToLeave = user.getRoomsConnected()[0];
		userLeftRoom(user, zone.getRoom(rIdToLeave)); 
	}
	_server.joinRoom(user, rIdToLeave, true, newId);
	user.properties.put("nextZone", "")
	user.properties.put("nextZoneId", -1)
	user.properties.put("zone", zoneName)
	room.properties.put("actualName", zoneName);
	if(room.properties.get("pvp") == 1){
		setPvP(true, user);
	} else {
		setPvP(false, user);
		user.properties.put("lastNormalZone", zoneName)
	}
	sendRoomData(user, newId);
	userJoinedRoom(user, room);
	
	//trace("User Joined Zone");
}

function sendRoomData(user, sfsRoomId){
	user.properties.put("zoneInit", true);
	var sfsRoom = zone.getRoom(sfsRoomId);
	var zoneName = sfsRoom.properties.get("actualName");
	var users = sfsRoom.getAllUsers();
	var usersInRoom = [];
	var obj = {};
	obj.cmd = "zoneData";
	obj.users = [];
	obj.enemies = [];
	if(sfsRoom.properties.get("pvp") == true){
		obj.isPvP = true;
	} else {
		obj.isPvP = false;
	}
	
	for(i = 0; i < users.length; i++){
		if(users[i].getName() != user.getName()){
			var u = {};
			u.name = String(users[i].getName());
			u.id = Number(users[i].getUserId());
			u.x = Number(users[i].properties.get("x"))
			u.y = Number(users[i].properties.get("y"));
			u.room = String(users[i].properties.get("room"))
			u.dir = String(users[i].properties.get("dir"))
			u.gen = String(users[i].properties.get("gender"))
			u.wep = String(getItemFileById(users[i].properties.get("wepId")))
			u.arm = String(getItemFileById(users[i].properties.get("armorId")))
			u.hp = Number(users[i].properties.get("hp"))
			u.hpm = Number(users[i].properties.get("hpmax"))
			u.acc = Number(users[i].properties.get("access"))
			u.lvl = Number(users[i].properties.get("level"));
			obj.users.push(u);
		}
	}
	obj.enemies = getRoomEnemyInfo(sfsRoom);
	_server.sendResponse(obj, -1, null, [user], "json");
}



function getRoomEnemyInfo(room){
	var obj = [];
	var enemies = room.properties.get("enemies");
	for(var i = 0; i < enemies.length; i++){
		obj[i] = getEnemyInfo(i, enemies);
	}
	return obj;
}
function getEnemyInfo(i, enemies){
	var obj = {};
	obj.id = enemies[i].id
	obj.name = enemies[i].name
	obj.file = enemies[i].file
	obj.linkage = enemies[i].linkage
	obj.hp = enemies[i].hp
	obj.hpMax = enemies[i].hpMax
	obj.pad = enemies[i].pad
	obj.room = ""+enemies[i].room
	obj.level = enemies[i].level;
	obj.type = enemies[i].type;
	obj.inC = enemies[i].inCombat;
	
	return obj;
}


function userJoinedRoom(user, room){
	var u = {};
	u.name = String(user.getName());
	u.id = Number(user.getUserId());
	u.x = Number(user.properties.get("x"))
	u.y = Number(user.properties.get("y"));
	u.room = String(user.properties.get("room"))
	u.dir = String(user.properties.get("dir"))
	u.gen = String(user.properties.get("gender"))
	u.wep = String(getItemFileById(user.properties.get("wepId")))
	u.arm = String(getItemFileById(user.properties.get("armorId")))
	u.hp = Number(user.properties.get("hp"))
	u.hpm = Number(user.properties.get("hpmax"))
	u.acc = Number(user.properties.get("access"))
	u.lvl = Number(user.properties.get("level"));
	
	var obj = {};
	obj.cmd = "userJoined";
	obj.user = u;
	sendToAllUsersButOneJSON(obj, room.getId(), user);
}



function userLeftRoom(user, room){
	var obj = [];
	obj.push("userLeft");
	obj.push(user.getUserId())
	sendToAllUsersButOne(obj, room.getId(), user);	
}
function getAvailableRoom(name, user, num){
	if(!num){
		num = 1;
	}
	num = Math.round(num);
	if(zone.getRoomByName(name + "-" + num) != null){
		room = zone.getRoomByName(name + "-" + num);
		if(room.getUserCount() < room.getMaxUsers()){
			// room has space
			return room;
		} else {
			// room full
			return getAvailableRoom(name,user,num+1);
		}
	} else {
		//room doesn't exist, create room and add user
		var roomObj = {}
		var enemyList = [];
		roomObj.name = name + "-" + num;
		if(cachedZones[name].maxUsers != undefined && cachedZones[name].maxUsers > 0){
			roomObj.maxU = cachedZones[name].maxUsers;
		} else {
			roomObj.maxU = MAX_ROOM_USERS;
		}
		if(cachedZones[name].enemyArchitecture != ""){
			var eArch = cachedZones[name].enemyArchitecture.split(",");
			
			var enemies = [];
			for(var i = 0; i < eArch.length; i++){
				enemies.push(eArch[i].split(":"));
			}
			var eRoom;
			var ePad;
			var eId;
			var eInfo;
			for(i = 0; i < enemies.length; i++){
				eInfo = getEnemyById(enemies[i][2])
				if(eInfo != null){
					eRoom = enemies[i][0];
					ePad = enemies[i][1];
					eId = enemies[i][2];
					
					//trace(cachedEnemies[enemies[i][2]].name + ": located in " + eRoom + " at pad" + ePad);
					var newEnemy = {};
					newEnemy.id = enemyList.length;
					newEnemy.name = eInfo.name;
					newEnemy.file = eInfo.file;
					newEnemy.linkage = eInfo.linkage;
					newEnemy.hp = eInfo.hp;
					newEnemy.hpMax = eInfo.hp;
					newEnemy.pad = ePad;
					newEnemy.room = eRoom;
					newEnemy.level = eInfo.level;
					newEnemy.type = eInfo.type;
					newEnemy.questDrops = eInfo.questDrops;
					newEnemy.itemDrops = eInfo.itemDrops;
					newEnemy.goldDrop = eInfo.goldDrop; 
					newEnemy.xpDrop = eInfo.xpDrop;
					newEnemy.animList = eInfo.animList;
					
					newEnemy.minDamage = eInfo.minDamage;
					newEnemy.maxDamage = eInfo.maxDamage;
					newEnemy.targets = [];
					newEnemy.inCombat = false;
					
					enemyList.push(newEnemy);
				}
			}
		}
		
		var newRoom = _server.createRoom(roomObj, user)
		_server.sendRoomList(user);
		newRoom.properties.put("enemies", enemyList);
		if(Number(cachedZones[name].isPvP) == 1){
			newRoom.properties.put("pvp", 1);
		} else {
			newRoom.properties.put("pvp", 0);
		}
		if (newRoom != null){
			//room created, return room object
			return newRoom;
		} else {
			trace("ERROR OCCURED CREATING ROOM: " + name + "-" + num);
			return null;
		}
	}
}

function getEnemyById(id){
	if(cachedEnemies[id] == null){
		var enemy = query("SELECT * FROM enemies WHERE id="+id+"");
		if(enemy[0] != null){
			cachedEnemies[""+id] = enemy[0];
			cachedEnemies[""+id].minDamage = Number(enemy[0].damage.split("-")[0]);
			cachedEnemies[""+id].maxDamage = Number(enemy[0].damage.split("-")[1]);
			return enemy[0];
		}
	}
	return cachedEnemies[id];
}

function getZoneByName(name){
	var zoneName = validateSQL("" + name); // quotes bypass casting bug
	var zone;
	if(cachedZones.hasOwnProperty(zoneName)){
		zone = cachedZones[zoneName]
	} else {
		var zoneQuery = query("SELECT * FROM zones WHERE zoneName='" + zoneName + "'");
		if(zoneQuery[0] != null){
			zone = zoneQuery[0];
			cachedZones[zoneName] = zoneQuery[0];
		} else {
			return null;
		}
	}
	return zone;
}

function spawnEnemy(id, pad, roomLabel, zone){
	var eInfo = getEnemyById(Number(id));
	if(eInfo != null){
		var eList = zone.properties.get("enemies");
		var newEnemy = {};
		newEnemy.id = eList.length;
		newEnemy.name = eInfo.name;
		newEnemy.file = eInfo.file;
		newEnemy.linkage = eInfo.linkage;
		newEnemy.hp = eInfo.hp;
		newEnemy.hpMax = eInfo.hp;
		newEnemy.pad = pad;
		newEnemy.room = roomLabel;
		newEnemy.level = eInfo.level;
		newEnemy.type = eInfo.type;
		newEnemy.questDrops = eInfo.questDrops;
		newEnemy.itemDrops = eInfo.itemDrops;
		newEnemy.goldDrop = eInfo.goldDrop; 
		newEnemy.xpDrop = eInfo.xpDrop;
		newEnemy.animList = eInfo.animList;
		
		newEnemy.minDamage = eInfo.minDamage;
		newEnemy.maxDamage = eInfo.maxDamage;
		newEnemy.targets = [];
		newEnemy.inCombat = false;
		
		eList.push(newEnemy);
		var obj = {}; //enemy spawn
		obj.cmd = "eSpn"
		obj.info = getEnemyInfo(newEnemy.id, eList);
		
		sendToAllUsers(obj, zone.getId(), "json");
	}
}