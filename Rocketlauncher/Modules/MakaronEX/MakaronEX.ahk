MEmu := "MakaronEX"
MEmuV := "v4.1"
MURL := ["http://www.emu-land.net/consoles/dreamcast/emuls/windows"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "BC563838"
iCRC := "2B4EA0AE"
MID := "635038268902883049"
MSystem := ["Sega Dreamcast","Sega Naomi"]
;----------------------------------------------------------------------------
; Notes:
; Set fullscreen via the variable below
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("MakaronEX","TForm1"))		; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle(dialogOpen . " ahk_class #32770","#32770"))

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
enable2Players := moduleIni.Read("Settings", "Enable2Players","true",,1)

hideEmuObj := Object(emuOpenWindow,0,emuPrimaryWindow,1)

If StringUtils.Contains(systemName,"naomi")
	makINI := new IniFile(emuPath . "\Naomi\Naomi.ini")
Else If StringUtils.Contains(systemName,"dreamcast|dc")
	makINI := new IniFile(emuPath . "\Dreamcast\Makaron.ini")
Else
	ScriptError(systemName . " is not a recognized (aka supported) System Name for this module")
makINI.CheckFile()

currentFullScreen := makINI.Read("Settings","fullscreen")

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If (fullscreen != "true" && currentFullScreen = 1)
	makINI.Write(0,"Settings","fullscreen")
Else If (fullscreen = "true" && currentFullScreen = 0)
	makINI.Write(1,"Settings","fullscreen")

HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run("",(If InStr(systemName,"naomi") ? "hide":""))

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If StringUtils.Contains(systemName,"naomi")
{	; emuPrimaryWindow.GetControl("TToolBar1").ControlClick(,"L",1,"x240 y5")	; Click Naomi on Toolbar
	emuPrimaryWindow.CreateControl("TToolBar1")		; instantiate new control for TToolBar1
	emuPrimaryWindow.GetControl("TToolBar1").Control("Check")	; Check control TToolBar1, Somehow this selects Naomi on Toolbar... mmkay
	emuPrimaryWindow.MenuSelectItem("File","Open Rom","2&") ; Open Naomi T12.7 roms
	emuPVRWindow := new Window(new WindowTitle("NAOMI - PVR","PVR2"))
} Else If StringUtils.Contains(systemName,"dreamcast|dc")
{	emuPrimaryWindow.MenuSelectItem("File","Open Image") ; Open Image for dreamcast
	emuPVRWindow := new Window(new WindowTitle("Makaron - PVR","PVR2"))
}
emuPVRWindow.CreateControl("TopMost")	; instantiate new TopMost control for PVRWindow

emuOpenWindow.Wait()
emuOpenWindow.WaitActive()

emuOpenWindow.OpenROM(romPath . "\" . romName . romExtension)

emuPVRWindow.Wait()
emuPVRWindow.WaitActive()

If (enable2Players = "true")
	emuPVRWindow.PostMessage("0x111","40115")	; Enable 2 players

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
FadeOutExit()
ExitModule()


HaltEmu:
	If (fullscreen = "true")
		disableActivateBlackScreen := "true"
Return

CloseProcess:
	FadeOutStart()
	If emuPrimaryWindow.Active()
		emuPrimaryWindow.Close()
	Else {
		emuPVRWindow.GetControl("TopMost").Send("{F8}")	; Send F8 to TopMost control
		TimerUtils.Sleep(1000)	; required to help prevent an Invalid Filename error from showing. It can still show if user exits emu too fast after loading though. Nothing can be done about this.
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.Activate()
		emuPrimaryWindow.Close()
	}
Return
