package  {
	
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class DuelRequest extends MovieClip {
		
		private var i:int = 30;
		private var countDown:Timer = new Timer(1000);
		
		public function DuelRequest() {
			x = 480;
			y = 387;
			countDown.addEventListener(TimerEvent.TIMER, timerH);
			countDown.start();
		}
		public function destroy(){
			countDown.stop();
			countDown.removeEventListener(TimerEvent.TIMER, timerH);
			UI.instance.removeDuelRequest();
		}
		private function timerH(e:TimerEvent){
			i --;
			if(i < 0){
				UI.instance.declineDuel();
				return;
			}
			this.txtTime.text = "" + i;
		}
	}
	
}
