--[[
	initializer runs when launched by an LME.
	It sets up the class info to register as an interface.
	
	Only if alpha-ui is the current interface does it then open alphaui.lua
	that is where the interface itself is created.
]]--

local public = {
	IF = true,
}

lib.set_class("alphaui", "0", public)

local lme_global_state = lib.get_gstate()

local current_if = lme_global_state.current_if

if current_if == "alphaui" then
	lib.resolve_file("plugins/alpha-ui/alpha-ui.lua")
end

