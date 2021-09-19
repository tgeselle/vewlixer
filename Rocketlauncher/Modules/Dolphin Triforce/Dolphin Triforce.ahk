MEmu := "Dolphin Triforce"
MEmuV := "v4.0-315"
MURL := ["http://forums.dolphin-emu.org/Thread-triforce-mario-kart-arcade-gp2"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "8EE4885E"
iCRC := "8C524B53"
MID := "635038268885018176"
MSystem := ["Sega Triforce"]
;----------------------------------------------------------------------------
; Notes:
; Dolphin Triforce builds can be found here: https://dolphin-emu.org/download/list/Triforce/
; Go here for Mario Kart GP 2 setup: http://forums.dolphin-emulator.com/showthread.php?tid=23763
; If you get an error that you are missing a vcomp100.dll, install Visual C++ 2010: http://www.microsoft.com/download/en/details.aspx?id=14632
; Also make sure you are running latest directx: http://www.microsoft.com/downloads/details.aspx?FamilyID=2da43d38-db71-4c1b-bc6a-9b6652cd92a3
; Render to Main Window needs to be unchecked. This is done for you if you forget.
; If you get Unknown DVD Command errors, the game is not compatible with the emulator. Try a different game or emulator version.
; On the emulator GUI go to Options/Configure/Interface and uncheck "Confirm on Stop" otherwise RL won't be able to cleanly shutdown the emulator.
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Dolphin","wxWindowNR"))		; instantiate primary emulator window object
emuGameWindow := new Window(new WindowTitle("FPS","wxWindowNR"))

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
hideMouse := moduleIni.Read("Settings", "HideMouse","true",,1) ; hides mouse cursor in emu
renderToMain := moduleIni.Read(romName . "|Settings", "RenderToMain","false",,1)
sendF1 := moduleIni.Read(romName, "SendF1","false",,1)

BezelStart()

dolphinCurrentINI := new IniFile(A_MyDocuments . "\Dolphin Emulator\Config\Dolphin.ini")	; location of Dolphin.ini for v4.0+
dolphinLegacyINI := new IniFile(emuPath . "\User\Config\Dolphin.ini")	; location of Dolphin.ini prior to v4.0
If dolphinLegacyINI.Exist()
	dolphinINI := dolphinLegacyINI
Else
	dolphinINI := dolphinCurrentINI
dolphinINI.CheckFile("Could not find your Dolphin.ini in either of these folders. Please run Dolphin manually first to create it.`n" . dolphinLegacyINI.FileFullPath . "`n" . dolphinCurrentINI.FileFullPath)

fullscreen := If (Fullscreen = "true") ? "True" : "False"

; Compare existing settings and if different than desired, write them to the emulator's ini
dolphinINI.Write(fullscreen, "Display", "Fullscreen", 1)
dolphinINI.Write(renderToMain, "Display", "RenderToMain", 1)
dolphinINI.Write(hideMouse, "Interface", "HideCursor", 1)
dolphinINI.Write(6, "Core", "SerialPort1", 1)	; this puts the AM-Baseboard into the serial port. If previous launch was Gamecube or Wii, BBU would be set here and would result in Unknown DVD command errors

hideEmuObj := Object(emuGameWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" /b /e """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If (sendF1 = "true") {
	TimerUtils.Sleep(3000)
	KeyUtils.Send("{F1}")
}

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
	emuGameWindow.Close() ; this needs to close the window the game is running in otherwise dolphin crashes on exit
Return
