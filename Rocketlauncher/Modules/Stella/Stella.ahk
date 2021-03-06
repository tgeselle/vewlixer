MEmu := "Stella"
MEmuV := "v4.0"
MURL := ["http://stella.sourceforge.net/"]
MAuthor := ["djvj","bleasby"]
MVersion := "2.0.4"
MCRC := "BF858702"
iCRC := "CB43D314"
MID := "635038268926052339"
MSystem := ["Atari 2600"]
;----------------------------------------------------------------------------
; Notes:
; If you want to use a hotkey to swap disks, assign one in RocketLauncherUI for this module
; Stella stores its config @ C:\Users\USERNAME\AppData\Roaming\Stella
; CLI docs @ emuPath\docs\index.html#CommandLine
;
; In order for Stella to load the EEPROM data for AtariVox and SaveKey support from its own folder 
; you need to create a text file named basedir.txt in the emulator folder and write the path to that 
; folder inside it. This info is more detailed in chapter 7 of the docs mentioned above.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()
 
settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
; FullResolution := IniReadCheck(settingsFile, "Settings", "FullResolution","autoHL",,1)	; If autoHL, RocketLauncher will set the fullscreenres to your current monitor res. If auto, Stella will try to use the maximum resolution for your screen. Otherwise set your desired res here WxH (ex 1920x1200)
screenZoom := IniReadCheck(settingsFile, "Settings", "ScreenZoom","autoHL",,1)  		; If autoHL, RocketLauncher will set the zoom to maximize your gameplay area. Otherwise set your desired zoom as zoom2x, zoom3x, zoom4x or zoom5x. 
centerScreen :=  IniReadCheck(settingsFile, "Settings", "CenterScreen","true",,1)		; If true, center your gameplay screen
DiskSwapKey := IniReadCheck(settingsFile, "Settings", "DiskSwapKey",,,1)				; swaps disk

bezelTopOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset","31",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Bottom_Offset","8",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Left_Offset","8",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Right_Offset","8",,1)
BezelStart("fixResMode")

hideEmuObj := Object("Stella ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := " -fullscreen " . (If fullscreen = "true" ? 1 : 0)
centerScreen := " -center " . (If centerScreen = "true" ? 1 : 0)

; fullResolution := If (FullResolution="autoHL") ? (A_ScreenWidth . "x" . A_ScreenHeight) : (If FullResolution = "auto" ? "auto" : FullResolution)
If (screenZoom="autoHL") {
	gameRes := IniReadCheck(A_ScriptDir . "\Settings\" systemName . "\resolutions.ini", dbname, "Resolution","notFound",,1)  
	StringSplit, res, gameRes, x
	If (A_ScreenWidth >= res1*6) and (A_ScreenHeight >= res2*6)
		screenZoom := 6
	Else If (A_ScreenWidth >= res1*5) and (A_ScreenHeight >= res2*5)
		screenZoom := 5
	Else If (A_ScreenWidth >= res1*4) and (A_ScreenHeight >= res2*4)
		screenZoom := 4
	Else If (A_ScreenWidth >= res1*3) and (A_ScreenHeight >= res2*3)
		screenZoom := 3
	Else 
		screenZoom := 2
}

If (screenZoom)
	screenZoom := " -tia.zoom " . screenZoom

If DiskSwapKey
	XHotKeywrapper(DiskSwapKey,"DiskSwap")

HideEmuStart()

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . fullscreen . centerScreen . screenZoom . " """ . romPath . "\" . romName . romExtension . """  ", emuPath)

WinWait("Stella ahk_class SDL_app")
WinWaitActive("Stella ahk_class SDL_app")
Sleep, 700 ; Necessary otherwise your Front End window flashes back into view

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

DiskSwap:
	Send, {RCtrl down}{R down}{R up}{RCtrl up} ; need to send the keys slow so stella recognizes them
Return

RestoreEmu:
	Send, {Esc down}{Esc up}
Return

CloseProcess:
	FadeOutStart()
	WinClose("Stella ahk_class SDL_app")
Return
