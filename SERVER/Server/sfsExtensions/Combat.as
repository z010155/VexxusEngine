var ENEMY_RESPAWN_TIME = 10;
var PLAYER_RESPAWN_TIME = 10;
var GLOBAL_COOLDOWN_TIME = 1;
var ENEMY_COOLDOWN_TIME = 1.8;

var cachedAuras = {};
var cachedAbilities = {};
var cachedClasses = {};

function abilityUseRequest(params, user, num){
	if(isDead(user)){return;}
	setState(STATE.idle, user)
	handleAbilityUse(params, user, num);
}

function handleAbilityUse(params, user, abilityNumber) {
	var abilityId = getClassById(user.properties.get("class")).abilities[abilityNumber - 1];
	var ability = getAbilityById(abilityId);
	if(user != null && !isDead(user) && ability != null && getLevel(user) >= Number(ability.lvlReq)) {
		var lastGlobalAttack = user.properties.get("lastGlobalAttack");
		var lastAbilityUsage = user.properties.get("cd" + abilityNumber);
		var timeNow = new Date().getTime();
		if(lastGlobalAttack != null){
			if(((timeNow - lastGlobalAttack) < (GLOBAL_COOLDOWN_TIME - 0.25)*1000) && abilityNumber != 1){
				return; // Global cooldown still active!
			}
		}
		if(abilityNumber == 1 && ability.cd == -1){
			ability.cd = GLOBAL_COOLDOWN_TIME;
		}
		if(lastAbilityUsage != null && lastAbilityUsage != -1) {
			if(((timeNow - lastAbilityUsage) < (ability.cd - 0.25)*1000)) {
				return; // Ability still on cooldown!
			}
		}
		

		var uId = user.getUserId();
		var room = getRoomById(user.getRoomsConnected()[0]);
		var abilityUsedSuccessfully = false;
		var targetIsPlayer = params[1];
		var target;
		var auras;
		var i;
		var selectedAura;
		var finalDamage = 0;
		//trace("Ability ID: " + abilityId);
		var targetIds = params[0].toString();
		if(targetIds.indexOf(",") != -1){
			targetIds = targetIds.split(",")
		} else {
			targetIds = [targetIds];
		}
		var targetId;
		var faceTarget = 1;
		ability.amount = Number(ability.amount);
		var isHeal = 0;
		var c = ability.maxTgt;
		if(c == 0){
			c=1;
		}
		var targetsWithDamage = "";
		var targetsHandled = [];
		
		for(i = 0; i < c; i++){
			target = null;
			targetId = null;
			if(targetIds[i] != null){
				//Targeting checks, and set targt
				
				if(targetIds[i] != -1 && targetsHandled.indexOf(Number(targetIds[i])) == -1) {
					if(targetIsPlayer == null || targetIsPlayer == 0 || targetIsPlayer == "0") {//is targeting enemy
						targetIsPlayer = 0;
						
						targetId = Number(targetIds[i]);
						target = room.properties.get("enemies")[targetId];
						if(target == null || user.properties.get("room") != ""+target.room) {
							target = null;
						}
						if(target != null && target.hp < 1){
							target = null;
						}
					} else {//is targeting a player
						targetIsPlayer = 1;
						targetId = Number(targetIds[i]);
						target = getUserById(targetId);
					}
				}
				//PvP check
				if(ability.isHeal != 1 && ability.isFriendly != 1 && targetIsPlayer == 1 && getPvP(target) != true){continue;}
				
				//Deal damage or healing
				if(target != null && getHealth(target) > 0){
					if(ability.isHeal != 1) { //not heal
						var dmg = Math.round(getPlayerDamage(user) * ability.amount);
						if(dmg > 0 && ability.minTgt > 0) {
							finalDamage = damageTarget(target, dmg, user);
						} else {
							//self targeting buff
						}
					} else { //is heal
						var healAmount = getPlayerDamage(user) * ability.amount;
						finalDamage = healTarget(target, healAmount);
						isHeal = 1;
					}
					if(i != 0){
						targetsWithDamage += ",";
					}

					targetsWithDamage += targetId + ":" + finalDamage;
					applyAbilityAuras(ability, user, target, room, finalDamage);
					abilityUsedSuccessfully = true;
					targetsHandled.push(Number(targetId));
				}
				
			} else {
				break;
			}
		}
		
		
		
		if(abilityUsedSuccessfully) {
			var obj = [];
			obj.push("cd");
			obj.push(abilityNumber);
			if(abilityNumber == 1){
				obj.push("1");
			}
			if(Number(abilityNumber) > 1){
				user.properties.put("lastGlobalAttack", timeNow);
			}
			user.properties.put("cd" + abilityNumber, timeNow);
			_server.sendResponse(obj, -1, null, [user], "str");
			sendToAllUsers(["abu", uId, targetsWithDamage, targetIsPlayer, ability.anim, ability.fx, faceTarget, isHeal], room.getId());	//caster id, target id, targetIsPlayer, animation, effects, damage, faceTarget, isHeal
		}

	}
}


