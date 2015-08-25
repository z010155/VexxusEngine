package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Shop extends MovieClip {
		
		private var v:int;
		private var MAX_SLOTS_PER_PAGE:int = 10;
		private var curPage:int = 0;
		private var itemInfos:Array;
		private var indexedItemInfos:Object;
		private var data:Object;
		private var totalPages:int;
		
		public function Shop() {
			this.visible = false;
			this.addEventListener(MouseEvent.CLICK, clickH);
			itemInfos = [];
			indexedItemInfos = {};
		}
		public function destroy(){
			this.removeEventListener(MouseEvent.CLICK, clickH);
			destroySlots();
		}
		private function clickH(e:MouseEvent){
			switch(e.target.name){
				case 'btnPrevious':
				prevPage();
				break;
				case 'btnNext':
				nextPage();
				break;
			}
		}
		public function reset(){
			itemInfos = [];
			indexedItemInfos = {};
			data = {};
			this.visible = false;
			v = 0;
		}
		public function display(data:Object){
			this.data = data;
			var shopName:String = data.name;
			totalPages = Math.ceil(data.items.length / MAX_SLOTS_PER_PAGE)
			showPage(1);
			this.txtShopName.text = shopName;
			this.visible = true;
		}
		public function displayItem(obj:Object){
			v++;
			if(v <= MAX_SLOTS_PER_PAGE){
				var slot:ShopItem = this.getChildByName("itemSlot" + String(v)) as ShopItem;
				slot.activate(obj);
				if(slot.txtItemName.numLines < 2){
					slot.txtItemName.y -= slot.txtItemName.y / 2;
				}
				itemInfos.push(obj);
				indexedItemInfos[obj.id] = itemInfos[itemInfos.length - 1]
			}
		}
		
		public function showPage(number:int){
			curPage = number - 1;
			v = 0;
			var i:int;
			destroySlots();
			for(i = 0 + (MAX_SLOTS_PER_PAGE * curPage); i < MAX_SLOTS_PER_PAGE + (MAX_SLOTS_PER_PAGE * curPage); i++){
				if(data.items[i] != null){
					displayItem(data.items[i])
				}
			}
			btnNext.visible = false;
			btnPrevious.visible = false;
			if(number < totalPages){
				btnNext.visible = true;
			}
			if(number > 1){
				btnPrevious.visible = true;
			}
		}
		public function nextPage(){
			var a:int = curPage + 1;
			if(a < totalPages){
				showPage(a + 1);
			}
		}
		public function prevPage(){
			var a:int = curPage + 1;
			if(a > 1){
				showPage(a - 1);
			}
		}
		private function destroySlots(){
			for(var i:int = 1; i <= MAX_SLOTS_PER_PAGE; i++){
				var slot:ShopItem = this.getChildByName("itemSlot" + String(i)) as ShopItem;
				slot.destroy();
			}
		}
		
		
		
		public function startPurchase(){
			this.loadingCover.visible = true;
		}
		public function finishedPurchase(success:Boolean, id:int){
			if(success){
				if(UI.instance.inventoryHasId(id)){
					UI.instance.getCachedItemById(id).sN = Number(UI.instance.getCachedItemById(id).sN) + 1;
					if(Number(UI.instance.getCachedItemById(id).cT) == 0){
					   ClientInfo.data.gold -= UI.instance.getCachedItemById(id).cost;
					} else {
						UI.instance.removeItemFromInventory(Number(UI.instance.getCachedItemById(id).cT), UI.instance.getCachedItemById(id).cost);
					}
				} else {
					indexedItemInfos[id].sN = 1;
					UI.instance.inventoryCache.push(indexedItemInfos[id]);
					if(Number(indexedItemInfos[id].cT) == 0){
					   ClientInfo.data.gold -= indexedItemInfos[id].cost;
					} else {
						UI.instance.removeItemFromInventory(Number(indexedItemInfos[id].cT), indexedItemInfos[id].cost);
					}
				}
				UI.instance.openInventory();
			}
			this.loadingCover.visible = false;
		}
	}
	
}
