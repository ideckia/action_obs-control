# [BETA] Action for [ideckia](https://ideckia.github.io/): obs-control

## Description

Connect to OBS Studio and control it via websockets

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| address | String | Obs address | true | 'localhost:4455' | null |
| password | String | Obs password | true | null | null |
| request_type | String | Obs request | false | 'Switch scene' | [Switch scene,Toggle source,Mute input,Unmute input] |
| scene_name | String | Scene name mandatory in "Switch scene", "Toggle source" requests | false | null | null |
| source_name | String | Source name mandatory in "Toggle source" requests | false | null | null |
| input_name | String | Input name mandatory in "Mute input" and "Unmute input" requests | false | null | null |

## On single click

Calls to OBS to execute the given command

## Test the action

There is a script called `test_action.js` to test the new action. Set the `props` variable in the script with the properties you want and run this command:

```
node test_action.js
```

## Example in layout file

```json
{
    "text": "obs-control example",
    "bgColor": "00ff00",
    "actions": [
        {
            "name": "obs-control",
            "props": {
                "address": "localhost:4455",
                "password": null,
                "request_type": "Switch scene",
                "scene_name": "main-scene"
            }
        }
    ]
}
```
