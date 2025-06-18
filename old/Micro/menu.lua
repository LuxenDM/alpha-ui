local updateFuncs = {}

local function doAllUpdate()
	mif_con_print("PDA update triggered")
	if MicroIF.FuncLock == true then
		for k, v in ipairs(updateFuncs) do
			if type(v) == "function" then
				v()
			end
		end
	end
end

local PDATimer = Timer()
PDATimedUpdateFuncs = {}

local function doTimedUpdate()
	if MicroIF.FuncLock == true then
		for k, v in ipairs(PDATimedUpdateFuncs) do
			if type(v) == "function" then
				v()
			else
				console_print("had " .. tostring(v) .. " instead of a func in the timed updater?")
			end
		end
	end
	PDATimer:SetTimeout(1000, function() doTimedUpdate() end)
end

local function createChatArea()
	
	mif_con_print("Creating a new PDA chat area")
	
	local textEntry = iup.text {
		expand = "HORIZONTAL",
		value = "",
		font = Font.H5,
		wanttab = "YES",
		action = function(self, key)
			if key == 13 then
				if self.value ~= "" then
					if (string.sub(self.value, 1, 1) == "/") and (string.sub(self.value, 1, 4) ~= "/me ") then
						gkinterface.GKProcessCommand(string.sub(self.value, 2))
						self.value = ""
					else
						SendChat(self.value, "CHANNEL", GetActiveChatChannel())
						self.value = ""
					end
				end
			end
		end,
	}
	
	return iup.vbox {
		margin = "2",
		MicroIF.uigen.createChatContainer(),
		textEntry,
	}
	
end

