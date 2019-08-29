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
-- list of text events
----------------------------------------------------

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
	if newValue == '' then
		newValue = nil
	end
	db.set_preference_valuestring(keyType, newValue, network, channel)
	return previousValueTable
end

function models_channetg.iterate_over_lambda(keyType, lambda)
	local model_lambda = function(name, value)
		local chanNetTable = db_utils.convert_key_to_table(name)
		lambda(chanNetTable, value)
	end
	db.iterate_prefs_over_lambda(keyType, model_lambda)
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
