-- SPDX-License-Identifier: MIT
local version = '0.0.1'

hexchat.register(
	'Ignore Text Events',
	version,
	'Allows you to selectively ignore text events on a per channel, per network, or global basis'
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
local preferencesSubDelimiter = ';;;;;;'
-- Prefix for channel keys in preferences
local preferencesPrefix = 'ignoreTextEvents_type:'
-- Array-like table of text event strings
local listOfTextEvents =
	{
		'Add Notify',
		'Ban List',
		'Banned',
		'Beep',
		'Capability Acknowledgement',
		'Capability Deleted',
		'Capability List',
		'Capability Request',
		'Change Nick',
		'Channel Action',
		'Channel Action Hilight',
		'Channel Ban',
		'Channel Creation',
		'Channel DeHalfOp',
		'Channel DeOp',
		'Channel DeVoice',
		'Channel Exempt',
		'Channel Half-Operator',
		'Channel INVITE',
		'Channel List',
		'Channel Message',
		'Channel Mode Generic',
		'Channel Modes',
		'Channel Msg Hilight',
		'Channel Notice',
		'Channel Operator',
		'Channel Quiet',
		'Channel Remove Exempt',
		'Channel Remove Invite',
		'Channel Remove Keyword',
		'Channel Remove Limit',
		'Channel Set Key',
		'Channel Set Limit',
		'Channel UnBan',
		'Channel UnQuiet',
		'Channel Url',
		'Channel Voice',
		'Connected',
		'Connecting',
		'Connection Failed',
		'CTCP Generic',
		'CTCP Generic to Channel',
		'CTCP Send',
		'CTCP Sound',
		'CTCP Sound to Channel',
		'DCC CHAT Abort',
		'DCC CHAT Connect',
		'DCC CHAT Failed',
		'DCC CHAT Offer',
		'DCC CHAT Offering',
		'DCC CHAT Reoffer',
		'DCC Conection Failed',
		'DCC Generic Offer',
		'DCC Header',
		'DCC Malformed',
		'DCC Offer',
		'DCC Offer Not Valid',
		'DCC RECV Abort',
		'DCC RECV Complete',
		'DCC RECV Connect',
		'DCC RECV Failed',
		'DCC RECV File Open Error',
		'DCC Rename',
		'DCC RESUME Request',
		'DCC SEND Abort',
		'DCC SEND Complete',
		'DCC SEND Connect',
		'DCC SEND Failed',
		'DCC SEND Offer',
		'DCC Stall',
		'DCC Timeout',
		'Delete Notify',
		'Disconnected',
		'Found IP',
		'Generic Message',
		'Ignore Add',
		'Ignore Changed',
		'Ignore Footer',
		'Ignore Header',
		'Ignore Remove',
		'Ignorelist Empty',
		'Invite',
		'Invited',
		'Join',
		'Keyword',
		'Kick',
		'Killed',
		'Message Send',
		'Motd',
		'MOTD Skipped',
		'Nick Clash',
		'Nick Erroneous',
		'Nick Failed',
		'No DCC',
		'No Running Process',
		'Notice',
		'Notice Send',
		'Notify Away',
		'Notify Back',
		'Notify Empty',
		'Notify Header',
		'Notify Number',
		'Notify Offline',
		'Notify Online',
		'Open Dialog',
		'Part',
		'Part with Reason',
		'Ping Reply',
		'Ping Timeout',
		'Private Action',
		'Private Action to Dialog',
		'Private Message',
		'Private Message to Dialog',
		'Process Already Running',
		'Quit',
		'Raw Modes',
		'Receive Wallops',
		'Resolving User',
		'SASL Authenticating',
		'SASL Response',
		'Server Connected',
		'Server Error',
		'Server Lookup',
		'Server Notice',
		'Server Text',
		'SSL Message',
		'Stop Connection',
		'Topic',
		'Topic Change',
		'Topic Creation',
		'Unknown Host',
		'User Limit',
		'Users On Channel',
		'WhoIs Authenticated',
		'WhoIs Away Line',
		'WhoIs Channel/Oper Line',
		'WhoIs End',
		'WhoIs Identified',
		'WhoIs Idle Line',
		'WhoIs Idle Line with Signon',
		'WhoIs Name Line',
		'WhoIs Real Host',
		'WhoIs Server Line',
		'WhoIs Special',
		'You Join',
		'You Kicked',
		'You Part',
		'You Part with Reason',
		'Your Action',
		'Your Invitation',
		'Your Message',
		'Your Nick Changing',
	}

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

-- Removes whitespace around string s
local function trim(s)
	return (s:gsub('^%s*(.-)%s*$', '%1'))
end

-- Checks if table tab has value val, return false if not
local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Returns index of val in table tab or nil if not found
local function find(tab, val)
	for i, v in pairs(tab) do
		if v == val then
			return i
		end
	end
	return nil
end

----------------------------------------------------
-- Plugin preferences: general
----------------------------------------------------

-- For future proofing in case a reset is ever needed
hexchat.pluginprefs['version'] = 'v' .. version

-- Resets all plugin preferences
local function reset_plugin_prefs()
	for a, b in pairs(hexchat.pluginprefs) do
		hexchat.pluginprefs[a] = nil
	end
end

----------------------------------------------------
-- Plugin preferences: set and get from database
----------------------------------------------------

-- Returns preferences key lookup string
local function db_compose_preferences_key(keyType, networkOrTextEvent, channel)
	if keyType == 'channel' then
		return preferencesPrefix .. keyType .. preferencesDelimiter .. networkOrTextEvent .. preferencesDelimiter .. channel
	elseif keyType == 'network' then
		return preferencesPrefix .. keyType .. preferencesDelimiter .. networkOrTextEvent
	elseif keyType == 'textevent' then
		return preferencesPrefix .. keyType .. preferencesDelimiter .. networkOrTextEvent
	else
		return preferencesPrefix .. keyType
	end
end

-- Returns text events string to array
local function db_text_events_prefsvaluestring_to_array(eventsString)
	local returnArray = split(eventsString, ',')
	return returnArray
end

-- Returns text events array to string
local function db_text_events_array_to_prefsvaluestring(eventsArray)
	local returnString = ''
	for key, value in pairs(eventsArray) do
		returnString = returnString .. value
	end
	return returnString
end

-- Get pluginprefs value based on keyType
local function db_get_preference_valuestring(
keyType,
	networkOrTextEvent,
	channel
)
	local pref = false
	pref =
		hexchat.pluginprefs[db_compose_preferences_key(
			keyType,
			networkOrTextEvent,
			channel
		)]
	if pref then
		return pref
	end
	return ''
end

-- Set pluginprefs value based on keyType
local function db_set_preference_valuestring(
keyType,
	value,
	networkOrTextEvent,
	channel
)
	hexchat.pluginprefs[db_compose_preferences_key(
			keyType,
			networkOrTextEvent,
			channel
		)]
	= value
end

----------------------------------------------------
-- Models: text event
----------------------------------------------------
-- TODO Go through line by line from model add and figure out if this is right
-- Value format: bool||||||n1,n3,n3||||||c1;;;;;;nc1,c2;;;;;;nc2,c3;;;;;;nc3
local function modelte_convert_eventtype_value_to_table(value)
	local splitTable = split(value, preferencesDelimiter)
	if #splitTable == 3 then
		local formattedTable = {}
		formattedTable['global'] = splitTable[1]
		formattedTable['networks'] = split(splitTable[2], ',')
		local channetUndelim = split(splitTable[3], ',')
		formattedTable['channels'] = {}
		for i, v in pairs(channetUndelim) do
			local channetPair = split(v, ';;;;;;')
			table.insert(formattedTable['channels'], {
				channel = channetPair[1],
				network = channetPair[2],
			})
		end
		return formattedTable
	else
		return {
			global = 'false',
			networks = {},
			channels = {},
		}
	end
end

local function modelte_convert_eventtype_table_to_value(theTable)
	local returnString = ''
	returnString = returnString .. theTable['global'] .. preferencesDelimiter
	for i, network in pairs(theTable['networks']) do
		returnString = returnString .. network
		if not (i == #theTable['networks']) then
			returnString = returnString .. ','
		end
	end
	for i, channet in pairs(theTable['networks']) do
		returnString =
			returnString .. channet['channel'] .. preferencesSubDelimiter .. channet['network']
		if not (i == #theTable['networks']) then
			returnString = returnString .. ','
		end
	end
	return returnString
end

local function modelte_set_preference_events_add_event(
keyType,
	event,
	network,
	channel
)
	local eventValue = db_get_preference_valuestring('textevent', event)
	local formattedTable = modelte_convert_eventtype_value_to_table(eventValue)
	if keyType == 'global' then
		formattedTable['global'] = 'true'
	elseif keyType == 'network' then
		table.insert(formattedTable['networks'], network)
	else
		table.insert(formattedTable['channels'], {
			channel = channel,
			network = network,
		})
	end
	local formattedTextEventValue =
		modelte_convert_eventtype_table_to_value(formattedTable)
	db_set_preference_valuestring('textevent', formattedTextEventValue, event)
end

local function modelte_set_preference_events_remove_event(
keyType,
	event,
	network,
	channel
)
	local eventValue = db_get_preference_valuestring('textevent', event)
	local formattedTable = modelte_convert_eventtype_value_to_table(eventValue)
	if keyType == 'global' then
		formattedTable['global'] = 'false'
	-- Set to nil when all done and set hook event gone
	elseif keyType == 'network' then
		table.remove(
			formattedTable['network'],
			find(formattedTable['network'], event)
		)
	else
		table.remove(
			formattedTable['network'],
			find(formattedTable['network'], event)
		)
	end
	local formattedTextEventValue =
		modelte_convert_eventtype_table_to_value(formattedTable)
	db_set_preference_valuestring('textevent', formattedTextEventValue, event)
end

----------------------------------------------------
-- Models: Channel/network aka Channet
----------------------------------------------------

-- Convert pluginprefs channel/network key to table with corresponding keys
local function modelchannet_convert_preference_channetkey_to_table(
keyType,
	setting
)
	local settingsArray = split(setting, preferencesDelimiter)
	local chanNetTable = { network = settingsArray[2] }
	if keyType == 'channel' then
		chanNetTable['channel'] = settingsArray[3]
	end
	return chanNetTable
end

local function modelchannet_get_preference_events_values_array(
keyType,
	network,
	channel
)
	return db_text_events_prefsvaluestring_to_array(
		db_get_preference_valuestring(keyType, network, channel)
	)
end

local function modelchannet_is_set_to_ignore_channet(event, network, channel)
	local currentNetworkIgnoredEvents =
		modelchannet_get_preference_events_values_array('network', network)
	if has_value(currentNetworkIgnoredEvents, event) then
		return true
	else
		local currentChannelIgnoredEvents =
			modelchannet_get_preference_events_values_array(
				'channel',
				network,
				channel
			)
		if has_value(currentChannelIgnoredEvents, event) then
			return true
		end
	end
	return false
end

-- Iterates through channel or network preferences and passes their names and values to given function
local function modelchannet_iterate_channet_prefs_over_lambda(keyType, lambda)
	for name, value in pairs(hexchat.pluginprefs) do
		if name:sub(
			0,
			string.len(preferencesPrefix) + string.len(keyType)
		) == (preferencesPrefix .. keyType) then
			lambda(name, value)
		end
	end
end

----------------------------------------------------
-- Models: Global
----------------------------------------------------

local function modelglobal_is_set_to_ignore_global(event)
	local currentIgnoredEvents =
		modelchannet_get_preference_events_values_array('global')
	return has_value(currentIgnoredEvents, event)
end

----------------------------------------------------
-- Models: add/remove
---------------------------------------------------

local function models_add_event(keyType, event, network, channel)
	local previousValueTable =
		modelchannet_get_preference_events_values_array(
			keyType,
			network,
			channel
		)
	table.insert(previousValueTable, event)
	local newValue =
		db_text_events_array_to_prefsvaluestring(previousValueTable)
	db_set_preference_valuestring(keyType, newValue, network, channel)
	modelte_set_preference_events_add_event(keyType, event, network, channel)
end

local function models_remove_event(keyType, event, network, channel)
	local previousValueTable =
		modelchannet_get_preference_events_values_array(
			keyType,
			network,
			channel
		)
	table.remove(previousValueTable, find(previousValueTable, event))
	local newValue =
		db_text_events_array_to_prefsvaluestring(previousValueTable)
	db_set_preference_valuestring(keyType, newValue, network, channel)
	modelte_set_preference_events_remove_event(event)
	return previousValueTable
end

----------------------------------------------------
-- Views: Menu manipulation
----------------------------------------------------

local function views_add_text_events_to_channel_menu(
menu,
	events,
	action,
	actionIdent
)
	local eventsArray = events
	if type(events) == 'string' then
		eventsArray = db_text_events_prefsvaluestring_to_array(events)
	end
	for key, event in pairs(eventsArray) do
		hexchat.command(
			'menu -t1 add "' .. menu .. event .. '" "" "' .. action .. ' ' .. event:gsub(
				' ',
				spaceDelimiter
			) .. ' ' .. actionIdent .. '"'
		)
	end
end

local function views_add_ignored_channel_menu(network, channel, events)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '"'
	)
	views_add_text_events_to_channel_menu(
		'Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '/' .. channel .. '/',
		events,
		'stopIgnoringEvent',
		'channel ' .. channel:gsub(' ', spaceDelimiter) .. ' ' .. network:gsub(
			' ',
			spaceDelimiter
		)
	)
end

local function views_add_ignored_network_menu(network, events)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network .. '"'
	)
	views_add_text_events_to_channel_menu(
		'Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network .. '/',
		events,
		'stopIgnoringEvent',
		'network ' .. network:gsub(' ', spaceDelimiter)
	)
end

local function views_remove_ignored_channel_menu(
network,
	channel,
	textEventsArray
)
	if #textEventsArray > 1 then
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '/' .. channel .. '/' .. event .. '"'
		)
	else
		local networkShouldBeRemoved = true
		local iterateOver = function(name, value)
			local chanNetTable =
				modelchannet_convert_preference_channetkey_to_table(
					'channel',
					name
				)
			if chanNetTable['network'] == network then
				networkShouldBeRemoved = false
			end
		end
		modelchannet_iterate_channet_prefs_over_lambda(iterateOver)
		if networkShouldBeRemoved == true then
			hexchat.command(
				'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '"'
			)
		else
			hexchat.command(
				'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '/' .. channel .. '"'
			)
		end
	end
