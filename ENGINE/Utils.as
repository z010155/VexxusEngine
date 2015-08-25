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
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;

	public class Utils {

		public function Utils() {
			// constructor code
		}
		public static function emptyObject(obj:MovieClip){
			while(obj.numChildren){
				obj.removeChildAt(0);
			}
		}
		public static function frameLabelExists(movieClip:MovieClip, labelName:String) {
			var i:int;
			var k:int = movieClip.currentLabels.length;
			for (i; i < k; ++i) {
				var label:FrameLabel = movieClip.currentLabels[i];
				if (label.name == labelName) {
					return true;
				}
			}
			return false;
		}
		public static function getProperties(obj:*):String {
			var str:String = "";
			for (var id:String in obj) {
				var value:Object = obj[id];
				str +=  id + " = " + value + ", ";
			}
			return str;
		}
		public static function capitalize(str:String):String {
			if(str != null){
			var firstChar:String = str.substr(0,1);
			var restOfString:String = str.substr(1,str.length);

			return firstChar.toUpperCase()+restOfString.toLowerCase();
			}
			return "";
		}
		public static function strReplace(str:String, search:String, replace:String):String {
			return str.split(search).join(replace);
		}

		public static function formatNumber(number:Number):String {
			var numString:String = number.toString();
			var result:String = '';
			while (numString.length > 3) {
				var chunk:String = numString.substr(-3);
				numString = numString.substr(0,numString.length - 3);
				result = ',' + chunk + result;
			}

			if (numString.length > 0) {
				result = numString + result;
			}

			return result;
		}
		public static function getDistance(pObj1:MovieClip,pObj2:MovieClip):Number {
			var distX:Number = pObj1.x - pObj2.x;
			var distY:Number = pObj1.y - pObj2.y;
			return Math.sqrt(distX * distX + distY * distY);
		}
		public static function getIconAsset(name:String):MovieClip {
			var iconClass:Class;
			var iconMC:MovieClip;
			if (Main.assets["icons_common"] != null && Main.assets["icons_common"].hasDefinition(name)) {
				iconClass = Main.assets["icons_common"].getDefinition(name) as Class;
				iconMC = new iconClass();
				return iconMC;
			} else if (Main.assets["icons_abilities"] != null && Main.assets["icons_abilities"].hasDefinition(name)) {
				iconClass = Main.assets["icons_abilities"].getDefinition(name) as Class;
				iconMC = new iconClass();
				return iconMC;
			}
			return null;
		}
		public static function getSpellEffectAsset(id:String):MovieClip {
			var iconClass:Class;
			var iconMC:MovieClip;
			var name:String;
			if(Main.assets["spell_effects_file"]["index"][id.toString()][0] != null){
				name = Main.assets["spell_effects_file"]["index"][id.toString()][0];
				if (Main.assets["spell_effects"].hasDefinition(name)) {
					iconClass = Main.assets["spell_effects"].getDefinition(name) as Class;
					iconMC = new iconClass();
					return iconMC;
				}
			}
			return null;
		}
		public static function spellEffectIsProjectile(id:String) {
			if(Main.assets["spell_effects_file"]["index"][id.toString()][1] != null){
				if(Main.assets["spell_effects_file"]["index"][id.toString()][1] == true){
					return true;
				}
			}
			return false;
		}
		
		public static function getAssetFromApplicationDomain(appDomain:ApplicationDomain, linkage:String):MovieClip {
			var newClass = appDomain.getDefinition(linkage) as Class;
			return new newClass() as MovieClip;;
		}
		public static function dumpObject(o:Object) {
			trace('\n');
			for (var val:* in o) {
				trace('   [' + typeof(o[val]) + '] ' + val + ' => ' + o[val]);
			}
			trace('\n');
		}
		public static function rnd(min:int, max:int):int{
    		return (Math.floor(Math.random() * (max - min + 1)) + min);
		}
		public static function markForDeletion(obj:Object){
			obj.addEventListener("DeleteThis", removeObject, 0, false, true);
		}
		public static function removeObject(e:Event){
			e.target.removeEventListener("DeleteThis", removeObject);
			e.target.parent.removeChild(e.target);
		}
		public static function delayFunction(delay:Number, func:Function) {
			var timer:Timer = new Timer(delay * 1000, 1);
			timer.addEventListener(TimerEvent.TIMER, _func);
			timer.start();
			function _func(e:TimerEvent){
				timer.removeEventListener(TimerEvent.TIMER, _func);
				timer = null;
				if(func.length > 0){
					func(e);
				} else {
					func();
				}
			}
		}
		public static function duplicateMovieclip(source:MovieClip):MovieClip{
			// create duplicate
			var sourceClass:Class = Object(source).constructor;
			var duplicate:MovieClip = new sourceClass();
			
			// duplicate properties
			duplicate.transform = source.transform;
			duplicate.filters = source.filters;
			duplicate.cacheAsBitmap = source.cacheAsBitmap;
			duplicate.opaqueBackground = source.opaqueBackground;
			
			if (source.scale9Grid) {
				var rect:Rectangle = source.scale9Grid;
				duplicate.scale9Grid = rect;
			}
			
			return duplicate;
		}
	}
}