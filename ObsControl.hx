package;

using api.IdeckiaApi;

typedef Props = {
	@:shared
	@:editable('Obs address', 'localhost:4455')
	var address:String;
	@:shared
	@:editable('Obs password')
	var password:String;
	@:editable('Obs request', 'Switch scene', [
		'Switch scene',
		'Activate source',
		'Deactivate source',
		'Mute input',
		'Unmute input'
	])
	var request_type:String;
	@:editable('Scene name mandatory in "Switch scene", "Activate source" and "Deactivate source" requests')
	var scene_name:String;
	@:editable('Source name mandatory in "Activate source" and "Deactivate source" requests')
	var source_name:String;
	@:editable('Input name mandatory in "Mute input" and "Unmute input" requests')
	var input_name:String;
}

@:name('obs-control')
@:description('Control OBS via websockets. A wrapper for obs-websocket-js')
class ObsControl extends IdeckiaAction {
	static var obs:ObsWebsocketJs;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var msg = assertOBSRequest();
			if (msg != '')
				reject('Not enough values given. $msg');

			if (obs != null) {
				server.log.debug('OBS already connected.');
				resolve(initialState);
				return;
			}

			obs = new ObsWebsocketJs();
			var websocketProtocol = 'ws://';
			var address = StringTools.startsWith(props.address, websocketProtocol) ? props.address : websocketProtocol + props.address;
			server.log.info('Connecting to obs-websocket [address=${address}].');
			obs.connect(address, props.password).then((_) -> {
				server.log.info("Success! We're connected & authenticated.");
			}).catchError((error) -> {
				obs = null;
				reject('Error connecting to OBS: $error');
			});
			resolve(initialState);
		});
	}

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			if (obs == null)
				reject('OBS Websocket client is not initialized.');
			callOBSRequest().then(data -> {
				server.log.debug('Received data: $data.');
			}).catchError((error) -> {
				reject('Error: $error');
			});

			resolve(currentState);
		});
	}

	function assertOBSRequest() {
		return switch props.request_type {
			case 'Switch scene' if (props.scene_name == null):
				'"scene_name" is mandatory.';
			case 'Activate source' | 'Deactivate source' if (props.scene_name == null && props.source_name == null):
				'"scene_name" and "source_name" are mandatory.';
			case 'Mute input' | 'Unmute input' if (props.input_name == null):
				'"input_name" is mandatory.';
			case x if (x == ''):
				'"request_type" is mandatory';
			case _: '';
		}
	}

	function callOBSRequest() {
		return switch props.request_type {
			case 'Switch scene':
				setSceneObsRequest(props.scene_name);
			case 'Activate source':
				setSourceActiveObsRequest(props.scene_name, props.source_name, true);
			case 'Deactivate source':
				setSourceActiveObsRequest(props.scene_name, props.source_name, false);
			case 'Mute input':
				setInputMuteObsRequest(props.input_name, true);
			case 'Unmute input':
				setInputMuteObsRequest(props.input_name, false);
			case _: js.lib.Promise.resolve('');
		}
	}

	function setSceneObsRequest(sceneName:String) {
		return obs.call('SetCurrentProgramScene', {
			"sceneName": sceneName
		});
	}

	function setInputMuteObsRequest(inputName:String, inputMuted:Bool) {
		return obs.call('SetInputMute', {
			"inputName": inputName,
			"inputMuted": inputMuted
		});
	}

	function setSourceActiveObsRequest(sceneName:String, sourceName:String, activate:Bool) {
		return new js.lib.Promise((resolve, reject) -> {
			obs.call('GetSceneItemId', {
				"sceneName": sceneName,
				"sourceName": sourceName
			}).then(data -> {
				var resp:{sceneItemId:Int} = cast data;
				obs.call('SetSceneItemEnabled', {
					"sceneName": sceneName,
					"sceneItemId": resp.sceneItemId,
					"sceneItemEnabled": activate
				}).then(d -> resolve(d)).catchError(reject);
			}).catchError(reject);
		});
	}
}
