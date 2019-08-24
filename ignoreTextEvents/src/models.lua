---------------------------------------------------
-- Models: add/remove
---------------------------------------------------

local models = {}

local channetg = require'models_channetg.lua'
local te = require'models_textEvent.lua'

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

return models