end

local function views_remove_ignored_network_menu(network, textEventsArray)
	if #textEventsArray > 1 then
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network .. '/' .. event .. '"'
		)
	else
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network .. '"'
		)
	end
end

----------------------------------------------------
-- Views: Menu generation
----------------------------------------------------

-- Generated menu of channels with ignored text events from pluginprefs
local function views_generate_currently_ignored_channel_menu()
	local iterateOver = function(name, value)
		local chanNetTable =
			modelchannet_convert_preference_channetkey_to_table('channel', name)
		views_add_ignored_channel_menu(
			chanNetTable['network'],
			chanNetTable['channel'],
			value
		)
	end
	modelchannet_iterate_channet_prefs_over_lambda('channel', iterateOver)
end

-- Generated menu of channels with ignored text events from pluginprefs
local function views_generate_currently_ignored_network_menu()
	local iterateOver = function(name, value)
		local chanNetTable =
			modelchannet_convert_preference_channetkey_to_table('network', name)
		views_add_ignored_network_menu(chanNetTable['network'], value)
	end
	modelchannet_iterate_channet_prefs_over_lambda('channel', iterateOver)
end

local function views_generate_context_menu(context)
	for key, event in pairs(listOfTextEvents) do
		local formattedEvent = event:gsub(' ', spaceDelimiter)
		local commandString =
			'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/' .. context .. '/' .. event .. '" '
		commandString =
			commandString .. '"startIgnoringEvent ' .. context:lower() .. ' ' .. formattedEvent .. '"'
		hexchat.command(commandString)
	end
