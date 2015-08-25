package  {
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	
	public class ClientInfo {
		
		public var name:String;
		public var gold:int;
		public var id:int;
		public var access:int;
		public var gender:int;
		public var weaponData:String;
		public var armorData:String;
		public var weaponAD:ApplicationDomain;
		public var armorAD:ApplicationDomain;
		public var abilities:Array;
		public var health:int;
		public var maxHealth:int;
		public var useBitmapCaching:Boolean = false;
		public var xpMax:int
		
		private var _xp:int;
		private var playerLevel:int;
		private var cachedQuests:Object = {};
		private var activeQuests:Object = {};
		private var questObjectives:Object = {};
		
		
		private static var _instance:ClientInfo;
		public function ClientInfo() {
			_instance = this;
		}
		public function destroy(){
			_instance = null;
		}
		public static function get data():ClientInfo{
			return _instance;
		}
		public function cacheQuest(data:Object){
			cachedQuests[String(data.id)] = data;
		}
		public function getCachedQuest(id:int){
			return cachedQuests[String(id)];
		}
		public function get xp():int{
			return _xp;
		}
		public function set xp(e:int){
			_xp = e;
			UI.instance.updateXPBar();
		}
		public function get level():int{
			return playerLevel;
		}
		public function set level(e:int){
			playerLevel = e;
			xpMax = getXPToLevel(e);
			UI.instance.refreshAbilityAvailability();
			UI.instance.updateXPBar();
			
		}
		private function getXPToLevel(lvl:int):int{
			lvl++;
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
			
			return xpBase * lvl * (1+lvl);
		}
		public function addQuestToLog(id:int){
			var quest:Object = getCachedQuest(id);
			if(quest != null){
				activeQuests[String(id)] = quest;
				var objs:Array = quest.objs.split(",");
				for(var i:int = 0; i < objs.length; i++){
					var obj:Array = objs[i].split(":");
					questObjectives[""+obj[0]] = [0, obj[1], obj[2]];
				}
				UI.instance.updateQuestTracker();
			}
		}
		public function removeQuestFromLog(id:int){
			if(activeQuests[String(id)] != null){
				var quest:Object = getCachedQuest(id);
				if(quest != null){
					var objs:Array = quest.objs.split(",");
					for(var i:int = 0; i < objs.length; i++){
						var obj:Array = objs[i].split(":");
						delete questObjectives[""+obj[0]];
					}
				}
				delete activeQuests[String(id)];
				UI.instance.updateQuestTracker();
			}
		}
		public function hasActiveQuest(id:int):Boolean {
			if(activeQuests[String(id)] != null){
				return true;
			}
			return false;
		}
		public function getQuestObjective(id:int){
			return questObjectives[""+id];
		}
		public function activeQuestIsComplete(id):Boolean { //using quest id, needs to use obj id
			if(activeQuests[String(id)] != null){
				var quest:Object = activeQuests[String(id)];
				var objs:Array = quest.objs.split(",");
				for(var i:int = 0; i < objs.length; i++){
					var obj:Array = objs[i].split(":");
					if(Number(questObjectives[""+obj[0]][0]) < Number(questObjectives[""+obj[0]][1])){
						return false;
					}
				}
				return true;
			}
			return false;
		}
		public function getQuestLog():Array{
			var a:Array = [];
			for (var key:String in activeQuests) {
				a.push(activeQuests[key]);
			}
			trace(a.length);
			return a;
		}
		public function updateQuestObjective(id:int, amountToIncrease:int){
			if(Number(questObjectives[""+id][0]) < Number(questObjectives[""+id][1])){
				questObjectives[""+id][0] += amountToIncrease;
				UI.instance.updateQuestTracker();
			}
		}
		public function get weaponFile():String{
			return weaponData.split(",")[0];
		}
		public function get weaponLinkage():String{
			return weaponData.split(",")[1];
		}
		
		public function get armorFile():String{
			return armorData.split(",")[0];
		}
		public function get armorLinkage():String{
			return armorData.split(",")[1];
		}
		public function get genderToString():String{
			var gender:String = "M";
			if(this.gender != 0){
				gender = "F";
			}
			return gender;
		}
		
	}
}
