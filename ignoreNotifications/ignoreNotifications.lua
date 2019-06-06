-- SPDX-License-Identifier: MIT
local version = '1.0.55'

hexchat.register(
	'Ignore Notifications',
	version,
	'Allows you to ignore notifications for specific channels'
)

-- For future proofing in case a reset is ever needed
hexchat.pluginprefs['version'] = 'v' .. version

----------------------------------------------------
-- Utility functions
----------------------------------------------------

-- Fix for lua 5.2
if unpack == nil then
	unpack = table.unpack
end

-- Delimiter variables. Changing preferences delimiter will invalidate preferences
local spaceDelimiter = '|||SPACE|||'
local preferencesDelimiter = '||||||'

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

-- Reverse an array-like table's order
local function reverse_array_table(arr)
	local i = 1
	local j = #arr
	while i < j do
		arr[i], arr[j] = arr[j], arr[i]
		i = i + 1
		j = j - 1
	end
	return arr
end

----------------------------------------------------
-- Plugin preferences
----------------------------------------------------

-- Get pluginprefs value based on given network and channel strings
-- Returns empty table if not found
local function get_channel_preference(channel, network)
	local pref =
		hexchat.pluginprefs['ignoreNotifications_' .. network .. preferencesDelimiter .. channel]
	if pref then
		return pref
	end
	return {}
end

-- Returns true if channel is set to ignore, false otherwise
local function isIgnored(channel, network)
	if get_channel_preference(channel, network) == 'ignore' then
		return true
	else
		return false
	end
end

-- Set pluginprefs value based on given network and channel strings to given value string
local function set_channel_preference(channel, network, value)
	hexchat.pluginprefs['ignoreNotifications_' .. network .. preferencesDelimiter .. channel]
	= value
end

-- Convert pluginprefs key to table[1] = channel, table[2] = network format
local function convert_preference_to_table(setting)
	local settingArray = split(setting, preferencesDelimiter)
	settingArray[1] = settingArray[1]:sub(21)
	return reverse_array_table(settingArray)
end

local function reset_plugin_prefs()
	for a, b in pairs(hexchat.pluginprefs) do
		hexchat.pluginprefs[a] = nil
	end
end

----------------------------------------------------
-- Menu manipulation
----------------------------------------------------

-- Add menu item of currently ignored channel based on network and channel string
local function add_ignored_channel_menu(channel, network)
	hexchat.command(
		'menu add "Settings/Ignoring Notifications/Currently Ignored Channels/' .. network .. '"'
	)
	hexchat.command(
		'menu -t1 add "Settings/Ignoring Notifications/Currently Ignored Channels/' .. network .. '/' .. channel .. '" "" "unignoreNotifications ' .. channel:gsub(
			' ',
			spaceDelimiter
		) .. ' ' .. network:gsub(' ', spaceDelimiter) .. '"'
	)
end

-- Remove menu item of given channel. Removes network menu if no other channels ignored in network
local function remove_ignored_channel_menu(channel, network)
	local networkShouldBeRemoved = true
	for name, value in pairs(hexchat.pluginprefs) do
		if name:sub(0, 20) == 'ignoreNotifications_' then
			local nameArray = convert_preference_to_table(name)
			if nameArray[2] == network then
				networkShouldBeRemoved = false
			end
		end
	end
	if networkShouldBeRemoved == true then
		hexchat.command(
			'menu del "Settings/Ignoring Notifications/Currently Ignored Channels/' .. network .. '"'
		)
	else
		hexchat.command(
			'menu del "Settings/Ignoring Notifications/Currently Ignored Channels/' .. network .. '/' .. channel .. '"'
		)
	end
end

-- Generated menu of ignored channels from pluginprefs
local function generate_ignored_menu()
	for name, value in pairs(hexchat.pluginprefs) do
		if name:sub(0, 20) == 'ignoreNotifications_' then
			local nameArray = convert_preference_to_table(name)
			add_ignored_channel_menu(nameArray[1], nameArray[2])
		end
	end
end

----------------------------------------------------
-- Menu loading and unloading
----------------------------------------------------

-- Loads all the menus
local function load_menus()
	hexchat.command('menu add "Settings/Ignoring Notifications"')
	hexchat.command(
		'menu add "Settings/Ignoring Notifications/Ignore Current Channel" "ignoreNotifications"'
	)
	hexchat.command(
		'menu add "Settings/Ignoring Notifications/Currently Ignored Channels"'
	)
	generate_ignored_menu()
end

-- Unload handler
local function unload_menus()
	hexchat.command('menu del "Settings/Ignoring Notifications"')
end

----------------------------------------------------
-- Text event handlers
----------------------------------------------------

-- Will check if channel is to be ignored, then emits print and eats everything else
-- (event should be non-notification version of notification)
local function check_notifications(args, attrs, event)
	local channel = hexchat.get_info('channel')
	local network = hexchat.get_info('network')
	if isIgnored(channel, network) then
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
	local returnArray = {}
	returnArray[1] = hexchat.get_info('channel')
	returnArray[2] = hexchat.get_info('network')
	if word[2] then
		returnArray[1] = word[2]:gsub(spaceDelimiter, ' ')
	end
	if word[3] then
		returnArray[2] = word[3]:gsub(spaceDelimiter, ' ')
	end
	return returnArray
end

-- Will set channel to ignore notifications
local function ignore_notifications_cb(word)
	local infoArray = callback_handler(word)
	set_channel_preference(infoArray[1], infoArray[2], 'ignore')
	add_ignored_channel_menu(infoArray[1], infoArray[2])
end

-- Will set channel to unignore notifications
local function unignore_notifications_cb(word)
	local infoArray = callback_handler(word)
	set_channel_preference(infoArray[1], infoArray[2], nil)
	remove_ignored_channel_menu(infoArray[1], infoArray[2])
end

-- Will print out if a channel is ignored or not
local function check_notifications_cb(word)
	local infoArray = callback_handler(word)
	if isIgnored(infoArray[1], infoArray[2]) then
		print(
			'Channel ',
			infoArray[1],
			' of network ',
			infoArray[2],
			' is ignored.'
		)
	else
		print(
			'Channel ',
			infoArray[1],
			' of network ',
			infoArray[2],
			' is not ignored.'
		)
	end
end

-- Resets pluginprefs
local function reset_plugin_prefs_cb()
	reset_plugin_prefs()
	unload_menus()
	load_menus()
end

-- Prints out hexchat.pluginprefs in human readable format
local function debug_plugin_prefs_cb()
	print(dump(hexchat.pluginprefs))
end

----------------------------------------------------
-- Command hooks
----------------------------------------------------

hexchat.hook_command(
	'ignoreNotifications',
	ignore_notifications_cb,
	'Usage: ignoreNotifications [channel] [network]\n\tStarts ignoring notifications for channel. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'unignoreNotifications',
	unignore_notifications_cb,
	'Usage: unignoreNotifications [channel] [network]\n\tStops ignoring notifications for channel. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkIgnoreNotifications',
	check_notifications_cb,
	'Usage: checkIgnoreNotifications [channel] [network]\n\tChecks if notifications are ignored for channel. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'resetIgnoreNotifications',
	reset_plugin_prefs_cb,
	'Usage: resetIgnoreNotifications\n\tWill reset the plugin preferences and remove all channels from being ignored. '
)
hexchat.hook_command(
	'debugIgnoreNotifications',
	debug_plugin_prefs_cb,
	'Usage: debugIgnoreNotifications\n\tWill print out plugin preferences.'
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
