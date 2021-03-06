-- SPDX-License-Identifier: MIT
local version = '1.0.0'

hexchat.register(
	'Ignore Text Events',
	version,
	'Allows you to selectively ignore text events on a per channel, per network, or global basis'
)

-- Fix for lua 5.2
if unpack == nil then
	unpack = table.unpack
end

local controller = require'controller.lua'
local callbacks = require'commandCallbacks.lua'

----------------------------------------------------
-- Command hooks
----------------------------------------------------

hexchat.hook_command(
	'startIgnoringEvent',
	callbacks.start_ignoring_event_cb,
	'Usage: startIgnoringEvent type event [network] [channel]\n\tStarts ignoring given event for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'stopIgnoringEvent',
	callbacks.stop_ignoring_event_cb,
	'Usage: stopIgnoringEvent type event [network] [channel]\n\tStops ignoring given event for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkEventIgnoredAtContext',
	callbacks.check_event_ignored_context_cb,
	'Usage: checkEventIgnoredAtContext type event [network] [channel]\n\tChecks if given event is ignored for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkEventIgnored',
	callbacks.check_event_ignored_cb,
	'Usage: checkEventIgnored event\n\tChecks if given event is ignored at all and if so, where?'
)
hexchat.hook_command(
	'listEventsIgnored',
	callbacks.list_events_ignored_cb,
	'Usage: listEventsIgnored\n\tLists all text events that are ignored and where they are ignored. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'resetIgnoreTextEvents',
	callbacks.reset_plugin_prefs_cb,
	'Usage: resetIgnoreTextEvents\n\tWill reset the plugin preferences and remove all text events from being ignored.'
)
hexchat.hook_command(
	'debugIgnoreTextEvents',
	callbacks.debug_plugin_prefs_cb,
	'Usage: debugIgnoreTextEvents\n\tWill print out plugin preferences and currently enabled hooks.'
)

controller.set_version(version)
controller.init()
