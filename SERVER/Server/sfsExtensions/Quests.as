var cachedQuests = {};
var cachedQuestList = {};

function sendQuestList(id, user){
	if(user != null){
		if(!isFinite(id)){
			return;
		}
		var list = getQuestListById(Number(id))
		if(list == null || Number(list.active) != 1 || getAccess(user) < Number(list.access)){
			return;
		}
		var quests = String(list.quests).split(",");
		var questList = [];
		var parsedQuest;
		var quest;
		for(var i = 0; i < quests.length; i++){
			if(isFinite(quests[i])){
				quest = getQuestById(Number(quests[i]));
				if(quest != null && questAvailableToUser(quest, user)){
					parsedQuest = [quest.id, quest.name];
					questList.push(parsedQuest);
				}
			}
		}
		var obj = {};
		obj.cmd = "qList";
		obj.id = ""+id;
		obj.quests = questList;
		_server.sendResponse(obj, -1, null, [user], "json");
		user.properties.put("legalQuestIds", String(list.quests));
		user.properties.put("curQuestListId", Number(id));
	}
}


function sendQuestData(id, user, serverOverride){
	if(serverOverride == null){
		serverOverride = false;
	}
	if(user != null){
		if(hasLegalQuestId(id, user) || serverOverride == true){
			var questList = [];
			var quest = getQuestById(Number(id));
			
			if(quest != null && questAvailableToUser(quest, user)){
				var parsedQuest = parseQuest(quest);
				if(parsedQuest != null){
					var obj = {};
					obj.cmd = "qData";
					obj.data = parsedQuest;
					_server.sendResponse(obj, -1, null, [user], "json");
				}
			}
		} else {
			kickAndInform(user, .5, "IBQD", "Illegal Quest Data Request");
		}
	}
}


function startQuest(id, user){
	if(isFinite(id) && hasLegalQuestId(id, user)){
		var res = [];
		res.push("stQR");
		res.push(id);
		
		
		id = Number(id);
		var quest = getQuestById(id);
		if(quest != null && !hasActiveQuest(id, user) && questAvailableToUser(quest, user)){
			var objectives = String(quest.objectives).split(",");
			for(var i = 0; i < objectives.length; i++){
				var obj = objectives[i].split(":");
				addObjective(obj[0], user);
			}
			addActiveQuest(id, user);
			res.push(1) //was successful, add quest to quest log
		}
		_server.sendResponse(res, -1, null, [user], "str"); //send response
	}
	//do not send response if quest id was not legal, as it was most likely a hacking attempt and
	//there's no need to waste bandwith on a hacker :)
}

function completeQuest(id, user){
	if(isFinite(id)){
		id = Number(id);
		var quest = getQuestById(id);
		if(quest != null && hasActiveQuest(id, user)){
			var objectives = String(quest.objectives).split(",");
			var i;
			for(i = 0; i < objectives.length; i++){
				var obj = objectives[i].split(":");
				var reqAmount = Number(obj[1]);
				if(getObjective(obj[0], user) < reqAmount){
					trace("Quest requirements not met!")
					return;
				}
			}
			for(i = 0; i < objectives.length; i++){
				var obj = objectives[i].split(":");
				removeObjective(obj[i], user);
			}
			removeActiveQuest(id, user);
			//give rewards and stuff here
			var rewards = quest.rewards.split(",");
			for(i = 0; i < rewards.length; i++){
				var reward = rewards[i].split(":");
				if(reward[0] == "g"){
					giveGold(Number(reward[1]), user);
				} else if(reward[0] == "xp"){
					giveXP(Number(reward[1]), user);
				} else if(reward[0] == "i"){
					giveItem(user, Number(reward[1]));
				}
			}
			//
			saveQuestCompletion(id, user);
		}
	}
}
function quitQuest(id, user){
	if(isFinite(id)){
		id = Number(id);
		var quest = getQuestById(id);
		if(quest != null && hasActiveQuest(id, user)){
			var objectives = String(quest.objectives).split(",");
			var i;
			for(i = 0; i < objectives.length; i++){
				var obj = objectives[i].split(":");
				removeObjective(obj[0], user);
			}
			removeActiveQuest(id, user);
		}
	}
}

function questAvailableToUser(quest, user){
	if((Number(quest.oneTime) == 1 || Number(quest.isDaily) == 1) && hasCompletedQuest(quest.id, user)){
		return false;
	}
	if(Number(quest.reqLevel) > getLevel(user)){
		return false;
	}
	if(Number(quest.access) > getAccess(user)){
		return false;
	}
	if(Number(quest.reqQuest) != -1){
		if(!hasCompletedQuest(Number(quest.reqQuest), user)){
			return false;
		}
	}
	return true;
}

