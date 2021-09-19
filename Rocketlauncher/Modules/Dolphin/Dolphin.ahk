MEmu := "Dolphin"
MEmuV := "v5.0"
MURL := ["https://dolphin-emu.org/"]
MAuthor := ["djvj","bleasby"]
MVersion := "2.2.0"
MCRC := "C7DEEF2C"
iCRC := "9DF8C36F"
MID := "635038268884477733"
MSystem := ["Nintendo Gamecube","Nintendo Wii","Nintendo WiiWare"]
;----------------------------------------------------------------------------
; Notes:
; Be sure you are running at least Dolphin v4.0 or greater.
; If you get an error that you are missing a vcomp100.dll, install Visual C++ 2010: http://www.microsoft.com/download/en/details.aspx?id=14632
; Also make sure you are running latest directx: http://www.microsoft.com/downloads/details.aspx?FamilyID=2da43d38-db71-4c1b-bc6a-9b6652cd92a3
; Dolphin will sometimes crash when connnecting a Wiimote, then going back to the game. After all Wiimotes are connected that you want to use, it shouldn't have anymore issues.
; Convert all your games to ciso using Wii Backup Manager to save alot of space by stripping everything but the game partition. http://www.wiibackupmanager.tk/
; If you want to keep your Dolphin.ini in the emu folder, create a "portable.txt" file in MyDocuments\Dolphin Emulator\
;
; Bezels:
; If the game does not fit the window, you can try setting stretch to window manually in dolphin.
;
; Setting up custom Wiimote or GCPad profiles:
; First set UseCustomWiimoteProfiles or UseCustomGCpadProfiles to true in RocketLauncherUI for this module
; Launch Dolphin manually and goto Options->(Wiimote or Gamecube Pad) Settings and configure all your controls how you want your default setup to look like. This will be used for all games that you don't set a custom profile for. No need to save any profiles.
; All your controls are stored in WiimoteNew.ini or GCPadNew.ini and get copied to a _Default_(WiimoteNew or GCPadNew).ini on first launch. This ini contains all the controls for all 4 controllers.
; Do not confuse this with Dolphin's built-in profiles as those only contain info for only one controller. The (WiimoteNew or GCPadNew).ini and all the profiles RocketLauncher uses contain info for all controllers in one file.
; This new profile now called _Default_(WiimoteNew or GCPadNew).ini will be found in Dolphins settings folder: \Config\Profiles\(Wiimote or GCPad) (RL)\Default.ini
; For each game or custom control sets you want to use, edit the controls for all the controllers to work for that game and exit Dolphin. Now copy the (WiimoteNew or GCPadNew).ini to the "(Wiimote or GCPad) (RL)" folder and name it whatever you like.
; In RocketLauncherUI's module settings for Dolphin, Click the Rom Settings tab and add each game from your xml you want to use a this custom profile for.
; Now for all those games you added, make sure the Profile setting it set to the custom profile you want to load when that game is launched.
; Any game not added will use the "_Default_(WiimoteNew or GCPadNew).ini" profile RocketLauncher makes on first launch.
;
; To Pair a Wiimote:
; Highly suggest getting a Mayflash DolphinBar as it makes pairing and using wiimotes as easy as with a real Wii: http://www.amazon.com/TOTALCONSOLE-W010-Wireless-Sensor-DolphinBar/dp/B00HZWEB74
; If using the DolphinBar, just make sure Dolphin is set to continuously scan for wiimotes and set controls to use real wiimotes for as many wiimotes you have.
; You do not need to pair the wiimote with the PC first as you would with a standard blueooth and wiimote.
; DolphinBar should be on Mode 4. Wiimotes don't get paired until after Dolphin is running, not before!!
; After Dolphin is running, press 1+2 on each wiimote and after a few moments, the wiimote will pair and vibrate and one led will lock solid. Do this for each wiimote. That's it!
;
; If using a standard LED Bar:
; Make sure all your wiimotes have already been paired with your PC's bluetooth adapter
; All 4 leds on the wiimote should be flashing
; Press your Refresh key (set in RocketLauncherUI for this module) or enable continuous scanning in Dolphin
; Press 1 + 2 on the wiimote and one led should go solid designating the player number
;
; MultiGame:
; Currently unable to get disc swapping to work. See MultiGame section below for additional details.
;
; Netplay:
; If you're using a GameCube game with saves, synchronize your memory cards, Wii NAND needs to be synchronized, and some settings (such as CPU Clock Override) must be either synchronized or disabled.
; Because netplay may require different settings than you would normally use with local play, the module will look for any inis in your Dolphin user config folder ending with "_netplay" and use those configs instead of your normal ones.
; So for example, after you tweak all your dolphin settings for netplay, copy your dolphin.ini to dolphin_netplay.ini in the same folder.
; When the module launches and you choose multiplayer from RocketLauncher on screen menu, the module will backup dolphin.ini and copy dolphin_network.ini to dolphin.IniDelete
; On exit, the module will restore your backed up dolphin.ini and any other ini files in this folder (and all subfolders) that had the "_netplay" in the name.
; Guide on tweaking performance for netplay: https://dolphin-emu.org/docs/guides/netplay-guide/
; Another guide: https://docs.google.com/document/d/1CIkBAGcf_-kBUa4urn4KUj2U4UA6y_2a7stXJz85yiE/
;
; Linking a GameCube game with VBA-M
; Game tested: Legend of Zelda, The - Four Swords Adventures (USA)
; VBA-M emulator tested: visualboyadvance-m2.0.0Beta1
; dolphin emulator tested: dolphin-master-4.0-6725-x64
; On RocketLaunchUI, dolphin, GameCube Module settings set your VBA-M executable and VBA Bios file path on the VBALink tab.
; On RocketLaunchUI, dolphin, GameCube, Game name Module Settings enable VBA Link
; If your Game Boy Advanced Windows appear frozen after the RocketLauncher fade screen loads, increase the value of the VBADelay on GameCube, VBALink settings. Default value is 500 milliseconds.
; A game with one VBA window will use a two screens bezel file, Bezel [2S].png, the first screen for the GameCube game and the second one for the VBA screen. Two VBAs = Bezel [3S].png, again first screen for the GameCube game and second and third for the VBA screens, and so on.
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
UseCustomWiimoteProfiles := moduleIni.Read("Settings", "UseCustomWiimoteProfiles","false",,1)	; set to true if you want to setup custom Wiimote profiles for games
UseCustomGCPadProfiles := moduleIni.Read("Settings", "UseCustomGCPadProfiles","false",,1)	; set to true if you want to setup custom GCPad profiles for games
HideMouse := moduleIni.Read("Settings", "HideMouse","true",,1)					; hides mouse cursor in the emu options
RefreshKey := moduleIni.Read("Settings", "RefreshKey",,,1)						; hotkey to "Refresh" Wiimotes, delete the key to disable it
Timeout := moduleIni.Read("Settings", "Timeout","5",,1)							; amount in seconds we should wait for the above hotkeys to timeout
renderToMain := moduleIni.Read("Settings", "Render_To_Main","false",,1)
enableNetworkPlay := moduleIni.Read("Network", "Enable_Network_Play","false",,1)
controlTypePort1 := moduleIni.Read(romName . "|Controls", "Control_Type_Port_1",,,1)
controlTypePort2 := moduleIni.Read(romName . "|Controls", "Control_Type_Port_2",,,1)
controlTypePort3 := moduleIni.Read(romName . "|Controls", "Control_Type_Port_3",,,1)
controlTypePort4 := moduleIni.Read(romName . "|Controls", "Control_Type_Port_4",,,1)

