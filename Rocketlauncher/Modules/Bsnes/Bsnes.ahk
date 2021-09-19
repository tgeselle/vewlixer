MEmu := "Bsnes"
MEmuV := "v0.87"
MURL := ["http://byuu.org/bsnes/"]
MAuthor := ["djvj"]
MVersion := "2.0.4"
MCRC := "11A27D67"
iCRC := "77DA7529"
MID := "635038268877141627"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom""Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Satellaview","Nintendo Super Famicom","Super Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; You can set your Exit key in the emu by going to Settings->Configuration Settings->Input->Hotkeys->Exit Emulator (not needed for this script)
; If you want to use xpadder, or joy2key, goto Settings->Advanced Settings and change Input to DirectInput
; Fullscreen is controlled via GUi when running the module directly
; Sram Support is controlled via GUi when running the module directly - If true, the module will backup srm files into a backup folder and copy them back to the 7z_Extract_Path so bsnes can load them upon launch. You really only need this if you use 7z support (and 7z_Delete_Temp is true) or your romPath is read-only.
; If you use 7z support, the games that require special roms (dsp/cx4), the roms needs to be inside the 7z with the game. Otherwise you will get an error about the missing rom.
; You can find the dsp roms needed for some games here: http://www.caitsith2.com/snes/dsp/ and a list of what games use what chip here: http://www.pocketheaven.com/ph/wiki/SNES_games_with_special_chips
; bsnes stores its config @ C:\Users\%USER%\AppData\Roaming\bsnes
;
; Defining per-game controller types:
; In the module ini, set Controller_Reassigning_Enabled to true
; Default_P1_Controller and Default_P2_Controller should be set to the controller type you normally use for games not listed in the ini
; Make a new ini section with the name of your rom in your database, for example [Super Scope 6 (USA)]
; Under this section you can have 2 keys, P1_Controller and P2_Controller
; For P1_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Serial USART
; For P2_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Super Scope, 5=Justifier, 6=Dual Justifiers, 7=Serial USART
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","phoenix_window"))	; instantiate primary emulator window object

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
sramSupport := moduleIni.Read("Settings", "sramSupport","false",,1)
controllerReassigningEnabled := moduleIni.Read("Settings", "Controller_Reassigning_Enabled","false",,1)
defaultP1Controller := moduleIni.Read("Settings", "Default_P1_Controller",1,,1)
defaultP2Controller := moduleIni.Read("Settings", "Default_P2_Controller",1,,1)
bezelTopOffset := moduleIni.Read("Settings", "bezelTopOffset",51,,1)
bezelBottomOffset := moduleIni.Read("Settings", "bezelBottomOffset",31,,1)
bezelLeftOffset := moduleIni.Read("Settings", "bezelLeftOffset",7,,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset",7,,1)
p1Controller := moduleIni.Read(romName, "P1_Controller",,,1)
p2Controller := moduleIni.Read(romName, "P2_Controller",,,1)

BezelStart()

; Set desired fullscreen mode
bsnesFile := new File(A_AppData . "\bsnes\settings.cfg")
bsnesFile.CheckFile()
bsnesFile.Read()
currentFullScreen := (StringUtils.Contains(bsnesFile.Text, "Video::FullScreenMode = 1") ? "true" : "false")
If (Fullscreen != "true" And currentFullScreen = "true") {
	bsnesFile.Text := StringUtils.Replace(bsnesFile.Text,"Video::FullScreenMode = 1","Video::FullScreenMode = 0")
	bsnesFile.Text := StringUtils.Replace(bsnesFile.Text,"Video::StartFullScreen = true","Video::StartFullScreen = false")
	If (controllerReassigningEnabled != "true")	; file will be saved later it true
		bsnesFile.Save()
} Else If (Fullscreen = "true" And currentFullScreen = "false") {
	bsnesFile.Text := StringUtils.Replace(bsnesFile.Text,"Video::FullScreenMode = 0","Video::FullScreenMode = 1")
	bsnesFile.Text := StringUtils.Replace(bsnesFile.Text,"Video::StartFullScreen = false","Video::StartFullScreen = true")
	If (controllerReassigningEnabled != "true")	; file will be saved later it true
		bsnesFile.Save()
}

; copy backed-up srm files to folder where rom is located
If (sramSupport = "true") {
	sramBackupFile := new File(emuPath . "\srm\" . romName . ".srm")
	sramRomFile := new File(romPath . "\" . romName . ".srm")
	If sramBackupFile.Exist()
		sramBackupFile.Copy(sramRomFile.FilePath,1) ; overwriting existing srm with backup if it exists in destination folder
}

 ; Allows you to set on a per-rom basis the controller type plugged into controller ports 1 and 2
If (controllerReassigningEnabled = "true")
{	
	bsnesTempCfg := bsnesFile.Text	; required for loop to work
	Loop, Parse, bsnesTempCfg, `n
	{
		If StringUtils.Contains(A_LoopField,"SNES::Controller::Port1",0)	; do not log
			newCfg .= "SNES::Controller::Port1 = " . (If p1Controller ? p1Controller : defaultP1Controller) . "`r`n"	; sets controls for P1 to rom's P1 control type if exists, else sets to default P1 controls
		Else If StringUtils.Contains(A_LoopField,"SNES::Controller::Port2",0)
			newCfg .= "SNES::Controller::Port2 = " . (If p2Controller ? p2Controller : defaultP2Controller) . "`r`n"	; sets controls for P2 to rom's P2 control type if exists, else sets to default P2 controls
		Else
			newCfg .= If A_LoopField = "" ? "" : A_LoopField . "`n"
	}
	bsnesFile.Text := newCfg	; overwrite object's text
	bsnesFile.Save()
}

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

; WinMove, 0, 0 ; when going from fullscreen to window, bsnes still has its menubar hidden, uncomment this to access it
primaryExe.Process("WaitClose")

 ; Back up srm file so it is available for next launch
If (sramSupport = "true")
{
	If !sramBackupFile.Exist("folder")	; check if srm backup folder exists
		sramBackupFile.CreateDir()	; create srm folder if it doesn't exist
	sramRomFile.Copy(sramBackupFile.FilePath,1)
}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


BezelLabel:
	disableHideTitleBar := "true"
	disableHideToggleMenu := "true"
	disableHideBorder := "true"
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
