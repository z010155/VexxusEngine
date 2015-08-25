package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class RoomList extends MovieClip {
		
		
		public function RoomList() {
			this.visible = false;
			this.addEventListener(MouseEvent.CLICK, clickH);
			txtTitle.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
			txtTitle.addEventListener(MouseEvent.MOUSE_UP, dragStop);
		}
		public function destroy(){
			this.visible = false;
			this.removeEventListener(MouseEvent.CLICK, clickH);
			txtTitle.removeEventListener(MouseEvent.MOUSE_DOWN, dragStart);
			txtTitle.removeEventListener(MouseEvent.MOUSE_UP, dragStop);
		}
		private function clickH(e:MouseEvent){
			switch(e.target.name){
				case 'btnClose':
				this.visible = false;
				break;
			}
		}
		private function dragStart(e:MouseEvent){
			this.startDrag();
		}
		private function dragStop(e:MouseEvent){
			this.stopDrag();
		}
		public function show(content:String){
			txtList.text = content;
			this.x = 960 / 2;
			this.y = 550 / 2;
			this.visible = true;
		}
	}
	
}
