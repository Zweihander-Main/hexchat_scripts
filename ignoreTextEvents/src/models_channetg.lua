local models_channetg = {}

local db = require'db.lua'
local db_utils = require'db_utils.lua'
local util = require'utilities.lua'
----------------------------------------------------
-- Models: Channel/network/global aka Channetg
--
-- DB model:
-- ignoreTextEvents_type:channel/network,
-- network name,
-- (if channel) channel name
-- =
-- list of text events TODO with comma splitter
----------------------------------------------------

-- TODO something wrong here, stopIgnoringEvent callback is somehow saved?

function models_channetg.get_events_array(keyType, network, channel)
	return db_utils.comma_delim_string_to_array(
		db.get_preference_valuestring(keyType, network, channel)
	)
end

function models_channetg.add_event(keyType, event, network, channel)
	local previousValueTable =
		models_channetg.get_events_array(keyType, network, channel)
	if previousValueTable ~= nil and next(
		previousValueTable
	) ~= nil and previousValueTable[1] ~= '' then
		table.insert(previousValueTable, event)
	else
		previousValueTable = { event }
	end
	local newValue = db_utils.array_to_comma_delim_string(previousValueTable)
	db.set_preference_valuestring(keyType, newValue, network, channel)
end

function models_channetg.remove_event(keyType, event, network, channel)
	local previousValueTable =
		models_channetg.get_events_array(keyType, network, channel)
	table.remove(previousValueTable, util.find(previousValueTable, event))
	local newValue = db_utils.array_to_comma_delim_string(previousValueTable)
	db.set_preference_valuestring(keyType, newValue, network, channel)
	return previousValueTable
end

--
-- local function modelchannet_is_set_to_ignore_channet(event, network, channel)
-- 	local currentNetworkIgnoredEvents =
-- 		modelchannet_get_preference_events_values_array('network', network)
-- 	if has_value(currentNetworkIgnoredEvents, event) then
-- 		return true
-- 	else
-- 		local currentChannelIgnoredEvents =
-- 			modelchannet_get_preference_events_values_array(
-- 				'channel',
-- 				network,
-- 				channel
-- 			)
-- 		if has_value(currentChannelIgnoredEvents, event) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

return models_channetg