end

-- Generated menu of global text events with already ignored ones toggled
local function views_generate_global_menu()
	local globalIgnoredEvents =
		modelchannet_get_preference_events_values_array('global')
	for key, event in pairs(listOfTextEvents) do
		local formattedEvent = event:gsub(' ', spaceDelimiter)
		local commandString = 'menu '
		if has_value(globalIgnoredEvents, event) then
			commandString = commandString .. '-t1'
		else
			commandString = commandString .. '-t0'
		end
		commandString =
			commandString .. ' add "Settings/Ignore Text Events/Toggle Events Ignored Globally/' .. event .. '" '
		commandString =
			commandString .. '"startIgnoringEvent global ' .. formattedEvent .. '"'
		commandString =
			commandString .. '"stopIgnoringEvent global ' .. formattedEvent .. '"'
		hexchat.command(commandString)
	end
end

----------------------------------------------------
-- Views: add/remove event
----------------------------------------------------

local function views_add_event(keyType, event, network, channel)
	if keyType == 'network' then
		views_add_ignored_network_menu(network, { event })
	elseif keyType == 'channel' then
		views_add_ignored_channel_menu(network, channel, { event })
	end
end

local function views_remove_event(
keyType,
	updatedModelTextEventsTable,
	network,
	channel
)
	if keyType == 'network' then
		views_remove_ignored_network_menu(network, updatedModelTextEventsTable)
	elseif keyType == 'channel' then
		views_remove_ignored_channel_menu(
			network,
			channel,
			updatedModelTextEventsTable
		)
	end
