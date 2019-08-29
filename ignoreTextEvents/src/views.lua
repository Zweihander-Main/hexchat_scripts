local views = {}

local channet = require'models_channetg.lua'
local const = require'constants.lua'
local util = require'utilities.lua'
local db_utils = require'db_utils.lua'
local models = require'models.lua'
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
				commandToAdd .. 'Channels/' .. menuSettings.network:gsub(
					'/',
					'|'
				) .. '/' .. menuSettings.channel:gsub('/', '|') .. '/'
		else
			commandToAdd =
				commandToAdd .. 'Networks/' .. menuSettings.network:gsub(
					'/',
					'|'
				) .. '/'
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
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
			'/',
			'|'
		) .. '"'
	)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
			'/',
			'|'
		) .. '/' .. channel:gsub('/', '|') .. '"'
	)
	local menuSettings = {
		type = 'channel',
		channel = channel,
		network = network,
	}
	add_text_events_to_currently_ignored_in_menu(eventsString, menuSettings)
end

local function add_ignored_network_menu(network, eventsString)
	hexchat.command(
		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network:gsub(
			'/',
			'|'
		) .. '"'
	)
	local menuSettings = {
		type = 'network',
		network = network,
	}
	add_text_events_to_currently_ignored_in_menu(eventsString, menuSettings)
end

local function remove_ignored_channel_menu(
network,
	channel,
	textEventsArray,
	event
)
	if #textEventsArray > 0 then
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
				'/',
				'|'
			) .. '/' .. channel:gsub('/', '|') .. '/' .. event .. '"'
		)
	else
		local networkShouldBeRemoved = true
		local iterateOver = function(chanNetTable, value)
			if chanNetTable['network'] == network and value ~= nil and value ~= '' then
				networkShouldBeRemoved = false
			end
		end
		channet.iterate_over_lambda('channel', iterateOver)
		if networkShouldBeRemoved == true then
			hexchat.command(
				'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
					'/',
					'|'
				) .. '"'
			)
		else
			hexchat.command(
				'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
					'/',
					'|'
				) .. '/' .. channel:gsub('/', '|') .. '"'
			)
		end
	end
end

local function remove_ignored_network_menu(network, textEventsArray, event)
	if #textEventsArray > 1 then
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network:gsub(
				'/',
				'|'
			) .. '/' .. event .. '"'
		)
	else
		hexchat.command(
			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network:gsub(
				'/',
				'|'
			) .. '"'
		)
	end
end

----------------------------------------------------
-- Views: Menu generation
----------------------------------------------------

-- Generated menu of channels with ignored text events from pluginprefs
local function generate_currently_ignored_channel_menu()
	local iterateOver = function(chanNetTable, value)
		add_ignored_channel_menu(
			chanNetTable['network'],
			chanNetTable['channel'],
			value
		)
	end
	channet.iterate_over_lambda('channel', iterateOver)
end

-- Generated menu of channels with ignored text events from pluginprefs
local function generate_currently_ignored_network_menu()
	local iterateOver = function(chanNetTable, value)
		add_ignored_network_menu(chanNetTable['network'], value)
	end
	channet.iterate_over_lambda('network', iterateOver)
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
			commandString .. '"startIgnoringEvent global ' .. formattedEvent .. '" '
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
		add_ignored_network_menu(network, event)
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
