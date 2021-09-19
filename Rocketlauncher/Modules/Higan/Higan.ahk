MEmu := "Higan"
MEmuV := "v0.94 & v0.97"
MURL := ["http://byuu.org/higan/"]
MAuthor := ["djvj"]
MVersion := "2.0.7"
MCRC := "B6639EFE"
iCRC := "4D06E1E6"
MID := "635038268899159961"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom","Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Satellaview","Nintendo Super Famicom","Super Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; You can set your Exit key in the emu by going to Settings->Configuration Settings->Input->Hotkeys->Exit Emulator (not needed for this script)
; If you want to use xpadder, or joy2key, goto Settings->Advanced Settings and change Input to DirectInput
; Fullscreen is controlled via GUi when running the module directly
; Sram Support is controlled via GUi when running the module directly - If true, the module will backup srm files into a backup folder and copy them back to the 7z_Extract_Path so higan can load them upon launch. You really only need this if you use 7z support (and 7z_Delete_Temp is true) or your romPath is read-only.
; If you use 7z support, the games that require special roms (dsp/cx4), the roms needs to be inside the 7z with the game. Otherwise you will get an error about the missing rom.
; You can find the dsp roms needed for some games here: http://www.caitsith2.com/snes/dsp/ and a list of what games use what chip here: http://wiki.pocketheaven.com/index.php?title=SNES_games_with_special_chips
; On v0.97, ; higan stores its config in the emuPath and Bezels require fixedresmode, so set the scale you want in the emu which will control the size of the bezels.
; On older versions, higan stores its config @ C:\Users\%USER%\AppData\Roaming\higan
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("higan","phoenix_window"))		; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
sramSupport := moduleIni.Read("Settings", "SRAM_Support","true",,1)
bezelTopOffset := moduleIni.Read("Settings", "bezelTopOffset","51",,1)
bezelBottomOffset := moduleIni.Read("Settings", "bezelBottomOffset","31",,1)
bezelLeftOffset := moduleIni.Read("Settings", "bezelLeftOffset","7",,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset","7",,1)
legacyMode := moduleIni.Read("Settings", "Legacy_Mode","false",,1)

If (legacyMode = "true") {
	emuPrimaryWindow := new Window(new WindowTitle("higan","phoenix_window"))		; instantiate primary emulator window object
	BezelStart()
	hideEmuObj := Object(emuPrimaryWindow,1)

	; Set desired fullscreen mode
	HiganSettingsFile := new File(A_AppData . "\higan\settings.bml")
	HiganSettingsFile.CheckFile()
	HiganSettingsFile.Read()
	currentFullScreen := (InStr(higanCfg, "StartFullScreen: true") ? ("true") : ("false"))
	If (Fullscreen != "true" And currentFullScreen = "true") {
		StringUtils.Replace(HiganSettingsFile.Text, HiganSettingsFile.Text, "ShowStatusBar:true", "ShowStatusBar:false")
		SaveFile(HiganSettingsFile.Text)
	} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
		StringUtils.Replace(HiganSettingsFile.Text, HiganSettingsFile.Text, "ShowStatusBar:false", "ShowStatusBar:true")
		SaveFile(HiganSettingsFile.Text)
	}
} Else {
	emuPrimaryWindow := new Window(new WindowTitle(,"hiroWindow"))		; instantiate primary emulator window object
	BezelStart("FixResMode")
	hideEmuObj := Object(emuPrimaryWindow,1)

	If (bezelEnabled = "true") {
		HiganSettingsFile := new File(emuPath . "\settings.bml")
		HiganSettingsFile.CheckFile()
		HiganSettingsFile.Read()
		currentStatusBar := InStr(HiganSettingsFile.Text, "ShowStatusBar:true") ? "true" : "false"
		If (currentStatusBar = "true") {
			StringUtils.Replace(HiganSettingsFile.Text, HiganSettingsFile.Text, "ShowStatusBar:true", "ShowStatusBar:false")
			SaveFile(HiganSettingsFile.Text)
		} Else If (currentStatusBar = "false") {
			StringUtils.Replace(HiganSettingsFile.Text, HiganSettingsFile.Text, "ShowStatusBar:false", "ShowStatusBar:true")
			SaveFile(HiganSettingsFile.Text)
		}
	}

	If (Fullscreen = "true")
		params := " --fullscreen"
}

7z(romPath, romName, romExtension, sevenZExtractPath)

 ; copy backed-up srm files to folder where rom is located
If (sramSupport = "true") {
	RAMFile := new File(romPath . "\" romName . romExtension . "\save.ram")
	RAMBackupFile := new File(emuPath . "\srm\MSU1\" . romName . "\save.ram")
	If RAMBackupFile.Exist()
		RAMBackupFile.Copy(romPath . "\" . romName . romExtension,1) ;overwriting existing ram with backup if it exists in destination folder
	SRMFile := new File(romPath . "\" . romName . ".srm")
	SRMBackupFile := new File(emuPath . "\srm\" . romName . ".srm")
	If SRMBackupFile.Exist()
		SRMBackupFile.Copy(romPath,1) ; overwriting existing srm with backup if it exists in destination folder
}

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run((If params ? params : "") . " """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

; emuPrimaryWindow.Move(0, 0) ; when going from fullscreen to window, higan still has its menubar hidden, uncomment this to access it
; emuPrimaryWindow.MenuSelectItem("Super Famicom", "Port 2", "Justifier")
primaryExe.Process("WaitClose")

 ; Back up srm file so it is available for next launch
If (sramSupport = "true") {
	If !RAMBackupFile.Exist("folder")
		RAMBackupFile.CreateDir() ; create ram folder if it doesn't exist
	RAMFile.Copy(RAMBackupFile.FilePath,1)
	If !SRMBackupFile.Exist("folder")
		SRMBackupFile.CreateDir() ; create srm folder if it doesn't exist
	SRMFile.Copy(SRMBackupFile.FilePath,1)
}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


SaveFile(text) {
	HiganSettingsFile.Delete()
	HiganSettingsFile.Append(text)
}

BezelLabel:
	disableHideTitleBar := "true"
	disableHideToggleMenu := "true"
	disableHideBorder := "true"
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
