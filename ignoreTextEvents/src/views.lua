local views = {}

local channet = require'models_channetg.lua'
local const = require'constants.lua'
local util = require'utilities.lua'
local db_utils = require'db_utils.lua'
local db = require'db.lua'
----------------------------------------------------
-- Views: Menu manipulation
----------------------------------------------------

local function add_text_events_to_currently_ignored_in_menu(
eventsString,
	menuSettings
)
	local eventsArray = db_utils.comma_delim_string_to_array(eventsString)
	for key, event in pairs(eventsArray) do
		local commandToAdd =
			'menu -t1 add "Settings/Ignore Text Events/Events Currently Ignored In/'
		if (menuSettings.type == 'channel') then
			commandToAdd =
				commandToAdd .. 'Channels/' .. menuSettings.network .. '/' .. menuSettings.channel .. '/'
		else
			commandToAdd =
				commandToAdd .. 'Networks/' .. menuSettings.network .. '/'
		end

		commandToAdd =
			commandToAdd .. event .. '" "" "stopIgnoringEvent ' .. menuSettings.type .. ' ' .. event:gsub(
				' ',
				const.spaceDelimiter
			) .. ' ' .. menuSettings.network:gsub(' ', const.spaceDelimiter)

		if (menuSettings.type == 'channel') then
			commandToAdd =
				commandToAdd .. ' ' .. menuSettings.channel:gsub(
					' ',
					const.spaceDelimiter
				)
		end

		commandToAdd = commandToAdd .. '"'

		hexchat.command(commandToAdd)
	end
end

local function add_ignored_channel_menu(network, channel, eventsString)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '"'
	)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '/' .. channel .. '"'
	)
	local menuSettings = {
		type = 'channel',
		channel = channel,
		network = network,
	}
	add_text_events_to_currently_ignored_in_menu(eventsString, menuSettings)

	-- add_text_events_to_menu(
	-- 	'Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '/' .. channel .. '/',
	-- 	eventsString,
	-- 	'stopIgnoringEvent',
	-- 	'channel ' .. channel:gsub(
	-- 		' ',
	-- 		const.spaceDelimiter
	-- 	) .. ' ' .. network:gsub(' ', const.spaceDelimiter)
	-- )
end

local function add_ignored_network_menu(network, eventsString)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network .. '"'
	)
	local menuSettings = {
		type = 'network',
		network = network,
	}
	add_text_events_to_currently_ignored_in_menu(eventsString, menuSettings)
	-- add_text_events_to_menu(
	-- 	'Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network .. '/',
	-- 	eventsString,
	-- 	'stopIgnoringEvent',
	-- 	'network ' .. network:gsub(' ', const.spaceDelimiter)
	-- )
end

local function remove_ignored_channel_menu(
network,
	channel,
	textEventsArray,
	event
)
	if #textEventsArray > 1 then
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network .. '/' .. channel .. '/' .. event .. '"'
		)
	else
		local networkShouldBeRemoved = true
		local iterateOver = function(name, value)
			local chanNetTable = db_utils.convert_key_to_table(name)
			if chanNetTable['network'] == network then
				networkShouldBeRemoved = false
			end
		end
		db.iterate_prefs_over_lambda(iterateOver)
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

local function remove_ignored_network_menu(network, textEventsArray, event)
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
local function generate_currently_ignored_channel_menu()
	local iterateOver = function(name, value)
		local chanNetTable = db_utils.convert_key_to_table(name)
		add_ignored_channel_menu(
			chanNetTable['network'],
			chanNetTable['channel'],
			value
		)
	end
	db.iterate_prefs_over_lambda('channel', iterateOver)
end

-- Generated menu of channels with ignored text events from pluginprefs
local function generate_currently_ignored_network_menu()
	local iterateOver = function(name, value)
		local chanNetTable = db_utils.convert_key_to_table(name)
		add_ignored_network_menu(chanNetTable['network'], value)
	end
	db.iterate_prefs_over_lambda('network', iterateOver)
end

local function generate_context_menu(context)
	for key, event in pairs(const.listOfTextEvents) do
		local formattedEvent = event:gsub(' ', const.spaceDelimiter)
		local commandString =
			'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/' .. context .. '/' .. event .. '" '
		commandString =
			commandString .. '"startIgnoringEvent ' .. context:lower() .. ' ' .. formattedEvent .. '"'
		hexchat.command(commandString)
	end
end

-- Generated menu of global text events with already ignored ones toggled
local function generate_global_menu()
	local globalIgnoredEvents = channet.get_events_array('global')
	for key, event in pairs(const.listOfTextEvents) do
		local formattedEvent = event:gsub(' ', const.spaceDelimiter)
		local commandString = 'menu '
		if util.has_value(globalIgnoredEvents, event) then
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

function views.add_event(keyType, event, network, channel)
	if keyType == 'network' then
		add_ignored_network_menu(network, event) --TODO wtf table
	elseif keyType == 'channel' then
		add_ignored_channel_menu(network, channel, event)
	end
end

function views.remove_event(
keyType,
	updatedModelTextEventsTable,
	event,
	network,
	channel
)
	if keyType == 'network' then
		remove_ignored_network_menu(network, updatedModelTextEventsTable, event)
	elseif keyType == 'channel' then
		remove_ignored_channel_menu(
			network,
			channel,
			updatedModelTextEventsTable,
			event
		)
	end
end

----------------------------------------------------
-- Views: Menu init and unloading
----------------------------------------------------

-- Loads all the menus
function views.load_menus()
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
	generate_currently_ignored_channel_menu()
	generate_currently_ignored_network_menu()
	generate_context_menu('Channel')
	generate_context_menu('Network')
	generate_global_menu()
end

-- Unload handler
function views.unload_menus()
	hexchat.command('menu del "Settings/Ignore Text Events"')
end

return views
