package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.*;


	public class Projectile extends MovieClip {

		private var target:MovieClip;
		private var lastX:Number;
		private var pSpeed:Number;
		private var count:int = 0;
		
		public function Projectile(projectileClip:MovieClip, userMC:MovieClip, targetMC:MovieClip, intSpeed:int) {
			x = userMC.x;
			y = userMC.y;
			target = targetMC;
			pSpeed = intSpeed;
			this.addChild(projectileClip);
			
			
			this.addEventListener(Event.ENTER_FRAME, oeF);
			
		}
		private function oeF(e:Event) {
			count++;
			if(count > 10){
				pSpeed ++;
				count = 0;
				trace(pSpeed);
			}
			//rotation = Math.atan2(y - target.y,x - target.x) / Math.PI * 180;
			var speed = pSpeed;
			var targetP:Point = new Point(target.x, target.y);
			var diff:Point = targetP.subtract(new Point(this.x,this.y));
			var dist = diff.length;
			if ((dist <= speed)) {
				this.x = targetP.x;
				this.y = targetP.y;
				destroy();
			} else {
				diff.normalize(1);
				this.x +=  Math.round(diff.x * speed);
				this.y +=  Math.round(diff.y * speed);
			}
		}
		public function destroy(){
			this.removeEventListener(Event.ENTER_FRAME, oeF);
			this.parent.removeChild(this);
		}
	}

}