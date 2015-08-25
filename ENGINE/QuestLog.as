package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class QuestLog extends MovieClip {
		public var questListId:int;
		private var listData:Object;
		private var viewingQuest:int;
		private var isViewingLog:Boolean = false;
		
		public var state:int = 0;
		public function QuestLog() {
			stop();
			this.addEventListener(MouseEvent.CLICK, clickH);
		}
		public function destroy(){
			listData = null;
			viewingQuest = -1;
			isViewingLog = false;
			this.removeEventListener(MouseEvent.CLICK, clickH);
		}
		private function clickH(e:MouseEvent){
			if(e.target.name == "questSlotBtn"){
				openQuest(e.target.parent as QuestLogSlot);
			}
			switch(e.target.name){
				case 'btnBackToList':
					if(isViewingLog){
						displayQuestLog();
					} else {
						displayQuestList(listData);
					}
				break;
				case 'btnAcceptQuest':
					if(viewingQuest != -1){
						Server.instance.startQuest(viewingQuest);
						gotoAndStop("Wait");
					}
				break;
				case 'btnDeclineQuest':
					displayQuestList(listData);
				break;
				case 'btnCompleteQuest':
					state = 2;
					if(viewingQuest != -1){
						Server.instance.completeQuest(viewingQuest);
						buttons.gotoAndStop(4);
						//gotoAndStop("Wait");
					}
				break;
				case 'btnAbandonQuest':
					state = 1;
					if(viewingQuest != -1){
						Server.instance.quitQuest(viewingQuest);
						buttons.gotoAndStop(5);
						//gotoAndStop("Wait");
					}
				break;
			}
		}
		private function openQuest(slot:QuestLogSlot){
			Server.instance.getQuestData(slot.id);
		}
		
		public function displayQuest(data:Object, state:int = 0){
			this.visible = false;
			gotoAndStop("QuestOpen");
			var desc:String;
			if(state == 0){ //a new quest
				buttons.gotoAndStop(1);
				desc = data.stTxt.split("%p%").join(Utils.capitalize(ClientInfo.data.name));
			} else if(state == 1){ //active
				buttons.gotoAndStop(2);
				desc = data.stTxt.split("%p%").join(Utils.capitalize(ClientInfo.data.name));
			}  else if(state == 2){ //complete
				if(!isViewingLog){
					buttons.gotoAndStop(3);
					desc = data.enTxt.split("%p%").join(Utils.capitalize(ClientInfo.data.name));
				} else {
					buttons.gotoAndStop(2);
					desc = data.stTxt.split("%p%").join(Utils.capitalize(ClientInfo.data.name));
				}
			}
			
			txtQuestDescription.text = desc;
			txtQuestName.text = data.name;
			viewingQuest = data.id;
			this.visible = true;
		}
		public function displayQuestList(data:Object){
			if(data != null){
				listData = data;
			}
			if(listData != null){
				this.visible = false;
				gotoAndStop("List");
				for(var i:int = 0; i < listData.length; i++){
					var slot:QuestLogSlot = new QuestLogSlot();
					slot.id = Number(listData[i][0]);
					slot.txtName.text = listData[i][1];
					slot.y = (slot.height + 12) * listHolder.numChildren;
					
					listHolder.addChild(slot);
				}
				this.visible = true;
			} else {
				UI.instance.closeWindows();
			}
		}
		public function questAcceptResponse(id:int, success:Boolean){
			if(!success){
				Chatbox.instance.postError("Error Accepting Quest!");
				if(listData != null){
					displayQuestList(listData);
				}
				return;
			}
			if(listData != null){
				displayQuestList(listData);
			}
			ClientInfo.data.addQuestToLog(id);
			
		}
		
		public function displayQuestLog(){
			var logData:Object = ClientInfo.data.getQuestLog();
			this.visible = false;
			gotoAndStop("List");
			for(var i:int = 0; i < logData.length; i++){
				var slot:QuestLogSlot = new QuestLogSlot();
				slot.id = Number(logData[i].id);
				slot.txtName.text = logData[i].name;
				slot.y = (slot.height + 12) * listHolder.numChildren;
				
				listHolder.addChild(slot);
			}
			isViewingLog = true;
			this.visible = true;
		}
		
		
	}
}
