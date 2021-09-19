MEmu := "Emu7800"
MEmuV := "v1.8"
MURL := ["http://emu7800.sourceforge.net/"]
MAuthor := ["brolly","djvj"]
MVersion := "2.0.3"
MCRC := "E12DB39E"
iCRC := "1E716C97"
MID := "635038268887690414"
MSystem := ["Atari 7800","Atari 2600"]
;----------------------------------------------------------------------------
; Notes:
; Emu does not support zipped roms through CLI. So enable 7z or keep your roms uncompressed.
; This module supports both the Classic and D2D versions
; On the D2D version if you need to access the settings panel, press H to bring up the HUD
;
; If you are using the Emu7800 Classic version Lightgun emulation (using mouse) will only work on in Fullscreen DirectX mode.
; Settings for the Classic version are stored in:
; %userprofile%\AppData\Local\IsolatedStorage\[random path nodes]\AssemFiles\EMU7800.configuration
; Settings for the D2D version are stored in:
; %userprofile%\AppData\Local\EMU7800.<random guid>\
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

d2dMode := "false"
windowTitle := "EMU7800 ahk_class EMU7800.DirectX.HostingWindow"
if executable contains d2d
{
	d2dMode := "true"
	windowTitle := "EMU7800 ahk_class EMU7800"
}

BezelStart()
hideEmuObj := Object(windowTitle,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

VideoMode := (If Fullscreen = "true" ? "DirectX (DX9 Fullscreen)" : "DirectX (DX9)")

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If (d2dMode = "false")
	Run(executable . " """ . romPath . "\" . romName . romExtension . """ """ . VideoMode . """", emuPath)
Else
	Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait(windowTitle)
WinWaitActive(windowTitle)

If (d2dMode = "true" && Fullscreen = "true")
	MaximizeWindow(windowTitle)

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
	WinClose(windowTitle)
Return
