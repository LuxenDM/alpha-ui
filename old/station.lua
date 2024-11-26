updateOnMenuOpen = {}

local function create_subdlg(ctrl) --stolen from DB
	local dlg = iup.dialog{ctrl, border="NO", menubox="NO", resize="NO", size = "FULL", bgcolor="0 0 0 0 *",}
	dlg.visible = "YES"
	return dlg
end

local function create_scrollbox(content) --stolen from DB
	local scrollbox = iup.stationsublist{{}, control = "YES", expand = "YES", border = "NO", bgcolor = "0 0 0 0 *",}
	iup.Append(scrollbox, create_subdlg(content))
	scrollbox[1] = 1
	return scrollbox
end



local function createTabs(ihtable)
	assert(type(ihtable) == "table", "expected table, got " .. type(ihtable))
	
	local tabRowContainer = {}
	local tabPageContainer = {}
	local err, tabPanelRoot = pcall( function(input) 
		input.alignment = "NW"
		return iup.zbox(input)
	end, ihtable)
	
	assert(err == true, "Bad argument for qgen.defaulttabs; improperly formatted table for zbox. " .. tostring(tabPanelRoot))
	
	for key, value in ipairs(ihtable) do --do button rows
		tabPageContainer[key] = value
		if type(value.tabtitle) == "string" then
			tabRowContainer[key] = iup.stationbutton {
				title = value.tabtitle,
			}
		else
			tabRowContainer[key] = iup.stationbutton {
				title = "Tab " .. tostring(key),
			}
		end
	end
	
	local tabRowRoot = iup.hbox {}
	
	for key, value in ipairs(tabRowContainer) do
		value.action = function(self)
			for k, v in pairs(tabRowContainer) do
				v.bgcolor = "255 255 255"
			end
			self.bgcolor = "255 255 255"
			tabPanelRoot.value = tabPageContainer[key]
		end
		iup.Append(tabRowRoot, tabRowContainer[key])
	end
	
	tabPanelRoot.value = tabPageContainer[1]
	
	return iup.stationsubframe {
		iup.hbox {
			iup.vbox {
				tabRowRoot,
				tabPanelRoot,
			},
		},
	}
	
end

