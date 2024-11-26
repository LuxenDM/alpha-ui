local file_args = {...}

local public = file_args[1]
local private = file_args[2]

local he = {} -->>public.util._func()

--future reference: Replace iup.GetType with iup.GetClassName if using iup >3.xx



local container_types = {
	["hbox"] = true,
	["vbox"] = true,
	["frame"] = true,
	["zbox"] = true,
	["cbox"] = true,
	["dialog"] = true,
	["sbox"] = true,
}



--Maps a dialog, and handles map_cb() for ALL CHILDREN
he.map_dialog = function(ihandle)
	local cb_children
	cb_children = function(ihandle)
		local children = {}
		while true do
			local obj = iup.GetNextChild(ihandle, children[#children])
			if not obj then 
				break
			elseif obj.map_cb and type(obj.map_cb) == "function" then
				obj:map_cb()
			end
			table.insert(children, obj)
			if container_types[iup.GetType(obj)] then
				cb_children(obj)
			end
		end
		children = nil
	end
	
	if iup.IsValid(ihandle) then
		if iup.GetType(ihandle) == "dialog" then
			ihandle:map()
		end
		cb_children(ihandle)
		iup.Refresh(ihandle)
	end
end



--creates a simple table mapping an iup object.
he.index_container = function(roothandle)
	local index_object
    index_object = function(ihandle)
        local children = {}
        local last_child = nil
        while true do
            local obj = iup.GetNextChild(ihandle, last_child)
            if not obj then
                break
            end
            local obj_type = iup.GetType(obj)
            local obj_for_table
            if container_types[obj_type] then
                obj_for_table = index_object(obj)
                obj_for_table["_type"] = obj_type
            else
                obj_for_table = obj
            end
            table.insert(children, obj_for_table)
            last_child = obj
        end
        return children
    end

    return index_object(roothandle)
end



--like Append, but as a prefix. puts an object on the front of an iup stack
he.iup_prepend = function(root, obj)
	assert(iup.IsValid(obj) and iup.IsValid(root), "helium.iup_prepend expects both root and object to be valid iup containers!")
	
	local contents = {}
	local next = iup.GetNextChild(root)
	
	while next do
		table.insert(contents, next)
		next = iup.GetNextChild(root, next)
	end
	
	for k, v in ipairs(contents) do
		v:detach()
	end
	
	root:append(obj)
	
	for k, v in ipairs(contents) do
		root:append(v)
	end
	
	iup.Refresh(root)
end



--inserts the element in the target position
he.iup_insert = function(root, ihandle, position)
	assert(iup.IsValid(root) and iup.IsValid(ihandle), "helium.iup_insert expects both root and object to be valid iup containers!")
	assert(type(position) == "number", "helium.iup_insert expects the insert position to be a number; was type " .. type(position))
	
	local contents = {}
	local next = iup.GetNextChild(root)
	
	while next do
		table.insert(contents, next)
		next = iup.GetNextChild(root, next)
	end
	
	for i=1, #contents do
		contents[i]:detach()
	end
	
	if position < 0 then
		position = #contents + position
	end
	
	if position == 0 then
		position = 1
	end
	
	if position > #contents then
		position = #contents
	end
	
	table.insert(contents, position, ihandle)
	
	for k, v in ipairs(contents) do
		root:append(v)
	end
	
	iup.Refresh(root)
end



--draugath's old iup.IsValid, kept for posterity
he.is_iup = function(ihandle)
	return pcall(iup.GetType, ihandle)
end



--gets pixel position of the mouse
he.get_mouse_abs_pos = function(x_off, y_off)
	local perX, perY = gkinterface.GetMousePosition()
	local absX = (gkinterface.GetXResolution() * perX) + (tonumber(x_off) or 0)
	local absY = (gkinterface.GetYResolution() * perY) + (tonumber(y_off) or 0)
	
	return absX, absY
end



--scales a 1d value so that sizes are similar on all systems
he.scale_size = function(expected_size, expected_default)
	assert(type(expected_size) == "number", "helium.scale_size expects a number for the 'expected size' (arg 1), got " .. type(expected_size))
	if (type(expected_default) ~= "number") or (expected_default < 1) then
		expected_default = 24
	end
	
	return (Font.Default / expected_default) * expected_size
end



--scales 2d sizes based on an expected font size
he.scale_2x = function(exp_x, exp_y, exp_def)
	if (type(exp_def) ~= "number") or (exp_def < 1) then
		exp_def = 24
	end
	return tostring(he.scale_size(exp_x, exp_def)) .. "x" .. tostring(he.scale_size(exp_y, exp_def))
end



--splits numeric values into a table. if used on iup.size string, returns {x, y}
he.iter_nums_from_string = function(size)
	local entries = {}
	for value in string.gmatch(size, "%d+") do
		table.insert(entries, tonumber(value))
	end
	
	return entries
end



public.util = he
return public