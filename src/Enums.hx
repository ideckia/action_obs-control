enum abstract RequestType(String) from String to String {
	var switch_scene = 'Switch scene';
	var toggle_source = 'Toggle source';
	var mute_input = 'Mute input';
	var unmute_input = 'Unmute input';
	var start_recording = 'Start Recording';
	var stop_recording = 'Stop Recording';
	var toggle_recording = 'Toggle Recording';
	var start_streaming = 'Start Streaming';
	var stop_streaming = 'Stop Streaming';
	var toggle_streaming = 'Toggle Streaming';
}

enum abstract ObsRequest(String) from String to String {
	var getCurrentProgramScene = 'GetCurrentProgramScene';
	var getSceneList = 'GetSceneList';
	var getSceneItemList = 'GetSceneItemList';
	var setCurrentProgramScene = 'SetCurrentProgramScene';
	var setInputMute = 'SetInputMute';
	var setSceneItemEnabled = 'SetSceneItemEnabled';
	var getVersion = 'GetVersion';
	var startRecord = 'StartRecord';
	var stopRecord = 'StopRecord';
	var toggleRecord = 'ToggleRecord';
	var startStream = 'StartStream';
	var stopStream = 'StopStream';
	var toggleStream = 'ToggleStream';
}
