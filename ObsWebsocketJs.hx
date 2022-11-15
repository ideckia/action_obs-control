@:jsRequire('obs-websocket-js', 'default')
extern class ObsWebsocketJs {
	function new();
	function connect(url:String, ?password:String):js.lib.Promise<Any>;
	function on(eventName:String, ?args:Any):js.lib.Promise<Any>;
	function call(requestName:String, ?args:Any):js.lib.Promise<Any>;
}
