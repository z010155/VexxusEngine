package  {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	
	public class Chatbox extends MovieClip {
		
		private static var _instance:Chatbox;
		private var lastInput:String;
		private var lastWhisperOwner:String;
		public function Chatbox() {
			if(_instance){
				throw new Error("Server: Called illegal instanciation of singleton! Use instance()");
			}
			_instance = this;
			txtChat.text = "";
			//this.txtChat.mouseEnabled = false;
			this.mouseEnabled = false;
			this.txtInput.addEventListener(FocusEvent.FOCUS_IN, onFocused);
			this.txtInput.addEventListener(FocusEvent.FOCUS_OUT, lostFocus);
			this.txtInput.addEventListener(FocusEvent.FOCUS_OUT, lostFocus);
			this.txtChat.addEventListener(TextEvent.LINK, linkClickHandler);
			Main.STAGE.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
			this.addEventListener(MouseEvent.CLICK, clickH);
		}
		public function destroy(){
			this.txtInput.removeEventListener(FocusEvent.FOCUS_IN, onFocused);
			this.txtInput.removeEventListener(FocusEvent.FOCUS_OUT, lostFocus);
			this.txtChat.removeEventListener(TextEvent.LINK, linkClickHandler);
			Main.STAGE.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);
			this.removeEventListener(MouseEvent.CLICK, clickH);
			_instance = null;
		}
		private function clickH(e:MouseEvent){
			switch(e.target.name){
				case 'btnChat':
				this.txtChat.visible = !this.txtChat.visible;
				break;
				case 'btnToggleLinks':
				this.txtChat.mouseEnabled = !this.txtChat.mouseEnabled;
				break;
			}
		}
		private function onFocused(e:FocusEvent){
			World.instance.cancelMoving();
			//this.txtChat.mouseEnabled = true;
		}
		private function lostFocus(e:FocusEvent){
			//this.txtChat.mouseEnabled = false;
			//this.txtInput.text = "";
		}
		private function linkClickHandler(e:TextEvent){
			var cmd:String = e.text.split(":", 1)[0];
			var param:String = e.text.replace(cmd + ":", "");
			switch(cmd){
				case 'user':
					UI.instance.showClickMenu(param, clickMenuHandler, ["Whisper", "Cancel"]);
				break;
			}
		}
		private function clickMenuHandler(e:String, data:String){
			switch(e){
				case 'Whisper':
					whisperText(data)
				break;
			}
		}
		public function onKeyPress(e:KeyboardEvent){
			if(e.keyCode == Keyboard.ENTER){
				if(Main.STAGE.stage.focus == this.txtInput){ 
					var msg:String = this.txtInput.text;
					if(/\S/.test(msg)){
						lastInput = msg;
						if(msg.split("")[0] == "/"){
							handleChatCommand(msg);
						} else {
							Server.instance.sendChatMessage(msg);
						}
						Main.STAGE.stage.focus = Main.STAGE;
						this.txtInput.text = "";
					} else {
						Main.STAGE.stage.focus = Main.STAGE;
					}
				} else {
					Main.STAGE.stage.focus = this.txtInput;
					this.txtInput.text = "";
				}
			}
			if(e.keyCode == Keyboard.R){
				if(lastWhisperOwner != null && Main.STAGE.stage.focus != this.txtInput){
					whisperText(lastWhisperOwner);
				}
			}
			if(e.keyCode == Keyboard.SPACE){
				if(lastWhisperOwner != null && this.txtInput.text == "/r "){
					whisperText(lastWhisperOwner);
				}
			}
			if(e.keyCode == Keyboard.UP){
				if(lastInput != null && Main.STAGE.stage.focus == this.txtInput){
					this.txtInput.text = lastInput;
					this.txtInput.setSelection(this.txtInput.text.length,this.txtInput.text.length);
				}
			}
			if(e.keyCode == Keyboard.SLASH){
				if(Main.STAGE.stage.focus != this.txtInput){
					this.txtInput.text = "/";
					Main.STAGE.stage.focus = this.txtInput;
					this.txtInput.setSelection(txtInput.text.length,txtInput.text.length);
				}
			}
		}
		public function whisperText(to:String){
			Main.STAGE.stage.focus = this.txtInput;
			this.txtInput.text = "/w " + to + ": ";
			this.txtInput.setSelection(this.txtInput.text.length,this.txtInput.text.length);
		}
		public function postMsg(userName:String, msg:String, access:int){
			var finalMsg:String = "";
			var color:String = "#999999";
			switch(access){
				case 2:
				color = "#0066CC";
				break;
				case 3:
				color = "#FF9900";
				break;
				case 4:
				color = "#FF3300";
				break;
				case 5:
				color = "#FF9900";
				break;
				case 6:
				color = "#FF0000";
				break;
			}
			if(access < 6){
				finalMsg = "<font color='"+color+"'>[<a href='event:user:"+ userName +"'>" + userName + "</a>]: </font>" + msg;
			} else {
				finalMsg = "<font color='"+color+"'>" + userName + ": " + msg + "</font>";
			}
			txtChat.htmlText += finalMsg + "<br>";
			txtChat.scrollV = txtChat.maxScrollV;
		}
		public static function get instance():Chatbox{
			return _instance;
		}
		public function handleChatCommand(msg:String){
			var obj:Array = [];
			var cmd:String = msg.split(" ", 1)[0].substr(1);
			var param:String = msg.substr(cmd.length + 2);
			var cursorCoords = Math.round(Main.STAGE.stage.mouseX) + "," + Math.round(Main.STAGE.stage.mouseY);
			param = param.replace("cursorcoords", cursorCoords);
			trace(param);
			switch(cmd){
				case 'w':
				case 'whisper':
				case 'pst':
				case 'pm':
				case 'tell':
				case 'message':
					obj = [];
					obj.push(param.split(": ")[0]);
					obj.push(param.replace(obj[0]+": ", ""));
					Server.instance.sendXt("pm", obj, "str");
					postPM(Utils.capitalize(obj[0]), obj[1], "To");
				break;
				case "duel":
					Server.instance.duelTarget();
				break;
		
				case 'rest':
					Server.instance.rest();
				break;
				case 'hascompletedquest':
					obj = [];
					obj.push(Number(param));
					Server.instance.sendXt("hasCQ", obj, "str");
				break;
				case 'roomlist':
					UI.instance.showRoomList();
				break;
				case 'teleport':
					obj = [];
					obj.push(Main.STAGE.stage.mouseX);
					obj.push(Main.STAGE.stage.mouseY);
					if(param != null){
						obj.push(param);
					}
					Server.instance.sendXt("tele", obj, "str");
				break;
				case 'getid':
					if(World.instance.target != null && ClientInfo.data.access > 2){
						postDebug(World.instance.target.id);
					}
				break;
				case 'isplayer':
					if(World.instance.target != null && ClientInfo.data.access > 2){
						postDebug(World.instance.target.isPlayer.toString());
					}
				break;
				
				default:
					Server.instance.sendXt("cCmd", [cmd, param], "str");
				break;
			}
		}
		public function postPM(userName:String, msg:String, prefix:String = "From"){
			if(prefix == "From"){
				lastWhisperOwner = userName;
			}
			txtChat.htmlText += "<font color='#6600FF'>"+prefix+" [<a href='event:user:"+ userName +"'>" + userName + "</a>]: " +msg+"</font></br>";
			txtChat.scrollV = txtChat.maxScrollV;
		}
		public function postError(msg:String){
			txtChat.htmlText += "<b><font color='#FF0000'>"+msg+"</font></b></br>";
			txtChat.scrollV = txtChat.maxScrollV;
		}
		public function postDebug(msg:String){
			txtChat.htmlText += "<b>DEBUG: </b><font color='#FFCC00'>"+msg+"</font></br>";
			txtChat.scrollV = txtChat.maxScrollV;
		}
		public function postServer(msg:String, username:String){
			if(username.toLowerCase() != "server" && username.toLowerCase() != "warning"){
				username = Utils.capitalize(username);
				txtChat.htmlText += "<b><font color='#FFCC00'>[ADMIN] ("+username+"): "+msg+"</font></b></br>";
			} else if(username.toLowerCase() == "warning"){ 
				txtChat.htmlText += "<b><font color='#FF3300'>["+username+"]: "+msg+"</font></b></br>";
			} else {
				txtChat.htmlText += "<b><font color='#006699'>["+username+"]: "+msg+"</font></b></br>";
			}
			txtChat.scrollV = txtChat.maxScrollV;
		}
	}
	
}
