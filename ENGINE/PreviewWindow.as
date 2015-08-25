package  {
	
	import flash.display.MovieClip;
	import com.util.File;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	
	public class PreviewWindow extends MovieClip {
		
		private const newX:int = 234 / 2;
		private const newY:int = 348 / 2 + 65;
		
		private var linkage:String;
		private var type:String;
		
		public function PreviewWindow() {
			this.visible = false;
			this.x = 135.85;
			this.y = 79.05;
		}
		public function show(file:String, type:String){
			Utils.emptyObject(holder);
			holder.x = -117;
			holder.y = 35;
			this.visible = true;
			var loadingFlame:MovieClip = new LoadingDisplay();
			loadingFlame.x = newX;
			loadingFlame.y = newY;
			holder.addChild(loadingFlame);
			
			var url:String = file.split(",")[0];
			if(type == "1,0"){
				url = Game.WEAPON_URL + url;
			} else if(type == "1,1"){
				url = Game.ARMOR_URL + World.instance.playerUnit.genderToString.toLowerCase() + "/" +  url;
			} else {
				return;
			}
			this.type = type;
			linkage = file.split(",")[1];
			var newFile:File = new File(url, fileLoadComplete, null, fileLoadFailed);
			
			
		}
		public function close(){
			Utils.emptyObject(holder);
			visible = false;
		}
		private function fileLoadComplete(e:Event){
			Utils.emptyObject(holder);
			var appDomain:ApplicationDomain = e.target.applicationDomain;
			
			if(type == "1,0"){
				var assetClass:Class = appDomain.getDefinition(linkage) as Class
				var newModel:MovieClip = new assetClass() as MovieClip;
				newModel.x = newX;
				newModel.y = newY;
				newModel.mouseChildren = false;
				holder.addChild(newModel);
			} else {
				var previewUnit:Unit = new Unit(1,1);
				previewUnit.gender = ClientInfo.data.gender;
				previewUnit.makeNonInteractive();
				
				previewUnit.displayArmor(appDomain, false, linkage);
				previewUnit.x = 130;
				previewUnit.y = 315;
				previewUnit.size = 100;
				previewUnit.displayName = "";
				previewUnit.mouseChildren = false;
				holder.addChild(previewUnit);
			}
		}
		private function fileLoadFailed(){
			Utils.emptyObject(holder);
			var err:MovieClip = new ErrorDisplay();
			err.x = newX;
			err.y = newY - 50;
			holder.addChild(err);
			trace("File load failed");
		}
	}
	
}
