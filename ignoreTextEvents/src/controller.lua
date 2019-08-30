local controller = {}
local views = require'views.lua'
local models = require'models.lua'
local hooks = require'hooks.lua'

local controller_version = ''

--!
--! @brief      Adds an event to relevant models, views, and hooks.
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
function controller.add_event(keyType, event, network, channel)
	models.add_event(keyType, event, network, channel)
	views.add_event(keyType, event, network, channel)
	hooks.add_event_hook(keyType, event, network, channel)
end

--!
--! @brief      Removes an event from relevant models, views, and hooks
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
function controller.remove_event(keyType, event, network, channel)
	local updatedModelTextEventsTable =
		models.remove_event(keyType, event, network, channel)
	views.remove_event(
		keyType,
		updatedModelTextEventsTable,
		event,
		network,
		channel
	)
	hooks.remove_event_hook(keyType, event, network, channel)
end

--!
--! @brief      Loads saved data, creates menus, loads hooks based on saved data
--!
function controller.init()
	models.set_version(controller_version)
	hexchat.hook_unload(views.unload_menus)
	views.load_menus()
	hooks.load_all_hooks()
end

--!
--! @brief      Resets all saved data, resets menus, resets hooks
--!
function controller.reset()
	models.reset()
	models.set_version(controller_version)
	views.unload_menus()
	hooks.reset()
	views.load_menus()
end

--!
--! @brief      Prints out debugging information from models and views
--!
function controller.debug()
	models.debug()
	hooks.debug()
end

--!
--! @brief      Gets data related to given event
--!
--! @param      event  The text event to pull data from
--!
function controller.get_event_data(event)
	return hooks.get_event_data(event)
end

--!
--! @brief      Iterates over all text event data with given lambda
--!
--! @param      lambda  The lambda, see models_te for details
--!
function controller.iterate_over_all_event_data(lambda)
	models.iterate_over_all_event_data(lambda)
end

--!
--! @brief      Sets the application version. Useful for future proofing.
--!
--! @param      version  The version string of the application to set
--!
function controller.set_version(version)
	controller_version = version
end

return controller
