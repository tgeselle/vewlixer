MEmu := "Nebula"
MEmuV := "v2.25b"
MURL := ["http://nebula.emulatronia.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.2"
MCRC := "CBF0591C"
iCRC := "1E716C97"
MID := "635038268907246687"
MSystem := ["Sega Model 2","SNK Neo Geo","SNK Neo Geo AES"]
;----------------------------------------------------------------------------
; Notes:
; Hardware emulated: NeoGeo, CPS1, CPS2, Konami, PGM
; Under Video->Fullscreen, make sure to set your desired settings for fullscreen operation
; Under Emulation->Rom Directories, make sure all your dirs that you want Nebula to find your roms
; You can find the clrmame dat for nebula @ http://www.logiqx.com/Dats/
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","Nebula"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(romName)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

Loop { ; looping until nebula is done loading roms and the default window size changes
	emuPrimaryWindow.GetPos(,,emuW,emuH)
	res := (emuW . "x" . emuH)
	If (res != "416x358")
		Break
	TimerUtils.Sleep(50)
}
TimerUtils.Sleep(500) ; increase this is emu is not going fullscreen

If (Fullscreen = "true")
{	KeyUtils.SetKeyDelay(50)
	KeyUtils.Send("{Alt Down}{Enter Down}{Enter Up}{Alt Up}")	; nebula doesn't pick up fast keys, this method slows it down
}

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
