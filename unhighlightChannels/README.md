# Unhighlight Channels

This script adds in a menu under `Settings` called `Unhighlighted Channels`. You can select `Unhighlight Current Channel` to ignore notifications from the currently selected channel and then select that channel under `Currently Unhighlighted Channels` to unignore it.

Note that notifications being ignored include `Channel Msg Hilight` and `Channel Action Hilight` text events.

Also note that the notifications are converted into their non-notification counterparts (`Channel Message` and `Channel Action`). The messages are not removed entirely, simply converted.

## Commands added

These are an alternative to using the `Settings` > `Unhighlighted Channels` menu. Note you can run `/help command` to get info on what a command does.

Commands which have optional `[channel] [network]` arguments will use the currently selected channel to determine context. You can specify a channel name while in the same network as the intended channel without having to specify a network. Arguments should use quotations if spaces are present.

### `unhighlightChannel [channel] [network]`

Starts converting highlights for channel to non-highlighted text events.

### `stopUnhighlightChannel [channel] [network]`

Stops converting highlights to non-highlighted text events for channel.

### `checkHighlightChannel [channel] [network]`

Checks if highlights are being converted to non-highlighted text events for this channel.

### `resetUnhighlightChannels`

Will reset the plugin preferences and remove all channels from having their highlights converted.

### `debugUnhighlightChannels`

Will print out plugin preferences.

## Todo

-   Add in more performant hook design as found in ignoreTextEvents
-   Break up file into modules
-   Create method to list all affected channels in table

## Available for Hire

I'm available for freelance, contracts, and consulting both remotely and in the Hudson Valley, NY (USA) area. [Some more about me](https://www.zweisolutions.com/about.html) and [what I can do for you](https://www.zweisolutions.com/services.html).

Feel free to drop me a message at:

```
hi [a+] zweisolutions {●} com
```

## License

[MIT](../LICENSE)
