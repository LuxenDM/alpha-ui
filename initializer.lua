--[[
	initializer runs when launched by an LME.
	It sets up the class info to register as an interface.
	
	todo: babel and CCD1 stuff. Open -> set as interface
]]--

local cp = function(ins)
	lib.log_error("[alphaui] " .. tostring(ins), 2, "alphaui", "0")
end

local no_helium_safety_diag = iup.dialog {
	topmost = "YES",
	fullscreen = "YES",
	alignment = "ACENTER",
	iup.vbox {
		iup.hbox {
			iup.stationbuttonframe {
				iup.vbox {
					iup.label {
						wordwrap = "YES",
						size = "THIRDx",
						title = "This dialog will only appear if Helium is not enabled. Enable Helium version 0.5.0 -dev, or switch back to the default interface.",
					},
					iup.fill {
						size = "%2",
					},
					iup.hbox {
						iup.stationbutton {
							title = "Open neomgr",
							action = function()
								lib.open_config()
							end,
						},
					},
				},
			},
		},
	},
}

local public = {
	IF = true,
}

lib.set_class("alphaui", "0", public)

local current_if = lib.get_gstate().current_if

lib.set_waiting("alphaui", "0", "YES", "&&")

if current_if == "alphaui" then
	no_helium_safety_diag:open()
	lib.require({{name = "helium", version = "1.0.0"}}, function()
		lib.resolve_file("plugins/alpha-ui/alpha-ui.lua")
		no_helium_safety_diag:hide()
		lib.set_waiting("alphaui", "0", "NO", "&&")
	end)
else
	cp("running as addon")
	lib.require({{name = "helium", version = "1.0.0"}}, function()
		cp("Helium found, executing")
		lib.resolve_file("plugins/alpha-ui/alpha-ui.lua")
		lib.set_waiting("alphaui", "0", "NO", "&&")
	end)
end

cp("AlphaUI Initialized and is waiting for helium")