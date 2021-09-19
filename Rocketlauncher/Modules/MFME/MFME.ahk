MEmu := "MFME"
MEmuV := "v3.2 & v9.4 & v10.1a"
MURL := ["http://www.fruit-emu.com/"]
MAuthor := ["djvj"]
MVersion := "2.1.0"
MCRC := "273694CE"
iCRC := "DD016B70"
MID := "635880617939097804"
MSystem := ["Fruit Machine","MFME"]
;----------------------------------------------------------------------------
; Notes:
; MFME's different versions all support different games. No one version plays them all. Place all your MFME exes into your Emu_Path dir. Create one emu section for each of the 3 MFME versions used by this module in your Global Emulators or Emulators.ini
; Each game should be in its own dir. The dir name should match the game name from your database xml.
; Each game has a ".gam" file, It's name needs to match the name from the database. This is like a cue file that contains info about a game's settings and where to find the rest of the files.
; For example, if you have a game name of "Back To The Features" and when you extract the game it looks like this:
; 	Back To The Features\Back_To_The_Features.gam
; Rename it so it looks like this:
; 	Back To The Features\Back To The Features.gam
;
; MFME layouts only support a fixed resolution, so if your desktop is not set to the same size as these layouts, it takes away from the MFME environment. By default this resolution is 1280x1024, so the module will change your desktop to match if resizeDesktop is enabled (default).
;
; Your Games.ini needs to have a section for each game that will not use your default emulator defined in Emulators.ini. This module supports MFME v3.2, 9.4, and 10.1a
; I would set MFME v10.1a as your default emulator.
; For each game that needs to use MFME v9.4, create a section like this:
; [Game 1]
; Emulator=MFME v9.4
; For each game that needs to use MFME v3.2, create a section like this:
; [Game 1]
; Emulator=MFME v3.2
; See the RocketLauncher site on how to use Games.ini for additional help

; If you use Magnifier mode, start it manually once and set it's view to Dock, then Exit
; If you want the script to be able to move and remove the border/title of the magnifier window, it has to be done as admin or you need to turn off UAC.
; Optionally you can set MagnifyWrapper.exe to run as admin if you are on win7 or greater and it will close Magnifier on exit
; One known issue is the magnifier window sometimes won't launch with the desired position on screen. Yet if you launch it manually it will show where you previously told it to start. I can't find the solution to this as the values are being stored in the registry properly.
; Magnifier's settings are stored in the registry @ HKEY_CURRENT_USER\Software\Microsoft\ScreenMagnifier
;
; MFME stores its settings (pretty much only launch history) in the registry @ HKEY_CURRENT_USER\Software\CJW\MFME
; As far as I can tell, there is no way to go fullscreen (only v3.2 supports it)
;----------------------------------------------------------------------------
StartModule()
BezelGUI()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"TForm1"))		; instantiate primary emulator window object

minimizeWindows := moduleIni.Read("Settings", "minimizeWindows","true",,1)
resizeDesktop := moduleIni.Read("Settings", "resizeDesktop","true",,1)
backgroundPic := moduleIni.Read("Settings", "backgroundPic",modulePath . "\Background.png",,1)
magnify := moduleIni.Read("Settings", "Magnify","true",,1)			; Create a windows magnifier window in the bottom right corner to see things closer over your cursor
magnifyPercentage := moduleIni.Read("Settings", "MagnifyPercentage","200",,1)
magnifyAlignment := moduleIni.Read("Settings", "MagnifyAlignment","Bottom Right Corner",,1)
magWinW := moduleIni.Read("Settings", "MagnifyWinSizeW","245",,1)
magWinH := moduleIni.Read("Settings", "MagnifyWinSizeH","245",,1)
magWinX := moduleIni.Read("Settings", "MagnifyWinPosX",A_Space,,1)
magWinY := moduleIni.Read("Settings", "MagnifyWinPosY",A_Space,,1)
ambientSound := moduleIni.Read("Settings", "ambientSound","true",,1)
ambientSoundFile := moduleIni.Read("Settings", "ambientSoundFile",moduleExtensionsPath . "\Quiet atmosphere in a small restaurant (indistinct speech) - 1978 (1R8,reprocessed).mp3",,1)
ambientSoundPlayer := moduleIni.Read("Settings", "ambientSoundPlayer",moduleExtensionsPath . "\djAmbiencePlayer.exe",,1)
ambientStopKey := moduleIni.Read("Settings", "ambientStopKey","PAUSE",,1)
resetKey := moduleIni.Read("Settings", "resetKey","F12",,1)			; key to reset the game while playing

