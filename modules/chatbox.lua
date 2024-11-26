local gkrs = gkini.ReadString

local file_args = {...}

local private = file_args[1]
private.chatbox = {
	selected_channel = {
		--current channel data
		reset_flag = true,
		origin = "SECTOR",
		name = "General Chat",
		control = "CHANNEL",
		subcon = "33765",
	},
	input_history = {
		[-1] = "",
		[0] = "",
	},
	history_index = 0,
}
local public = file_args[2]
public.chatbox = {}
local config = file_args[3]
config.chatbox = {
	--chatbox config
	log_length = gkrs("alphaui", "log_length", "200"),
	text_length = gkrs("alphaui", "text_length", "10000"),
	clear_on_login = gkrs("alphaui", "clear_on_login", "NO"),
	default_channel = gkrs("alphaui", "chat_default_channel", "100"),
	named_channels = {
		["1"] = "Newbie/Help Chat",
		["11"] = "Nation Chat",
		["100"] = "General Chat",
	},
	colors = {}, --read from config
}

local he = lib.get_class("helium", "0.5.0 -dev")

local init_events_list = {
	--todo: functions can register new events and reset the chat reciever to handle custom inputs. There should be a non-event hook for this too
	"CHAT_MSG_MOTD",
	"CHAT_MSG_ERROR",
	"CHAT_MSG_PRINT",
	"CHAT_MSG_SERVER",
	"CHAT_MSG_CONFIRMATION",
	"CHAT_MSG_PRIVATE",
	"CHAT_MSG_PRIVATEOUTGOING",
	"CHAT_MSG_DEATH",
	"CHAT_MSG_DISABLED",
	"CHAT_MSG_SERVER_CHANNEL",
	"CHAT_MSG_SERVER_CHANNEL_ACTIVE",
	"CHAT_MSG_CHANNEL_EMOTE",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_CHANNEL_EMOTE_ACTIVE",
	"CHAT_MSG_CHANNEL_ACTIVE",
	"CHAT_MSG_SERVER_SECTOR",
	"CHAT_MSG_SECTOR_EMOTE",
	"CHAT_MSG_SECTOR",
	"CHAT_MSG_GOBAL_SERVER",
	"CHAT_MSG_NATION",
	"CHAT_MSG_SERVER_GUILD",
	"CHAT_MSG_GUILD_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_GUILD_MOTD",
	"CHAT_MSG_GUIDE",
	"CHAT_MSG_GROUP",
	"CHAT_MSG_GROUP_NOTIFICATION",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_MISSION",
	"CHAT_MSG_SECTORD",
	"CHAT_MSG_SECTORD_SECTOR",
	"CHAT_MSG_SECTORD_MISSION",
	"CHAT_MSG_BAR_EMOTE",
	"CHAT_MSG_BAR",
	"CHAT_MSG_BAR_EMOTE1",
	"CHAT_MSG_BAR1",
	"CHAT_MSG_BAR_EMOTE2",
	"CHAT_MSG_BAR2",
	"CHAT_MSG_BAR_EMOTE3",
	"CHAT_MSG_BAR3",
	"CHAT_MSG_BARENTER",
	"CHAT_MSG_BARLEAVE",
	"CHAT_MSG_BARLIST",
	"CHAT_MSG_BUDDYNOTE",
	"CHAT_MSG_INCOMINGBUDDYNOTE",
	"CHAT_MSG_STORAGERENTALMSG",
	"LOGIN_SUCCESSFUL",
}

for k, v in ipairs(init_events_list) do
	config.chatbox.colors[v] = gkrs("chatbox_colors", v, "255 255 255")
end

