Alpha-UI is a LME-based replacement interface and support modules. The goals of Alpha-UI are
• To create a minimal yet effective interface for day-to-day gameplay
• To provide an experimenting slate for the eventual creation of Quasar
• To demonstrate the effectiveness of the LME system


Requirements:
=========================================================================
The following plugins are required for AlphaUI to run
• Neoloader, or another LME provider
	Provides the management engine and core API for advanced plugin intercommunication and support
	- (API 3.11.x or greater, but less than 4)
• Helium
	Provides core interface generation tools
	- (v1.0.0 or greater)
	- (provided with package)
• ReWidgets
	Provides safe integration of interface elements
	- (v1.0.0 or greater)
	- (provided with package)
• Better HUD Bars
	Provides configurable HUD elements for tracking hull, shield, and energy
	- (v1.0.0 or greater)
	- (provided with package)
• (Others as created)

The following plugins are optional
• Babel
	pre-defined translation support (EN, ES, FR, PT machine translations provided by default)
	- (v1.2.0 or greater)
	- (provided with package)
• EasyDoc
	formatted text viewer for tag-searchable help manuals
	- (v1.0.0)
	- (provided with package)
• Advanced Chainfire Automation Module
	easy chainfire weapon management
	- (v1.1.0 (or current))
	- (not provided but optionally integrated)
• (Others as integrated)


Installation:
=========================================================================
Extract AlphaUI to the plugins directory. Enable AlphaUI in the LME manager and apply to get the module to load. Then, either 
• select AlphaUI from the interface selection in the LME manager's settings and apply changes, or
• use the smart-config menu and select the 'load as interface' button.

Your game will then reload with AlphaUI as the primary interface.


Using with DefaultUI:
=========================================================================
If AlphaUI is not selected as the current interface, you can still access the chat module and a few other interfaces as a standalone display.


(This roadmap was created in 2024 and may not match current goals, designs, or progress)
Roadmap:
=========================================================================
[ ]: indev [in progress]
	Concepting the interface and loading structure
	Concepting and creation of support libraries
	[ ] Chat
		required early; if the interface outright fails, it goes into an emergency mode where the user can access a text interface to execute commands as well as chat. This will also be provided as an independent "Console" interface.
	[ ] Core backend
		[ ] login, logout, char-select
			skip re-log to switch characters (must be enabled)
		[ ] sensors
			can keep last (configurable) number of target scans
			async system, gets charlist very often, list iterated seperately
	[ ] Babel v1.2.x
		Babel powers the translation capability of AlphaUI. v1.2.x is a rewrite for how the library operates; the API will not change, but the plugin should be much more resilient and be consistantly coded.
	[ ] Helium v1.0.0
		Helium powers the interface construction of AlphaUI; in tandem, AlphaUI showcases some of the capabilities that Helium provides.
	
[ ]: dev
	Creation of main interfaces
	[ ] Login and Character select
	[ ] PDA Primary
		[ ] Player status/home
		[ ] Navigation
		[ ] Local inventory
		[ ] Station Garage and Shop
			[ ] Ship selection
			[ ] Ship management
			[ ] Shop buy/sell (to station cargo)
		[ ] Station Mission Board
		[ ] Comms
			[ ] Sensor log
			[ ] Buddy list
			[ ] Group panel
			[ ] Guild panel
	[ ] HUD Primary
		[ ] Radar1/[addons and cargo, or chat, or mission info]/Radar2; screen bottom
		[ ] Current target info; top center
		[ ] sensor log; top right
		[ ] BHUDBar module - quad-bar display for hull/energy/velocity/etc
	[ ] Options
		[ ] Primary menu
			[ ] LME access
			[ ] Credits
			[ ] Log out
			[ ] switch characters
		[ ] Basic
		[ ] Controls
		[ ] Graphics
		[ ] Audio
		[ ] Interface
		[ ] Development
	
[ ]: alpha
	Reformatting and refining for uniformity across PC and large-format Mobile, bug fixing
	private releases
	
[ ]: beta
	Refining and streamlining interface, adding function input safety catches
	public releases
	
[ ]: Release
	Public v1.0.0 release
