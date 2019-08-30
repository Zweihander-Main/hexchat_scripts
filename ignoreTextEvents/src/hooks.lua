local hooks = {}

local te = require'models_textEvent.lua'
local const = require'constants.lua'
local util = require'utilities.lua'

local hook_lookup_table = {}

----------------------------------------------------
-- Hooks: Text event handlers
----------------------------------------------------

local function kill_event()
	return hexchat.EAT_ALL
end

local function check_if_ignored(ignoredData)
	if ignoredData.global == 'true' then
		return kill_event()
	else
		local network = hexchat.get_info('network')
		if util.has_value(ignoredData.networks, network) then
			return kill_event()
		else
			local channel = hexchat.get_info('channel')
			for i, channet in pairs(ignoredData.channets) do
				if channet['channel'] == channel and channet['network'] == network then
					return kill_event()
				end
			end
		end
	end
end

local function create_hook(event, ignoredData)
	return hexchat.hook_print(
		event,
		function()
			return check_if_ignored(ignoredData)
		end,
		hexchat.PRI_HIGHEST
	)
end

local function delete_hook(event)
	hexchat.unhook(hook_lookup_table[event])
	hook_lookup_table[event] = nil
end

function hooks.get_event_data(event)
	return te.get_event(event)
end

function hooks.add_event_hook(keyType, event, network, channel)
	if hook_lookup_table[event] then
		delete_hook(event)
	end
	local ignoredData = hooks.get_event_data(event)
	hook_lookup_table[event] = create_hook(event, ignoredData)
end

function hooks.remove_event_hook(keyType, event, network, channel)
	delete_hook(event)
	local ignoredData = hooks.get_event_data(event)
	if not (ignoredData['global'] == 'false' and #ignoredData['networks'] == 0 and #ignoredData['channets'] == 0) then
		hook_lookup_table[event] = create_hook(event, ignoredData)
	end
end

function hooks.load_all_hooks()
	local iterateOver = function(event, ignoredData)
		if not (ignoredData['global'] == 'false' and #ignoredData['networks'] == 0 and #ignoredData['channets'] == 0) then
			hook_lookup_table[event] = create_hook(event, ignoredData)
		end
	end
	te.iterate_over_lambda(iterateOver)
end

function hooks.reset()
	for event, hook in pairs(hook_lookup_table) do
		delete_hook(event)
	end
end

function hooks.debug()
	local printString = 'Enabled hooks: '
	for event, hook in pairs(hook_lookup_table) do
		printString = printString .. event .. ' '
	end
	print(printString)
end

return hooks
