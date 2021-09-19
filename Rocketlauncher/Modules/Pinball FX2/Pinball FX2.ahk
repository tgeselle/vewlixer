MEmu := "Pinball FX2"
MEmuV := "N/A"
MURL := ["http://www.pinballfx.com/"]
MAuthor := ["djvj","bleasby"]
MVersion := "2.1.3"
MCRC := "3C64C037"
iCRC := "489E4B10"
MID := "635244873683327779"
MSystem := ["Pinball FX2","Pinball"]
;----------------------------------------------------------------------------
; Notes:
; If launching as a Steam game:
; When setting this up in RocketLauncherUI under the global emulators tab, make sure to select it as a Virtual Emulator. Also no rom extensions, executable, or rom paths need to be defined. You can put an extension of pxp if you want RLUI audit to work however. It will not affect launching.
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
; If not launching through Steam:
; Add this as any other standard emulator and define the PInball FX2.exe as your executable, but still select Virtual Emulator as you do not need rom extensions or rom paths
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
; When setting this up in RocketLauncherUI under the global emulators tab, make sure to set rom extensions to pxp
; Also make your rom path the Pinball FX2\data_steam folder if you want audit to show green
;
; DMD (Dot Matrix Display)
; The module will support and hide the window components of detached DMD
; To see it, you must have a 2nd monitor connected as an extension of your desktop, and placement will be on that monitor
; To Detach:
; Run Pinball FX2 manually, and goto Help & Options -> Settings -> Video
; Set Dot Matrix Size to Off, and close Pinball FX2
; The module will automatically create the dotmatrix.cfg file in the same folder of the "Pinball FX2.exe" (your installation folder) for you
; Edit the module's settings in RLUI to customize the DMD size and placement of this window
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
primaryExe := new Emulator(If executable ? emuPath . "\" . executable : "Pinball FX2.exe")	; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Pinball FX2","PxWindowClass"))				; instantiate primary emulator window object
emuDMDWindow := new Window(new WindowTitle("Pinball FX2 DotMatrix","PxWindowClass"))

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
fullscreenWidth := moduleIni.Read("Settings", "Fullscreen_Width",A_ScreenWidth,,1)
fullscreenHeight := moduleIni.Read("Settings", "Fullscreen_Height",A_ScreenHeight,,1)
externalDMD := moduleIni.Read("Settings", "External_DMD","false",,1)
dmdX := moduleIni.Read("Settings", "DMD_X",A_ScreenWidth,,1)
dmdY := moduleIni.Read("Settings", "DMD_Y",0,,1)
dmdW := moduleIni.Read("Settings", "DMD_Width",0,,1)
dmdH := moduleIni.Read("Settings", "DMD_Height",0,,1)

BezelStart()

fullscreen := fullscreen = "true" ? " -fullscreen" : " -borderless"	; -window is also supported but not used in this module
resolution := " -resolution" . fullscreenWidth . "x" . fullscreenHeight

If (externalDMD = "true") {
	RLLog.Info("Module - Updating external DMD window placement values")
	If (!executable && !steamPath)
		GetSteamPath()
	dotmatrixCFGFile := new File(If executable ? emuPath . "\dotmatrix.cfg" : steamPath . "\SteamApps\common\Pinball FX2\dotmatrix.cfg")
	If !dotmatrixCFGFile.Exist()
		dotmatrixCFGFile.Append()	; create a new blank file if one does not exist
	RLLog.Info("Module - Using this dotmatrix.cfg: " . dotmatrixCFGFile.FileFullPath)
	dotmatrixCFG := LoadProperties(dotmatrixCFGFile.FileFullPath)
	WriteProperty(dotmatrixCFG, "x", dmdX, 1)
	WriteProperty(dotmatrixCFG, "y", dmdY, 1)
	WriteProperty(dotmatrixCFG, "width", dmdW, 1)
	WriteProperty(dotmatrixCFG, "height", dmdH, 1)
	SaveProperties(dotmatrixCFGFile.FileFullPath, dotmatrixCFG)	
}

hideEmuObj := Object(pinballTitleClass,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
HideAppStart(hideEmuObj,hideEmu)

If executable {
	RLLog.Info("Module - Running Pinball FX2 as a stand alone game and not through Steam as an executable was defined.")
	primaryExe.Run(" " . romName . fullscreen . resolution)
} Else {
	RLLog.Info("Module - Running Pinball FX2 through Steam.")
	Steam(226980,,romName . fullscreen . resolution)
}

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

; Attempt to hide window components of the detached DMD
If (externalDMD = "true") {
	Gui +LastFound
	hWnd := WinExist()
	DllCall("RegisterShellHookWindow", UInt,hWnd)
	MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
	OnMessage(MsgNum, "ShellMessage")
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
; Process("WaitClose", "Pinball FX2.exe")
BezelExit()
FadeOutExit()
ExitModule()
    

ShellMessage(wParam, lParam) {
	RLLog.Debug("Module - DMD external window - " . wParam)
	If (wParam = 1)
		If emuDMDWindow.Exist()
		{
			emuDMDWindow.RemoveBorder()				; hide title bar
			emuDMDWindow.Set("Style", "-0x800000")	; hide thin-line border
			emuDMDWindow.Set("Style", "-0x400000")	; hide dialog frame
			; emuDMDWindow.Set("Style", "-0xC00000")	; hide title bar
			; emuDMDWindow.Set("Style", "-0x40000")	; hide thickframe/sizebox
			; emuDMDWindow.Move(0,0,1920,1080)
		} 
}

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
