local hudUpdateFuncs = {}
local hudShown = false

local function doHudUpdate(event)
	if MicroIF.FuncLock == true then
		mif_con_print("HUD update triggered! event: " .. (event or 'non-event trigger') .. " > HUDmode is " .. MicroIF.curState)
		for k, v in ipairs(hudUpdateFuncs) do
			if type(v) == "function" then
				v()
			end
		end
	end
end

local hudTimedUpdateFuncs = {}
local hudTimer = Timer()

local function doTimedUpdate()
	if MicroIF.FuncLock == true then
		for k, v in ipairs(hudTimedUpdateFuncs) do
			if type(v) == "function" then
				v()
			end
		end
	end
	hudTimer:SetTimeout(500, function() doTimedUpdate() end)
end

local function createSelfInfoPanel()
	mif_con_print("Constructing self-info panel for HUD")
	local hullReadout = iup.label {
		title = "hull: XXXXXXXX/XXXXXXXX",
	}
	
	local shieldReadout = iup.label {
		title = "shield: XXXXXXXX/XXXXXXXX",
	}
	
	local shipName = iup.label {
		title = "",
	}
	
	local shipCargoReadout = iup.label {
		title = "Cargo: XXXX/XXXX",
	}
	
	local shipDetailPanel = iup.frame {
		iup.vbox {
			hullReadout,
			shieldReadout,
			shipName,
			shipCargoReadout,
		},
	}
	
	local function updateSelfHealth()
		if MicroIF.curState == "HUD" then
			mif_con_print("Updated self-info")
			local _, _, _, _, _, _, hullCur, hullMax, shieldCur, shieldMax = GetActiveShipHealth()
			hullReadout.title = "hull: \127FFFF55" .. tostring(hullMax) .. "\127FFFFFF/\127FF5555" .. tostring(hullCur)
			if type(shieldCur) == "number" then
				shieldReadout.title = "shield: \1275555FF" .. tostring(shieldMax) .. "\127FFFFFF/\127555555" .. tostring(shieldCur)
			else
				shieldReadout.title = ""
			end
			
			shipName.title = GetActiveShipName()
			
			local shipCargoCapacity = GetActiveShipMaxCargo()
			local shipCargoCurrent = GetActiveShipCargoCount()
			shipCargoReadout.title = "cargo: " .. tostring(shipCargoCapacity) .. "/" .. tostring(shipCargoCurrent) .. "cu"
			
			iup.Refresh(shipDetailPanel)
		end
	end
	hudUpdateFuncs[#hudUpdateFuncs + 1] = updateSelfHealth
	
	return shipDetailPanel
end

local function createTargetInfoPanel()
	mif_con_print("Creating target info panel")
	
	local tarNameReadout = iup.label {
		title = "<target name>",
	}
	
	local tarHullReadout = iup.label {
		title = "hull: XXX%",
	}
	
	local tarDistReadout = iup.label {
		title = "distance: XXXXm",
	}
	
	local targetDetailPanel = iup.frame {
		iup.vbox {
			tarNameReadout,
			tarHullReadout,
			tarDistReadout,
		},
	}
	
	local function updateTargetInfo()
		if MicroIF.curState == "HUD" then
			mif_con_print("updated target data")
			local tarName, tarHullPercent, tarDist, tarFaction, tarGuild, tarShipName = GetTargetInfo()
			tarNameReadout.title = tarName or "no target"
			tarHullReadout.title = "hull: " .. tostring((1 - (tarHullPercent or 1)) * 100) .. "%"
			tarDistReadout.title = "distance: " .. tostring(math.floor(tarDist or 0) or "") .. "m"
			
			iup.Refresh(targetDetailPanel)
		end
	end
	hudUpdateFuncs[#hudUpdateFuncs + 1] = updateTargetInfo
	hudTimedUpdateFuncs[#hudTimedUpdateFuncs + 1] = updateTargetInfo
	
	return targetDetailPanel
	
end

local function createChatPanel()
	mif_con_print("Creating HUD Chat panel")
	
	local chatRec = MicroIF.uigen.createChatContainer(0.15)
	
	local msgPrefix = iup.label {
		title = "",
	}
	local msgType = "CHANNEL"
	local outputDir = "100"
	
	local chatOutput = iup.text {
		expand = "HORIZONTAL",
		value = "",
		visible = "NO",
		action = function(self, key)
			if key == 13 then
				if self.value ~= "" then
					if (string.sub(self.value, 1, 1) == "/") and (string.sub(self.value, 1, 4) ~= "/me ") then
						gkinterface.GKProcessCommand(string.sub(self.value, 2))
						self.value = ""
					else
						SendChat(self.value, msgType, outputDir)
						self.value = ""
					end
				end
				iup.SetFocus(iup.GetDialog(self))
				self.visible = "NO"
				msgPrefix.title = ""
				gkinterface.HideMouse()
				Game.SetInputMode(1)
			end
		end,
	}
	
	local chatFrame = iup.vbox {
		chatRec,
		iup.hbox {
			msgPrefix,
			chatOutput,
		},
	}
	
	local function showHudChat(prefixText, type, channelid)
		chatOutput.visible = "YES",
		gkinterface.ShowMouse()
		msgPrefix.title = prefixText or ""
		msgType = type or "CHANNEL"
		outputDir = channelid or "100"
		iup.Refresh(chatFrame)
		iup.SetFocus(chatOutput)
	end
	
	local function showHudEventHandle(event, ...)
		if MicroIF.curState == "HUD" then
			mif_con_print("show_hud chat event handler triggered with " .. event)
			if hudShown == true then
				if event == "ACTIVATE_CHAT_CHANNEL" then
					showHudChat("channel: ", "CHANNEL", tostring(GetActiveChatChannel()))
				elseif event == "ACTIVATE_CHAT_GROUP" then
					showHudChat("group:", "GROUP", "null")
				elseif event == "ACTIVATE_CHAT_GUILD" then
					showHudChat("guild:", "GUILD", "null")
				elseif event == "ACTIVATE_CHAT_MISSION" then
					print("Hey, you triggered activate_chat_mission somehow! Cool!")
				elseif event == "ACTIVATE_CHAT_PRIVATE" then
					showHudChat("msg:", "PRIVATE", GetLastPrivateSpeaker() or GetPlayerName() or "Luxen")
				elseif event == "ACTIVATE_CHAT_SAY" then
					showHudChat("sector:", "SECTOR", "null")
				elseif event == "ACTIVATE_CHAT_SECTOR" then
					showHudChat("sector:", "SECTOR", "null")
				elseif event == "ACTIVATE_CHAT_USER" then
					print("Hey, you triggered activate_chat_user somehow! Cool!")
				end
			end
		end
	end
	
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_CHANNEL")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_GROUP")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_GUILD")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_MISSION")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_PRIVATE")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_SAY")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_SECTOR")
	RegisterEvent(showHudEventHandle, "ACTIVATE_CHAT_USER")
	
	return chatFrame
	
