function isUser(target){
	return target.properties != null;
}
function handleUserLogout(user){
	var id = Number(user.properties.get("id"));
	var zone = validateSQL(user.properties.get("lastNormalZone"));
	var room = validateSQL(user.properties.get("room"));
	var wepId = Number(user.properties.get("wepId"));
	var armId = Number(user.properties.get("armorId"));
	var gold = user.properties.get("gold");
	var xp = getXP(user);
	var level = getLevel(user);
	var setQuery = "lastZone='"+zone+"', lastRoom='"+room+"', weaponId='"+wepId+"', armorId='"+armId+"', gold='"+gold+"', xp='"+xp+"', level='"+level+"', lastLogoutIP='"+user.getIpAddress()+"'";
	
	
	sql = "UPDATE characters SET "+setQuery+" WHERE id="+id+"";
	database.executeCommand(sql)
}


function cancelDuelRequest(user){
	if(user.properties.get("duelTarget") != -1 && user.properties.get("duelTarget") != null){
		var timeNow = new Date().getTime();
		var duelee = getUserById(Number(user.properties.get("duelTarget")));
		if(duelee != null){
			var requestTime = user.properties.get("duelTime");
			if(requestTime != null && requestTime != -1){
				if(((timeNow - requestTime) < 32000)){
					_server.sendResponse(["dlCa", user.getUserId()], -1, null, [duelee], "str");
				}
			}
		}
	}
}


function getXPToLevel(lvl){
	lvl += 1;
	var xpBase = 20;
	if(lvl > 1 && lvl < 10 + 1){
		xpBase = 40;
	}else if(lvl > 10 && lvl < 20 + 1){
		xpBase = 85;
	}else if(lvl > 20 && lvl < 30 + 1){
		xpBase = 120;
	}else if(lvl > 30 && lvl < 50 + 1){
		xpBase = 190;
	}else if(lvl > 50 && lvl < 60 + 1){
		xpBase = 340;
	}
	var newXP = xpBase * lvl * (1+lvl);
	return newXP;
}
function getLevelHP(level){
	return 100 + (8 * (level - 1));;
}
function getHealth(target){
	if(target != null){
		if(!isUser(target)){ //if target is an enemy and not a user
			return target.hp;
		} else {
			return Number(target.properties.get("hp"));
		}
	}
	return 0;
}


function setHealth(amount, target){
	if(target != null && isFinite(amount)){
		if(isUser(target)){
			target.properties.put("hp", Number(amount));
		}
	}
}

function getUserRoomId(target){
	if(target != null){
		return target.getRoomsConnected()[0];
	}
	return null;
}

function getMaxHealth(target){
	if(target != null){
		if(!isUser(target)){ //if target is an enemy and not a user
			return target.hpMax;
		} else {
			return Number(target.properties.get("hpmax"));
		}
	}
	return 0;
}

function getLevel(target){
	if(target != null){
		if(!isUser(target)){ //if target is an enemy and not a user
			return target.level;
		} else {
			return Number(target.properties.get("level"));
		}
	}
	return 0;
}
function getXP(target){
	if(target != null){
		return Number(target.properties.get("xp"));
	}
	return 0;
}
function getPvP(target){
	if(target != null){
		return target.properties.get("pvp");
	}
	return false;
}
function setPvP(bool, target){
	if(target != null){
		target.properties.put("pvp", Boolean(bool));
	}
}
function getGold(target){
	if(target != null){
		return Number(target.properties.get("gold"));
	}
	return 0;
}
function setXP(amount, target){
	if(target != null){
		target.properties.put("xp", Number(amount));
	}
}
function getCharId(target){
	if(target != null){
		return Number(target.properties.get("id"));
	}
	return null;
}
function getAccess(target){
	if(target != null){
		if(isUser(target)){ //if target is a user
			return Number(target.properties.get("access"));
		}
	}
	return 0;
}

function getState(target){
	if(target != null){
		return Number(target.properties.get("state"));
	}
	return -1;
}
function setState(state, target){
	if(target != null){
		target.properties.put("state", Number(state));
	}
}



function saveGold(newGold, user){
	if(user != null && isFinite(newGold)){
		newGold = Number(newGold);
		var uId = getCharId(user);
		sql = "UPDATE characters SET gold="+newGold+" WHERE id="+uId+"";
		var success = database.executeCommand(sql);
		if(success){
			user.properties.put("gold", newGold);
			return true;
		} else {
			trace("ERROR GOLD NOT SAVED: Database Query Failed!");
		}
	} else {
		trace("ERROR GOLD NOT SAVED: User Null OR Gold Not Finite!");
	}
}

function saveLevel(newLevel, user){
	if(user != null && isFinite(newLevel)){
		newLevel = Number(newLevel);
		var uId = getCharId(user);
		sql = "UPDATE characters SET level="+newLevel+" WHERE id="+uId+"";
		var success = database.executeCommand(sql);
		if(success){
			user.properties.put("level", newLevel);
			return true;
		} else {
			trace("ERROR LEVEL NOT SAVED: Database Query Failed!");
		}
	} else {
		trace("ERROR LEVEL NOT SAVED: User Null OR Level Not Finite!");
	}
	return false;
}
function saveClass(id, user){
	if(user != null){
		user.properties.put("classItemId", id);
		var uId = getCharId(user);
		var sql = "UPDATE characters SET classId="+id+" WHERE id="+uId+"";
		var success = database.executeCommand(sql);
	}
}

function changeUserClass(classId, user){
	if(user != null){
		user.properties.put("class", classId);
		parseClass(user.properties.get("class"));
		
		var obj = {};
		obj.cmd = "chAb";
		obj.d = getClassAbilityInfo(user.properties.get("class"));
		_server.sendResponse(obj, -1, null, [user], "json");
	}
}



// -------------- QUESTS -------------------------------
function getQuestObjectives(target){
	if(target != null){
		if(isUser(target)){ //if target is a user
			var e = String(target.properties.get("questObj")).split(",");
			return e;
		}
	}
	return 0;
}

function setQuestObjectives(newObj, target){
	if(target != null){
		if(isUser(target)){ //if target is a user
			var e = newObj.join(",");
			if(e.indexOf(",") == 0){
				e = e.substr(1);
			}
			target.properties.put("questObj", e);
		}
	}
}
function getActiveQuests(target){
	if(target != null){
		if(isUser(target)){ //if target is a user
			var e = String(target.properties.get("activeQuests")).split(",");
			return e;
		}
	}
	return 0;
}

function setActiveQuests(newObj, target){
	if(target != null){
		if(isUser(target)){ //if target is a user
			var e = newObj.join(",");
			if(e.indexOf(",") == 0){
				e = e.substr(1);
			}
			target.properties.put("activeQuests", e);
		}
	}
}

function getCompletedQuests(target){
	if(target != null){
		var e = String(target.properties.get("quests"));
		var a = e.split(",");
		return a;
	}
	return [];
}
//------------------------------------------------------