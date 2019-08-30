local utilities = {}

-- Converts table to human readable format
--
-- @param      o     {input table}
--
-- @return     string
--
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

-- Returns an array-like table from a string s, splitting the string using
-- delimiter
--
-- @param      s          string to split
-- @param      delimiter  The delimiter to split with
--
-- @return     [string]
--
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

--!
--! @brief      Joins table entries using delimiter into a string
--!
--! @param      tab        Array like table
--! @param      delimiter  The delimiter to join with
--!
--! @return     string
--!
function utilities.join(tab, delimiter)
	return table.concat(tab, delimiter)
end

-- Removes whitespace around string s
--
-- @param      s     string to remove whitespace around
--
-- @return     string
--
function utilities.trim(s)
	return (s:gsub('^%s*(.-)%s*$', '%1'))
end

-- Checks if table tab has value val, return false if not
--
-- @param      tab   The table to check
-- @param      val   The value to find in the table
--
-- @return     True if table has value, False otherwise.
--
function utilities.has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- https://bitbucket.org/snippets/marcotrosi/XnyRj/lua-isequal
-- Checks if two tables are equal -- can perform deep search
--
-- @param      tab1  The first table
-- @param      tab2  The second table
--
-- @return     True if equal for tables, False otherwise.
--
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
--
-- @param      tab          Table to look in
-- @param      valueToFind  The value to find
--
-- @return     Number index or nil if not found
--
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

--!
--! @brief      Takes string and sets it to len length, padding with whitespace
--!             if needed
--!
--! @param      str   The string
--! @param      len   Number, The length to set it to
--!
--! @return     string
--!
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
