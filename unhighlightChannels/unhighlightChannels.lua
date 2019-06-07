-- SPDX-License-Identifier: MIT
local version = '1.1.0'

hexchat.register(
	'Unhighlight Channels',
	version,
	'Allows you to convert highlights to regular text events for each channel'
)
----------------------------------------------------
-- Utility functions and variables
----------------------------------------------------

-- Fix for lua 5.2
if unpack == nil then
	unpack = table.unpack
end

-- Delimiter variables. Changing preferences delimiter will invalidate preferences
local spaceDelimiter = '|||SPACE|||'
local preferencesDelimiter = '||||||'
-- Prefix for channel keys in preferences
local preferencesPrefix = 'unhighlightChannels_'

-- Converts table to human readable format
local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then
				k = '"' .. k .. '"'
			end
			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

-- Returns an array-like table from a string s, splitting the string using delimiter
local function split(s, delimiter)
	local result = {}
	for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
		table.insert(result, match)
	end
	return result
end

----------------------------------------------------
-- Plugin preferences
----------------------------------------------------

-- For future proofing in case a reset is ever needed
hexchat.pluginprefs['version'] = 'v' .. version

-- Get pluginprefs value based on given network and channel strings
-- Returns empty table if not found
local function get_channel_preference(channel, network)
	local pref =
		hexchat.pluginprefs[preferencesPrefix .. network .. preferencesDelimiter .. channel]
	if pref then
		return pref
	end
	return {}
end

-- Returns true if channel is set to convert highlights, false otherwise
local function isSetToConvert(channel, network)
	if get_channel_preference(channel, network) == 'convert' then
		return true
	else
		return false
	end
end

-- Set pluginprefs value based on given network and channel strings to given value string
local function set_channel_preference(channel, network, value)
	hexchat.pluginprefs[preferencesPrefix .. network .. preferencesDelimiter .. channel]
	= value
end

-- Convert pluginprefs key to table with channel and network keys
local function convert_preference_to_table(setting)
	local settingsArray = split(setting, preferencesDelimiter)
	local chanNetTable = {
		network = settingsArray[1]:sub(21),
		channel = settingsArray[2],
	}
	return chanNetTable
end

-- Iterates through channel preferences and passes their names and values to given function
local function iterate_channel_prefs_over_lambda(lambda)
	for name, value in pairs(hexchat.pluginprefs) do
		if name:sub(0, 20) == preferencesPrefix then
			lambda(name, value)
		end
	end
end

-- Resets all plugin preferences
local function reset_plugin_prefs()
	for a, b in pairs(hexchat.pluginprefs) do
		hexchat.pluginprefs[a] = nil
	end
end

----------------------------------------------------
-- Menu manipulation
----------------------------------------------------

-- Add 'Currently Unhighlighted Channels' listing menu item of given channel.
-- Each menu item will call the hexchat command unconvertHighlights if selected
-- Network and channel will be passed to unconvertHighlights with spaces
-- replaced with spaceDelimiter
local function add_unhighlighted_channel_menu(channel, network)
	hexchat.command(
		'menu add "Settings/Unhighlighted Channels/Currently Unhighlighted Channels/' .. network .. '"'
	)
	hexchat.command(
		'menu -t1 add "Settings/Unhighlighted Channels/Currently Unhighlighted Channels/' .. network .. '/' .. channel .. '" "" "stopUnhighlightChannel ' .. channel:gsub(
			' ',
			spaceDelimiter
		) .. ' ' .. network:gsub(' ', spaceDelimiter) .. '"'
	)
end

-- Remove menu item of given channel. Removes network menu if no other channels being converted in network
local function remove_unhighlighted_channel_menu(channel, network)
	local networkShouldBeRemoved = true
	local iterateOver = function(name)
		local chanNetTable = convert_preference_to_table(name)
		if chanNetTable['network'] == network then
			networkShouldBeRemoved = false
		end
	end
	iterate_channel_prefs_over_lambda(iterateOver)
	if networkShouldBeRemoved == true then
		hexchat.command(
			'menu del "Settings/Unhighlighted Channels/Currently Unhighlighted Channels/' .. network .. '"'
		)
	else
		hexchat.command(
			'menu del "Settings/Unhighlighted Channels/Currently Unhighlighted Channels/' .. network .. '/' .. channel .. '"'
		)
	end
end

-- Generated menu of unhighlighted channels from pluginprefs
local function generate_unhighlighted_menu()
	local iterateOver = function(name)
		local chanNetTable = convert_preference_to_table(name)
		add_unhighlighted_channel_menu(
			chanNetTable['channel'],
			chanNetTable['network']
		)
	end
	iterate_channel_prefs_over_lambda(iterateOver)
end

----------------------------------------------------
-- Menu loading and unloading
----------------------------------------------------

