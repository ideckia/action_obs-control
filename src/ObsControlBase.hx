package;

using api.IdeckiaApi;

typedef Props = {
	@:shared('obs.address')
	@:editable('prop_obs_address', 'localhost:4455')
	var address:String;
	@:shared('obs.password')
	@:editable('prop_obs_password')
	var password:String;
	@:editable('base_prop_request_type', 'Switch scene', ['Switch scene', 'Toggle source', 'Mute input', 'Unmute input'])
	var request_type:String;
	@:editable('base_prop_scene_name')
	var scene_name:String;
	@:editable('base_prop_source_name')
	var source_name:String;
	@:editable('base_prop_input_name')
	var input_name:String;
	var clickCallback:Void->js.lib.Promise<ActionOutcome>;
	var obs:ObsWebsocket;
}

@:name("obs-control-base")
@:description("base_action_description")
@:localize
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
				core.log.debug('Received data: $data.');
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
