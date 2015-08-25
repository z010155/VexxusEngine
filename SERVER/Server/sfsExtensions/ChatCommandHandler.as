function handleChatCommand(cmd, param, user, roomId){
	switch(cmd.toLowerCase()){
		
		case 'template':
			if(getAccess(user) >= MOD){
				
			}
		break;
		
		case "sendquest":
			if(getAccess(user) >= MOD){
				var id = param.split(" ")[0];
				var userN = param.split(" ")[1];
				var targetU = zone.getUserByName(userN.toLowerCase())
				if(targetU == null){
					targetU = user;
				}
				sendQuestData(Number(id), targetU, true);
				var obj = [];
				obj.push("admBC");
				obj.push("SERVER");
				obj.push(6);
				obj.push("You were sent a quest by "+user.getName()+"!");
				_server.sendResponse(obj, -1, null, [targetU], "str");
			}
		break;
		
		case "sendquestlist":
			if(getAccess(user) >= MOD){
				var id = param.split(" ")[0];
				var userN = param.split(" ")[1];
				var targetU;
				if(targetU == null){
					targetU = user;
				} else {
					targetU = zone.getUserByName(userN.toLowerCase());
				}
				sendQuestList(Number(id), targetU);
				var obj = [];
				obj.push("admBC");
				obj.push("SERVER");
				obj.push(6);
				obj.push("You were sent a quest by "+user.getName()+"!");
				_server.sendResponse(obj, -1, null, [targetU], "str");
			}
		break;
		
		case 'recache':
			if(getAccess(user) >= STAFF){
				param = param.toLowerCase();
				var key;
				var list = [];
				var i;
				if(param == "items"){
					for (key in cachedItems) {
						list.push(key);
					}
					
					cachedItems = {};
					for(i = 0; i < list.length; i++){
						getItemById(list[i]);
					}
				} else if(param == "shops"){
					for (key in cachedShops) {
						list.push(key);
					}
					cachedShops = {};
					for(i = 0; i < list.length; i++){
						getShopById(list[i]);
					}
				} else if(param == "enemies"){
					for (key in cachedEnemies) {
						list.push(key);
					}
					
					cachedEnemies = {};
					for(i = 0; i < list.length; i++){
						getEnemyById(list[i]);
					}
				} else if(param == "zones" || param == "maps"){
					for (key in cachedZones) {
						list.push(key);
					}
					
					cachedZones = {};
					for(i = 0; i < list.length; i++){
						getZoneByName(list[i]);
					}
				} else if(param == "quests"){
					//cachedQuests = {};
					//cachedQuestList = {};
					for (key in cachedQuests) {
						list.push(key);
					}
					
					cachedQuests = {};
					for(i = 0; i < list.length; i++){
						getQuestById(list[i]);
					}
				} else if(param == "questlists"){
					for (key in cachedQuestList) {
						list.push(key);
					}
					
					cachedQuestList = {};
					for(i = 0; i < list.length; i++){
						getQuestListById(list[i]);
					}
				}
			}
		break;
		
		case 'spawn':
			if(getAccess(user) >= ADMIN){
				var roomLabel = user.properties.get("room");
				if(isFinite(param)){
					spawnEnemy(Number(param), user.properties.get("x")+","+user.properties.get("y"), roomLabel, getRoomById(roomId))
				} else {
					var id = Number(param.split(" ")[0])
					var coords = param.split(" ")[1];
					spawnEnemy(id, coords, roomLabel, getRoomById(roomId))
				}
			}
		break;
		
		case 'murder':
		case 'kill':
			if(getAccess(user) >= STAFF){
				if(!isFinite(param)){
					var name = param.split(" ")[0].toLowerCase();
					var amount = Number(param.split(" ")[1]);
					var targetU = zone.getUserByName(name)
					if(targetU != null){
						setHealth(0, targetU);
						markUserForRespawn(targetU);
					}
				} else {
					var room = getRoomById(roomId);
					var enemy = room.properties.get("enemies")[""+param];
					if(enemy != null){
						sendToAllUsers(["dmg", Number(param), 0, damageTarget(enemy, enemy.hp, user)], roomId);
					}
				}
			}
		break;
		
		case 'dmg':
			if(getAccess(user) >= MOD){
				if(isFinite(param)){
					sendToAllUsers(["dmg", user.getUserId(), 1, damageTarget(user, Number(param))], roomId);
				} else {
					
					var name = param.split(" ")[0].toLowerCase();
					var amount = Number(param.split(" ")[1]);
					var targetU = zone.getUserByName(name)
					if(targetU != null){
						sendToAllUsers(["dmg", targetU.getUserId(), 1, damageTarget(targetU, Number(param))], roomId);
					}
				}
				
			}
		break;
		
		
		case 'heal':
			if(getAccess(user) >= MOD){
				if(isFinite(param)){
					sendToAllUsers(["hl", user.getUserId(), 1, healTarget(user, Number(param))], roomId);
				} else {
					
					var name = param.split(" ")[0].toLowerCase();
					var amount = Number(param.split(" ")[1]);
					var targetU = zone.getUserByName(name)
					if(targetU != null){
						sendToAllUsers(["hl", targetU.getUserId(), 1, healTarget(targetU, Number(param))], roomId);
					}
				}
				
			}
		break;
		
		case 'tei':
		case 'gei':
		case 'traceenemyinfo':
			if(getAccess(user) >= STAFF){
				var enemies = getRoomById(roomId).properties.get("enemies");
				for(var i = 0; i < enemies.length; i++){
					dumpObject(enemies[i]);
				}
			}
		break;
		
		case "kick":
			if(getAccess(user) >= PERMISSIONS.Kick){
				var uToKick = zone.getUserByName(param.toLowerCase())
				if(uToKick != null){
					_server.kickUser(uToKick, 0, "KICKED");
				} 
			}
		break;
		
		
		
		case "kickall":
			if(getAccess(user) >= STAFF){
				var users = getAllUsersInZone();
				for(var i = 0; i < users.length; i++){
					_server.kickUser(users[i], 0, "");
				}
			}
		break;
		
		
		case "broadcast":
			if(getAccess(user) >= PERMISSIONS.Broadcast){
				if(param != "" && param != undefined){
					var obj = [];
					obj.push("admBC");
					obj.push(user.getName());
					obj.push(6);
					obj.push(param);
					sendToZone(obj);
				}
			} 
		break;
		
		case "give":
			if(getAccess(user) >= MOD){
				if(param != "" && param != undefined){
					if(isFinite(param)){
						giveItem(user, Number(param));
					} else {
						var name = param.split(" ")[0].toLowerCase();
						var id = Number(param.split(" ")[1]);
						
						var targetU = zone.getUserByName(name)
						if(targetU != null){
							giveItem(targetU, id);
							var obj = [];
							obj.push("admBC");
							obj.push("SERVER");
							obj.push(6);
							obj.push("You were given an item by "+user.getName()+".");
							_server.sendResponse(obj, -1, null, [targetU], "str");
						}
					}
				}
			}
		break;
		
		case "ban":
			if(getAccess(user) >= PERMISSIONS.Ban){
				var uToKick = zone.getUserByName(param.toLowerCase())
				if(uToKick != null){
					changeUserAccess(0, uToKick);
					_server.kickUser(uToKick, 0, "KICKED");
				}
			}
		break;
		
		case "givexp":
		case "xp":
			if(getAccess(user) >= PERMISSIONS.Give){
				if(isFinite(param)){
					giveXP(Number(param), user);
				} else {
					var name = param.split(" ")[0].toLowerCase();
					var amount = Number(param.split(" ")[1]);
					var targetU = zone.getUserByName(name)
					if(targetU != null){
						giveXP(amount, targetU);
					}
				}
				
			}
		break;
		case 'gold':
		case "givegold":
			if(getAccess(user) >= PERMISSIONS.Give){
				if(isFinite(param)){
					giveGold(Number(param), user);
				} else {
					var name = param.split(" ")[0].toLowerCase();
					var amount = Number(param.split(" ")[1]);
					var targetU = zone.getUserByName(name)
					if(targetU != null){
						giveGold(amount, targetU);
					}
				}
				
			}
		break;
		
		
		case "mute":
			if(getAccess(user) >= PERMISSIONS.Mute){
				var targetUser = zone.getUserByName(param.toLowerCase())
				if(targetUser != null){
					targetUser.properties.put("mute", true);
					var obj = [];
					obj.push("admBC");
					obj.push("SERVER");
					obj.push(6);
					obj.push("You have been muted by "+user.getName()+"!");
					_server.sendResponse(obj, -1, null, [targetUser], "str");
					}
			}
		break;
		case "unmute":
			if(getAccess(user) >= PERMISSIONS.Mute){
				var targetUser = zone.getUserByName(param.toLowerCase())
				if(targetUser != null){
					targetUser.properties.put("mute", false);
					var obj = [];
					obj.push("admBC");
					obj.push("SERVER");
					obj.push(6);
					obj.push("You have been unmuted by "+user.getName()+"!");
					_server.sendResponse(obj, -1, null, [targetUser], "str");
				}
			}
		break;
		
		case 'shop':
		case 'loadshop':
			if(getAccess(user) >= MOD){
				loadShop(user, Number(param));
			}
		break;
		
		// ---------------------- QUEST COMMANDS -------------------------
		case 'savequest':
			if(getAccess(user) >= STAFF){
				saveQuestCompletion(Number(param), user);
			}
		break;
		case 'hascq':
			if(getAccess(user) >= STAFF){
				alertUser(hasCompletedQuest(Number(param), user), user);
			}
		break;
		
		case 'upq':
			if(getAccess(user) >= STAFF){
				incrementObjective(Number(param), user)
			}
		break;
		case 'adq':
			if(getAccess(user) >= STAFF){
				addObjective(Number(param), user)
			}
		break;
		case 'remobj':
			if(getAccess(user) >= STAFF){
				removeObjective(Number(param), user)
			}
		break;
		case 'getobj':
			if(getAccess(user) >= STAFF){
				alertUser(user.properties.get("questObj"), user);
			}
		break;
		case 'getaq': //active quests
			if(getAccess(user) >= STAFF){
				alertUser(user.properties.get("activeQuests"), user);
			}
		break;
		
		
		// ---------------------- ---------------------- -------------------------
		
		case 'join':
			if(getAccess(user) >= MOD){
				if(param.indexOf("-") == -1){
					requestEnterZone(user, param);
				} else {
					requestEnterZone(user, param.split("-")[0], null, Number(param.split("-")[1]));
				}
			}
		break;
	}
}