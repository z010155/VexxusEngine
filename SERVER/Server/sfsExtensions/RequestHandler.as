function handleRequest(cmd, params, user, roomId){
	var lastPacketTime = user.properties.get("lastPacketTime");
	var packetCount = Number(user.properties.get("packetCount"));
	var timeNow = new Date().getTime();
	if(lastPacketTime != null){
		if(((timeNow - lastPacketTime) < 500)){
			user.properties.put("packetCount", packetCount + 1);
		} else {
			user.properties.put("packetCount", 1);
			user.properties.put("lastPacketTime", timeNow);
		}
	} else {
		user.properties.put("lastPacketTime", timeNow);
	}
	if(packetCount > 30){
		kickAndInform(user, .5, "spam", "User sent " +packetCount+ " packets in under half a second.");
		return;
	}
	switch(cmd){
		case 'cCmd':
			handleChatCommand(""+params[0], ""+params[1], user, roomId);
		break;
		case "chat":
			if(isDead(user)){return;}
			if(params[0] != "" && params[0] != undefined){
				if(getAccess(user) < MOD){
					params[0] = params[0].replace("<", "&#60;");
					params[0] = params[0].replace(">", "&#62;");
					params[0] = params[0].replace('\\', "&#92;");
					params[0] = params[0].replace('%', "&#37;");
				}
				if(user.properties.get("mute") == null || user.properties.get("mute") == false){
					var obj = [];
					obj.push("msg");
					obj.push(user.getName());
					obj.push(getAccess(user));
					obj.push(params[0]);
					logChat(params[0], user);
					sendToAllUsers(obj, roomId);
				} else {
					var obj = [];
					obj.push("admBC");
					obj.push("SERVER");
					obj.push(6);
					obj.push("You are muted!");
					_server.sendResponse(obj, -1, null, [user], "str");
				}
			}
		break;
		
		
		
		case "pm":
			if(params[0] != "" && params[0] != undefined && params[1] != "" && params[1] != null){
				var targetU = zone.getUserByName(params[0].toLowerCase())
				if(targetU != null){
					var obj = [];
					obj.push("pm");
					obj.push(user.getName());
					obj.push(params[1]);
					_server.sendResponse(obj, -1, null, [targetU], "str");
				}
			}
		break;
		
		
		case "emo":
			if(isDead(user)){return;}
			var obj = [];
			obj.push("emo");
			obj.push(user.getUserId());
			obj.push(params[0]);
			sendToAllUsers(obj, roomId);
			setState(STATE.idle, user)
		break;
		
		case "rest":
			if(isDead(user)){return;}
			var room = getRoomById(roomId);
			var enemies = room.properties.get("enemies");
			for (var key in enemies) {
				if(enemies[key].targets.indexOf(user.getUserId()) != -1){
					return;
				}
			}
			setState(STATE.rest, user)
		break;
		
		case "reSp":
			if(getHealth(user) < 1){
				var deathTime = user.properties.get("deathTime");
				if(deathTime != null && deathTime != -1) {
					var timeNow = new Date().getTime();
					if(((timeNow - deathTime) > (RESPAWN_TIMER)*1000)) {
						respawnUser(user);
						if(user.properties.get("zone") == "duel"){
							requestEnterZone(user, user.properties.get("lastNormalZone"), user.properties.get("lastNormalRoom"));
						}
					}
				}
			}
		break;
		
		case "enterZone":
			if(isDead(user)){return;}
			var newName = params.name.toLowerCase();
			if(newName != "default"){
				if(params.room != null && params.room.length > 0){
					requestEnterZone(user, newName, params.room);
				} else {
					requestEnterZone(user, newName);
				}
			} else {
				if(String(user.properties.get("lZone")).length > 1){
					requestEnterZone(user, user.properties.get("lZone"), user.properties.get("lRoom"));
				} else {
					requestEnterZone(user, GLOBALS.DEFAULT_MAP);
				}
			}
			setState(STATE.idle, user);
			cancelDuelRequest(user);
		break;
		
		case "initZone":
			if(isDead(user)){return;}
			user.properties.put("x", params.x);
			user.properties.put("y", params.y);
			user.properties.put("room", params.room);
			user.properties.put("dir", params.dir);
			
			var nextZone = user.properties.get("nextZone")
			var nextZoneId = user.properties.get("nextZoneId")
			
			if(nextZone != null && nextZone != ""){
				//trace(user.getName() + " is joining " + nextZone);
				if(nextZoneId == null || nextZoneId == -1){
					joinZone(user, nextZone);
				} else {
					joinZone(user, nextZone, nextZoneId);
				}
			}
			setState(STATE.idle, user)
		break; 
		
		case "loadShop":
			if(isDead(user)){return;}
			if(params[0] != undefined && params[0] != null && isFinite(params[0])){
				loadShop(user, params[0]);
			}
		break;
		
		case "buyItem":
			if(isDead(user)){return;}
			if(params[0] != undefined && params[0] != null && isFinite(params[0])){
				buyItem(user, params[0]);
			}
		break;
		case "sellItem":
			if(isDead(user)){return;}
			if(params[0] != undefined && params[0] != null && isFinite(params[0])){
				sellItem(user, params[0]);
			}
		break; 
		
		case "useItem":
			if(isDead(user)){return;}
			if(params[0] != undefined && params[0] != null && isFinite(params[0])){
				useItem(Number(params[0]), user, roomId);
			}
		break; 
		
		case "getInvent":
			if(isDead(user)){return;}
			sendInventory(user);
		break;
		
		case "prIt": //get Item Preview
			if(params[0] != undefined && params[0] != null && isFinite(params[0])){
				var item = getItemById(Number(params[0]));
				if(item.type == "1,0" || item.type == "1,1"){
					var file = getItemFileById(Number(params[0]));
					var obj = ["itPr",file,item.type];
					
					
					_server.sendResponse(obj, -1, null, [user], "str");
				}
			}
		break;
		
		case "strResponse":
			/*var obj = [];
			obj.push("0"); 
			obj.push("1"); 
			_server.sendResponse(obj, -1, null, [user], "str");
*/		break;
		
		case "jsonResponse":
			/*var obj = {};
			obj.cmd = "1";
			obj.val1 = "2!";
			_server.sendResponse(obj, -1, null, [user], "json");
*/		break;
		
		case "tele":
			if(isDead(user)){return;}
			if(Number(getAccess(user)) >= MOD){
				setState(STATE.idle, user)
				var targetU;
				if(params[2] == "" || params[2] == null || params[2].length > 2){
					targetU = user;
				} else {
					var tU = zone.getUserByName(params[2].toLowerCase())
					if(tU != null){
						trace("Tele target: " + params[2]);
						targetU = tU;
						var obj = [];
						obj.push("admBC");
						obj.push("SERVER");
						obj.push(6);
						obj.push("You were teleported by "+user.getName()+"!");
						_server.sendResponse(obj, -1, null, [targetU], "str");
					} else {
						return;
					}
				}
				targetU.properties.put("x", params[0]);
				targetU.properties.put("y", params[1]);				
				
				var obj = [];
				obj.push("tele");
				obj.push(targetU.getUserId());
				obj.push(params[0]);
				obj.push(params[1]);
				
				sendToAllUsers(obj, roomId);
			} else {
				kickAndInform(user, .5, "natdt", "User tried to teleport but was not legit enough");
			}
		break;
		
		case "setPos":
			//x, y, direction, room
			if(isDead(user)){return;}
			user.properties.put("x", params[0]);
			user.properties.put("y", params[1]);
			if(params[2]){
				user.properties.put("dir", params[2]);
			}
			if(params[3]){
				user.properties.put("room", params[3]);
			}
			var obj = [];
			obj.push("pos");
			obj.push(user.getUserId());
			obj.push(params[0]);
			obj.push(params[1]);
			if(params[2]){
				obj.push(params[2]);
			} else {
				obj.push(2);
			}
			if(params[3]){
				obj.push(params[3]);
			}
			setState(STATE.idle, user);
			//sendToAllUsersButOne(obj, roomId, user);
			sendToAllUsers(obj, roomId, "str");
		break;
		
		case "stopMove":
			//x, y, direction
			if(isDead(user)){return;}
			user.properties.put("x", params[0]);
			user.properties.put("y", params[1]);
			if(params[2]){
				user.properties.put("dir", params[2]);
			}
			var obj = [];
			obj.push("stopMove");
			obj.push(user.getUserId());
			obj.push(params[0]);
			obj.push(params[1]);
			if(params[2]){
				obj.push(params[2]);
			} else {
				obj.push(2);
			}
			setState(STATE.idle, user)
			sendToAllUsersButOne(obj, roomId, user);
		break;
		
		case 'stQ':
			startQuest(Number(params[0]), user)
		break;
		
		case 'compQ':
			completeQuest(Number(params[0]), user);
		break;

		case 'quitQ':
			quitQuest(Number(params[0]), user);
		break;

		
		case "getQL": //quest list
			if(params[0] != "" && params[0] != undefined && isFinite(params[0])){
				sendQuestList(params[0], user);
			}
		break;
		case "getQD": //quest data
			if(params[0] != "" && params[0] != undefined && isFinite(params[0])){
				sendQuestData(params[0], user);
			}
		break;
		
		
		
		case "sQ": //start quest
			if(params[0] != "" && params[0] != undefined && isFinite(params[0])){
				startQuest(Number(params[0]), user);
			}
		break;
		
		/* --------- HANDLE SPELLS -------- */
		case "a1":
			abilityUseRequest(params, user, 1);
		break;
		case "a2":
			abilityUseRequest(params, user, 2);
		break;
		case "a3":
			abilityUseRequest(params, user, 3)
		break;
		case "a4":
			abilityUseRequest(params, user, 4);
		break;
		case "a5":
			abilityUseRequest(params, user, 5);
		break;
		/* -------------------------------- */
		
		case 'dlRq': //duel request
			if(isDead(user)){return;}
			cancelDuelRequest(user);
			
			if(params[0] != "" && params[0] != undefined && isFinite(params[0])){
				var target = getUserById(Number(params[0]));
				if(target == null || target == user){return;}
				if(getUserRoomId(target) != getUserRoomId(user)){
					trace(target.properties.get("zone") + " != " + user.properties.get("zone"));
					return;
				}
				//if target in duel: return;
				//if target already has duel request: return;
				user.properties.put("duelTarget", Number(params[0]));
				user.properties.put("duelTime", timeNow);
				_server.sendResponse(["dlRq", user.getUserId()], -1, null, [target], "str");
			}
		break;
		
		case 'dlAc': //duel accept
			if(isDead(user)){return;}
			if(params[0] != "" && params[0] != undefined && isFinite(params[0])){
				var dueler = getUserById(Number(params[0]));
				if(dueler == null){return;}
				if(dueler.properties.get("duelTarget") == user.getUserId()){
					var requestTime = dueler.properties.get("duelTime");
					if(requestTime != null && requestTime != -1){
						if(((timeNow - requestTime) < 32000)){
							fullHeal(user);
							fullHeal(dueler);
							dueler.properties.put("duelTarget", -1);
							dueler.properties.put("duelTime", -1);
							
							dueler.properties.put("lastNormalRoom", dueler.properties.get("room"));
							user.properties.put("lastNormalRoom", dueler.properties.get("room"));
							
							requestEnterZone(user, "duel", null, dueler.getUserId() + user.getUserId());
							requestEnterZone(dueler, "duel", null, dueler.getUserId() + user.getUserId());
						}
					}
				}
			}
		break;
		
		case 'dlDc': //duel decline
			if(params[0] != undefined && isFinite(params[0])){
				var alreadyDueling = 0;
				if(params[1] != null){
					alreadyDueling = 1;
				}
				var dueler = getUserById(Number(params[0]));
				if(dueler != null && dueler.properties.get("duelTarget") == user.getUserId()){
					dueler.properties.put("duelTarget", -1);
					dueler.properties.put("duelTime", -1);
					_server.sendResponse(["dlDc", alreadyDueling], -1, null, [dueler], "str");
				}
			}
		break;
		
		default:
		print("Unkown command: " + cmd);
		break;
	}
};