If (magnify = "true")
{	MagnifyWrapperExe := new Process(moduleExtensionsPath . "\MagnifyWrapper.exe")
	MagnifyExe := new Process(A_WinDir . "\system32\magnify.exe")
	MagnifyWrapperExe.CheckFile("You have Magnify enabled but could not find the module extension to handle it: " . MagnifyWrapperExe.FileFullPath)
	MagnifyExe.CheckFile("Could not find Windows Magnifier in " . MagnifyExe.FileFullPath . "`nPlease disable Magnify in the module settings in RocketLauncherUI, or copy it to the above folder.")
}
If (ambientSound = "true")
{	AmbientSoundFile := new File(ambientSoundFile)
	AmbientSoundFile.CheckFile()
	AmbientSoundPlayerExe := new Process(ambientSoundPlayer)
	AmbientSoundPlayerExe.CheckFile()
}

; This gets rid of the emu window that pops up on launch
; GUI 5 creates the background that persists during gameplay.
If (fadeIn = "true")
{	; must keep fade on its own line so it passes authenticity checks
	FadeInStart()
	Gui 5: +LastFound
	WinGet GUI_ID5, ID
	Gui 5: -AlwaysOnTop -Caption +ToolWindow
	Gui 5: Color, %loadingColor%
	backgroundPicHandle := Gdip_CreateBitmapFromFile(backgroundPic)
	Gdip_GetImageDimensions(backgroundPicHandle, backgroundPicW, backgroundPicH)
	RLLog.Debug("Module - backgroundPic's dimensions are: " . backgroundPicW . "x" . backgroundPicH)
	backXPos := ( A_ScreenWidth / 2 ) - ( backgroundPicW / 2 )
	backYPos := ( A_ScreenHeight / 2 ) - ( backgroundPicH / 2 )
	Gui 5: Add, Picture,x%backXPos% y%backYPos%, %backgroundPic%
	Gui 5: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
	RLLog.Info("Module - Displaying backgroundPic's dimensions at - x: " . backXPos . " y: " . backYPos)
}

resetKey := xHotKeyVarEdit(resetKey,"resetKey","~","Add")
xHotKeywrapper(resetKey,"Reset")

If (minimizeWindows = "true") {
	RLLog.Info("Module - Minimizing all windows")
	WinMinimizeAll
}

BezelStart()

If (resizeDesktop = "true")
{	;TimerUtils.Sleep(1000) ; probably don't need this
	currentFloat := A_FormatFloat 	; backup current float
	SetFormat, Float, 6.2
	If bezelPath	; if bezels are user, utilized monitor should be the desired bezel monitor, not the primary one for the system
		MFME_Monitor := bezelMonitor
	Else
		MFME_Monitor := primMonitor

	; In case there is a bug where windows is reporting wrong frequency
	; originalScreenRes := ConvertToMonitorObject(MFME_Monitor . "|" . MonitorTable[MFME_Monitor].Width . "|" . MonitorTable[MFME_Monitor].Height . "|" . MonitorTable[MFME_Monitor].BitDepth . "|" . MonitorTable[MFME_Monitor].Frequency)	; build monitor object
	; originalScreenRes := CheckForNearestSupportedRes(MFME_Monitor, originalScreenRes)	; assures that the current resolution is a compatible mode (sometimes the frequency can be wrongly defined on the previous function, this line double check this to avoid any issues).
	desiredRes := ConvertToMonitorObject(MFME_Monitor . "|1280|1024|" . monitorTable[MFME_Monitor].BitDepth . "|" . monitorTable[MFME_Monitor].Frequency )	; build monitor object from array
	desiredRes := CheckForNearestSupportedRes(MFME_Monitor, desiredRes) ; determine the supported res nearest to the desired 1280x1024 res.
	RLLog.Info("Module - Changing monitor " . MFME_Monitor . " to resolution width: " . desiredRes[MFME_Monitor].Width . ", height: " . desiredRes[MFME_Monitor].Height . ", bit depth: " . desiredRes[MFME_Monitor].BitDepth . ", frequency: " . desiredRes[MFME_Monitor].Frequency)
	SetDisplaySettings(desiredRes) ; changes the res to 1280x1024
	;TimerUtils.Sleep(1000) ; probably don't need this
}

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)