end

local function createSensorDisplay()
	local playerIndexIDPairs = {}
	local listSize = 0
	
	local function setClickedTarget(index)
		if (playerIndexIDPairs[index] ~= nil) and (playerIndexIDPairs[index] ~= 0) then
			radar.SetRadarSelection(GetPlayerNodeID(playerIndexIDPairs[index]))
		end
	end
	
	local localPlayerList = iup.list {
		expand = "YES",
		bgcolor = "0 0 0 0 *",
		action = function(self, text, index, clickValue)
			if clickValue == 1 then
				setClickedTarget(index)
			end
		end,
	}
	
	local function updatelocalPlayerList()
		--there was an iup matrix here, but had to give up on that. idgaf.
		playerIndexIDPairs = {}
		local internalList = {}
		ForEachPlayer(
			function(id)
				internalList[#internalList + 1] = {
					id = id,
					name = GetPlayerName(id) or "err:" .. tostring(id),
					dist = tostring(math.floor(tonumber(GetPlayerDistance(id) or 0))),
				}
			end
		)
		
		table.sort(internalList, function(k1, k2) return string.upper(k1.name) < string.upper(k2.name) end)
		table.sort(internalList, function(k1, k2) return k1.dist < k2.dist end)
		
		table.insert(internalList, 1, {id = 0, name = "Player", dist = "Distance"})
		
		if listSize > #internalList then
			for i=#internalList, listSize do
				localPlayerList[i] = nil
			end
		end
		
		for k, v in ipairs(internalList) do
			localPlayerList[k] = "(" .. tostring(v.dist) .. ") " .. tostring(v.name)
			playerIndexIDPairs[k] = v.id or 0
		end
		
		listSize = #internalList
		
		iup.Refresh(iup.GetDialog(localPlayerList))
	end
	
	hudTimedUpdateFuncs[#hudTimedUpdateFuncs + 1] = updatelocalPlayerList
	
	return iup.vbox {
		localPlayerList,
	}
	
end

local function createRadarFront()
	mif_con_print("Creating the main radar")
	local radarFrontObj = iup.radar {
		type = "FRONT",
		blipscale = "1",
		image = "plugins/Micro/null_img.png",
		size = HUDSize(1, 1), 
		bgcolor = "255 255 255 255 &", 
		expand = "YES", 
		active = "NO",
	}
	
	return iup.vbox { 
		radarFrontObj,
	}
	
end

local function createCrosshair()

	local crosshair = iup.vbox {
		iup.fill { },
		iup.hbox {
			iup.fill { },
			iup.label {
				title = "",
				image = "skins/platinum/hud_new_crosshair.png",
			},
			iup.fill { },
		},
		iup.fill { },
	}
	
	return crosshair
end

local hudDiag = iup.dialog {
	fullscreen = "YES",
	topmost = "YES",
	bgcolor = "0 0 0 0 *",
	show_cb = function(self)
		mif_con_print("HUD Shown (show_cb)")
		iup.GetFocus(self)
		Game.SetInputMode(1)
		hudShown = true
		doHudUpdate()
	end,
	hide_cb = function(self)
		mif_con_print("HUD Hidden (hide_cb)")
		hudShown = false
		hudShown = false
	end,
	close_cb = function()
		mif_con_print("HUD Hidden (close_cb)")
		hudShown = false
	end,
	iup.zbox {
		iup.vbox {
			iup.hbox {
				createTargetInfoPanel(),
				iup.fill { },
				createChatPanel(),
				iup.fill { },
				createSelfInfoPanel(),
			},
			iup.fill { },
			iup.hbox {
				--middle left
				iup.fill { },
				--middle center
				iup.fill { },
				--middle right
			},
			iup.fill { },
			iup.hbox {
				--low left
				iup.fill { },
				--low mid
				iup.fill { },
				createSensorDisplay(),
			},
			cx = 0,
			cy = 0,
		},
		createRadarFront(),
		createCrosshair(),
		all = "YES",
		alignent = "NW",
	},
}

hudDiag:map()
RegisterEvent(doHudUpdate, "TARGET_CHANGED")
RegisterEvent(doHudUpdate, "TARGET_HEALTH_UPDATE")
RegisterEvent(doHudUpdate, "PLAYER_HIT")
RegisterEvent(doHudUpdate, "PLAYER_GOT_HIT")
RegisterEvent(doHudUpdate, "PLAYER_ENTERED_SECTOR")

doTimedUpdate()

return hudDiag




























































