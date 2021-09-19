MEmu := "puNES"
MEmuV := "v0.94"
MURL := ["http://forums.nesdev.com/viewtopic.php?t=6928"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "83A72B1B"
iCRC := "1E716C97"
MID := "635038268920657843"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom"]
;----------------------------------------------------------------------------
; Notes:
; Portable mode no longer seems to work in 0.94
; Emu saves settings in C:\Users\USERNAME\Documents\puNES
; Emu seems a bit slow when responding to bezel support, leaving it disabled for now as it needs work
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("puNES","QWidget"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)
; BezelStart("FixResMode")

fullscreen := If Fullscreen = "true" ? " -u yes" : ""

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(fullscreen . " """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

; BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
