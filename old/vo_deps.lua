IF_DIR = 'vo/'
IMAGE_DIR = gkini.ReadString("Vendetta", "skin", "images/station/")
tabseltextcolor = "1 241 255"
tabunseltextcolor = "0 185 199"

print = console_print --print() was co-opted to display in the vanilla chat window.  console_print() appears to be replacement.

function HUDSize(x,y) 
	local xres = gkinterface.GetXResolution()
	local yres = gkinterface.GetYResolution()
	return string.format("%sx%s", x and math.floor(x * xres) or "", y and "%"..math.floor(y * 100) or "")
end

function HideDialog(dlg) dlg:hide() end

function ShowDialog(dlg, x, y) if x then dlg:showxy(x, y) else dlg:show() end end

function PopupDialog(dlg, x, y) dlg:popup(x, y) end

dofile(IF_DIR..'if_fontsize.lua')
dofile(IF_DIR..'if_templates.lua')

function OpenAlarm(title, text, buttontext)
	PopupDialog(iup.dialog{
		iup.vbox{
			iup.label{title = title.."\n"..text},
			iup.hbox{
				iup.fill{},
				iup.stationbutton{title = buttontext, action = function(self)
					local d = iup.GetDialog(self)
					HideDialog(d)
					iup.Destroy(d)
				end},
				iup.fill{},
			},
		},
		topmost = "YES",
		menubox = "NO",
		
	}, iup.CENTER, iup.CENTER)
end

function GetFriendlyStatus()
	return 1
end
