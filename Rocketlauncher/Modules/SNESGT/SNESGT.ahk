MEmu := "SNESGT"
MEmuV := "v0.230 beta 7"
MURL := ["http://gigo.retrogames.com/","http://gigo.retrogames.com/bbs/c-board.cgi?cmd=one;no=2205"]
MAuthor := ["djvj","bleasby"]
MVersion := "1.0.1"
MCRC := "B66757D3"
iCRC := "565CFAD"
MID := "635986877402729496"
MSystem := ["Super Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; You can find the beta 7 edition here: http://gigo.retrogames.com/bbs/c-board.cgi?cmd=one;no=2205
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)						; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("i)SNESGT","i)ATL:"))		; instantiate primary emulator window object. Using RegEx as class changes each emu version.

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
bezelTopOffset := moduleIni.Read("Settings", "Bezel_Top_Offset","50",,1)
bezelBottomOffset := moduleIni.Read("Settings", "Bezel_Bottom_Offset","8",,1)
bezelRightOffset := moduleIni.Read("Settings", "Bezel_Right_Offset", "8",,1)
bezelLeftOffset := moduleIni.Read("Settings", "Bezel_Left_Offset", "8",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart()
HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait(,,"RegEx")
emuPrimaryWindow.WaitActive(,,"RegEx")

If (fullscreen = "true")
	emuPrimaryWindow.MenuSelectItem("Options","Display","Switch Screen Mode",,,,,"RegEx")

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	disableSuspendEmu := true
RestoreEmu:
	If (fullscreen = "true")
		emuPrimaryWindow.MenuSelectItem("Options","Display","Switch Screen Mode",,,,,"RegEx")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close(,"RegEx")
Return

BezelLabel:
	disableHideTitleBar := "true"
	disableHideToggleMenu := "true"
	disableHideBorder := "true"
Return
