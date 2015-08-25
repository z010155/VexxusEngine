package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class ItemIconSlot extends MovieClip {
		
		public var icon:ItemIcon;
		public var id:int;
		private var _stack:int;
		private var iT:String;
		
		public function ItemIconSlot() {
		}
		public function destroy(){
			id = 0;
			if(this.hasEventListener(MouseEvent.CLICK)){
				this.removeEventListener(MouseEvent.CLICK, hClick);
				Tooltip.instance.removeHoverTip(this);
				this.gotoAndStop(2);
			}
		}
		public function activate(data:Object){
			this.gotoAndStop(1);
			icon = this.iconMC;
			icon.icon = data.ic;
			//icon.rarity = data.rL;
			this.iT = data.iT;
			this.stack = data.sN;
			icon.setExtra(Number(data.iM), Number(data.iT))
			
			this.id = data.id;
			Tooltip.instance.hoverTip(this, Inventory.createToolTipContent(data));
			this.addEventListener(MouseEvent.CLICK, hClick);
		}
		public function set stack(e:int){
			_stack = e;
			icon.stackSize = _stack;
		}
		public function get stack():int{
			return _stack;
		}
		private function hClick(e:MouseEvent){
			Tooltip.instance.hide();
			if(MovieClip(this.parent.parent).currentFrameLabel == "Shop"){
				if(iT == "1,0" || iT == "1,1"){
					UI.instance.showClickMenu(id.toString(), UI.instance.itemMenuHandler, ["Sell", "Preview", "Cancel"]);
				} else {
					UI.instance.showClickMenu(id.toString(), UI.instance.itemMenuHandler, ["Sell", "Cancel"]);
				}
			} else {
				if(iT == "1,0" || iT == "1,1"){
					UI.instance.showClickMenu(id.toString(), UI.instance.itemMenuHandler, [Inventory.getMenuStringByType(iT), "Preview", "Cancel"]);
				} else {
					UI.instance.showClickMenu(id.toString(), UI.instance.itemMenuHandler, [Inventory.getMenuStringByType(iT), "Cancel"]);
				}
			}
		}
		
	}
	
}
