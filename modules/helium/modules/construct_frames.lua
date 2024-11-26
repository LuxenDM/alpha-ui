local file_args = {...}

local public = file_args[1]
local private = file_args[2]

local he = {} -->>public.construct._func()





--a simple frame that can be expanded or shrank vertically; contents are stored and append/detached
he.vexpandbox = function(intable)
	local default = {
		state = "CLOSED",
		map_cb = nil,
		drawer_cb = function(self) end,
		[1] = iup.vbox {},
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local vexpand
	local contents = iup.vbox {}
	local contents_table = {}
	
	for k, v in ipairs(default) do 
		table.insert(contents_table, v)
		if default.state == "OPEN" then
			contents:append(v)
		end
	end
	
	vexpand = he.control.clearframe {
		map_cb = default.map_cb,
		contents,
		state = default.state,
		get_obj_table = function(self)
			return contents_table
		end,
		drawer_toggle = function(self, new_state)
			if new_state == "OPEN" or new_state == "CLOSED" then
				self.state = new_state
			else
				self.state = self.state == "OPEN" and "CLOSED" or "OPEN"
			end
			
			if self.state == "CLOSED" then
				for k, v in ipairs(contents_table) do
					v:detach()
				end
			else
				for k, v in ipairs(contents_table) do
					contents:append(v)
				end
			end
			
			iup.Refresh(self)
			default.drawer_cb(self)
		end,
	}
	
	return vexpand
end



--a simple frame that can be expanded or shrank horizontally; contents are stored and append/detached
he.hexpandbox = function()
	local default = {
		state = "CLOSED", --current state of drawer. closed is hidden.
		map_cb = nil,
		drawer_cb = function(self) end, --called after expand/contracting the drawer
		[1] = iup.hbox {},
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local vexpand
	local contents = iup.hbox {}
	local contents_table = {}
	
	for k, v in ipairs(default) do 
		table.insert(contents_table, v)
		if default.state == "OPEN" then
			contents:append(v)
		end
	end
	
	hexpand = he.control.clearframe {
		map_cb = default.map_cb,
		contents,
		state = default.state,
		get_obj_table = function(self)
			return contents_table
		end,
		drawer_toggle = function(self, new_state)
			if new_state == "OPEN" or new_state == "CLOSED" then
				self.state = new_state
			else
				self.state = self.state == "OPEN" and "CLOSED" or "OPEN"
			end
			
			if self.state == "CLOSED" then
				for k, v in ipairs(contents_table) do
					v:detach()
				end
			else
				for k, v in ipairs(contents_table) do
					contents:append(v)
				end
			end
			
			iup.Refresh(self)
			default.drawer_cb(self)
		end,
	}
	
	return hexpand
end



--a vertically scrolling pane, without using a control iup.list
he.vscroll = function(intable)
	local default = {
		expand = "YES",
		[1] = iup.vbox { },
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local iup_element = default[1]
	default[1] = nil
	
	local imposter = public.primitives.clearframe {
		--used to get size of parent
		expand = "YES",
		iup.vbox {
			iup.hbox {
				iup.fill { },
			},
			iup.fill { },
		},
	}
	
	local content_frame = public.primitives.clearframe {
		cx = 0,
		cy = 0,
		iup_element,
	}
	
	local scroller
	scroller = public.primitives.vslider {
		scroll_event_cb = function()
			content_frame.cy = ((scroller:get_pos() * (content_frame.h - scroller.h)) / 100) * -1
			iup.Refresh(content_frame)
		end,
	}
	
	local cbox_area = iup.cbox {
		expand = "YES",
		content_frame,
	}
	
	default[1] = iup.hbox {
		cbox_area,
		scroller,
	}
	
	local root_frame = public.primitives.clearframe(default)
	root_frame.map_cb = function(self)
		if self.expand == "NO" then
			return
		end
		
		--todo: determine if cbox_area < frame size; hide scroller if true
		
		local root = imposter --iup.GetParent(self)
		local w = root.w
		local h = root.h
		self.size = tostring(w) .. "x" .. tostring(h)
		cbox_area.size = tostring(w - Font.Default) .. "x" .. tostring(h)
		scroller.size = tostring(Font.Default) .. "x" .. tostring(h)
		content_frame.size = tostring(w - Font.Default) .. "x" .. tostring(content_frame.h)
		private.cp("vscroller fit-to-parent feedback:")
		private.cp("	parent w: " .. tostring(w))
		private.cp("	parent h: " .. tostring(h))
		private.cp("	size: " .. tostring(self.size))
		iup.Refresh(self)
		private.cp("	size (post-refresh): " .. tostring(self.size))
	end
	
	local final_frame = iup.zbox {
		root_frame,
		default.expand == "YES" and imposter or nil,
	}
	
	return final_frame
end



--a horizontally scrolling pane, which iup.list cannot do
he.hscroll = function(intable)
	local default = {
		expand = "YES",
		[1] = iup.hbox { },
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local iup_element = default[1]
	default[1] = nil
	
	local imposter = public.primitives.clearframe {
		--used to get size of parent
		expand = "YES",
		iup.vbox {
			iup.hbox {
				iup.fill { },
			},
			iup.fill { },
		},
	}
	
	local content_frame = public.primitives.clearframe {
		cx = 0,
		cy = 0,
		iup_element,
	}
	
	local scroller
	scroller = public.primitives.hslider {
		scroll_event_cb = function()
			content_frame.cx = ((scroller:get_pos() * (content_frame.w - scroller.w)) / 100) * -1
			iup.Refresh(content_frame)
		end,
	}
	
	local cbox_area = iup.cbox {
		expand = "YES",
		content_frame,
	}
	
	default[1] = iup.vbox {
		cbox_area,
		scroller,
	}
	
	local root_frame = public.primitives.clearframe(default)
	root_frame.map_cb = function(self)
		if self.expand == "NO" then
			return
		end
		
		--todo: determine if cbox_area < frame size; hide scroller if true
		
		local root = imposter --iup.GetParent(self)
		local w = root.w
		local h = root.h
		self.size = tostring(w) .. "x" .. tostring(h)
		cbox_area.size = tostring(w) .. "x" .. tostring(h - Font.Default)
		scroller.size = tostring(w) .. "x" .. tostring(Font.Default)
		content_frame.size = tostring(content_frame.w) .. "x" .. tostring(h - Font.Default)
		private.cp("hscroller fit-to-parent feedback:")
		private.cp("	parent w: " .. tostring(w))
		private.cp("	parent h: " .. tostring(h))
		private.cp("	size: " .. tostring(self.size))
		iup.Refresh(self)
		private.cp("	size (post-refresh): " .. tostring(self.size))
	end
	
	local final_frame = iup.zbox {
		root_frame,
		default.expand == "YES" and imposter or nil,
	}
	
	return final_frame
end



--horizontal list of buttons, used for tabs maybe
he.hbuttonlist = function(intable)
	local default = {
		select_cb = function(self, select_index, previous_index)
			
		end,
		provider = iup.stationbutton,
		
		fgcolor_base = "100 100 100",
		fgcolor_select = "255 255 255",
		
		bgcolor_base = nil,
		bgcolor_select = nil,
		
		default_select = 1,
		
		[1] = "untitled",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local last_selection = default.default_select
	
	local button_tabl = {}
	local button_disp = iup.hbox {}
	local button_frame = public.primitives.clearframe {
		button_disp,
	}
	
	local make_button = function(text, index)
		local new_button = default.provider {
			title = tostring(text),
			button_index = index,
			fgcolor = default.fgcolor_base,
			bgcolor = default.bgcolor_base,
			action = function(self)
				if default.fgcolor_select then
					button_tabl[last_selection].fgcolor = default.fgcolor_base
					self.fgcolor = default.fgcolor_select
				end
				
				if default.bgcolor_select then
					button_tabl[last_selection].bgcolor = default.bgcolor_base
					self.bgcolor = default.bgcolor_select
				end
				
				default.select_cb(button_frame, self.button_index, last_selection)
				
				last_selection = tonumber(self.button_index)
			end,
		}
		
		if default.fgcolor_select and index == (default.default_select) then
			new_button.fgcolor = default.fgcolor_select
		end
		
		if default.bgcolor_select and index == (default.default_select) then
			new_button.bgcolor = default.bgcolor_select
		end
		
		return new_button
	end
	
	for k, v in ipairs(intable) do
		local new_button = make_button(v, k)
		
		table.insert(button_tabl, new_button)
		iup.Append(button_disp, new_button)
	end
	
	button_frame.get_button_by_index = function(self, index)
		return button_tabl[index]
	end
	
	button_frame.get_num_buttons = function(self)
		return #button_tabl
	end
	
	--todo: ability to add, remove buttons. indexes need to be configured on every refresh
	
	return button_frame
end



--vertical list of buttons, used for tabs maybe
he.vbuttonlist = function(intable)
	local last_selection = -1
	
	local default = {
		select_cb = function(self, select_index, previous_index)
			
		end,
		provider = iup.stationbutton,
		
		fgcolor_base = "100 100 100",
		fgcolor_select = "255 255 255",
		
		bgcolor_base = nil,
		bgcolor_select = nil,
		
		[1] = "untitled",
	}
	
	for k, v in pairs(intable) do
		default[k] = v
	end
	
	local button_tabl = {}
	local button_disp = iup.vbox {}
	local button_frame = public.primitives.clearframe {
		button_disp,
	}
	
	for k, v in ipairs(intable) do
		local new_button = default.provider {
			title = tostring(v),
			button_index = k,
			fgcolor = default.fgcolor_base,
			bgcolor = default.bgcolor_base,
			action = function(self)
				if default.fgcolor_select then
					button_tabl[last_selection].fgcolor = default.fgcolor_base
					self.fgcolor = default.fgcolor_select
				end
				
				if default.bgcolor_select then
					button_tabl[last_selection].bgcolor = default.bgcolor_base
					self.bgcolor = default.bgcolor_select
				end
				
				default.select_cb(button_frame, self.button_index, last_selection)
				
				last_selection = self.button_index
			end,
		}
		
		table.insert(button_tabl, new_button)
		iup.Append(button_disp, new_button)
	end
	
	button_frame.get_button_by_index = function(self, index)
		return button_tabl[index]
	end
	
	button_frame.get_num_buttons = function(self)
		return #button_tabl
	end
	
	--todo: ability to add, remove buttons. indexes need to be configured on every refresh
	
	return button_frame
end



for k, v in pairs(he) do
	public.constructs[k] = v
end
return public