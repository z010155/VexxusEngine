var cachedItems = {};
var cachedShops = {};

function getItemFileById(id){
	var itemData = getItemById(id);
	if(itemData != null && id > 0){
		var file = itemData.itemData + "," + itemData.linkage;
		return file;
	}
	return '?,?';
}


function sendInventory(user){ 
	if(user == null){
		return;
	}
	var dbItems = [];
	var items = [];
	dbItems = query("SELECT * FROM inventory WHERE userId=" + Number(getCharId(user)) + "");
	if(dbItems[0] != null){
		for (var i = 0; i < dbItems.length; i++){
			var item = getItemById(dbItems[i].itemId);
			if(item != null){
				var newItem = parseItem(item);
				newItem.sN = dbItems[i].stack;
				items.push(newItem);
			}
		}
	}
	var obj = {};
	obj.cmd = "userInvent";
	obj.items = items;
	_server.sendResponse(obj, -1, null, [user], "json");
	
}

function loadShop(user, shopId){
	var shopData = getShopById(Number(shopId));
	if(shopData != null){
		var shopAccess = shopData.access;
		if(Number(user.properties.get("access")) >= shopAccess){
			var shopName = shopData.shopName;
			var shopContents = shopData.shopContents.split(",");
			var items = [];
			if(shopData.shopContents != "" && shopData.shopContents != null){
				for (var i = 0; i<shopContents.length; i++){
					var item = getItemById(shopContents[i]);
					if(item != null){
						items.push(parseItem(item));
					}
				}
			}
			var obj = {};
			obj.cmd = "shopData";
			obj.id = shopId;
			obj.items = items;
			obj.name = shopName;
			user.properties.put("legalBuyIds", shopContents);
			_server.sendResponse(obj, -1, null, [user], "json");
		} else {
			trace("Attempted To Open Shop But Access Was Too Low! Inform Admins And Kick User!")
			_server.kickUser(user, .5, "COS-ATL"); //can't open shop - access too low
		}
	}
	
}
function buyItem(user, id){
	if(hasLegalBuyId(id, user)){
		var uId = getCharId(user);
		var item = getItemById(id);
		if(item != null){
			var obj = [];
			obj.push("buyResult");
			var cost = Number(item.cost);
			var currencyType = item.currency;
			var userCurrency = getCurrency(user, currencyType);
			if(userCurrency >= cost){
				var success = addItem(user, id);
				if (success == true){
					var newAmount = userCurrency - cost;
					setCurrency(user, currencyType, newAmount)
					obj.push("success"); 
					obj.push(id);
				} else if(success == "max"){
					obj.push("msr");
				} else {
					obj.push("iif");
				}
			} else{
				//trace("Not enough gold!")
				obj.push("neg");
			}
			_server.sendResponse(obj, -1, null, [user], "str");
		}
	} else {
		kickAndInform(user, .5, "IBID", "Illegal Buy Request");
	}
}

function sellItem(user, id){
	if(hasEquipped(user, id)){return;}
	
	var uId = getCharId(user);
	var gold = Number(user.properties.get("gold"));
	var item = getItemById(id);
	if(item != null){
		var obj = [];
		obj.push("sellResult");
		var sellPrice = Number(item.sellPrice);
		if(sellPrice > -1){
			var numSold = removeItem(user, id, 1);
			if (numSold != null){
				gold += sellPrice * numSold;
				if(randomBetween(1, 100) <= SAVE_GOLD_CHANCE){
					saveGold(gold, user);
				}
				user.properties.put("gold", gold);
				obj.push("suc"); 
				obj.push(numSold);
				obj.push(id); 
			} else {
				obj.push("sif"); // failed
			}
		} else {
			obj.push("cbs"); // (item) cannot be sold
		}
		_server.sendResponse(obj, -1, null, [user], "str");
	}
}

function giveItem(user, id){
	//trace("Reward!");
	var item = getItemById(id);
	if(item != null){
		var addSuccess = addItem(user, id);
		//trace("Add success: " + addSuccess);
		if(addSuccess == true){
			item = parseItem(item);
			item.cmd = "rewRec";
			_server.sendResponse(item, -1, null, [user], "json");
			//trace("Reward sent!");
		} else {
			//trace("Item not added!");
		}
	} else {
		//trace("Item Not Found!");
	}
}