local function createMerchBox()
	
	--[[
		two tab x two tab
		L1:
			Ship status and equipment ports
			+Unequip item
			+Repair ship
			+Reload all ports
		L2:
			Ship Cargo
			+Move to station cargo
			+Sell item
		R1:
			Station Cargo
			+Sell item
			+Load to ship cargo
		R2: 
			Station Merchandise
			+Buy and move to [dropdown]
				>Station cargo
				>Ship Cargo
	]]--
	local function createShipStatus()
		--[[
			zbox:all {
				Name
				Credits
				Licenses
				modelview
			}
			Listview of ship ports
			control buttons
		]]--
		local shipView = iup.modelview {
			size = HUDSize(0.3, 0.1),
		}
		
		function shipView:doUpdate()
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
		
		updateOnMenuOpen[#updateOnMenuOpen + 1] = shipView.doUpdate
		
		local usrName = iup.label {
			title = "____Name____",
		}
		
		local usrCash = iup.label {
			title = "0000000000000 Credits",
		}
		
		local usrLisc = iup.label {
			title = "30/30/30/30/30",
		}
		
		local function updateUsrData()
			local details = {GetCharacterInfo(1)} --Micro
			usrName.title = details[1]
			usrCash.title = tostring(details[3]) .. " credits"
			usrLisc.title = tostring(details[8]) .. "/" .. tostring(details[9]) .. "/" .. tostring(details[10]) .. "/" .. tostring(details[11]) .. "/" .. tostring(details[12])
		end
		
		updateOnMenuOpen[#updateOnMenuOpen + 1] = updateUsrData
		
		local repairButton = iup.stationbutton {
			title = "Repair ship",
			action = function()
				RepairShip(GetActiveShipID())
			end,
		}
		
		local refillButton = iup.stationbutton {
			title = "Refill ammo",
			action = function()
				ReplenishAll(GetActiveShipID())
			end,
		}
		
		local portList = iup.list {
			expand = "YES",
			size = HUDSize(0.3, 0.1),
			action = function(self, text, index, clickValue)
				if clickValue == 1 then
					--set ship port to modify
				end
			end,
		}
		
		return iup.vbox {
			iup.zbox {
				all = "YES",
				alignment = "NW",
				shipView,
				iup.vbox {
					usrName,
					usrCash,
					usrLisc,
				},
			},
			repairButton,
			refillButton,
			portList,
		}
		
	end
	
	local function createStationCargo()
		
		local itemselect
		local updateStationCargo
		local itemselindex = 0
		local stationcargocontainer = {}
		local stationcargodisplay = {}
		
		local itemnamedisp = iup.label {
			title = "____ITEM____",
		}
		
		local itemamountdisp = iup.label {
			title = "____QUAN____",
		}
		
		local quantosell = iup.text {
			size = "200",
			value = "1",
			action = function(self)
				self.value = string.gsub(self.value, "%D", '')
			end,
		}
		
		local sellbutton = iup.stationbutton {
			title = "Sell",
			action = function(self)
				SellInventoryItem(itemselect, tonumber(quantosell),
				function(err) updateStationCargo()
					if err ~= nil then
						print("There was an issue buying that item; error code " .. tostring(err))
					else
						print("Sold!")
					end
				end)
			end,
		}
		
		local movebutton = iup.stationbutton {
			title = "Load onto ship",
			action = function(self)
				LoadCargo(
					{{
						itemid = itemselect,
						quantity = tonumber(quantosell),
					}},	
					function(err) updateStationCargo()
						if err ~= nil then
							print("Failed to load item onto ship with error code " .. tostring(err))
						else
							print("Loaded an item")
						end
					end
				)
			end,
		}
		
		local ctrlshipbutton = iup.stationbutton {
			title = "Pilot this ship",
			action = function()
				SelectActiveShip(itemselect)
				updateStationCargo()
			end,
		}
		
		local cargolist = iup.list {
			expand = "YES",
			size = HUDSize(0.1, 0.1),
			action = function(self, text, index, clickValue)
				if clickValue == 1 then
					itemselindex = index
					itemnamedisp.title = stationcargocontainer[index][1]
					itemamountdisp.title = stationcargocontainer[index][2]
					itemselect = stationcargocontainer[index][3]
				end
			end,
		}
		
		
		function updateStationCargo()
			if IsConnected() == true then
				local stationcargo = GetStationCargoList()
				
				for k, v in ipairs(stationcargo) do
					local detail = {GetInventoryItemInfo(v)}
					stationcargocontainer[#stationcargocontainer + 1] = {
						name = detail[2],
						quantity = detail[3],
						itemid = v,
					}
					cargolist[#stationcargocontainer] = detail[2]
				end
			end
		end
		
		updateOnMenuOpen[#updateOnMenuOpen + 1] = updateStationCargo
		
		return iup.vbox {
			cargolist,
			iup.fill { },
			iup.hbox {
				iup.label {
					title = "Quantity: ",
				},
				quantosell,
			},
			iup.hbox {
				ctrlshipbutton,
				movebutton,
				sellbutton,
			},
		}
		
	end
	
	
	local yarr
	
	return iup.vbox {
		tabtitle = "Station",
		iup.hbox {
			createTabs {
				createShipStatus(),
			},
			createTabs {
				createStationCargo(),
			},
		},
	}
	
end

local function createSocialBox()
	
	local buddyList = iup.list {
		expand = "VERTICAL",
		size = HUDSize(0.4, 0.3),
		action = function(self, text, index, clickValue)
			if clickValue == 1 then
				--set buddy last cliccked
			end
		end,
	}
	
	function buddyList:doUpdate()
		local counter = 0
		ForEachBuddy(function(id, status, loc)
			counter = counter + 1
			buddyList[counter] = id .. " (" .. tostring(status) .. ")"
		end)
	end
	
	updateOnMenuOpen[#updateOnMenuOpen + 1] = buddyList.doUpdate
	
	return iup.hbox {
		tabtitle = "Social",
		iup.vbox {
			createChatBox(1),
		},
		iup.vbox {
			iup.label {
				title = "Buddies:",
			},
			buddyList,
		},
	}
	
end

local function createNavBox()
	local useGridView = gkini.ReadInt("Micro", "NavGrid", 0)
	local newRoute = "1"
	
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
		iup.LoadNavmap(navPanel, useGridView + 1, "lua/maps/system" .. tostring(GetSystemID(SafeGetCurrentSectorid())) .. "map.lua", GetSystemID(SafeGetCurrentSectorid()) - 1)
		navPanel.currentid = SafeGetCurrentSectorid()
	end
	
	updateOnMenuOpen[#updateOnMenuOpen + 1] = updateNav
	
	return iup.vbox {
		tabtitle = "Nav Menu",
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



local diag = iup.dialog {
	topmost = "YES",
	fullscreen = "YES",
	bgcolor = "0 0 0 150 *",
	show_cb = function(self)
		print("PDA triggered show_cb")
		for k, v in ipairs(updateOnMenuOpen) do
			v()
		end
	end,
	close_cb = function(self)
		print("PDA triggered close_cb")
	end,
	iup.vbox {
		iup.label {
			title = "Alpha-UI v" .. lib.get_latest("alphaui"),
		},
		iup.fill {
			size = "%1",
		},
		iup.vbox {
			chat.box,
		},
		iup.hbox {
			iup.fill {
				size = "%1",
			},
			createTabs {
				createMerchBox(),
				createNavBox(),
				--createSocialBox(),
			},
			iup.fill {
				size = "%1",
			},
		},
		iup.hbox {
			iup.fill { },
			iup.stationbutton {
				title = "Launch",
				action = function(self)
					RequestLaunch()
				end,
			},
			iup.stationbutton {
				title = lib.get_gstate().current_mgr,
				action = function(self)
					lib.open_config()
				end,
			},
			iup.fill {
				size = "%1",
			},
		},
		iup.fill {
			size = "%4",
		},
	},
}

diag:map()



STATION = diag