package  {
	
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import fl.transitions.TweenEvent;
	
	
	public class NpcUI extends MovieClip {
		
		private var xT:Tween;
		private var yT:Tween;
		private var sxT:Tween;
		private var syT:Tween;
		public var world:World = World.instance;
		private var bg:MovieClip = new NpcUIBG();
		
		public function NpcUI() {
		}
		public function show(npc:MovieClip, ui:MovieClip, npcInMap:MovieClip){
			this.addChild(ui);
			this.addChild(npc);
			npc.mouseEnabled = false;
			npc.mouseChildren = false;
			if(npcInMap != null){
				npc.cacheAsBitmap = true;
				xT = new Tween(npc, "x", Regular.easeOut, npcInMap.x - 480, -385, 1.5, true);
				yT = new Tween(npc, "y", Regular.easeOut, npcInMap.y - 275, 145, 1.5, true);
				
				sxT = new Tween(npc, "scaleX", Regular.easeOut, npcInMap.scaleX, 1, 1.5, true);
				syT = new Tween(npc, "scaleY", Regular.easeOut, npcInMap.scaleY, 1, 1.5, true);
				sxT.start();
				syT.start();
			} else {
				xT = new Tween(npc, "x", Regular.easeOut, -625, -385, 0.5, true);
				yT = new Tween(npc, "y", Regular.easeOut, 145, 145, 0.5, true);
			}
			
			xT.start();
			yT.start();
		}
		public function reset(){
			Utils.emptyObject(this);
			this.addChild(bg);
			xT = null;
			yT = null;
			sxT = null;
			syT = null;
		}
	}
	
}
