MEmu := "PicoDrive"
MEmuV := "v1.45a"
MURL := ["http://notaz.gp2x.de/pico.php"]
MAuthor := ["bleasby"]
MVersion := "2.0.5"
MCRC := "6A2986AF"
iCRC := "34905C0E"
MID := "635083171511164818"
MSystem := ["Sega Pico"]
;----------------------------------------------------------------------------
; Notes:
; Sega Pico games have three windows: the game window, the storywave and the drawing pad. For better gameplay please enable the RocketLauncher bezel feature. 
; The bezel overlay feature is not supported for the three screens mode. 
; If you use the provided bezel images in resolutions lower then 1360x768, some parts of the game window could be clipped out of the screen. For better gameplay experience resize the bezel image to fill your screen resolution and update the pixel positions at the bezel.ini file or set the option ChangeRes to true. This cannot be done automatically by RocketLauncher because this emulator does not allow to resize the storywave and the drawing pad. You should keep their sizes at the provided pixel dimensions and just resize the main game screen.
; The ChangeRes option will change your monitor screen resolution before creating the bezel image and restore it after. If the restored resolution does not corresponds to your native monitor resolution, please change the nativeScreenWidth and nativeScreenHeigth variables to the desired monitor resolution.   
; If you want to restore the screen to a different resolution from the one automatically detected one while ChangeRes is set to true, please fill the variable desired ScreenRes with the width|height|quality|frequency info (for example: 1280|1024|32|60 for 1280x1024 pixels with 32 bit colors and 60Hz frequency).
; To use use different Game Pad images, create a folder in your emulator folder\pico\GamePads and save the image as romName.png - with romName being the name of the game you are using it for  
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"PicoMainFrame"))		; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle("Open","#32770"))
emuErrorWindow := new Window(new WindowTitle("Error","#32770"))
emuStorywareWindow := new Window(new WindowTitle("Storyware","PicoSwWnd"))
emuDrawingPadWindow := new Window(new WindowTitle("Drawing Pad","PicoPadWnd"))

ChangeRes := moduleIni.Read("Settings", "ChangeRes","false",,1)		;	Resize your monitor resolution to the bezel image size. 
desiredScreenRes := moduleIni.Read("Settings", "ScreenRes",,,1)	;	Desired Monitor Screen resolution restore after the gameplay
bezelTopOffsetScreen1 := moduleIni.Read("Settings", "Bezel_Top_Offset_Screen_1","29",,1)
storywarePageUPKey := moduleIni.Read("Settings", "Storyware_Page_UP_Key","M",,1)
picoStorywarePageDown := moduleIni.Read("Settings", "Storyware_Page_Down_Key","N",,1)

hideEmuObj := Object(emuStorywareWindow,0,emuDrawingPadWindow,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart(3)

If bezelPath
{	If (ChangeRes = "true")
	{
		desiredRes := ConvertToMonitorObject(bezelMonitor . "|" . bezelImageW . "|" . bezelImageH . "|" . monitorTable[bezelMonitor].BitDepth . "|" . monitorTable[bezelMonitor].Frequency )	; build monitor object from array
		desiredRes := CheckForNearestSupportedRes(bezelMonitor, desiredRes) ; determine the supported res nearest to the desired of the bezel
		RLLog.Info("Module - Changing monitor " . bezelMonitor . " to resolution width: " . desiredRes[bezelMonitor].Width . ", height: " . desiredRes[bezelMonitor].Height . ", bit depth: " . desiredRes[bezelMonitor].BitDepth . ", frequency: " . desiredRes[bezelMonitor].Frequency)
		SetDisplaySettings(desiredRes) ; changes to the closest res that matches bezel
	}
}

picoStorywareCurrentPage := 0
XHotKeywrapper(storywarePageUPKey,"picoStorywarePageUP")
XHotKeywrapper(picoStorywarePageDown,"picoStorywarePageDown")

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If bezelPath {
	Screen1ID := emuPrimaryWindow.Exist()		; Screen 1
	Screen2ID := emuStorywareWindow.Exist()		; Screen 2
	Screen3ID := emuDrawingPadWindow.Exist()	; Screen 3
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()

If bezelPath {
	If (ChangeRes = "true") {
		SetDisplaySettings(originalMonitorTable)	; change res back to original
	}
}

ExitModule()


BezelLabel:
	disableHideToggleMenuScreen1 := true
	disableHideToggleMenuScreen2 := true
	disableHideToggleMenuScreen3 := true
Return

PicoStorywarePageUP:
	Loop
	{	picoStorywareCurrentPage++
		If picoStorywareCurrentPage
			errLvl := emuPrimaryWindow.MenuSelectItem("Pico", "Page " . picoStorywareCurrentPage)
		If !errLvl
			Break 
		Else 
			picoStorywareCurrentPage := picoStorywareCurrentPage-1
	}
Return

PicoStorywarePageDown:
	picoStorywareCurrentPage--
	If (picoStorywareCurrentPage < 0)
		picoStorywareCurrentPage := 0
	If picoStorywareCurrentPage
		emuPrimaryWindow.MenuSelectItem("Pico", "Page " . picoStorywareCurrentPage)
	Else
		emuPrimaryWindow.MenuSelectItem("Pico", "Title")
Return

CloseProcess:
	FadeOutStart()
	emuOpenWindow.Close()
	emuErrorWindow.Close()
	emuPrimaryWindow.Close()
Return
