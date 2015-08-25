package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class ShopItem extends MovieClip {
		
		public var itemId:int;
		public var icon:ItemIcon;
		public var info:Object;
		private var iT:String;
		
		public function ShopItem() {
		}
		private function hClick(e:MouseEvent){
			if(this.itemId > 0){
				Tooltip.instance.hide();
				if(iT == "1,0" || iT == "1,1"){
					UI.instance.showClickMenu(itemId.toString(), UI.instance.itemMenuHandler, ["Buy", "Preview", "Cancel"]);
				} else {
					UI.instance.showClickMenu(itemId.toString(), UI.instance.itemMenuHandler, ["Buy", "Cancel"]);
				}
				
			}
			
		}
		
		public function destroy(){
			itemId = 0;
			icon = null;
			info = null;
			if(this.hasEventListener(MouseEvent.CLICK)){
				this.removeEventListener(MouseEvent.CLICK, hClick);
				Tooltip.instance.removeHoverTip(this);
			}
			this.gotoAndStop(2);
		}
		public function activate(data:Object){
			this.gotoAndStop(1);
			this.txtItemName.y = -18.9;
			while(currency.numChildren){
				currency.removeChildAt(0);
			}
			this.info = data;
			iT = info.iT;
			icon = this.iconMC as ItemIcon;
			icon.icon = data.ic;
			icon.setExtra(Number(data.iM), Number(data.iT))
			this.itemId = data.id;
			if(Number(data.cT) == 0){
				currency.addChild(new icon_default_currency());
			} else {
				if(Inventory.CURRENCY_ICONS.hasOwnProperty(Number(data.cT))){
					currency.addChild(Utils.getIconAsset(Inventory.CURRENCY_ICONS[Number(data.cT)]));
				}
			}
			
			txtItemCost.text = Utils.formatNumber(data.cost);
			txtItemName.htmlText = "<b><font color='"+Inventory.getRarityColor(data.rL)+"'>"+data.name+"</font></b>";
			
			Tooltip.instance.hoverTip(this, Inventory.createToolTipContent(data));
			this.addEventListener(MouseEvent.CLICK, hClick);
			
			this.txtItemName.mouseEnabled = false;
			this.txtItemCost.mouseEnabled = false;
			this.currency.mouseEnabled = false;
			this.currency.mouseChildren = false;
		}
		
	}
	
}