function applyAbilityAuras(ability, user, target, room, dmg){
	if(ability.auras.length > 1) {
		auras = ability.auras.split(",");
		for(i = 0; i < auras.length; i++){
			if(auras[i].length > 0){
				selectedAura = auras[i].split(":");
				if(selectedAura[0] == "t"){
					applyAura(user, target, Number(selectedAura[1]), room, dmg)
				} else {
					applyAura(user, user, Number(selectedAura[1]), room, dmg)
				}
			}
		}
	}
}

function damagedEnemy(oldHP, target, user, room){
	if(target != null){
		if(target.hp < 1) {
			if(oldHP > 0){
				if(target.targets.indexOf(user.getUserId()) == -1){
					target.targets.push(user.getUserId());
				}
				sendToAllUsers(["eCU", 0, target.id], room.getId());//enemy combat update
				sendToAllUsers(["eD", target.id], room.getId()); // enemy death
				if(target.targets.length > 0){
					for(var i = 0; i < target.targets.length; i++){
						giveEnemyRewards(target, getUserById(target.targets[i]));
					}
				}
				target.targets = [];
				markEnemyForRespawn(target.id, room, ENEMY_RESPAWN_TIME);
			}
		} else {
			enemyRespond(target, user, room);
		}
	}
}
function giveEnemyRewards(enemy, user){
	var i;
	var id;
	var dropChance;
	//do gold xp drops
	giveXP(enemy.xpDrop, user);
	giveGold(enemy.goldDrop,user);
	
	//do item drops
	var iDrops = enemy.itemDrops.split(',');
	for(i = 0; i < iDrops.length; i++){
		id = Number(iDrops[i].split(":")[0]);
		dropChance = Number(iDrops[i].split(":")[1]) * 100;
		if(roll() <= dropChance){
			giveItem(user, id);
		}
	}
	//do quest drops
	var qDrops = enemy.questDrops.split(',');
	for(i = 0; i < qDrops.length; i++){
		id = Number(qDrops[i].split(":")[0])
		dropChance = Number(qDrops[i].split(":")[1]) * 100;
		if(roll() <= dropChance){
			incrementObjective(id, user);
		}
	}
}
function giveGold(amount, user, informUser){
	amount = amount * goldRate;
	if(informUser == undefined){
		informUser = true;
	}
	var success = saveGold(getGold(user) + amount, user);
	
	if(success && informUser){
		var obj = [];
		obj.push("goRec"); 
		obj.push(amount); 
		_server.sendResponse(obj, -1, null, [user], "str");
	}
}
function giveXP(amount, user, informUser){
	amount = amount * xpRate;
	if(getLevel(user) < MAX_LEVEL){
		if(informUser == undefined){
			informUser = true;
		}
		setXP(getXP(user) + amount, user);
		var xp = getXP(user);
		var xpToLevel = getXPToLevel(getLevel(user));
		if(informUser){
			var obj = [];
			obj.push("xpRec"); 
			obj.push(amount); 
			_server.sendResponse(obj, -1, null, [user], "str");
		}
		
		if(xp >= xpToLevel){
			xp -= xpToLevel;
			setXP(xp, user);
			var newLevel = getLevel(user) + 1;
			if(saveLevel(newLevel, user)){
				user.properties.put("hp", getLevelHP(newLevel));
				user.properties.put("hpmax", getLevelHP(newLevel));
				var obj = [];
				obj.push("lvlUp");
				obj.push(user.getUserId());
				obj.push(getLevelHP(newLevel));
				sendToAllUsers(obj, user.getRoomsConnected()[0]);
				if(newLevel == MAX_LEVEL){
					serverMessageToZone(user.getName() + " has reached level " + MAX_LEVEL + "!");
				}
			}
		}
	}
}
function attackAI(params, taskObject){
	var enemy = params.room.properties.get("enemies")[params.id];
	if(enemy != null){
		if(enemy.inCombat){
			if(enemy.targets.length > 0 && enemy.hp > 0){
				enemyAttack(enemy, params.room.getId());
			} else if(enemy.hp < 1){
				enemy.inCombat = false;
				taskObject.active = false;
			} else {
				if(enemy.hp < enemy.hpMax){
					enemyVictory(enemy, params.room.getId())
				}
				enemy.targets = [];
				enemy.inCombat = false;
				taskObject.active = false;
			}
		} else {
			if(params.room != null && enemy.hp < enemy.hpMax){
				enemyVictory(enemy, params.room.getId())
			}
			taskObject.active = false;
		}
	}
}
function enemyAttack(enemy, roomId){
	if(enemy != null && enemy.targets != null && enemy.targets.length > 0){
		var target = null;
		var targetId = enemy.targets[Math.floor(Math.random()*enemy.targets.length)];
		target = getUserById(targetId);
		if(target != null && !isDead(target) && inSameRoomAndZone(enemy, target, roomId)){
			var dmg = getEnemyDamage(enemy);
			var finalDamage = damageTarget(target, dmg);
			var newTargetHP = getHealth(target);
			var aList = enemy.animList.split(",");
			var animId = aList[Math.floor(Math.random() * aList.length)];
			sendToAllUsers(["eAct", 1, enemy.id, target.getUserId(), finalDamage, animId], roomId);
			
			//action, enemy id, params
			//1, enemy id, target id, damage, animation id
			
			
			if(newTargetHP == 0){
				enemy.targets.splice(enemy.targets.indexOf(targetId), 1);
			}
			
			if(newTargetHP == 0 && enemy.targets.length == 0){
				enemyVictory(enemy, roomId);
			} else if(enemy.targets.length > 0 && newTargetHP == 0){
				enemyAttack(enemy, roomId)
			}
		} else {
			enemy.targets.splice(enemy.targets.indexOf(targetId), 1);
			enemyAttack(enemy, roomId);
		}
	}
}
function enemyVictory(enemy, roomId){
	if(enemy != null){
		enemy.targets = [];
		enemy.inCombat = false;
		sendToAllUsers(["eCU", 0, enemy.id], roomId);//enemy combat update
		sendToAllUsers(["eAct", 2, enemy.id], roomId); // return to spawn
		enemy.hp = enemy.hpMax;
	}
}