end

----------------------------------------------------
-- Views: Menu init and unloading
----------------------------------------------------

-- Loads all the menus
local function views_load_menus()
	hexchat.command('menu add "Settings/Ignore Text Events"')

	hexchat.command(
		'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current"'
	)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/Channel"'
	)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/Network"'
	)

	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In"'
	)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels"'
	)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Networks"'
	)

	hexchat.command(
		'menu add "Settings/Ignore Text Events/Toggle Events Ignored Globally"'
	)
	views_generate_currently_ignored_channel_menu()
	views_generate_currently_ignored_network_menu()
	views_generate_context_menu('Channel')
	views_generate_context_menu('Network')
	views_generate_global_menu()
end

-- Unload handler
local function views_unload_menus()
	hexchat.command('menu del "Settings/Ignore Text Events"')
end

----------------------------------------------------
-- Hooks: Text event handlers
----------------------------------------------------

local function kill_event()
	return hexchat.EAT_ALL
end

local function check_if_ignored(ignoredData)
	if ignoredData.global == true then
		return kill_event()
	else
		local network = hexchat.get_info('network')
		if has_value(ignoredData.networks, network) then
			return kill_event()
		else
			local channel = hexchat.get_info('channel')
			if has_value(ignoredData.channels, channel) then
				return kill_event()
			end
		end
	end
