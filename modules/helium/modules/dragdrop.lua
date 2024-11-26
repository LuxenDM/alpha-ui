local file_args = {...}

local public = file_args[1]
local private = file_args[2]

local he = {} --these go to constructs



--button to launch a dragable item.
he.drag_item = function()
	
end



--panel to accept dragged items
he.drag_target = function()
	
end



for k, v in pairs(he) do
	public.constructs[k] = v
end
return public