function respawnUser(user){
	if(user != null){
		user.properties.put("hp", user.properties.get("hpmax"));
		user.properties.put("deathTime", -1)
		sendToAllUsers(["reU", user.getUserId()], user.getRoomsConnected()[0]);
	}
}

function respawnEnemy(params){
	if(params.room != null){
		var enemy = params.room.properties.get("enemies")[params.id];
		
		if(enemy != null){
			enemy.targets = [];
			var roomId = params.room.getId();
			enemy.hp = enemy.hpMax;
			sendToAllUsers(["reE", enemy.id, enemy.hp], roomId);
		}
	}
}

function markEnemyForRespawn(id, zone, respawnTime){
	var task = newTask({cmd:"respawnEnemy", room:zone, id:id});
	addTask(task, respawnTime, false);
}
function markUserForRespawn(user){
	var timeNow = new Date().getTime();
	user.properties.put("deathTime", timeNow);
	sendToAllUsers(["uD", user.getUserId()], getUserRoomId(user));
	if(user.properties.get("zone") == "duel"){
		var room = getRoomById(getUserRoomId(user));
		var users = room.getAllUsers();
		for(var i = 0; i < users.length; i++){
			if(users[i] != user){
				requestEnterZone(users[i], users[i].properties.get("lastNormalZone"), users[i].properties.get("lastNormalZone"));
			}
		}
	}
}
function isDead(target){
	return getHealth(target) < 1;
}
function inSameRoomAndZone(enemy, user, roomId){
	if(""+enemy.room == ""+user.properties.get("room") && roomId == user.getRoomsConnected()[0]){
		return true;
	}
	return false;
}


