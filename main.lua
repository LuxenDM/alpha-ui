if type(lib) == "table" and lib[0] == "LME" then
	if not lib.is_exist('helium', '1.0.0') then
		lib.register("plugins/alpha-ui/modules/helium/helium.lua")
	end
	
	if not lib.is_exist('alphaui') then
		lib.register("plugins/alpha-ui/alpha-ui.ini")
	end
end