
local he_ver = "0.5.0 -dev"
local he_path = lib.get_path("helium", he_ver)

local cp = function(msg)
	lib.log_error("[helium]" .. tostring(msg), 2, "helium", he_ver)
end
local cerr = function(msg)
	lib.log_error("[helium] " .. tostring(msg), 3, "helium", he_ver)
	return false, msg
end

cp("Helium " .. he_ver .. " is operating out of " .. he_path)

local gkrs = gkini.ReadString





local config = {
	async_process_time = gkrs("helium", "async_process_time", 10),
}

local config_types = {
	--value types for config vars. config (unformatted) -> configfm (formatted)
	async_process_time = {
		type = "number",
		min = 0,
		max = 1000,
	},
	
}

local configfm = {
	--formatted config values
	async_process_time = -1
}

local cfg_update = function()
	--should be called after config is edited or after initial loading
	for k, v in pairs(config) do
		local convstyle = config_types[k] or {}
		if convstyle.type == "number" then
			local outval = tonumber(v)
			if convstyle.max and convstyle.max < outval then
				outval = convstyle.max
			elseif convstyle.min and convstyle.min > outval then
				outval = convstyle.min
			end
			
			configfm[k] = outval
		elseif convstyle.type == "string" then
			local outval = tostring(v)
			
			configfm[k] = outval
		else
			
		end
	end
end

cfg_update()





local public = {
	--helium's public class
	ver = he_ver,
	path = he_path,
	--util,
	--async,
	--primitive,
	--construct,
	--preset,
}

local private --self referencial
private = {
	--internal functions to pass to submodules
	he_ver = he_ver,
	he_path = he_path,
	cp = cp,
	cerr = cerr,
	tryfile = function(file)
		local imgfile = (IMAGE_DIR or "skins/platinum/") .. file
		return gksys.IsExist(imgfile) and imgfile or (he_path .. "img/" .. file)
	end,
	load_module = function(file_path)
		--find a file, pass the class_table to be operated on, then recieve and update context here
		
		local valid_file_path = lib.find_file(he_path .. "modules/" .. file_path)
		if valid_file_path then
			cp("executing module " .. valid_file_path)
			
			local file_f, err = loadfile(valid_file_path)
			
			if not file_f then
				cerr("failed to load sub-file " .. file_path)
				cerr("Error defined is " .. tostring(err))
			else
				public = file_f(public, private)
			end
		else
			cerr("failed to find sub-file " .. file_path)
			lib.update_state("helium", he_ver, {complete = false})
			--error()
		end
	end,
}



private.load_module("utilfunc.lua")
private.load_module("async.lua")

private.load_module("primitives.lua")
private.load_module("construct_misc.lua") --before other constructs
private.load_module("construct_frames.lua")
private.load_module("dragdrop.lua") --before color_picker
private.load_module("gui_presets.lua") --before color_picker
private.load_module("color_picker.lua")



lib.set_class("helium", he_ver, public)