function addItem(user, id){
	//check if user has item
	var uId = getCharId(user);
	var totalSlots = Number(user.properties.get("iSlots"));
	var count = 0;
	var slotCount = query("SELECT count(*) FROM inventory WHERE userId="+uId+"");
	if(slotCount[0] != null){
		count = Number(slotCount[0]["count(*)"]);
	}
	if(count < totalSlots){
		var userItem = query("SELECT stack FROM inventory WHERE itemId="+id+" AND userId="+uId+"");
		if(userItem[0] == null){
			var sql = "INSERT INTO inventory (userId, itemId) VALUES ('"+uId+"',"+id+")"
			return database.executeCommand(sql)
		} else {
			//check if item stack is less than max stack
			var stack = Number(userItem[0].stack);
			var item = getItemById(id);
			if(item != null){
				var maxStack = Number(item.maxStack);
				//trace("maxstack: " + maxStack);
				if(stack < maxStack){
					var newStack = stack + 1;
					sql = "UPDATE inventory SET stack="+newStack+" WHERE itemId="+id+" AND userId="+uId+"";
					return database.executeCommand(sql)
				} else {
					return "max";
				}
			}
		}
	}
}

function getCurrency(user, id){
	id = Number(id);
	//trace(id);
	if(id == 0){
		var gold = Number(user.properties.get("gold"));
		return gold;
	} else {
		var a = userHasItem(user, id);
		if(a != null){
			return a;
		}
	}
	return null;
}
function setCurrency(user, id, newAmount){
	id = Number(id);
	var uId = Number(getCharId(user));
	if(id == 0){
		if(randomBetween(1, 100) <= SAVE_GOLD_CHANCE){
			saveGold(newAmount, user);
		}
		user.properties.put("gold", newAmount);
	} else {
		if(newAmount <= 0){
			sql = "DELETE FROM inventory WHERE itemId="+id+" AND userId="+uId+"";
			database.executeCommand(sql)
		} else {
			sql = "UPDATE inventory SET stack="+newAmount+" WHERE itemId="+id+" AND userId="+uId+"";
			database.executeCommand(sql)
		}
	}
}

function userHasItem(user, id){
	var uId = getCharId(user);
	var userItem = query("SELECT stack FROM inventory WHERE itemId="+id+" AND userId="+uId+"");
	if(userItem[0] != null){
		return userItem[0].stack;
	}
	return null;
}

function removeItem(user, id, sellAmount){
	//check if user has item
	if(hasEquipped(user, id)){return;}
	var uId = getCharId(user);
	var userItem = query("SELECT stack FROM inventory WHERE itemId="+id+" AND userId="+uId+"");
	if(userItem[0] != null){
		var stack = Number(userItem[0].stack);
		if(stack == 1){
			sql = "DELETE FROM inventory WHERE itemId="+id+" AND userId="+uId+"";
			if(database.executeCommand(sql)){
				return 1;
			}
		} else if(sellAmount != undefined && sellAmount != null && isFinite(sellAmount) && sellAmount <= stack){
			var newStack = stack - sellAmount;
			sql = "UPDATE inventory SET stack="+newStack+" WHERE itemId="+id+" AND userId="+uId+"";
			if(database.executeCommand(sql)){
				return Number(sellAmount);
			}
		}
	} //else {
		// user does not have this item, kick and inform the admins!
		//kickAndInform(user, .5, "ISID", "User attempted to sell id that he did not own!");
	///}
	return null;
}

