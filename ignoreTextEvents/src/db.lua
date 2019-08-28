local db = {}

local db_utils = require'db_utils.lua'
local const = require'constants.lua'
local util = require'utilities.lua'

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
