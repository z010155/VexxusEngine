package  {
	
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	
	public class SpeechBubble extends MovieClip {
		
		private var timer:Timer;
		
		
		public function SpeechBubble() {
			stop();
			this.visible = false;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.txtMessage.mouseEnabled = false;
			this.box.mouseEnabled = false;
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		private function destroy(e:Event){
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			endTimer();
		}
		public function show(msg:String){
			endTimer();
			timer = new Timer((100 * msg.length) + 1000,1);
			var textBox = this.txtMessage
			var bottomCoord = textBox.y + textBox.height;
			textBox.autoSize = TextFieldAutoSize.CENTER;
    		this.txtMessage.wordWrap = true; 
			textBox.htmlText = msg
			textBox.y = bottomCoord - textBox.height;
			this.box.height = this.txtMessage.textHeight + 10;
			this.box.width = this.txtMessage.textWidth + 30;
			timer.addEventListener(TimerEvent.TIMER, timerFunction);
			this.visible = true;
			timer.start();
		}
		public function timerFunction(e:TimerEvent){
			endTimer();
			this.visible = false;
		}
		private function endTimer(){
			if(timer != null){
				timer.stop();
				timer.reset();
				if(timer.hasEventListener(TimerEvent.TIMER)){
					timer.removeEventListener(TimerEvent.TIMER, timerFunction);
				}
			}
			timer = null;
		}
		public function showAsAdmin(){
			gotoAndStop(2);
		}
	}
	
}
