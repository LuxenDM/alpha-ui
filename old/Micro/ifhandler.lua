function mif_con_print(input)
	--for debugging only
	console_print("MicroIF CON: " .. tostring(input))
	
end

print("Loading MicroIF...")

MicroIF = {
	main = "Micro Interface",
	version = "indev1.0 b001",
	dir = "plugins/Micro/",
	uigen = {},
	funcLock = false,--false prevents certain functions from running.
	curState = "NULL",--current dialog state
}

gkini.WriteString("MultiUI", "doDependencyPatch", "YES") --Micro does not have self-provided ui elements.

RegisterUserCommand("reload", function() ReloadInterface() end)

local function doLoginHandler()
	print("Constructing Login Handler")
	local user = iup.text {
		size = "%20",
	}
	
	local pswd = iup.text {
		size = "%20",
		password = "YES",
		action = function(self, key)
			if key == 13 then
				Login(user.value, self.value)
				iup.Destroy(iup.GetDialog(self))
			end
		end
	}
	
	local quitBtn = iup.stationbutton {
		title = "Exit",
		action = function()
			Game.Quit()
		end,
	}
	
	local loginPanel = iup.dialog {
		topmost = "YES",
		bgcolor = "0 0 0 0 *",
		fullscreen = "YES",
		startfocus = user,
		defaultesc = quitBtn,
		iup.vbox {
			iup.hbox {
				iup.fill { },
				iup.label {
					title = MicroIF.main .. " \12700FF00" .. MicroIF.version,
				},
				iup.fill { },
			},
			iup.fill { },
			iup.hbox {
				iup.vbox {
					iup.stationbutton {
						title = "Website",
						action = function()
							Game.OpenWebBrowser("http://vendetta-online.com/")
						end,
					},
					iup.stationbutton {
						title = "Discord",
						action = function()
							Game.OpenWebBrowser("http://discord.gg/vendetta")
						end,
					},
				},
				iup.fill { },
				iup.stationsubsubframe {
					iup.vbox {
						alignment = "ACENTER",
						iup.label {
							title = "Please Login:",
							font = Font.H4,
						},
						iup.hbox {
							iup.label {
								title = "Username: ",
							},
							user,
						},
						iup.hbox {
							iup.label {
								title = "Password: ",
							},
							pswd,
						},
						iup.hbox {
							iup.stationbutton {
								title = "Login",
								action = function(self)
									print("Attempting login...")
									Login(user.value, pswd.value)
									iup.Destroy(iup.GetDialog(self))
								end,
							},
							quitBtn,
						},
					},
				},
				iup.fill { },
				iup.vbox {
					alignment = "ARIGHT",
					iup.stationbutton {
						title = "Neoloader Manager",
						action = function()
							lib.open_config()
						end,
					},
					iup.stationbutton {
						title = "MultiUI Menu",
						action = function()
							lib.open_if_config()
						end,
					},
					iup.stationbutton {
						title = "Reload Interface",
						action = function()
							ReloadInterface()
						end,
					},
				},
			},
		},
	}
	loginPanel:map()
	loginPanel:show()
	
end

local function doAltSel()
	print("Constructing Alt Selection Interface")
	local altToLogin = 1
	
	local altList = iup.list {
		dropdown = "YES",
		readonly = "YES",
		action = function(self, name, index, clickval)
			if clickval == 1 then
				altToLogin = index
			end
		end,
	}
	
	for i=1, 6 do
		altList[i] = GetCharacterInfo(i)
	end
	
	iup.Refresh(altList)
	
	local logoutBtn = iup.stationbutton {
		title = "Logout",
		action = function(self)
			Logout()
			print("Logout was triggered")
			iup.Destroy(iup.GetDialog(self))
		end,
	}
	
	local loginBtn = iup.stationbutton {
		title = "Select Character",
		action = function(self)
			SelectCharacter(altToLogin)
			MicroIF.lastCharSel = altToLogin
			print("Attempting game entry...")
			iup.Destroy(iup.GetDialog(self))
		end,
	}
	
	local charSelect = iup.dialog {
		topmost = "YES",
		fullscreen = "YES",
		bgcolor = "0 0 0 0 *",
		startfocus = loginBtn,
		defaultesc = logoutBtn,
		iup.vbox {
			iup.hbox {
				iup.fill { },
				iup.label {
					title = MicroIF.main .. " \12700FF00" .. MicroIF.version,
				},
				iup.fill { },
			},
			iup.fill { },
			iup.hbox {
				iup.fill { },
				iup.stationsubsubframe {
					iup.vbox {
						alignment = "ACENTER",
						iup.label {
							title = "Select your alt:",
							font = Font.H4,
						},
						iup.hbox {
							altList,
						},
						iup.hbox {
							loginBtn,
							logoutBtn,
						},
					},
				},
				iup.fill { },
			},
		},
	}
	charSelect:map()
	iup.SetFocus(loginBtn)
	
	charSelect:show()
	
end