local chatlog = {
	new = function(self, msgtable)
		if type(msgtable) ~= "table" then
			msgtable = {msgtable}
		end
		msgtable.time = os.time()
		table.insert(self, msgtable)
		if #self > tonumber(config.chatbox.log_length) then
			table.remove(self, 1)
		end
	end,
	async_dump = function(self, reciever)
		--async-get log contents
		if type(reciever) ~= "function" then
			return false
		end
		
		local process_timer = Timer()
		local counter = 0
		local process_func
		process_func = function()
			counter = counter + 1
			if counter > #self then
				reciever({-1, "END OF LOG", event = "CHATBOX_CONTROL"})
				return
			end
			reciever(self[counter])
			process_timer:SetTimeout(1, process_func)
		end
		process_timer:SetTimeout(1, process_func)
	end,
	[1] = {
		-1,
		"DUMMY ENTRY",
		event = "CHATBOX_CONTROL",
	},
}

public.chatbox.get_chat_history = function(reciever_function)
	chatlog:async_dump(reciever_function)
end



local highlite_names = {
	["Incarnate"] = true, --current dev
	["raybondo"] = true, --current dev
	["Glyptapanteles"] = true, --dev-run bot
	["a1k0n"] = true, --ex dev
	["musabi"] = true, --ex dev
	["VO-Discord"] = true, --dev-run bot
}

local preprocess_inputs = function(input)
	local ev = input.event or "NULL"
	local color = config.chatbox.colors[ev] or "255 255 255"
	input.color = color
	
	local from = input.name or "NULL"
	if from == "VO-Discord" then
		input.name = "RELAY"
	end
	
	if highlite_names[from] then
		input.faction = -1
	else
		
	end
	
	return input
end



local outputs = {
	--list of current outputs.
	new = function(self, registrar, callback)
		table.insert(self, {
			owner = registrar,
			func = callback or function() end,
		})
		
		return #self
	end,
	kill = function(self, kill_id)
		self[kill_id] = 0
	end,
}



local input_processor = function(input)
	--takes incoming messages, processes, and distributes them
	
	input[1] = 1 --what was this for again?
	input.event = input.event or "UNKNOWN EVENT"
	input = preprocess_inputs(input)
	chatlog:new(input)
	
	--async distribute messages
	local process_timer = Timer()
	local counter = 0
	local process_func
	process_func = function()
		counter = counter + 1
		if counter > #outputs then
			return
		end
		local func = outputs[counter].func
		if type(func) == 'function' then
			func(input)
		end
		process_timer:SetTimeout(1, process_func)
	end
	process_timer:SetTimeout(1, process_func)
end

local event_handler = function(event, data, ...)
	--starting point for incoming messages
	local args = {...}
	if type(data) == "table" then
		for k, v in pairs(data) do
			args[k] = v
		end
	else
		table.insert(args, data)
	end
	args.event = event
	
	--clear log on login (if configd)
	if (event == "LOGIN_SUCCESSFUL") and (config.chatbox.clear_on_login == "YES") then
		for i=#chatlog, 1, -1 do
			chatlog[i] = nil
		end
	end
	
	input_processor(args)
end

for k, v in ipairs(init_events_list) do
	RegisterEvent(event_handler, v)
end

public.chatbox.add_event = function(event, color)
	--add new events to receiver process
	RegisterEvent(event_handler, event)
	config.chatbox.colors[event] = color
end

local old_print = print
print = function(input_string)
	input_string = tostring(input_string)
	--console_print(input_string)
	old_print(input_string)
	event_handler("USER_PRINT", {
		msg = input_string,
	})
end













--interface builder