end

----------------------------------------------------
-- Hooks: Add/remove channels/networks/global
----------------------------------------------------
-- Some way to create all the hooks when this loads up without having to do silly lookups
-- Performant way to add and remove
-- Added all preference above, remove if not using
-- Instead of using all, use textevent type

local function hooks_add_event_hook(event, type, network, channel)
	-- hexchat.hook_print(
	-- 	'Channel Msg Hilight',
	-- 	function()
	-- 		local ignoredData = {
	-- 			global = false,
	-- 			networks = {},
	-- 			channels = {},
	-- 		}
	-- 		return check_if_ignored(ignoredData)
	-- 	end,
	-- 	hexchat.PRI_HIGHEST
	-- )
end

local function hooks_remove_event_hook(event, type, network, channel)
	--
end

----------------------------------------------------
-- Controller
----------------------------------------------------

local function controller_add_text_event_to_ignore(
keyType,
	event,
	network,
	channel
)
	models_add_event(keyType, event, network, channel)
	views_add_event(keyType, event, network, channel)
	hooks_add_event_hook()
end

local function controller_remove_text_event_to_ignore(
keyType,
	event,
	network,
	channel
)
	local updatedModelTextEventsTable =
		models_remove_event(keyType, event, network, channel)
	views_remove_event(keyType, updatedModelTextEventsTable, network, channel)
	hooks_remove_event_hook()
