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

--!
--! @brief      Gets the events ignored in current context in an array-like
--!             table
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
--! @return     [string]
--!
function models_channetg.get_events_array(keyType, network, channel)
	return db_utils.comma_delim_string_to_array(
		db.get_preference_valuestring(keyType, network, channel)
	)
end

--!
--! @brief      Adds an event to the channel/network/global models.
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
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

--!
--! @brief      Removes an event from channel/network/global models
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
--! @return     [array-like table of value strings]
--!
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

--!
--! @brief      Iterates all database values matching keyType over lambda. Key
--!             is converted to {channel=string,network=string} format.
--!
--! @param      keyType  The key type -- network, channel, global
--! @param      lambda   The lambda with two arguments roughly corresponding to
--!                      key,value
--!
function models_channetg.iterate_over_lambda(keyType, lambda)
	local model_lambda = function(name, value)
		local chanNetTable = db_utils.convert_key_to_table(name)
		lambda(chanNetTable, value)
	end
	db.iterate_prefs_over_lambda(keyType, model_lambda)
end

return models_channetg
