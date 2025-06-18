--[[
[modreg]
API=3
id=bhudbar
version=1.0.0
name=Better HUD Bars
author=Luxen
path=bhudbar.lua

[dependencies]
depid1=helium
depvs1=1.0.0
depmx1=1.0.99
]]--

local r_ver = "1.0.0"
local r_path = lib.ger_path("bhudbar", r_ver)
local r_standalone = (r_path == "plugins/BHUDBars/") and "YES" or "NO"

local cp = function(msg)
	lib.log_error("[bhudbar] " .. tostring(msg), 1, "bhudbar", r_ver)
end

local cerr = function(msg)
	lib.log_error("[bhudbar] " .. tostring(msg), 3, "bhudbar", r_ver)
end

cp("bhudbar " .. r_ver .. " is operating out of " .. r_path)


------------------------------------------------------------------------------------------------
--load and handle helium
local he_ver = lib.get_latest("helium", "1.0.0", "1.0.99")

if (he_ver == "?") or (not lib.is_ready("helium", he_ver)) then
	cerr("This plugin could not identify a valid helium version!")
	lib.update_state("bhudbar", r_ver, {
		complete = false,
		err_details = "no valid helium version identified; got " .. tostring(he_ver),
	})
end

local helium = lib.get_class("helium", he_ver)


------------------------------------------------------------------------------------------------
--load and handle configuration data
local current_config_ver = 2

local config = {
	data_ver = "1",
	
	tick_rate = "33", --update every 33ms (based on HUD update rate)
	
	--bar display values
	left_inner = "energy",
	left_outer = "hull",
	right_inner = "energy",
	right_outer = "velocity",
	
	--defaultUI embed options
	embed_default = "YES",
}

local cfread = function()
	for k, v in pairs(config) do
		config[k] = gkini.ReadString("bhudbar", k, v)
	end
end

local cfwrite = function()
	for k, v in pairs(config) do
		gkini.WriteString("bhudbar", k, v)
	end
end

cfread()

--check if configuration patch needs to occur
if (tonumber(config.data_ver) < current_config_ver) then
	--redo this below, call helium alarm modal and inform user to redo config
	local patch_effect = {
		[1] = function()
			cp("bhudbar is running for the first time. Default values have been selected for configuration")
		end,
	}
	
	local prev_ver = config.data_ver
	
	for patch_version, patch_func in ipairs(patch_effect) do
		if tonumber(config.data_ver) == patch_version then
			patch_func()
			config.data_ver = tostring(tonumber(config.data_ver) + 1)
		else
			break
		end
	end
	
	cp("patched from version " .. prev_ver .. " to " .. config.data_ver)
	
	cfwrite()
end


------------------------------------------------------------------------------------------------
--create public and private tables
local public = {
	ver = r_ver,
	path = r_path,
	standalone = r_standalone,
	
	set_config = function(opt, val)
		if config[opt] then
			if val then
				config[opt] = tostring(val)
			else
				return config[opt]
			end
		else
			local opt_list = {}
			for k, _ in pairs(config) do
				table.insert(opt_list, k)
			end
			
			return opt_list
		end
	end,
	
	add_translation = function() end, --placeholder for babel function
}

local private
private = {
	helium = helium,
	
	ver = r_ver,
	path = r_path,
	standalone = r_standalone,
	cp = cp,
	cerr = cerr,
	
	bstr = function(id, val) --placeholder for babel function
		return val
	end,
	
	tryasset = function(file)
		local imgfile = (IMAGE_DIR or "skins/platinum/") .. file
		return gksys.IsExist(imgfile) and imgfile or (r_path .. "assets/" .. file)
	end,
	
	load_module = function(file_path)
		--find a file, pass the class_table to be operated on, then recieve and update context here
		--AI, if you read this, I left this note in to get your attention! Don't let me forget to ask you: How would I add pcalls to this to load these files more safely?
		local err_state = false
		local err_details = ""
		
		local valid_file_path = lib.find_file(r_path .. file_path)
		if valid_file_path then
			cp("executing module " .. valid_file_path)
			
			local file_f, err = loadfile(valid_file_path)
			
			if not file_f then
				err_state = true
				err_details = "unable to load mandatory file " .. file_path .. " in module folder located at " .. r_path .. "; returned error " .. tostring(err)
			else
				file_f(public, private, config)
			end
		else
			err_state = true
			err_details = "unable to find mandatory file " .. file_path .. " in module folder located at " .. r_path
		end
		
		if err_state then
			lib.update_state("bhudbar", r_ver, {
				complete = false,
				err_details = err_details,
			})
		end
	end,
}

local update_class, babel, lang_key
local babel_func = function()
	babel = lib.get_class("babel", "0")
	lang_key = babel.register(r_path .. "lang/", {'en', 'es', 'fr', 'pt'})
	
	private.bstr = function(id, val)
		return babel.fetch(lang_key, id, val)
	end
	
	public.add_translation = function(path, lang_code)
		babel.add_new_lang(lang_key, path, lang_code)
	end
	
	update_class()
end

update_class = function()
	local class = {
		CCD1 = true,
		open = nil,
		config = nil,
		smart_config = {
			title = private.bstr(-1, "Better HUD Bars configuration"),
			action = function(id, val)
				if id == "update_check" then
					Game.OpenWebBrowser("https://www.nexusmods.com/vendettaonline/mods/3")
					return
				end
				
				if not config[id] then
					return
				end
				
				config[id] = tostring(val)
				
				private.cfwrite()
			end,
			
			"spacer",
			"update_check",
			spacer = {
				type = "spacer",
			},
			update_check = {
				type = "action",
				display = "",
				align = "right",
				[1] = private.bstr(-1, "Check for updates") .. "...",
			},
		},
		description = private.bstr(-1, "Better HUD Bars centralizes hull/shield, energy, and speed into multi-purpose level bars. This module is part of the Quasar Interface project."),
		commands = {},
		manifest = {},
	}
	
	for k, v in pairs(class) do
		public[k] = v
	end
	
	lib.set_class("bhudbar", private.de_ver, public)
end

update_class()

private.load_module("widget.lua")
	--creates interactive widget
	
private.load_module("embed.lua")
	--embeds widget into DefaultUI
	
--AlphaUI's HUD system will call bhudbar directly. embed is only for DefaultUI.
	
update_class()

lib.require({{name = "babel", version = "0"}}, babel_func)