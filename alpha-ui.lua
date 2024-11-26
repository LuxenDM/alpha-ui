local ver = lib.get_latest("alphaui")
local al_path = lib.get_path("alphaui", ver)

local cp = function(msg)
	lib.log_error("[alphaui]" .. tostring(msg), 2, "alphaui", ver)
end
local cerr = function(msg)
	lib.log_error("[alphaui] " .. tostring(msg), 3, "alphaui", ver)
	return false, msg
end

cp("Alpha-UI is operationg out of " .. al_path)

local private, public, config

local dump_table
dump_table = function(intable, depth, visited)
	depth = depth or 0
	local tabdepth = function(mod)
		return string.rep("\t", depth + (mod or 0))
	end
	
	visited = visited or {}
	local retstr = ""
	local tabs = tabdepth()
	if visited[intable] then
		return tabs .. tostring(intable) .. " (Circular reference)"
	end
	visited[intable] = true
	retstr = retstr .. "\n" .. tabs .. tostring(intable) .. " {"
	depth = depth + 1 -- Increase depth here

	-- Sorting keys alphabetically
	local sortedKeys = {}
	for k, _ in pairs(intable) do
		table.insert(sortedKeys, k)
	end
	table.sort(sortedKeys, function(a, b) return tostring(a) < tostring(b) end)

	for _, k in ipairs(sortedKeys) do
		local v = intable[k]
		if type(v) == "table" then
			retstr = retstr .. "\n" .. tabdepth() .. tostring(k) .. " >> " .. dump_table(v, depth + 1, visited)
		else
			retstr = retstr .. "\n" .. tabdepth() .. tostring(k) .. " >> " .. tostring(v)
		end
	end
	retstr = retstr .. "\n" .. tabdepth(-1) .. "}"
	return retstr
end

private = {
	ver = lib.get_latest("alphaui"),
	path = lib.get_path("alphaui", "0"),
	cp = cp,
	cerr = cerr,
	dump_table = dump_table,
	bstr = function(id, val)
		return val
	end,
	load_module = function(file_path)
		--find a file, pass the class_table to be operated on, then recieve and update context here
		
		local valid_file_path = lib.find_file(al_path .. "modules/" .. file_path)
		if valid_file_path then
			cp("executing module " .. valid_file_path)
			
			local file_f, err = loadfile(valid_file_path)
			
			if not file_f then
				cerr("failed to load sub-file " .. file_path)
				cerr("Error defined is " .. tostring(err))
			else
				--cp("private is " .. dump_table(private))
				private, public, config = file_f(private, public, config)
				--cp("	now: " .. dump_table(private))
			end
		else
			cerr("failed to find sub-file " .. file_path)
			lib.update_state("alphaui", he_ver, {complete = false})
			--error()
		end
	end,
}

public = {
	add_translation = function() end, --babel empty function
}

config = {
	
}

local update_class, babel, lang_key
local babel_func = function()
	babel = lib.get_class("babel", "0")
	lang_key = babel.register(lib.get_path("alphaui", "0") .. "lang/", {'en', 'es', 'fr', 'pt'})
	
	private.bstr = function(id, val)
		return babel.fetch(lang_key, id, val)
	end
	
	public.add_translation = function(path, lang_code)
		babel.add_new_lang(ref_id, path, lang_code)
	end
	
	update_class()
end

update_class = function()
	local class = {
		IF = true,
		CCD1 = true,
		open = nil, --no primary PDA
		config = nil, --point at Options menu
		smart_config = {
			title = private.bstr(-1, "Alpha UI"),
			action = function(id, val)
				if id == "update_check" then
					Game.OpenWebBrowser("https://www.nexusmods.com/vendettaonline/mods/24")
				end
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
		description = private.bstr(-1, "indev: lightweight minimal-effort user interface for Vendetta Online"),
		commands = {},
		manifest = {},
	}
	
	for k, v in pairs(class) do
		public[k] = v
	end
	
	lib.set_class("alphaui", "0", public)
end

private.load_module("chatbox.lua")






local current_if = lib.get_gstate().current_if
if current_if == "alphaui" then
	private.load_module("core.lua")
else
	private.load_module("addon.lua")
end

update_class()

lib.require({{name = "babel", version = "0"}}, babel_func)