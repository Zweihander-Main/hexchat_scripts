----------------------------------------------------
-- Command callbacks
----------------------------------------------------

local commandCallbacks = {}

local util = require'utilities.lua'
local const = require'constants.lua'
local controller = require'controller.lua'
local views = require'views.lua'
local db = require'db.lua'

-- Uses default context unless arguments supplied.
-- Converts arguments if they're coming from menu
local function callback_handler(word)
	local returnArray = {
		channel = hexchat.get_info('channel'),
		network = hexchat.get_info('network'),
	}
	if word[2] then
		returnArray['keyType'] =
			util.trim(word[2]:gsub(const.spaceDelimiter, ' '))
	end
	if word[3] then
		returnArray['event'] =
			util.trim(word[3]:gsub(const.spaceDelimiter, ' '))
	end
	if word[4] then
		returnArray['network'] =
			util.trim(word[4]:gsub(const.spaceDelimiter, ' '))
	end
	if word[5] then
		returnArray['channel'] =
			util.trim(word[5]:gsub(const.spaceDelimiter, ' '))
	end
	return returnArray
	-- TODO sanitize event against event list
end

function commandCallbacks.start_ignoring_event_cb(word)
	local infoArray = callback_handler(word)
	if infoArray['keyType'] == 'channel' then
		controller.add_event(
			infoArray['keyType'],
			infoArray['event'],
			infoArray['network'],
			infoArray['channel']
		)
	elseif infoArray['keyType'] == 'network' then
		controller.add_event(
			infoArray['keyType'],
			infoArray['event'],
			infoArray['network']
		)
	else
		controller.add_event(infoArray['keyType'], infoArray['event'])
	end
end

function commandCallbacks.stop_ignoring_event_cb(word)
	local infoArray = callback_handler(word)
	if infoArray['keyType'] == 'channel' then
		controller.remove_event(
			infoArray['keyType'],
			infoArray['event'],
			infoArray['network'],
			infoArray['channel']
		)
	elseif infoArray['keyType'] == 'network' then
		controller.remove_event(
			infoArray['keyType'],
			infoArray['event'],
			infoArray['network']
		)
	else
		controller.remove_event(infoArray['keyType'], infoArray['event'])
	end
end

function commandCallbacks.check_event_ignored_context_cb(word)
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

function commandCallbacks.check_event_ignored_cb(word)
	-- word[2] is event
end

function commandCallbacks.list_events_ignored_cb()
	--
	-- | Network | Channel | Event |
end

-- Resets pluginprefs
function commandCallbacks.reset_plugin_prefs_cb()
	db.reset()
	views.unload_menus()
	views.load_menus()
	print('Ignore Text Events: Reset complete')
	-- TODO version
end

-- Prints out hexchat.pluginprefs in human readable format
function commandCallbacks.debug_plugin_prefs_cb()
	print(util.dump(hexchat.pluginprefs))
end

return commandCallbacks
