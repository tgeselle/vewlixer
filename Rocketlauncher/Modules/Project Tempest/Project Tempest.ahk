MEmu := "Project Tempest"
MEmuV := "v0.95"
MURL := ["http://pt.emuunlim.com/"]
MAuthor := ["djvj","faahrev"]
MVersion := "2.0.4"
MCRC := "13E5E480"
iCRC := "109E182B"
MID := "635224813748790881"
MSystem := ["Atari Jaguar","Atari Jaguar CD"]
;----------------------------------------------------------------------------
; Notes:
; Fullscreen mode controlled in RocketLauncherUI
; In the emu's gui, keep fullscreen off, otherwise the module will put it to windowed on launch.
; Emu stores joypad config in registry (64-bit OS) @ HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Project Tempest
; Some games may not work correctly with PT and will popup with an address box. If this happens, try a different emu like Virtual Jaguar.
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Project Tempest","PT"))		; instantiate primary emulator window object
emuDownloadWindow := new Window(new WindowTitle("download"))	

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
controlDelay := moduleIni.Read("Settings", "ControlDelay","40",,1)		; raise this if the module is getting stuck using SelectGameMode 1
keyDelay := moduleIni.Read("Settings", "KeyDelay","-1",,1)				; raise this if the module is getting stuck using SelectGameMode 2

BezelStart()

7z(romPath, romName, romExtension, sevenZExtractPath)

MiscUtils.SetControlDelay(controlDelay)
KeyUtils.SetKeyDelay(keyDelay)
MiscUtils.SetWinDelay(10)

primaryExe.Run()

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If (romExtension = ".cdi") {
	emuOpenWindow := new Window(new WindowTitle("Open CD Image","#32770"))
	hideEmuObj := Object(emuOpenWindow,0,emuPrimaryWindow,1)
	emuPrimaryWindow.MenuSelectItem("File", "Open CD Image")
	HideAppStart(hideEmuObj,hideEmu)
	emuOpenWindow.WaitActive()
} Else {
	emuOpenWindow := new Window(new WindowTitle("Open ROM File","#32770"))
	hideEmuObj := Object(emuOpenWindow,0,emuPrimaryWindow,1)
	emuPrimaryWindow.MenuSelectItem("File", "Open ROM")
	HideAppStart(hideEmuObj,hideEmu)
	emuOpenWindow.WaitActive()
}

emuOpenWindow.OpenROM(romPath . "\" . romName . romExtension)
emuPrimaryWindow.WaitActive()

;Some roms might display download screen
If emuDownloadWindow.Active()
{
	emuDownloadWindow.CreateControl("Cancel")		; instantiate new control for Cancel
	emuDownloadWindow.GetControl("Cancel").Click()
	Goto Error
}

If (fullscreen = "true")
	KeyUtils.Send("{Esc}")

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


Error:
    RLLog.Error("Module - There was an error. Try running outside RocketLauncher to see the error.")
    Goto CloseProcess
Return                                                                                

HaltEmu:
	KeyUtils.Send("{Esc}")
	TimerUtils.Sleep(200)
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	KeyUtils.Send("{Esc}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
