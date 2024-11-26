local file_args = {...}

local public = file_args[1]
local private = file_args[2]

local he = {} -->>public.primitives._func()



--todo: replace assert() with cerr()?



--transparent frame template
he.clearframe = function(intable)
	--assert(type(intable) == "table", "Helium.clearframe expects a table for its argument, got a " .. type(intable))
	--assert((iup.IsValid(intable[1])) or (intable[1] == nil), "Helium.solidframe input table did not have a valid IUP element at [1]; got " .. type(intable[1]))
	
	local defaults = {
		image = private.tryfile("solidframe.png"),
		bgcolor = "0 0 0 0 *",
		segmented = "0 0 1 1",
		iup.vbox { },
		expand = "NO",
	}
	
	for k, v in pairs(intable) do
		defaults[k] = v
	end
	
	return iup.frame(defaults)
end



--very simple opaque panel
he.solidframe = function(intable)
	assert(type(intable) == "table", "Helium.solidframe expects a table for its argument, got a " .. type(intable))
	assert((iup.IsValid(intable[1])) or (intable[1] == nil), "Helium.solidframe input table did not have a valid IUP element at [1]; got " .. type(intable[1]))
	
	local defaults = {
		image = private.tryfile("solidframe.png"),
		bgcolor = "255 255 255 255 *",
		segmented = "0.1 0.1 0.9 0.9",
		iup.vbox { },
		expand = "NO",
	}
	
	for k, v in pairs(intable) do
		defaults[k] = v
	end
	
	return iup.frame(defaults)
end



--very simple edge frame
he.borderframe = function(intable)
	assert(type(intable) == "table", "Helium.borderframe expects a table for its argument, got a " .. type(intable))
	
	local defaults = {
		image = private.tryfile("borderframe.png"),
		bgcolor = "255 255 255 255 *",
		segmented = "0.1 0.1 0.9 0.9",
		iup.vbox { },
		expand = "NO",
	}
	
	for k, v in pairs(intable) do
		defaults[k] = v
	end
	
	assert((iup.IsValid(intable[1])), "Helium.solidframe input table did not have a valid IUP element at [1]; got " .. type(intable[1]))
	
	return iup.frame(defaults)
end



--primitive object used for highlite rules (hover on mouseover stuff), controlled by parent
he.highlite_panel = function()
	local highlite_obj = iup.label {
		title = "",
		image = private.tryfile("buttonRounded.png"),
		bgcolor = "255 255 255 0 *",
		expand = "YES",
		highlite = function(self)
			self.bgcolor = "255 255 255 255 *"
		end,
		clear_highlite = function(self)
			self.bgcolor = "255 255 255 0 *"
		end,
	}
	
	return highlite_obj
end



