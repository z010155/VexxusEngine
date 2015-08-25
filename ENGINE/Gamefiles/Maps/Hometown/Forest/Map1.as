package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	
	
	public class Map1 extends MovieClip {
		
		public var world:*;
		public var defaultRoom:String = "Room1";
		public var size:int = 38;
		public var speed:int = 8;
		public var music:Sound = new ForestTheme();
		public function Map1() {
			stop();
			this.addEventListener(MouseEvent.CLICK, hClick);
		}
		private function hClick(e:MouseEvent){
			var name:String = e.target.name;
			if(name == "npcTalkButton"){
				name = e.target.parent.name;
			}
			if(world != null){
				switch(name){
					case 'npcTalk1':
						world.openNPC("Npc1", npc1);
						//world.npcQuestList(1);
					break;
					case 'btnHalloweenShop':
						world.openShop(6);
					break;
				}
			}
		}
	}
	
}
