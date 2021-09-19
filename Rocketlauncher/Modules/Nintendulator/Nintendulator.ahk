MEmu := "Nintendulator"
MEmuV := "v0.975 Beta"
MURL := ["http://www.qmtpro.com/~nes/nintendulator/"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "C884E64B"
iCRC := "1E716C97"
MID := "635038268908817987"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom"]
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped as .nes/.fds/.unif/.unf files, zips are not supported
; Turn on Auto-Run under the File menu
; Emulator stores its config in the registry and the rest in C:\Users\%USER%\AppData\Roaming\Nintendulator
; In the registry @ HKEY_USERS\S-1-5-21-440413192-1003725550-97281542-1001\Software\Nintendulator
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","NINTENDULATOR"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)
BezelStart()

If StringUtils.Contains(romExtension,"\.zip|\.7z|\.rar")
	ScriptError(MEmu . " does not support compressed roms. Please enable 7z support in RocketLauncherUI to use this module/emu.")

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """",If fullscreen = "true" ? "Hide" : "")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()

If (Fullscreen = "true")
	KeyUtils.Send("!{ENTER}")	; go fullscreen

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	disableSuspendEmu := "true"
	KeyUtils.Send("!{Enter}")
	TimerUtils.Sleep(200)
	KeyUtils.Send("{F3}")
	TimerUtils.Sleep(200)
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	KeyUtils.Send("!{Enter}")
	KeyUtils.Send("{F2}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
