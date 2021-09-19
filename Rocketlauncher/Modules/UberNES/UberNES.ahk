MEmu := "UberNES"
MEmuV := "v2011.0"
MURL := ["http://www.ubernes.com/"]
MAuthor := ["ghutch92"]
MVersion := "2.0.1"
MCRC := "53ADBDFF"
iCRC := "B7930DC6"
MID := "635038268929184951"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom"]
;----------------------------------------------------------------------------
; Notes:
; All emulator settings will be have to set through the emulator by opening it manually.
; If you want fullscreen you will need to enable it manually through the emulator options in the gui as cfg file is not plain text.
; The Settings in the emulator can be found under tools -> options.
; It's recommended thate fade be enabled for this emulator.
; fullscreen module setting does not control emu's fullscreen setting. Only set it to match what you use in the emu.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","UberNESClass"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
TimerUtils.Sleep(2000)	; prevent window from flashing into view (only works with fade)

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu:
	If fullscreen = "true")
		KeyUtils.Send("!{Enter}")
Return 
RestoreEmu: 
	emuPrimaryWindow.Activate()
	If fullscreen = "true") {
		TimerUtils.Sleep(200)
		KeyUtils.Send("!{Enter}")
	}
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
