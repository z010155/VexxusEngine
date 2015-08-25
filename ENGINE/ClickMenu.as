﻿package  {		import flash.display.MovieClip;	import flash.events.Event;	import flash.events.MouseEvent;			public class ClickMenu extends MovieClip {				private var func:Function;		private var data:String; 						public function ClickMenu(x:Number, y:Number, options:Array, func:Function, data:String) {			for(var i:int = 0; i < options.length; i++){				var opt:MovieClip = new ClickMenuOption();				opt.y = opt.height * (this.numChildren - 1);				opt.txtName.text = options[i];				opt.txtName.mouseEnabled = false;				addChild(opt);			}			this.func = func;			this.data = data;			this.bg.width = this.width + 8;			this.bg.height = this.height + 8;			this.bg.x -= 4;			this.bg.y -= 4;			this.y = y - 1;			if(x + this.width + 10 > Main.STAGE_WIDTH){				this.x = x - this.width + 8;			}else{				this.x = x - 1;			}			if(y + this.height + 10 > Main.STAGE_HEIGHT){				this.y = y - this.height + 8;			}else{				this.y = y - 1;			}			UI.instance.addChild(this);			this.bg.gotoAndPlay(2);			Utils.delayFunction(0.300, activate);		}		public function activate(){			this.bg.addEventListener(MouseEvent.MOUSE_OUT, destroy);			this.addEventListener(MouseEvent.CLICK, clickH);		}		private function clickH(e:MouseEvent){			if(e.target.name == "btnOption"){				var particle:MovieClip = new ClickMenuOptionOut();				particle.x = e.target.parent.x + this.x;				particle.y = e.target.parent.y + this.y;				particle.base.txtName.text = e.target.parent.txtName.text;				particle.mouseEnabled = false;				particle.mouseChildren = false;				particle.base.mouseEnabled = false;				particle.base.mouseChildren = false;				particle.base.txtName.mouseEnabled = false;				UI.instance.addChild(particle);								func(e.target.parent.txtName.text, data);				destroy();			}		}		public function destroy(e:Event = null){			this.bg.removeEventListener(MouseEvent.MOUSE_OUT, destroy);			this.removeEventListener(MouseEvent.CLICK, clickH);						func = null;			data = null;			UI.instance.removeChild(this);			UI.instance.destroyClickMenu();		}			}	}