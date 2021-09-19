MEmu := "CPS3"
MEmuV := "v1.0a"
MURL := ["http://nebula.emulatronia.com/"]
MAuthor := ["djvj"]
MVersion := "1.0.1"
MCRC := "DB274422"
iCRC := "EB44FC76"
MID := "635732033396524046"
MSystem := ["Capcom Play System 3","Capcom Play System III"]
;---------------------------------------------------------------------------- 
; Notes:
; Roms must be named mame-style short names because they get passed as is to the emu to load.
; Open the emulator.ini in the emu folder and make sure the Dir1 points to your folder with your roms. Also make sure to remove the ; at the beginning of the line.
; Set any other settings in the emulator.ini that you may need as well. AutoFull will be controlled by the module.
;---------------------------------------------------------------------------- 
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

BezelStart()

;Set the properties in the emulator.ini file
configFile := CheckFile(emuPath . "\emulator.ini")
IniRead, currentFullscreen, %configFile%, Renderer, AutoFull
If (fullscreen = "true" && currentFullscreen != "1")
	IniWrite, 1, %configFile%, Renderer, AutoFull
Else If (fullscreen != "true" && currentFullscreen != "0")
	IniWrite, 0, %configFile%, Renderer, AutoFull

hideEmuObj := Object("ahk_class MYWIN",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
HideEmuStart()
Run(executable . A_Space . romName, emuPath)

WinWait("ahk_class MYWIN")
WinWaitActive("ahk_class MYWIN")
Sleep, 2000	; Increase if your front end is getting a quick flash before the game loads

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
RestoreEmu:
	If fullscreen = true
	{	PostMessage, 0x111, 40010,,,ahk_class MYWIN	; Toggle Fullscreen
		Sleep, 2000	; required otherwise the emu crashes from being paused
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class MYWIN")
Return

; Unused commands
; PostMessage, 0x111, 40004,,,ahk_class MYWIN	; Exit
; PostMessage, 0x111, 40010,,,ahk_class MYWIN	; Set to Custom (.ini) res