function enemyRespond(enemy, user, zone){
	var roomId = zone.getId();
	if(enemy.targets.indexOf(user.getUserId()) == -1){
		enemy.targets.push(user.getUserId());
	}
	if(!enemy.inCombat){
		enemy.inCombat = true;
		sendToAllUsers(["eCU", 1, enemy.id], roomId);//enemy combat update
		var task = newTask({cmd:"attackAI", room:zone, id:enemy.id});
		addTask(task, ENEMY_COOLDOWN_TIME * .001, true);
		enemyAttack(enemy, zone.getId());
	}
}
function getEnemyDamage(enemy){
	return Math.round(randomBetween(enemy.minDamage, enemy.maxDamage));
}
function getPlayerDamage(user){
	var wep = getItemById(user.properties.get("wepId"));
	var minDamage = Number(wep.damage.split("-")[0]);
	var maxDamage = Number(wep.damage.split("-")[1]);
	return Math.round(randomBetween(minDamage, maxDamage));
}
function damageTarget(target, dmg, user){
	dmg = Math.round(dmg);
	if(target != null && dmg != null && getHealth(target) > 0){
		if(!isUser(target)){ //if target is an enemy and not a user
			var oldHP = target.hp;
			if((target.hp - dmg) < 1){
				target.hp = 0;
			} else {
				target.hp -= dmg;
			}
			if(user != null){
				damagedEnemy(oldHP, target, user, getRoomById(user.getRoomsConnected()[0]));
			}
			return dmg;
		} else {
			var hp = Number(target.properties.get("hp"));
			dmg = Math.round(modMeleeDamageByDefence(target, dmg));
			if((hp - dmg) < 1){
				if(hp > 0){
					markUserForRespawn(target);
				}
				hp = 0;
			} else {
				hp -= dmg;
			}
			var newHP = Math.round(hp);
			target.properties.put("hp", newHP);
			setState(STATE.idle, target);
			return dmg;
		}
	}
	return 0;
}
function modMeleeDamageByDefence(target, dmg){
	if(isUser(target)){
		var meleeDefense = getMeleeDefense(target);
		dmg = dmg * meleeDefense;
	}
	return dmg;
}
function healTarget(target, healAmount){
	healAmount = Math.round(healAmount);
	if(target != null && healAmount != null && getHealth(target) > 0){
		if(!isUser(target)){ //if target is an enemy and not a user
			if((target.hp + healAmount) > target.hpMax){
				target.hp = target.hpMax;
			} else {
				target.hp += healAmount;
			}
			return healAmount;
		} else {
			var hp = Number(target.properties.get("hp"));
			if((hp + healAmount) > Number(target.properties.get("hpmax"))){
				hp = Number(target.properties.get("hpmax"));
			} else {
				hp += healAmount;
			}
			target.properties.put("hp", Math.round(hp));
			return healAmount;
		}
	}
	return 0;
}


function fullHeal(user){
	setHealth(getMaxHealth(user), user);
}


function getAbilityById(id){
	if(cachedAbilities[id] == null){
		var ability = query("SELECT * FROM abilities WHERE id="+id+"");
		if(ability[0] != null){
			cachedAbilities[""+id] = ability[0];
			return ability[0];
		}
	}
	return cachedAbilities[id];
}

function getAuraById(id){
	if(cachedAuras[id] == null){
		var aura = query("SELECT * FROM auras WHERE id="+id+"");
		if(aura[0] != null){
			cachedAuras[""+id] = aura[0];
			return cachedAuras[id];
		}
	}
	return cachedAuras[id];
}

function getClassById(id){
	if(cachedClasses[""+id] == null){
		var c = query("SELECT * FROM classes WHERE id="+id+"");
		if(c[0] != null){
			cachedClasses[""+id] = c[0];
			
			return cachedClasses[id];
		}
	}
	return cachedClasses[""+id];
}

function parseClass(id){
	if(cachedClasses[id] == null){
		var c = getClassById(id);
		if(c != null){
			var abilities = c.abilities.split(",");
			cachedClasses[id].abilities = abilities;
			for(var i = 0; i < abilities.length; i++){
				getAbilityById(Number(abilities[i]));
			}
		} else {
			trace("Critical Error: Class not registered!");
		}
	}
}

