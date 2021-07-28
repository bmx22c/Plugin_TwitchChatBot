# Twitch Chat Bot

Twitch Chat Bot in an OpenPlanet plugin for Trackmania 2020 that answer to commands. It can display the map you're playing, the serveur you're on, your personnal best time, a link to the map you're playing and a few more configurable fields.

Note: Thanks to [Miss's Twitch Chat plugin](https://openplanet.nl/files/23) for providing the base of this plugin.

## Installation

Put the files in your OpenPlanet directory which is located under:
```
C:\Users\<username>\OpenplanetNext\Scripts\TwitchChat
```

## Settings
### Parameters
You'll need to update the plugin settings tab under the `Twitch Chat Bot` then `Parameters` tab with some informations:
- `Twitch Oauth Token` that you can get from [here](https://twitchapps.com/tmi/).
- `Twitch Nickname` is the Twitch nickname from the channel you'll be streaming on.
- `Twitch Channel` which is, as the name suggests, your Twitch channel, preceded by `#`.

### Commands
- You can enable or disable specific commands. (⚠ _please note that some characters will not work because they are locked by Twitch, such as `/`, `//`, `@` or `.`_)
- You can configure the command prefix (example: `!`)
- You can configure the command strings (example: `map`, `server`, `pb` and `url`)

### Strings
You can configure every strings that will be posted in the chat.

You will have variables available for every command:
- Map:
    - `{name}` - map name
    - `{author}` - map author
- Server:
    - `{name}` - server name
    - `{nbr_player}` - current player count
    - `{max_player}` - number of slots of current serveur
- Personnal best time:
    - `{pb}` - personnal best time
- URL:
    - `{url}` - map URL

You can place these variables wherever you want inside the associated field.

_Note: You can paste emojis from outside OpenPlanet and they will work. It will display a `?` but will still work._

## Usage
Once properly configured, just launch Trackmania and it should connect to your Twitch chat automatically.

Everyone will be able to use these commands.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)