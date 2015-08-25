package {

	import flash.display.MovieClip;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class Tooltip extends MovieClip {

		private static var _instance:Tooltip;
		private var following:Boolean = false;
		private var hoverTips:Array;
		
		public function Tooltip() {
			if(_instance){
				throw new Error("Singleton cannot be instanciated more than once!");
			}
			_instance = this;
			hoverTips = new Array();
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.content.mouseEnabled = false;
		}
		public function destroy(){
			if(following){
				Main.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, autoMove);
			}
			while(hoverTips.length){
				removeHoverTip(hoverTips[0]);
			}
			_instance = null;
		}
		public function show(x:Number,y:Number,content:String) {
			this.visible = false;
			//set content
			this.content.htmlText = content; 
			
			
			//make sure textboxes auto size to the content
			this.content.autoSize = TextFieldAutoSize.LEFT;
			
			//set tooltip background size
			this.bg_mc.width = 200;
			
			//sets the text width
			this.content.width = 190;
			
			//saves the content width/height
			var boxHeight:Number = this.content.height + 10;
			var boxWidth:Number = this.content.width + 10;
			
			//sets the background height based on text height
			this.bg_mc.height = boxHeight;
			position(x, y);
			this.visible = true;
			//Main.STAGE.addChild(this);
		}
		public function hide() {
			this.visible = false;
			//MovieClip(this.parent).removeChild(this);
		}
		public function set autoFollowMouse(bool:Boolean){
			if(bool && !following){
				following = true;
				Main.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, autoMove);
			} else if(!bool && following){
				following = false;
				Main.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, autoMove);
			}
		}
		public function position(posX:Number, posY:Number){
			var tempX:Number = posX;
			var tempY:Number = posY;
			
			if(tempX + this.width > Main.STAGE_WIDTH){
				this.x = tempX - this.width;
			}else{
				this.x = tempX
			}
			if(tempY + this.height > Main.STAGE_HEIGHT){
				this.y = tempY - this.height;
			}else{
				this.y = tempY
			}
			
		}
		private function autoMove(e:MouseEvent){
			this.position(e.stageX - this.width, e.stageY);
			e.updateAfterEvent();
		}
		public function hoverTip(mc:*, content:String){
			hoverTips.push(mc);
			mc.addEventListener(MouseEvent.MOUSE_OVER, hoverTipOVER);
			mc.addEventListener(MouseEvent.MOUSE_OUT, hoverTipOUT);
			mc.addEventListener("disableHoverTip", removeHovers);
			function hoverTipOVER(e:MouseEvent){
				show(e.stageX - width, e.stageY, content);
				autoFollowMouse = true;
			}
			function hoverTipOUT(e:MouseEvent){
				hide();
				autoFollowMouse = false;
			}
			function removeHovers(e:Event){
				hide();
				try{
					mc.removeEventListener(MouseEvent.MOUSE_OVER, hoverTipOVER);
					mc.removeEventListener(MouseEvent.MOUSE_OUT, hoverTipOUT);
					hoverTips.splice(hoverTips.indexOf(mc), 1);
				} catch(e:Error){};
			}
		}
		public function removeHoverTip(mc:*){
			mc.dispatchEvent(new Event("disableHoverTip"));
		}
		public static function get instance():Tooltip{
			if(!_instance){
				return null;
			}
			return _instance;
		}
	}

}