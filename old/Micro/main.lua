if type(lib) == "table" and lib[0] == "LME" then
	if lib.is_ready("MultiUI") then
		lib.execute("MultiUI", "0", "register_interface", {name = "Micro", path = "plugins/Micro/ifhandler.lua"})
	end
end