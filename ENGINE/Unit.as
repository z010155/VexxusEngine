package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import com.util.File;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.Timer;
	
	public class Unit extends MovieClip {
		
		public var isPlayer:Boolean = false;
		
		public var _runAnimation:String = "Run";
		public var _idleAnimation:String = "Idle";
		private var _name:String;
		private var _id:int;
		private var _gender:int;
		private var _access:int = 0;
		private var _model:MovieClip;
		private var actionQueue:Array;
		private var curActionEvent:String;
		private var curActionTarget:Object;
		private var curActionName:String;
		
		private var hp:int;
		private var maxHp:int;
		private var nextWepLinkage:String;
		private var nextWepFile:String;
		private var nextArmorLinkage:String;
		private var nextArmorFile:String;
		
		private var moveSpeed:Number = 7;
		private var portraitClip:MovieClip;
		private var unstickTimer:Timer = new Timer(2000);
		private var clickArea:MovieClip = new ClickArea();
		
		public var actionInProgress:Boolean;
		public var autoIdle:Boolean = false;
		public var currentAnimation:String = "Idle";
		public var stopMoving:Boolean = false;
		public var targetPoint:Point;
		public var isMoving:Boolean = false;
		public var level:int = 1;
		public var type:int = 0;
		public var distanceFromPlayer:Number;
		public var inCombat:Boolean = false;
		
		
		
		public function Unit(health:int, maxHealth:int) {
			this.visible = false;
			this.feet.visible = false;
			this.mouseEnabled = false;
			this.header.mouseEnabled = false;
			this.header.mouseChildren = false;
			hp = health;
			maxHp = maxHealth;
			if(hp != maxHp){
				this.health = hp;
			}
			actionQueue = [];
			unstickTimer.addEventListener(TimerEvent.TIMER, unstickQueue);
			this.makeInteractive();
		}
		public function destroy(){
			makeNonInteractive()
			if(model != null){
				killMove(false);
				unstickTimer.removeEventListener(TimerEvent.TIMER, unstickQueue);
			}
			if(World.instance.target == this){
				World.instance.target = null;
			}
		}
		public function makeNonInteractive(){
			if(this.hasEventListener(MouseEvent.CLICK)){
				this.removeEventListener(MouseEvent.CLICK, handleClick);
			}
		}
		public function makeInteractive(){
			if(!this.hasEventListener(MouseEvent.CLICK)){
				this.addEventListener(MouseEvent.CLICK, handleClick);
			}
		}
		private function handleClick(e:MouseEvent){
			if(World.instance.target != this){
				World.instance.target = this;
			}
		}
		public function set model(e:MovieClip){
			if(_model == null){
				_model = e;
				this.addChild(model);
				this.addChild(clickArea);
				this.visible = true;
			}
		}
		public function get model(){
			return _model;
		}
		public function set portrait(e:MovieClip){
			portraitClip = e;
		}
		public function get portrait():MovieClip {
			return portraitClip;
		}
		public function set gender(e:int){
			_gender = e;
			var asset:Class;
			if(_gender == 0){
				asset = Main.assets["template"].getDefinition("TemplateBaseMale") as Class;
			} else {
				asset = Main.assets["template"].getDefinition("TemplateBaseFemale") as Class;
			}
			model = new asset();
			model.shield.visible = false;
			Utils.emptyObject(model.weapon);
			this.portrait = Utils.duplicateMovieclip(model);
			this.portrait.scaleX = 1;
			this.portrait.scaleY = 1;
			this.portrait.x = 0;
			this.portrait.y = 275;
			
			
			
			
		}
		public function set speed(e:int){
			moveSpeed = e;
		}
		public function get speed():int{
			return moveSpeed;
		}
		public function set health(e:int){
			if(e < 1){
				e = 0;
			}
			if(e > maxHealth){
				e = maxHealth;
			}
			hp = e;
			this.dispatchEvent(new Event("Update"));
		}
		public function get health():int{
			return hp;
		}
		public function get maxHealth():int{
			return maxHp;
		}
		public function set maxHealth(e:int){
			maxHp = e;
		}
		public function set access(e:int){
			this._access = e;
		}
		public function get access(){
			return this._access;
		}
		public function set displayName(e:String){
			_name = Utils.capitalize(e);
			if(access >= 5){
				this.header.txtName.htmlText = "<font color='#FF3300'>" + _name + "</font>";
			} else if(access >= 3){
				this.header.txtName.htmlText = "<font color='#FF9900'>" + _name + "</font>";
			} else {
				this.header.txtName.htmlText = _name;
			}
		}
		public function get displayName():String{
			return _name;
		}
		public function set pos(e:MovieClip){
			this.x = e.x;
			this.y = e.y;
		}
		public function set point(e:Point){
			this.killMove(true);
			this.x = e.x;
			this.y = e.y;
		}
		public function set id(e:int){
			_id = e;
		}
		public function get id(){
			return _id;
		}
		public function set size(e:int){
			var i:Number = e / 100;
			model.scaleX = i;
			model.scaleY = i;
			shadow.scaleX = i * 3;
			shadow.scaleY = i * 3;
			this.header.y = -model.height - 15;
			clickArea.width = model.width / 2;
			clickArea.height = model.height;
		}
		public function get size(){
			return Math.abs(model.scaleY);
		}
		public function set direction(side:*) {
			if (side == "right" || side == 0) {
				model.scaleX = Math.abs(model.scaleX);
			} else if (side == "left" || side == 1) {
				model.scaleX = -Math.abs(model.scaleX);
			}
		}
		public function set weapon(wep:MovieClip) {
			while(model.weapon.numChildren){
				model.weapon.removeChildAt(0);
			}
			model.weapon.addChild(wep);
		}
		public function get dirAsInt():int{
			if (model.scaleX == Math.abs(model.scaleX)) {
				return 0;
			} else if (model.scaleX == -Math.abs(model.scaleX)) {
				return 1;
			}
			return 2;
		}
		public function getMeleeRangePos(target:Unit):Point{
			var p:Point = new Point();
			
			p.y = this.y - (Math.random() * 30);
			if(target.x > this.x){
				p.x = this.x + 35 + (Math.random() * 30);;
			} else {
				p.x = this.x - 35 - (Math.random() * 30);
			}
			
			
			return p;
		}
		public function loadWeapon(url:String, linkage:String){
			if(url.length > 3 && linkage.length > 3){
				if(isClient){
					ClientInfo.data.weaponData = url + "," + linkage;
				}
				nextWepLinkage = linkage;
				nextWepFile = url;
				var aD:ApplicationDomain = World.instance.getCachedWeapon(url);
				if(aD == null){
					var newFile:File = new File(Game.WEAPON_URL + url, weaponLoadComplete, null, weaponLoadFailure);
				} else {
					trace("cached weapon");
					displayWeapon(aD);
				}
			}
		}
		private function weaponLoadComplete(e:Event){
			World.instance.cacheWeapon(nextWepFile, e.target.applicationDomain);
			
			Utils.emptyObject(model.weapon);
			displayWeapon(e.target.applicationDomain);
		}
		public function displayWeapon(weaponDomain:ApplicationDomain, useClientData:Boolean = false){
			var linkage:String = nextWepLinkage;
			if(useClientData){
				linkage = ClientInfo.data.weaponLinkage;
			}
			var assetClass:Class = weaponDomain.getDefinition(linkage) as Class
			var newWeapon:MovieClip = new assetClass() as MovieClip;
			if(isClient){
				ClientInfo.data.weaponAD = weaponDomain;
			}
			weapon = newWeapon;
		}
		public function loadArmor(url:String, linkage:String){
			if(url.length > 3 && linkage.length > 3){
				if(isClient){
					ClientInfo.data.armorData = url + "," + linkage;
				}
				nextArmorLinkage = linkage;
				nextArmorFile = url;
				var aD:ApplicationDomain = World.instance.getCachedArmor(genderToString + url);
				if(isClient){
					ClientInfo.data.armorAD = aD;
				}
				if(aD == null){
					var newFile:File = new File(Game.ARMOR_URL + genderToString.toLowerCase() + "/" + url, armorLoadComplete, null, armorLoadFailure);
				} else {
					displayArmor(aD);
				}
			}
		}
		private function armorLoadFailure(e:Event){
			trace("Armor Load Failed!");
		}
		private function weaponLoadFailure(e:Event){
			trace("Weapon Load Failed!");
		}
		private function armorLoadComplete(e:Event){
			var armorDomain:ApplicationDomain = e.target.applicationDomain;
			World.instance.cacheArmor(genderToString + nextArmorFile, armorDomain);
			displayArmor(armorDomain);
		}
		public function displayArmor(armorDomain:ApplicationDomain, useClientData:Boolean = false, forceLinkage:String = ""){
			var linkage:String = nextArmorLinkage;
			if(forceLinkage.length > 0){
				linkage = forceLinkage;
			}
			if(useClientData){
				linkage = ClientInfo.data.armorLinkage;
				
			}
			if(isClient){
				ClientInfo.data.armorAD = armorDomain;
			}
			setArmorItem("shoulder", "Shoulder", armorDomain, linkage);
			setArmorItem("shoulderback", "BackShoulder", armorDomain, linkage);
			
			setArmorItem("footback", "BackFoot", armorDomain, linkage);
			setArmorItem("forearmback", "BackForearm", armorDomain, linkage);
			setArmorItem("handback", "BackHand", armorDomain, linkage);
			setArmorItem("footfront", "FootFront", armorDomain, linkage);
			setArmorItem("forearm", "Forearm", armorDomain, linkage);
			setArmorItem("hand", "Hand", armorDomain, linkage);
			setArmorItem("head", "Head", armorDomain, linkage);
			setArmorItem("shin", "Shin", armorDomain, linkage);
			setArmorItem("shinback", "BackShin", armorDomain, linkage);
			setArmorItem("thigh", "Thigh", armorDomain, linkage);
			setArmorItem("torso", "Torso", armorDomain, linkage);
			setArmorItem("thighback", "BackThigh", armorDomain, linkage);
			setArmorItem("foot", "Foot", armorDomain, linkage);

			/*
			if(this.id == ClientInfo.data.id){
				UI.instance.showPlayerFrame();
			}
			if(World.instance.target == this){
				UI.instance.showTargetFrame();
			}
			*/
		}
		private function setArmorItem(instanceName:String, pieceStr:String, armorDomain:ApplicationDomain, linkage:String){			
			if(armorDomain.hasDefinition(genderToString + pieceStr + linkage)){
				var assetClass:Class = armorDomain.getDefinition(genderToString + pieceStr + linkage) as Class;
				var armorModel:MovieClip = new assetClass() as MovieClip;
				var armorModel2:MovieClip = new assetClass() as MovieClip;
				if(model.hasOwnProperty(instanceName) && armorModel != null){
					Utils.emptyObject(model[instanceName]);
					MovieClip(model[instanceName]).addChild(armorModel);
					
					Utils.emptyObject(portrait[instanceName]);
					MovieClip(portrait[instanceName]).addChild(armorModel2);
				}
			}
		}
		public function playIdle() {
			if (model.currentLabel != _idleAnimation) {
				currentAnimation = _idleAnimation;
				model.gotoAndStop(_idleAnimation);
			}
		}
		public function get isClient():Boolean{
			return this.id == ClientInfo.data.id;
		}
		public function get genderToString():String{
			var gender:String = "M";
			if(this._gender != 0){
				gender = "F";
			}
			return gender;
		}
		public function playAnim(anim:String, force:Boolean = false) {
			if (model.currentLabel != anim || force) {
				if(Utils.frameLabelExists(model, anim)){
					currentAnimation = anim;
					model.gotoAndPlay(anim);
				}
			}
		}
		
		
		public function playRun() {
			if (currentAnimation != _runAnimation) {
				currentAnimation = _runAnimation;
				model.gotoAndPlay(_runAnimation);
			}
		}
	
		public function gotoAnim(label:String, gotoLastFrame:Boolean = false){
			currentAnimation = label;
			if(!gotoLastFrame){
				model.gotoAndStop(label);
			} else {
				model.gotoAndStop(label);
				for(var i:int = 0; i < 45; i++){
					model.gotoAndStop(model.currentFrame + 1);
					if(model.currentLabel != label){
						model.gotoAndStop(model.currentFrame - 1);
						return;
					}
				}
			}
		}

		public function moveTo(newX:Number, newY:Number) {
			killMove(false, true);
			targetPoint = new Point(newX,newY);
			isMoving = true;
			addEventListener(Event.ENTER_FRAME, moveThis);
			if (newX > this.x) {
				direction = "right";
			} else {
				direction = "left";
			}
			playRun();
		}
		public function killMove(autoIdle:Boolean = false, preMoveKill:Boolean = false) {
			if (hasEventListener(Event.ENTER_FRAME)) {
				try {
					removeEventListener(Event.ENTER_FRAME, moveThis);
				} catch (e:Error) {}
			}
			if(autoIdle || this.autoIdle){
				playIdle();
				if(!preMoveKill){
					this.autoIdle = false;
				}
			}
			
			isMoving = false;
		}
		private function moveThis(e:Event):void {
			var speed = this.moveSpeed;
			var target = this.targetPoint;
			var diff:Point = target.subtract(new Point(this.x,this.y));
			var dist = diff.length;
			if ((dist <= speed)) {
				this.x = targetPoint.x;
				this.y = targetPoint.y;
				killMove();
				dispatchEvent(new Event("MoveComplete"));
			} else {
				diff.normalize(1);
				this.x +=  Math.round(diff.x * speed);
				this.y +=  Math.round(diff.y * speed);
				if (stopMoving) {
					killMove();
				}
			}
		}
		public function quickTween(x:Number, y:Number, time:Number = .12){
			var t:Tween = new Tween(this, "x", None.easeNone, this.x, x, time, true);
			var a:Tween = new Tween(this, "y", None.easeNone, this.y, y, time, true);
		}
		public function fadeOut(){
			var t:Tween = new Tween(this, "alpha", None.easeNone, 1, 0, 1, true);
		}
		public function lookAt(mc:MovieClip){
			if(mc != this){
				if(mc.x > this.x){
					direction = "right";
				} else {
					direction = "left";
				}
			}
		}
		public function damage(amount:int, isCrit:Boolean = false){
			if(isPlayer == false && inCombat == false){
				return;
			}
			health -= amount;
			displayDamage(amount, isCrit);
		}
		public function heal(amount:int){
			health += amount;
			displayHeal(amount);
		}
		public function queueAction(obj:Object){
			if(this.health > 0){
				actionQueue.push(obj);
				if(!actionInProgress){
					nextActionInQueue();
				}
			}
		}
		public function displayDamage(dmg:int, isCrit:Boolean = false){
			if(dmg > 0){
				var display:MovieClip;
				if(isCrit){
					display = new DamageDisplayCrit();
				} else {
					display = new DamageDisplay();
				}
				display.base.txtNumber.text = dmg.toString();
				display.y = this.header.y;
				Utils.markForDeletion(display);
				addChild(display);
			} else {
				trace("Damaged for 0");
			}
		}
		public function displayHeal(dmg:int){
			if(dmg > 0){
				var display:MovieClip = new HealDisplay();
				display.base.txtNumber.text = dmg.toString();
				display.y = this.header.y;
				Utils.markForDeletion(display);
				addChild(display);
			} else {
				trace("Healed for 0");
			}
		}
		public function displayExp(xp:int){
			if(xp > 0){
				var display:MovieClip = new ExpDisplay();
				display.base.txtNumber.text = xp.toString() + "xp";
				display.y = this.header.y + 10;
				Utils.markForDeletion(display);
				addChild(display);
			}
		}
		public function displayGold(gold:int){
			if(gold > 0){
				var display:MovieClip = new GoldDisplay();
				display.base.txtNumber.text = gold.toString() + "gold";
				display.y = this.header.y + 25;
				Utils.markForDeletion(display);
				addChild(display);
			}
		}
		public function displayLevelup(){
			var display:MovieClip = new LevelUpDisplay();
			display.scaleX = Math.abs(model.scaleX)
			display.scaleY = Math.abs(model.scaleY)
			Utils.markForDeletion(display);
			addChild(display);
		}
		public function nextActionInQueue(e:* = null){
			if(curActionEvent != null && curActionTarget.hasEventListener(curActionEvent)){
				curActionTarget.removeEventListener(curActionEvent, nextActionInQueue);
				curActionTarget = null;
				curActionEvent = null;
			}
			if(actionQueue.length > 0){
				var action:Object = actionQueue[0];
				actionQueue.shift();
				actionInProgress = true;
				unstickTimer.stop();
				unstickTimer.reset();
				unstickTimer.start();
				
				var pad:MovieClip;
				var point:Point;
				curActionName = action.name;

				switch(action.name){
					case 'aiAttack':
						if(Utils.getDistance(action.target, this) > Game.MELEE_RANGE){
							point = action.target.getMeleeRangePos(this);
							this.quickTween(point.x, point.y);
						}
						lookAt(action.target);
						playAnim(Game.ENEMY_ANIMATION_LIBRARY[action.animation]);
						curActionEvent = "AttackHit";
						curActionTarget = model;
						curActionTarget.addEventListener(curActionEvent, nextActionInQueue, false, 0, true);
					break;
					case 'aiReturnToSpawn':
						if(World.instance.enemies[String(id)].pad.indexOf(",") == -1){
							pad = MovieClip(World.instance.map.getChildByName("mobPad" + World.instance.enemies[String(id)].pad));
						} else {
							pad = new MovieClip();
							pad.x = Number(World.instance.enemies[String(id)].pad.split(",")[0]);
							pad.y = Number(World.instance.enemies[String(id)].pad.split(",")[1]);
						}
						if(pad != null){
							autoIdle = true;
							moveTo(pad.x, pad.y);
							curActionEvent = "MoveComplete";
							curActionTarget = this;
							curActionTarget.addEventListener(curActionEvent, nextActionInQueue, false, 0, true);

						} else {
							nextActionInQueue();
						}
					break;
				}
			} else {
				actionInProgress = false;
			}
		}
		public function unstickQueue(e:TimerEvent = null){
			if(actionInProgress){
				nextActionInQueue();
			} else {
				unstickTimer.stop();
				unstickTimer.reset();
			}
		}
		public function resetActionQueue(){
			actionQueue = [];
			actionInProgress = false;
			if(curActionEvent != null && curActionTarget.hasEventListener(curActionEvent)){
				curActionTarget.removeEventListener(curActionEvent, nextActionInQueue);
				curActionTarget = null;
				curActionEvent = null;
				curActionName = null;
			}
		}
		public function playDeathAnimation(animate:Boolean = true){
			if(this.isPlayer == false){
				Utils.delayFunction(2.5, fadeOut);
			}
			if(animate){
				playAnim("Death");
			} else {
				gotoAnim("Death", true);
			}
		}
		public function displaySpellEffect(effect:MovieClip, isProjectile:Boolean = false, caster:Unit = null){
			if(effect != null){
				Utils.markForDeletion(effect);
				effect.scaleX = this.model.scaleX;
				effect.scaleY = this.model.scaleY;
				if(isProjectile){
					effect.scaleX = caster.model.scaleX;
					effect.scaleY = this.model.scaleY;
					var proj:Projectile = new Projectile(effect, caster, this, 12);
					World.instance.cell.addChild(proj);
				} else {
					addChild(effect);
				}
			} else {
				trace("Null Spell Effect Error");
			}
		}
		public function say(message:String){
			var b:SpeechBubble = this.header.speechBubble as SpeechBubble;
			if(this.access > 3){
				b.showAsAdmin();
			}
			b.show(message);
		}
	}
}
