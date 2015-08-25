package  {
	
	import flash.display.MovieClip;
	
	
	public final class Console extends MovieClip {
		
		private static var _instance:Console;
		public var autoTrace:Boolean = false;
		
		public function Console() {
			if(_instance){
				throw new Error("Console: Called illegal instanciation of singleton! Use instance()");
			} 
			_instance = this;
		}
		public function destroy(){
			_instance = null;
		}
		public static function get log():Console{
			if(!_instance){
				new Console();
			} 
			return _instance;
		}
		public function log(msg:String, traceMsg:Boolean = false){
			consoleText.appendText(msg + "\n");
			if(autoTrace || traceMsg){
				trace(msg);
			}
		}
		public function clean(){
			consoleText.text = "";
		}
	}
	
}
