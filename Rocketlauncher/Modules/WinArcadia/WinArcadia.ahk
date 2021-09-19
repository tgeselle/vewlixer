MEmu := "WinArcadia"
MEmuV := "v24.3"
MURL := ["http://amigan.1emu.net/releases/"]
MAuthor := ["brolly"]
MVersion := "2.0.4"
MCRC := "DA2D6854"
iCRC := "E898F177"
MID := "635038268934589449"
MSystem := ["Coleco Telstar","Emerson Arcadia 2001","Interton VC 4000"]
;----------------------------------------------------------------------------
; Notes:
; The settings are saved by default on a file named WinArcadia.ini inside the Configs folder.
; You can also create different config files per game in that folder 
; and name them to match the roms and those will be used instead of the default WA.CFG one.
;
; Pong systems such as Coleco Telstar don't use roms so make sure you set skipchecks to rom only for those.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"WinArcadia"))	; instantiate primary emulator window object

; This object controls how the module reacts to different systems. WinArcadia can play several systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Coleco Telstar","ay-3-8550","Emerson Arcadia 2001","arcadia","Interton VC 4000","vc4000")
ident := mType[systemName]	; search object for the systemName identifier
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this WinUAE module: " . moduleName)

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
DefaultCfgFile := moduleIni.Read("Settings", "DefaultCfgFile","WinArcadia.ini",,1)
ShowDebugger := moduleIni.Read("Settings", "ShowDebugger","false",,1)
ShowSidebar := moduleIni.Read("Settings", "ShowSidebar","false",,1)
ShowMenuBar := moduleIni.Read("Settings", "ShowMenuBar","false",,1)
ShowMousePointer := moduleIni.Read("Settings", "ShowMousePointer","true",,1)
ShowStatusBar := moduleIni.Read("Settings", "ShowStatusBar","false",,1)
ShowTitleBar := moduleIni.Read("Settings", "ShowTitleBar","true",,1)
ShowToolBar := moduleIni.Read("Settings", "ShowToolBar","false",,1)
ShowScanlines := moduleIni.Read("Settings", "ShowScanlines","false",,1)
WindowedZoomLevel := moduleIni.Read("Settings", "WindowedZoomLevel","3",,1)

