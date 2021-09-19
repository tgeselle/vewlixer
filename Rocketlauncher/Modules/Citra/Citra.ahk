MEmu := "Citra"
MEmuV := "2016-11-23"
MURL := ["http://citra-emu.org/"]
MAuthor := ["djvj","bleasby"]
MVersion := "1.0.1"
MCRC := "B2CEA0A2"
iCRC := "8131AB6F"
MID := "635740704032217117"
MSystem := ["Nintendo 3DS"]
;---------------------------------------------------------------------------- 
; Notes:
; Roms must be decrypted to run in the emu
; See here for a guide on decrypting games you own: https://gbatemp.net/threads/tutorial-how-to-decrypt-extract-rebuild-3ds-roms-run-xy-oras-without-update.383055/
;---------------------------------------------------------------------------- 
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
primaryWindowClassName := "Qt5QWindowIcon"
emuPrimaryWindow := new Window(new WindowTitle("Citra",primaryWindowClassName))	; instantiate primary emulator window object
emuConsoleWindow := new Window(new WindowTitle(,"ConsoleWindowClass"))

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
bezelTopOffset := moduleIni.Read("Settings", "Bezel_Top_Offset","30",,1)
bezelBottomOffset := moduleIni.Read("Settings", "Bezel_Bottom_Offset","8",,1)
bezelRightOffset := moduleIni.Read("Settings", "Bezel_Right_Offset", "8",,1)
bezelLeftOffset := moduleIni.Read("Settings", "Bezel_Left_Offset", "8",,1)

CitraIni := new IniFile(emuPath . "\user\config\qt-config.ini")
CitraIni.CheckFile("Could not find Citra's ini file. Please run Citra manually first and make sure that you use the module recomended emulator version.")

; Disabling the emu exit confirmation
confirmClose := CitraIni.Read("UI", "confirmClose")
If (confirmClose = "true")
	CitraIni.Write("false", "UI", "confirmClose")

; Setting the game to launch on an extra window. 
singleWindowMode := CitraIni.Read("UI", "singleWindowMode")
If (singleWindowMode = "true")
	CitraIni.Write("false", "UI", "singleWindowMode")

BezelStart()

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)

7z(romPath, romName, romExtension, SevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run("""" . romPath . "\" . romName . romExtension . """")

; Waiting for main emu window
emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

; Hiding citra console window
emuConsoleWindow.Set("Transparent",0)

; Waiting for game to load
TimeOut := 3000
StartTime := A_TickCount
Loop, {
	WinGet, IDList, List, ahk_class %primaryWindowClassName% ; get a list of all windows which match this windowTitle
	Loop, % IDList ; IDList set to number of matches found
	{	id := IDList%A_Index%
		ControlGet, OutputVar, Hwnd,, Qt5QWindowOwnDCIcon1, ahk_id %id%
		If !ErrorLevel
		{	gameWindowID := id
			Break
		}
	}
	If (TimeOut && A_TickCount - StartTime > TimeOut)
		Break
}
; Saving id of extra emulator window to be hidden
WinGet, IDList, List, ahk_class %primaryWindowClassName% ; Get a list of all windows which match this windowTitle
Loop, % IDList ; IDList set to number of matches found
{	id := IDList%A_Index%
	If !(id = gameWindowID) {
		launchWindowID := id
		launchWindow := new Window(new WindowTitle(,,,launchWindowID))
		Break
	}
}

; Hiding extra emulator window
If (launchWindowID)  {
	launchWindow.Hide()
}

; Waiting for game window to be active if it is not
gameWindow := new Window(new WindowTitle(,,,gameWindowID))
gameWindow.WaitActive()

if (Fullscreen = "true"){  ; Creating fake full screen as the emu always launches in windowed mode
	WinGet emulatorID, ID, A
	emulatorWindow := new Window(new WindowTitle(,,,emulatorID))
	RLObject.hideWindowTitleBar(emulatorID)
	RLObject.hideWindowBorder(emulatorID)
	emulatorWindow.Move(0,0,A_screenWidth,A_screenHeight + 38)
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	If (launchWindowID)
		launchWindow.Close()
	Else
		gameWindow.Close()
Return

BezelLabel:
	disableHideBorder := "true"
	disableHideTitleBar := "true"
	disableHideToggleMenu := "true"
Return
