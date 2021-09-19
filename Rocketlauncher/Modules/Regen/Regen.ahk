MEmu := "Regen"
MEmuV := "v0.97"
MURL := ["http://aamirm.hacking-cult.org/www/regen.html"]
MAuthor := ["djvj"]
MVersion := "2.0.2"
MCRC := "715A91C8"
iCRC := "1E716C97"
MID := "635038268921698714"
MSystem := ["Sega Genesis","Sega Mega Drive"]
;----------------------------------------------------------------------------
; Notes:
; Set your fullscreen resolution by going to Video->Fullscreen Resolution
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Regen","Regen"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

regenINI := new IniFile(emuPath . "\regen.ini")
regenINI.CheckFile()

BezelStart("FixResMode")

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()

 ; Go fullscreen
If (Fullscreen = "true")
{	TimerUtils.Sleep(100)	; just in case some lag is needed
	emuPrimaryWindow.MenuSelectItem("Video","Enter Fullscreen")
	; KeyUtils.Send("!{Enter}")	; alt method to go fullscreen
}

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	KeyUtils.Send("!{Enter}")
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	KeyUtils.Send("!{Enter}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
