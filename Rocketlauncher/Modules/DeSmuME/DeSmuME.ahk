MEmu := "DeSmuME"
MEmuV := "v0.9.9"
MURL := ["http://www.desmume.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.9"
MCRC := "F665C5F2"
iCRC := "54A7E48C"
MID := "635038268882946453"
MSystem := ["Nintendo DS"]
;----------------------------------------------------------------------------
; Notes:
; The example module ini from GIT comes with some of the vertical games already configured for vertical mode.
; Uncheck View->Show Toolbar
; Set View->Screen seperation to black, also choose your border (I prefer 5px)
; Open the desmume.ini and add "Show Console=0" anywhere to stop the console window from showing up
; Per-game rotation settings can be controlled via the module settings in RocketLauncherUI
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("","DeSmuME"))	; instantiate primary emulator window object
emuConsoleWindow := new Window(new WindowTitle("","ConsoleWindowClass"))

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
rotation := moduleIni.Read("Settings|" . romName, "Rotation",0,,1)
lcdsLayout := moduleIni.Read("Settings|" . romName, "LCDs_Layout",0,,1)
lcdsSwap := moduleIni.Read("Settings|" . romName, "LCDs_Swap",0,,1)
bezelTopOffset := moduleIni.Read("Settings", "Bezel_Top_Offset","8",,1)
bezelBottomOffset := moduleIni.Read("Settings", "Bezel_Bottom_Offset","8",,1)
bezelRightOffset := moduleIni.Read("Settings", "Bezel_Right_Offset", "8",,1)
bezelLeftOffset := moduleIni.Read("Settings", "Bezel_Left_Offset", "8",,1)

; X432R support
StringUtils.SplitPath(executable,,,,exeNoExt)
x432rIni := new IniFile(emuPath . "\" . exeNoExt . ".ini")	; this fork always names the ini after the executable name
x432riniFound := ""
If x432rIni.Exist() {
	RLLog.Info("Module - Found X432R DeSmuME Emu")
	desmumeIni := x432rIni
	x432riniFound := true
} Else {
	desmumeIni := new IniFile(emuPath . "\desmume.ini")	; default ini
	desmumeIni.CheckFile()
}

currentRotate := desmumeIni.Read("Video","Window Rotate",0)
currentRotateSet := desmumeIni.Read("Video","Window Rotate Set",0)
currentLCDsLayout := desmumeIni.Read("Video","LCDsLayout",0)
currentLCDsSwap := desmumeIni.Read("Video","LCDsSwap",0)

If StringUtils.Contains(rotation,"true|false")
	ScriptError("Please change your " . MEmu . " module settings to properly set the Rotation setting to 0|90|180|270 as this was recently changed.")

If (rotation != currentRotate || rotation != currentRotateSet) {
	desmumeIni.Write(rotation,"Video","Window Rotate")
	desmumeIni.Write(rotation,"Video","Window Rotate Set")
}
If (currentLCDsLayout != lcdsLayout)
	desmumeIni.Write(lcdsLayout,"Video","LCDsLayout")
If (currentLCDsSwap != lcdsSwap)
	desmumeIni.Write(lcdsLayout,"Video","LCDsSwap")

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart(,, (StringUtils.Contains(rotation,"90|270")) ? "true" : "")

If bezelPath {	; defining xscale and yscale relative to the bezel windowed mode
	desmumeIni.Write(0,"Display","Window Split Border Drag")
	If (rotation = 0 || rotation = 180)
		screenGapPixels := Round((bezelScreenHeight - 2*192*bezelScreenWidth/256) * (256/bezelScreenWidth))
	Else
		screenGapPixels := Round((bezelScreenWidth - 2*192*bezelScreenHeight/256) * (192/bezelScreenHeight))
	desmumeIni.Write(screenGapPixels,"Display","ScreenGap")
}

If (bezelEnabled = "true" || fullscreen = "true")
	desmumeIni.Write(0,"Display","Show Toolbar")	; turn off the toolbar

If x432riniFound {
	currentWindowFS := desmumeIni.Read("X432R", "WindowFullScreen")
	If (currentWindowFS != 1 && fullscreen = "true")
		desmumeIni.Write(1,"X432R","WindowFullScreen")
	Else If (currentWindowFS != 0 && fullscreen != "true")
		desmumeIni.Write(0,"X432R","WindowFullScreen")
}

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()

If (Fullscreen = "true" && !x432riniFound)
{	
	emuPrimaryWindow.GetPos(x,y,w,h)	; Getting original position of the emu, so we know when it goes Fullscreen
	KeyUtils.Send("!{Enter}")	; Go Fullscreen, DeSmuME does not support auto-fullscreen yet
	Loop {	; looping so we know when to destroy the GUI
		TimerUtils.Sleep(200,0)
		emuPrimaryWindow.GetPos(x2,y2,w2,h2,0)
		; ToolTip, x=%x%`ny=%y%`nw=%w%`nh=%h%`nx2=%x2%`ny2=%y2%`nw2=%w2%`nh2=%h2%
		If (x != x2)	; x changes when emu goes fullscreen, so we will break here and destroy the GUI
			Break
	}
	TimerUtils.Sleep(200)	; Need a moment for the emu to finish going Fullscreen, otherwise we see the background briefly
}

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


BezelLabel:
	disableHideTitleBar := true
	emuConsoleWindow.Set("Transparent",0)
Return

SaveStateSlot1:
SaveStateSlot2:
SaveStateSlot3:
SaveStateSlot4:
SaveStateSlot5:
LoadStateSlot1:
LoadStateSlot2:
LoadStateSlot3:
LoadStateSlot4:
LoadStateSlot5:
	If (Fullscreen = "true")
		KeyUtils.Send("!{Enter}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
