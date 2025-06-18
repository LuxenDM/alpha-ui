local file_args = {...}

local public = file_args[1]
local private = file_args[2]
local config = file_args[3]

local sa = iup.StoreAttribute --the devs think its important to shortcut this for efficiency, sop i'll do that too

local percent_to_color = {
	[0] = "128 0 0 100 *",
	[33] = "128 88 0 100 *",
	[66] = "44 128 0 100 *",
	[80] = "0 44 128 100 *",
}
local percent_thresholds = {
	[1] = 80,
	[2] = 66,
	[3] = 33,
	[4] = 0,
}

local get_col = function(inval)
	for _, threshold in ipairs(percent_thresholds) do
		if inval > threshold then
			return percent_to_color[threshold]
		end
	end
	return "255 255 255 255 *" --error, value below 0
end

local update_types = { --called on every update
	energy = function(bar)
		local current_int, percent_float = GetActiveShipEnergy()
		local per_val = math.floor(percent_float * 100)
		sa(bar, 'value', per_val)
		sa(bar, 'lowercolor', get_col(per_val))
	end,
	hull = function(bar)
		local hull_data = {GetActiveShipHealth()}
		--arg1 through arg6 are individual segment damage counters. they add up to arg7
		--arg8 is total health. arg9/arg10 are sheild values
		local hull_percent = math.floor(((hull_data[8] - hull_data[7]) / hull_data[8]) * 100)
		sa(bar, 'value', hull_percent)
		sa(bar, 'lowercolor', get_col(hull_percent))
	end,
	velocity = function(bar)
		--trinary
		sa(bar, 'value', GetActiveShipSpeed() or 0)
		sa(bar, 'altvalue', Game.GetDesiredSpeed() or 0)
	end,
	shield = function(bar)
		--trinary
		local hull_data = {GetActiveShipHealth()}
		local hull_percent = math.floor(((hull_data[8] - hull_data[7]) / hull_data[8]) * 100)
		sa(bar, 'value', hull_percent)
		sa(bar, 'lowercolor', get_col(hull_percent))
		sa(bar, 'altvalue', (((hull_data[9] or 0) / (hull_data[10] or 1)) * 100))
	end,
}

local init_types = { --called on creation or change type
	energy = function(bar)
		bar.mode = "BINARY"
		bar.maxvalue = 100
		bar.lowercolor = "128 128 128 100 *"
	end,
	hull = function(bar)
		bar.mode = "BINARY"
		bar.maxvalue = 100
		bar.lowercolor = "128 128 128 100 *"
	end,
	velocity = function(bar)
		--trinary if F/A
		bar.mode = "BINARY"
		bar.maxvalue = GetActiveShipMaxSpeed() or 50
		bar.lowercolor = "128 128 128 100 *"
		if Game.GetFlightMode() then
			--F/A enabled
			bar.mode = "TRINARY"
		end
	end,
	shield = function(bar)
		--handles hull and shield in trinary
		bar.mode = "TRINARY"
		local hull_data = {GetActiveShipHealth()}
		bar.maxvalue = 100
		bar.lowercolor = "128 128 128 100 *"
	end,
}

public.create_multibar = function(intable)
	local default = {
		tick_rate = config.tick_rate,
		
		inner = "energy",
		outer = "hull",
		orientation = "left",
		expand = "YES",
		size = nil,
		
		--texture overrides
		inner_filled = nil,
		inner_empty = nil,
		outer_filled = nil,
		outer_empty = nil,
	}
	
	for i, v in pairs(intable) do
		default[i] = v
	end
	
	default.orientation = (string.lower(default.orientation) == "right" and "right") or "left"
	
	--textures
	local inner_filled = default.inner_filled or (private.path .. "assets/hud_" .. default.orientation .. "_inner.png")
	
	local inner_empty = default.inner_empty or (private.path .. "assets/hud_" .. default.orientation .. "_inner_empty.png")
	
	local outer_filled = default.outer_filled or (private.path .. "assets/hud_" .. default.orientation .. "_outer.png")
	
	local outer_empty = default.outer_empty or (private.path .. "assets/hud_" .. default.orientation .. "_outer_empty.png")
	
	
	
	local inner_bar = iup.progressbar {
		type = "VERTICAL",
		mode = "BINARY",           -- Trinary Enables VALUE + ALTVALUE region logic
		minvalue = 0,
		maxvalue = 100,
		
		value = 0,                  -- primary value
		altvalue = 0,               -- secondary value
		
		lowertexture = inner_filled, --value AND altvalue texture
		middletexture = inner_filled, --value OR altvalue texture
		uppertexture = inner_empty, --NOT (value or altvalue) // background
		
		middlebelowtexture = inner_filled, --for trinary mode
		middleabovetexture = inner_filled, --for trinary mode
		
		--can't use colors - doesn't work with images using alpha-transparency
		--actually, maybe it does with matching textures and not just middletex
		
		lowercolor = "128 128 128 100 *",			-- where value and altvalue > minimum
		middlebelowcolor = "128 0 0 100 *",	-- where altvalue > value
		middleabovecolor = "0 128 0 100 *",   -- where value > altvalue
		uppercolor = "128 128 128 100 *",   	-- where value and altvalue < max
		
		--uv = "0 0 1 1", --this just means 'use the whole image', we're not doing any image cropping here, and 0 0 1 1 is the default afaik
		
		active = "NO",
		expand = default.expand,
		size = default.size,
		
		_tracking = default.inner,
	}
	
	local outer_bar = iup.progressbar {
		type = "VERTICAL",
		mode = "BINARY",           -- Trinary Enables VALUE + ALTVALUE region logic
		minvalue = 0,
		maxvalue = 100,
		
		value = 0,                  -- primary value
		altvalue = 0,               -- secondary value
		
		lowertexture = outer_filled, --value AND altvalue texture
		middletexture = outer_filled, --value OR altvalue texture
		uppertexture = outer_empty, --NOT (value or altvalue) // background
		
		middlebelowtexture = outer_filled, --for trinary mode
		middleabovetexture = outer_filled, --for trinary mode
		
		lowercolor = "128 128 128 100 *",			-- where value and altvalue > minimum
		middlebelowcolor = "128 0 0 100 *",	-- where altvalue > value
		middleabovecolor = "0 128 0 100 *",   -- where value > altvalue
		uppercolor = "128 128 128 100 *",   	-- where value and altvalue < max
		
		--uv = "0 0 1 1", --this just means 'use the whole image', we're not doing any image cropping here, and 0 0 1 1 is the default afaik
		
		active = "NO",
		expand = default.expand,
		size = default.size,
		
		_tracking = default.outer,
	}
	
	if not init_types[inner_bar._tracking] then inner_bar._tracking = "energy" end
	if not init_types[outer_bar._tracking] then outer_bar._tracking = "energy" end
	
	init_types[inner_bar._tracking](inner_bar)
	init_types[outer_bar._tracking](outer_bar)
	
	local pause_updates = false
	
	local update_timer = Timer()
	local update_func
	update_func = function()
		update_timer:SetTimeout(tonumber(default.tick_rate) or 33, update_func)
		
		if pause_updates or (inner_bar.visible == "NO") then
			return
		end
		
		update_types[inner_bar._tracking](inner_bar)
		update_types[outer_bar._tracking](outer_bar)
	end
end

