MEmu := "CDiEmu"
MEmuV := "v0.5.2 or v0.5.3 beta"
MURL := ["http://www.cdiemu.org/"]
MAuthor := ["djvj","brolly"]
MVersion := "2.0.3"
MCRC := "881E4013"
iCRC := "EFDCB23C"
MID := "635038268878712944"
MSystem := ["Philips CD-i"]
;----------------------------------------------------------------------------
; Notes:
; Place your bios in the rom subfolder. I think cdi910.rom is the latest revision.
; Games cannot be zipped. 0.5.2 supports bin, cdi, img, iso, nrg, raw, tao. 0.5.3 beta adds support for chd
; 0.5.3 beta won't work after January 2012, so make sure you activate the ChangeDate setting in RocketLauncherUI module settings if you are using this version
; Network paths for games are not supported from CLI, yet they work when using the built-in file browser. For some reason \\REMOTEPC\games\ gets translated to C:\REMOTEPC\games\
; The module will automatically handle network paths for you and load games through the built-in browser
; The script will manually turn off the toolbar, and enable stretch and fullscreen. The emulator does not support saving these between games. Emulator also doesn't support remapping of keys.
; Press Alt+W if you need to get the toolbar back.
; USA games will use 60hz via the "-ntsc" flag and European games -pal will use 50hz
; -savenvram is so the emu doesn't annoy you about saving nvram when exiting. It is only supported in v0.5.2, not in 0.5.3 beta
; Bezels work fine, but emu runs at super fast speed...unsure how to fix so far...disabled for now.
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("CD-i Emulator","CdiWndClass"))		; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle(dialogOpen,"#32770"))

fullscreen := moduleIni.Read("Settings","Fullscreen","true",,1)
changeDate := moduleIni.Read("Settings","ChangeDate","false",,1)
autoPlayDisc := moduleIni.Read("Settings","AutoPlayDisc","true",,1)

cdiFileProductVersion := SubStr(FileGetVersionInfo_AW(primaryExe.FileFullPath, "ProductVersion", "|"),1,5)	; get emu version from exe
If (changeDate = "true")
{
	runAsDateExe := new Emulator(ModuleExtensionsPath . "\RunAsDate.exe")
	runAsDateExe.CheckFile()
}

networkGamePath := ""
If StringUtils.RegExMatch(romPath,"\\\\[a-zA-Z0-9_]") {
	RLLog.Info("Module - This is a network game path, which CDiEmu cannot load through CLI. Loading game through the emu's file browser instead.")
	networkGamePath := 1
}

If !networkGamePath
	Params := "-start"

If (cdiFileProductVersion = "0.5.2")
	Params .= " -savenvram"		; this only works in 0.5.2

If (autoPlayDisc = "true")
	Params .= " -playcdi"

If StringUtils.InStr(romName, "(USA)")
	Params .= " -ntsc"
Else
	Params .= " -pal"

; BezelStart()
hideEmuObj := Object(emuOpenWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)

If (changeDate = "true") ;Change visible date to the emulator using RunAsDate
	runAsDateExe.Run(" 22\10\2011" . " """ . primaryExe.FileFullPath . """" . (If networkGamePath ? "" : " -disc """ . romPath . "\" . romName . romExtension . """") . " " . Params)
Else
	primaryExe.Run((If networkGamePath ? "" : " -disc """ . romPath . "\" . romName . romExtension . """") . " " . Params)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

emuPrimaryWindow.PostMessage("0x111","32796") ; disable toolbar
emuPrimaryWindow.PostMessage("0x111","32794") ; enable stretch

If networkGamePath {
	emuPrimaryWindow.PostMessage("0x111","32778") ; Open Browser
	emuOpenWindow.OpenROM(romPath . "\" . romName . romExtension)
	emuPrimaryWindow.WaitActive()
	emuPrimaryWindow.PostMessage("0x111","32774") ; Start Emulation
}

If (fullscreen = "true")
	emuPrimaryWindow.PostMessage("0x111","32797") ; enable Fullscreen
; emuPrimaryWindow.PostMessage("0x111","32811") ; disable Fullscreen (restore)

; BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	; If emulation is not paused internally, it sometimes skips scenes
	emuPrimaryWindow.PostMessage("0x111","32775") ; Pause
Return
RestoreEmu:
	emuPrimaryWindow.PostMessage("0x111","32779") ; Continue
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
