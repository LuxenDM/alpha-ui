local file_args = {...}

local private = file_args[1]
local public = file_args[2]
local config = file_args[3]


private.create_login_failure = function(status, reason)
	local errors = {
		"overload", --servers are overloaded and need time to auto-rescale
		"Login incorrect", --incorrect username or password
		"Account is being deleted", --account marked for deletion
	}
end

private.create_login_dialog = function()
	local field_user = iup.text {
		size = "%20",
	}
	
	local field_pswd = iup.text {
		size = "%20",
		password = "YES",
		action = function(self, key)
			if key == 13 then
				private.account.save_creds(field_user.value, self.value)
				
				Login(user.value, self.value)
				HideDialog(iup.GetDialog(self))
				--iup.Destroy(iup.GetDialog(self))
			end
		end,
	}
	
	local button_exit = iup.stationbutton {
		title = "Exit",
		action = function()
			Game.Quit()
		end,
	}
	
	local login_screen = iup.dialog {
		bgcolor = "0 0 0 0 *",
		fullscreen = "YES",
		defaultesc = button_exit,
		iup.vbox {
			iup.fill { },
			iup.zbox {
				all = "YES",
				alignment = "SE",
				iup.hbox {
					--login box
					iup.fill { },
					private.helium.primitives.borderframe {
						iup.vbox {
							alignment = "ACENTER",
							iup.label {
								title = "Login: ",
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
										field_pswd:action(13)
									end,
								},
								button_exit,
							},
						},
					},
					iup.fill { },
				},
				
				iup.hbox {
					--window edge boxes
					alignment = "ABOTTOM",
					iup.vbox {
						--left display, list options and neo
						--make into helium uniform button list
						iup.stationbutton {
							title = "Options",
							action = function()
								--open offline options menu
							end,
						},
						iup.stationbutton {
							title = "LME Manager",
							action = function()
								lib.open_config()
							end,
						},
					},
					iup.fill { },
					iup.vbox {
						--right display, list community buttons
						iup.stationbutton {
							--Game website
							title = "",
							image = private.path .. "assets/VO.png",
							size = Font.Default .. "x" .. Font.Default,
							action = function()
								Game.OpenWebBrowser("http://vendetta-online.com/")
							end,
						},
						iup.stationbutton {
							--Game website
							title = "",
							image = private.path .. "assets/GS.png",
							size = Font.Default .. "x" .. Font.Default,
							action = function()
								Game.OpenWebBrowser("http://guildsoftware.com/")
							end,
						},
						iup.stationbutton {
							--Game website
							title = "",
							image = private.path .. "assets/Discord.png",
							size = Font.Default .. "x" .. Font.Default,
							action = function()
								Game.OpenWebBrowser("http://discord.gg/vendetta")
							end,
						},
					},
				},
			},
		},
	}
	
	private.helium.util.map_dialog(login_screen)
	ShowDialog(login_screen)
end

private.create_char_selection = function()
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
					title = "Alpha-UI \12700FF00" .. private.ver,
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