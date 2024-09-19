# [BETA] Action for [ideckia](https://ideckia.github.io/): obs-all-items

## Description

Create a directory with the items of the current OBS Studio scene dynamically

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| address | String | Obs address | true | 'localhost:4455' | null |
| password | String | Obs password | true | null | null |

## On single click

Opens a directory showing the items of the current scene

## Test the action

There is a script called `test_action.js` to test the new action. Set the `props` variable in the script with the properties you want and run this command:

```
node test_action.js
```

## Example in layout file

```json
{
    "text": "obs-all-items example",
    "bgColor": "00ff00",
    "actions": [
        {
            "name": "obs-all-items",
            "props": {
                "address": "localhost:4455",
                "password": null
            }
        }
    ]
}
```
