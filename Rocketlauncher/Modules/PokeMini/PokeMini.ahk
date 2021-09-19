MEmu := "PokeMini"
MEmuV := "v0.60"
MURL := ["https://code.google.com/p/pokemini/"]
MAuthor := ["djvj","brolly"]
MVersion := "2.0.1"
MCRC := "225A4E2C"
iCRC := "7AE78479"
MID := "635038268915383452"
MSystem := ["Nintendo Pokemon Mini"]
;----------------------------------------------------------------------------
; Notes:
; This will only work with the windows SDL port. The win32 port did not work for me.
; Place bios.min in the emu dir if you have it, otherwise the emu resorts to Pokemon-Mini FreeBIOS
; Emu requires zlib1.dll to be installed or exist in the emu folder, get it here if you don't have it: http://sourceforge.net/projects/libpng/?source=dlp
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
BatteryState := IniReadCheck(settingsFile, "Settings", "BatteryState","full",,1)		; Options are full and low
Joystick := IniReadCheck(settingsFile, "Settings", "Joystick","true",,1)			; True enables joystick support

BezelStart()

7z(romPath, romName, romExtension, 7zExtractPath)

fs := (If Fullscreen = "true" ? ("-fullscreen") : (""))
battery := (If BatteryState = "full" ? ("-fullbattery") : ("-lowbattery"))
joystick := (If Joystick = "true" ? ("-joystick") : (""))

Run(executable . " " . fs . " " . battery . " " . joystick . " """ . romPath . "\" . romName . romExtension . """",emuPath)

WinWait("PokeMini ahk_class POKEMINIWIN")
WinActivate, PokeMini ahk_class POKEMINIWIN

MouseMove, %A_ScreenWidth%, %A_ScreenHeight%

If (Fullscreen = "true")
	DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ;Hide menu bar

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("PokeMini ahk_class POKEMINIWIN")
Return
