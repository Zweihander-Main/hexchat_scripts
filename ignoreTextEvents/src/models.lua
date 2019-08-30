local models = {}

local channetg = require'models_channetg.lua'
local te = require'models_textEvent.lua'
local db = require'db.lua'

--!
--! @brief      Adds an event to both model types.
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
--! @return     { description_of_the_return_value }
--!
function models.add_event(keyType, event, network, channel)
	channetg.add_event(keyType, event, network, channel)
	te.add_event(keyType, event, network, channel)
end

--!
--! @brief      Removes an event from both models types.
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
--! @return     [string array of events in current context]
--!
function models.remove_event(keyType, event, network, channel)
	local updatedValueTable =
		channetg.remove_event(keyType, event, network, channel)
	te.remove_event(keyType, event, network, channel)
	return updatedValueTable
end

--!
--! @brief      Resets the database.
--!
function models.reset()
	db.reset()
end

--!
--! @brief      Prints out information from database.
--!
function models.debug()
	db.debug()
end

--!
--! @brief      Iterates lambda over text event information.
--!
--! @param      lambda  The lambda -- see models_te for info
--!
function models.iterate_over_all_event_data(lambda)
	te.iterate_over_lambda(lambda)
end

--!
--! @brief      Sets the version in the database
--!
--! @param      version  The version string
--!
function models.set_version(version)
	db.set_version(version)
end

return models