;options to Gamecube and VBA Link
enableVBALink := moduleIni.Read(romName, "enableVBALink", "false",,1)
VBAExePath := moduleIni.Read("VBA Link", "VBAExePath",,,1)
VBABiosPath := moduleIni.Read("VBA Link", "VBABiosPath",,,1)
VBADelay := moduleIni.Read("VBA Link", "VBADelay", 500,,1)

If (renderToMain = "true") {
	emuPrimaryWindow := new Window(new WindowTitle("Dolphin","wxWindowNR"))	; instantiate primary emulator window object
	emuGameWindow := emuPrimaryWindow
} Else {
	emuPrimaryWindow := new Window(new WindowTitle("Dolphin","wxWindowNR"))	; instantiate primary emulator window object
	emuPrimaryWindow.ExcludeTitle := "FPS"	; when main window doesn't have the game, FPS will not be on the title bar
	emuGameWindow := new Window(new WindowTitle("FPS","wxWindowNR"))
}
emuPrimaryWindow := new Window(new WindowTitle("Dolphin","wxWindowNR"))	; instantiate primary emulator window object
emuGameWindow := If renderToMain = "true" ? emuPrimaryWindow : new Window(new WindowTitle("FPS","wxWindowNR"))	; Older dolphins used "FPS ahk_class wxWindowClassNR"
emuScanningWindow := new Window(new WindowTitle("Scanning for ISOs","#32770"))
emuNetPlaySetupWindow := new Window(new WindowTitle("Dolphin NetPlay Setup","wxWindowNR"))
emuNetPlayWindow := new Window(new WindowTitle("Dolphin NetPlay","wxWindowNR"))
emuWiimoteWindow := new Window(new WindowTitle("Dolphin Controller Configuration","#32770"))
emuOpenROMWindow := new Window(new WindowTitle("Select","#32770"))
emuErrorWindow1 := new Window(new WindowTitle("Warning","#32770"))
emuErrorWindow2 := new Window(new WindowTitle("Error","#32770"))
emuWiimoteWindow.CreateControl("OK")