romNameCfgFile := new IniFile(emuPath . "\Configs\" . romName . ".ini")
cfgFile := If romNameCfgFile.Exist() ? (romName . ".ini") : DefaultCfgFile

waFile := new File(emuPath . "\Configs\" . cfgFile)
waFile.CheckFile()
waIni := LoadProperties(waFile.FileFullPath)	; load the config into memory

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)
BezelStart("fixResMode")

fsPrefix := If Fullscreen = "true" ? "fullscreen_" : "windowed_"

;WriteProperty(waIni, "fullscreen", Fullscreen)
WriteProperty(waIni, fsPrefix . "debugger", If Fullscreen = "true" ? "false" : ShowDebugger)
WriteProperty(waIni, fsPrefix . "sidebar", If Fullscreen = "true" ? "false" : ShowSidebar)
WriteProperty(waIni, fsPrefix . "menubar", If Fullscreen = "true" ? "false" : ShowMenuBar)
WriteProperty(waIni, fsPrefix . "pointer", If Fullscreen = "true" ? "false" : ShowMousePointer)
WriteProperty(waIni, fsPrefix . "statusbar", If Fullscreen = "true" ? "false" : ShowStatusBar)
WriteProperty(waIni, fsPrefix . "titlebar", If Fullscreen = "true" ? "false" : ShowTitleBar)
WriteProperty(waIni, fsPrefix . "toolbar", If Fullscreen = "true" ? "false" : ShowToolBar)
WriteProperty(waIni, "colourset", "0")
WriteProperty(waIni, "scanlines", ShowScanlines)
WriteProperty(waIni, "size", WindowedZoomLevel)

If (StringUtils.Contains(ident,"ay.*8550"))
	SetupPong("8550")
Else If (StringUtils.Contains(ident,"ay.*8600"))
	SetupPong("8600")
Else {
	filePath := " FILE=""" . romPath . "\" . romName . romExtension . """"
}

SaveProperties(waFile.FileFullPath,waIni)

;Delete AUTOSAVE.COS file if it exists (otherwise it will cause issues particularly with pong systems)
AutoSaveFile := new File(emuPath . "\AUTOSAVE.COS")
If AutoSaveFile.Exist()
	AutoSaveFile.Delete()

fs := If Fullscreen = "true" ? " FULLSCREEN=ON" : " FULLSCREEN=OFF"

HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run(" SETTINGS=""" . cfgFile . """" . fs . filePath)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

SetupPong(mode) {
	Global systemName, romName, waIni

	BatSize := moduleIni.Read("Pong", "BatSize","1",,1)
	BallSpeed := moduleIni.Read("Pong", "BallSpeed","0",,1)
	Serving := moduleIni.Read("Pong", "Serving","1",,1)
	BallAngles := moduleIni.Read("Pong", "BallAngles","2",,1)
	LockHorizontal := moduleIni.Read("Pong", "LockHorizontal","true",,1)

	ColorSet := "1" ;Default is Black & White

	If (mode = "8550") {
		If (StringUtils.Contains(romName, "Tennis"))
			gameId := "0"
		Else If (StringUtils.Contains(romName, "Soccer|Hockey"))
			gameId := "1"
		Else If (StringUtils.Contains(romName, "Handicap"))
			gameId := "2" ;Undocumented game that could be played when none of the previous six games was selected on the game switch
		Else If (StringUtils.Contains(romName, "Squash|Handball"))
			gameId := "3"
		Else If (StringUtils.Contains(romName, "Practice"))
			gameId := "4"
		Else If (StringUtils.Contains(romName, "Target"))
			gameId := "5"
		Else If (StringUtils.Contains(romName, "Skeet"))
			gameId := "6"
		Else
			ScriptError("Your romName is: " . romName . "`nIt's not a recognized pong game for this system")
		memoryMap := "29"

		If (systemName = "Coleco Telstar") {
			;Force some options for this system regardless the ini settings
			LockHorizontal := "true"
		}
	}
	Else If (mode = "8600") {
		If (StringUtils.Contains(romName, "Tennis"))
			gameId := "7"
		Else If (StringUtils.Contains(romName, "Hockey"))
			gameId := "8"
		Else If (StringUtils.Contains(romName, "Soccer"))
			gameId := "9"
		Else If (StringUtils.Contains(romName, "Squash|Jai Alai"))
			gameId := "10"
		Else If (StringUtils.Contains(romName, "Basketball Practice"))
			gameId := "14"
		Else If (StringUtils.Contains(romName, "Practice"))
			gameId := "11"
		Else If (StringUtils.Contains(romName, "Gridball"))
			gameId := "12"
		Else If (StringUtils.Contains(romName, "Basketball"))
			gameId := "13"
		Else If (StringUtils.Contains(romName, "1-Player Target"))
			gameId := "15"
		Else If (StringUtils.Contains(romName, "2-Player Target"))
			gameId := "16"
		Else
			ScriptError("Your romName is: " . romName . "`nIt's not a recognized pong game for this system")
		memoryMap := "30"
	}

	WriteProperty(waIni, "guest", "11") ;Guest=11 means Pong systems, check source file aa.h (#define PONG 11)
	WriteProperty(waIni, "pong_batsizes", BatSize)
	WriteProperty(waIni, "pong_speed", BallSpeed)
	WriteProperty(waIni, "pong_serving", Serving)
	WriteProperty(waIni, "pong_angles", BallAngles)
	WriteProperty(waIni, "pong_lockhorizontal", LockHorizontal)
	WriteProperty(waIni, "memorymap", memoryMap) ;Admissible values for memorymap are listed in the source aa.h file at about line 1100 (#define MEMMAP_8550 29)
	WriteProperty(waIni, "pong_variant", gameId)
	WriteProperty(waIni, "colourset", ColorSet)

	;Clear game dir and previously loaded roms otherwise emulator will try to auto detect the system from those
	WriteProperty(waIni, "gamedir", "")
	WriteProperty(waIni, "recent_0", "")
	WriteProperty(waIni, "recent_1", "")
	WriteProperty(waIni, "recent_2", "")
	WriteProperty(waIni, "recent_3", "")
}

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
