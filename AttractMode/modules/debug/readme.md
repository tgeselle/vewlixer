# Debug module for AttractMode front end

by [Keil Miller Jr](http://keilmillerjr.com)

## DESCRIPTION:

Debug module is for the [AttractMode](http://attractmode.org) front end. It can assist you in sending messages to the terminal.

You may also want to check out the [Debug plugin](https://github.com/keilmillerjr/debug-plugin).

## Paths

You may need to change file paths as necessary as each platform (windows, mac, linux) has a slightly different directory structure.

## Install Files

1. Copy module files to `$HOME/.attract/modules/Debug/`

## Usage

From within your layout, you can load the module, debug, and distribute safely if you use a technique similar to the example provided.

Example:

```Squirrel
// Load Debug Module
if (fe.load_module("Debug")) local log = Log();

// Usage For Development or Production
try { log.send("This will show if the Debug module is present, and will fallback safely."); } catch(e) {}
```

When using the send method on the Message class, you can pass two optional params (prefix and suffix). I would recommend using the defaults, and only change them if necessary. 

## Notes

More functionality is expected as it meets my needs. If you have an idea of something to add that might benefit a wide range of layout developers, please join the AttractMode forum and send me a message.