local chatData = os.date()
local updateChatList = {}
local function updateAllChatContainers()
	mif_con_print("Chat List Update Triggered")
	for k, v in ipairs(updateChatList) do
		if iup.GetType(v) == "multiline" then
			v.value = tostring(chatData) .. " "
		else
			mif_con_print("Weird! We got a " .. iup.GetType(v))
		end
	end
	mif_con_print("end of update")
end

function MicroIF.uigen.createChatContainer(vertsize)
	mif_con_print("Creating new chat container")
	local doFill = false
	if vertsize == 1 then
		vertsize = 0.1
		doFill = true
	end
	
	local chatReciever = iup.multiline {
		readonly = "YES",
		expand = "HORIZONTAL",
		size = HUDSize(0.5, vertsize or 0.2),
		value = chatData,
	}
	
	if doFill == true then
		chatReciever.expand = "YES"
	end
	
	updateChatList[#updateChatList + 1] = chatReciever
	
	return iup.frame {
		chatReciever,
	}
	
end

print = function(instr)
	chatData = string.sub(chatData, -10000) .. "\n\127FFFFFF" .. (instr or "nil")
	console_print(instr)
	updateAllChatContainers()
end

local function chatEventHandler(event, args)
	local outmsg = ""
	
	local fargs = { --args to formatted args
		msg = args.msg or "",
		loc = args.channelid or args.guildtag or "",
		spk = args.name or "",
		clr = tostring(rgbtohex(FactionColor_RGB[args.faction or 1])) or "\127FFFFFF",
		gld = args.guildtag or "",
	}
	if event == "CHAT_MSG_CHANNEL" then
		fargs.mcr = "\127999999"
	elseif event == "CHAT_MSG_CHANNEL_ACTIVE" then
		fargs.mcr = "\127FFFFFF"
	elseif event == "CHAT_MSG_CHANNEL_EMOTE" then
		fargs.mcr = "\127999999"	
	elseif event == "CHAT_MSG_CHANNEL_EMOTE_ACTIVE" then
		fargs.mcr = "\127FFFFFF"
	elseif event == "CHAT_MSG_SECTOR" then
		fargs.mcr = "\12700FF00"
	elseif event == "CHAT_MSG_GUILD" then
		fargs.mcr = "\127FFAA00"
	elseif event == "CHAT_MSG_GROUP" then
		fargs.mcr = "\127FFFF00"
	elseif event == "CHAT_MSG_SYSTEM" then
		fargs.mcr = "\127FF00FF"
	elseif event == "CHAT_MSG_ERROR" then
		fargs.mcr = "\127FF0000"
	elseif event == "CHAT_MSG_PRINT" then
		fargs.mcr = "\12700AAFF"
	elseif event == "CHAT_MSG_PRIVATE" then
		fargs.mcr = "\127FF0000"
	elseif event == "CHAT_MSG_PRIVATEOUTGOING" then
		fargs.mcr = "\127444444"
	
	else
		fargs.mcr = "\127FFFFFF"
		print("error? Unknown event somehow triggered in MicroIF chat event handler?")
	end
	
	print("\127FFFFFF" .. fargs.loc .. " [" .. fargs.gld .. "] " .. fargs.clr .. fargs.spk .. "\127FFFFFF > " .. fargs.mcr .. fargs.msg)
	
	
end

RegisterEvent(chatEventHandler, "CHAT_MSG_CHANNEL")
RegisterEvent(chatEventHandler, "CHAT_MSG_CHANNEL_ACTIVE")
RegisterEvent(chatEventHandler, "CHAT_MSG_CHANNEL_EMOTE")
RegisterEvent(chatEventHandler, "CHAT_MSG_CHANNEL_EMOTE_ACTIVE")
RegisterEvent(chatEventHandler, "CHAT_MSG_SECTOR")
RegisterEvent(chatEventHandler, "CHAT_MSG_GUILD")
RegisterEvent(chatEventHandler, "CHAT_MSG_GROUP")
RegisterEvent(chatEventHandler, "CHAT_MSG_SYSTEM")
RegisterEvent(chatEventHandler, "CHAT_MSG_ERROR")
RegisterEvent(chatEventHandler, "CHAT_MSG_PRINT")
RegisterEvent(chatEventHandler, "CHAT_MSG_PRIVATE")
RegisterEvent(chatEventHandler, "CHAT_MSG_PRIVATEOUTGOING")

print("Micro pre-init done!")
--stuff
MicroIF.HUD = dofile(MicroIF.dir .. "hud.lua")
MicroIF.PDA = dofile(MicroIF.dir .. "menu.lua")


function MicroIF:OnEvent(event, ...)
	mif_con_print("MicroIF:OnEvent handler: " .. event)
	if (event == "ACTIVATE_CHAT_CHANNEL") then
		--do nothing for now
	elseif (event == "CHAT_CANCELLED" or event == "CHAT_DONE") then
		--do nothing for now
	
	elseif (event == "CHAT_SCROLL_DOWN") then
		--do nothing for now
		
	elseif (event == "CHAT_SCROLL_UP") then
		--do nothing for now

	elseif (event == "LOGIN_FAILED") then
		print("Failed to login")
		doLoginHandler()
		OpenAlarm ("Login error", "Failed to log in!", "OK")

	elseif (event == "PLAYER_LOGGED_OUT") then
		print("Logged out")
		MicroIF.FuncLock = false
		MicroIF.HUD:hide()
		MicroIF.PDA:hide()
		doLoginHandler()
		
	elseif (event == "HUD_SHOW") then
		mif_con_print("HUD was shown")
		MicroIF.FuncLock = true
		MicroIF.curState = "HUD"
		MicroIF.PDA:hide()
		MicroIF.HUD:show()
		iup.SetFocus(MicroIF.HUD)
		Game.SetInputMode(1)
		gkinterface.HideMouse()
		radar.Show3000mNavpoint()
		radar.ShowRadar()
	
	elseif (event == "HUD_HIDE") then
		mif_con_print("HUD was hidden (hud-hide event)")
		MicroIF.curState = "PDA"
		MicroIF.FuncLock = true
		MicroIF.HUD:hide()
		radar.Hide3000mNavpoint()
		radar.HideRadar()
		gkinterface.ShowMouse()
		MicroIF.PDA:show()
		

	elseif (event == "START") then
		--Initial start only
		mif_con_print("Micro user-start")
		MicroIF.FuncLock = false
		Game.EnableInput()
		clearscene()
		loadscene(nil, 5597) --77, 5597
		Game.StopLoginCinematic()
		MicroIF.curState = "LOGIN"
		doLoginHandler()
	
	elseif (event == "UPDATE_CHARACTER_LIST") then
		--Character Select
		doAltSel()
		mif_con_print("charlist updated")
		
	elseif (event == "SHOW_STATION") then
		mif_con_print("show station event occured 1")
		if IsConnected() == true then
			MicroIF.FuncLock = true
			mif_con_print("show station event occured 2")
			MicroIF.HUD:hide()
			mif_con_print("show station event occured 3")
			MicroIF.PDA:show()
			MicroIF.curState = "PDA"
		else
			print("Not connected but show station event occured")
		end
	
	elseif (event == "PLAYER_ENTERED_GAME") then
		MicroIF.FuncLock = false
		LoadChannels()
		
	elseif (event == "NAVROUTE_CHANGED") then
		if IsConnected() == true then
			local nextJumpPoint = NavRoute.GetNextHop()
			if nextJumpPoint ~= nil then
				Game.SetJumpDest(nextJumpPoint)
			else
				Game.SetJumpDest(GetCurrentSectorid())
				print("End of route plotted")
			end
		else
			print("Not connected but Navroute change event triggered")
		end
		
	elseif (event == "SECTOR_CHANGED") then
		print("You have entered " .. LocationStr(GetCurrentSectorid()))
		if IsConnected() == true then
			local nextJumpPoint = NavRoute.GetNextHop()
			if nextJumpPoint ~= nil then
				Game.SetJumpDest(nextJumpPoint)
			else
				Game.SetJumpDest(GetCurrentSectorid())
				print("End of route reached")
			end
		else
			print("Not connected but Navroute change event triggered")
		end
		
	elseif (event == "SECTOR_LOADED") then
		MicroIF.FuncLock = true
		
	elseif (event == "CINEMATIC_START") then
		MicroIF.FuncLock = false
		
	elseif (event == "ENTERING_STATION") then
		MicroIF.FuncLock = false
		
	elseif (event == "LEAVING_STATION") then
		MicroIF.FuncLock = false
		
	elseif (event == "PLAYER_ENTERED_STATION") then
		MicroIF.FuncLock = true
		
	end

end

RegisterEvent(MicroIF, "ACTIVATE_CHAT_CHANNEL")
RegisterEvent(MicroIF, "CHAT_CANCELLED")
RegisterEvent(MicroIF, "CHAT_DONE")
RegisterEvent(MicroIF, "CHAT_SCROLL_DOWN")
RegisterEvent(MicroIF, "CHAT_SCROLL_UP")
RegisterEvent(MicroIF, "LOGIN_FAILED")
RegisterEvent(MicroIF, "PLAYER_LOGGED_OUT")
RegisterEvent(MicroIF, "HUD_SHOW")
RegisterEvent(MicroIF, "HUD_HIDE")
RegisterEvent(MicroIF, "SHOW_STATION")
RegisterEvent(MicroIF, "START")
RegisterEvent(MicroIF, "UPDATE_CHARACTER_LIST")
RegisterEvent(MicroIF, "PLAYER_ENTERED_GAME")
RegisterEvent(MicroIF, "NAVROUTE_CHANGED")
RegisterEvent(MicroIF, "NAVROUTE_ADD")
RegisterEvent(MicroIF, "NAVROUTE_UNDOLAST")
RegisterEvent(MicroIF, "SECTOR_CHANGED")

--control certain functions from "allow to run"
RegisterEvent(MicroIF, "SECTOR_LOADED")--on
RegisterEvent(MicroIF, "CINEMATIC_START")--off
RegisterEvent(MicroIF, "ENTERING_STATION")--off
RegisterEvent(MicroIF, "LEAVING_STATION")--off
RegisterEvent(MicroIF, "PLAYER_ENTERED_STATION")--on



