end

local function controller_init()
	hexchat.hook_unload(views_unload_menus)
	views_load_menus()
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
		returnArray['keyType'] = trim(word[2]:gsub(spaceDelimiter, ' '))
	end
	if word[3] then
		returnArray['event'] = trim(word[3]:gsub(spaceDelimiter, ' '))
	end
	if word[4] then
		returnArray['network'] = trim(word[3]:gsub(spaceDelimiter, ' '))
	end
	if word[5] then
		returnArray['channel'] = trim(word[3]:gsub(spaceDelimiter, ' '))
	end
	return returnArray
	-- TODO sanitize event against event list
end

local function start_ignoring_event_cb(word)
	local infoArray = callback_handler(word)
	controller_add_text_event_to_ignore(
		infoArray['keyType'],
		infoArray['event'],
		infoArray['network'],
		infoArray['channel']
	)
end

local function stop_ignoring_event_cb(word)
	local infoArray = callback_handler(word)
	controller_remove_text_event_to_ignore(
		infoArray['keyType'],
		infoArray['event'],
		infoArray['network'],
		infoArray['channel']
	)
end

local function check_event_ignored_context_cb(word)
	local infoArray = callback_handler(word)
	-- if isSetToConvert(infoArray['channel'], infoArray['network']) then
	-- 	print(
	-- 		'Channel ',
	-- 		infoArray['channel'],
	-- 		' of network ',
	-- 		infoArray['network'],
	-- 		' is converting highlights to regular text events.'
	-- 	)
	-- else
	-- 	print(
	-- 		'Channel ',
	-- 		infoArray['channel'],
	-- 		' of network ',
	-- 		infoArray['network'],
	-- 		' is not converting highlights.'
	-- 	)
	-- end
end

local function check_event_ignored_cb(word)
	-- word[2] is event
end

local function list_events_ignored_cb()
	--
	-- | Network | Channel | Event |
end

-- Resets pluginprefs
local function reset_plugin_prefs_cb()
	reset_plugin_prefs()
	views_unload_menus()
	views_load_menus()
	print('Ignore Text Events: Reset complete')
	-- TODO version
end

-- Prints out hexchat.pluginprefs in human readable format
local function debug_plugin_prefs_cb()
	print(dump(hexchat.pluginprefs))
end

----------------------------------------------------
-- Command hooks
----------------------------------------------------

hexchat.hook_command(
	'startIgnoringEvent',
	start_ignoring_event_cb,
	'Usage: startIgnoringEvent type event [network] [channel]\n\tStarts ignoring given event for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'stopIgnoringEvent',
	stop_ignoring_event_cb,
	'Usage: stopIgnoringEvent type event [network] [channel]\n\tStops ignoring given event for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkEventIgnoredAtContext',
	check_event_ignored_context_cb,
	'Usage: checkEventIgnored type event [network] [channel]\n\tChecks if given event is ignored for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkEventIgnored',
	check_event_ignored_cb,
	'Usage: checkEventIgnored event\n\tChecks if given event is ignored at all. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'listEventsIgnored',
	list_events_ignored_cb,
	'Usage: listEventsIgnored\n\tLists all text events that are ignored and where they are ignored. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'resetIgnoreTextEvents',
	reset_plugin_prefs_cb,
	'Usage: resetIgnoreTextEvents\n\tWill reset the plugin preferences and remove all text events from being ignored.'
)
hexchat.hook_command(
	'debugIgnoreTextEvents',
	debug_plugin_prefs_cb,
	'Usage: debugIgnoreTextEvents\n\tWill print out plugin preferences.'
)

----------------------------------------------------
-- Text event hooks
----------------------------------------------------

-- Hook and unhook when loading and when calling commands
-- Hook should already have the type of hook pushed into it (global, network, channel)
-- Should store list of networks and channels and also push those
-- Massive table object

-- Improve unhighlight with event hook/unhook method
-- Improve unhighlight with list channels

----------------------------------------------------
-- Init
----------------------------------------------------
controller_init()
