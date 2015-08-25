package  {
	
	import flash.display.MovieClip;
	
	
	public class Inventory extends MovieClip {
		
		private var v:int;
		public static var MAX_SLOTS_PER_PAGE:int = 24;
		public static var COLOR_ITEM_MYTHIC:String = "#990000";
		public static var COLOR_ITEM_LEGENDARY:String = "#CE4300";
		public static var COLOR_ITEM_EPIC:String = "#9B21ED";
		public static var COLOR_ITEM_RARE:String = "#0070ff";
		public static var COLOR_ITEM_UNIQUE:String = "#00BB00";
		public static var COLOR_ITEM_COMMON:String = "#CCCCCC";
		
		public static var CURRENCY_ICONS:Object = {9003: "badge_blue"}
		public static var CURRENCY_NAMES:Object = {9003: "Badge of Victory"}
		
		public function Inventory() {
			this.visible = false;
		}
		public function reset(){
			this.visible = false;
			v = 0;
			for(var i:int = 1; i <= MAX_SLOTS_PER_PAGE; i++){
				var slot:MovieClip = this.getChildByName("itemSlot" + String(i)) as MovieClip;
				slot.destroy();
				slot.gotoAndStop(1);
			}
		}
		public function display(){
			for(var i:int = v + 1; i <= MAX_SLOTS_PER_PAGE; i++){
				var slot:MovieClip = this.getChildByName("itemSlot" + String(i)) as MovieClip;
				slot.gotoAndStop(2);
			}
			this.txtGold.text = Utils.formatNumber(ClientInfo.data.gold);
			this.visible = true;
		}
		public function displayItem(obj:Object){
			v++;
			if(v <= MAX_SLOTS_PER_PAGE){
				var slot:ItemIconSlot = this.getChildByName("itemSlot" + String(v)) as ItemIconSlot;
				slot.activate(obj);
			}
		}
		public function getSlotByItemId(id:int):ItemIconSlot{
			for(var i:int = 1; i < Inventory.MAX_SLOTS_PER_PAGE + 1; i++){
				var s:ItemIconSlot = MovieClip(this.getChildByName("itemSlot" + i)) as ItemIconSlot;
				if(s.id == id){
					return s;
				}
			}
			return null;
		}
		public static function getRarityColor(rarity:int){
			switch(rarity){
				case 1:
				return Inventory.COLOR_ITEM_UNIQUE;
				break;
				
				case 2:
				return Inventory.COLOR_ITEM_RARE;
				break;
				
				case 3:
				return Inventory.COLOR_ITEM_EPIC
				break;
				
				case 4:
				return Inventory.COLOR_ITEM_LEGENDARY;
				break;
				
				case 5:
				return Inventory.COLOR_ITEM_MYTHIC;
				break;
				
				default:
				return Inventory.COLOR_ITEM_COMMON;
			}
		}
		public static function getRarityName(rarity:int){
			switch(rarity){
				case 1:
				return "unique";
				break;
				
				case 2:
				return "rare";
				break;
				
				case 3:
				return "epic";
				break;
				
				case 4:
				return "legendary";
				break;
				
				case 5:
				return "mythic";
				break;
				
				default:
				return "common";
			}
		}
		public static function getCurrencyName(id:int){
			if(id == 0){
				return 'gold';
			}
			if(CURRENCY_NAMES.hasOwnProperty(id)){
				return CURRENCY_NAMES[id];
			} 
			return 'currency';
		}
		public static function createToolTipContent(data:Object):String{
			var tip:String = "";
			tip += "<b><font color='"+Inventory.getRarityColor(data.rL)+"'>"+data.name+"</font></b>" + "<br>";
			if(data.iT == "1,0"){
				tip += "Weapon" + "<br>";
				tip += Utils.capitalize(Inventory.getRarityName(data.rL)) + " quality" + "<br>";
				tip += ""+data.dmg+" damage<br>";
			} else if(data.iT == "1,2"){
				tip += "<font color='#FF6666'>Class</font>" + "<br>";
			} else {
				tip += Utils.capitalize(Inventory.getRarityName(data.rL)) + " item" + "<br>";
				if(Number(data.mS) > 1){
					tip += "Max Stack " + data.mS + "<br>";
				}
			}
			if(data.desc.length > 0){
				tip += "\""+data.desc+"\"<br>";
			}
			if(Number(data.sell) > 0){
				tip += "Sell price: " + Utils.formatNumber(data.sell) + " "+getCurrencyName(data.cT)+"<br>";
			} else if(Number(data.sell) > -1){
				tip += "No sell price<br>";
			} else {
				tip += "Cannot be sold<br>";
			}
			return tip;
		}
		public static function getMenuStringByType(e:String):String{
			switch(e){
				case '1,0':
				case '1,1':
				case '1,2':
					return 'Equip';
				break;
				
				default:
					return 'Use';
				break;
			}
			return "User";
		}
	}
	
}
