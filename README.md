# Action for ideckia: Obs-Control

## Definition

Connect to OBS Studio and control it via websockets

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| address | String | Obs address | true | 'localhost:4455' | null |
| password | String | Obs password | true | null | null |
| request_type | String | Obs request | false | 'Switch scene' | [Switch scene,Activate source,Deactivate source,Mute input,Unmute input] |
| scene_name | String | Scene name mandatory in "Switch scene", "Activate source" and "Deactivate source" requests | false | null | null |
| source_name | String | Source name mandatory in "Activate source" and "Deactivate source" requests | false | null | null |
| input_name | String | Input name mandatory in "Mute input" and "Unmute input" requests | false | null | null |


## Example in layout file

```json
{
    "state": {
        "text": "to first scene",
        "bgColor": "00ff00",
        "action": {
            "name": "obs-control",
            "props": {
                "address": "localhost:4455",
                "password": null,
                "request_type": "Switch scene",
                "scene_name": "main-scene"
            }
        }
    }
}
```

Some examples can be found in [presets.json](presets.json)

## Server

This action works with OBS WebSocket plugin (version 5.x.x). It is included in OBS Studio > 28.0.0. [More info](https://github.com/obsproject/obs-websocket/).