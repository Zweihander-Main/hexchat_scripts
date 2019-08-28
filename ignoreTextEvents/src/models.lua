---------------------------------------------------
-- Models: add/remove
---------------------------------------------------

local models = {}

local channetg = require'models_channetg.lua'
local te = require'models_textEvent.lua'
local db = require'db.lua'

function models.add_event(keyType, event, network, channel)
	channetg.add_event(keyType, event, network, channel)
	te.add_event(keyType, event, network, channel)
end

function models.remove_event(keyType, event, network, channel)
	local updatedValueTable =
		channetg.remove_event(keyType, event, network, channel)
	te.remove_event(keyType, event, network, channel)
	return updatedValueTable
end

function models.reset()
	db.reset()
end

function models.debug()
	db.debug()
end

function models.iterate_over_lambda(keyType, lambda)
	db.iterate_prefs_over_lambda(keyType, lambda)
end

return models