; Determine where Dolphin is storing its ini, this will act as the base folder for settings and profiles related to this emu
dolphinININewPath := new File(A_MyDocuments . "\Dolphin Emulator\Config\Dolphin.ini")	; location of Dolphin.ini for v4.0+
dolphinINIOldPath := new File(emuPath . "\User\Config\Dolphin.ini")	; location of Dolphin.ini prior to v4.0
portableTxtFile := new File(emuPath . "\portable.txt")
If (!portableTxtFile.Exist() && dolphinININewPath.Exist())
{	dolphinBasePath := A_MyDocuments . "\Dolphin Emulator"
	RLLog.Info("Module - Dolphin's base settings folder is not portable and found in: " . dolphinBasePath)
} Else If (portableTxtFile.Exist() || dolphinINIOldPath.Exist())
{	dolphinBasePath := emuPath . "\User"
	RLLog.Info("Module - Dolphin's base settings folder is portable and found in: " . dolphinBasePath)
} Else
	ScriptError("Could not find your Dolphin.ini in either of these folders. Please run Dolphin manually first to create it.`n" . dolphinINIOldPath.FileFullPath . "`n" . dolphinININewPath.FileFullPath)
dolphinINI := new IniFile(dolphinBasePath . "\Config\Dolphin.ini")

If (enableVBALink = "true"){
	VBAExePath := AbsoluteFromRelative(EmuPath, VBAExePath)
	VBABiosPath := AbsoluteFromRelative(EmuPath, VBABiosPath)
	StringUtils.SplitPath(VBAExePath, VBAFile, VBAPath)
	SelectedNumberofPlayers := NumberOfPlayersSelectionMenu(4)
	If (SelectedNumberofPlayers = 1) {
		enableVBALink := "false"
	} Else {
		; backup original ini
		dolphinINIBackup := new File(dolphinBasePath . "\Config\Dolphin_Backup.ini")
		dolphinINI.Copy(dolphinINIBackup.FileFullPath)
		Loop, % SelectedNumberofPlayers
		{ 	tempCount := A_Index-1
			dolphinINI.Write(5, "Controls", PadType%tempCount%)
		}
	}
}

If (enableVBALink = "true")
	BezelStart(SelectedNumberofPlayers+1)
Else
	BezelStart()

If (enableVBALink = "true" and !bezelPath)   ; disabling fullscreen if VBA Link mode
	Fullscreen := "false"

If (renderToMain = "true" && (enableVBALink = "true" || bezelEnabled = "true")) {   ; disabling toolbar and statusbar if bezels or vba link is used as it will show when rendering to the main window
	dolphinINI.Write("False", "Interface", "ShowToolbar")
	dolphinINI.Write("False", "Interface", "ShowStatusbar")
}

If (renderToMain = "true")
	hideEmuObj := Object(emuScanningWindow,0,emuNetPlayWindow,0,emuNetPlaySetupWindow,0,emuErrorWindow1,0,emuErrorWindow2,0,emuGameWindow,1)
Else
	hideEmuObj := Object(emuScanningWindow,0,emuNetPlayWindow,0,emuNetPlaySetupWindow,0,emuErrorWindow1,0,emuErrorWindow2,0,emuPrimaryWindow,0,emuGameWindow,1)

; Set control types in each port
dolphinDevice := 0
Loop 4 {
	If controlTypePort%A_Index%
		dolphinINI.Write(controlTypePort%A_Index%, "Core", "SIDevice" . dolphinDevice)
	dolphinDevice++
}

7z(romPath, romName, romExtension, sevenZExtractPath)

If StringUtils.Contains(romExtension,"\.zip|\.7z|\.rar")
	ScriptError(MEmu . " does not support compressed roms. Please enable 7z support in RocketLauncherUI to use this module/emu.")

If RefreshKey {
	RefreshKey := xHotKeyVarEdit(RefreshKey,"RefreshKey","~","Add")
	xHotKeywrapper(RefreshKey,"RefreshWiimote")
}

Fullscreen := If Fullscreen = "true" ? "True" : "False"
HideMouse := If HideMouse = "true" ? "True" : "False"

