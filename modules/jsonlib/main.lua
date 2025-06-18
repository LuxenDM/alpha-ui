if isdeclared("lib") and type(lib) == "table" and lib[0] == "LME" then
	if not lib.is_exist("json", "1.0.0 -rxi") then
		lib.register("plugins/jsonlib/rxi_reg.ini")
	end
	
	if gksys.IsExist("plugins/jsonlib/akn_reg.ini") and not lib.is_exist("json", "0.0.0 -a1k0n") then
		lib.register("plugins/jsonlib/akn_reg.ini")
	end
end