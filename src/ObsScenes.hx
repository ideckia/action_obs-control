package;

import api.action.Data;

using api.IdeckiaApi;

typedef Props = {
	@:shared('obs.address')
	@:editable('Obs address', "localhost:4455")
	var address:String;
	@:shared('obs.password')
	@:editable('Obs password')
	var password:String;
}

@:name("obs-scenes")
@:description("Create a directory with the current obs scenes dynamically")
class ObsScenes extends IdeckiaAction {
	static var SCENE_BG = Data.embedBase64('film_frame.png');
	static var obs:ObsWebsocket = new ObsWebsocket();

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var runtimeBack = Data.getBase64('film_frame.png');
			if (runtimeBack != null)
				SCENE_BG = runtimeBack;

			obs = new ObsWebsocket(props.address, props.password, server);

			obs.checkConnection().then(_ -> {
				resolve(initialState);
			}).catchError(e -> {
				var msg = 'Error checking connection to OBS: [$e]';
				log(msg);
				reject(msg);
			});
		});
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			obs.getCurrentScene().then(obsResponse -> {
				getScenes(currentState, obsResponse.sceneName).then(resolve).catchError(reject);
			}).catchError(reject);
		});
	}

	function getScenes(currentState:ItemState, currentScene:String) {
		return new js.lib.Promise((resolve, reject) -> {
			var scenes:Array<DynamicDirItem> = [];
			obs.getScenes().then(obsScenesResp -> {
				for (s in obsScenesResp.scenes) {
					scenes.push({
						text: s.sceneName,
						icon: SCENE_BG,
						bgColor: s.sceneName == currentScene ? 'ff00aa00' : 'ffaa0000',
						textColor: 'ffaaaaaa',
						textSize: 20,
						textPosition: 'center',
						actions: [
							{
								name: '_obs-control-base',
								props: {
									obs: obs,
									request_type: "Switch scene",
									scene_name: s.sceneName,
									clickCallback: execute.bind(currentState)
								}
							}
						]
					});
				}

				var rows = 2;
				var columns = 2;
				while (rows * columns < scenes.length) {
					rows++;
					if (rows * columns >= scenes.length)
						break;
					columns++;
				}
				resolve(new ActionOutcome({
					directory: {
						rows: rows,
						columns: columns,
						items: scenes
					}
				}));
			}).catchError(reject);
		});
	}

	function log(value:Dynamic, ?pos:haxe.PosInfos) {
		if (server != null)
			server.log.debug(value);
		else
			trace(value, pos);
	}
}
