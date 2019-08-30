# Ignore Text Events

This script adds in a menu under `Settings` called `Ignore Text Events`. You can select a text event to ignore in the context of the current channel or network using the `Set Events To Ignore In Current` menu. You can set that event to stop being ignored using the `Events Currently Ignored In` menu. Alternatively, you can toggle events to be ignored in the global context using the `Toggle Events Ignored Globally` menu.

**Common use cases include:**

-   Removing `abc gives voice to xyz` (Channel Voice) events
-   Removing `ChanServ gives channel operator status to xyz` (Channel Operator) events

Note that when you ignore a text event, it will not longer be emitted in the chat window and other plugins/scripts which interact with it will no longer see it.

Also note that this only hooks the text events, not the server events themselves. This won't stop private message/notice/part behavior but will suppress the text events emitted from them.

You can figure out which event you want to target by correlating the message you're seeing to the list of events and their pre-written text strings in `Settings>Text Events`.

## Installation

You will want to use the [single flat file in the build directory](https://github.com/Zweihander-Main/hexchat_scripts/blob/master/ignoreTextEvents/build/ignoreTextEvents.lua).

More information on the [top level README](https://github.com/Zweihander-Main/hexchat_scripts#installation) as well as the [official documentation](https://hexchat.readthedocs.io/en/latest/faq.html#how-do-i-auto-load-scripts-at-startup).

## Commands added

These are an alternative to using the `Settings` > `Ignore Text Events` menu. Note you can run `/help command` to get info on what a command does.

Commands which have optional `[channel] [network]` arguments will use the currently selected channel to determine context. You can specify a channel name while in the same network as the intended channel without having to specify a network. Arguments should use quotations if spaces are present.

`type` is one of `channel`, `network`, or `global`.

### `startIgnoringEvent type event [network] [channel]`

Starts ignoring given event for given context.

### `stopIgnoringEvent type event [network] [channel]`

Stops ignoring given event for given context.

### `checkEventIgnoredAtContext type event [network] [channel]`

Checks if given event is ignored for given context.

### `checkEventIgnored event`

Checks if given event is ignored at all and if so, where?

### `listEventsIgnored`

Lists all text events that are ignored and where they are ignored.

### `resetIgnoreTextEvents`

Will reset the plugin preferences and remove all text events from being ignored.

### `debugIgnoreTextEvents`

Will print out plugin preferences and currently enabled hooks.

## Development notes

Credits:

-   https://gist.github.com/turtleDev/a54a61a14e4a438f893865843279fd40 for the module packing and loading script
-   https://bitbucket.org/snippets/marcotrosi/XnyRj/lua-isequal for the table comparison script

Limitations in the HexChat pluginprefs interface led to a lot of the decisions that caused the script to become more complicated than it would normally be. For example, this script attempts to remain as performant as possible in regards to hooks processing text events. This led to using two models when saving to the plugin preferences: one storing all contexts tied to a particular event for use with hooks and another tied to storing all events tied to a particular context for use with views.

## Building

See [the top level README file](https://github.com/Zweihander-Main/hexchat_scripts#building)

## Todo

-   Sanitize event input against possible pre-programmed text events (may prevent custom text events however)
-   Refactor `model_channetg` iteration to convert value into array-like table

## Available for Hire

I'm available for freelance, contracts, and consulting both remotely and in the Hudson Valley, NY (USA) area. [Some more about me](https://www.zweisolutions.com/about.html) and [what I can do for you](https://www.zweisolutions.com/services.html).

Feel free to drop me a message at:

```
hi [a+] zweisolutions {●} com
```

## License

[MIT](../LICENSE)
