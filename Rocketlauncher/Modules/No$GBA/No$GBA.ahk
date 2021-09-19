MEmu := "No$GBA & No$Zoomer"
MEmuV := "v2.6a & v2.3.0.2"
MURL := ["http://www.nogba.com/"]
MAuthor := ["brolly","djvj"]
MVersion := "2.0.3"
MCRC := "EAEB245"
iCRC := "1B02DE88"
MID := "635038268909338425"
MSystem := ["Nintendo DS","Nintendo Game Boy Advance"]
;----------------------------------------------------------------------------
; Notes:
; On first run make sure you right click the game window during gameplay and select fullscreen and always on top
;
; For Nintendo DS support only:
; Create a separate entry in your Global Emulators or Emulators.ini for this same module as the GBA entry (if none exists already)
; Requires No$Zoomer.exe
; Point your exe to No$Zoomer.exe
; On first run No$Zoomer you will ask you to point to the No$GBA executable
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

zoomEmu := StringUtils.Contains(executable,"zoom")	; if executable is No$Zoomer.exe
If zoomEmu
	emuPrimaryWindow := new Window(new WindowTitle("NO$Zoomer","HT_MainWindowClass"))	; instantiate primary emulator window object
Else
	emuPrimaryWindow := new Window(new WindowTitle("No$gba Emulator","No$dlgClass"))

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuExe := new Emulator("NO$GBA.exe")

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
bezelTopOffset := moduleIni.Read("Settings", "bezelTopOffset","50",,1)
bezelBottomOffset := moduleIni.Read("Settings", "bezelBottomOffset","7",,1)
bezelLeftOffset := moduleIni.Read("Settings", "bezelLeftOffset","7",,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset","7",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart()

gbaINI := new IniFile(emuPath . "\" . (If zoomEmu ? "NO$Zoomer.ini" : "NO$GBA.INI"))
gbaINI.CheckFile()

; Setting Fullscreen setting in ini if it doesn't match what user wants
If zoomEmu
{
	currentFullScreen := gbaINI.Read("NO$ZOOMER","ExecFullscreen")
	If (fullscreen != "true" && currentFullScreen = 1)
		gbaINI.Write(0,"NO$ZOOMER","ExecFullscreen")
	Else If (fullscreen = "true" && currentFullScreen = 0)
		gbaINI.Write(1,"NO$ZOOMER","ExecFullscreen")
}

If bezelPath	; defining bezel game window size for Nintendo DS
{	
	bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
	gbaINI.Write(bezelScreenX,"NO$ZOOMER","PosX")
	gbaINI.Write(bezelScreenY,"NO$ZOOMER","PosY")
	scaleGameScreen := bezelScreenWidth/256
	gbaINI.Write(scaleGameScreen,"NO$ZOOMER","Zoom")
}

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If (!zoomEmu && fullscreen = "true") {	; only want this for GBA mode
	; These do not work :-(
	; WinSet, Style, -0x40000, % emuTitle ; Removes the border of the game window
	; WinSet, Style, -0xC00000, %emuTitle% ; Removes the TitleBar
	emuPrimaryWindow.RemoveMenubar() ; Removes the MenuBar
	emuPrimaryWindow.Maximize()
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
emuExe.Process("WaitClose")	; must wait for the actual emulator exe even when No$Zoomer.exe is used
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


BezelLabel:
	disableHideTitleBar := "true"
	disableHideToggleMenu := "true"
	disableHideBorder := "true"
	If zoomEmu   ; only want this for No$Zoomer
		disableWinMove := "true"
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
