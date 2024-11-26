local file_args = {...}

local public = file_args[1]
local private = file_args[2]

local he = {} -->>public.construct._func()



--invisible button to cover selected object
he.coverbutton = function(intable)
	local default = {
		action = function(self) end,
		expand = "NO",
		highlite = "NO",
		[1] = iup.vbox { },
		size = nil,
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local hlpane = he.primitives.highlite_panel()
	
	local cover = iup.button {
		title = "", 
		bgcolor = "0 0 0 0 *",
		expand = "YES",
		action = default.action,
		size = default.size,
		enterwindow_cb = function(self)
			hlpane:highlite()
		end,
		leavewindow_cb = function(self)
			hlpane:clear_highlite()
		end,
		destroy_cb = function()
			hlpane:destroy()
		end,
	}
	
	return iup.zbox {
		all = "YES",
		expand = default.expand,
		alignment = "ACENTER",
		default.highlite == "YES" and hlpane or nil,
		default[1],
		cover,
	}
end



--selectable_text uses a cover_button on top of a label. eventually will use frame/image properties to underline text maybe?
he.select_text = function(intable)
	local default = {
		title = "selectable text",
		action = function(self) end,
		font = Font.Default,
		fgcolor = nil,
		bgcolor = nil,
		highlite = "NO",
		size = nil,
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local obj = he.coverbutton {
		action = default.action,
		highlite = default.highlite,
		size = default.size,
		iup.label {
			title = default.title,
			font = default.font,
			fgcolor = default.fgcolor,
			bgcolor = default.bgcolor,
		},
	}
	
	return obj
end



--preset select_text used for URLs
he.link_text = function(intable)
	local default = {
		title = "selectable url",
		url = "http://vendetta-online.com/",
		font = Font.Default,
		fgcolor = "128 0 255",
		bgcolor = nil,
		highlite = "YES",
		size = nil,
		link_image = tryfile("weblink.png"),
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local linkimg = iup.label {
		title = "",
		image = default.link_image,
		size = tostring(default.font) .. "x" .. tostring(default.font),
	}
	
	local obj = he.coverbutton {
		action = function(self)
			Game.OpenWebBrowser(default.url or default.title)
		end,
		highlite = default.highlite,
		size = default.size,
		iup.hbox {
			iup.label {
				title = default.title,
				font = default.font,
				fgcolor = default.fgcolor,
				bgcolor = default.bgcolor,
			},
			default.link_image and linkimg or nil,
		},
	}
	
	return obj
end



--numeric input 'spin dial'
he.ticker = function(intable)
	local default = {
		constrain = "YES", --limit to min/max if yes
		min = 0,
		max = 10,
		default = 0,
		readonly = "NO", --prevents text edits. buttons are active.
		active = "YES", --overrides readonly; prevents any changes
		action = function(self, value, caller) end,
		v_size = tostring(mobile_scalar()),
		h_size = "200", --h_size of text control
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local tickframe
	
	local update_val = function(input, mod, editor)
		mod = tonumber(mod) or 0
		input = (tonumber(input) or 0) + mod
		if default.constrain == "YES" then
			if input > default.max then
				input = default.max
			elseif input < default.min then
				input = default.min
			end
		end
		tickframe.value = tostring(input)
		default.action(tickframe, tickframe.value, editor)
	end
	
	local tickreader = iup.text {
		size = tostring(default.h_size) .. "x" .. tostring(default.v_size),
		value = default.default,
		readonly = (default.active == "NO" and "YES") or default.readonly,
		action = function(self)
			self.value = string.match(self.value, "%d+%.?%d*")
			update_val(self.value, 0, "edit")
			self.value = tickframe.value
		end,
	}
	
	local uptick = iup.stationbutton {
		title = "+",
		size = tostring(default.v_size) .. "x" .. tostring(default.v_size / 2),
		active = default.active,
		action = function()
			update_val(tickframe.value, 1, "up")
			tickreader.value = tickframe.value
		end,
	}
	
	local downtick = iup.stationbutton {
		title = "-",
		size = tostring(default.v_size) .. "x" .. tostring(default.v_size / 2),
		active = default.active,
		action = function()
			update_val(tickframe.value, -1, "down")
			tickreader.value = tickframe.value
		end,
	}
	
	tickframe = public.primitives.borderframe {
		iup.hbox {
			tickreader,
			iup.vbox {
				uptick,
				downtick,
			},
		},
		value = default.default,
	}
	
	return tickframe
end



--mobile-style slide toggle control
he.slide_toggle = function()
	cerr("slide_toggle is a stub")
end



--triple button; two for navigating options, center to accept selection
he.multi_button = function()
	cerr("multi_button is a stub")
end



he.radio_collect = function()
	cerr("radio_collect is a stub")
end



he.bg_frame = function()
	
end



he.shrink_label = function()
	
end



public.constructs = he
return public