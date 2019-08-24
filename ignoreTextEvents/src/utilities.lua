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
	return result
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
local function isEqualForTables(tab1, tab2)
	if tab1 == tab2 then
		return true
	end
	for key, value in pairs(tab1) do
		if type(tab1[key]) ~= type(tab2[key]) then
			return false
		end

		if type(tab1[key]) == 'table' then
			if not isEqualForTables(tab1[key], tab2[key]) then
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
			if not isEqualForTables(tab2[key], tab1[key]) then
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
			if isEqualForTables(v, valueToFind) then
				return i
			end
		elseif v == valueToFind then
			return i
		end
	end
	return nil
end

return utilities
