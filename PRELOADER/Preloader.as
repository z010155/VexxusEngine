package  {
	
	import flash.display.MovieClip;
	import com.util.File;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	
	public class Preloader extends MovieClip {
		
		private var game:File;
		private var engineFile:String = "latestBuild.swf";
		private var connection:Connection;
		private var localMode:Boolean = new RegExp("file://").test(loaderInfo.url) || new RegExp("localhost").test(loaderInfo.url);

		public function Preloader() {
			var url:String = ExternalInterface.call("window.location.href.toString");
			if(localMode){
				connection = new Connection("localhost/game");
			} else {
				if(url.indexOf("zapto") > -1){
					connection = new Connection("azerron.zapto.org/AzerronStaffTest");
				} else {
					connection = new Connection("azerron.com/game");
				}
			}
			stop();
			bar.gotoAndStop(1);
			barGlow.gotoAndStop(101);
			connection.postPage("getCurrentBuild.php", {}, onBuildGetComplete);
		}
		private function onBuildGetComplete(data:Object){
			if(data.latestBuild != null){
				engineFile = data.latestBuild;
			}
			game = new File(engineFile, onCompleteH, onUpdateH, onFailureH);
		}
		private function onCompleteH(e:Event){
			while(this.numChildren){
				this.removeChildAt(0);
			}
			this.addChild(e.target.content);
		}
		private function onUpdateH(perc:int){
			bar.gotoAndStop(perc + 1);
		}
		private function onFailureH(e){
			this.gotoAndStop(2);
		}
	}
	
}
