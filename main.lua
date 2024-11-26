if type(lib) == "table" and lib[0] == "LME" then
	if not lib.is_exist('helium', '0.5.0 -dev') then
		lib.register("plugins/alpha-ui/modules/helium/helium.ini")
	end
	
	if not lib.is_exist('alphaui') then
		lib.register("plugins/alpha-ui/alpha-ui.ini")
	end
end