MEmu := "Fceux"
MEmuV := "r2699"
MURL := ["http://www.fceux.com/web/home.html"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "F8F251F"
iCRC := ""
MID := "635038268889762139"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System"]
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen, goto Config->Video and check Enter full screen mode after game is loaded. Leave Full Screen unchecked.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","FCEUXWindowClass"))	; instantiate primary emulator window object

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
