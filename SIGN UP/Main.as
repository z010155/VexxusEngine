package  {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class Main extends MovieClip {
		
		public var intGender:Number = 0;
		public var buttonGlow:GlowFilter = new GlowFilter();
		public var email:String;
		public var web:WebLoader;
		public var LOCAL_MODE:Boolean = new RegExp("file://").test(loaderInfo.url);

		
		public function Main() {
			if(LOCAL_MODE){
				web = new WebLoader("localhost/AzerronStaffTest");
			} else {
				if(this.loaderInfo.url.indexOf("zapto") > -1){
					web = new WebLoader("azerron.zapto.org/AzerronStaffTest");
				} else {
					web = new WebLoader("azerron.com/game");
				}
			}
			if (this.loaderInfo.url.indexOf("localhost") > -1 || this.loaderInfo.url.indexOf("azerron.") > -1 || LOCAL_MODE) {
				UI.gotoAndStop(1);
			} else {
				UI.gotoAndStop(2);
			}
			
			strEmail.text = "";
			strUsername.text = "";
			strPassword.text = "";
			strPasswordRepeat.text = "";
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		public function clickHandler(e:MouseEvent){
			switch(e.target.name){
				case 'btnMale':
					btnMale.filters = [buttonGlow];
					btnFemale.filters = [];
					intGender = 1;
				break;
				case 'btnPlay':
					var newRequest:URLRequest = new URLRequest("/game");
					navigateToURL(newRequest);
				break;
				case 'btnFemale':
					btnFemale.filters = [buttonGlow];
					btnMale.filters = [];
					intGender = 2;
				break;
				case 'btnRegister':
					registerAccount();
				break;
			}
		}
		
		public function registerAccount(){
			email = strEmail.text;
			if(strUsername.text == "" || strPassword.text == "" || strPasswordRepeat.text == ""){
				trace("empty field found");
				showError("Please fill out all fields!");
				return;
			}
			if(strEmail.text.length < 6){
				trace("email must be at least 6 characters");
				showError("Email must be at least 6 characters!");
				return;
			}
			if(strUsername.text.length < 3){
				trace("username must be at least 3 characters");
				showError("Username must be at least 3 characters!");
				return;
			}
			if(strPassword.text.length < 6){
				trace("password must be at least 6 characters");
				showError("Password must be at least 6 characters!");
				return;
			}
			if(intGender == 0){
				trace("no gender selected");
				showError("Choose a Gender!");
				return;
			}
			if(strPassword.text != strPasswordRepeat.text){
				trace("passwords don't match");
				showError("Passwords don't match!");
				return;
			}
			if(email == "" || email.indexOf("@") == -1){
				trace("invalid email address");
				showError("Invalid email address.");
				return
			}

			var data:Object = {};
			data.email = email;
			data.username = strUsername.text;
			data.password = strPassword.text;
			data.gender = intGender - 1;
			
			web.postPage("register", data, registerResponse);
			
			UI.gotoAndStop(2);
		}

		private function registerResponse(data:Object){
			if(data.hasOwnProperty("success")){
				if(data.success == "true"){
					UI.gotoAndStop(3);
				} else {
					UI.gotoAndStop(1);
					trace(data.error);
					if(data.error == "email_taken"){
						showError("That email already exists!");
					} else if(data.error == "name_taken"){
						showError("That name already exists!");
					} else if(data.error == "too_simple"){
						showError("That password is too simple!");
					} else {
						showError("Error creating account.");
					}
				}
			}
		}
		private function showError(msg:String){
			error.gotoAndPlay(2);
			error.base.txtError.text = msg;
		}
	}
	
}
