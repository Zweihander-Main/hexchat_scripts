local models_textEvent = {}

local db = require'db.lua'
local db_util = require'db_utils.lua'
local util = require'utilities.lua'
local const = require'constants.lua'

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

local function convert_tevalue_to_table(value)
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

function models_textEvent.add_event(keyType, event, network, channel)
	local prefValue = db.get_preference_valuestring('textevent', event)
	local formattedTable = convert_tevalue_to_table(prefValue)
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
	local prefValue = db.get_preference_valuestring('textevent', event)
	local formattedTable = convert_tevalue_to_table(prefValue)
	if keyType == 'global' then
		formattedTable['global'] = 'false'
	elseif keyType == 'network' then
		table.remove(
			formattedTable['network'],
			util.find(formattedTable['network'], network)
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
	db.set_preference_valuestring('textevent', formattedTextEventValue, event)
end

return models_textEvent