-- Loads all the menus
-- Hitting 'Unhighlight Current Channel' will call convertHighlights command
local function load_menus()
	hexchat.command('menu add "Settings/Unhighlighted Channels"')
	hexchat.command(
		'menu add "Settings/Unhighlighted Channels/Unhighlight Current Channel" "unhighlightChannel"'
	)
	hexchat.command(
		'menu add "Settings/Unhighlighted Channels/Currently Unhighlighted Channels"'
	)
	generate_unhighlighted_menu()
end

-- Unload handler
local function unload_menus()
	hexchat.command('menu del "Settings/Unhighlighted Channels"')
end

----------------------------------------------------
-- Text event handlers
----------------------------------------------------

-- Will check if channel is to be unhighlighted, then emits print and eats everything else
-- (event should be non-highlight version of notification)
local function check_notifications(args, attrs, event)
	local channel = hexchat.get_info('channel')
	local network = hexchat.get_info('network')
	if isSetToConvert(channel, network) then
		hexchat.emit_print_attrs(attrs, event, unpack(args))
		return hexchat.EAT_ALL
	end
end

----------------------------------------------------
-- Command callbacks
----------------------------------------------------

-- Uses default context unless arguments supplied.
-- Converts arguments if they're coming from menu
local function callback_handler(word)
	local returnArray = {
		channel = hexchat.get_info('channel'),
		network = hexchat.get_info('network'),
	}
	if word[2] then
		returnArray['channel'] = word[2]:gsub(spaceDelimiter, ' ')
	end
	if word[3] then
		returnArray['network'] = word[3]:gsub(spaceDelimiter, ' ')
	end
	return returnArray
end

-- Will set channel to convert highlights to text events
local function convert_highlights_cb(word)
	local infoArray = callback_handler(word)
	set_channel_preference(
		infoArray['channel'],
		infoArray['network'],
		'convert'
	)
	add_unhighlighted_channel_menu(infoArray['channel'], infoArray['network'])
end

-- Will set channel to stop converting highlights to text events
local function stop_converting_highlights_cb(word)
	local infoArray = callback_handler(word)
	set_channel_preference(infoArray['channel'], infoArray['network'], nil)
	remove_unhighlighted_channel_menu(
		infoArray['channel'],
		infoArray['network']
	)
end

-- Will print out if a channel is converting highlights or not
local function check_highlights_cb(word)
	local infoArray = callback_handler(word)
	if isSetToConvert(infoArray['channel'], infoArray['network']) then
		print(
			'Channel ',
			infoArray['channel'],
			' of network ',
			infoArray['network'],
			' is converting highlights to regular text events.'
		)
	else
		print(
			'Channel ',
			infoArray['channel'],
			' of network ',
			infoArray['network'],
			' is not converting highlights.'
		)
	end
end

-- Resets pluginprefs
local function reset_plugin_prefs_cb()
	reset_plugin_prefs()
	unload_menus()
	load_menus()
	print('Unhighlight Channels: Reset complete')
end

-- Prints out hexchat.pluginprefs in human readable format
local function debug_plugin_prefs_cb()
	print(dump(hexchat.pluginprefs))
end

----------------------------------------------------
-- Command hooks
----------------------------------------------------

hexchat.hook_command(
	'unhighlightChannel',
	convert_highlights_cb,
	'Usage: unhighlightChannel [channel] [network]\n\tStarts converting highlights for channel to non-highlighted text events. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'stopUnhighlightChannel',
	stop_converting_highlights_cb,
	'Usage: stopUnhighlightChannel [channel] [network]\n\tStops converting highlights for channel. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkHighlightChannel',
	check_highlights_cb,
	'Usage: checkHighlightChannel [channel] [network]\n\tChecks if highlights are converted for this channel. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'resetUnhighlightChannels',
	reset_plugin_prefs_cb,
	'Usage: resetUnhighlightChannels\n\tWill reset the plugin preferences and remove all channels from having their highlights converted. '
)
hexchat.hook_command(
	'debugUnhighlightChannels',
	debug_plugin_prefs_cb,
	'Usage: debugUnhighlightChannels\n\tWill print out plugin preferences.'
)

----------------------------------------------------
-- Text event hooks
----------------------------------------------------

hexchat.hook_print_attrs(
	'Channel Msg Hilight',
	function(args, attrs)
		return check_notifications(args, attrs, 'Channel Message')
	end,
	hexchat.PRI_HIGH
)
hexchat.hook_print_attrs(
	'Channel Action Hilight',
	function(args, attrs)
		return check_notifications(args, attrs, 'Channel Action')
	end,
	hexchat.PRI_HIGH
)

----------------------------------------------------
-- Menu calls
----------------------------------------------------

hexchat.hook_unload(unload_menus)
load_menus()
