

function serverMessageToZone(msg){
	var obj = [];
	obj.push("admBC");
	obj.push("SERVER");
	obj.push(6);
	obj.push(msg);
	sendToZone(obj);
}



function changeUserAccess(access, user){
	if(user != null && isFinite(access)){
		var charId = getCharId(user);
		if(charId != null){
			access = Number(access);
			user.properties.put("access", access);
			var setQuery = "access = '"+access+"'";
			sql = "UPDATE characters SET "+setQuery+" WHERE id="+charId+"";
			database.executeCommand(sql)
		}
	}
}




function randomBetween(min,max){
    return Math.floor(Math.random()*(max-min+1)+min);
}


function roll(){
    return randomBetween(0,100);
}

// -------- SERVER -------------------
function alertUser(msg, user){
	var obj = [];
	obj.push("admBC");
	obj.push("SERVER");
	obj.push(6);
	obj.push(msg);
	_server.sendResponse(obj, -1, null, [user], "str");
}


function kickAndInform(user, time, msgToUser, msgToAdmin){
	_server.kickUser(user, time, msgToUser)
	var uId = getCharId(user);
	var sql = "INSERT INTO log_admin_inform (content) VALUES ('Kicked user with id " + uId+ " from server with reason: "+_server.escapeQuotes(msgToAdmin)+"')"
	return database.executeCommand(sql)
}

function sendToAllUsers(obj, roomId, format){
	var room = zone.getRoom(roomId);
	if(format == null || format == undefined){
		format = "str";
	}
	if(room != null){
		var users = room.getAllUsers();
		_server.sendResponse(obj, -1, null, users, format);
	}
}

function sendToZone(obj, roomId){
	var users = getAllUsersInZone();
	_server.sendResponse(obj, -1, null, users, "str");
}


function sendToAllUsersButOne(obj, roomId, userToIgnore){
	var users = [];
	if(zone.getRoom(roomId) != null){
		var room = zone.getRoom(roomId);
		if(room != null){
			users = room.getAllUsers();
			var users2 = [];
			for(i = 0; i < users.length; i++){
				if(users[i].getUserId() != userToIgnore.getUserId()){
					users2.push(users[i]);
				}
			}
			_server.sendResponse(obj, -1, null, users2, "str");
		}
	}
}
function sendToAllUsersButOneJSON(obj, roomId, userToIgnore){
	var users = [];
	if(zone.getRoom(roomId) != null){
		var room = zone.getRoom(roomId);
		if(room != null){
			users = room.getAllUsers();
			var users2 = [];
			for(i = 0; i < users.length; i++){
				if(users[i].getUserId() != userToIgnore.getUserId()){
					users2.push(users[i]);
				}
			}
			_server.sendResponse(obj, -1, null, users2, "json");
		}
	}
}

function getRoomById(id){
	return zone.getRoom(id);
}

function getUserById(id){
	return _server.getUserById(id)
}

function getAllUsersInZone(){
   var listOfChannels = zone.getAllUsersInZone()
   var allUsers = []
   var socketChan = null
   
   for (var i = 0; i < listOfChannels.size(); i++)
   {
      socketChan = listOfChannels.get(i)
      allUsers.push( _server.getUserByChannel( socketChan ) )
   }
   
   return allUsers;
}

function print(msg){
	__out.println(msg);
}
function log(msg){
	_server.writeFile("DEBUG/_log.txt", msg, true);
}



function logChat(msg, user){
	//var uId = getCharId(user);
	//var sql = "INSERT INTO log_chat (uId, content) VALUES ('"+uId+"','"+_server.escapeQuotes(msg)+"')"
	//return database.executeCommand(sql)
}

function addTask(a,b,c){
	scheduler.addScheduledTask(a, b, c, taskHandler)
}
function newTask(a){
	return new _scheduler.Task(a);
}

// -------- DATABASE -------------------
function cacheDB(){
	var classes = query("SELECT * FROM classes");
	for(var i = 0; i < classes.length; i ++){
		cachedClasses[""+classes[i].id] = classes[i];
	}
	var abilities = query("SELECT * FROM abilities");
	for(var i = 0; i < abilities.length; i ++){
		cachedAbilities[""+abilities[i].abilityId] = abilities[i];
	}
	var auras = query("SELECT * FROM auras");
	for(var i = 0; i < auras.length; i ++){
		cachedAuras[""+auras[i].auraId] = auras[i];
	}
}


function query(sql){
	var queryRes = database.executeQuery(sql);
	var list = [];
	if (queryRes == null){
		return 0;
	}
	
	for(var i=0; i <queryRes.size(); i++){
		var tempRow = queryRes.get(i);
		var asObj = getASObj(tempRow);
		list.push(asObj);
	}
	return list;
}

function getASObj(row){
	var map = row.getDataAsMap();
	var mapKeys = map.keySet();
	var mapKeysArray = mapKeys.toArray();
	var asObj = new Object();
	for(var i = 0; i < mapKeysArray.length; i++){
		var d = map.get(mapKeysArray[i]);
		asObj[mapKeysArray[i]] = "" + d;
	}
	return asObj;
}
function validateSQL(str){
	return _server.escapeQuotes(str);
}

function roll(){
	return Math.floor((Math.random() * 100) + 1);;
}

function dumpObject(o) {
	trace('\n');
	for (var val in o) {
		trace('   [' + typeof(o[val]) + '] ' + val + ' => ' + o[val]);
	}
	trace('\n');
}

