local hooks = {}

----------------------------------------------------
-- Hooks: Text event handlers
----------------------------------------------------

local function kill_event()
	return hexchat.EAT_ALL
end

local function check_if_ignored(ignoredData)
	-- if ignoredData.global == true then
	-- 	return kill_event()
	-- else
	-- 	local network = hexchat.get_info('network')
	-- 	if has_value(ignoredData.networks, network) then
	-- 		return kill_event()
	-- 	else
	-- 		local channel = hexchat.get_info('channel')
	-- 		if has_value(ignoredData.channels, channel) then
	-- 			return kill_event()
	-- 		end
	-- 	end
	-- end
end

----------------------------------------------------
-- Hooks: Add/remove channels/networks/global
----------------------------------------------------
-- Some way to create all the hooks when this loads up without having to do silly lookups
-- Performant way to add and remove
-- Added all preference above, remove if not using
-- Instead of using all, use textevent type

-- Store pointer to hook in global table in format te: pointer
-- Add = removes old pointer if exists, creates new one
-- Remove = removes old pointer, if anything left, creates new one, if not, end
--

function hooks.add_event_hook(event, type, network, channel)
	-- hexchat.hook_print(
	-- 	'Channel Msg Hilight',
	-- 	function()
	-- 		local ignoredData = {
	-- 			global = false,
	-- 			networks = {},
	-- 			channels = {},
	-- 		}
	-- 		return check_if_ignored(ignoredData)
	-- 	end,
	-- 	hexchat.PRI_HIGHEST
	-- )
end

function hooks.remove_event_hook(event, type, network, channel)
	--
end

return hooks
