package  {
	
	import flash.display.MovieClip;
	
	
	public class ServerDisplay extends MovieClip {
		
		private var ip:String;
		private var port:int;
		public function ServerDisplay() {
			txtName.mouseEnabled = false;
		}
		public function set Name(e:String){
			this.txtName.text = e;
		}
		public function set IP(e:String){
			ip = e;
		}
		public function set Port(e:int){
			port = e;
		}
		public function get IP():String{
			return ip;
		}
		public function get Port():int{
			return port;
		}
	}
	
}
