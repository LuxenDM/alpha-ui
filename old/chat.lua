chat = {
	log = {},
	history = {},
}

function chat:OnEvent(event, ...)
	if (event == "LOGIN_SUCCESSFUL") then
		self.log = {}
	else
		local data = ...
		if (#self.log > 100) then table.remove(self.log, 1) end
		local msg = (data.name and "<"..data.name.."> " or "")..data.msg
		table.insert(self.log, msg)
		self.text.value = table.concat(self.log, "\n")
	end
end

local function BuildChat()
	local box
	local text
	local entry
	
	text = iup.multiline{size = "xTHIRD", active = "NO", indent = "YES", expand = "HORIZONTAL", border = "NO", readonly = "YES"}
	entry = iup.text{expand = "HORIZONTAL", wanttab = "YES"}
	box = iup.vbox{
		text,
		entry,
		gap = 2,
	}

	function entry:action(char, str)
		if (char == 13) then -- Enter
			ProcessEvent("CHAT_DONE")
			self.value = ""
			if (string.sub(str, 1,1) == "/") then
				gkinterface.GKProcessCommand(string.sub(str, 2))
			else
				SendChat(str, "CHANNEL", 100)
			end
			
		elseif (char == 27) then -- Escape
			ProcessEvent("CHAT_CANCELLED")
			self.value = ""
		end
	end
	
	chat.entry = entry
	chat.text = text
	chat.box = box
end

BuildChat()

RegisterEvent(chat, "LOGIN_SUCCESSFUL")

RegisterEvent(chat, "CHAT_MSG_PRINT")
RegisterEvent(chat, "CHAT_MSG_SERVER")
RegisterEvent(chat, "CHAT_MSG_PRIVATE")
RegisterEvent(chat, "CHAT_MSG_PRIVATEOUTGOING")
RegisterEvent(chat, "CHAT_MSG_SERVER_CHANNEL")
RegisterEvent(chat, "CHAT_MSG_SERVER_CHANNEL_ACTIVE")
RegisterEvent(chat, "CHAT_MSG_CHANNEL_EMOTE")
RegisterEvent(chat, "CHAT_MSG_CHANNEL")
RegisterEvent(chat, "CHAT_MSG_CHANNEL_EMOTE_ACTIVE")
RegisterEvent(chat, "CHAT_MSG_CHANNEL_ACTIVE")
RegisterEvent(chat, "CHAT_MSG_SECTOR_EMOTE")
RegisterEvent(chat, "CHAT_MSG_SECTOR")
RegisterEvent(chat, "CHAT_MSG_GLOBAL_SERVER")
RegisterEvent(chat, "CHAT_MSG_NATION")
RegisterEvent(chat, "CHAT_MSG_SERVER_GUILD")
RegisterEvent(chat, "CHAT_MSG_GUILD_EMOTE")
RegisterEvent(chat, "CHAT_MSG_GUILD")
RegisterEvent(chat, "CHAT_MSG_GUILD_MOTD")
RegisterEvent(chat, "CHAT_MSG_GUIDE")
RegisterEvent(chat, "CHAT_MSG_GROUP")
RegisterEvent(chat, "CHAT_MSG_GROUP_NOTIFICATION")
RegisterEvent(chat, "CHAT_MSG_SYSTEM")
RegisterEvent(chat, "CHAT_MSG_BAR")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE")
RegisterEvent(chat, "CHAT_MSG_BAR1")
RegisterEvent(chat, "CHAT_MSG_BAR2")
RegisterEvent(chat, "CHAT_MSG_BAR3")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE1")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE2")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE3")
RegisterEvent(chat, "CHAT_MSG_BUDDYNOTE")
RegisterEvent(chat, "CHAT_MSG_INCOMINGBUDDYNOTE")
RegisterEvent(chat, "CHAT_MSG_BUDDYNOTE")
RegisterEvent(chat, "CHAT_MSG_INCOMINGBUDDYNOTE")
RegisterEvent(chat, "CHAT_MSG_PRIVATEOUTGOING")
RegisterEvent(chat, "CHAT_MSG_PRIVATE")
RegisterEvent(chat, "CHAT_MSG_BARLIST")
RegisterEvent(chat, "CHAT_MSG_BARENTER")
RegisterEvent(chat, "CHAT_MSG_BARLEAVE")
RegisterEvent(chat, "CHAT_MSG_BAR")
RegisterEvent(chat, "CHAT_MSG_BAR1")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE1")
RegisterEvent(chat, "CHAT_MSG_BAR2")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE2")
RegisterEvent(chat, "CHAT_MSG_BAR3")
RegisterEvent(chat, "CHAT_MSG_BAR_EMOTE3")
RegisterEvent(chat, "CHAT_MSG_SECTOR")
RegisterEvent(chat, "CHAT_MSG_SECTOR_EMOTE")
RegisterEvent(chat, "CHAT_MSG_MISSION")
RegisterEvent(chat, "CHAT_MSG_SECTORD_MISSION")
RegisterEvent(chat, "CHAT_MSG_GUILD")
RegisterEvent(chat, "CHAT_MSG_GUILD_EMOTE")
RegisterEvent(chat, "CHAT_MSG_GUIDE")
RegisterEvent(chat, "CHAT_MSG_GROUP")
RegisterEvent(chat, "CHAT_MSG_GROUP_NOTIFICATION")
RegisterEvent(chat, "CHAT_MSG_SYSTEM")
RegisterEvent(chat, "CHAT_MSG_SECTORD")
RegisterEvent(chat, "CHAT_MSG_CHANNEL_ACTIVE")
RegisterEvent(chat, "CHAT_MSG_CHANNEL_EMOTE_ACTIVE")
RegisterEvent(chat, "CHAT_MSG_CHANNEL")
RegisterEvent(chat, "CHAT_MSG_CHANNEL_EMOTE")
RegisterEvent(chat, "CHAT_MSG_NATION")

