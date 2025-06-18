--stub

local diag = iup.dialog {
	topmost = "YES",
	fullscreen = "YES",
	bgcolor = "0 0 0 150 *",
	show_cb = function(self)
		print("Options Dialog was shown")
	end,
	close_cb = function(self)
		print("Options Dialog was closed")
	end,
	iup.vbox {
		iup.fill {
			size = "%8",
		},
		iup.hbox {
			iup.fill { },
			iup.stationsubframe {
				iup.vbox {
					alignment = "ACENTER",
					iup.label {
						title = "Options",
					},
					iup.fill {
						size = "%4"
					},
					iup.hbox {
						iup.fill { 
							size = "%2",
						},
						iup.stationbutton {
							title = "Reload Interface",
							action = function(self)
								ReloadInterface()
							end,
						},
						iup.fill { 
							size = "%2",
						},
					},
					iup.stationbutton {
						title = "Log off",
						action = function(self)
							
						end,
					},
					iup.stationbutton {
						title = "MultiUI",
						action = function(self)
							CreateIFSelector()
						end
					},
					iup.fill {
						size = "%8"
					},
					iup.stationbutton {
						title = "Close",
						action = function(self)
							iup.GetDialog(self):hide()
						end,
					},
				},
			},
			iup.fill { },
		},
		iup.fill {
			size = "%2",
		},
	},
}
diag:map()

return diag