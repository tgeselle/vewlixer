MEmu := "Unit3D Pinball"
MEmuV := "v1.0"
MURL := ["http://www.unit3dpinball.net/"]
MAuthor := ["bleasby"]
MVersion := "1.0.0"
MCRC := "F841787F"
iCRC := "9424A5B9"
MID := "635718231483564523"
MSystem := ["Unit3D Pinball"]
;----------------------------------------------------------------------------
; Notes:
; 
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
WindowedMode := IniReadCheck(settingsFile, "settings", "WindowedMode","Window",,1) ; Window, Fake Full Screen Mono, Fake Full Screen All  

BezelStart()

if (bezelEnabled = "true") and (bezelPath)
	WindowedMode := "Window"

; Control Fullscreen via xml settings
WindowedMode := If ( WindowedMode = "Window" ) ? "0" : ( If ( WindowedMode = "Fake Full Screen Mono" ) ? "1" : "2")
U3DPinballSettingsFile := emuPath . "\Config\options.ui.puo"
FileRead, U3DPinballXML, %U3DPinballSettingsFile%
RegExMatch(U3DPinballXML, "s)<combo name=" . """" . "displayModeCB" . """" . ">[0-9]", screenMode)
StringTrimRight, newScreenMode, screenMode, 1 
StringReplace, U3DPinballXML, U3DPinballXML,%screenMode%, % newScreenMode . (If ( Fullscreen = "true" ) ? "3" : WindowedMode)
FileDelete, %U3DPinballSettingsFile%
FileAppend, %U3DPinballXML%, %U3DPinballSettingsFile%, UTF-8

hideEmuObj := Object("Unit3D Pinball by French Pinball Team ahk_class UnityWndClass",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Unit3D Pinball by French Pinball Team ahk_class UnityWndClass")
WinWaitActive("Unit3D Pinball by French Pinball Team ahk_class UnityWndClass")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("Unit3D Pinball by French Pinball Team ahk_class UnityWndClass")
Return
