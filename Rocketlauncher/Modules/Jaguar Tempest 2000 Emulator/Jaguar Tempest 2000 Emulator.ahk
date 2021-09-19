MEmu := "Jaguar Tempest 2000 Emulator"
MEmuV := "v0.06b"
MURL := ["http://www.yakyak.org/viewtopic.php?f=5&t=41691"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "5FD79D8E"
iCRC := "1E716C97"
MID := "635038268899690393"
MSystem := ["Atari Jaguar"]
;----------------------------------------------------------------------------
; Notes:
; This emulator emulates Tempest 2000 much better than Project Tempest
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Tempest 2000","SampleClass"))		; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

BezelStart()

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" " . romPath . "\" . romName . romExtension, (If fullscreen = "true" ? "Hide" : ""))	; must not be wrapped in quotes otherwise emu doesn't launch game

errorLvl := emuPrimaryWindow.Wait(5)	; wait 5 seconds
If errorLvl
	ScriptError("There was a problem launching " . MEmu . ".`nPlease try again as sometimes the emulator doesn't start.")
emuPrimaryWindow.WaitActive()

If (fullscreen = "true")
	KeyUtils.Send("{F1}")	; this sets fullscreen

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
