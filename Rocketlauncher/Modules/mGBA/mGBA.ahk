MEmu := "mGBA"
MEmuV := "v0.2.0"
MURL := ["http://endrift.com/mgba/"]
MAuthor := ["djvj"]
MVersion := "1.0"
MCRC := "A996EEC9"
iCRC := "1E716C97"
MID := "635643149754664225"
MSystem := ["Nintendo Game Boy Advance"]
;----------------------------------------------------------------------------
; Notes:
; Settings stored in C:\Users\NAME\AppData\Roaming\mGBA
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

BezelStart()

mgbaIni := CheckFile(A_AppData . "\mGBA\config.ini", "Could not find " . A_AppData . "\mGBA\config.ini`nPlease run mGBA manually first so it is created for you.")
IniRead, currentFullScreen, %mgbaIni%, ports.qt, fullscreen
If (Fullscreen != "true" && currentFullScreen = 1)
	IniWrite, 0, %mgbaIni%, ports.qt, fullscreen
Else If (Fullscreen = "true" & currentFullScreen = 0)
	IniWrite, 1, %mgbaIni%, ports.qt, fullscreen

hideEmuObj := Object("mGBA ahk_class Qt5QWindowIcon",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("mGBA ahk_class Qt5QWindowIcon")
WinWaitActive("mGBA ahk_class Qt5QWindowIcon")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("mGBA ahk_class Qt5QWindowIcon")
Return
