# HexChat IRC Client Scripts

Each folder contains a different script for HexChat as well as a README describing how it works.

## List of Scripts

[Unhighlight Channels](./unhighlightChannels/) -- converts highlights from user-selected channels to regular non-highlighted text events
[Ignore Text Events](./ignoreTextEvents/) -- allows a user to remove text events from a given channel, network, or global context

## Installation

For installation: `Window` > `Plugins and Scripts` will allow you to load and unload them. See [the official documentation](https://hexchat.readthedocs.io/en/latest/faq.html#how-do-i-auto-load-scripts-at-startup) on how to load scripts automatically at startup.

## Building

Run `make` on the top level directory (where this README is located). Currently used by scripts which use modules to compress them into one flat file. This will take the modules in the `./script/src` directory and output them to `./script/build`.

Credits to https://gist.github.com/turtleDev/a54a61a14e4a438f893865843279fd40 for the included pack.lua script that enables this.

## Todo

-   Future script: Ignore private messages from users matching x both globally and maybe per network
-   Future script: Highlight all text events in a channel

## Available for Hire

I'm available for freelance, contracts, and consulting both remotely and in the Hudson Valley, NY (USA) area. [Some more about me](https://www.zweisolutions.com/about.html) and [what I can do for you](https://www.zweisolutions.com/services.html).

Feel free to drop me a message at:

```
hi [a+] zweisolutions {●} com
```

## License

[MIT](./LICENSE)