local parse_command_string = function(input) --wow, this is really different from get_args()
    -- Trim leading and trailing spaces
    input = input:match("^%s*(.-)%s*$")

    -- Find the command (first word)
    local command, rest = input:match("^(%S+)%s*(.*)")

    -- If there's no rest, create an empty string for further processing
    rest = rest or ""

    local args = {}
    local inQuotes = false
    local quoteChar = nil
    local currentArg = ""

    for i = 1, #rest do
        local char = rest:sub(i, i)
        if inQuotes then
            if char == quoteChar then
                inQuotes = false
                quoteChar = nil
                table.insert(args, currentArg)
                currentArg = ""
            else
                currentArg = currentArg .. char
            end
        else
            if char == '"' or char == "'" then
                inQuotes = true
                quoteChar = char
                if #currentArg > 0 then
                    table.insert(args, currentArg)
                    currentArg = ""
                end
            elseif char:match("%s") then
                if #currentArg > 0 then
                    table.insert(args, currentArg)
                    currentArg = ""
                end
            else
                currentArg = currentArg .. char
            end
        end
    end

    if #currentArg > 0 then
        table.insert(args, currentArg)
    end

    return command, rest, args
end

private.chatbox.input_action = function(self, key)
	private.chatbox.input_history[0] = self.value
	if key == iup.K_UP then
		private.chatbox.history_index = private.chatbox.history_index + 1
		if private.chatbox.history_index > #private.chatbox.input_history then
			private.chatbox.history_index = 0
		elseif private.chatbox.history_index < -1 then
			private.chatbox.history_index = #private.chatbox.input_history
		end
		self.value = private.chatbox.input_history[private.chatbox.history_index]
	elseif key == iup.K_DOWN then
		private.chatbox.history_index = private.chatbox.history_index - 1
		if private.chatbox.history_index > #private.chatbox.input_history then
			private.chatbox.history_index = 0
		elseif private.chatbox.history_index < -1 then
			private.chatbox.history_index = #private.chatbox.input_history
		end
		self.value = private.chatbox.input_history[private.chatbox.history_index]
	elseif key == 9 then --tab
		self.value = tabcomplete(self.value, self.caret)
		private.chatbox.input_history[0] = self.value
	elseif key == iup.K_PGUP then
		--self.scroll_up()
	elseif key == iup.K_PGDN then
		--self.scroll_down()
	elseif key == 3875 then --END key
		--self.scroll_down(true)
	elseif key == 3 then --CTRL + C
		Game.SetClipboardText(self.value)
	elseif key == 19 then --CTRL + S
		console_print(self.value)
	elseif key == 31 then --CTRL + Shift + Underscore
		self.value = self.value .. "\128"
	elseif key == 127 then --CTRL + Backspace
		self.value = ""
	elseif key == 13 then --enter key
		if self.value == "" then
			return
		end
		
		table.insert(private.chatbox.input_history, self.value)
		private.chatbox.history_index = 0
		
		local message = substitute_vars(self.value)
		local original = string.gsub(self.value, "[\n\r]+$", "")
		local prefix, line, args = parse_command_string(message)
		
		self.value = ""
		
		
		if string.sub(prefix, 1, 1) == "/" then
			if prefix == "/me" then
				--don't process, so no 'return' statement
			elseif prefix == "/clear" then
				self:clear_display()
				return
			elseif prefix == "/msg" then
				--is this needed? Yes, yes it is.
				
				return
			elseif prefix == "/roper" then
				--execute on-server lua
				--if you aren't authorized, nothing happens, but Incarnate gets a log notice
				roper(args[1])
				return
			elseif prefix == "/oper" then
				--admin command
				--if you aren't authorized, nothing happens, but Incarnate gets a log notice
				oper(args[1])
				return
			elseif prefix == "/lua" then
				print("Executing the following lua: " .. line)
				loadstring(line)()
				return
			elseif prefix == "/help" then
				if args[1] == "" then
					--open help menu
					return
				else
					SendChat(args[1], "CHANNEL", "1")
					return
				end
			elseif prefix == "/nation" then
				SendChat(args[1], "CHANNEL", "11")
				return
			elseif prefix == "/rp" then
				SendChat(args[1], "CHANNEL", "300")
				return
			elseif prefix == "/debug" then
				print("args: " .. spickle(args))
				print("orig: " .. original)
				print("msg : " .. message)
				return
			else
				gkinterface.GKProcessCommand(string.sub(original, 2))
				return
			end
		end
		
		local sctab = private.chatbox.selected_channel
		
		SendChat(original, sctab.control or "CHATBOX_ERROR", sctab.subcon or "CHATBOX_ERROR")
		
		self.value = ""
	end
