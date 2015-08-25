package  {
	
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.geom.ColorTransform;
	
	public class ItemRecievedToast extends MovieClip {
		
		public var icon:ItemIcon;
		
		public function ItemRecievedToast() {
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		public function showToast(data:Object){
			this.gotoAndStop(2);
			icon = base.iconMC as ItemIcon;
			icon.icon = data.ic;
			//icon.setExtra(Number(data.iM), Number(data.iT))
			var color = new ColorTransform();
			color.color = uint("0x"+Inventory.getRarityColor(data.rL).substr(1));
			base.base.transform.colorTransform = color;
			base.txtItemName.htmlText = "<b><font color='"+Inventory.getRarityColor(data.rL)+"'>"+data.name+"</font></b>";
			play();
		}
	}
}
