using api.IdeckiaApi;

@:keep
class ObsWebsocket {
	var obs:ObsWebsocketExtern;
	var address:String;
	var password:String;
	var core:IdeckiaCore;

	public function new(?address:String, ?password:String, ?core:IdeckiaCore) {
		obs = new ObsWebsocketExtern();
		this.address = address;
		this.password = password;
		this.core = core;
	}

	public function connect():js.lib.Promise<Bool> {
		return new js.lib.Promise((resolve, reject) -> {
			var websocketProtocol = 'ws://';
			if (address == null || address == '') {
				reject('Cannot connect to OBS, address is empty');
				return;
			}
			var address = StringTools.startsWith(address, websocketProtocol) ? address : websocketProtocol + address;
			log('Connecting to obs-websocket [address=${address}].');
			obs.connect(address, password).then((_) -> {
				log("Success! We're connected & authenticated.");
				resolve(true);
			}).catchError(error -> {
				obs = null;
				var msg = if (Std.string(error).indexOf('ECONNREFUSED') != -1) {
					"Can't connect to OBS Studio. Be sure it is running and the Websocket server is enabled (Tools > Websocket Server Settings)";
				} else {
					'Error connecting to OBS: [$error]';
				}
				reject(msg);
			});
		});
	}

	public function getCurrentScene() {
		return new js.lib.Promise((resolve, reject) -> {
			checkConnection().then(_ -> {
				obs.call('GetCurrentProgramScene', {}).then(response -> {
					var obsResponse:ObsCurrentSceneResponse = cast response;
					resolve(obsResponse);
				}).catchError(reject);
			}).catchError(reject);
		});
	}

	public function getScenes() {
		return new js.lib.Promise((resolve, reject) -> {
			checkConnection().then(_ -> {
				obs.call('GetSceneList', {}).then(response -> {
					var obsResponse:ObsScenesResponse = cast response;
					resolve(obsResponse);
				}).catchError(reject);
			}).catchError(reject);
		});
	}

	public function getSceneItems(sceneName:String) {
		return new js.lib.Promise((resolve, reject) -> {
			checkConnection().then(_ -> {
				obs.call('GetSceneItemList', {sceneName: sceneName}).then(response -> {
					var obsResponse:ObsSceneItemsResponse = cast response;
					resolve(obsResponse);
				}).catchError(reject);
			}).catchError(reject);
		});
	}

	public function setCurrentScene(sceneName:String) {
		return new js.lib.Promise((resolve, reject) -> {
			checkConnection().then(_ -> {
				obs.call('SetCurrentProgramScene', {
					"sceneName": sceneName
				}).then(data -> {
					resolve(true);
				}).catchError((error) -> {
					log('Error: $error');
					resolve(true);
				});
			}).catchError(reject);
		});
	}

	public function setInputMute(inputName:String, inputMuted:Bool) {
		return new js.lib.Promise((resolve, reject) -> {
			checkConnection().then(_ -> {
				obs.call('SetInputMute', {
					"inputName": inputName,
					"inputMuted": inputMuted
				}).then(data -> {
					resolve(true);
				}).catchError((error) -> {
					log('Error: $error');
					resolve(true);
				});
			}).catchError(reject);
		});
	}

	public function setSourceEnabled(sceneName:String, sceneItemId:UInt, isEnabled:Bool) {
		return new js.lib.Promise((resolve, reject) -> {
			checkConnection().then(_ -> {
				obs.call('SetSceneItemEnabled', {
					"sceneName": sceneName,
					"sceneItemId": sceneItemId,
					"sceneItemEnabled": isEnabled
				}).then(data -> {
					resolve(true);
				}).catchError((error) -> {
					log('Error: $error');
					resolve(true);
				});
			}).catchError(reject);
		});
	}

	public function checkConnection() {
		return new js.lib.Promise((resolve, reject) -> {
			function connectToObs() {
				connect().then((_) -> {
					log("Success! We're connected & authenticated.");
					resolve(true);
				}).catchError(error -> {
					obs = null;
					var msg = if (Std.string(error).indexOf('ECONNREFUSED') != -1) {
						"Can't connect to OBS Studio. Be sure it is running and the Websocket server is enabled (Tools > Websocket Server Settings)";
					} else {
						'Error connecting to OBS: [$error]';
					}
					reject(msg);
				});
			}
			if (obs == null) {
				obs = new ObsWebsocketExtern();
				connectToObs();
			} else {
				obs.call('GetVersion').then(data -> {
					log(data);
					log('OBS already connected.');
					resolve(true);
				}).catchError((error) -> {
					log('Error: $error');
					log('Reconnecting');
					connectToObs();
				});
			}
		});
	}

	function log(value:Dynamic, ?pos:haxe.PosInfos) {
		if (core != null)
			core.log.debug(value);
		else
			trace(value, pos);
	}
}

typedef ObsSceneObject = {
	var sceneIndex:UInt;
	var sceneName:String;
}

typedef ObsSceneItemObject = {
	var sceneItemEnabled:Bool;
	var sceneItemId:UInt;
	var sourceName:String;
}

typedef ObsScenesResponse = {
	var currentProgramSceneName:String;
	var currentPreviewSceneName:String;
	var scenes:Array<ObsSceneObject>;
}

typedef ObsCurrentSceneResponse = {
	var sceneName:String;
	var sceneUuid:String;
	var currentProgramSceneName:String;
	var currentPreviewSceneName:String;
}

typedef ObsSceneItemsResponse = {
	var sceneItems:Array<ObsSceneItemObject>;
}

typedef GetVersionResponse = {
	var availableRequests:Array<String>;
	var obsVersion:String;
	var obsWebsocketVersion:String;
	var platform:String;
	var platformDescription:String;
}

@:jsRequire('obs-websocket-js', 'default')
extern class ObsWebsocketExtern {
	function new();
	function connect(url:String, ?password:String):js.lib.Promise<Any>;
	function on(eventName:String, ?args:Any):js.lib.Promise<Any>;
	function call(requestName:String, ?args:Any):js.lib.Promise<Any>;
}