local function createStationMerchInterface()
	mif_con_print("Creating Station Merchant Interface")
	--[[
	list of local cargo, station cargo, and station buy/sell
	]]--
	local lastListClicked = "none" --local (on-ship), station (cargo bay), merchant (to be bought or sold)
	local itemClicked = 0 --list index should match with input table of same type
	
	
	local listLocalCargo = iup.stationsublist {
		expand = "YES",
		action = function(self, text, index, clickValue)
			if clickValue == 1 then
				lastListClicked = "local"
				itemClicked = index
			end
		end,
	}
	
	local listStationCargo = iup.stationsublist {
		expand = "YES",
		action = function(self, text, index, clickValue)
			if clickValue == 1 then
				lastListClicked = "station"
				itemClicked = index
			end
		end,
	}
	
	local listMerchantCargo = iup.stationsublist {
		expand = "YES",
		action = function(self, text, index, clickValue)
			if clickValue == 1 then
				lastListClicked = "merchant"
				itemClicked = index
			end
		end,
	}
	
	
	
	local localCargoTable = {}
	local stationCargoTable = {}
	local merchantCargoTable = {}
	
	local function updateTables()
		localCargoTable = {}
		stationCargoTable = {}
		merchantCargoTable = {}
		
		if MicroIF.curState == "PDA" then
			for merchID = 1, GetNumStationMerch() do
				local detail = GetStationMerchInfo(merchID)
				merchantCargoTable[merchID] = {name = detail.name, price = detail.price, itemid = detail.itemid}
				listMerchantCargo[merchID] = detail.name .. " (" .. tostring(detail.price) .. ")"
			end
			
			local shipItems = GetShipInventory(GetActiveShipID())
			
			for k, v in ipairs(shipItems.cargo) do
				local detail = {GetInventoryItemInfo(v)}
				localCargoTable[#localCargoTable + 1] = {name = detail[2], quantity = detail[3], itemid = v}
				listLocalCargo[#localCargoTable] = detail[2] .. " x" .. detail[3]
			end
			
			local stationItems = GetStationCargoList()
			
			for k, v in ipairs(stationItems) do
				local detail = {GetInventoryItemInfo(v)}
				stationCargoTable[#stationCargoTable + 1] = {name = detail[2], quantity = detail[3], itemid = v}
				listStationCargo[#stationCargoTable] = detail[2] .. " x" .. detail[3]
			end
		end
		
	end
	updateFuncs[#updateFuncs + 1] = updateTables
	updateTables()
	
	
	
	local playerName = iup.label {
		title = GetPlayerName() or "PLAYERAAAAA",
	}
	
	local playerCash = iup.label {
		title = "0000000000000 Credits",
	}
	
	local playerLisc = iup.label {
		title = "30/30/30/30/30",
	}
	
	local function updatePlayerData()
		local details = {GetCharacterInfo(MicroIF.lastCharSel or 1)}
		playerName.title = details[1]
		playerCash.title = tostring(details[3]) .. " credits"
		playerLisc.title = tostring(details[8]) .. "/" .. tostring(details[9]) .. "/" .. tostring(details[10]) .. "/" .. tostring(details[11]) .. "/" .. tostring(details[12])
	end
	updateFuncs[#updateFuncs + 1] = updatePlayerData
	
	
	
	
	
	local quantityHolder = iup.text {
		size = "150",
		value = "1",
		action = function(self)
			self.value = string.gsub(self.value, "%D", '')
		end,
	}
	
	local buyButton = iup.stationbutton {
		title = "Buy merchandise item",
		action = function()
			if lastListClicked == "merchant" then
				PurchaseMerchandiseItem(merchantCargoTable[itemClicked].itemid, tonumber(quantityHolder.value), function (err) updateTables() 
					if err ~= nil then
						print ("There was an issue buying that item. error code " .. tostring(err))
					else
						print("Purchased " .. merchantCargoTable[itemClicked].name .. " for " .. merchantCargoTable[itemClicked].price)
					end
				end)
			end
		end,
	}
	
	local sellButton = iup.stationbutton {
		title = "Sell item from cargo",
		action = function()
			if lastListClicked ~= "merchant" then
				local sellitem = 0
				if lastListClicked == "local" then
					sellitem = localCargoTable[itemClicked].itemid
				elseif lastListClicked == "station" then
					sellitem = stationCargoTable[itemClicked].itemid
				end
				if sellitem ~= 0 then
					SellInventoryItem(sellitem, tonumber(quantityHolder.value), function (err) updateTables() 
						if err ~= nil then
							print ("There was an issue buying that item. error code " .. tostring(err))
						else
							print("Sold that item for money!")
						end
					end)
				end
			end
		end,
	}
	
	local moveToLocal = iup.stationbutton {
		title = "Move item to ship storage",
		action = function()
			if lastListClicked == "station" then
				LoadCargo({{itemid=stationCargoTable[itemClicked].itemid, quantity=tonumber(quantityHolder.value)}}, function(err) updateTables()
					if err ~= nil then
						print("Failed to load item onto ship with error code " .. tostring(err))
					else
						print("Loaded an item")
					end
				end)
				updateTables()
			end
		end,
	}
	
	local moveToStation = iup.stationbutton {
		title = "Move item to station storage",
		action = function()
			if lastListClicked == "local" then
				UnloadCargo({{itemid=localCargoTable[itemClicked].itemid, quantity=tonumber(quantityHolder.value)}}, function(err)
					if err ~= nil then
						print("Failed to unload item from ship with error code " .. tostring(err))
					else
						print("Unloaded an item")
					end
				end)
				updateTables()
			end
		end,
	}
	
	local controlShip = iup.stationbutton {
		title = "Pilot this ship",
		action = function()
			if lastListClicked == "station" then
				SelectActiveShip(stationCargoTable[itemClicked].itemid)
				doAllUpdate()
			else
				print("Please select a ship in your station's storage.")
			end
		end,
	}
	
	return iup.vbox {
		iup.hbox {
			iup.vbox {
				iup.label {
					title = "Ship cargo:",
				},
				listLocalCargo,
				iup.frame {
					iup.vbox {
						alignment = "ALEFT",
						playerName,
						playerCash,
						playerLisc,
						iup.fill {size = "%2"},
					},
				},
			},
			iup.vbox {
				iup.label {
					title = "Station cargo:",
				},
				listStationCargo,
			},
			iup.vbox {
				iup.label {
					title = "Merchant:",
				},
				listMerchantCargo,
			},
		},
		iup.hbox {
			iup.frame {
				iup.hbox {
					iup.label {
						title = "Q:",
					},
					quantityHolder,
				},
			},
			moveToLocal,
			moveToStation,
			controlShip,
			iup.fill { },
			sellButton,
			buyButton,
		},
	}
	
end

local function createShipModMenu()
	mif_con_print("Creating Ship Mod Menu")
	return iup.vbox {
		title = "indev",
	}
	
end

local function createDockInterface()
	mif_con_print("Creating Dock Interface")
	
	local launchButton = iup.stationbutton {
		title = "Launch from dock",
		action = function()
			RequestLaunch()
		end,
	}
	
	local repairButton = iup.stationbutton {
		title = "Repair ship",
		action = function()
			RepairShip(GetActiveShipID(), 1, function(cbdata) print("repaired! " .. tostring(cbdata)) end)
		end,
	}
	
	local refillButton = iup.stationbutton {
		title = "Refill ammo",
		action = function()
			ReplenishAll(GetActiveShipID())
		end,
	}
	
	local shipView = iup.modelview {
		size = HUDSize(0.3, 0.3),
		expand = "YES",
	}
	
	local function updateShipViewer()
		if GetActiveShipID() ~= nil then
			local shipName, shipModel, shipColor = GetShipMeshInfo(GetActiveShipID())
			--SetViewObject(shipView, shipName, shipModel, shipColor, 1, 0, 1)
			if shipName and shipModel then
				shipView.value = shipModel .. ":" .. shipName
				shipView.fgcolor = "255 255 255"
				iup.Refresh(shipView)
			end
		end
	end
	updateFuncs[#updateFuncs + 1] = updateShipViewer
	updateShipViewer()
	
	
	
	
	local playerName = iup.label {
		title = GetPlayerName() or "PlayerAAAA",
	}
	
	local playerCash = iup.label {
		title = "0000000000000 Credits",
	}
	
	local playerLisc = iup.label {
		title = "30/30/30/30/30",
	}
	
	local function updatePlayerData()
		local details = {GetCharacterInfo(MicroIF.lastCharSel or 1)}
		playerName.title = details[1]
		playerCash.title = tostring(details[3]) .. " credits"
		playerLisc.title = tostring(details[8]) .. "/" .. tostring(details[9]) .. "/" .. tostring(details[10]) .. "/" .. tostring(details[11]) .. "/" .. tostring(details[12])
	end
	updateFuncs[#updateFuncs + 1] = updatePlayerData
	
	return iup.vbox {
		iup.hbox {
			iup.frame {
				iup.vbox {
					alignment = "ALEFT",
					shipView,
					iup.fill {size = "%2"},
					playerName,
					playerCash,
					playerLisc,
				},
			},
			iup.fill { },
			iup.frame {
				iup.vbox {
					alignment = "ARIGHT",
					repairButton,
					refillButton,
					launchButton,
					iup.fill { },
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
				},
			},
		},
	}
	
end

local function createNavigationInterface()
	mif_con_print("Creating nav interface")
	newRoute = "1"
	useGridView = gkini.ReadInt("Micro", "NavGrid", 0)
	
	local sectorDetail = iup.multiline {
		readonly = "YES",
		value = "",
		expand = "VERTICAL",
		size = HUDSize(0.2, 0.2),
	}
	
	local function SafeGetCurrentSectorid()
		--if the player isn't in the game, using GCSid can cause errors to appear. Using this to attempt bug-squashing.
		local retVal = 1
		if IsConnected() == true then
			retVal = GetCurrentSectorid()
		end
		return retVal
	end
	
	local navPanel = iup.navmap {
		expand = "YES",
		clickedsector = NavRoute.GetFinalDestination() or SafeGetCurrentSectorid(),
		clickedsystem = GetSystemID(SafeGetCurrentSectorid()),
		click_cb = function(self, arg1, arg2)
			mif_con_print("Clicked a sector: " .. tostring(arg1))
			if useGridView == 1 then
				newRoute = arg1
			else
				--gridmode is disabled, so sector offset won't apply; this provides proper coords.
				newRoute = (arg1 + 1) + (GetCurrentSystemid() * 256) - 256
			end
		end,
	}
	
	local function setPath()
		navPanel.currentid = SafeGetCurrentSectorid()
		navPanel.clickedid = newRoute - 1 + useGridView
		navPanel:setpath(GetFullPath(SafeGetCurrentSectorid(), NavRoute.GetCurrentRoute()))
	end
	
	local function updateNav()
		--iup.LoadNavmap(navPanel, useGridView + 1, "lua/maps/system" .. tostring(GetCurrentSystemid()) .. "map.lua", GetCurrentSystemid())
		mif_con_print("Updated the nav: " .. tostring(useGridView) .. "> " .. tostring(GetSystemID(SafeGetCurrentSectorid())) .. "> " .. tostring(SafeGetCurrentSectorid()))
		iup.LoadNavmap(navPanel, useGridView + 1, "lua/maps/system" .. tostring(GetSystemID(SafeGetCurrentSectorid())) .. "map.lua", GetSystemID(SafeGetCurrentSectorid()) - 1)
		navPanel.currentid = SafeGetCurrentSectorid()
	end
	
	updateFuncs[#updateFuncs + 1] = updateNav
	
	return iup.vbox {
		iup.hbox {
			navPanel,
			iup.fill { },
			iup.vbox {
				iup.stationbutton {
					title = "Set Destination",
					action = function()
						NavRoute.clear()
						NavRoute.SetFinalDestination(newRoute)
						print("Set " .. LocationStr(newRoute) .. " to your destination")
						setPath()
					end,
				},
				iup.stationbutton {
					title = "Add stop",
					action = function()
						NavRoute.addbyid(newRoute)
						print("Added " .. LocationStr(newRoute) .. " to your route")
						setPath()
					end,
				},
				iup.fill { },
				iup.stationtoggle { --seperate so this can be changed on load
					title = ":Use Grid Mode",
					value = "OFF",
					action = function(self)
						if self.value == "ON" then
							useGridView = 1
							gkini.WriteInt("Micro", "NavGrid", 1)
							updateNav()
							setPath()
						else
							useGridView = 0
							gkini.WriteInt("Micro", "NavGrid", 0)
							updateNav()
							setPath()
						end
					end,
				},
			},
		},
	}
end

local function createSocialInterface()
	local textEntry = iup.text {
		expand = "HORIZONTAL",
		value = "",
		font = Font.H5,
		wanttab = "YES",
		action = function(self, key)
			if key == 13 then
				if self.value ~= "" then
					if (string.sub(self.value, 1, 1) == "/") and (string.sub(self.value, 1, 4) ~= "/me ") then
						gkinterface.GKProcessCommand(string.sub(self.value, 2))
						self.value = ""
					else
						SendChat(self.value, "CHANNEL", GetActiveChatChannel())
						self.value = ""
					end
				end
			end
		end,
	}
	
	return iup.vbox {
		MicroIF.uigen.createChatContainer(1),
		textEntry,
	}
end

local function createSensorTab()
	local playerIndexIDPairs = {}
	local listSize = 0
	
	local function setClickedTarget(index)
		if (playerIndexIDPairs[index] ~= nil) and (playerIndexIDPairs[index] ~= 0) then
			radar.SetRadarSelection(GetPlayerNodeID(playerIndexIDPairs[index]))
		end
	end
	
	local localPlayerList = iup.stationsublist {
		expand = "YES",
		bgcolor = "50 50 50 50 *",
		action = function(self, text, index, clickValue)
			if clickValue == 1 then
				setClickedTarget(index)
			end
		end,
	}
	
	local function updatelocalPlayerList()
		--there was an iup matrix here, but had to give up on that. idgaf.
		playerIndexIDPairs = {}
		local internalList = {
			[1] = {
				id = 0,
				name = "Player",
				dist = "Distance",
			}
		}
		ForEachPlayer(
			function(id)
				internalList[#internalList + 1] = {
					id = id,
					name = GetPlayerName(id) or "err:" .. tostring(id),
					dist = GetPlayerDistance(id) or "out of range",
				}
			end
		)
		
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
	
	PDATimedUpdateFuncs[#PDATimedUpdateFuncs + 1] = updatelocalPlayerList
	
	return iup.vbox {
		iup.label {
			title = "Sensor Log:",
		},
		iup.stationsubframe {
			localPlayerList,
		},
	}
	
end
	

local tempPanels = {
	createDockInterface(),
	createStationMerchInterface(),
	createShipModMenu(),
	createNavigationInterface(),
	createSensorTab(),
	createSocialInterface(),
}

local panelContainer = iup.zbox {
	tempPanels[1],
	tempPanels[2],
	tempPanels[3],
	tempPanels[4],
	tempPanels[5],
	tempPanels[6],
	value = tempPanels[1],
}

local tabContainer = iup.hbox {
	iup.fill { },
	iup.stationbutton {
		title = "Station Dock",
		action = function()
			panelContainer.value = tempPanels[1]
			doAllUpdate()
		end,
	},
	iup.fill { },
	iup.stationbutton {
		title = "Cargo and Merchant",
		action = function()
			panelContainer.value = tempPanels[2]
			doAllUpdate()
		end,
	},
	iup.fill { },
	iup.stationbutton {
		title = "Ship Garage",
		action = function()
			panelContainer.value = tempPanels[3]
			doAllUpdate()
		end,
	},
	iup.fill { },
	iup.stationbutton {
		title = "Navigation",
		action = function()
			panelContainer.value = tempPanels[4]
			doAllUpdate()
		end,
	},
	iup.fill { },
	iup.stationbutton {
		title = "Sensors",
		action = function()
			panelContainer.value = tempPanels[5]
			doAllUpdate()
		end,
	},
	iup.fill { },
	iup.stationbutton {
		title = "Social",
		action = function()
			panelContainer.value = tempPanels[6]
			doAllUpdate()
		end,
	},
	iup.fill { },
}

do
	local closeBtn = iup.stationbutton {
		title = "close",
		action = function(self)
			iup.GetDialog(self):hide()
			if MicroIF.curState == "HUD" then
				ProcessEvent("HUD_SHOW")
			elseif MicroIF.curState == "PDA" then
				MicroIF.PDA:show()
			else
				iup.GetDialog(self):show()
				print("Error: No unknown window state! Currently " .. tostring(MicroIF.curState or "nil"))
			end
		end,
	}
	
	local flightPDA = iup.dialog {
		topmost = "YES",
		fullscreen = "YES",
		bgcolor = "0 0 0 150 *",
		size = HUDSize(1, 1),
		shrink = "YES",
		show_cb = function()
			mif_con_print("Show flight pda")
			doAllUpdate(2)
		end,
		close_cb = function()
			mif_con_print("flight pda hidden")
		end,
		defaultesc = closeBtn,
		iup.vbox {
			createChatArea(),
			iup.hbox {
				iup.vbox {
					createSensorTab(),
				},
				iup.fill { },
				iup.vbox {
					createNavigationInterface(),
				},
			},
			iup.hbox {
				iup.fill { },
				closeBtn,
			},
		},
	}
	flightPDA:map()
	
	MicroIF.flightPDA = flightPDA
	
	RegisterUserCommand("flymenu", function() flightPDA:show() end)
	
end

PDADialog = iup.dialog {
	topmost = "YES",
	fullscreen = "YES",
	bgcolor = "0 0 0 150 *",
	size = HUDSize(1, 1),
	shrink = "YES",
	show_cb = function(self)
		mif_con_print("Menu Shown")
		doAllUpdate()
	end,
	close_cb = function(self)
		mif_con_print("Menu Hidden")
	end,
	iup.vbox {
		margin = "2",
		iup.label {
			title = " ",
			font = "10",
		},
		createChatArea(),
		tabContainer,
		panelContainer,
		iup.fill { },
		iup.hbox {
			iup.frame {
				iup.label {
					title = MicroIF.main .. " (" .. MicroIF.version .. ") ",
					fgcolor = "255 0 0",
				},
			},
			iup.fill { },
			iup.stationbutton {
				title = "Reload",
				action = function()
					ReloadInterface()
				end,
			},
			iup.stationbutton {
				title = "Log out",
				action = function()
					Logout()
				end,
			},
			iup.stationbutton {
				title = "MultiIF",
				action = function()
					lib.open_if_config()
				end,
			},
			iup.stationbutton {
				title = "Neo",
				action = function()
					lib.open_config()
				end,
			},
		},
		iup.label {
			title = " ",
			font = "10",
		},
	},
}
PDADialog:map()

doTimedUpdate()

return PDADialog
























