HUD = HUD or {}

local function BuildHUD()
	local dlg
	local layers, icon_layer
	local crosshair = iup.label{title="", image=IMAGE_DIR.."hud_new_crosshairs.png", size="50x50", bgcolor="255 255 255 255 &"}
	
	icon_layer = iup.vbox{
		iup.fill{},
		iup.hbox{
			iup.fill{},
			crosshair,
			iup.fill{},
		},
		iup.fill{},
	}

	
	
	layers = iup.zbox{
		icon_layer,
		chat.box,
		all = "YES",
		alignment = "NW",
	}
	

	dlg = iup.dialog{
		layers,
		fullscreen = "YES",
		bgcolor = "0 0 0 0 *",
	}
	iup.Map(dlg)
	
	function dlg:getfocus_cb()
		gkinterface.HideMouse()
		Game.SetInputMode(1)
	end
	
	HUD.dlg = dlg
	
end

BuildHUD()
