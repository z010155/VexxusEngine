package {
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	public class Connection {
		public var prefix:String = "";
		public function Connection(prefix:String) {
			this.prefix = prefix;
		}
		public function postPage(page:String, vars:Object, completeHandler:Function) {
			var loader:URLLoader = new URLLoader  ;
			if(page.indexOf(".php")){
				page = page.split(".php")[0];
			}
			var urlreq:URLRequest = new URLRequest("http://" + prefix + "/" + page + ".php");
			//var urlvars:URLVariables = new URLVariables  
			var urlvars:URLVariables = ObjectToUrlVars(vars);
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			urlreq.method = URLRequestMethod.POST;
			urlreq.data = urlvars;
			loader.addEventListener(Event.COMPLETE, completed);
			loader.load(urlreq);
			function completed(event:Event) {
				var loader:URLLoader = URLLoader(event.target);
				//trace(data.a + ", " + data.b);
				completeHandler.call(null, loader.data);
			}
		}
		private function ObjectToUrlVars(parameters:Object):URLVariables {
			var paramsToSend:URLVariables = new URLVariables();
			for (var i:String in parameters) {
				if (i != null) {
					if (parameters[i] is Array) {
						paramsToSend[i] = parameters[i];
					} else {
						paramsToSend[i] = parameters[i].toString();
					}
				}
			}
			return paramsToSend;
		}
	}

}