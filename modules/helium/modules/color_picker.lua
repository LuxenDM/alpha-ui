local file_args = {...}

local public = file_args[1]
local private = file_args[2]

local he = {} --these go to constructs, but the preset is handled seperately
local preset = {}



--ship paint select panel. acts like a button/dragable element
he.paint_panel = function()
	
end



--RGB select panel. acts like a button/dragable element
he.color_panel = function()
	
end



--ship paint select panel. viewer and config button. opens color_diag in palette-only mode
he.paint_select = function()
	
end



--RGB select panel. viewer and config button
he.color_select = function()
	
end



--preset dialog to select a color. tabs between ship palette and RGB picker, inactive if set to palette-only mode. returns user-selected color when closed (if opened by a paint_select/color_select, updates the caller with new color
preset.color_diag = function()
	
end



for k, v in pairs(he) do
	public.constructs[k] = v
end
for k, v in pairs(preset) do
	public.presets[k] = v
end
return public