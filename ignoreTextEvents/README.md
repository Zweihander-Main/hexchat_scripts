# Ignore Text Events

This isn't the prettiest Lua code you'll ever see however it does do the job and manages to stay in one easy to load/share/transfer file.

https://gist.github.com/turtleDev/a54a61a14e4a438f893865843279fd40

This only hooks the text events, not the server events themselves. This won't stop private message/notice/part behavior but will suppress the text events emitted from them.

This will kill/eat text events.

Example use cases:
'Gives voice to'

## Commands added

## Todo

-   Prevent adding the same event to the same context multiple times (return 'already added' message)
-   Sanitize event input against possible pre-programmed text events (may prevent custom text events however)
-   Re-add version identifier upon reset

## Available for Hire

I'm available for freelance, contracts, and consulting both remotely and in the Hudson Valley, NY (USA) area. [Some more about me](https://www.zweisolutions.com/about.html) and [what I can do for you](https://www.zweisolutions.com/services.html).

Feel free to drop me a message at:

```
hi [a+] zweisolutions {●} com
```

## License

[MIT](../LICENSE)
