MEmu := "ColEm"
MEmuV := "v3.6"
MURL := ["http://fms.komkon.org/ColEm/"]
MAuthor := ["djvj"]
MVersion := "1.0"
MCRC := "35D399B3"
iCRC := "EB44FC76"
MID := "635988791288546912"
MSystem := ["ColecoVision"]
;---------------------------------------------------------------------------- 
; Notes:
; Emu stores its settings in the registry @ HKEY_CURRENT_USER\Software\EMUL8\ColEm
;---------------------------------------------------------------------------- 
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)						; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("ColEm","ColEm"))	; instantiate primary emulator window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

currentFullScreen := Registry.Read("HKCU", "Software\EMUL8\ColEm", "FullScreen") ;, "Auto")
If (Fullscreen != "true" And currentFullScreen = 1)
	Registry.Write("REG_DWORD", "HKCU", "Software\EMUL8\ColEm", "FullScreen", 0)
Else If (Fullscreen = "true" And currentFullScreen = 0)
	Registry.Write("REG_DWORD", "HKCU", "Software\EMUL8\ColEm", "FullScreen", 1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart()
HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
RestoreEmu:
	If (fullscreen = "true")
		KeyUtils.Send("!Enter")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
