package {

	import flash.display.MovieClip;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import it.gotoandplay.smartfoxserver.SFSEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.LoaderInfo;
	import flash.display.FrameLabel;
	import com.util.File;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import fl.transitions.TweenEvent;
	import flash.system.*;
	import flash.net.SharedObject;
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.media.SoundChannel;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.media.SoundTransform;
	import flash.display.StageDisplayState;


	public class Main extends MovieClip {
		
		public static const BUILD_NUMBER:String = "Alpha Build 0.1.9.8.5";
		public static var BUILD_HASH:String = "48ddd1dd784db04d5afc91e477ccd412";
		public static var STAGE:MovieClip;
		public static var STAGE_WIDTH:Number;
		public static var STAGE_HEIGHT:Number;
		public static var MAX_CHAT_MSG_LENGTH:int = 150;
		public static var AUTO_VOLUME:Number = 0.20;
		public static var game:Game;
		
		public static var assets:Object = {};
		private static var _soundChannel:SoundChannel = new SoundChannel();
		private static var _soundTransform:SoundTransform = new SoundTransform();
		public static var options:SharedObject = SharedObject.getLocal("AzerronLegendsOptions");
		
		public var LOCAL_MODE:Boolean = new RegExp("file://").test(loaderInfo.url);
		public var web:WebLoader;
		
		public var logoClip:MovieClip;
		private var loginUI:MovieClip;
		private var quality:int = 1;
		private var loginData:Object;
		private var username:String;
		private var password:String;
		
		public function Main() {
			//addEventListener(MouseEvent.CLICK, leftClickHandle);
			//var url:String = ExternalInterface.call("window.location.href.toString");
			//if (url.indexOf("localhost") != -1 || url.indexOf("azerron.com") != -1 || url.indexOf("azerron.zapto.org") != -1 || LOCAL_MODE) {
				addEventListener(Event.ADDED_TO_STAGE, init); 
			//}
					
		}
		public function rightClickHandle(e:Event){}
		public function leftClickHandle(e:Event){
			trace(e.target.name);
		}
		
		private function init(e:Event = null){
			removeEventListener(Event.ADDED_TO_STAGE, init); 
			this.tabChildren = false;
			this.tabEnabled = false;
			stage.showDefaultContextMenu = false;
			stage.stageFocusRect = false;
			STAGE = this;
			STAGE_WIDTH = this.width;
			STAGE_HEIGHT = this.height;
			if(LOCAL_MODE){
				web = new WebLoader("localhost/game");
			} else {
				if(this.loaderInfo.url.indexOf("zapto") > -1){
					web = new WebLoader("localhost/game");
				} else {
					web = new WebLoader("localhost/game");
				}
			}
			addEventListener(MouseEvent.RIGHT_CLICK, rightClickHandle);
			//addEventListener(MouseEvent.CLICK, leftClickHandle);
			gotoAndStop("Login");
			initLoginUI();
			LoadingScreen.instance.hide();
		}
		private function initLoginUI(){
			loginUI = new LoginUI();
			if(logoClip == null){
				var logo:File = new File("Gamefiles/UI/Logo2.swf", onLogoC);
				function onLogoC(e:Event){
					logoClip = e.target.content;
					showLogo();
				}
			} else {
				loginUI.logoHolder.alpha = 1;
				loginUI.logoHolder.addChild(logoClip);
			}
			if (options.data.volume != null) {
				masterVolume = options.data.volume;
				if(masterVolume > 0){
					loginUI.muteToggle.gotoAndStop(1);
				} else {
					loginUI.muteToggle.gotoAndStop(2);
				}
			} else {
				masterVolume = Main.AUTO_VOLUME;
			}
			Main.stopSound();
			Main.soundChannel = new Menu_Theme().play();
			activateLoginUI();
		}
		private function keyPressedHandler(e:KeyboardEvent){
			if(e.keyCode == Keyboard.ENTER){
				login();
			}
		}
		private function connectToServer(ip:String, port:int){
			LoadingScreen.instance.show();
			this.removeEventListener(MouseEvent.CLICK, onClick);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyPressedHandler);
			game = new Game();
			game.server.openConnection(username, password, ip, port);
			stopSound();
		}
		private function activateLoginUI(){
			username = null;
			password = null;
			loginData = null;
			if (options.data.username) {
				loginUI.txtUsername.text = options.data.username;
			}
			if (options.data.password) {
				loginUI.txtPassword.text = options.data.password;
			}
			
			
			loginUI.txtBuild.text = Main.BUILD_NUMBER;
			this.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyPressedHandler);
			stage.focus = stage;
			loginUI.x = 480;
			loginUI.y = 275;
			addChild(loginUI);
		}
		private function showLogo(){
			logoClip.alpha = 1;
			//loginUI.logoHolder.alpha = 0;
			loginUI.logoHolder.addChild(logoClip);
			//var alphaTween:Tween = new Tween(loginUI.logoHolder, "alpha", Regular.easeIn, 0, 100, 20, true);
		}
		private function killDisclaimer(){
			loginUI.disclaimer.visible = false;
		}
		public function completeLogout(){
			game = null;
			gotoAndStop("Login");
			initLoginUI();
		}
		
		public function onClick(e:MouseEvent){
			switch(e.target.name){
				case 'disclaimer':
					killDisclaimer();
				break;
				case 'btnLogin':
					login();
				break;
				case 'btnRegister':
					var newRequest:URLRequest = new URLRequest("signup.php");
					navigateToURL(newRequest);
				break;
				case 'btnServer':
					var server:ServerDisplay = e.target.parent as ServerDisplay;
					connectToServer(server.IP, server.Port);
				break;
				
				case 'btnServerSelectLogout':
					gotoAndStop("Login");
					initLoginUI();
				break;
				
				case 'muteToggle':
					toggleMute();
					if(masterVolume > 0){
						loginUI.muteToggle.gotoAndStop(1);
					} else {
						loginUI.muteToggle.gotoAndStop(2);
					}
				break;
				
			}
		}
		private function login(){
			if(this.currentLabel == "Login" && loginUI.txtUsername.length > 1 && loginUI.txtPassword.length > 3){
				web.postPage("login", {username: loginUI.txtUsername.text, password: loginUI.txtPassword.text}, loginComplete);
				username = loginUI.txtUsername.text;
				password = loginUI.txtPassword.text;
				loginUI.gotoAndStop(2);
			}
		}
		private function loginComplete(data:Object){
			if(data.hasOwnProperty("success")){
				if(data.success == "true"){
					loginData = data;
					options.data.username = username;
					options.data.password = password;
					options.flush();
					displayServerSelect();
				} else {
					loginUI.gotoAndStop(1);
					loginUI.txtUsername.text = username;
					loginUI.txtPassword.text = password;
					loginUI.error.gotoAndPlay(2);
					if(data.error == "login_failed"){
						loginUI.error.base.txtError.text = "Incorrect Username/Password!";
					} else if(data.error == "banned"){
						loginUI.error.base.txtError.text = "Your account is banned!";
						LoadingScreen.instance.show();
						LoadingScreen.instance.banned();
					} else {
						loginUI.error.base.txtError.text = "Login Error";
					}
				}
			}
		}
		public function displayServerSelect(onLoginUI:Boolean = true){
			if(onLoginUI){
				removeChild(loginUI);
			} else {
				this.addEventListener(MouseEvent.CLICK, onClick);
			}
			gotoAndStop("Servers");
			var base:MovieClip = server;
			
			
			removeChild(base);
			for(var i:int = 1; i <= Number(loginData.serverCount); i++){
				var newServer:ServerDisplay = new ServerDisplay();
				newServer.x = base.x;
				newServer.y = base.y + (78 * (i - 1));
				newServer.Name = loginData["serverName" + i];
				newServer.IP = loginData["serverIP" + i];
				newServer.Port = loginData["serverPort" + i];
				newServer.icon.gotoAndStop("online");
				serverHolder.addChild(newServer);
			}
		}
		public function setQuality(i:int = 1){
			switch(i){
				case 1:
				stage.quality = StageQuality.HIGH;
				break;
				case 2:
				stage.quality = StageQuality.MEDIUM;
				break;
				case 3:
				stage.quality = StageQuality.LOW;
				break;
			}
			quality = i;
		}
		public static function stopSound(){
			if(Main.soundChannel != null){
				Main.soundChannel.stop();
			}
			Main.soundChannel = null;
		}
		public static function get soundChannel():SoundChannel{
			return _soundChannel;
		}
		public static function set soundChannel(e:*){
			_soundChannel = e;
			if(e != null){
				_soundChannel.soundTransform = _soundTransform;
			}
		}
		
		public static function get masterVolume():Number{
			return _soundTransform.volume;
		}
		public static function set masterVolume(e:Number){
			_soundTransform.volume = e;
			if(soundChannel != null){
				soundChannel.soundTransform = _soundTransform;
			}
			options.data.volume = e;
			options.flush();
		}
		public static function toggleMute(){
			if(masterVolume == 0){
				masterVolume = Main.AUTO_VOLUME;
			} else {
				masterVolume = 0;
			}
		}
		public static function toggleFullscreen(){
			if (Main.STAGE.stage.displayState == StageDisplayState.NORMAL) {
				Main.STAGE.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			} else {
				Main.STAGE.stage.displayState = StageDisplayState.NORMAL;
			}
		}

	}

}