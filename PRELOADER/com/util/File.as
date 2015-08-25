package com.util{
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;

	public class File {
		/* -------------------------------- DOCUMENTATION --------------------------------
		swfPath: Complete URL Path to SWF (or KOL)
		completeFunction  *: The function to be executed upon file completion
		onProgressUpdate **: The function to be called to display current file load progress
		
		*  Function must have one (1) Event type paramet to be returned the LoadedFile information.
		** Function must have one Number type parameter which will be sent the current progress percent.
		
		Usage Example: 
		var loader:SWFLoader = new SWFLoader("gamefiles/test.kol", completeHandler, updateHandler);
			function completeHandler(e:Event){
				addChild(e.currentTarget.content);
				trace("Finished Loading!")
			}
			function updateHandler(percent){
				trace(percent + " Loaded!")
			}
		
		*/
		
		private var completeFunc:Function
		private var updateFunc:Function;
		private var errorFunc:Function;
		private var path:String;
		private var mLoader:Loader = new Loader();
		private var mRequest:URLRequest
		public function File (swfPath:String, completeFunction:Function, onProgressUpdate:Function = null, onFailureToLoad:Function = null) {
			completeFunc = completeFunction;
			updateFunc = onProgressUpdate;
			errorFunc = onFailureToLoad;
			path = swfPath;
			startLoad();
		}
		private function startLoad () {
			mRequest = new URLRequest(path);
			mLoader.contentLoaderInfo.addEventListener (Event.COMPLETE, onCompleteHandler);
			mLoader.contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS, onProgressHandler);
			mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
			mLoader.load (mRequest);
		}

		private function onCompleteHandler (loadEvent:Event) {
			mLoader.contentLoaderInfo.removeEventListener (Event.COMPLETE, onCompleteHandler);
			mLoader.contentLoaderInfo.removeEventListener (ProgressEvent.PROGRESS, onProgressHandler);
			if(completeFunc.length > 1){
				completeFunc(loadEvent, mLoader.content)
			} else {
				completeFunc(loadEvent);
			}
			
			//addChild (loadEvent.currentTarget.content);
		}
		private function onProgressHandler (mProgress:ProgressEvent) {
			var percent:int = mProgress.bytesLoaded / mProgress.bytesTotal * 100;
			if(updateFunc != null){
				updateFunc(percent)
			}
		}
		private function onErrorHandler (error:IOErrorEvent) {
			if(errorFunc != null){
				if(errorFunc.length == 1){
					errorFunc(error);
				} else {
					errorFunc();
				}
			}
		}

	}

}