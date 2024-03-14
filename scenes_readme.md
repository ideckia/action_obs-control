# [BETA] Action for [ideckia](https://ideckia.github.io/): obs-scenes

## Description

Create a directory with the scenes defined in OBS Studio

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| address | String | Obs address | true | 'localhost:4455' | null |
| password | String | Obs password | true | null | null |

## On single click

Opens a directory with the scenes defined in OBS Studio

## Test the action

There is a script called `test_action.js` to test the new action. Set the `props` variable in the script with the properties you want and run this command:

```
node test_action.js
```

## Example in layout file

```json
{
    "text": "obs-scenes example",
    "bgColor": "00ff00",
    "actions": [
        {
            "name": "obs-scenes",
            "props": {
                "address": "localhost:4455",
                "password": null
            }
        }
    ]
}
```
