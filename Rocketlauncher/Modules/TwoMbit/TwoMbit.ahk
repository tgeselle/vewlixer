MEmu := "TwoMbit"
MEmuV := "v1.0.5"
MURL := ["http://sourceforge.net/projects/twombit/"]
MAuthor := ["djvj"]
MVersion := "2.0.2"
MCRC := "A65CB5D"
iCRC := "E6F44714"
MID := "635038268928134070"
MSystem := ["Sega Master System","Sega Game Gear"]
;----------------------------------------------------------------------------
; Notes:
; Set your fullscreen resolution by starting the emu manually and going to Video->Fullscreen
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(romName,"QWidget"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
bezelTopOffset := moduleIni.Read("Settings", "bezelTopOffset","51",,1)
bezelBottomOffset := moduleIni.Read("Settings", "bezelBottomOffset","8",,1)
bezelLeftOffset := moduleIni.Read("Settings", "bezelLeftOffset","8",,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset","8",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart("FixResMode")

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()		; TwoMbit puts the emuPath and romName in the WinTitle 
emuPrimaryWindow.WaitActive()

If (fullscreen = "true")
{	TimerUtils.Sleep(100)
	KeyUtils.Send("!{Enter}")
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


BezelLabel:
	disableHideTitleBar := "true"
	disableHideToggleMenu := "true"
	disableHideBorder := "true"
Return

HaltEmu:
	KeyUtils.Send("!{Enter}")
	TimerUtils.Sleep(200)
Return
RestoreEmu:
	KeyUtils.Send("!{Enter}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
