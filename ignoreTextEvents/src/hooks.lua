local hooks = {}

local te = require'models_textEvent.lua'
local const = require'constants.lua'
local util = require'utilities.lua'

local hook_lookup_table = {}

--!
--! @brief      What happens when an event is found that should be ignored. Will
--!             eat the event thus removing it from the user and stopping other
--!             plugins from interacting with it.
--!
--! @return     hexchat.EAT_ALL object
--!
local function kill_event()
	return hexchat.EAT_ALL
end

--!
--! @brief      Checks if given data signals that a text event should be ignored
--!
--! @param      ignoredData  {global=string,networks=[string],channets=[{channel
--! 			,network}]}
--!
--! @return     hexchat.EAT_ALL object if text event should be ignored/eaten
--!
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

--!
--! @brief      Creates hexchat hook, returns pointer
--!
--! @param      event        The event to hook
--! @param      ignoredData  ignoredData
--!                          {global=string,networks=[string],channets=[{channel
--!                          ,network}]}
--!
--! @return     hook pointer
--!
local function create_hook(event, ignoredData)
	return hexchat.hook_print(
		event,
		function()
			return check_if_ignored(ignoredData)
		end,
		hexchat.PRI_HIGHEST
	)
end

--!
--! @brief      Unhooks a hook for an event and removes it from lookup table
--!
--! @param      event  The event to delete
--!
--! @return     { description_of_the_return_value }
--!
local function delete_hook(event)
	hexchat.unhook(hook_lookup_table[event])
	hook_lookup_table[event] = nil
end

--!
--! @brief      Get database data of event
--!
--! @param      event  The event
--!
--! @return     {} - models_te database data table
--!
function hooks.get_event_data(event)
	return te.get_event(event)
end

--!
--! @brief      Adds an event hook. If a previous one exists, removes it before
--! 			adding a new one.
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
function hooks.add_event_hook(keyType, event, network, channel)
	if hook_lookup_table[event] then
		delete_hook(event)
	end
	local ignoredData = hooks.get_event_data(event)
	hook_lookup_table[event] = create_hook(event, ignoredData)
end

--!
--! @brief      Removes an event hook. Removes the data from the lookup table if
--!             no other contexts ignore the event. Otherwise, readds it with
--!             the other still ignored contexts.
--!
--! @param      keyType  The context to ignore in: global, network, channel
--! @param      event    The textevent to ignore
--! @param      network  (Optional) The network to ignore in
--! @param      channel  (Optional) The channel to ignore in
--!
function hooks.remove_event_hook(keyType, event, network, channel)
	delete_hook(event)
	local ignoredData = hooks.get_event_data(event)
	if not (ignoredData['global'] == 'false' and #ignoredData['networks'] == 0 and #ignoredData['channets'] == 0) then
		hook_lookup_table[event] = create_hook(event, ignoredData)
	end
end

--!
--! @brief      Loads all hooks at application start.
--!
function hooks.load_all_hooks()
	local iterateOver = function(event, ignoredData)
		if not (ignoredData['global'] == 'false' and #ignoredData['networks'] == 0 and #ignoredData['channets'] == 0) then
			hook_lookup_table[event] = create_hook(event, ignoredData)
		end
	end
	te.iterate_over_lambda(iterateOver)
end

--!
--! @brief      Deletes all hooks.
--!
function hooks.reset()
	for event, hook in pairs(hook_lookup_table) do
		delete_hook(event)
	end
end

--!
--! @brief      Prints hook_lookup_table to see what hooks are enabled.
--!
function hooks.debug()
	local printString = 'Enabled hooks: '
	for event, hook in pairs(hook_lookup_table) do
		printString = printString .. event .. ' '
	end
	print(printString)
end

return hooks
