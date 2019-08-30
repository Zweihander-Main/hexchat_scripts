__luapack_modules__ = {
    (function()
        ----------------------------------------------------
        -- Utility functions
        ----------------------------------------------------
        
        local utilities = {}
        
        -- Converts table to human readable format
        function utilities.dump(o)
        	if type(o) == 'table' then
        		local s = '{ '
        		for k, v in pairs(o) do
        			if type(k) ~= 'number' then
        				k = '"' .. k .. '"'
        			end
        			s = s .. '[' .. k .. '] = ' .. utilities.dump(v) .. ','
        		end
        		return s .. '} '
        	else
        		return tostring(o)
        	end
        end
        
        -- Returns an array-like table from a string s, splitting the string using delimiter
        function utilities.split(s, delimiter)
        	local result = {}
        	for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
        		table.insert(result, match)
        	end
        	if (#result == 1 and result[1] == '') then
        		return {}
        	else
        		return result
        	end
        end
        
        function utilities.join(tab, delimiter)
        	return table.concat(tab, delimiter)
        end
        
        -- Removes whitespace around string s
        function utilities.trim(s)
        	return (s:gsub('^%s*(.-)%s*$', '%1'))
        end
        
        -- Checks if table tab has value val, return false if not
        function utilities.has_value(tab, val)
        	for index, value in ipairs(tab) do
        		if value == val then
        			return true
        		end
        	end
        	return false
        end
        
        -- https://bitbucket.org/snippets/marcotrosi/XnyRj/lua-isequal
        local function is_equal_for_tables(tab1, tab2)
        	if tab1 == tab2 then
        		return true
        	end
        	for key, value in pairs(tab1) do
        		if type(tab1[key]) ~= type(tab2[key]) then
        			return false
        		end
        
        		if type(tab1[key]) == 'table' then
        			if not is_equal_for_tables(tab1[key], tab2[key]) then
        				return false
        			end
        		else
        			if tab1[key] ~= tab2[key] then
        				return false
        			end
        		end
        	end
        	for key, value in pairs(tab2) do
        		if type(tab2[key]) ~= type(tab1[key]) then
        			return false
        		end
        
        		if type(tab2[key]) == 'table' then
        			if not is_equal_for_tables(tab2[key], tab1[key]) then
        				return false
        			end
        		else
        			if tab2[key] ~= tab1[key] then
        				return false
        			end
        		end
        	end
        	return true
        end
        
        -- Returns index of val in table tab or nil if not found
        function utilities.find(tab, valueToFind)
        	for i, v in pairs(tab) do
        		if type(v) == 'table' then
        			if is_equal_for_tables(v, valueToFind) then
        				return i
        			end
        		elseif v == valueToFind then
        			return i
        		end
        	end
        	return nil
        end
        
        function utilities.length_format(str, len)
        	if (#str == len) then
        		return str
        	elseif (#str > len) then
        		return string.sub(str, 0, len)
        	else
        		for i = len - #str, 1, -1 do
        			str = str .. ' '
        		end
        		return str
        	end
        end
        
        return utilities
    
    end),
    (function()
        ----------------------------------------------------
        -- Preferences/constants
        ----------------------------------------------------
        
        local constants = {}
        
        -- Delimiter variables. Changing preferences delimiter will invalidate preferences
        constants.spaceDelimiter = '_,_,_,_'
        constants.preferencesDelimiter = '{}}{{}'
        constants.preferencesSubDelimiter = ';>;<;>'
        -- Prefix for channel keys in preferences
        constants.preferencesPrefix = 'ignoreTextEvents_type:'
        -- Array-like table of text event strings
        constants.listOfTextEvents =
        	{
        		'Add Notify',
        		'Ban List',
        		'Banned',
        		'Beep',
        		'Capability Acknowledgement',
        		'Capability Deleted',
        		'Capability List',
        		'Capability Request',
        		'Change Nick',
        		'Channel Action',
        		'Channel Action Hilight',
        		'Channel Ban',
        		'Channel Creation',
        		'Channel DeHalfOp',
        		'Channel DeOp',
        		'Channel DeVoice',
        		'Channel Exempt',
        		'Channel Half-Operator',
        		'Channel INVITE',
        		'Channel List',
        		'Channel Message',
        		'Channel Mode Generic',
        		'Channel Modes',
        		'Channel Msg Hilight',
        		'Channel Notice',
        		'Channel Operator',
        		'Channel Quiet',
        		'Channel Remove Exempt',
        		'Channel Remove Invite',
        		'Channel Remove Keyword',
        		'Channel Remove Limit',
        		'Channel Set Key',
        		'Channel Set Limit',
        		'Channel UnBan',
        		'Channel UnQuiet',
        		'Channel Url',
        		'Channel Voice',
        		'Connected',
        		'Connecting',
        		'Connection Failed',
        		'CTCP Generic',
        		'CTCP Generic to Channel',
        		'CTCP Send',
        		'CTCP Sound',
        		'CTCP Sound to Channel',
        		'DCC CHAT Abort',
        		'DCC CHAT Connect',
        		'DCC CHAT Failed',
        		'DCC CHAT Offer',
        		'DCC CHAT Offering',
        		'DCC CHAT Reoffer',
        		'DCC Conection Failed',
        		'DCC Generic Offer',
        		'DCC Header',
        		'DCC Malformed',
        		'DCC Offer',
        		'DCC Offer Not Valid',
        		'DCC RECV Abort',
        		'DCC RECV Complete',
        		'DCC RECV Connect',
        		'DCC RECV Failed',
        		'DCC RECV File Open Error',
        		'DCC Rename',
        		'DCC RESUME Request',
        		'DCC SEND Abort',
        		'DCC SEND Complete',
        		'DCC SEND Connect',
        		'DCC SEND Failed',
        		'DCC SEND Offer',
        		'DCC Stall',
        		'DCC Timeout',
        		'Delete Notify',
        		'Disconnected',
        		'Found IP',
        		'Generic Message',
        		'Ignore Add',
        		'Ignore Changed',
        		'Ignore Footer',
        		'Ignore Header',
        		'Ignore Remove',
        		'Ignorelist Empty',
        		'Invite',
        		'Invited',
        		'Join',
        		'Keyword',
        		'Kick',
        		'Killed',
        		'Message Send',
        		'Motd',
        		'MOTD Skipped',
        		'Nick Clash',
        		'Nick Erroneous',
        		'Nick Failed',
        		'No DCC',
        		'No Running Process',
        		'Notice',
        		'Notice Send',
        		'Notify Away',
        		'Notify Back',
        		'Notify Empty',
        		'Notify Header',
        		'Notify Number',
        		'Notify Offline',
        		'Notify Online',
        		'Open Dialog',
        		'Part',
        		'Part with Reason',
        		'Ping Reply',
        		'Ping Timeout',
        		'Private Action',
        		'Private Action to Dialog',
        		'Private Message',
        		'Private Message to Dialog',
        		'Process Already Running',
        		'Quit',
        		'Raw Modes',
        		'Receive Wallops',
        		'Resolving User',
        		'SASL Authenticating',
        		'SASL Response',
        		'Server Connected',
        		'Server Error',
        		'Server Lookup',
        		'Server Notice',
        		'Server Text',
        		'SSL Message',
        		'Stop Connection',
        		'Topic',
        		'Topic Change',
        		'Topic Creation',
        		'Unknown Host',
        		'User Limit',
        		'Users On Channel',
        		'WhoIs Authenticated',
        		'WhoIs Away Line',
        		'WhoIs Channel/Oper Line',
        		'WhoIs End',
        		'WhoIs Identified',
        		'WhoIs Idle Line',
        		'WhoIs Idle Line with Signon',
        		'WhoIs Name Line',
        		'WhoIs Real Host',
        		'WhoIs Server Line',
        		'WhoIs Special',
        		'You Join',
        		'You Kicked',
        		'You Part',
        		'You Part with Reason',
        		'Your Action',
        		'Your Invitation',
        		'Your Message',
        		'Your Nick Changing',
        	}
        
        return constants
    
    end),
    (function()
        local db_utils = {}
        
        local util = __luapack_require__(1)
        local const = __luapack_require__(2)
        -- Splits string into array using comma delimiter
        --
        -- @param      eventsString  The events string to be split
        --
        -- @return     [string]
        --
        function db_utils.comma_delim_string_to_array(value)
        	local returnArray = util.split(value, ',')
        	return returnArray
        end
        
        -- Opposite of above -- takes flat array like table and concatenates it into a
        -- string split by commas
        --
        -- @param      eventsArray  Flat array like table of strings
        --
        -- @return     string
        --
        function db_utils.array_to_comma_delim_string(valueArray)
        	local returnString = ''
        	returnString = returnString .. util.join(valueArray, ',')
        	return returnString
        end
        
        function db_utils.extract_keyType(key)
        	local locationOfFirstDelim =
        		string.find(key, const.preferencesDelimiter, 0, true)
        	if locationOfFirstDelim then
        		return key:sub(
        			string.len(const.preferencesPrefix) + 1,
        			locationOfFirstDelim - 1
        		)
        	else
        		return nil
        	end
        end
        
        function db_utils.convert_key_to_table(key)
        	local keyType = db_utils.extract_keyType(key)
        	local keyArray = util.split(key, const.preferencesDelimiter)
        	local returnTable = { keyType = keyType }
        	if keyType == 'textevent' then
        		returnTable['textevent'] = keyArray[2]
        	elseif keyType ~= 'global' then
        		returnTable['network'] = keyArray[2]
        		if keyType == 'channel' then
        			returnTable['channel'] = keyArray[3]
        		end
        	end
        	return returnTable
        end
        
        return db_utils
    
    end),
    (function()
        local db = {}
        
        local db_utils = __luapack_require__(3)
        local const = __luapack_require__(2)
        local util = __luapack_require__(1)
        -- Creates string corresponding to key in preferences
        --
        -- @param      keyType             global, channel, network, textevent
        -- @param      networkOrTextEvent  (Optional) The network or text event
        -- @param      channel             (Optional) The channel
        --
        -- @return     string
        --
        local function compose_preferences_key(keyType, networkOrTextEvent, channel)
        	if channel then
        		return const.preferencesPrefix .. keyType .. const.preferencesDelimiter .. networkOrTextEvent .. const.preferencesDelimiter .. channel
        	elseif networkOrTextEvent then
        		return const.preferencesPrefix .. keyType .. const.preferencesDelimiter .. networkOrTextEvent
        	else
        		return const.preferencesPrefix .. keyType
        	end
        end
        
        ----------------------------------------------------
        -- Plugin preferences: general
        ----------------------------------------------------
        
        -- Set version, for future proofing in case a reset is ever needed
        --
        -- @param      version  The version in semantic versioning format
        --
        function db.set_version(version)
        	hexchat.pluginprefs['version'] = 'v' .. version
        end
        
        -- Resets all hexchat plugin preferences related to this script
        function db.reset()
        	for a, b in pairs(hexchat.pluginprefs) do
        		hexchat.pluginprefs[a] = nil
        	end
        end
        
        function db.debug()
        	print(util.dump(hexchat.pluginprefs))
        end
        
        ----------------------------------------------------
        -- Plugin preferences: set and get from database
        ----------------------------------------------------
        
        -- Get plugin preferences value based on inputs or empty string if not found
        --
        -- @param      keyType             global, channel, network, textevent
        -- @param      networkOrTextEvent  (Optional) The network or text event
        -- @param      channel             (Optional) The channel
        --
        -- @return     string
        --
        function db.get_preference_valuestring(keyType, networkOrTextEvent, channel)
        	local pref = false
        	pref =
        		hexchat.pluginprefs[compose_preferences_key(
        			keyType,
        			networkOrTextEvent,
        			channel
        		)]
        	if pref then
        		return pref
        	end
        	return ''
        end
        
        -- Set plugin preferences value
        --
        -- @param      keyType             global, channel, network, textevent
        -- @param      value               The value to set the key to
        -- @param      networkOrTextEvent  (Optional) The network or text event
        -- @param      channel             (Optional) The channel
        --
        -- @return     { description_of_the_return_value }
        --
        function db.set_preference_valuestring(
        keyType,
        	value,
        	networkOrTextEvent,
        	channel
        )
        	hexchat.pluginprefs[compose_preferences_key(
        			keyType,
        			networkOrTextEvent,
        			channel
        		)]
        	= value
        end
        
        --!
        --! @brief      Checks if a key string is of type keyType
        --!
        --! @param      keyType  string: global, network, channel, textevent
        --! @param      key      key string
        --!
        --! @return     True if keytype, False otherwise.
        --!
        local function is_keytype(keyType, key)
        	if db_utils.extract_keyType(key) == keyType then
        		return true
        	else
        		return false
        	end
        end
        
        -- Iterates through preferences of keyType and passes their names and
        -- values to given function
        --
        -- @param      keyType  string: global, network, channel, textevent
        -- @param      lambda   The lambda function to call with the key and value
        --
        -- @return     { description_of_the_return_value }
        --
        function db.iterate_prefs_over_lambda(keyType, lambda)
        	for key, value in pairs(hexchat.pluginprefs) do
        		if is_keytype(keyType, key) then
        			lambda(key, value)
        		end
        	end
        end
        
        return db
    
    end),
    (function()
        local models_channetg = {}
        
        local db = __luapack_require__(4)
        local db_utils = __luapack_require__(3)
        local util = __luapack_require__(1)
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
        
        function models_channetg.get_events_array(keyType, network, channel)
        	return db_utils.comma_delim_string_to_array(
        		db.get_preference_valuestring(keyType, network, channel)
        	)
        end
        
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
        
        function models_channetg.iterate_over_lambda(keyType, lambda)
        	local model_lambda = function(name, value)
        		local chanNetTable = db_utils.convert_key_to_table(name)
        		lambda(chanNetTable, value)
        	end
        	db.iterate_prefs_over_lambda(keyType, model_lambda)
        end
        
        --
        -- local function modelchannet_is_set_to_ignore_channet(event, network, channel)
        -- 	local currentNetworkIgnoredEvents =
        -- 		modelchannet_get_preference_events_values_array('network', network)
        -- 	if has_value(currentNetworkIgnoredEvents, event) then
        -- 		return true
        -- 	else
        -- 		local currentChannelIgnoredEvents =
        -- 			modelchannet_get_preference_events_values_array(
        -- 				'channel',
        -- 				network,
        -- 				channel
        -- 			)
        -- 		if has_value(currentChannelIgnoredEvents, event) then
        -- 			return true
        -- 		end
        -- 	end
        -- 	return false
        -- end
        
        return models_channetg
    
    end),
    (function()
        local models_textEvent = {}
        
        local db = __luapack_require__(4)
        local db_util = __luapack_require__(3)
        local util = __luapack_require__(1)
        local const = __luapack_require__(2)
        ----------------------------------------------------
        -- Models: text event
        -- DB model:
        -- ignoreTextEvents_type:textevent,
        -- text event name
        -- =
        -- global boolean,
        -- networks,
        -- channel;;;;;;network pairs
        --
        -- Value should look something like:
        -- gbool||||||n1,n3,n3||||||c1;;;;;;nc1,c2;;;;;;nc2,c3;;;;;;nc3
        ----------------------------------------------------
        
        function convert_tevalue_to_table(value)
        	local splitTable = util.split(value, const.preferencesDelimiter)
        	if #splitTable == 3 then
        		local formattedTable = {}
        		formattedTable['global'] = splitTable[1]
        		formattedTable['networks'] = util.split(splitTable[2], ',')
        		local channetUndelim = util.split(splitTable[3], ',')
        		formattedTable['channets'] = {}
        		for i, channet in pairs(channetUndelim) do
        			local channetPair =
        				util.split(channet, const.preferencesSubDelimiter)
        			table.insert(formattedTable['channets'], {
        				channel = channetPair[1],
        				network = channetPair[2],
        			})
        		end
        		return formattedTable
        	else
        		return {
        			global = 'false',
        			networks = {},
        			channets = {},
        		}
        	end
        end
        
        local function convert_table_to_tevalue(valueTable)
        	local returnString = ''
        	returnString =
        		returnString .. valueTable['global'] .. const.preferencesDelimiter
        	returnString =
        		returnString .. util.join(
        			valueTable['networks'],
        			','
        		) .. const.preferencesDelimiter
        	local channetArray = {}
        	for i, channet in pairs(valueTable['channets']) do
        		local channetString =
        			channet['channel'] .. const.preferencesSubDelimiter .. channet['network']
        		table.insert(channetArray, channetString)
        	end
        	returnString = returnString .. util.join(channetArray, ',')
        	return returnString
        end
        
        function models_textEvent.get_event(event)
        	local prefValue = db.get_preference_valuestring('textevent', event)
        	local formattedTable = convert_tevalue_to_table(prefValue)
        	return formattedTable
        end
        
        function models_textEvent.add_event(keyType, event, network, channel)
        	local formattedTable = models_textEvent.get_event(event)
        	if keyType == 'global' then
        		formattedTable['global'] = 'true'
        	elseif keyType == 'network' then
        		table.insert(formattedTable['networks'], network)
        	else
        		table.insert(formattedTable['channets'], {
        			channel = channel,
        			network = network,
        		})
        	end
        	local formattedTextEventValue = convert_table_to_tevalue(formattedTable)
        	db.set_preference_valuestring('textevent', formattedTextEventValue, event)
        end
        
        function models_textEvent.remove_event(keyType, event, network, channel)
        	local formattedTable = models_textEvent.get_event(event)
        	if keyType == 'global' then
        		formattedTable['global'] = 'false'
        	elseif keyType == 'network' then
        		table.remove(
        			formattedTable['networks'],
        			util.find(formattedTable['networks'], network)
        		)
        	else
        		table.remove(
        			formattedTable['channets'],
        			util.find(formattedTable['channets'], {
        				channel = channel,
        				network = network,
        			})
        		)
        	end
        	local formattedTextEventValue = convert_table_to_tevalue(formattedTable)
        	if formattedTextEventValue == ('false' .. const.preferencesDelimiter .. const.preferencesDelimiter) then
        		formattedTextEventValue = nil
        	end
        	db.set_preference_valuestring('textevent', formattedTextEventValue, event)
        end
        
        function models_textEvent.iterate_over_lambda(lambda)
        	local model_lambda = function(name, value)
        		local delimStart, delimEnd =
        			string.find(name, const.preferencesDelimiter, 0, true)
        		local event = name:sub(delimEnd + 1)
        		local ignoredData = convert_tevalue_to_table(value)
        		lambda(event, ignoredData)
        	end
        	db.iterate_prefs_over_lambda('textevent', model_lambda)
        end
        
        return models_textEvent
    
    end),
    (function()
        ---------------------------------------------------
        -- Models: add/remove
        ---------------------------------------------------
        
        local models = {}
        
        local channetg = __luapack_require__(5)
        local te = __luapack_require__(6)
        local db = __luapack_require__(4)
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
        
        function models.iterate_over_all_event_data(lambda)
        	te.iterate_over_lambda(lambda)
        end
        
        function models.set_version(version)
        	db.set_version(version)
        end
        
        return models
    
    end),
    (function()
        local views = {}
        
        local channet = __luapack_require__(5)
        local const = __luapack_require__(2)
        local util = __luapack_require__(1)
        local db_utils = __luapack_require__(3)
        local models = __luapack_require__(7)
        ----------------------------------------------------
        -- Views: Menu manipulation
        ----------------------------------------------------
        
        local function add_text_events_to_currently_ignored_in_menu(
        eventsString,
        	menuSettings
        )
        	local eventsArray = db_utils.comma_delim_string_to_array(eventsString)
        	for key, event in pairs(eventsArray) do
        		local commandToAdd =
        			'menu -t1 add "Settings/Ignore Text Events/Events Currently Ignored In/'
        		if (menuSettings.type == 'channel') then
        			commandToAdd =
        				commandToAdd .. 'Channels/' .. menuSettings.network:gsub(
        					'/',
        					'|'
        				) .. '/' .. menuSettings.channel:gsub('/', '|') .. '/'
        		else
        			commandToAdd =
        				commandToAdd .. 'Networks/' .. menuSettings.network:gsub(
        					'/',
        					'|'
        				) .. '/'
        		end
        
        		commandToAdd =
        			commandToAdd .. event .. '" "" "stopIgnoringEvent ' .. menuSettings.type .. ' ' .. event:gsub(
        				' ',
        				const.spaceDelimiter
        			) .. ' ' .. menuSettings.network:gsub(' ', const.spaceDelimiter)
        
        		if (menuSettings.type == 'channel') then
        			commandToAdd =
        				commandToAdd .. ' ' .. menuSettings.channel:gsub(
        					' ',
        					const.spaceDelimiter
        				)
        		end
        
        		commandToAdd = commandToAdd .. '"'
        		hexchat.command(commandToAdd)
        	end
        end
        
        local function add_ignored_channel_menu(network, channel, eventsString)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
        			'/',
        			'|'
        		) .. '"'
        	)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
        			'/',
        			'|'
        		) .. '/' .. channel:gsub('/', '|') .. '"'
        	)
        	local menuSettings = {
        		type = 'channel',
        		channel = channel,
        		network = network,
        	}
        	add_text_events_to_currently_ignored_in_menu(eventsString, menuSettings)
        end
        
        local function add_ignored_network_menu(network, eventsString)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network:gsub(
        			'/',
        			'|'
        		) .. '"'
        	)
        	local menuSettings = {
        		type = 'network',
        		network = network,
        	}
        	add_text_events_to_currently_ignored_in_menu(eventsString, menuSettings)
        end
        
        local function remove_ignored_channel_menu(
        network,
        	channel,
        	textEventsArray,
        	event
        )
        	if #textEventsArray > 0 then
        		hexchat.command(
        			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
        				'/',
        				'|'
        			) .. '/' .. channel:gsub('/', '|') .. '/' .. event .. '"'
        		)
        	else
        		local networkShouldBeRemoved = true
        		local iterateOver = function(chanNetTable, value)
        			if chanNetTable['network'] == network and value ~= nil and value ~= '' then
        				networkShouldBeRemoved = false
        			end
        		end
        		channet.iterate_over_lambda('channel', iterateOver)
        		if networkShouldBeRemoved == true then
        			hexchat.command(
        				'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
        					'/',
        					'|'
        				) .. '"'
        			)
        		else
        			hexchat.command(
        				'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Channels/' .. network:gsub(
        					'/',
        					'|'
        				) .. '/' .. channel:gsub('/', '|') .. '"'
        			)
        		end
        	end
        end
        
        local function remove_ignored_network_menu(network, textEventsArray, event)
        	if #textEventsArray > 1 then
        		hexchat.command(
        			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network:gsub(
        				'/',
        				'|'
        			) .. '/' .. event .. '"'
        		)
        	else
        		hexchat.command(
        			'menu del "Settings/Ignore Text Events/Events Currently Ignored In/Networks/' .. network:gsub(
        				'/',
        				'|'
        			) .. '"'
        		)
        	end
        end
        
        ----------------------------------------------------
        -- Views: Menu generation
        ----------------------------------------------------
        
        -- Generated menu of channels with ignored text events from pluginprefs
        local function generate_currently_ignored_channel_menu()
        	local iterateOver = function(chanNetTable, value)
        		add_ignored_channel_menu(
        			chanNetTable['network'],
        			chanNetTable['channel'],
        			value
        		)
        	end
        	channet.iterate_over_lambda('channel', iterateOver)
        end
        
        -- Generated menu of channels with ignored text events from pluginprefs
        local function generate_currently_ignored_network_menu()
        	local iterateOver = function(chanNetTable, value)
        		add_ignored_network_menu(chanNetTable['network'], value)
        	end
        	channet.iterate_over_lambda('network', iterateOver)
        end
        
        local function generate_context_menu(context)
        	for key, event in pairs(const.listOfTextEvents) do
        		local formattedEvent = event:gsub(' ', const.spaceDelimiter)
        		local commandString =
        			'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/' .. context .. '/' .. event .. '" '
        		commandString =
        			commandString .. '"startIgnoringEvent ' .. context:lower() .. ' ' .. formattedEvent .. '"'
        		hexchat.command(commandString)
        	end
        end
        
        -- Generated menu of global text events with already ignored ones toggled
        local function generate_global_menu()
        	local globalIgnoredEvents = channet.get_events_array('global')
        	for key, event in pairs(const.listOfTextEvents) do
        		local formattedEvent = event:gsub(' ', const.spaceDelimiter)
        		local commandString = 'menu '
        		if util.has_value(globalIgnoredEvents, event) then
        			commandString = commandString .. '-t1'
        		else
        			commandString = commandString .. '-t0'
        		end
        		commandString =
        			commandString .. ' add "Settings/Ignore Text Events/Toggle Events Ignored Globally/' .. event .. '" '
        		commandString =
        			commandString .. '"startIgnoringEvent global ' .. formattedEvent .. '" '
        		commandString =
        			commandString .. '"stopIgnoringEvent global ' .. formattedEvent .. '"'
        		hexchat.command(commandString)
        	end
        end
        
        ----------------------------------------------------
        -- Views: add/remove event
        ----------------------------------------------------
        
        function views.add_event(keyType, event, network, channel)
        	if keyType == 'network' then
        		add_ignored_network_menu(network, event)
        	elseif keyType == 'channel' then
        		add_ignored_channel_menu(network, channel, event)
        	end
        end
        
        function views.remove_event(
        keyType,
        	updatedModelTextEventsTable,
        	event,
        	network,
        	channel
        )
        	if keyType == 'network' then
        		remove_ignored_network_menu(network, updatedModelTextEventsTable, event)
        	elseif keyType == 'channel' then
        		remove_ignored_channel_menu(
        			network,
        			channel,
        			updatedModelTextEventsTable,
        			event
        		)
        	end
        end
        
        ----------------------------------------------------
        -- Views: Menu init and unloading
        ----------------------------------------------------
        
        -- Loads all the menus
        function views.load_menus()
        	hexchat.command('menu add "Settings/Ignore Text Events"')
        
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current"'
        	)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/Channel"'
        	)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Set Events To Ignore In Current/Network"'
        	)
        
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Events Currently Ignored In"'
        	)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Channels"'
        	)
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Events Currently Ignored In/Networks"'
        	)
        
        	hexchat.command(
        		'menu add "Settings/Ignore Text Events/Toggle Events Ignored Globally"'
        	)
        	generate_currently_ignored_channel_menu()
        	generate_currently_ignored_network_menu()
        	generate_context_menu('Channel')
        	generate_context_menu('Network')
        	generate_global_menu()
        end
        
        -- Unload handler
        function views.unload_menus()
        	hexchat.command('menu del "Settings/Ignore Text Events"')
        end
        
        return views
    
    end),
    (function()
        local hooks = {}
        
        local te = __luapack_require__(6)
        local const = __luapack_require__(2)
        local util = __luapack_require__(1)
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
    
    end),
    (function()
        ----------------------------------------------------
        -- Controller
        ----------------------------------------------------
        
        local controller = {}
        local views = __luapack_require__(8)
        local models = __luapack_require__(7)
        local hooks = __luapack_require__(9)
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
    
    end),
    (function()
        ----------------------------------------------------
        -- Command callbacks
        ----------------------------------------------------
        
        local commandCallbacks = {}
        
        local util = __luapack_require__(1)
        local const = __luapack_require__(2)
        local controller = __luapack_require__(10)
        -- Uses default context unless arguments supplied.
        -- Converts arguments if they're coming from menu
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
        	-- TODO sanitize event against event list
        end
        
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
        	-- TODO version
        end
        
        -- Prints out hexchat.pluginprefs in human readable format
        function commandCallbacks.debug_plugin_prefs_cb()
        	controller.debug()
        end
        
        return commandCallbacks
    
    end),
}
__luapack_cache__ = {}
__luapack_require__ = function(idx)
	local cache = __luapack_cache__[idx]
	if cache then
		return cache
	end

	local module = __luapack_modules__[idx]()
	__luapack_cache__[idx] = module
	return module
