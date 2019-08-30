local commandCallbacks = {}

local util = require'utilities.lua'
local const = require'constants.lua'
local controller = require'controller.lua'

-- Uses default context unless arguments supplied. Converts arguments if they're
-- coming from menu.
--
-- @param      word  The input array from the command
--
-- @return     {'keyType' = string,'event' = string,'network' = string,'channel'
--             = string}
--
local function callback_handler(word)
	local returnArray = {
		channel = hexchat.get_info('channel'),
		network = hexchat.get_info('network'),
	}
	if word[2] then
		returnArray['keyType'] =
			util.trim(word[2]:gsub(const.spaceDelimiter, ' '))
	end
	if word[3] then
		returnArray['event'] =
			util.trim(word[3]:gsub(const.spaceDelimiter, ' '))
	end
	if word[4] then
		returnArray['network'] =
			util.trim(word[4]:gsub(const.spaceDelimiter, ' '))
	end
	if word[5] then
		returnArray['channel'] =
			util.trim(word[5]:gsub(const.spaceDelimiter, ' '))
	end
	return returnArray
end

--!
--! @brief      Start ignoring an event. Checks if it already exists, if not
--!             sends it to the controller to add.
--!
--! @param      word  Command data
--!
function commandCallbacks.start_ignoring_event_cb(word)
	local infoArray = callback_handler(word)
	local alreadyExists = false
	local iterateOver = function(event, ignoredData)
		if event == infoArray['event'] then
			if infoArray['keyType'] == 'global' and ignoredData['global'] == 'true' then
				alreadyExists = true
			elseif infoArray['keyType'] == 'network' and #ignoredData['networks'] > 0 then
				if util.has_value(
					ignoredData.networks,
					infoArray['network']
				) then
					alreadyExists = true
				end
			elseif infoArray['keyType'] == 'channel' and #ignoredData['channets'] > 0 then
				for i, channet in pairs(ignoredData.channets) do
					if channet['channel'] == infoArray['channel'] and channet['network'] == infoArray['network'] then
						alreadyExists = true
					end
				end
			end
		end
	end
	controller.iterate_over_all_event_data(iterateOver)
	if alreadyExists == false then
		if infoArray['keyType'] == 'channel' then
			controller.add_event(
				infoArray['keyType'],
				infoArray['event'],
				infoArray['network'],
				infoArray['channel']
			)
		elseif infoArray['keyType'] == 'network' then
			controller.add_event(
				infoArray['keyType'],
				infoArray['event'],
				infoArray['network']
			)
		else
			controller.add_event(infoArray['keyType'], infoArray['event'])
		end
	else
		print('Event is already being ignored on this context.')
	end
end

--!
--! @brief      Stops ignoring an already ignored event.
--!
--! @param      word  Command data
--!
function commandCallbacks.stop_ignoring_event_cb(word)
	local infoArray = callback_handler(word)
	if infoArray['keyType'] == 'channel' then
		controller.remove_event(
			infoArray['keyType'],
			infoArray['event'],
			infoArray['network'],
			infoArray['channel']
		)
	elseif infoArray['keyType'] == 'network' then
		controller.remove_event(
			infoArray['keyType'],
			infoArray['event'],
			infoArray['network']
		)
	else
		controller.remove_event(infoArray['keyType'], infoArray['event'])
	end
end

--!
--! @brief      Check if an event is ignored in the given context
--!
--! @param      word  Command data
--!
function commandCallbacks.check_event_ignored_context_cb(word)
	local infoArray = callback_handler(word)
	local ignoredData = controller.get_event_data(infoArray['event'])
	if infoArray['keyType'] == 'global' then
		if ignoredData.global == 'true' then
			print(infoArray['event'] .. ' is ignored globally.')
		else
			print(infoArray['event'] .. ' is not ignored globally.')
		end
	elseif infoArray['keyType'] == 'network' then
		if util.has_value(ignoredData.networks, infoArray['network']) then
			print(infoArray['event'] .. ' is ignored on this network.')
		else
			print(infoArray['event'] .. ' is not ignored on this network.')
		end
	elseif infoArray['keyType'] == 'channel' then
		local printString = ''
		if #ignoredData.channets > 0 then
			for i, channet in pairs(ignoredData.channets) do
				if channet['channel'] == infoArray['channel'] and channet['network'] == infoArray['network'] then
					printString =
						printString .. infoArray['event'] .. ' is ignored on this channel.'
				end
			end
		end
		if (printString ~= '') then
			print(printString)
		else
			print(infoArray['event'] .. ' is not ignored on this channel.')
		end
	else
		print(
			'Invalid context type given. Possible values are global, network, or channel.'
		)
	end
end

--!
--! @brief      Checks if an event is ignored and if so, where?
--!
--! @param      word  Command data
--!
function commandCallbacks.check_event_ignored_cb(word)
	local ignoredData = controller.get_event_data(word[2])
	if ignoredData.global == 'true' then
		print(word[2] .. ' is ignored globally.')
	else
		if #ignoredData.networks > 0 then
			local printString =
				word[2] .. ' is ignored on the following networks: '
			for i, network in pairs(ignoredData.networks) do
				printString = printString .. network .. ', '
			end
		elseif #ignoredData.channets > 0 then
			local printString =
				word[2] .. ' is ignored on the following channels: '
			for i, channet in pairs(ignoredData.channets) do
				printString =
					printString .. channet['channel'] .. ' on ' .. channet['network'] .. ', '
			end
		else
			print(word[2] .. ' is not ignored')
		end
	end
end

--!
--! @brief      Lists all ignored events and where they are ignored in a
--!             human-readable format
--!
function commandCallbacks.list_events_ignored_cb()
	print('>---------------v--------v---------------------------------<')
	print('|event__________|context_|location_________________________|')
	local iterateOver = function(event, ignoredData)
		if ignoredData.global == 'true' then
			print(
				'|' .. util.length_format(
					event,
					15
				) .. '|global  |' .. util.length_format('', 33) .. '|'
			)
		end
		if #ignoredData.networks > 0 then
			for i, network in pairs(ignoredData.networks) do
				print(
					'|' .. util.length_format(
						event,
						15
					) .. '|network |' .. util.length_format(network, 33) .. '|'
				)
			end
		end
		if #ignoredData.channets > 0 then
			for i, channet in pairs(ignoredData.channets) do
				print(
					'|' .. util.length_format(
						event,
						15
					) .. '|channel |' .. util.length_format(
						channet['channel'] .. '>' .. channet['network'],
						33
					) .. '|'
				)
			end
		end
	end
	controller.iterate_over_all_event_data(iterateOver)
	print('>---------------^--------^---------------------------------<')
end

-- Resets pluginprefs
function commandCallbacks.reset_plugin_prefs_cb()
	controller.reset()
	print('Ignore Text Events: Reset complete')
end

-- Prints out hexchat.pluginprefs and what hooks are enabled
function commandCallbacks.debug_plugin_prefs_cb()
	controller.debug()
end

return commandCallbacks
