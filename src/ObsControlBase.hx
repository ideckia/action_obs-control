package;

using api.IdeckiaApi;

typedef Props = {
	@:shared('obs.address')
	@:editable('prop_obs_address', "localhost:4455")
	var address:String;
	@:shared('obs.password')
	@:editable('prop_obs_password')
	var password:String;
	@:editable('base_prop_request_type', switch_scene, [
		switch_scene,
		toggle_source,
		mute_input,
		unmute_input,
		start_recording,
		stop_recording,
		toggle_recording,
		start_streaming,
		stop_streaming,
		toggle_streaming
	], PropEditorFieldType.text)
	var request_type:Enums.RequestType;
	@:editable('base_prop_scene_name')
	var scene_name:String;
	@:editable('base_prop_source_name')
	var source_name:String;
	@:editable('base_prop_input_name')
	var input_name:String;
	var clickCallback:Void->js.lib.Promise<ActionOutcome>;
	var obs:ObsWebsocket;
}

@:name("obs-control")
@:description("control_action_description")
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
			case switch_scene if (props.scene_name == null):
				Loc.scene_name_mandatory.tr();
			case toggle_source if (props.scene_name == null && props.source_name == null):
				Loc.scene_and_source_names_mandatory.tr();
			case mute_input | unmute_input if (props.input_name == null):
				Loc.input_name_mandatory.tr();
			case x if (x == ''):
				Loc.request_type_mandatory.tr();
			case _:
				'';
		}
	}

	function checkObsConnection() {
		return new js.lib.Promise((resolve, reject) -> {
			if (props.obs != null) {
				resolve(true);
				return;
			}

			props.obs = new ObsWebsocket(props.address, props.password, core);

			props.obs.checkConnection().then(_ -> {
				resolve(true);
			}).catchError(e -> {
				var msg = 'Error checking connection to OBS: [$e]';
				reject(msg);
			});
		});
	}

	function callOBSRequest(currentState:ItemState) {
		return new js.lib.Promise((resolve, reject) -> {
			checkObsConnection().then(_ -> {
				var promise = switch props.request_type {
					case switch_scene:
						props.obs.setCurrentScene(props.scene_name);
					case toggle_source:
						toggleSourceActiveObsRequest(currentState);
					case mute_input:
						props.obs.setInputMute(props.input_name, true);
					case unmute_input:
						props.obs.setInputMute(props.input_name, false);
					case start_recording:
						js.lib.Promise.resolve(false);
					case stop_recording:
						js.lib.Promise.resolve(false);
					case toggle_recording:
						js.lib.Promise.resolve(false);
					case start_streaming:
						js.lib.Promise.resolve(false);
					case stop_streaming:
						js.lib.Promise.resolve(false);
					case toggle_streaming:
						js.lib.Promise.resolve(false);
					case _: js.lib.Promise.resolve(false);
				}

				promise.then(resolve).catchError(reject);
			});
		}).catchError(_ -> {});
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
