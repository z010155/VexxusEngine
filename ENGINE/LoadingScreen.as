package  {
	
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class LoadingScreen extends MovieClip {
		
		private static var _instance:LoadingScreen;
		
		public function LoadingScreen() {
			stop();
			if(_instance){
				throw new Error("LoadingScreen: Called illegal instanciation of singleton! Use instance()");
			} 
			_instance = this;
		}
		public static function get instance():LoadingScreen{
			if(!_instance){
				new LoadingScreen();
			} 
			return _instance;
		}
		
		//---------------
		
		public function show(){
			isError = false;
			this.visible = true;
			this.percentText.text = "";
			if(UI.instance != null){
				UI.instance.closeWindows();
				Tooltip.instance.hide();
			}
		}
		public function hide(){
			gotoAndStop(1);
			this.visible = false;
			if(loadingBar != null){
				loadingBar.visible = false;
			}
		}
		public function set text(e:String){
			if(this.currentFrame == 1){
				this.loadingText.text = e;
			}
		}
		public function set info(e:String){
			if(this.currentFrame == 1){
				this.infoText.text = e;
			}
		}
		public function set percent(e:int){
			if(this.percentText != null){
				if(e < 1){
					this.percentText.text = "";
					return;
				}
			}
			if(this.currentFrame == 1){
				loadingBar.visible = true;
				this.percentText.text = e + "%";
				this.loadingBar.gotoAndStop(e);
			}
			
		}
		public function set isError(e:Boolean){
			if(errorDisplay != null){
				if(e){
					errorDisplay.gotoAndStop(2);
				} else {
					errorDisplay.gotoAndStop(1);
				}
			}
		}
		public function banned(){
			this.gotoAndStop(2);
		}
	}
	
}