function useItem(id, user, room){
	if(userHasItem(user, id) != null){
		var item = getItemById(id);
		if(item != null){
			if(Number(item.access) > getAccess(user) || Number(item.reqLvl) > getLevel(user)){
				return;
			}
			var obj = [];
			obj.push("useRes");
			var type = item.type.split(",");
			if(type[0] != null){
				switch(type[0]){
					case '1': 
					if(type[1] != null){
						if(!hasEquipped(user, id)){
							if(type[1] == "0"){
								//weapon
								obj.push("wep");
								obj.push(item.itemData + "," + item.linkage);
								changeEquip(user, "wep", item.itemData + "," + item.linkage, id, room);
							} else if(type[1] == "1"){
								//armor
								obj.push("arm");
								obj.push(item.itemData + "," + item.linkage);
								changeEquip(user, "arm", item.itemData + "," + item.linkage, id, room);
							} else if(type[1] == "2"){
								//class
								changeUserClass(Number(item.itemData), user);
								saveClass(Number(id), user);
							} else if(type[1] == "3"){
								//stat item
							}
						}
					}
					break;
					case '2':
					if(type[1] != null){
						if(type[1] == "0"){
							//potion
						} else if(type[1] == "1"){
							//bonus
						} else if(type[1] == "2"){
							//teleport
							obj.push("tel");
							obj.push(id);
							if(type[2] == "1"){
								if(removeItem(user, id, 1) == null){
									return;
								}
							} else {
								obj.pop();
								obj.pop();
							}
							requestEnterZone(user, item.itemData.toLowerCase());
						} else if(type[1] == "3"){
							//container
							obj.push("box");
							obj.push(id);
							if(type[2] == "1"){
								if(removeItem(user, id, 1) == null){
									return;
								}
							} else {
								obj.pop();
								obj.pop();
							}
							var itemFromCont = getItemFromContainer(Number(item.itemData));
							if(itemFromCont != null){
								giveItem(user, itemFromCont);
							}
						}
					}
					break;
				}
			}
			_server.sendResponse(obj, -1, null, [user], "str");
		}
	} else {
		//trace("Doesn't have item!");
	}
}
function changeEquip(user, equipType, data, id, room){
	var propertyName;
	if(equipType == "arm"){
		propertyName = "armorId";
	} else {
		propertyName = equipType + "Id";
	}
	user.properties.put(propertyName, id);
	var obj = [];
	obj.push(equipType + "Ch");
	obj.push(user.getUserId());
	obj.push(data);
	sendToAllUsersButOne(obj, room, user);
}

function hasEquipped(user, id){
	if(Number(user.properties.get("wepId")) == Number(id) || Number(user.properties.get("armorId")) == Number(id) || Number(user.properties.get("classItemId")) == Number(id)){
		return true;
	}
	return false;
}

function parseItem(item){
	var iO = {};
	iO.name = item.name;
	iO.dmg = item.damage;
	iO.desc = item.desc;
	iO.cost = item.cost;
	iO.sell = item.sellPrice;
	iO.id = item.id;
	iO.ic = item.icon;
	iO.rL = item.rarity;
	iO.iM = item.isMember;
	iO.iT = item.isToken;
	iO.mS = item.maxStack;
	iO.cT = item.currency;
	iO.iT = item.type;
	iO.rqL = item.reqLvl;
	return iO;
}
function getItemFromContainer(containerId){
	containerId = Number(containerId);
	var container = query("SELECT * FROM containers WHERE id="+containerId+"");
	if(container[0] != null){
		var itemList = container[0].items.split(",");
		var i;
		var list = [];
		var weight = [];

		for(i = 0; i < itemList.length; i++){
			var itemInfo = itemList[i].split(":");
			list.push(itemInfo[0])
			weight.push(Number(itemInfo[1]) / 100);
		}
		
		var weighed_list = [];
		// Loop over weights
		for (var i = 0; i < weight.length; i++) {
			var multiples = weight[i] * 100;
			for (var j = 0; j < multiples; j++) {
				weighed_list.push(list[i]);
			}
		}
		return weighed_list[randomBetween(0, weighed_list.length-1)];
	}
	return null;
}
function getItemById(id){
	if(cachedItems.hasOwnProperty(""+id) && cachedItems[""+id] != null){
		return cachedItems[""+id];
	}
	var item = query("SELECT * FROM items WHERE id="+id+"");
	if(item[0] != null){
		cachedItems[""+id] = item[0];
		return item[0];
	}
	return null;
}

function getShopById(id){
	if(cachedShops.hasOwnProperty(""+id) && cachedShops[""+id] != null){
		return cachedShops[""+id];
	}
	var shop = query("SELECT * FROM shops WHERE id="+id+"");
	if(shop[0] != null){
		cachedShops[""+id] = shop[0];
		return shop[0];
	}
	return null;
}

function hasLegalBuyId(id, user){
	if(user.properties.get("legalBuyIds") == null){
		return false;
	} 
	var a = String(user.properties.get("legalBuyIds")).split(",");
	if(a.indexOf(String(id)) == -1){
		return false;
	}
	return true;
}