networkSession := ""
If (enableNetworkPlay = "true") {
	RLLog.Info("Module - Network Multi-Player is an available option for " . dbName)
	dolphinNickname := dolphinINI.Read("NetPlay", "Nickname")
	dolphinAddress := dolphinINI.Read("NetPlay", "Address")
	dolphinCPort := dolphinINI.Read("NetPlay", "ConnectPort")
	dolphinHPort := dolphinINI.Read("NetPlay", "HostPort")
	netplayNickname := moduleIni.Read("Network", "NetPlay_Nickname","Player",,1)
	getWANIP := moduleIni.Read("Network", "Get_WAN_IP","false",,1)
	networkPlayers := 4	; Max amount of networkable players

	If (getWANIP = "true")
		myPublicIP := GetPublicIP()

	defaultServerIP := moduleIni.Read("Network", "Default_Server_IP", myPublicIP,,1)
	defaultServerPort := moduleIni.Read("Network", "Default_Server_Port",,,1)
	lastIP := moduleIni.Read("Network", "Last_IP", defaultServerIP,,1)	; does not need to be on the ISD
	lastPort := moduleIni.Read("Network", "Last_Port", defaultServerPort,,1)	; does not need to be on the ISD

	If (netplayNickname != dolphinNickname)
		dolphinINI.Write(netplayNickname, "NetPlay", "Nickname")

	MultiplayerMenu(lastIP,lastPort,networkType,networkPlayers,0)
	If networkSession {
		RLLog.Info("Module - Using a Network for " . dbName)

		restoreIniObject := Object()	; initialize object
		currentObj := ""
		dolphinConfigPath := dolphinBasePath . "\Config"
		Loop, % dolphinConfigPath . "\*.ini"
		{
			If StringUtils.InStr(A_LoopFileName, "_netplay.ini",,,,0) {
				RLLog.Info("Module - Found a network specific ini: " . A_LoopFileFullPath)
				networkIni%A_Index%File := new File(A_LoopFileFullPath)
				originalIni%A_Index%File := new File(StringUtils.RegExReplace(A_LoopFileFullPath, "_netplay",,,-1,15))
				backupIni%A_Index%File := new File(originalIni%A_Index%File.FileFullPath . ".backup")
				originalIni%A_Index%File.Move(backupIni%A_Index%File,1)	; backup original ini
				networkIni%A_Index%File.Copy(originalIni%A_Index%File)	; copy network ini to original name
			}
		}
		
		moduleIni.Write(lastPort, "GlobalModuleIni", "Network", "Last_Port")

		If (networkType = "client") {
			moduleIni.Write(lastIP, "GlobalModuleIni", "Network", "Last_IP")	; Save last used IP and Port for quicker launching next time
			dolphinINI.Write(lastIP, "Network", "Address")
			dolphinINI.Write(lastPort, "Network", "ConnectPort")
		} Else	; server
			dolphinINI.Write(lastPort, "Network", "HostPort")

		dolphinINI.Write(romPath, "Network", "ISOPath0")	; makes browser only show the one game we want to play
		dolphinINI.Write(1, "General", "ISOPaths")	; makes browser only show the first path set
		dolphinINI.Write(romPath . "\" . romName . romExtension, "General", "LastFilename")
		RLLog.Info("Module - Starting a network session using the IP """ . networkIP . """ and PORT """ . networkPort . """")
	} Else
		RLLog.Info("Module - User chose Single Player mode for this session")
}

gcSerialPort := 5	; this puts the BBA network adapter into the serial port. If previous launch was Triforce, AM-Baseboard would be set here and would result in Unknown DVD command errors

; Compare existing settings and if different than desired, write them to the emulator's ini
dolphinINI.Write(Fullscreen, "Display", "Fullscreen", 1)
dolphinINI.Write(renderToMain, "Display", "RenderToMain", 1)
dolphinINI.Write(HideMouse, "Interface", "HideCursor", 1)
dolphinINI.Write("False", "Interface", "ConfirmStop", 1)
dolphinINI.Write("False", "Interface", "UsePanicHandlers", 1)
dolphinINI.Write(gcSerialPort, "Core", "SerialPort1", 1)

 ; Load default or user specified Wiimote or GCPad profiles for launching
If (StringUtils.InStr(systemName, "wii") && UseCustomWiimoteProfiles = "true")
	ChangeDolphinProfile("Wiimote")
If (UseCustomGCPadProfiles = "true")
	ChangeDolphinProfile("GCPad")

HideAppStart(hideEmuObj,hideEmu)

If networkSession
	primaryExe.Run()	; must be launched w/o /b for browser list to work
Else
	primaryExe.Run(" /b /e """ . romPath . "\" . romName . romExtension . """")	; /b = batch (exit dolphin with emu), /e = load file

emuGameWindow.Wait()
emuGameWindow.Get("ID")
emuGameWindow.WaitActive()

If networkSession {
	RLLog.Info("Module - Opening NetPlay window")

	; Get the 6-letter ID of the game
	If (romExtension = ".wbfs")
		gameID := RLObject.readFileData(romPath . "\" . romName . romExtension,512,6,"UTF8")
	Else If (romExtension = ".iso")
		gameID := RLObject.readFileData(romPath . "\" . romName . romExtension,0,6,"UTF8")
	Else If (romExtension = ".ciso")
		gameID := RLObject.readFileData(romPath . "\" . romName . romExtension,32768,6,"UTF8")

	; Must wait for Dolphin to finish scanning isos before netplay window can be opened so the game list is populated. Opening too early and the game list will be blank or partially filled.
	If emuScanningWindow.Exist()
		emuScanningWindow.WaitClose(60)	; wait 60 seconds max. hopefully doesn't take longer than that to scan your isos...
	Else {
		errlvl := emuScanningWindow.Wait(5)	; wait 5 seconds max to appear
		If errlvl
			RLLog.Info("Module - Timed out waiting for ""Scanning for ISOs"" window to appear. It may have finished before it could be detected, moving on.")
		Else
			RLLog.Info("Module - ""Scanning for ISOs"" window found.")
	}
	emuPrimaryWindow.MenuSelectItem("Tools", "Start NetPlay")
	matchMode := A_TitleMatchMode	; store for restoration later
	MiscUtils.SetTitleMatchMode(3)	; changes match mode so title must match exactly
	emuNetPlaySetupWindow.Wait()
	emuNetPlaySetupWindow.WaitActive()
	emuNetPlayWindow.ExcludeTitle := emuNetPlaySetupWindow.WinTitle.GetWIndowTitle()		; set emuNetPlayWindow exclude title for the below command
	If (networkType = "client") {
		RLLog.Info("Module - Clicking Connect button")

		emuNetPlaySetupWindow.CreateControl("Button1")		; instantiate new control for button1
		emuErrorWindow1.CreateControl("Button1")
		emuErrorWindow2.CreateControl("Button1")

		While !breakLoops {
			emuNetPlaySetupWindow.GetControl("button1").Click()	; click connect button
			RLLog.Info("Module - Waiting for Host to start game")
			errlvl := emuNetPlayWindow.Wait(2)	; waits 2 seconds
			If errlvl {	; 1 if timed out, now check for any error windows and close them
				Loop, 2		; loop through both error windows
					If emuErrorWindow%A_Index%.Exist()	; error windows that can appear when host is not running yet
						emuErrorWindow%A_Index%.GetControl("button1").Click()	; click ok to clear the error
				RLLog.Info("Module - Host not running yet, trying again")
				Continue
			} Else {	; window exists
				RLLog.Info("Module - Connected to host, waiting for host to start game")
				Break
			}
		}
	} Else {	; server
		emuNetPlayWindow.CreateControl("ListBox1")	; create a control called ListBox1
		emuNetPlayWindow.CreateControl("Button8")	; create a control called Button8 (the Host's Start button)
		emuNetPlaySetupWindow.CreateControl("ListBox1")	; create a control called ListBox1
		emuNetPlaySetupWindow.CreateControl("Button3")	; create a control called Button3 (the Host button)
		emuNetPlaySetupWindow.GetControl("ListBox1").Get("List")	; Get the text from the ListBox
		loopList := emuNetPlaySetupWindow.GetControl("ListBox1").List	; can't use this object directly on the Parse Loop below
		Loop, Parse, loopList, `n
		{
			If StringUtils.InStr(A_Loopfield, gameID,,,,0) {
				idLocation := A_Index	; record the location in the ListBox of our game
				RLLog.Info("Module - Game list shows """ . A_LoopField . """ as item " . A_Index)	; logging each items in ListBox
			}
		}
		If !idLocation {	; game was not found in list
			ScriptError("Could not find your """ . romName . """ in the game selection window for netplay. Possibly the gameID could not be found in your game. Please check your the RocketLauncher log and report this error.",,,,,1)
			Gosub, CloseProcess
			FadeInExit()
			Goto, CloseDolphin
		}
		emuNetPlaySetupWindow.GetControl("ListBox1").Control("Choose",idLocation)	; selects our game in the ListBox
		RLLog.Info("Module - Clicking Host button")
		emuNetPlaySetupWindow.GetControl("Button3").Click()	; click host button
		emuNetPlayWindow.Wait()	; this window should now appear when hosted correctly
		RLLog.Info("Module - Waiting for " . networkPlayers . " players until the game is started")
		While !breakLoops {
			emuNetPlayWindow.GetControl("ListBox1").Get("List")	; Get the text from the ListBox
			If StringUtils.InStr(emuNetPlayWindow.GetControl("ListBox1").List,"[" . networkPlayers . "]",,,,0) {
				RLLog.Info("Module - All players have joined, starting game")
				Break
			}
			TimerUtils.Sleep(100,0)
		}
		emuNetPlayWindow.GetControl("Button8").Click()	; click Start button
	}
	MiscUtils.SetTitleMatchMode(matchMode)	; restore old match mode
}


If (enableVBALink = "true") {
	vbaINI := new IniFile(VBAPath . "\vbam.ini")
	vbaINI.CheckFile()
	vbaINIBackup := new File(VBAPath . "\vbam_Backup.ini")
	vbaINI.Copy(vbaINIBackup.FileFullPath)
	;removing fullscreen from VBA-M
	vbaINI.Write(0, "preferences", "fullScreen")
	;setting other VBA-M ini options
	VBABiosPathDoubleSlash := StringUtils.Replace(VBABiosPath,"\","\\","all")
	vbaINI.Write(0, "preferences", "pauseWhenInactive")
	vbaINI.Write(VBABiosPathDoubleSlash, "GBA", "BiosFile")
	vbaINI.Write(1, "GBA", "LinkAuto")
	vbaINI.Write("127.0.0.1", "GBA", "LinkHost")
	vbaINI.Write(3, "GBA", "LinkType")
	vbaINI.Write(SelectedNumberofPlayers, "preferences", "LinkNumPlayers")
	vbaINI.Write(1, "preferences", "useBiosGBA")
	vbaINI.Write(1, "Display", "Stretch")
	vbaINI.Write(1, "Display", "Scale")
	
	;running VBA-M
	Loop % SelectedNumberofPlayers {
		currentScreen := A_Index + 1
		VBA%currentScreen%Exe := new Process(VBAExePath)	; instantiate a new process for each instance of VBA we need to run
		VBA%currentScreen%Exe.Run(" """ . VBABiosPath . """")
		; msgbox % "PID: " . VBA%A_Index%Exe.PID . "`nVBABiosPath: " . VBABiosPath
		VBA%currentScreen%Window := new Window(new WindowTitle(,,,,VBA%currentScreen%Exe.PID))
		VBA%currentScreen%Window.Wait()
		TimerUtils.Sleep(VBADelay,0)
		bezelBottomOffsetScreen%currentScreen% := 24 ; to hide emu bottom bar
	}
	;waiting for VBA-M windows bios loading
	timeout := A_TickCount
	VBAGBABiosWindow := new Window(new WindowTitle("gba_bios - VisualBoyAdvance-M"))
	Loop {	
		VBAGBABiosWindow.Get("List")	; Get a list of all vba-m hwnd IDs
		If (VBAGBABiosWindow.List[0] = SelectedNumberofPlayers){
			Loop % VBAGBABiosWindow.List[0] {	; loop through each vba-m window
				currentScreen := A_Index + 1
				Screen%currentScreen%ID := VBAGBABiosWindow.List[A_Index]	; record each vba-m window's hwnd ID
			}
			RLLog.Info("Module - gba_bios Loaded")
			Break
		}
		If (timeout < A_TickCount - 10000) {
			RLLog.Warning("Module - Timed out waiting gba_bios to load")
			Break
		}
		TimerUtils.Sleep(100,0)
	}
	;Resizing Windows to fill screen if no bezel file is found
	If !(bezelPath) {
		Loop % (SelectedNumberofPlayers + 1) {
			If (A_Index = 1) {	; the main Dolphin window
				X1 := 0
				Y1 := 0
				W1 := A_ScreenWidth//2
				H1 := A_ScreenHeight
				emuGameWindow.WinTitle.PID := ""	; remove PID from object's WinTitle so only the window hwnd ID is acted upon
				emuGameWindow.RemoveBorder()	
				emuGameWindow.RemoveTitlebar()
				emuGameWindow.ToggleMenu()
				emuGameWindow.Move(X1,Y1,W1,H1)
			} Else {	; the vba-m windows
				X%A_Index% := A_ScreenWidth//2
				Y%A_Index% := (A_Index-2)*(A_ScreenHeight//SelectedNumberofPlayers)
				W%A_Index% := A_ScreenWidth//2
				H%A_Index% := (A_ScreenHeight//SelectedNumberofPlayers)+bezelBottomOffsetScreen%A_Index%
				VBA%A_Index%Window.WinTitle.ID := Screen%A_Index%ID	; set ID of window into object
				VBA%A_Index%Window.WinTitle.PID := ""	; remove PID from object's WinTitle so only the window hwnd ID is acted upon
				VBA%A_Index%Window.RemoveBorder()
				VBA%A_Index%Window.RemoveTitlebar()
				VBA%A_Index%Window.ToggleMenu()
				VBA%A_Index%Window.Move(X%A_Index%,Y%A_Index%,W%A_Index%,H%A_Index%)
			}
		}
		TimerUtils.Sleep(50)
		Loop % SelectedNumberofPlayers {
			currentScreen := A_Index + 1
			VBA%currentScreen%Window.Activate()	; put focus on all the VBA windows
		}
		VBA1Window.Activate()	; put focus on the first VBA window
	}
}

BezelDraw()

emuGameWindow.Activate()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")

CloseDolphin:
If networkSession {
	Loop {	
		If !IsObject(backupIni%A_Index%File)
			Break
		RLLog.Info("Module - Restoring the original ini: " . backupIni%A_Index%File.FileFullPath . " to " . originalIni%A_Index%File.FileFullPath)
		backupIni%A_Index%File.Move(originalIni%A_Index%File.FileFullPath,1)		; restore all backed up inis
	}
}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


ChangeDolphinProfile(profileType) {
	Global settingsFile,romName,dolphinBasePath,RLLog,moduleIni
	profile := moduleIni.Read(romName, "profile", "Default",,1)
	RLProfilePath := new Folder(dolphinBasePath . "\Config\Profiles\" . profileType . " (RL)")
	currentProfileFile := new File(dolphinBasePath . "\Config\" . profileType . "New.ini")
	defaultProfileFile := new File(RLProfilePath.FilePath . "\_Default_" . profileType . "New.ini")
	customProfileFile := new File(RLProfilePath.FilePath . "\" . profile . ".ini")
	If !currentProfileFile.Exist() {
		RLLog.Warning("Module - You have custom " . profileType . " profiles enabled, but could not locate " . currentProfileFile.FileFullPath . ". This file stores all your current controls in Dolphin. Please setup your controls in Dolphin first.")
		Return
	}
	If !defaultProfileFile.Exist() {
		RLLog.Warning("Module - Creating initial Default " . profileType . " profile by copying " . profileType . ".ini to " . defaultProfileFile.FileFullPath)
		RLProfilePath.CreateDir()
		currentProfileFile.Copy(defaultProfileFile.FileFullPath)	; create the initial default profile on first launch
	}
	If (profile != "Default" && !customProfileFile.Exist())
		RLLog.Warning("Module - " . romName . " is set to load a custom " . profileType . " profile`, but it could not be found: " . customProfileFile.FileFullPath)
	currentProfileFile.Read()	; read current profile into memory
	customProfileFile.Read()	; read custom profile into memory
	If (currentProfileFile.Text != customProfileFile.Text) {	; if both profiles do not match exactly
		RLLog.Info("Module - Current " . profileType . " profile does not match the one this game should use.")
		If (profile != "Default") {	; if user set to use a custom profile
			RLLog.Info("Module - Copying this defined " . profileType . " profile to replace the current one: " . customProfileFile.FileFullPath)
			customProfileFile.Copy(currentProfileFile.FileFullPath,1)
		} Else {	; load default profile
			RLLog.Info("Module - Copying the default " . profileType . " profile to replace the current one: " . defaultProfileFile.FileFullPath)
			defaultProfileFile.Copy(currentProfileFile.FileFullPath,1)
		}
	} Else
		RLLog.Info("Module - Current " . profileType . " profile is already the correct one for this game, not touching it.")
}

ConnectWiimote(key) {
	Global Timeout,emuPrimaryWindow,emuGameWindow,emuWiimoteWindow
	If !emuWiimoteWindow.Exist()
	{
		MiscUtils.DetectHiddenWindows("OFF") ; this needs to be off otherwise WinMenuSelectItem doesn't work for some odd reason
		emuPrimaryWindow.Activate()
		emuPrimaryWindow.MenuSelectItem("Options","Controller Settings")
		emuWiimoteWindow.Wait()
		emuWiimoteWindow.WaitActive()
	}
	;emuWiimoteWindow.Activate() ; test if window needs to be active
	If !emuWiimoteWindow.GetControl(key)
		emuWiimoteWindow.CreateControl(key)
	emuWiimoteWindow.GetControl(key).Click()
	emuWiimoteWindow.GetControl("OK").Click()
	emuGameWindow.Activate()
}

PairWiimote:
	ConnectWiimote("Pair Up")
Return

RefreshWiimote:
	ConnectWiimote("Refresh")
Return

HaltEmu:
	If RefreshKey
		XHotKeywrapper(RefreshKey,"RefreshWiimote","OFF")
Return

MultiGame:
	; MultiGame doesn't work with Dolphin currently because Dolphin hides itself from Winspector Spy and cannot send any commands to the emulator through scripts.
	If (fullscreen = "True")
	{	KeyUtils.SetKeyDelay(50)
		KeyUtils.Send("{Alt Down}{Enter Down}{Enter Up}{Alt Up}")	; go windowed to get the menubar
	}
	If bezelEnabled
		emuGameWindow.ToggleMenu()	; put the menubar back
	; emuPrimaryWindow.MenuSelectItem("File","Change Disc...")
	emuPrimaryWindow.MessageUtils.PostMessage("0x111", "00288")	; Change Disc
	OpenROM(emuOpenROMWindow.WinTitle.GetWindowTitle(), selectedRom)
	emuPrimaryWindow.WaitActive()
	If bezelEnabled
		emuGameWindow.ToggleMenu()	; remove the menubar again
	If (fullscreen = "True")
		KeyUtils.Send("{Alt Down}{Enter Down}{Enter Up}{Alt Up}")	; restore fullscreen
Return

RestoreEmu:
	If RefreshKey
		XHotKeywrapper(RefreshKey,"RefreshWiimote","ON")
Return

CloseProcess:
	breakLoops := 1
	FadeOutStart()
	If (enableVBALink = "true") {
		Loop % SelectedNumberofPlayers
		{	currentScreen := A_Index + 1
			;VBA%currentScreen%Window.Activate()
			VBA%currentScreen%Window.Close()
			TimerUtils.Sleep(100,0)
		}
		dolphinINIBackup.Move(dolphinINI.FileFullPath)
		vbaINIBackup.Move(vbaINI,1)
	}
	If networkSession {
		If emuNetPlaySetupWindow.Exist()
			emuNetPlaySetupWindow.Close()
		If emuNetPlayWindow.Exist()
			emuNetPlayWindow.Close()
		If !emuGameWindow.Exist()	; if game never launched, close the main emu window
			emuPrimaryWindow.Close()
	}
	If emuGameWindow.Exist()
		emuGameWindow.Close() ; this needs to close the window the game is running in otherwise dolphin crashes on exit
Return

; Unused messages for reference from Dolphin v4.0 build 6980 x64:
; emuPrimaryWindow.PostMessage("0x111", "0261")		; Toggle Fullscreen
; emuPrimaryWindow.PostMessage("0x111", "0258")		; Toggle Play/Pause
; emuPrimaryWindow.PostMessage("0x111", "0259")		; Stop
; emuPrimaryWindow.PostMessage("0x111", "0260")		; Reset
; emuPrimaryWindow.PostMessage("0x111", "00539")	; Show Toolbar
; emuPrimaryWindow.PostMessage("0x111", "00540")	; Show Statusbar
; emuPrimaryWindow.PostMessage("0x111", "05123")	; Refresh List
; emuPrimaryWindow.PostMessage("0x111", "0305")		; Change Disc
; emuPrimaryWindow.PostMessage("0x111", "00218")	; Load State Slot 1
; emuPrimaryWindow.PostMessage("0x111", "00227")	; Load State Slot 10
; emuPrimaryWindow.PostMessage("0x111", "00208")	; Save State Slot 1
; emuPrimaryWindow.PostMessage("0x111", "00217")	; Save State Slot 10
; emuPrimaryWindow.PostMessage("0x111", "00303")	; Start Netplay
; emuPrimaryWindow.PostMessage("0x111", "05000")	; Open

; Unused messages for reference from Dolphin v4.0.2 x86:
; emuPrimaryWindow.PostMessage("0x111", "00248")	; Toggle Fullscreen
; emuPrimaryWindow.PostMessage("0x111", "00245")	; Toggle Play/Pause
; emuPrimaryWindow.PostMessage("0x111", "00246")	; Stop
; emuPrimaryWindow.PostMessage("0x111", "00247")	; Reset
; emuPrimaryWindow.PostMessage("0x111", "00501")	; Show Toolbar
; emuPrimaryWindow.PostMessage("0x111", "00502")	; Show Statusbar
; emuPrimaryWindow.PostMessage("0x111", "00217")	; Load State Slot 1
; emuPrimaryWindow.PostMessage("0x111", "00226")	; Load State Slot 10
; emuPrimaryWindow.PostMessage("0x111", "00207")	; Save State Slot 1
; emuPrimaryWindow.PostMessage("0x111", "00216")	; Save State Slot 10
; emuPrimaryWindow.PostMessage("0x111", "00286")	; Start Netplay
; emuPrimaryWindow.PostMessage("0x111", "05000")	; Open
; emuPrimaryWindow.PostMessage("0x111", "05006")	; Exit
