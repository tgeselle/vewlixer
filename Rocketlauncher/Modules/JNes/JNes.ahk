MEmu := "JNes"
MEmuV := "v1.1"
MURL := ["http://www.jabosoft.com/categories/1"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "1E62A232"
MID := "635038268900200827"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom"]
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen, goto Options->Video->Display and check Enter full screen mode after game is loaded. Leave Full Screen unchecked.
; If you have any issues with the emu not showing up, remove the Hide at the end of the run line. It's there to give the emu a cleaner launch
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","Jnes Window"))	; instantiate primary emulator window object

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
