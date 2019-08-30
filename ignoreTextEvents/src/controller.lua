----------------------------------------------------
-- Controller
----------------------------------------------------

local controller = {}
local views = require'views.lua'
local models = require'models.lua'
local hooks = require'hooks.lua'

local controller_version = ''

function controller.add_event(keyType, event, network, channel)
	models.add_event(keyType, event, network, channel)
	views.add_event(keyType, event, network, channel)
	hooks.add_event_hook(keyType, event, network, channel)
end

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

function controller.init()
	models.set_version(controller_version)
	hexchat.hook_unload(views.unload_menus)
	views.load_menus()
	hooks.load_all_hooks()
end

function controller.reset()
	models.reset()
	models.set_version(controller_version)
	views.unload_menus()
	hooks.reset()
	views.load_menus()
end

function controller.debug()
	models.debug()
	hooks.debug()
end

function controller.get_event_data(event)
	return hooks.get_event_data(event)
end

function controller.iterate_over_all_event_data(lambda)
	models.iterate_over_all_event_data(lambda)
end

function controller.set_version(version)
	controller_version = version
end

return controller
