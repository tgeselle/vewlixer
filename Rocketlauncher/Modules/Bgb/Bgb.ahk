MEmu := "Bgb"
MEmuV := "v1.4.3"
MURL := ["http://bgb.bircd.org/"]
MAuthor := ["djvj,ghutch92"]
MVersion := "2.0.8"
MCRC := "50733FC3"
iCRC := "E03EEAC6"
MID := "635637123510883144"
MSystem := ["Nintendo Game Boy","Nintendo Game Boy Color"]
;----------------------------------------------------------------------------
; Notes:
; Place the "[BIOS] Nintendo Game Boy Color Boot ROM (World).gbc" rom in the bgb dir so you get correct colors
; Run the emu, right click and goto Options->System->GBC Bootrom and paste in the filename of the GBC boot rom
; Don't forget to check the "bootroms enabled" box
; Module will automatically delete the width/height settings so BGB sizes correctly to your monitor when going fullscreen.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()

primaryExe := new Emulator(emuPath . "\" . executable)	; instantiate emulator executable object

SplitScreen2PlayersMode := moduleIni.Read("Settings", "SplitScreen_2_Players","Vertical",,1) ;horizontal or vertical
SplitScreen3PlayersMode := moduleIni.Read("Settings", "SplitScreen_3_Players","P1top",,1) ; For Player1 screen to be on left: P1left. For Player1 screen to be on top: P1top. For Player1 screen to be on bottom: P1bottom. For Player1 screen to be on right: P1right.

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
SGBColorsEnabled := moduleIni.Read("Settings", "SGB_Colors_Enabled","false",,1) ; if enabled some game boy games will have color instead of being black and white
SGBBorderEnabled := moduleIni.Read("Settings", "SGB_Border_Enabled","false",,1) ; if enabled some game boy games will have the border that the SGB used for tv screens
multiplayerMenu := moduleIni.Read(romName . "|Settings", "Multiplayer_Menu","false",,1)

If (multiplayerMenu = "true")
	SelectedNumberofPlayers := NumberOfPlayersSelectionMenu(4)

FadeInStart()

If (SelectedNumberofPlayers > 1)
	BezelStart(SelectedNumberofPlayers)
Else
	BezelStart()

; Using commandline -setting name=value to set emulator options

; This disables Esc from bringing up the debug window (bgb's default behavior). If it's on, pressing Esc brings up debug, rather then closing the emu
parameters := " -setting DebugEsc=0"
;disables or enables Super Game Boy Colors for the Game Boy (DMG)
parameters := (SGBColorsEnabled = "true") ? (parameters . " -setting SGBnocolors=0") : (parameters . " -setting SGBnocolors=1")
;disables or enables Super Game Boy Border for the Game Boy (DMG)
parameters := (SGBBorderEnabled = "true") ? (parameters . " -setting Border=1") : (parameters . " -setting Border=0")

7z(romPath, romName, romExtension, sevenZExtractPath)

If (SelectedNumberofPlayers = 1 || multiplayerMenu = "false") {
	emuPrimaryWindow := new Window(new WindowTitle(,"Tfgb"))	; instantiate primary emulator window object

	If (Fullscreen = "true") {
		; Width/Height values must be blank so BGB sizes correctly to the monitor when going fullscreen because it has no proper aspect ratio control.
		bgbIniFile := emuPath . "\bgb.ini"
		bgbIni := LoadProperties(bgbIniFile)	; load the ini into memory
		WriteProperty(bgbIni,"Width","")	; delete value
		WriteProperty(bgbIni,"Height","")
		SaveProperties(bgbIniFile,bgbIni)	; save changes
	}

	hideEmuObj := Object(emuPrimaryWindow,1)
	HideAppStart(hideEmuObj,hideEmu)

	parameters .= " -setting Windowmode=1"
	primaryExe.Run(parameters . " """ . romPath . "\" . romName . romExtension . """")
	emuPrimaryWindow.Wait()
	emuPrimaryWindow.WaitActive()
	If (Fullscreen = "true") {
		RLLog.Info("Module - Creating black background to simulate a fullscreen look.")
		MaximizeWindow("bgb ahk_class Tfgb")	; bgb always stretches when telling it to go fullscreen so module handles it instead
		emuPrimaryWindow.Set("AlwaysOnTop", "On")	; forces emu to always remain above the background
		Gui bgbGUI: -AlwaysOnTop -Caption +ToolWindow
		Gui bgbGUI: Color, Black
		Gui bgbGUI: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
		emuPrimaryWindow.Activate()
	}
} Else {
	; Screen positions
	If (SelectedNumberofPlayers = 2)
		If (SplitScreen2PlayersMode = "Vertical")
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight
		Else
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2 , X2 := 0 , Y2 := A_ScreenHeight//2 ,	W2 := A_ScreenWidth , H2 := A_ScreenHeight//2
	Else If (SelectedNumberofPlayers = 3)
		If (SplitScreen3PlayersMode = "P1left")
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := A_ScreenWidth//2 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else If (SplitScreen3PlayersMode = "P1bottom")
			X1 := 0 , Y1 := A_ScreenHeight//2 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2 , X2 := 0 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := A_ScreenWidth//2 , Y3 := 0 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else If (SplitScreen3PlayersMode = "P1right")
			X1 := A_ScreenWidth//2 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight ,	X2 := 0 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := 0 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else	; top
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2, X2 := 0 , Y2 := A_ScreenHeight//2 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2, X3 := A_ScreenWidth//2 , Y3 := A_ScreenHeight//2 , W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
	Else
		X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight//2 , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := 0 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2 , X4 := A_ScreenWidth//2 , Y4 := A_ScreenHeight//2 ,	W4 := A_ScreenWidth//2 , H4 := A_ScreenHeight//2

	; Removing fullscreen ## only app with focus receives input. This means player 1 can't control player 2's game. ## Turning on remotejoy so player 2 can actually play
	parameters .= " -setting Windowmode=1 -setting JoyFocus=1 -setting RemoteJoy=1"
	
	Address := "127.0.0.1"		;local address
	Port    := 8765				;default port
		
	Loop % SelectedNumberofPlayers
	{
		MiscUtils.DetectHiddenWindows("Off")
		currentScreen := A_Index
		MultiPlayerExe%currentScreen% := new Process(emuPath . "\" . executable)	; instantiate each emulator executable object

		parameters .= " " . (If (currentScreen = 1) ? "-listen" : "-connect") . " " . address . ":" . port
		
		multi_romName := gamesSelectedArray[currentScreen]
		If !multi_romName
			multi_romName := romName
		
		MultiPlayerExe%currentScreen%.Run(parameters . " """ . romPath . "\" . multi_romName . romExtension . """")
		MultiPlayerEmuWindow%currentScreen% := new Window(new WindowTitle(,,,,MultiPlayerExe%currentScreen%.PID))	; instantiate each emulator window object
		MultiPlayerEmuWindow%currentScreen%.Wait()
		MultiPlayerEmuWindow%currentScreen%.WaitActive()
		MultiPlayerEmuWindow%currentScreen%.Get("ID")	; retrieve ID of the this player's window
		MultiPlayerEmuWindow%currentScreen%.WinTitle.ID := MultiPlayerExe%currentScreen%.ID	; switch the WinTitle to the ID of the window for the rest of the module
		If (Fullscreen = "true")
		{
			MultiPlayerEmuWindow%currentScreen%.RemoveBorder()
			MultiPlayerEmuWindow%currentScreen%.Move(X%currentScreen%, Y%currentScreen%, W%currentScreen%, H%currentScreen%,2000)
			timeout := A_TickCount
			Loop	; Check If window moved
			{
				MultiPlayerEmuWindow%currentScreen%.GetPos(X, Y, W, H)
				If ((MultiPlayerEmuWindow%currentScreen%.X = X%currentScreen%) and (MultiPlayerEmuWindow%currentScreen%.Y = Y%currentScreen%) and (MultiPlayerEmuWindow%currentScreen%.W = W%currentScreen%) and (MultiPlayerEmuWindow%currentScreen%.H = H%currentScreen%) || (timeout < A_TickCount-2000))
					Break
				TimerUtils.Sleep(50)
				MultiPlayerEmuWindow%currentScreen%.Move(X%currentScreen%, Y%currentScreen%, W%currentScreen%, H%currentScreen%,2000)
			}
		}
		TimerUtils.Sleep(50)
	}	
}

; TimerUtils.Sleep(5000)
BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")

If (fullscreen = "true")
{	Gui bgbGUI: Destroy
	RLLog.Info("Module - Destroyed black gui background.")
}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	If (SelectedNumberofPlayers > 1) {
		Loop % SelectedNumberofPlayers
		{
			MultiPlayerEmuWindow%A_Index%.Close()
			MultiPlayerEmuWindow%A_Index%.WaitClose()
		}
	} Else
		emuPrimaryWindow.Close()
Return