function getClassAbilityInfo(id){
	var c = getClassById(id);
	var a = [];
	if(c != null){
		for(var i = 0; i < c.abilities.length; i++){
			var ability = getAbilityById(Number(c.abilities[i]));
			var obj = {};
			obj.name = ability.name;
			obj.desc = ability.desc;
			obj.icon = ability.icon;
			obj.rpType = ability.rpType;
			obj.rpCost = ability.rpCost;
			obj.cd = ability.cd;
			obj.minTgt = ability.minTgt;
			obj.maxTgt = ability.maxTgt;
			obj.range = ability.range;
			obj.friendly = ability.isFriendly;
			obj.lvlreq = ability.lvlReq;
			
			a.push(obj);
			
		}
		return a;
	} else {
		trace("Critical Error: Class not registered!");
	}
	return [];
}

function applyAura(caster, target, id, room, dmg){
	if(target != null && id != null){
		var aura = getAuraById(id);
		if(aura != null){
			if(aura.seconds < 1){
				aura.seconds = 1;
			}
			if(aura.ticks < 1){
				aura.ticks = 1;
			}
			if(Number(aura.type) == 0){
				switch(Number(aura.subType)){
					case 1:
					setMeleeDefense(target, getMeleeDefense(target) - Number(aura.amount));
					break;
				}
			}
			var auraTick = Number(aura.seconds) / Number(aura.ticks)
			var task = newTask({cmd:"auraTick", id:id, target:target, caster:caster, dmg:dmg, room:room, ticks:0});
			addTask(task, auraTick, true);
			
		} else {
			trace("Critical Error: Aura '"+id+"' does not exist");
		}
	}
}
function auraTick(params, taskObject){
	var aura = getAuraById(params.id);
	var target = params.target;
	var caster = params.caster;
	if(!isUser(target) && target.targets.length < 1){
		taskObject.active = false;
		return;
	}
	if(aura != null && target != null && getHealth(target) > 0){
		var amount = Number(aura.amount);
		if(Number(aura.type) != 0 && getHealth(target) > 0){
			var dmg = Number(params.dmg);
			var room = params.room;
			var newAmount;
			var bIsUser = 0;
			var id;
			var finalAmount;
			
			if(!isUser(target)){ //if target is an enemy and not a user
				id = target.id;
			} else {
				id = target.getUserId();
				bIsUser = 1;
			}
			switch(Number(aura.type)){
				case 0://element buff
				break;
				case 1://HoT
					newAmount = dmg * amount;
					if(newAmount > .99){
						finalAmount = healTarget(target, newAmount);
						sendToAllUsers(["hl", id, bIsUser, finalAmount], room.getId());
						//target id, is player, amount
					}
				break;
				case 2://DoT
					newAmount = dmg * amount;
					if(newAmount > .99){
						finalAmount = damageTarget(target, newAmount, caster);
						sendToAllUsers(["dmg", id, bIsUser, finalAmount], room.getId());
						//target id, is player, amount
					}
				break;
			}
		} else {//is temporary stat buff
			switch(Number(aura.subType)){
				case 1:
					setMeleeDefense(target, getMeleeDefense(target) + amount);
				break;
			}
		}
		params.ticks ++;
		if(Number(params.ticks) == Number(aura.ticks)){
			taskObject.active = false;
		}
	} else {
		taskObject.active = false;
	}
	
}


function getMeleeDefense(target){
	return Number(target.properties.get("melee_defense"));
}
function setMeleeDefense(target, val){
	target.properties.put("melee_defense", Number(val));
}


function restLoop(){
	var users = getAllUsersInZone();
	for(var i = 0; i < users.length; i++){
		var user = users[i];
		if(user.properties.get("zone") != "duel" && getHealth(user) < getMaxHealth(user) && getState(user) == STATE.rest){
			var room = getRoomById(user.getRoomsConnected()[0]);
			if(user != null && room != null){
				var newAmount = getMaxHealth(user) * .20;
				var finalAmount = healTarget(user, newAmount);
				sendToAllUsers(["hl", user.getUserId(), 1, finalAmount], room.getId());
			}
		}
	}
}