--primitive spacer using a frame object, mimics html <hr> kinda
--its actually a complex, but bite me
he.page_rule = function(intable)
	local default = {
		orientation = "HORIZONTAL",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	default[1] = iup.vbox {
		((default.orientation == "VERTICAL") or (default.orientation == "ALL")) and iup.fill { } or nil,
		iup.hbox {
			((default.orientation == "HORIZONTAL") or (default.orientation == "ALL")) and iup.fill { } or nil,
		},
	}
	
	local object = he.control.solidframe (default)
	
	return object
end



--preset progress bar. default valuess of iup.progressbar are wierd.
--todo: add functions for async value tweening and preset images. also, just figure out things?
he.progressbar = function(intable)
	local defaults = {
		--uppertexture = tryfile("progress_frame.png")
		--middletexture = tryfile("??")
		--lowertexture = tryfile("??")
		
		uppercolor = "255 255 255 255 *",
		--middleabovecolor = 
		--middlebelowcolor = 
		lowercolor = "0 0 0 255 *",
		
		type = "HORIZONTAL",
		
		minvalue = 0,
		maxvalue = 100,
		value = 33,
		
		size = "200x" .. tostring(Font.Default),
	}
	
	for k, v in pairs(intable) do
		defaults[k] = v
	end
	
	return iup.progressbar(defaults)
end



he.hslider = function(intable)
	
	local scroll_timer = Timer()
		--scroll_cb is called EVERY FRAME during a drag event. if your function is heavy, use scroll_event_cb() instead. There should be an EVEN better way of doing this, but i've not found it
	local scroll_flag = false
	
	local default = {
		xmin = 0,
		xmax = 100,
		dx = 30,
		posx = 0,
		scrollbar = "HORIZONTAL",
		expand = "HORIZONTAL",
		scroll_event_cb = function() end, --called by timer when flagged with default scroll_cb()
		scroll_cb = function(self)
			scroll_flag = true
		end,
		border = "NO",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local scroller = iup.canvas(default)
	
	scroller.get_pos = function(self)
		--get percentage position
		return (self.posx / (self.xmax - self.xmin) * 100)
	end
	
	local scroll_update
	scroll_update = function()
		if not iup.IsValid(scroller) then
			scroll_timer:Kill()
			return
		end
		
		if scroll_flag then
			default.scroll_event_cb(scroller)
			scroll_flag = false
		end
		
		scroll_timer:SetTimeout(1, scroll_update)
	end
	
	scroller.init_timer = function(self)
		scroll_update()
	end
	
	scroller.map_cb = function(self)
		--if map_cb is replaced, this needs to be added manually to it
		self:init_timer()
	end
	
	return scroller
end


--[[
	old vslider element, kept in case I need it for some stupid reason
he.vslider = function(intable)
	
	local scroll_timer = Timer()
		--scroll_cb is called EVERY FRAME during a drag event. if your function is heavy, use scroll_event_cb() instead. There should be an EVEN better way of doing this, but i've not found it
	
	local default = {
		ymin = 0,
		ymax = 100,
		dy = 30,
		posy = 0,
		scrollbar = "VERTICAL",
		expand = "VERTICAL",
		scroll_event_cb = function() end, --called by timer with default scroll_cb()
		scroll_cb = function(self)
			scroll_timer:SetTimeout(1, self.scroll_event_cb)
		end,
		border = "NO",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local scroller = iup.canvas(default)
	
	scroller.get_pos = function(self)
		--get percentage position
		return (self.posy / (self.ymax - self.ymin) * 100)
	end
	
	return scroller
end
]]--

he.vslider = function(intable)
	
	local scroll_timer = Timer()
		--scroll_cb is called EVERY FRAME during a drag event. if your function is heavy, use scroll_event_cb() instead. There should be an EVEN better way of doing this, but i've not found it
	local scroll_flag = false
	
	local default = {
		ymin = 0,
		ymax = 100,
		dy = 30,
		posy = 0,
		scrollbar = "VERTICAL",
		expand = "VERTICAL",
		scroll_event_cb = function() end, --called by timer when flagged with default scroll_cb()
		scroll_cb = function(self)
			scroll_flag = true
		end,
		border = "NO",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local scroller = iup.canvas(default)
	
	scroller.get_pos = function(self)
		--get percentage position
		return (self.posy / (self.ymax - self.ymin) * 100)
	end
	
	local scroll_update
	scroll_update = function()
		if not iup.IsValid(scroller) then
			scroll_timer:Kill()
			return
		end
		
		if scroll_flag then
			default.scroll_event_cb(scroller)
			scroll_flag = false
		end
		
		scroll_timer:SetTimeout(1, scroll_update)
	end
	
	scroller.init_timer = function(self)
		scroll_update()
	end
	
	scroller.map_cb = function(self)
		--if map_cb is replaced, this needs to be added manually to it
		self:init_timer()
	end
	
	return scroller
end



--single-button toggle that switches between options when pressed
he.cycle_button = function(intable)
	local default = {
		base = iup.stationbutton,
		action = function(self)
			
		end,
		default = 1,
		[1] = "Untitled",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local get_longest = function()
		--doesn't actually get LONGEST string, just one with most chars
		local longest = 0
		local longest_index = -1
		for k, v in ipairs(default) do
			local length = string.len(v)
			if length > longest then
				longest_index = k
				longest = length
			end
		end
		
		return longest_index
	end
	
	local cycle_button = default.base {
		title = default[get_longest()],
		index = default.default,
		map_cb = function(self)
			self.size = tostring(self.w) .. "x" .. tostring(self.h)
			self.title = default[default.default]
		end,
		action = function(self)
			self.index = self.index
			self.index = tonumber(self.index) + 1
			if tonumber(self.index) > #default then
				self.index = 1
			end
			self.title = default[tonumber(self.index)]
			default.action(self, tonumber(self.index))
		end,
	}
	
	return cycle_button
end



public.primitives = he
return public