emuPID := Run(executable . " """ . romPath . "\"  . romName . romExtension . """", emuPath)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

TimerUtils.Sleep(1000)
emuPrimaryWindow.Set("Style", "-0xC00000")		;Removes the titlebar of the game window
emuPrimaryWindow.Set("Style", "-0x40000")		;Removes the border of the game window
DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) 	;Removes the MenuBar
; Control, Hide, , TPanel, AHK_class TForm1		;Removes the TPanel - Doesn't seem to work
; emuPrimaryWindow.Set("TransColor", "F0F0F0") ; Removes the grey around the machine, but slightly darkens the overall image

emuPrimaryWindow.Activate()
emuPrimaryWindow.WaitActive()

If (magnify = "true")
{	TimerUtils.Sleep(500)
	magPID := MagnifyExe.Process("Exist")
	If (magPID != 0)
		MagnifyExe.Process("Close")
	
	GetMagWinPosition(magWinX, magWinY, magWinW, magWinH, magnifyAlignment)	; Calculate the positioning of the Magnify Window
	
	; If A_OSVersion not in WIN_2003, WIN_XP, WIN_2000, WIN_NT4, WIN_95, WIN_98, WIN_M
	; {	RootKey = HKCU
		; SubKey = Software\Microsoft\ScreenMagnifier
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,MagnifierUIWindowMinimized, 1 			; start with ui minimized
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,MagnificationMode, 1					;choosing docked mode
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicDocked, 0 						;choosing classic window mode
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,Magnification, %magnifyPercentage% 		;Magnification Percentage
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowX, %magWinX%		;Window Pos x
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowY, %magWinY% 		;Window Pos y
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowCX, %magWinW%		;Window Width
		; regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowCY, %magWinH% 		;Window Height
	; }
	; Run(magnifierExe) ;,, Min
	; WinWait("ahk_class Screen Magnifier Window",,5)
	; If ErrorLevel {
		; SetKeyDelay, 50
		; Send,^!d	; turning on docked mode - does not work w/o admin mode
		; Sleep, 3000
	; }
	; WinWait("ahk_class Screen Magnifier Window",,6)
	; If ErrorLevel {
		; mfmeError=1
		; Gosub, CloseProcess
	; }
	If StringUtils.Contains(A_OSVersion,"WIN_2003|WIN_XP|WIN_2000|WIN_NT4|WIN_95|WIN_98|WIN_M")
	{	XpBelow := "true"
		MagnifyWindow := new Window(new WindowTitle(,"Screen Magnifier Window"))
		MagUIWindow := new Window(new WindowTitle(,"MagUIClass"))
		MagnifyWindow.Set("Style", "-0xC00000")		;Removes the titlebar of the magnifier window
		MagnifyWindow.Set("Style", "-0x40000")		;Removes the border of the magnifier window
		MagUIWindow.Minimize()
		MagnifyWindow.Move(magWinX,magWinY,magWinW,magWinH)
	} Else {
		;This is because of UAC control if it's turned off this will run much smoother
		; errorLvl := Run("MagnifyWrapper.exe """ . executable . """ " . x . " " . y, modulePath,"UseErrorLevel")
		errorLvl := MagnifyWrapperExe.Run(" """ . executable . """ " . magWinX . " " . magWinY . " " . magWinW . " " . magWinH,"UseErrorLevel")
		If errorLvl {
			mfmeError := 1
			Goto, CloseProcess
		}
	}
}

If (ambientSound = "true")
	AmbientSoundPlayerExe.Run(" """ . ambientSoundFile.FileFullPath . """ " . ambientStopKey)

If (resizeDesktop = "true")
	SetFormat, Float, %currentFloat%	; restore previous value

BezelDraw()
HideEmuEnd()
FadeInExit()

; WinSet, TransColor, 42424A 200, ahk_class TForm1
; PID doesn't seem to work for MFME, so have to use this method instead
primaryExe.Process("WaitClose")
BezelExit()

If (magnify = "true") And (XpBelow = "true")
	MagnifyExe.Process("Close")

If (ambientSound = "true")
	AmbientSoundPlayerExe.Process("Close")

;restore original resolution
If (resizeDesktop = "true")
{
	SetDisplaySettings(originalMonitorTable)	; change res back to original
	;Sleep, 1000
}

If (minimizeWindows = "true") {
	RLLog.Info("Module - Un-Minimizing all windows")
	WinMinimizeAllUndo
}

7zCleanUp()

If mfmeError {
	TimerUtils.Sleep(1000) ; giving some extra time in case desktop needs to be resized
	ScriptError("There was an error launching and docking the Magnifier window. Please manually start Magnifier and set it to docked view.")
}

FadeOutExit()
ExitModule()


GetMagWinPosition(ByRef x, ByRef y, ByRef w, ByRef h,pos){
	SysGet, b, 2 ; SM_CXVSCROLL - Get size of scrollbars, use this to adjust the size, and position of the final window. If this is not adjusted, the magnifier window has white background on the bottom and right sides.
	If (pos = "Center") {
		x := ( A_ScreenWidth / 2 ) - ( w / 2 ) + ( b / 2 )
		y := ( A_ScreenHeight / 2 ) - ( h / 2 ) + ( b / 2 )
	} Else If (pos = "Top Left Corner") {
		x := 0
		y := 0
	} Else If (pos = "Top Right Corner") {
		x := A_ScreenWidth - w + b
		y := 0
	} Else If (pos = "Bottom Left Corner") {
		x := 0
		y := A_ScreenHeight - h + b
	} Else If (pos = "Bottom Right Corner") {
		x := A_ScreenWidth - w + b
		y := A_ScreenHeight - h + b
	} Else If (pos = "Top Center") {
		x := ( A_ScreenWidth / 2 ) - ( w / 2 ) + ( b / 2 )
		y := 0
	} Else If (pos = "Bottom Center") {
		x := ( A_ScreenWidth / 2 ) - ( w / 2 ) + b
		y := A_ScreenHeight - h + b
	} Else If (pos = "Left Center") {
		x := 0
		y := ( A_ScreenHeight / 2 ) - ( h / 2 ) + ( b / 2 )
	} Else If (pos = "Right Center") {
		x := A_ScreenWidth - w + b
		y := ( A_ScreenHeight / 2 ) - ( h / 2 ) + ( b / 2 )
	} Else {
		x := x
		y := y
	}
	w := w - b
	h := h - b
}

Reset:
	KeyUtils.Send("!r")
Return

HaltEmu:
	XHotKeywrapper(resetKey,"Reset","OFF")
Return

RestoreEmu:
	XHotKeywrapper(resetKey,"Reset","ON")
Return

CloseProcess:
	FadeOutStart()
	TimerUtils.Sleep(400)
	; WinClose("MFME")
	; WinClose("ahk_pid " . emuPID)
	emuPrimaryWindow.Close()
Return