end





local create_channel_table = function()
	
	--creates a table used when generating a player's channel list
	--insert, remove, update are currently unused
	
	local channel_select = -1
	local channel_list = {
		--[[
		[index] = {
			name = display name
			original = data name
			control = sendchat arg 2
			subcon = sendchat arg 3 or nil
			action = function reciever override (prevents sendchat)
		},
		]]--
		insert = function(self, item, insert_index)
			table.insert(self, insert_index or item, (insert_index and item or nil))
			self:update_ui()
		end,
		remove = function(self, remove_index)
			table.remove(self, remove_index)
			self:update_ui()
		end,
		update_ui = function() end,
		channel_select = -1,
	}
	
	do
		local numbered_channels = GetJoinedChannels()
		for k, v in ipairs(numbered_channels) do
			v = tostring(v)
			local name = config.chatbox.named_channels[v] or ((config.long_channel_names == "YES" and "Channel " or "") .. tostring(v))
			table.insert(channel_list, {
				origin = v,
				name = name,
				control = "CHANNEL",
				subcon = v,
			})
		end
	end
	
	do
		for k, v in ipairs {
			"SECTOR",
			"SYSTEM",
			"GROUP",
			"GUILD",
		} do
			local name = v
			if v == "GUILD" then
				name = GetGuildAcronym() or nil
			end
			if name then
				table.insert(channel_list, {
					origin = v,
					name = name,
					control = v,
					subcon = "*NONE",
				})
			end
		end
	end
	
	local find_default_channel = function(override)
		local def_channel = (override > 0 and "100") or config.default_channel
		for k, v in ipairs(channel_list) do
			if v.origin == def_channel then
				channel_select = k
				if private.chatbox.selected_channel.reset_flag then
					private.chatbox.selected_channel = v
				end
			end
		end
	end
	
	find_default_channel(0)
	if channel_select == -1 then
		--didn't find default, use "100" instead
		find_default_channel(1)
	end
	if channel_select == -1 then
		--player isn't in 100, use the first channel entry instead
		channel_select = 1
	end
	
	channel_list.channel_select = channel_select
	
	return channel_list
end



public.chatbox.create_channel_display = function(channel_table)
	
	--creates the channel selection interface item
	--[[
		redesign: banner shows current channel, with a context button for switching?
		wouldn't work for large number of channel options...
	]]--
	
	if not channel_table then
		--can provide custom display table
		channel_table = create_channel_table()
	end
	
	local display_list = {}
	for k, v in ipairs(channel_table) do
		--build name display used by helium's tab generator
		display_list[k] = v.name
	end
	
	display_list.select_cb = function(self, index)
		--on tab select, change channel_select index to new tab
		channel_table.channel_select = index
		private.chatbox.selected_channel = channel_table[tonumber(index)]
	end
	
	--display options
	display_list.active_color = config.focus_channel_color
	display_list.inactive_color = config.default_channel_color
	display_list.default_select = channel_table.channel_select
	
	--this is the display interface object
	local channel_display = he.constructs.hbuttonlist(display_list)
	
	--function to get currently selected, for sendchat()
	channel_display.get_selected = function()
		return channel_table.channel_select
	end
	
	return channel_display
end