end

-- SPDX-License-Identifier: MIT
local version = '1.0.0'

hexchat.register(
	'Ignore Text Events',
	version,
	'Allows you to selectively ignore text events on a per channel, per network, or global basis'
)

-- Fix for lua 5.2
if unpack == nil then
	unpack = table.unpack
end

local controller = __luapack_require__(10)
local callbacks = __luapack_require__(11)
controller.set_version(version)

----------------------------------------------------
-- Command hooks
----------------------------------------------------

hexchat.hook_command(
	'startIgnoringEvent',
	callbacks.start_ignoring_event_cb,
	'Usage: startIgnoringEvent type event [network] [channel]\n\tStarts ignoring given event for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'stopIgnoringEvent',
	callbacks.stop_ignoring_event_cb,
	'Usage: stopIgnoringEvent type event [network] [channel]\n\tStops ignoring given event for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkEventIgnoredAtContext',
	callbacks.check_event_ignored_context_cb,
	'Usage: checkEventIgnoredAtContext type event [network] [channel]\n\tChecks if given event is ignored for given context. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'checkEventIgnored',
	callbacks.check_event_ignored_cb,
	'Usage: checkEventIgnored event\n\tChecks if given event is ignored at all.'
)
hexchat.hook_command(
	'listEventsIgnored',
	callbacks.list_events_ignored_cb,
	'Usage: listEventsIgnored\n\tLists all text events that are ignored and where they are ignored. Will use current context for any missing arguments.'
)
hexchat.hook_command(
	'resetIgnoreTextEvents',
	callbacks.reset_plugin_prefs_cb,
	'Usage: resetIgnoreTextEvents\n\tWill reset the plugin preferences and remove all text events from being ignored.'
)
hexchat.hook_command(
	'debugIgnoreTextEvents',
	callbacks.debug_plugin_prefs_cb,
	'Usage: debugIgnoreTextEvents\n\tWill print out plugin preferences.'
)

controller.init()
