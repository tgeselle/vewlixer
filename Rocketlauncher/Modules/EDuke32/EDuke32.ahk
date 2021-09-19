MEmu := "EDuke32"
MEmuV := "v5.307"
MURL := ["http://eduke32.com/"]
MAuthor := ["10cold","djvj"]
MVersion := "0.6"
MCRC := "9C8DF2A6"
iCRC := "535F9E27"
MID := "635835606059869427"
MSystem := ["Duke Nukem","PC Games"]
;--------------------------------------------------------------------------------------
; Notes:
; More info about what this module is for here: http://www.rlauncher.com/forum/showthread.php?1532-EDuke32-Module-Help
; If you keep your games archived, you need to at least set Skip Checks to Rom Extension 
; because there is no rom extension like a normal rom would have.
; For games archived, pack them with all files necessary to work together
; with also the EDuke32 files. Create an entry on "Duke Nukem.ini" file with all parameters
; necessary to open the game like the examples here:
;  Examples:
;	[Attrition] #Working
;	params=-game_dir attrition -hatt_hrp.def -cachesize 131072
;	[Platoon] #Working
;	params=-gPlatoon.grp -xPlatoon.gam %1 %2 %3 %4 %5 %6
;	[WG Realms]
;	params=-gWGR.GRP -jDukePlus -hdukeplus.def -xWGRealmsPlus.con
; The module adds automaticaly the Fullscreen setting (when not specified) and also the -nosetup
; to go directly to the game.
; This way the module will open the EDuke32 copy inside the game folder.
; Don't forget to add .bat and the archived extension on your rom extension setting.
; Exit button is not working yet. need some work on that.
;--------------------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "" romName "" , "Fullscreen", "true",,1)
params := IniReadCheck(settingsFile, "" romName "", "params","",,1)
showLauncher := IniReadCheck(settingsFile, "" romName "", "showlauncher","false",,1)
showSetupStatus := If (showLauncher = "true") ? " -setup" : " -nosetup"

hideEmuObj := Object("EDuke32 ahk_class #32770",0,"EDuke32 ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

eduke32cfg := CheckFile(romPath . "\eduke32.cfg")
If bezelEnabled = true
{	BezelStart()
	edukeWidth := Round(bezelScreenWidth)
	edukeHeight := Round(bezelScreenHeight)
	IniWrite, 0, %eduke32cfg%, Screen Setup, ScreenMode
	IniWrite, %edukeWidth%, %eduke32cfg%, Screen Setup, ScreenWidth
	IniWrite, %edukeHeight%, %eduke32cfg%, Screen Setup, ScreenHeight
}

IniRead, currentFullScreen, %eduke32cfg%, Screen Setup, ScreenMode
If (currentFullScreen = 0) and (fullscreen = "true") {
	IniWrite, 1, %eduke32cfg%, Screen Setup, ScreenMode
	IniWrite, %A_ScreenWidth%, %eduke32cfg%, Screen Setup, ScreenWidth
	IniWrite, %A_ScreenHeight%, %eduke32cfg%, Screen Setup, ScreenHeight
} Else If (currentFullScreen = 1) and (fullscreen = "false") {
	IniWrite, 0, %eduke32cfg%, Screen Setup, ScreenMode
}

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Err := Run("eduke32.exe" . " """ . params . """" . showSetupStatus, romPath, "UseErrorLevel", game_PID)
If Err
	ScriptError("Failed to launch " . romName)

WinGetActiveTitle, gameTitle
Log("Module - Active window is currently: " . gameTitle)

WinWait("EDuke32 ahk_class SDL_app")
WinWaitActive("EDuke32 ahk_class SDL_app")

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
	Process("Close", executable)	; this is the only thing that can close the application
Return