public.chatbox.create_chat_view = function()
	local text_view = iup.multiline {
		size = "200x200",
		expand = "YES",
		active = "NO",
		indent = "YES",
		border = "NO",
		readonly = "YES",
		bgcolor = "0 0 0 100 *",
	}
	
	local view_id = -1
	
	local text_view_input = function(msg_table)
		if not iup.IsValid(text_view) then
			outputs:kill(view_id)
			return
		end
		
		if (not iup.GetDialog(text_view)) or (iup.GetDialog(text_view).visible == "NO") then
			return
		end
		
		if type(msg_table) ~= "table" then
			return
		elseif msg_table[1] == -1 then
			return --control, not input
		end
		
		--console_print(private.dump_table(msg_table))
		
		local msg = "\n" .. rgbtohex(msg_table.color or "255 255 255")
		
		if msg_table.channelid then
			msg = msg .. "[" .. tostring(msg_table.channelid) .. "]"
		elseif string.find(msg_table.event, "GUILD") then
			msg = msg .. "[" .. GetGuildAcronym() .. "]"
		elseif string.find(msg_table.event, "GROUP") then
			msg = msg .. "[GROUP]"
		elseif string.find(msg_table.event, "SECTOR") then
			msg = msg .. "[SECTOR]"
		elseif string.find(msg_table.event, "SYSTEM") then
			msg = msg .. "[SYSTEM]"
		elseif string.find(msg_table.event, "PRIVATE") then
			msg = msg .. "[MSG]"
		end
		
		if msg_table.name then
			if msg_table.faction == -1 then
				msg = msg .. rgbtohex("0 255 0")
			else
				msg = msg .. rgbtohex(FactionColor_RGB[msg_table.faction or "?"] or "255 255 255")
			end
			
			if string.find(msg_table.event, "EMOTE") then
				msg = msg .. " " .. msg_table.name .. " "
			else
				msg = msg .. " <" .. msg_table.name .. "> "
			end
		end
		
		if string.find(msg_table.event, "OUTGOING") then
			msg = msg .. " <<< "
		end
		
		msg = msg .. "\127FFFFFF" .. tostring(msg_table.msg)
		
		text_view.value = string.sub(text_view.value, -1 * tonumber(config.chatbox.text_length)) .. msg
	end
	
	public.chatbox.get_chat_history(text_view_input)
	
	view_id = outputs:new("chatbox", text_view_input)
	
	return text_view
end

public.chatbox.create_chat_entry = function()
	local text_input = iup.text {
		wanttab = "YES",
		size = "200x" .. tostring(Font.Default * 1.1),
		expand = "HORIZONTAL",
		font = Font.Default,
		value = "",
		
		action = private.chatbox.input_action,
		
		display_element = nil,
		clear_display = function(self)
			if self.display_element and iup.IsValid(self.display_element) then
				self.display_element.value = "\127FFFFFF"
			end
		end,
	}
	
	return text_input
end

public.chatbox.create_chat_preset = function()
	local tabs = he.constructs.hscroll {
		public.chatbox.create_channel_display()
	}
	
	local viewer_element = public.chatbox.create_chat_view()
	
	local entry_element = public.chatbox.create_chat_entry()
	entry_element.display_element = viewer_element
	
	local panel = iup.vbox {
		tabs,
		entry_element,
		viewer_element,
	}
	
	return panel
end

local test_chat = function()
	local chatbox = public.chatbox.create_chat_preset()
	
	declare("diag")
	
	diag = iup.dialog {
		topmost = "YES",
		fullscreen = "YES",
		bgcolor = "0 0 0 150 *",
		he.primitives.borderframe {
			bgcolor = "255 255 255 100 *",
			expand = "YES",
			iup.vbox {
				iup.hbox {
					iup.label {
						title = "AlphaUI Chat test panel",
					},
					iup.fill { },
					iup.button {
						title = "Close",
						action = function(self)
							HideDialog(iup.GetDialog(self))
						end,
					},
				},
				he.primitives.clearframe {
					expand = "YES",
					iup.vbox {
						iup.hbox {
							iup.fill { },
						},
						chatbox,
						iup.fill { },
					},
				},
			},
		},
	}
	
	
	he.util.map_dialog(diag)
	ShowDialog(diag)
end

RegisterUserCommand("alphachat", test_chat)


return private, public, config