//Objective Functions
function incrementObjective(id, user){
	id = Number(id);
	if(hasObjective(id, user)){
		var objectives = getQuestObjectives(user);
		var obj = String(objectives[getObjectiveIndex(id, objectives)]).split(":");
		obj[1] = Number(obj[1]) + 1;
		objectives[getObjectiveIndex(id, objectives)] = obj.join(":");
		setQuestObjectives(objectives, user);
		var res = [];
		res.push("qoAdd");
		res.push(id);
		res.push(1);
		_server.sendResponse(res, -1, null, [user], "str"); //send response
	}
}

function getObjective(id, user){
	id = Number(id);
	if(hasObjective(id, user)){
		var objectives = getQuestObjectives(user);
		var obj = String(objectives[getObjectiveIndex(id, objectives)]).split(":");
		return Number(obj[1]);
	}
	return -1;
}

function addObjective(id, user){
	id = Number(id);
	if(!hasObjective(id, user)){
		var objectives = getQuestObjectives(user);
		var e = id + ":0";
		objectives.push(e);
		setQuestObjectives(objectives, user);
	}
}

function removeObjective(id, user){
	id = Number(id);
	if(hasObjective(id, user)){
		var objectives = getQuestObjectives(user);
		trace(getObjectiveIndex(id, objectives));
		trace(objectives);
		objectives.splice(getObjectiveIndex(id, objectives), 1);
		trace(objectives);
		setQuestObjectives(objectives, user);
	}
}

function hasObjective(id, user){
	var objectives = getQuestObjectives(user);
	for(var i = 0; i < objectives.length; i++){
		if(objectives[i].indexOf(String(id) + ":") == 0){
			return true;
		}
	}
	return false;
}

function getObjectiveIndex(id, objectives){
	for(var i = 0; i < objectives.length; i++){
		if(objectives[i].indexOf(String(id) + ":") == 0){
			return i;
		}
	}
	return -1;
}




//Active Quest functions
function addActiveQuest(id, user){
	id = Number(id);
	if(!hasActiveQuest(id, user)){
		var activeQuests = getActiveQuests(user);
		var e = String(id);
		activeQuests.push(e);
		setActiveQuests(activeQuests, user);
	}
}

function removeActiveQuest(id, user){
	id = Number(id);
	if(hasActiveQuest(id, user)){
		var activeQuests = getActiveQuests(user);
		activeQuests.splice(activeQuests.indexOf(String(id)), 1);
		setActiveQuests(activeQuests, user);
		sendRemoveQuestFromLog(id, user);
	}
}
function hasActiveQuest(id, user){
	id = String(id);
	var aQuests = getActiveQuests(user);
	if(aQuests.indexOf(String(id)) > -1){
		return true;
	}
	return false;
}



//Quest Completion Functions
function hasCompletedQuest(id, user){
	var quests = getCompletedQuests(user);
	if(quests.indexOf(String(id)) > -1){
		return true;
	}
	return false;
}

function saveQuestCompletion(id, user){
	var charId = Number(user.properties.get("id"));
	if(!hasCompletedQuest(id, user)){
		user.properties.put("quests", user.properties.get("quests") + "," + id);
		var setQuery = "quests = CONCAT(quests, ',"+id+"')";
	
		sql = "UPDATE characters SET "+setQuery+" WHERE id="+charId+"";
		database.executeCommand(sql)
	}
}

//Database Functions
function getQuestById(id){
	if(cachedQuests[id] == null){
		var quest = query("SELECT * FROM quests WHERE id="+id+"");
		if(quest[0] != null){
			cachedQuests[""+id] = quest[0];
			return cachedQuests[id];
		}
	}
	return cachedQuests[id];
}

function getQuestListById(id){
	if(cachedQuestList[id] == null){
		var questList = query("SELECT * FROM questlists WHERE id="+id+"");
		if(questList[0] != null){
			cachedQuestList[""+id] = questList[0];
			return cachedQuestList[id];
		}
	}
	return cachedQuestList[id];
}

function parseQuest(quest){
	if(quest != null){
		var newQuest = {};
		newQuest.id = quest.id;
		newQuest.name = quest.name;
		newQuest.stTxt = quest.startText;
		newQuest.enTxt = quest.endText;
		newQuest.objs = quest.objectives;
		
		return newQuest;
	}
	return null;
}

function hasLegalQuestId(id, user){
	if(user.properties.get("legalQuestIds") == null){
		return false;
	}
	var a = String(user.properties.get("legalQuestIds")).split(",");
	if(a.indexOf(String(id)) == -1){
		return false;
	}
	return true;
}

function sendRemoveQuestFromLog(id, user){
	var res = [];
	res.push("rfQL"); //remove from quest log
	res.push(id); //quest id to update
	
	_server.sendResponse(res, -1, null, [user], "str")
}