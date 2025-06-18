local file_args = {...}

local private = file_args[1]
private.account = {}
local public = file_args[2]
public.account = {}
local config = file_args[3]
config.account = {
	rapid_login = gkrs("alphaui", "rapid_login", "YES")
}

--[[
	This module wraps around the login functionality, so a player can quickly log out and back in to the character select screen without having to re-enter credentials.
	
	if rapid_login is not "YES" then login info will not be stored this session
]]--

local last_username = ""
local last_password = ""
local login_once_flag = false

local save_creds_func = function(user, pass)
	if config.account.rapid_login ~= "YES" then
		return
	end
	
	last_username = user
	last_password = pass
	login_once_flag = true
end

private.account.save_creds = save_creds_func

local security_timer = Timer()
local secure_check_func
secure_check_func = function()
	if private.account.save_creds ~= save_creds_func then
		error("Security flag! Something has overwritten AlphaUI's ability to save user credentials! DO NOT enter your login information into the game, as it may not be secure to do so!")
		return
	end
	security_timer:SetTimeout(1000, secure_check_func)
end
secure_check_func()



public.account.can_quick_login = function()
	return login_once_flag
end

public.account.quick_login = function()
	--[[
		if credentials are stored, gets to the character select screen quickly.
		logs the user out if already logged in.
	]]--
	
	if IsConnected() then
		Logout()
	end
	if not login_once_flag then
		return false
	end
	Login(last_username, last_password)
end



return private, public, config