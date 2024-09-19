package;

using api.IdeckiaApi;

typedef Props = {
	@:shared('obs.address')
	@:editable('prop_obs_address', "localhost:4455")
	var address:String;
	@:shared('obs.password')
	@:editable('prop_obs_password')
	var password:String;
}

@:name("obs-all-items")
@:description("items_action_description")
@:localize
class ObsItems extends IdeckiaAction {
	static var SCENE_BG = Data.embedBase64('film_frame.png');
	static var obs:ObsWebsocket = new ObsWebsocket();

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var runtimeBack = core.data.getBase64('film_frame.png');
			if (runtimeBack != null)
				SCENE_BG = runtimeBack;

			obs = new ObsWebsocket(props.address, props.password, core);

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
				getItems(currentState, obsResponse.currentProgramSceneName).then(resolve).catchError(reject);
			}).catchError(reject);
		});
	}

	function getItems(currentState:ItemState, sceneName:String) {
		return new js.lib.Promise((resolve, reject) -> {
			var sceneItems:Array<DynamicDirItem> = [];
			obs.getSceneItems(sceneName).then(obsResponse -> {
				for (s in obsResponse.sceneItems) {
					core.log.debug(s);
					sceneItems.push({
						text: s.sourceName,
						bgColor: s.sceneItemEnabled ? 'ff00aa00' : 'ffaa0000',
						actions: [
							{
								name: 'obs-control',
								props: {
									obs: obs,
									request_type: 'Toggle source',
									scene_name: sceneName,
									source_name: s.sourceName,
									clickCallback: execute.bind(currentState)
								}
							}
						]
					});
				}

				var rows = 2;
				var columns = 2;
				while (rows * columns < sceneItems.length) {
					rows++;
					if (rows * columns >= sceneItems.length)
						break;
					columns++;
				}
				resolve(new ActionOutcome({
					directory: {
						rows: rows,
						columns: columns,
						items: sceneItems
					}
				}));
			}).catchError(e -> {
				core.dialog.error('OBS itemak lortzean errorea', 'Errorea: $e');
				reject(e);
			});
		});
	}

	function log(value:Dynamic, ?pos:haxe.PosInfos) {
		if (core != null)
			core.log.debug(value);
		else
			trace(value, pos);
	}
}
