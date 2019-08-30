local db_utils = {}

local util = require'utilities.lua'
local const = require'constants.lua'

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

--!
--! @brief      Takes key from database and extracts the keyType
--!             (channel/network/global)
--!
--! @param      key   The key from the database
--!
--! @return     String or nil if not found
--!
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

--!
--! @brief      Converts a database key into a more workable table
--!
--! @param      key   The key from the database
--!
--! @return     {keyType = string, textevent/network/channel = string}
--!
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
