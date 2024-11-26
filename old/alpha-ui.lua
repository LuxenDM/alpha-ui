CustomInterface = {}

CUSTOMIF_DIR = "plugins/alpha-ui/"

dofile(CUSTOMIF_DIR.."vo_deps.lua")

dofile(CUSTOMIF_DIR.."chat.lua")
dofile(CUSTOMIF_DIR.."station.lua")
dofile(CUSTOMIF_DIR.."hud.lua")
CustomInterface.LoginDialog = dofile(CUSTOMIF_DIR.."login.lua")

function CustomInterface:OnEvent(event, ...)
	if (event == "ACTIVATE_CHAT_CHANNEL") then
		iup.SetFocus(chat.entry)

	elseif (event == "CHAT_CANCELLED" or event == "CHAT_DONE") then
		HUD.dlg:getfocus_cb()
	
	elseif (event == "CHAT_SCROLL_DOWN") then
		chat.text.scroll = "PAGEDOWN"
		
	elseif (event == "CHAT_SCROLL_UP") then
		chat.text.scroll = "PAGEUP"

	elseif (event == "LOGIN_FAILED") then
		-- returns failure message
		self.LoginDialog.login()

	elseif (event == "PLAYER_LOGGED_OUT") then
		HUD.dlg:hide()
		self.LoginDialog.login()
		
	elseif (event == "HUD_SHOW") then
		-- returns a message indicating what HUD to show
		HUD.dlg:show()
		
	elseif (event == "SHOW_STATION") then
		-- returns a message indicating what HUD to show
		STATION:show()

	elseif (event == "START") then
		--Initial start only
		clearscene()
		loadscene(nil, 5597) --77, 5597
		Game.StopLoginCinematic()
		
		Game.EnableInput()
		self.LoginDialog.login()
	
	elseif (event == "UPDATE_CHARACTER_LIST") then
		--Character Select
		self.LoginDialog.charselect()

	end

end

RegisterEvent(CustomInterface, "ACTIVATE_CHAT_CHANNEL")
RegisterEvent(CustomInterface, "CHAT_CANCELLED")
RegisterEvent(CustomInterface, "CHAT_DONE")
RegisterEvent(CustomInterface, "CHAT_SCROLL_DOWN")
RegisterEvent(CustomInterface, "CHAT_SCROLL_UP")
RegisterEvent(CustomInterface, "HUD_SHOW")
RegisterEvent(CustomInterface, "LOGIN_FAILED")
RegisterEvent(CustomInterface, "PLAYER_LOGGED_OUT")
RegisterEvent(CustomInterface, "SHOW_STATION")
RegisterEvent(CustomInterface, "START")
RegisterEvent(CustomInterface, "UPDATE_CHARACTER_LIST")
