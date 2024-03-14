package;

import api.action.Data;

using api.IdeckiaApi;

typedef Props = {
	@:shared
	@:editable('Obs address', 'localhost:4455')
	var address:String;
	@:shared
	@:editable('Obs password')
	var password:String;
	@:editable('Obs request', 'Switch scene', ['Switch scene', 'Toggle source', 'Mute input', 'Unmute input'])
	var request_type:String;
	@:editable('Scene name mandatory in "Switch scene" and "Toggle source" requests')
	var scene_name:String;
	@:editable('Source name mandatory in "Toggle source" requests')
	var source_name:String;
	@:editable('Input name mandatory in "Mute input" and "Unmute input" requests')
	var input_name:String;
	var clickCallback:Void->js.lib.Promise<ActionOutcome>;
	var obs:ObsWebsocket;
}

@:name("obs-control-base")
@:description("Basic OBS control to call to the websocket")
class ObsControlBase extends IdeckiaAction {
	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var msg = assertProps();
			if (msg != '')
				reject('Not enough values given. $msg');

			resolve(initialState);
		});
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			callOBSRequest(currentState).then(data -> {
				server.log.debug('Received data: $data.');
				if (props.clickCallback == null)
					resolve(new ActionOutcome({state: currentState}));
				else
					props.clickCallback().then(resp -> {
						if (resp.directory == null || resp.directory.items.length == 0)
							resolve(new ActionOutcome({state: currentState}));
						else
							resolve(resp);
					}).catchError(reject);
			}).catchError((error) -> {
				reject('Error: $error');
				resolve(new ActionOutcome({state: currentState}));
			});
		});
	}

	function assertProps() {
		return switch props.request_type {
			case 'Switch scene' if (props.scene_name == null):
				'"scene_name" is mandatory.';
			case 'Toggle source' if (props.scene_name == null && props.source_name == null):
				'"scene_name" and "source_name" are mandatory.';
			case 'Mute input' | 'Unmute input' if (props.input_name == null):
				'"input_name" is mandatory.';
			case x if (x == ''):
				'"request_type" is mandatory';
			case _: '';
		}
	}

	function callOBSRequest(currentState:ItemState) {
		return switch props.request_type {
			case 'Switch scene':
				props.obs.setCurrentScene(props.scene_name);
			case 'Toggle source':
				toggleSourceActiveObsRequest(currentState);
			case 'Mute input':
				props.obs.setInputMute(props.input_name, true);
			case 'Unmute input':
				props.obs.setInputMute(props.input_name, false);
			case _: js.lib.Promise.resolve(false);
		}
	}

	function toggleSourceActiveObsRequest(currentState:ItemState) {
		return new js.lib.Promise((resolve, reject) -> {
			props.obs.getSceneItems(props.scene_name).then(obsResponse -> {
				for (s in obsResponse.sceneItems) {
					if (s.sourceName == props.source_name) {
						var isEnabled = !s.sceneItemEnabled;
						currentState.bgColor = isEnabled ? 'ff00aa00' : 'ffaa0000';
						props.obs.setSourceEnabled(props.scene_name, s.sceneItemId, isEnabled).then(d -> resolve(d)).catchError(reject);
						break;
					}
				}
			}).catchError(reject);
		});
	}
}
