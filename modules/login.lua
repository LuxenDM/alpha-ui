local file_args = {...}

local private = file_args[1]
local public = file_args[2]
local config = file_args[3]

--these need to be completely revamped.

private.login_handler()
	print("Constructing Login Handler")
	local user = iup.text {
		size = "%20",
	}
	
	local pswd = iup.text {
		size = "%20",
		password = "YES",
		action = function(self, key)
			if key == 13 then
				Login(user.value, self.value)
				iup.Destroy(iup.GetDialog(self))
			end
		end
	}
	
	local quitBtn = iup.stationbutton {
		title = "Exit",
		action = function()
			Game.Quit()
		end,
	}
	
	local loginPanel = iup.dialog {
		topmost = "YES",
		bgcolor = "0 0 0 0 *",
		fullscreen = "YES",
		startfocus = user,
		defaultesc = quitBtn,
		iup.vbox {
			iup.hbox {
				iup.fill { },
				iup.label {
					title = "Alpha-UI \12700FF00" .. lib.get_latest("alphaui"),
				},
				iup.fill { },
			},
			iup.fill { },
			iup.hbox {
				iup.vbox {
					iup.stationbutton {
						title = "Website",
						action = function()
							Game.OpenWebBrowser("http://vendetta-online.com/")
						end,
					},
					iup.stationbutton {
						title = "Discord",
						action = function()
							Game.OpenWebBrowser("http://discord.gg/vendetta")
						end,
					},
				},
				iup.fill { },
				iup.stationsubsubframe {
					iup.vbox {
						alignment = "ACENTER",
						iup.label {
							title = "Please Login:",
							font = Font.H4,
						},
						iup.hbox {
							iup.label {
								title = "Username: ",
							},
							user,
						},
						iup.hbox {
							iup.label {
								title = "Password: ",
							},
							pswd,
						},
						iup.hbox {
							iup.stationbutton {
								title = "Login",
								action = function(self)
									print("Attempting login...")
									Login(user.value, pswd.value)
									iup.Destroy(iup.GetDialog(self))
								end,
							},
							quitBtn,
						},
					},
				},
				iup.fill { },
				iup.vbox {
					alignment = "ARIGHT",
					iup.stationbutton {
						title = "Neoloader Manager",
						action = function()
							lib.open_config()
						end,
					},
					iup.stationbutton {
						title = "Reload Interface",
						action = function()
							ReloadInterface()
						end,
					},
				},
			},
		},
	}
	loginPanel:map()
	loginPanel:show()
	
end

private.char_selection()
	print("Constructing Alt Selection Interface")
	local altToLogin = 1
	
	local altList = iup.list {
		dropdown = "YES",
		readonly = "YES",
		action = function(self, name, index, clickval)
			if clickval == 1 then
				altToLogin = index
			end
		end,
	}
	
	for i=1, 6 do
		altList[i] = GetCharacterInfo(i)
	end
	
	iup.Refresh(altList)
	
	local logoutBtn = iup.stationbutton {
		title = "Logout",
		action = function(self)
			Logout()
			print("Logout was triggered")
			iup.Destroy(iup.GetDialog(self))
		end,
	}
	
	local loginBtn = iup.stationbutton {
		title = "Select Character",
		action = function(self)
			SelectCharacter(altToLogin)
			--MicroIF.lastCharSel = altToLogin
			print("Attempting game entry...")
			iup.Destroy(iup.GetDialog(self))
		end,
	}
	
	local charSelect = iup.dialog {
		topmost = "YES",
		fullscreen = "YES",
		bgcolor = "0 0 0 0 *",
		startfocus = loginBtn,
		defaultesc = logoutBtn,
		iup.vbox {
			iup.hbox {
				iup.fill { },
				iup.label {
					title = "Alpha-UI \12700FF00" .. lib.get_latest("alphaui"),
				},
				iup.fill { },
			},
			iup.fill { },
			iup.hbox {
				iup.fill { },
				iup.stationsubsubframe {
					iup.vbox {
						alignment = "ACENTER",
						iup.label {
							title = "Select your alt:",
							font = Font.H4,
						},
						iup.hbox {
							altList,
						},
						iup.hbox {
							loginBtn,
							logoutBtn,
						},
					},
				},
				iup.fill { },
			},
		},
	}
	charSelect:map()
	iup.SetFocus(loginBtn)
	
	charSelect:show()
	
end

return private, public, config