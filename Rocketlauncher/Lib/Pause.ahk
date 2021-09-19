MCRC := "CB993981"
MVersion := "1.2.18"

;Author: bleasby
;Thanks to djvj and brolly for helping in the development of Pause (without them this would be impossible to achieve)
;Thanks to THK for the great work with moves list icons
;Thanks to all beta testers, ghutch92 (thks for the owner gui code), dustind900, emb, mameshane, DrMoney,...
;Thanks to autohotkey community for library files and example scripts
;Thanks to all people from the command.dat project, emumovies, tempest for creating system ini files, HitoText creators,... 
;---------------------------------------
;A necessary Warning for anyone that wants to modify my code! I am not a programmer. I did this as a hobby and a way to learn languages and autohotkey. Right now I would do a lot of things diferently, but time is a scarce commodity.
;Probably my way to code is not the smallest, more structured or more efficient way to do things.
;I am really, really, open to any suggestion about the code If you have more experience in codding.

;File Descripton
;This file contains all functions and labels related with the Pause Addon for RocketLauncher

;Pause Layers
; 	- Pause_GUI21 - Loading Screen and Black Screen to Hide FrontEnd
; 	- Pause_GUI21b - Loading Screen Dynamic Text
; 	- Pause_GUI22 - Background Image (covers entire screen)
; 	- Pause_GUI23 - Background (covers entire screen)
; 	- Pause_GUI24 - Moving description
; 	- Pause_GUI25 - Main Menu bar
; 	- Pause_GUI26 - Config Options (Above Bar Label)
; 	- Pause_GUI27 - Submenus
; 	- Pause_GUI28 - Clock
; 	- Pause_GUI29 - Full Screen drawing while changing screens in Pause (covers entire screen)
; 	- Pause_GUI30 - Disc Rotation, animations, submenu animations
; 	- Pause_GUI31 - ActiveX Video
; 	- Pause_GUI32 - Mouse Overlay
; 	- Pause_GUI33 - Help text while in submenu
; 	- Pause_GUI34 - Now Playing info

;Rini Variables
;Stat - Global Statistics Settings 
;Stat_Sys - System Statistics Settings
;P - Global Pause Settings  
;P_sys - System Pause Settings


;PauseMediaObj

;PauseMediaObj[SubMenuLabel].maxLabelSize
;PauseMediaObj[SubMenuLabel].txtLines 
;PauseMediaObj[SubMenuLabel].txtFSLines 

;PauseMediaObj[SubMenuLabel].1 := Label   ; gives the label corresponding to each index (index = 1, 2, ...)
;PauseMediaObj[SubMenuLabel].Label.Label	
;PauseMediaObj[SubMenuLabel].Label.Path1, PauseMediaObj[SubMenuLabel].Label.Ext2,...
;PauseMediaObj[SubMenuLabel].Label.Ext1, PauseMediaObj[SubMenuLabel].Label.Ext2,...
;PauseMediaObj[SubMenuLabel].Label.TotalItems   

;for txt only
;PauseMediaObj[SubMenuLabel].Label.txtWidth
;PauseMediaObj[SubMenuLabel].Label.Page1, PauseMediaObj[SubMenuLabel].Label.Page2, ....
;PauseMediaObj[SubMenuLabel].Label.FSPage1, PauseMediaObj[SubMenuLabel].Label.Page2, ....
;PauseMediaObj[SubMenuLabel].Label.TotalV2SubMenuItems
;PauseMediaObj[SubMenuLabel].Label.TotalFSV2SubMenuItems

;-----------------CODE-------------

Pause_Main:
    Pause_Running := true ; Pause menu is running
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF") ;cancel exit emulator key for future reasigning 
    XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","OFF") ;cancel Pause key for future reasigning 
    If (mgEnabled = "true")
        XHotKeywrapper(mgKey,"StartMulti","OFF") ;cancel MultiGame key while Pause is running
    If (bezelEnabled = true) and (bezelPath = true)
	{	Gosub, DisableBezelKeys%zz%	; many more bezel keys if they are used need to be disabled
        if %ICRandomSlideShowTimer%
			SetTimer, randomICChange%zz%, off
        if ICRightMenuDraw 
            Gosub, DisableICRightMenuKeys%zz%
        if ICLeftMenuDraw
            Gosub, DisableICLeftMenuKeys%zz%
        if (bezelBackgroundsList.MaxIndex() > 1)
            if bezelBackgroundChangeDur
                settimer, BezelBackgroundTimer%zz%, OFF
	}
    RLLog.Debug(A_ThisLabel . " - Disabled exit emulator, bezel, and multigame keys")
	If (emuIdleShutdown and emuIdleShutdown != "ERROR")	; turn off emuIdleShutdown while in Pause
		SetTimer, EmuIdleCheck%zz%, Off
    If (Pause_Loaded <> 1){ ; Initiate Gdip+ If first Pause run
        If !pToken := Gdip_Startup()
            RLLog.Error(A_ThisLabel . " - gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system")
        RLLog.Debug(A_ThisLabel . " - Started Gdip " pToken " (If number -> loaded)")
    }
	CustomFunction.PrePauseStart() ; starting pause user functions here so they are triggered before Pause starts

    ; Loading Pause ini keys 
    Pause_GlobalFile := A_ScriptDir . "\Settings\Global Pause.ini" 
    Pause_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\Pause.ini" 
    If (RIni_Read("P",Pause_GlobalFile) = -11) {
        RLLog.Debug(A_ThisLabel . " - Global Pause.ini file not found, creating a new one.")
        RIni_Create("P")
    }
    If (RIni_Read("P_sys",Pause_SystemFile) = -11) {
        If !FileExist(A_ScriptDir . "\Settings\" . systemName)
            FileCreateDir, % A_ScriptDir . "\Settings\" . systemName
        RLLog.Debug(A_ThisLabel . " - " . A_ScriptDir . "\Settings\" . systemName . "\Pause.ini file not found, creating a new one.")
        RIni_Create("P_sys")
	}
    If (Pause_Loaded <> 1){ ;determining emulator information to use in system specific commands in the module files
        WinGet emulatorProcessName, ProcessName, A
        WinGetClass, EmulatorClass, A
        WinGet emulatorID, ID, A
        WinGet emulatorProcessID, PID, A
    }
    RLLog.Debug(A_ThisLabel . " - Loaded Emulator information: EmulatorProcessName: " emulatorProcessName ", EmulatorClass: " EmulatorClass ", EmulatorID: " EmulatorID)
    ;Mute when loading Pause to avoiding sound stuttering
    Pause_MuteWhenLoading := RIniPauseLoadVar("P","P_sys", "General Options", "Mute_when_Loading_Pause", "true") 
    Pause_MuteSound := RIniPauseLoadVar("P","P_sys", "General Options", "Mute_Sound", "false") 
    getMute(PauseInitialMuteState)
    RLLog.Debug(A_ThisLabel . " - Master mute status: " PauseInitialMuteState " (1 is mutted)")
    If((Pause_MuteWhenLoading="true") or (Pause_MuteSound="true")){ 
        if !emulatorVolumeObject
            emulatorVolumeObject := GetVolumeObject(emulatorProcessID)
        getMute(PauseEmuInitialMuteState,emulatorVolumeObject)
        If !(PauseEmuInitialMuteState){
            setMute(1,emulatorVolumeObject)
            RLLog.Debug(A_ThisLabel . " - Muting emulator sound while Pause is loaded. Emulator mute status: " getMute(,emulatorVolumeObject) " (1 is mutted)")
        }
    }
    If(Pause_MainMenu_UseScreenshotAsBackground="true"){
        Pause_Screenshot_Extension := RIniPauseLoadVar("P","P_sys", "General Options", "Screenshot_Extension", "jpg") ;Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
        Pause_Screenshot_JPG_Quality := RIniPauseLoadVar("P","P_sys", "General Options", "Screenshot_JPG_Quality", "100") ;If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
        Pause_SaveScreenshotPath := RLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots"
        If !FileExist(Pause_SaveScreenshotPath)
            FileCreateDir, %Pause_SaveScreenshotPath%
        GameScreenshot := Pause_SaveScreenshotPath . "\GameScreenshot." . Pause_Screenshot_Extension
        CaptureScreen(GameScreenshot, "0|0|" . A_ScreenWidth . "|" . A_ScreenHeight , Pause_Screenshot_JPG_Quality)
    }
    
    if !(Pause_Loaded){
        Pause_MainMenu_Itens := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Menu_Items", "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown")
        Pause_MainMenu_Labels := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Menu_Labels", "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown")
        ; cheking if Pause_MainMenu_Labels is correctly filled
        if !(Pause_MainMenu_Labels){
            RLLog.Warning("Your pause Main_Menu_Labels is empty and it will be reset to the default value. To correct this warning go to RLUI and reset this field to its default value.`r`n`t`t`t`t`t Using default value: Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown")
            Pause_MainMenu_Labels := "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown"
        } else {
            StringReplace, Pause_MainMenu_Labels, Pause_MainMenu_Labels, |, |, UseErrorLevel
            if (ErrorLevel < 14){
                RLLog.Warning("You are missing " . 14-ErrorLevel " labels on your pause Main_Menu_Labels entry. You need to have one label for each possible pause menu item. To correct this warning go to RLUI and add a value to the missing labels or simply reset these fields to the default value:`r`n`t`t`t`t`t User Main Menu Labels: " Pause_MainMenu_Labels "`r`n`t`t`t`t`t Using default value: Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown")
                Pause_MainMenu_Labels := "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown|Change Disc"
            }
        }
        pauseBarItem := {}
        origMenuList := "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown"
        StringSplit, labels, Pause_MainMenu_Labels, |
        loop, parse, origMenuList, |
        {   pauseBarItem[a_loopfield] := {}
            pauseBarItem[a_loopfield].Label := labels%a_index%
        }
        ; Reading Pause menu disable option for canceling Pause drawn
        Pause_Disable_Menu := RIniPauseLoadVar("P","P_sys", "General Options", "Disable_Pause_Menu", "true") 
    }
    If !disableLoadScreen 
        gosub, HideFrontEnd ; Creating Pause_GUI21 non activated Black Screen to Hide FrontEnd
    RLLog.Info(A_ThisLabel . " - Pause Started: current rom: " dbName ", current system Name: " systemName)
    RLLog.Debug(A_ThisLabel . " - Created Black Screen to hide FrontEnd")
    Gosub, HaltEmu ;getting system specific commands from modules and pausing the emulator 
    RLLog.Debug(A_ThisLabel . " - Loaded emulator specific module start commands")
    If !disableLoadScreen ;activating Pause_GUI21 Black Screen for hidding FrontEnd If not disabled in the module 
        If !(disableActivateBlackScreen and Pause_Disable_Menu="true")
            WinActivate, PauseBlackScreen
    ;Acquiring screen info for dealing with rotated menu drawings
    if !(Pause_Loaded){
        pauseMonitor := RIniPauseLoadVar("P","P_sys", "General Options", "Pause_Monitor", "")
        pauseScreenRotationAngle := RIniPauseLoadVar("P","P_sys", "General Options", "Pause_Screen_Rotation_Angle", 0)
        If !(pauseMonitor)
            pauseMonitor := monitorTable.PrimaryMonitor
		;resetting to primary monitor if pause monitor chosen is higher than the monitors currently available
        If (pauseMonitor > monitorTable.MaxIndex())
			pauseMonitor := monitorTable.PrimaryMonitor
		;forcing RL rotation orientation when pause is draw on primary monitor
		If (pauseMonitor = monitorTable.PrimaryMonitor){
            pauseOnPrimaryMonitor := true
            pauseScreenRotationAngle := screenRotationAngle
        }
        ;Acquiring pause monitor information
        SysGet, Monitor, Monitor, %pauseMonitor%
        Gdip_Alt_GetRotatedDimensions(monitorTable[pauseMonitor].Width, monitorTable[pauseMonitor].Height, pauseScreenRotationAngle, baseScreenWidth, baseScreenHeight)
        Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, pauseScreenRotationAngle, xTranslation, yTranslation)
        xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
        ;Setting Scale Res Factors
        pauseWidthBaseRes := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Pause_Base_Resolution_Width", "1920") 
        pauseHeightBaseRes := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Pause_Base_Resolution_Height", "1080") 
        pauseWidthRes := pauseWidthBaseRes , pauseHeightRes := pauseHeightBaseRes
        if (((monitorTable[pauseMonitor].Width < monitorTable[pauseMonitor].Height) and ((pauseScreenRotationAngle=0) or (pauseScreenRotationAngle=180))) or ((monitorTable[pauseMonitor].Width > monitorTable[pauseMonitor].Height) and ((pauseScreenRotationAngle=90) or (pauseScreenRotationAngle=270)))){
            pauseWidthRes := pauseHeightBaseRes , pauseHeightRes := pauseWidthBaseRes
        }
        Pause_XScale := baseScreenWidth/pauseWidthRes
        Pause_YScale := baseScreenHeight/pauseHeightRes
        RLLog.Debug(A_ThisLabel . " - Pause screen scale factor: X=" . Pause_XScale . ", Y= " . Pause_YScale)
    }
    If !disableSuspendEmu { ;Suspending emulator process while in Pause (pauses the emulator If halemu does not contain pause controls)
		If (rlMode != "pause")	; On Pause mode, emulatorProcessName = RocketLauncher.exe and obviously can't be suspended
			ProcSus(emulatorProcessName)
	}
	LEDBlinky("RL")	; trigger ledblinky profile change if enabled
	KeymapperProfileSelect("RL", keyboardEncoder, winIPACFullPath, "ipc", "keyboard")
	KeymapperProfileSelect("RL", "UltraMap", ultraMapFullPath, "ugc")
    Pause_BeginTime := A_TickCount ;start to count the time expent in the pause menu for statistics purposes
    RLLog.Debug(A_ThisLabel . " - Setting Pause starting time for subtracting from statistics played time: " Pause_BeginTime)
    If !disableLoadScreen ;updating Pause_GUI21 for loading screen message If not disabled in the module 
        If !(disableActivateBlackScreen and Pause_Disable_Menu="true")
            gosub, LoadingPauseScreen
    RLLog.Debug(A_ThisLabel . " - Loading screen created")
    If (disableActivateBlackScreen and Pause_Disable_Menu="true") { ;Stop Pause Drawn If menu shouldnt be drawn (Pause key just pauses the emu)
        Pause_Active:=true ;Pause menu active (fully loaded)
        XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
        XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","ON")
        Return
    }
    if !(Pause_Loaded) {
        Pause_ChangeRes := RIniPauseLoadVar("P","P_sys", "General Options", "Force_Resolution_Change", "") 
		Pause_MonitorObj := ConvertToMonitorObject(pauseMonitor . "|" . Pause_ChangeRes)	; Convert to object
        Pause_ForcedRes := CheckForNearestSupportedRes( pauseMonitor,Pause_MonitorObj )
	}
    if Pause_ForcedRes[pauseMonitor].Width
        {
        Pause_MonitorRestorObj := GetDisplaySettings()	; store object with current display parameters
		Pause_Res := ConvertToMonitorObject(pauseMonitor . "|" . Pause_ForcedRes[pauseMonitor].Width . "|" . Pause_ForcedRes[pauseMonitor].Height . "|" . Pause_ForcedRes[pauseMonitor].BitDepth . "|" . Pause_ForcedRes[pauseMonitor].Frequency)
        SetDisplaySettings(Pause_Res)
    }
    If !(Pause_Loaded){
        gosub, LoadExternalVariables ;Loading external variables and paths for the first time
        RLLog.Debug(A_ThisLabel . " - Loaded Pause options")
        PauseOptionsScale() ;Setting scalling parameters and scalling variables        
        RLLog.Debug(A_ThisLabel . " - Scaled Pause variables")
        gosub, FirstTimePauseRun ;Loading variables on first run        
        RLLog.Debug(A_ThisLabel . " - Initilized Pause variables for the first time")
        SavedKeyDelay := A_KeyDelay ;Saving previous key delay and setting the new one for save and load state commands
    }
    If (pauseOnPrimaryMonitor or !Pause_Loaded) {   ; initialize pause menu if pause is not already drawn to secondary screen
        GoSub, InitializePauseMainMenu ;Initializing the main menu and creating Pause Guis
        RLLog.Debug(A_ThisLabel . " - Initialized Pause brushes and guis")

        Gosub DrawMainMenu ;Drawing the main menu background and game information
        Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22,0,0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,  monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Alt_UpdateLayeredWindow(Pause_hwnd23, Pause_hdc23,0,0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        RLLog.Debug(A_ThisLabel . " - Loaded Main Menu Background and infos")
        Gosub DrawMainMenuBar ;Drawing the main menu bar
        Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        RLLog.Debug(A_ThisLabel . " - Loaded Main Menu Bar. Current Main Menu Label: " Pause_MainMenuSelectedLabel)
        If(Pause_MainMenu_ShowClock="true"){ ;Drawing the clock
            SetTimer, Clock, 1000
            RLLog.Debug(A_ThisLabel . " - Loaded Clock")
        }
    }
    If !(Pause_MuteSound="true"){ 
        If(Pause_MuteWhenLoading="true"){ ;Unmuting If initial state was unmuted
            If !(PauseEmuInitialMuteState){
                getMute(CurrentMuteState,emulatorVolumeObject)
                If(CurrentMuteState=1){
                    setMute(0,emulatorVolumeObject)
                    RLLog.Debug(A_ThisLabel . " - Unmuting emulator sound while Pause is loaded. Emulator Mute status: " getMute(,emulatorVolumeObject) " (0 is unmutted)")
                }
            }  
        }
    }   
	If(Pause_MusicPlayerEnabled = "true"){ ;Loading music player 
		gosub, Pause_MusicPlayer
        RLLog.Debug(A_ThisLabel . " - Loaded Music Player")
    }
    XHotKeywrapper(navLeftKey,"MoveLeft","ON")
    XHotKeywrapper(navRightKey,"MoveRight","ON")
    XHotKeywrapper(navUpKey,"MoveUp","ON")
    XHotKeywrapper(navDownKey,"MoveDown","ON")
    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON") ;Activating Pause Menu Hotkeys
    XHotKeywrapper(navP2LeftKey,"MoveLeft","ON")
    XHotKeywrapper(navP2RightKey,"MoveRight","ON")
    XHotKeywrapper(navP2UpKey,"MoveUp","ON")
    XHotKeywrapper(navP2DownKey,"MoveDown","ON")
    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON")
    XHotKeywrapper(pauseBackToMenuBarKey,"BacktoMenuBar","ON")
    XHotKeywrapper(pauseZoomInKey,"ZoomIn","ON")
    XHotKeywrapper(pauseZoomOutKey,"ZoomOut","ON")
    XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
    XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","ON")
    If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true")
        {
        RunKeymapper%zz%("menu",keymapper)
        Loop, 10 { ;Activating Pause Screen
            CurrentGUI := A_Index+21
            WinActivate, pauseLayer%CurrentGUI%
        }
    }
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("menu")
    SetTimer, UpdateDescription, 15  ;Setting timer for game description scroling text
    SetTimer, SubMenuUpdate, 100  ;Setting timer for submenu apearance
    ; Clearing Loading Pause Screen
    If (pauseOnPrimaryMonitor){    
        Gdip_GraphicsClear(Pause_G21)
        Alt_UpdateLayeredWindow(Pause_hwnd21, Pause_hdc21, 0, 0, loadBaseScreenWidth, loadBaseScreenHeight,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)
    } else {
        Gdip_GraphicsClear(Pause_G21)
        Gdip_Alt_FillRectangle(Pause_G21, Pause_MainMenu_BackgroundBrushV, 0, 0, loadBaseScreenWidth+2, loadBaseScreenHeight+2,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight) 
        PauseGameText_Font := "Bebas Neue"
        PauseGameText_FontSize := "100"
        PauseGameText_FontColor := "ffaaaaaa"
        OptionScale(PauseGameText_FontSize, Pause_Load_YScale)
        Gdip_Alt_TextToGraphics(Pause_G21, "Game Paused", "x" . loadBaseScreenWidth//2 . " y" . (loadBaseScreenHeight - Pause_AuxiliarScreen_FontSize)//2 . " Center c" . PauseGameText_FontColor . " r4 s" . PauseGameText_FontSize, PauseGameText_Font,0,0,,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight)
        Alt_UpdateLayeredWindow(Pause_hwnd21, Pause_hdc21, 0, 0, loadBaseScreenWidth, loadBaseScreenHeight,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)
    }
    Gdip_GraphicsClear(Pause_G21b)
    Alt_UpdateLayeredWindow(Pause_hwnd21b, Pause_hdc21b, 0, 0, loadBaseScreenWidth, loadBaseScreenHeight,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)
    ;Initilaizing Mouse Overlay Controls
    If(Pause_EnableMouseControl = "true") {
        Gdip_Alt_DrawImage(Pause_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
        Alt_UpdateLayeredWindow(Pause_hwnd32, Pause_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,Pause_MouseControlTransparency,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        hotkey, LButton, pauseMouseClick
    }
    Pause_Active := true ;Pause menu active (fully loaded)
    Pause_Loaded := 1 ;Pause menu fully loaded at least one time
    RLLog.Info(A_ThisLabel . " - Finished Loading Pause")
    BroadcastMessage("RocketLauncher Message: Game Paused.")
Return

HideFrontEnd: ;Hide FrontEnd with a black Gui
    Pause_Load_Background_Color := "ff000000"
    Pause_Load_Background_Brush := Gdip_BrushCreateSolid("0x" . Pause_Load_Background_Color)
    Gui, Pause_GUI21: New, +HwndPause_hwnd21 +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, PauseBlackScreen
    Pause_hbm21 := CreateDIBSection(originalWidth, originalHeight)
    Pause_hdc21 := CreateCompatibleDC()
    Pause_obm21 := SelectObject(Pause_hdc21, Pause_hbm21)
    Pause_G21 := Gdip_GraphicsFromhdc(Pause_hdc21)
    Gdip_FillRectangle(Pause_G21, Pause_Load_Background_Brush, 0, 0, originalWidth+1, originalHeight+1)
    Gui, Pause_GUI21: Show, na
    UpdateLayeredWindow(Pause_hwnd21, Pause_hdc21, 0, 0, originalWidth, originalHeight)
Return

LoadingPauseScreen: ;Drawning Loading Pause Message
    Gdip_GraphicsClear(Pause_G21)
    ;Acquiring screen info for dealing with rotated menu drawings
    Gdip_Alt_GetRotatedDimensions(originalWidth, originalHeight, screenRotationAngle, loadBaseScreenWidth, loadBaseScreenHeight)
    Gdip_GetRotatedTranslation(loadBaseScreenWidth, loadBaseScreenHeight, screenRotationAngle, loadXTranslation, loadYTranslation)
    loadXTranslation:=round(loadXTranslation), loadYTranslation:=round(loadYTranslation)
    Gdip_TranslateWorldTransform(Pause_G21, loadXTranslation, loadYTranslation)
    Gdip_RotateWorldTransform(Pause_G21, screenRotationAngle)
    pGraphUpd(Pause_G21,loadBaseScreenWidth,loadBaseScreenHeight)
    loadPauseWidthBaseRes := pauseWidthBaseRes , loadPauseHeightBaseRes := pauseHeightBaseRes
    if (((originalWidth < originalHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((originalWidth > originalHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270)))){
        loadPauseWidthBaseRes := pauseHeightBaseRes , loadPauseHeightBaseRes := pauseWidthBaseRes
    }
    Pause_Load_XScale := loadBaseScreenWidth/loadPauseWidthBaseRes
    Pause_Load_YScale := loadBaseScreenHeight/loadPauseHeightBaseRes
    ;creating graphic elements
    Gdip_Alt_FillRectangle(Pause_G21, Pause_Load_Background_Brush, 0, 0, loadBaseScreenWidth+1, loadBaseScreenHeight+1,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight)
    Pause_AuxiliarScreen_StartText := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Loading_Text", "Loading Pause")
    Pause_AuxiliarScreen_ExitText := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Exiting_Text", "Exiting Pause")
    Pause_AuxiliarScreen_Font := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Font", "Bebas Neue")
    Pause_AuxiliarScreen_FontSize := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Font_Size", "45")
    Pause_AuxiliarScreen_FontColor := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Font_Color", "ff222222")
    Pause_AuxiliarScreen_ExitTextMargin := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Text_Margin", "65")
    CheckFont(Pause_AuxiliarScreen_Font)
    OptionScale(Pause_AuxiliarScreen_FontSize, Pause_Load_YScale)
    OptionScale(Pause_AuxiliarScreen_ExitTextMargin, Pause_Load_XScale)
    AuxiliarScreenTextX := Pause_AuxiliarScreen_ExitTextMargin
    AuxiliarScreenTextY := loadBaseScreenHeight - Pause_AuxiliarScreen_ExitTextMargin - Pause_AuxiliarScreen_FontSize
    OptionsLoadPause := "x" . AuxiliarScreenTextX . " y" . AuxiliarScreenTextY . " Left c" . Pause_AuxiliarScreen_FontColor . " r4 s" . Pause_AuxiliarScreen_FontSize . " bold"
    Gdip_Alt_TextToGraphics(Pause_G21, Pause_AuxiliarScreen_StartText, OptionsLoadPause, Pause_AuxiliarScreen_Font,0,0,,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight)
    Alt_UpdateLayeredWindow(Pause_hwnd21, Pause_hdc21, 0, 0, loadBaseScreenWidth, loadBaseScreenHeight,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)
    ;creating dynamic loading text gui
    Gui, Pause_GUI21b: New, +HwndPause_hwnd21b +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, pauseLayer21b
    Pause_hbm21b := CreateDIBSection(originalWidth, originalHeight)
    Pause_hdc21b := CreateCompatibleDC()
    Pause_obm21b := SelectObject(Pause_hdc21b, Pause_hbm21b)
    Pause_G21b := Gdip_GraphicsFromhdc(Pause_hdc21b)
    Gdip_TranslateWorldTransform(Pause_G21b, loadXTranslation, loadYTranslation)
    Gdip_RotateWorldTransform(Pause_G21b, screenRotationAngle)
    Gui, Pause_GUI21b: Show, na
Return
   

FirstTimePauseRun: ;Loading pause menu variables (first time run only)
    LoadingText("Initializing...")
    SelectedMenuOption := ""	; Loading auxiliar parameters
    Pause_MainMenuItem := 1
    FullScreenView := 0
    VSubMenuItem := 0
    V2SubMenuItem := 1
    HSubMenuItem := 1
    ZoomLevel := 100
    HorizontalPanFullScreen := 0
    VerticalPanFullScreen := 0
    TotalSubMenuGuidesPages := 0 
    TotalSubMenuManualsPages := 0 
    TotalSubMenuHistoryPages := 0 
    TotalSubMenuControllerPages := 0 
    TotalSubMenuArtworkPages := 0 
    filesToBeDeleted := ""
    FileRemoveDir, %Pause_GuidesTempPath%, 1	; Removing temp folders for pdf and compressed files
    FileRemoveDir, %Pause_ManualsTempPath%, 1
    FileRemoveDir, %Pause_ArtworkTempPath%, 1
    FileRemoveDir, %Pause_ControllerTempPath%, 1 
    Lettersandnumbers := "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9,/,\"	; List of letters and numbers for using in line validation on moves list
    ;Description name without (Disc X)
    If (!romTable && mgCandidate)
        romTable:=CreateRomTable(dbName)
    Totaldiscsofcurrentgame:=romTable.MaxIndex()
    If (Totaldiscsofcurrentgame>1){ 
        DescriptionNameWithoutDisc := romTable[1,4]
    } else {
        DescriptionNameWithoutDisc := dbName
    }
    ;Defining supported files in txt, pdf and images menu
    Supported_Images := "png"
    If (Pause_SupportAdditionalImageFiles="true")
        Supported_Images := "png,gif,tif,bmp,jpg"
    Supported_Extensions := Supported_Images . ",pdf,txt," . sevenZFormatsNoP . ",cbr,cbz"
    StringReplace, CommaSeparated_MusicFilesExtension, Pause_MusicFilesExtension, |,`,, All
    ;checking for bad written labels and non included labels (and adding them to the end of Pause_MainMenu_Itens)
    CheckedPause_MainMenu_Labels := ""
    Loop, parse, Pause_MainMenu_Itens,|
        {
        If A_LoopField in Controller,Change Disc,Save State,Load State,HighScore,Artwork,Guides,Manuals,Videos,Sound,Statistics,Moves List,History,Settings,Shutdown
            CheckedPause_MainMenu_Labels := CheckedPause_MainMenu_Labels . A_LoopField . "|"
    }
    If !(CheckedPause_MainMenu_Labels = Pause_MainMenu_Itens . "|")
        RLLog.Warning("You have a Main Menu item not found or bad written in the Main Menu items list:`r`n`t`t`t`t`t Original Ini Main Menu list: " Pause_MainMenu_Itens "`r`n`t`t`t`t`t Corrected Main Menu list:    " CheckedPause_MainMenu_Labels)
    Pause_MainMenu_Itens := CheckedPause_MainMenu_Labels
    ; removing menu items not needed on Pause only call 
    If (rlMode = "pause"){
        if InStr(Pause_MainMenu_Itens,"Save State")
            StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Save State|,
        if InStr(Pause_MainMenu_Itens,"Load State")
            StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Load State|,
        if InStr(Pause_MainMenu_Itens,"Change Disc")
            StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Change Disc|, ;
    }
    ;loading extra FE media assets
    if !(additionalFEAssetsLoaded){
        LoadingText("Loading FrontEnd media assets...")
        loadAdditionalFEAssets%zz%()
    }
    ;loading general image paths
    LoadingText("Loading Logos and Backgrounds...")
    LogoImageList := []
    If FileExist(RLMediaPath . "\Logos\" . systemname . "\" . dbname . "\*.*")
        Loop, parse, Supported_Images,`,
            Loop, % RLMediaPath . "\Logos\" . systemname . "\" . dbname . "\*." . A_LoopField
                LogoImageList.Insert(A_LoopFileFullPath)
    If !LogoImageList[1]
        If FileExist(RLMediaPath . "\Logos\" . systemname . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,
                Loop, % RLMediaPath . "\Logos\" . systemname . "\" . DescriptionNameWithoutDisc . "\*." . A_LoopField
                    LogoImageList.Insert(A_LoopFileFullPath)
    If !LogoImageList[1]
    {
        for index, element in feMedia["Logos"]
        {   if element.Label
            {   if (element.AssetType="game")
                {   loop, % element.TotalItems    
                    {    LogoImageList.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    PauseImage := Pause_IconsImagePath . "\Pause.png"
    SoundImage := Pause_IconsImagePath . "\Sound.png"
    MuteImage := Pause_IconsImagePath . "\Mute.png"
    ToggleONImage := Pause_IconsImagePath . "\Toggle_ON.png"
    ToggleOFFImage := Pause_IconsImagePath . "\Toggle_OFF.png"
    ;loading pause main menu logo
    pauseMainMenuLogo := {}
    origMenuList := "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown"
    Loop, Parse, origMenuList, |
    {   tempArray := []
        currentMenuLabel  := A_LoopField
        If FileExist(RLMediaPath . "\Pause\Menu Logos\" . systemname . "\" . dbname . "\" . currentMenuLabel . " - selected.*")
            Loop, parse, Supported_Images,`,
                Loop, % RLMediaPath . "\Pause\Menu Logos\" . systemname . "\" . dbname . "\" . currentMenuLabel . " - selected." . A_LoopField
                    tempArray.Insert(A_LoopFileFullPath)
        If !tempArray[1]
            If (Totaldiscsofcurrentgame>1)
                If FileExist(RLMediaPath . "\Pause\Menu Logos\" . systemname . "\" . DescriptionNameWithoutDisc . "\" . currentMenuLabel . " - selected.*")
                    Loop, parse, Supported_Images,`,
                        Loop, % RLMediaPath . "\Pause\Menu Logos\" . systemname . "\" . DescriptionNameWithoutDisc . "\" . currentMenuLabel . " - selected." . A_LoopField
                            tempArray.Insert(A_LoopFileFullPath)
        If !tempArray[1]
            if ((Pause_UseParentGameMediaAssets="true") and (gameInfo["CloneOf"].Value))
                If FileExist(RLMediaPath . "\Pause\Menu Logos\" . systemname . "\" . gameInfo["CloneOf"].Value . "\" . currentMenuLabel . " - selected.*")
                    Loop, parse, Supported_Images,`,
                        Loop, % RLMediaPath . "\Pause\Menu Logos\" . systemname . "\" . gameInfo["CloneOf"].Value . "\" . currentMenuLabel . " - selected." . A_LoopField
                            tempArray.Insert(A_LoopFileFullPath)
        If !tempArray[1]
            If FileExist(RLMediaPath . "\Pause\Menu Logos\" . systemname . "\_Default\" . currentMenuLabel . " - selected.*")
                Loop, parse, Supported_Images,`,
                    Loop, % RLMediaPath . "\Pause\Menu Logos\" . systemname . "\_Default\" . currentMenuLabel . " - selected." . A_LoopField
                        tempArray.Insert(A_LoopFileFullPath)                
        If !tempArray[1]
            If FileExist(RLMediaPath . "\Pause\Menu Logos\_Default\" . currentMenuLabel . " - selected.*")
                Loop, parse, Supported_Images,`,
                    Loop, % RLMediaPath . "\Pause\Menu Logos\_Default\" . currentMenuLabel . " - selected." . A_LoopField
                        tempArray.Insert(A_LoopFileFullPath)            
        If (tempArray[1]) {
            Random, RndmLogoImage, 1, % tempArray.MaxIndex()
            logoPathSelected := tempArray[RndmLogoImage]
            pauseMainMenuLogo[currentMenuLabel] := {}
            pauseMainMenuLogo[currentMenuLabel].ImagePath := logoPathSelected
            pauseMainMenuLogo[currentMenuLabel].selectedBitmap := Gdip_CreateBitmapFromFile(pauseMainMenuLogo[currentMenuLabel].ImagePath)
            pauseMainMenuLogo[currentMenuLabel].Width := Gdip_GetImageWidth(pauseMainMenuLogo[currentMenuLabel].selectedBitmap)
            pauseMainMenuLogo[currentMenuLabel].Height := Gdip_GetImageHeight(pauseMainMenuLogo[currentMenuLabel].selectedBitmap)
            pauseMainMenuLogo[currentMenuLabel].resizedWidth := pauseMainMenuLogo[currentMenuLabel].Width * Pause_MainMenu_BarHeight / pauseMainMenuLogo[currentMenuLabel].Height
            pauseMainMenuLogo[currentMenuLabel].resizedHeight := Pause_MainMenu_BarHeight      
            SplitPath, logoPathSelected, , OutDir, ext
            if FileExist(OutDir . "\" . currentMenuLabel . " - disabled." . ext)
                pauseMainMenuLogo[currentMenuLabel].disabledBitmap := Gdip_CreateBitmapFromFile( OutDir . "\" . currentMenuLabel . " - disabled." . ext )
            else
                pauseMainMenuLogo[currentMenuLabel].disabledBitmap := pauseMainMenuLogo[currentMenuLabel].selectedBitmap
        }    
    }
    RLLog.Debug(A_ThisLabel . " - Starting Creating Pause Contents Object.")
    ;loading background image paths
    PauseBackground := []
    if (((monitorTable[pauseMonitor].Width < monitorTable[pauseMonitor].Height) and ((pauseScreenRotationAngle=0) or (pauseScreenRotationAngle=180))) or ((monitorTable[pauseMonitor].Width > monitorTable[pauseMonitor].Height) and ((pauseScreenRotationAngle=90) or (pauseScreenRotationAngle=270))))
		screenVerticalOrientation := "true"
	
    If FileExist(Pause_BackgroundsPath . "\" . systemName . "\"  . dbName . "\*.*")
        Loop, parse, Supported_Images,`,
            Loop, % Pause_BackgroundsPath . "\" . systemName . "\" . dbName . "\*." . A_LoopField
                PauseBackground.Insert(A_LoopFileFullPath)
    If !PauseBackground[1]
        If (gameInfo["Cloneof"].Value)
            If FileExist(Pause_BackgroundsPath . "\" . systemName . "\"  . gameInfo["Cloneof"].Value . "\*.*")
                Loop, parse, Supported_Images,`,
                    Loop, % Pause_BackgroundsPath . "\" . systemName . "\" . gameInfo["Cloneof"].Value . "\*." . A_LoopField
                        PauseBackground.Insert(A_LoopFileFullPath)
    If !PauseBackground[1]
        If FileExist(Pause_BackgroundsPath . "\" . systemName . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,
                Loop, % Pause_BackgroundsPath . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\*." . A_LoopField
                    PauseBackground.Insert(A_LoopFileFullPath)
    If !PauseBackground[1]
    {
        for index, element in feMedia["Backgrounds"]
        {   if element.Label
            {   if (element.AssetType="game")
                {   loop, % element.TotalItems    
                    {   PauseBackground.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    If !PauseBackground[1]
    {   if (screenVerticalOrientation)
        {   If FileExist(Pause_BackgroundsPath . "\" . systemName . "\_Default\Vertical\*.*")
                Loop, parse, Supported_Images,`,
                    Loop, % Pause_BackgroundsPath . "\" . systemName . "\_Default\Vertical\*." . A_LoopField
                        PauseBackground.Insert(A_LoopFileFullPath)
        } else {
           If FileExist(Pause_BackgroundsPath . "\" . systemName . "\_Default\Horizontal\*.*")
                Loop, parse, Supported_Images,`,
                    Loop, % Pause_BackgroundsPath . "\" . systemName . "\_Default\Horizontal\*." . A_LoopField
                        PauseBackground.Insert(A_LoopFileFullPath)
        }
    }
    If !PauseBackground[1]
        If FileExist(Pause_BackgroundsPath . "\" . systemName . "\_Default\*.*")
            Loop, parse, Supported_Images,`,
                Loop, % Pause_BackgroundsPath . "\" . systemName . "\_Default\*." . A_LoopField
                    PauseBackground.Insert(A_LoopFileFullPath)
    If !PauseBackground[1]
    {
        for index, element in feMedia["Backgrounds"]
        {   if element.Label
            {   if (element.AssetType="system")
                {   loop, % element.TotalItems    
                    {    PauseBackground.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    If !PauseBackground[1]
    {   if (screenVerticalOrientation)
        {   If FileExist(Pause_BackgroundsPath . "\_Default\Vertical\*.*")
                Loop, parse, Supported_Images,`,
                    Loop, % Pause_BackgroundsPath . "\_Default\Vertical\*." . A_LoopField
                        PauseBackground.Insert(A_LoopFileFullPath)
        } else {
           If FileExist(Pause_BackgroundsPath . "\_Default\Horizontal\*.*")
                Loop, parse, Supported_Images,`,
                    Loop, % Pause_BackgroundsPath . "\_Default\Horizontal\*." . A_LoopField
                        PauseBackground.Insert(A_LoopFileFullPath)
        }
    }
    If !PauseBackground[1]
        If FileExist(Pause_BackgroundsPath . "\_Default\*.*")
            Loop, parse, Supported_Images,`,
                Loop, % Pause_BackgroundsPath . "\_Default\*." . A_LoopField, 0
                    PauseBackground.Insert(A_LoopFileFullPath)
    
    if !PauseMediaObj
        PauseMediaObj := []
    Loop, parse, Pause_MainMenu_Itens,|, ;Loading Submenu information and excluding empty sub menus
        {
        StringReplace, temp_mainmenulabel, A_LoopField, %A_SPACE%,, All
        If (temp_mainmenulabel="Artwork"){
            RLLog.Debug(A_ThisLabel . " - Loading Artwork Contents")
            LoadingText("Loading Artwork...")
            If (Pause_ArtworkMenuEnabled="true"){
                PauseMediaObj.Artwork := CreateSubMenuMediaObject("Artwork")
                ;MultiContentSubMenuList("Artwork") ;Creating Artwork list
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Artwork|, ;Removing Artwork menu If user defined to not show it
            }
        }
        If (temp_mainmenulabel="Controller"){
            RLLog.Debug(A_ThisLabel . " - Loading Controller Contents")
            If (Pause_ControllerMenuEnabled="true"){
                LoadingText("Loading Controller...")
                PauseMediaObj.Controller := CreateSubMenuMediaObject("Controller")
                ;config menu parameters
                If (keymapperEnabled = "true") {
                    WidthofConfigMenuLabel := MeasureText("Control Config"," Center r4 s" . Pause_SubMenu_FontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour
                    ConfigMenuX := (baseScreenWidth-(WidthofConfigMenuLabel+Pause_SubMenu_AdditionalTextMarginContour))//2
                    ConfigMenuY := (baseScreenHeight-Pause_MainMenu_BarHeight)//2-(Pause_SubMenu_FontSize+Pause_SubMenu_AdditionalTextMarginContour)+2
                    ConfigMenuWidth := WidthofConfigMenuLabel+Pause_SubMenu_AdditionalTextMarginContour
                    ConfigMenuHeight := Pause_SubMenu_FontSize+Pause_SubMenu_AdditionalTextMarginContour
                }
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Controller|, ;Removing Controller menu If user defined to not show it
            }
        }
        If ((temp_mainmenulabel="SaveState")or(temp_mainmenulabel="LoadState")){
            RLLog.Debug(A_ThisLabel . " - Loading " temp_mainmenulabel " Contents")
            If (Pause_SaveandLoadMenuEnabled="true"){
                LoadingText("Loading " temp_mainmenulabel "...")
                count := 0
                loop, 10
                    {
                    currentLabel := temp_mainmenulabel . "Slot" . a_index
                    if IsLabel(currentLabel) {
                        count++
                        RLLog.Debug(A_ThisLabel . " - " . temp_mainmenulabel . " - Loading " . temp_mainmenulabel . " Slot " . a_index . " from module code.") 
                    }
                }
                if (count=0) {
                    Loop, parse, pause%temp_mainmenulabel%KeyCodes,|, ;counting total save and load state slots
                    {   count++
                        RLLog.Debug(A_ThisLabel . " - " . temp_mainmenulabel . " - Loading " . temp_mainmenulabel . " Slot " . a_index . " from keyboard codes.") 
                    }
                }
                currentObj := {}
                currentObj["TotalLabels"] := count
                PauseMediaObj.Insert(temp_mainmenulabel, currentObj)
                If (PauseMediaObj[temp_mainmenulabel].TotalLabels<1){ ;Removing Save and Load State menus If no contents found 
                    RLLog.Debug(A_ThisLabel . " - " . temp_mainmenulabel . " - No " . temp_mainmenulabel . " slot defined either on the module labels or in the emulator keyboard codes.")
                    If (temp_mainmenulabel="SaveState")
                        StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Save State|,
                    Else
                        StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Load State|,
                } else 
                    RLLog.Debug(A_ThisLabel . " - " . temp_mainmenulabel . " - Number of " . temp_mainmenulabel . " slots loaded: " . PauseMediaObj[temp_mainmenulabel].TotalLabels)
            } Else { ;Removing Save and Load State menus If user defined to not show it
                RLLog.Debug(A_ThisLabel . " - " . temp_mainmenulabel . " - " . temp_mainmenulabel . " menu removed by user definition.")
                If (temp_mainmenulabel="SaveState")
                    StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Save State|,
                Else
                    StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Load State|,
            }
        }
        If (temp_mainmenulabel="ChangeDisc"){
            RLLog.Debug(A_ThisLabel . " - Loading Change Disc Contents")
            If (Pause_ChangeDiscMenuEnabled="true"){
                LoadingText("Loading Change Disc...")
                currentObj := {}
                currentObj["TotalLabels"] := Totaldiscsofcurrentgame
                PauseMediaObj.Insert(temp_mainmenulabel, currentObj) ;Checking If the game is a multi Disc game, loading images and counting total disc sub menu items
                If (Totaldiscsofcurrentgame>1){
                    If romExtensionOrig contains %sevenZFormats%
                        If (sevenZEnabled = "true")
                            romNeeds7z := 1
                } Else {
                    StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Change Disc|, ;Removing change disc submenu If the game is not a multi disc game  
                }
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Change Disc|, ;Removing change disc submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="HighScore"){
            RLLog.Debug(A_ThisLabel . " - Loading HighScore Contents")
            If(Pause_HighScoreMenuEnabled="true"){
                LoadingText("Loading HighScore...")
                HighScoreText := StdoutToVar_CreateProcess(pauseHiToTextPath . " -ra " . """" . emuPath . "\hi\" . dbName . ".hi" . """","",pauseHitoTextDir) ;Loading HighScore information
                StringReplace, HighScoreText, HighScoreText, %a_space%,,all
                stringreplace, HighScoreText, HighScoreText, `r`n,¡,all
                stringreplace, HighScoreText, HighScoreText, ¡¡,,all
                count := 0
                Loop, parse, HighScoreText,¡, ,all
                    {
                    count++
                    PauseMediaObj[temp_mainmenulabel].TotalLabels := A_Index-1
                }
                currentObj := {}
                currentObj["TotalLabels"] := count-1
                PauseMediaObj.Insert(temp_mainmenulabel, currentObj) 
                IfNotInString, HighScoreText, RANK ;Removing high score submenu If no high score information is found
                    {
                    StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, HighScore|,
                }                
            } Else { ;Removing high score submenu If user defined to not show it
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, HighScore|,
            }
        }
        If(temp_mainmenulabel="MovesList"){
            RLLog.Debug(A_ThisLabel . " - Loading MovesList Contents")
            If(Pause_MovesListMenuEnabled="true"){
                If FileExist(Pause_MovesListDataPath . "\" . systemName . ".dat") ;Loading Moves List
                    {
                    LoadingText("Loading MovesList...")
                    FileRead, CommandDatFileContents, %Pause_MovesListDataPath%\%systemName%.dat
                    CommandDatFileContents := RegExReplace(CommandDatFileContents, "i)info=\s*" . dbName . "\b\s*", "BeginofMovesListRomData",1) 
                    FoundPos := RegExMatch(CommandDatFileContents, "BeginofMovesListRomData")
                    If !FoundPos {
                        If (gameInfo["Cloneof"].Label)
                            CommandDatFileContents := RegExReplace(CommandDatFileContents, "i)info=\s*" . gameInfo["Cloneof"].Value . "\b\s*", "BeginofMovesListRomData",1) 
                    }
                    RomCommandDatText := StrX(CommandDatFileContents,"$BeginofMovesListRomData",1,0,"$info",1,0)
                    If RomCommandDatText
                        {
                        ReadMovesListInformation()
                    } Else {
                        StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Moves List|, ;Removing the moves list submenu If the game is not founded in the system.dat 
                    }
                } Else {
                    StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Moves List|, ;Removing the moves list submenu If the system.dat is not found
                }
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Moves List|, ;Removing the moves list submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Guides"){
            RLLog.Debug(A_ThisLabel . " - Loading Guides Contents")
            If(Pause_GuidesMenuEnabled="true"){
                LoadingText("Loading Guides...")
                PauseMediaObj.Guides := CreateSubMenuMediaObject("Guides")
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Guides|, ;Removing the guides submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Manuals"){
            RLLog.Debug(A_ThisLabel . " - Loading Manuals Contents")
            If(Pause_ManualsMenuEnabled="true"){
                LoadingText("Loading Manuals...")
                PauseMediaObj.Manuals := CreateSubMenuMediaObject("Manuals")
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Manuals|, ;Removing the manuals submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Videos"){
            RLLog.Debug(A_ThisLabel . " - Loading Videos Contents")
            If(Pause_VideosMenuEnabled="true"){
                LoadingText("Loading Videos...")
                StringReplace, ListofSupportedVideos, Pause_SupportedVideos, |, `,, All
                PauseMediaObj.Videos := CreateSubMenuMediaObject("Videos")
                ;VideoButtonImages
                PauseVideoImage1 := Pause_IconsImagePath . "\VideoPlayerPlay.png"
                PauseVideoImage2 := Pause_IconsImagePath . "\VideoPlayerFullScreen.png"
                PauseVideoImage3 := Pause_IconsImagePath . "\VideoPlayerRewind.png"
                PauseVideoImage4 := Pause_IconsImagePath . "\VideoPlayerFastForward.png"
                PauseVideoImage5 := Pause_IconsImagePath . "\VideoPlayerStop.png"
                PauseVideoImage6 := Pause_IconsImagePath . "\VideoPlayerPause.png"
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Videos|, ;Removing the videos submenu If user defined to not show it
            }
        }        
        If (temp_mainmenulabel="Sound"){
            If (Pause_SoundMenuEnabled="true")
                RLLog.Debug(A_ThisLabel . " - Loading Sound Contents")
            Else
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Sound|, ;Removing the sound submenu If user defined to not show it
        }     
        If (temp_mainmenulabel="Settings"){
            If (Pause_SettingsMenuEnabled="true")
                RLLog.Debug(A_ThisLabel . " - Loading Settings Menu Contents")
            Else
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Settings|, ;Removing the sound submenu If user defined to not show it
        }     
        If(temp_mainmenulabel="Statistics"){
            If  (statisticsEnabled = "true")
                {
                If (Pause_StatisticsMenuEnabled="true"){
                    RLLog.Debug(A_ThisLabel . " - Loading Statistics Contents")
                    LoadingText("Loading Statistics...")
                    if !statisticsLoaded 
                        gosub, LoadStatistics ;Load Game Statistics Information
                    CreatingStatisticsVariablestoSubmenu()
                } Else {
                    StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Statistics|, ;Removing the Statistics submenu If user defined to not show it
                }
            } Else { 
               StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Statistics|, 
           }
        }    
        If (temp_mainmenulabel="History"){
            RLLog.Debug(A_ThisLabel . " - Loading History.dat Contents")
            If (Pause_HistoryMenuEnabled="true"){
                LoadingText("Loading History.dat...")
                PauseMediaObj.History := loadHistoryDataInfo() ;creating History Dat submenu list
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, History|, ;Removing the History Dat submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Shutdown"){
            If(Pause_ShutdownLabelEnabled="true"){
                RLLog.Debug(A_ThisLabel . " - Adding Shutdown Label")
            } Else {
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, Shutdown|, ;Removing Artwork menu If user defined to not show it
            }
        }        
    }    
    LoadingText("Processing Pause Menu Contents...")
    PostProcessingMediaObject(feMedia,PauseMediaObj)
    if InStr(Pause_MainMenu_Itens,"Videos")
        loop, % PauseMediaObj["Videos"].TotalLabels
            VideoPosition%a_index% := 0
    StringTrimRight, Pause_MainMenu_Itens, Pause_MainMenu_Itens, 1 ;Counting total Main Menu items
    Loop, parse, Pause_MainMenu_Itens,|, 
        {
        TotalMainMenuItems := A_Index
    }
    RLLog.Info(A_ThisLabel . " - Pause Menu items: " Pause_MainMenu_Itens)
    If FileExist(Pause_GameInfoPath . "\" . systemName . ".ini") ;Reading game info ini for game information 
        {
        FileRead, GameInfoFileContents, %Pause_GameInfoPath%\%systemName%.ini
        If InStr(GameInfoFileContents, "[" . dbName . "]")
            {
            GameIniKey := dbName
        } Else If InStr(GameInfoFileContents, "[" . DescriptionNameWithoutDisc . "]")
            {
            GameIniKey := DescriptionNameWithoutDisc
        } Else If InStr(GameInfoFileContents, "[" . ClearDescriptionName . "]")
            {
            GameIniKey := ClearDescriptionName
        } Else { ;searching for variations of game name on ini files (&amp;=&, &apos;=', &=and)
            StringReplace, TempDbName, dbName, &amp;, &, All
			StringReplace, TempDbName, dbName, &apos;, ', All 
            StringReplace, TempDescriptionNameWithoutDisc, DescriptionNameWithoutDisc, &amp;, &, All
			StringReplace, TempDescriptionNameWithoutDisc, DescriptionNameWithoutDisc, &apos;, ', All         
            StringReplace, TempClearDescriptionName, ClearDescriptionName, &amp;, &, All
			StringReplace, TempClearDescriptionName, ClearDescriptionName, &apos;, ', All        
            StringReplace, Temp2DbName, TempDbName, &, and, All
            StringReplace, Temp2DescriptionNameWithoutDisc, TempDescriptionNameWithoutDisc, &, and, All
            StringReplace, Temp2ClearDescriptionName, TempClearDescriptionName, &, and, All
            If InStr(GameInfoFileContents, "[" . TempDbName . "]")
                GameIniKey := TempDbName
            Else If InStr(GameInfoFileContents, "[" . TempDescriptionNameWithoutDisc . "]")
                GameIniKey := TempDescriptionNameWithoutDisc
            Else If InStr(GameInfoFileContents, "[" . TempClearDescriptionName . "]")
                GameIniKey := TempClearDescriptionName
            Else If InStr(GameInfoFileContents, "[" . Temp2DbName . "]")
                GameIniKey := Temp2DbName
            Else If InStr(GameInfoFileContents, "[" . Temp2DescriptionNameWithoutDisc . "]")
                GameIniKey := Temp2DescriptionNameWithoutDisc
            Else If InStr(GameInfoFileContents, "[" . Temp2ClearDescriptionName . "]")
                GameIniKey := Temp2ClearDescriptionName
        }
        Loop, parse, Pause_MainMenu_Info_Labels,|, 
            {
            IniRead, %A_LoopField%, %Pause_GameInfoPath%\%systemName%.ini, %GameIniKey%, %A_LoopField%,%A_Space%
            If(%A_LoopField%)
                gameinfoexist := 1
        }
        If !gameinfoexist { ;Look for parent info if game info not found
            Loop, parse, Pause_MainMenu_Info_Labels,|, 
                {        
                IniRead, %A_LoopField%, %Pause_GameInfoPath%\%systemName%.ini, % gameInfo["Cloneof"].Value, %A_LoopField%,%A_Space%
                If(%A_LoopField%)  
                    gameinfoexist := 1
            }
        }
    }
    If !gameinfoexist { ;Look for database xml files info 
        Loop, parse, Pause_MainMenu_Info_Labels,|, 
            %A_loopfield% := gameInfo[A_loopfield].Value
    }
    Loop, parse, Pause_MainMenu_Info_Labels,|,   ; game info complete text
        If (%A_loopfield%)
            If !(A_LoopField="Description")
                TopLeftGameInfoText := % TopLeftGameInfoText . "`r`n" . A_loopfield . "=" . %A_loopfield%
    StringTrimLeft, TopLeftGameInfoText, TopLeftGameInfoText, 2
    posDescriptionY := round((baseScreenHeight+Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset+Pause_MainMenu_Info_Description_FontSize/2
    StringReplace,Description,Description,<br>,%A_Space%,All
    StringLen, DescriptionLength, Description
    Loop, parse, Pause_MainMenu_Itens,|, ;initializing auxiliar page tracking
        {
        StringReplace, temp_mainmenulabel, A_LoopField, %A_SPACE%,, All
        Loop, % PauseMediaObj[temp_mainmenulabel].TotalLabels {    
            HSubmenuitem%temp_mainmenulabel%VSubmenuitem%a_index% := 1
            HSubmenuitem%temp_mainmenulabel%VSubmenuitem%a_index% += 0 
            HSubmenuitem%temp_mainmenulabel%V2Submenuitem%a_index% := 1
            HSubmenuitem%temp_mainmenulabel%V2Submenuitem%a_index% += 0       
        }
    }
    If(Pause_EnableMouseControl = "true") {
        If(Pause_MouseClickSound = "true") {
            MouseSoundsAr:=[]
            Loop, % Pause_MouseSoundPath . "\*.mp3"
                MouseSoundsAr.Insert(A_LoopFileName)
        }
        MouseMaskBitmap := Gdip_CreateBitmapFromFile( Pause_MouseOverlayPath . "\MouseMask.png")
        MouseOverlayBitmap := Gdip_CreateBitmapFromFile( Pause_MouseOverlayPath . "\MouseOverlay.png")
        MouseFullScreenMaskBitmap := Gdip_CreateBitmapFromFile( Pause_MouseOverlayPath . "\MouseFullScreenMask.png")
        MouseFullScreenOverlayBitmap := Gdip_CreateBitmapFromFile( Pause_MouseOverlayPath . "\MouseFullScreenOverlay.png")
        MouseClickImageBitmap := Gdip_CreateBitmapFromFile( Pause_MouseOverlayPath . "\MouseClickImage.png")
        Gdip_GetImageDimensions(MouseOverlayBitmap, MouseOverlayW, MouseOverlayH)
        Gdip_GetImageDimensions(MouseClickImageBitmap, MouseClickImageW, MouseClickImageH)
    }
    ;calculating maximun main bar label size
    Loop, parse, Pause_MainMenu_Itens,|, 
        {
        if (pauseMainMenuLogo[A_LoopField].ImagePath) {
            WidthofPauseLabel := pauseMainMenuLogo[A_LoopField].resizedWidth
        } else
            WidthofPauseLabel := MeasureText(A_LoopField, "Centre r4 s" . Pause_MainMenu_LabelFontsize . " bold",Pause_MainMenu_LabelFont)
        if (WidthofPauseLabel>pauseMainMenuLabelMaxWidth)
            pauseMainMenuLabelMaxWidth := WidthofPauseLabel
    }
    LoadingText("Loading Complete!")
Return

InitializePauseMainMenu: ;Drawing the main menu for the first time (constructing Gui and setting initial parameters)
    ;Loading auxiliar parameters
    MenuChanged := 1
    ItemSelected := 0
    changeDiscMenuLoaded := 0
    ;Loading settings variables
    If (Pause_SettingsMenuEnabled="true"){
        if lockLaunchGame
            initialLockLaunch := lockLaunchGame
        else 
            initialLockLaunch := lockLaunch    
        currentLockLaunch := initialLockLaunch
        current7zDelTemp := sevenZDelTemp
    }
    ;Logo random image
    If LogoImageList[1]
        {
        Random, RndmLogoImage, 1, % LogoImageList.MaxIndex()
        LogoImage := LogoImageList[RndmLogoImage]
    }
    Loop, 3
        HSubmenuitemSoundVSubmenuitem%a_index% := 1
    BlackGradientBrush := Gdip_CreateLineBrushFromRect(-1, round(baseScreenHeight/2-50),baseScreenWidth+2, Pause_MainMenu_BarHeight, "0x" . Pause_MainMenu_BarGradientBrush1, "0x" . Pause_MainMenu_BarGradientBrush2, 1, 1) ;Loading Brushs
    Pause_SubMenu_BackgroundBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_BackgroundBrush)
    Pause_SubMenu_SelectedBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_SelectedBrush)
    Pause_SubMenu_DisabledBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_DisabledBrush)
    Pause_MainMenu_BackgroundBrushV := Gdip_BrushCreateSolid("0x" . Pause_MainMenu_BackgroundBrush)
    Pause_SubMenu_GuidesSelectedBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_GuidesSelectedBrush)
    Pause_SubMenu_ManualsSelectedBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_ManualsSelectedBrush)
    Pause_SubMenu_HistorySelectedBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_HistorySelectedBrush)
    Pause_SubMenu_ControllerSelectedBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_ControllerSelectedBrush)
    Pause_SubMenu_ArtworkSelectedBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_ArtworkSelectedBrush)
    Pause_SubMenu_FullScreenTextBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_FullScreenTextBrush)
    Pause_SubMenu_FullScreenBrushV := Gdip_BrushCreateSolid("0x" . Pause_SubMenu_FullScreenBrush)
    Pause_SubMenu_ControllerSelectedPen := Gdip_CreatePen("0x" . Pause_SubMenu_ControllerSelectedBrush, Pause_SubMenu_Pen_Width)
    If (PauseMediaObj["MovesList"].TotalLabels<>0){ ;Creating Bitmaps
        Loop, % TotalCommandDatImageFiles
            {
            CommandDatBitmap%A_index% := Gdip_CreateBitmapFromFile(CommandDatfile%A_index%)
        }
    }
    Loop, 13 { ;Creating Pause Menu Guis
        CurrentGUI := A_Index+21
        If not (CurrentGUI = 31) {
            If (A_Index=1) {
                Gui, Pause_GUI%CurrentGUI%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop  
            } Else If (A_Index = 11) {
                OwnerGUI := CurrentGUI - 2
                Gui, Pause_GUI%CurrentGUI%: +OwnerPause_GUI%OwnerGUI% +OwnDialogs -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            } Else If (A_Index = 12) {
                OwnerGUI := CurrentGUI - 1
                Gui, Pause_GUI%CurrentGUI%: +OwnerPause_GUI%OwnerGUI% +OwnDialogs -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            } Else {
                OwnerGUI := CurrentGUI - 1
                Gui, Pause_GUI%CurrentGUI%: +OwnerPause_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            }
            Gui, Pause_GUI%CurrentGUI%: Margin,0,0
            Gui, Pause_GUI%CurrentGUI%: Show,, pauseLayer%CurrentGUI%
            Pause_hwnd%CurrentGUI% := WinExist()
            Pause_hbm%CurrentGUI% := CreateDIBSection(monitorTable[pauseMonitor].Width, monitorTable[pauseMonitor].Height)
            Pause_hdc%CurrentGUI% := CreateCompatibleDC()
            Pause_obm%CurrentGUI% := SelectObject(Pause_hdc%CurrentGUI%, Pause_hbm%CurrentGUI%)
            Pause_G%CurrentGUI% := Gdip_GraphicsFromhdc(Pause_hdc%CurrentGUI%)
            Gdip_SetSmoothingMode(Pause_G%CurrentGUI%, 4)
            Gdip_TranslateWorldTransform(Pause_G%CurrentGUI%, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Pause_G%CurrentGUI%, pauseScreenRotationAngle)
        }
    }
    ; Definition of update layers areas needed for screen rotation support of non full screen update area
    ;pGraphUpd(Pause_G21,baseScreenWidth,baseScreenHeight) ;defined before
    pGraphUpd(Pause_G22,baseScreenWidth,baseScreenHeight)
    pGraphUpd(Pause_G23,baseScreenWidth,baseScreenHeight)
    pGraphUpd(Pause_G24,baseScreenWidth,2*Pause_MainMenu_Info_Description_FontSize) ;multiple values handled on code
    pGraphUpd(Pause_G25,baseScreenWidth,Pause_MainMenu_BarHeight) ; multiple values handled on code
    pGraphUpd(Pause_G26,ConfigMenuWidth,ConfigMenuHeight) 
    ;pGraphUpd(Pause_G27,Pause_SubMenu_Width, Pause_SubMenu_Height) ;multiple values handled on code
    ;pGraphUpd(Pause_G28,CurrentTimeTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_MainMenu_ClockFontSize) ; undefined, handled on code
    ;pGraphUpd(Pause_G29, Pause_ControllerFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin) ;multiple values handled on code
    ;pGraphUpd(Pause_G30,Pause_SubMenu_Width, Pause_SubMenu_Height) ;multiple values handled on code
    ;Pause_GUI31 is handled on the code as it is not composed by GDIP elements  
    pGraphUpd(Pause_G32,MouseOverlayW, MouseOverlayH)
    If (PauseMediaObj["Videos"].TotalLabels>0){ ;creating ActiveX video gui
        Gui, Pause_GUI31: +OwnerPause_GUI30 -Caption +LastFound +ToolWindow +AlwaysOnTop
        try Gui, Pause_GUI31: Add, ActiveX, vwmpVideo, WMPLayer.OCX
        catch e
            RLLog.Debug(A_ThisLabel . " - A Windows Media Player Video exception was thrown: " . e)
        try ComObjConnect(wmpVideo, "wmpVideo_")
        catch e
            RLLog.Debug(A_ThisLabel . " - A Windows Media Player Video exception was thrown: " . e)
        try wmpVideo.settings.volume := Pause_VideoPlayerVolumeLevel
        try wmpVideo.settings.autoStart := false
        If(Pause_EnableVideoLoop="true")
            try wmpVideo.Settings.setMode("Loop",true)
        try wmpVideo.settings.enableErrorDialogs := false
        try wmpVideo.uimode := "none"
        try wmpVideo.stretchToFit := true
        If (Pause_Loaded <> 1){
            try wmpVersion := wmpVideo.versionInfo
            RLLog.Debug(A_ThisLabel . " - Windows Media Player Version: " . wmpVersion)
        }
    }
    getVolume(Pause_VolumeMaster)
    If (SelectedMenuOption="Videos"){
        AnteriorFilePath := ""
        V2Submenuitem := 1
        try CurrentVideoPlayStatus := wmpVideo.playState
        If(CurrentVideoPlayStatus=3) {
            try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
            RLLog.Debug(A_ThisLabel . " - VideoPosition at main menu change:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%)
            try wmpVideo.controls.stop
        }
        Gui,Pause_GUI31: Show, Hide
        Gui, Pause_GUI32: Show
    }
Return

;-----------------MENU DRAWING-------------
DrawMainMenu: ;Draw Main Menu Background
    If(Pause_MainMenu_UseScreenshotAsBackground="true"){
        MainMenuBackground := GameScreenshot
        filesToBeDeleted .= GameScreenshot . "|"
        Pause_MainMenu_BackgroundAlign := "Stretch and Lose Aspect" 
    } Else If PauseBackground[1] {
        Random, RndmBackground, 1, % PauseBackground.MaxIndex()
        MainMenuBackground := PauseBackground[RndmBackground]
    }
    If MainMenuBackground {
        ; Creating background base color 
        Pause_Background_Brush := Gdip_BrushCreateSolid("0x" . Pause_MainMenu_Background_Color)
        Gdip_Alt_FillRectangle(Pause_G22, Pause_Background_Brush, -1, -1, originalWidth+1, originalHeight+1) 
        ; Loading Background image
        MainMenuBackgroundBitmap := Gdip_CreateBitmapFromFile(MainMenuBackground)
        Gdip_GetImageDimensions(MainMenuBackgroundBitmap, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        GetBGPicPosition(PauseBGPicXNew,PauseBGYNew,PauseBGWNew,PauseBGHNew,MainMenuBackgroundBitmapW,MainMenuBackgroundBitmapH,Pause_MainMenu_BackgroundAlign)	; get the background pic's new position and size
        If (Pause_MainMenu_BackgroundAlign = "Stretch and Lose Aspect") {	 
            MainMenuBackgroundX := 0
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := baseScreenWidth+1
            MainMenuBackgroundH := baseScreenHeight+1
        } Else If (Pause_MainMenu_BackgroundAlign = "Stretch and Keep Aspect" Or Pause_MainMenu_BackgroundAlign = "Center Width" Or Pause_MainMenu_BackgroundAlign = "Center Height" Or Pause_MainMenu_BackgroundAlign = "Align to Bottom Left" Or Pause_MainMenu_BackgroundAlign = "Align to Bottom Right") {
            MainMenuBackgroundX := PauseBGPicXNew
            MainMenuBackgroundY := PauseBGYNew
            MainMenuBackgroundW := PauseBGWNew+1
            MainMenuBackgroundH := PauseBGHNew+1
        } Else If (Pause_MainMenu_BackgroundAlign = "Center") {	; original image size and aspect
            MainMenuBackgroundX := PauseBGPicXNew
            MainMenuBackgroundY := PauseBGYNew
            MainMenuBackgroundW := MainMenuBackgroundBitmapW+1
            MainMenuBackgroundH := MainMenuBackgroundBitmapH+1
        } Else If (Pause_MainMenu_BackgroundAlign = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
            MainMenuBackgroundX := PauseBGPicXNew
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := PauseBGWNew+1
            MainMenuBackgroundH := PauseBGHNew
        } Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
            MainMenuBackgroundX := 0
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := PauseBGWNew+1
            MainMenuBackgroundH := PauseBGHNew+1
        }
        Gdip_Alt_DrawImage(Pause_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
    }
    Gdip_Alt_FillRectangle(Pause_G23, Pause_MainMenu_BackgroundBrushV, -1, -1, baseScreenWidth+2, baseScreenHeight+2)  
    PauseImageBitmap := Gdip_CreateBitmapFromFile(PauseImage) ;Drawing Main menu bitmaps
    PauseBitmapW := Gdip_GetImageWidth(PauseImageBitmap), PauseBitmapH := Gdip_GetImageHeight(PauseImageBitmap)
    OptionScale(PauseBitmapW, Pause_XScale)
    OptionScale(PauseBitmapH, Pause_XScale)
    Gdip_Alt_DrawImage(Pause_G23, PauseImageBitmap, Pause_Logo_Image_Margin, round((BitmapLogoH-PauseBitmapH)/2),PauseBitmapW,PauseBitmapH)        
    If FileExist(LogoImage) {
        LogoImageBitmap := Gdip_CreateBitmapFromFile(LogoImage)
        BitmapLogoW := Gdip_GetImageWidth(LogoImageBitmap), BitmapLogoH := Gdip_GetImageHeight(LogoImageBitmap)
        If(baseScreenWidth<=1000){
            OptionScale(BitmapLogoW, Pause_XScale)
            OptionScale(BitmapLogoH, Pause_XScale)
            }            
        if (((monitorTable[pauseMonitor].Width < monitorTable[pauseMonitor].Height) and ((pauseScreenRotationAngle=0) or (pauseScreenRotationAngle=180))) or ((monitorTable[pauseMonitor].Width > monitorTable[pauseMonitor].Height) and ((pauseScreenRotationAngle=90) or (pauseScreenRotationAngle=270))))
            LogoImageX := Pause_Logo_Image_Margin, LogoImageY := PauseBitmapH + Pause_Logo_Image_Margin
        else
            LogoImageX := PauseBitmapW + 2*Pause_Logo_Image_Margin, LogoImageY := Pause_Logo_Image_Margin
        Gdip_Alt_DrawImage(Pause_G23, LogoImageBitmap, LogoImageX, LogoImageY,BitmapLogoW,BitmapLogoH)
    }
    color := Pause_MainMenu_Info_FontColor
    posInfoX := baseScreenWidth-Pause_MainMenu_Info_Margin
    posInfoY := Pause_MainMenu_Info_Margin
    If (Pause_MainMenu_ShowClock="true")
        posInfoY := Pause_MainMenu_ClockFontSize
    If LogoImageBitmap
        TopLeftGameInfoWidth := baseScreenWidth - (LogoImageX + BitmapLogoW + Pause_MainMenu_Info_Margin)
    else
        TopLeftGameInfoWidth := baseScreenWidth - (PauseBitmapW + Pause_Logo_Image_Margin + Pause_MainMenu_Info_Margin) 
    Options_MainMenu_Info := % "x" . posInfoX-TopLeftGameInfoWidth . " y" . posInfoY . " Right c" . color . " r4 s" . Pause_MainMenu_Info_FontSize . " Regular W" . TopLeftGameInfoWidth . " H" . round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset-posInfoY-Pause_MainMenu_Info_FontSize
    Gdip_Alt_TextToGraphics(Pause_G23, TopLeftGameInfoText, Options_MainMenu_Info, Pause_MainMenu_Info_Font)
Return

DrawMainMenuBar: ;Drawing Main Menu Bar
    Gdip_Alt_FillRectangle(Pause_G25, BlackGradientBrush, -1, 0, baseScreenWidth+2, Pause_MainMenu_BarHeight) ;Draw Main Menu Bar
    color := Pause_MainMenu_LabelDisabledColor ;Draw Main Menu Labels
    posX1 := round(baseScreenWidth/2 - (Pause_MainMenuItem-1)*(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth))
    posX2 := round(baseScreenWidth/2 - (Pause_MainMenuItem-1)*(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth) - TotalMainMenuItems*(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth))
    posX3 := round(baseScreenWidth/2 - (Pause_MainMenuItem-1)*(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth) +  TotalMainMenuItems*(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth))
    posY := round(Pause_MainMenu_BarHeight/2 - Pause_MainMenu_LabelFontsize/2)
    Loop, parse, Pause_MainMenu_Itens, |
    {
        bitmap := pauseMainMenuLogo[A_LoopField].disabledBitmap
        If( (Pause_MainMenuItem = A_index)and(VSubMenuItem=0) ){
            color := Pause_MainMenu_LabelSelectedColor
            Pause_MainMenuSelectedLabel := A_LoopField
            bitmap := pauseMainMenuLogo[A_LoopField].selectedBitmap
        }
		Options1 := "x" . posX1 . " y" . posY . " Center c" . color . " r4 s" . Pause_MainMenu_LabelFontsize . " bold"
		Options2 := "x" . posX2 . " y" . posY . " Center c" . Pause_MainMenu_LabelDisabledColor . " r4 s" . Pause_MainMenu_LabelFontsize . " bold"
		Options3 := "x" . posX3 . " y" . posY . " Center c" . Pause_MainMenu_LabelDisabledColor . " r4 s" . Pause_MainMenu_LabelFontsize . " bold"
        if (pauseMainMenuLogo[A_LoopField].ImagePath) {
            Gdip_Alt_DrawImage(Pause_G25, bitmap, posX1 - pauseMainMenuLogo[A_LoopField].resizedWidth//2, 0, pauseMainMenuLogo[A_LoopField].resizedWidth, pauseMainMenuLogo[A_LoopField].resizedHeight)
            Gdip_Alt_DrawImage(Pause_G25, bitmap, posX2 - pauseMainMenuLogo[A_LoopField].resizedWidth//2, 0, pauseMainMenuLogo[A_LoopField].resizedWidth, pauseMainMenuLogo[A_LoopField].resizedHeight)
            Gdip_Alt_DrawImage(Pause_G25, bitmap, posX3 - pauseMainMenuLogo[A_LoopField].resizedWidth//2, 0, pauseMainMenuLogo[A_LoopField].resizedWidth, pauseMainMenuLogo[A_LoopField].resizedHeight)
        } else { 
            If (pauseBarItem[A_LoopField].Label="Change Disc") { 
                Gdip_Alt_TextToGraphics(Pause_G25, "Change " . romTable[1,6], Options1, Pause_MainMenu_LabelFont, 0, 0)
                Gdip_Alt_TextToGraphics(Pause_G25, "Change " . romTable[1,6], Options2, Pause_MainMenu_LabelFont, 0, 0)
                Gdip_Alt_TextToGraphics(Pause_G25, "Change " . romTable[1,6], Options3, Pause_MainMenu_LabelFont, 0, 0)
            } Else {
                Gdip_Alt_TextToGraphics(Pause_G25, pauseBarItem[A_LoopField].Label, Options1, Pause_MainMenu_LabelFont, 0, 0)
                Gdip_Alt_TextToGraphics(Pause_G25, pauseBarItem[A_LoopField].Label, Options2, Pause_MainMenu_LabelFont, 0, 0)
                Gdip_Alt_TextToGraphics(Pause_G25, pauseBarItem[A_LoopField].Label, Options3, Pause_MainMenu_LabelFont, 0, 0)            
            }
        }
        posX1 := posX1+(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth)
        posX2 := posX2+(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth)
        posx3 := posX3+(Pause_MainMenu_HdistBetwLabels+pauseMainMenuLabelMaxWidth)
        color := Pause_MainMenu_LabelDisabledColor
    }
Return


UpdateDescription: ;Updating moving description text position
	Options := "y0 c" . Pause_MainMenu_Info_Description_FontColor . " r4 s" . Pause_MainMenu_Info_Description_FontSize . " Regular"
    descX := (-descX >= E3) ? baseScreenWidth+Pause_MainMenu_Info_Description_FontSize : descX-Pause_MainMenu_DescriptionScrollingVelocity
    Gdip_GraphicsClear(Pause_G24)
    E := Gdip_Alt_TextToGraphics(Pause_G24, Description, "x" descX " " Options, "Arial", (descX < 0) ? baseScreenWidth+Pause_MainMenu_Info_Description_FontSize-descX : baseScreenWidth+Pause_MainMenu_Info_Description_FontSize, Pause_MainMenu_Info_Description_FontSize)
    StringSplit, E, E, |
    Alt_UpdateLayeredWindow(Pause_hwnd24, Pause_hdc24,0,posDescriptionY, baseScreenWidth, 2*Pause_MainMenu_Info_Description_FontSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
Return


SubMenuBottomApearanceAnimation: ;Showing SubMenu contents animation 
    if !Point1x
        CalcSubMenuCoordinates() 
    startTime := A_TickCount
    Gdip_GraphicsClear(Pause_G27)
    RPoint1x := Point1x, RPoint1y := Point1y, RPoint2x := Point2x, RPoint2y := Point2y, RPoint3x := Point3x, RPoint3y := Point3y
    GraphicsCoordUpdate(Pause_G27,RPoint1x,RPoint1y)
    GraphicsCoordUpdate(Pause_G27,RPoint2x,RPoint2y)
    GraphicsCoordUpdate(Pause_G27,RPoint3x,RPoint3y)
    Gdip_Alt_FillRectangle(Pause_G27, Pause_SubMenu_BackgroundBrushV, Point1x, Point1y, Pause_SubMenu_Width-Pause_SubMenu_TopRightChamfer, Pause_SubMenu_Height)
    Gdip_Alt_FillRectangle(Pause_G27, Pause_SubMenu_BackgroundBrushV, Point2x, Point2y, Pause_SubMenu_TopRightChamfer, Pause_SubMenu_Height-Pause_SubMenu_TopRightChamfer)
    Gdip_FillPolygon(Pause_G27, Pause_SubMenu_BackgroundBrushV,  RPoint1x . "," . RPoint1y . "|" . RPoint2x . "," . RPoint2y . "|" . RPoint3x . "," . RPoint3y, FillMode=0)
    Loop {
        t := If ((TimeElapsed := A_TickCount-startTime) < Pause_SubMenu_Appearance_Duration) ? ((1-(timeElapsed/Pause_SubMenu_Appearance_Duration))) : 0
        If (t <= 0)
			Break
        pGraphUpd(Pause_G27,Pause_SubMenu_Width, (1-t)*Pause_SubMenu_Height)
    	Alt_UpdateLayeredWindow(Pause_hwnd27, Pause_hdc27,baseScreenWidth-Pause_SubMenu_Width,baseScreenHeight-((1-t)*Pause_SubMenu_Height), Pause_SubMenu_Width, ((1-t)*Pause_SubMenu_Height),,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
    pGraphUpd(Pause_G27,Pause_SubMenu_Width, Pause_SubMenu_Height)
    Alt_UpdateLayeredWindow(Pause_hwnd27, Pause_hdc27,baseScreenWidth-Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
Return


CalcSubMenuCoordinates(){
    Global
    Point1x := Pause_SubMenu_TopRightChamfer
    Point1y := Pause_SubMenu_Height-Pause_SubMenu_Height
    Point2x := 0
    Point2y := Pause_SubMenu_Height+Pause_SubMenu_TopRightChamfer-Pause_SubMenu_Height
    Point3x := Pause_SubMenu_TopRightChamfer
    Point3y := Pause_SubMenu_Height+Pause_SubMenu_TopRightChamfer-Pause_SubMenu_Height
    RPoint1x := Point1x, RPoint1y := Point1y, RPoint2x := Point2x, RPoint2y := Point2y, RPoint3x := Point3x, RPoint3y := Point3y
    pGraphUpd(Pause_G27,Pause_SubMenu_Width, Pause_SubMenu_Height)
    GraphicsCoordUpdate(Pause_G27,RPoint1x,RPoint1y)
    GraphicsCoordUpdate(Pause_G27,RPoint2x,RPoint2y)
    GraphicsCoordUpdate(Pause_G27,RPoint3x,RPoint3y)
Return
}

DrawSubMenu: ;Drawing SubMenu Background
    Gdip_GraphicsClear(Pause_G26)
    Gdip_GraphicsClear(Pause_G27)
    pGraphUpd(Pause_G27,Pause_SubMenu_Width, Pause_SubMenu_Height)
    If not ((SelectedMenuOption = "Controller") and (!(PauseMediaObj["Controller"].TotalLabels))) or (SelectedMenuOption = "Shutdown") {
        if !Point1x
            CalcSubMenuCoordinates() 
        Gdip_Alt_FillRectangle(Pause_G27, Pause_SubMenu_BackgroundBrushV, Point1x, Point1y, Pause_SubMenu_Width-Pause_SubMenu_TopRightChamfer, Pause_SubMenu_Height)
        Gdip_Alt_FillRectangle(Pause_G27, Pause_SubMenu_BackgroundBrushV, Point2x, Point2y, Pause_SubMenu_TopRightChamfer, Pause_SubMenu_Height-Pause_SubMenu_TopRightChamfer)
        Gdip_FillPolygon(Pause_G27, Pause_SubMenu_BackgroundBrushV,  RPoint1x . "," . RPoint1y . "|" . RPoint2x . "," . RPoint2y . "|" . RPoint3x . "," . RPoint3y, FillMode=0)
    }
    If !submenuMouseClickChange
        SoundPlay %Pause_MenuSoundPath%\submenu.wav
    Else
        submenuMouseClickChange := ""
    If not (SelectedMenuOption = "Shutdown") {
        Loop, parse, Pause_MainMenu_Itens,|
        {
            If (Pause_MainMenuItem = a_Index) { 
                StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
                Gosub %SelectedMenuOption%
            }
        }
    }
    Alt_UpdateLayeredWindow(Pause_hwnd26, Pause_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    Alt_UpdateLayeredWindow(Pause_hwnd27, Pause_hdc27,baseScreenWidth-Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    RLLog.Info(A_ThisLabel . " - Loaded " SelectedMenuOption " SubMenu")
    SubMenuDrawn := 1
Return   


SubMenuUpdate: ;Drawing SubMenu Contents
		If ((A_TimeIdle >= Pause_SubMenu_DelayinMilliseconds) and (MenuChanged = 1)) {
            If(Pause_Active=true)
                gosub, DisableKeys
            If SelectedMenuOption
                If(SubMenuDrawn<>1) 
                    If (SelectedMenuOption <> "Shutdown") and not ((SelectedMenuOption = "Controller") and (!(PauseMediaObj["Controller"].TotalLabels)))
                        gosub, SubMenuBottomApearanceAnimation
            Loop, parse, Pause_MainMenu_Itens,|
                {
                If (Pause_MainMenuItem = a_Index) { 
                StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
                }
            }
            If not (SelectedMenuOption = "Shutdown")
                Gosub DrawSubMenu
            MenuChanged := 0
            If(Pause_Active=true)
                gosub, EnableKeys
        }
Return

;-----------------SUB MENU DRAWING-------------

;-------Controller Sub Menu------- 
Controller:
    ;drawing config controls option
    If (keymapperEnabled = "true") {
        If FileExist(Pause_KeymapperMediaPath . "\Controller Images\controller disconnected.png") {
            controllerDisconnectedBitmap := Gdip_CreateBitmapFromFile(Pause_KeymapperMediaPath . "\Controller Images\controller disconnected.png")
            Gdip_GetImageDimensions(controllerDisconnectedBitmap, BitmapW, BitmapH)
            controllerDisconnectedBitmapW := round(Pause_ControllerBannerHeight/BitmapH*BitmapW) 
        }
        If(VSubMenuItem = -1){
            color := Pause_MainMenu_LabelSelectedColor
            Optionbrush := Pause_SubMenu_SelectedBrushV            
        } Else {
            color := Pause_MainMenu_LabelDisabledColor
            Optionbrush := Pause_SubMenu_DisabledBrushV           
        }
        Gdip_Alt_FillRoundedRectangle(Pause_G26, Optionbrush, 0, 0, ConfigMenuWidth, ConfigMenuHeight,Pause_SubMenu_RadiusofRoundedCorners)
        Gdip_Alt_TextToGraphics(Pause_G26, "Control Config", "x" . ConfigMenuWidth//2 . " y" . Pause_SubMenu_AdditionalTextMarginContour//2 . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold",         Pause_SubMenu_LabelFont, 0, 0)
        If(VSubMenuItem = -1) and (FullScreenView = 1){
            gosub, CheckConnectedJoys
            Loop, 16
                {
                If joyConnectedInfo[A_Index,1]
                    {
                    If FileExist(Pause_KeymapperMediaPath . "\Controller Images\" . joyConnectedInfo[A_Index,2] . ".png")
                        joyConnectedInfo[A_Index,8] := Pause_KeymapperMediaPath . "\Controller Images\" . joyConnectedInfo[A_Index,2] . ".png"
                    Else If FileExist(Pause_KeymapperMediaPath . "\Controller Images\" . joyConnectedInfo[A_Index,6] . ".png")
                        joyConnectedInfo[A_Index,8] := Pause_KeymapperMediaPath . "\Controller Images\" . joyConnectedInfo[A_Index,2] . ".png"
                    Else
                        joyConnectedInfo[A_Index,8] := Pause_KeymapperMediaPath . "\Controller Images\default.png"
                }   
            }
            Loop, 16
                {
                If 	joyConnectedInfo[A_Index,1]
                    { 
                    TextSize := MeasureText(joyConnectedInfo[A_Index,7], "Centre r4 s" . Pause_SubMenu_FontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour    
                    ControllerNameTextSize := If ControllerNameTextSize > TextSize ? ControllerNameTextSize : TextSize
                    joyConnectedInfo[A_Index,9] := Gdip_CreateBitmapFromFile(joyConnectedInfo[A_Index,8])
                    Gdip_GetImageDimensions(joyConnectedInfo[A_Index,9], BitmapW, BitmapH)
                    joyConnectedInfo[A_Index,10] := round(Pause_ControllerBannerHeight/BitmapH*BitmapW) 
                    maxImageWidthSize := If maxImageWidthSize > joyConnectedInfo[A_Index,10] ? maxImageWidthSize : joyConnectedInfo[A_Index,10]
                    maxImageWidthSize := If maxImageWidthSize > controllerDisconnectedBitmapW ? maxImageWidthSize : controllerDisconnectedBitmapW                
                }
            }
            maxControllerTextsize := If ControllerNameTextSize > maxControllerTableTitleSize ? ControllerNameTextSize : maxControllerTableTitleSize
            NumberingTextSize := MeasureText("4", "Center r4 s" . Pause_SubMenu_FontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour 
            BannerTitleY := Pause_SubMenu_FullScreenMargin+2*Pause_vDistanceBetweenButtons
            PlayerX := Pause_SubMenu_AdditionalTextMarginContour+NumberingTextSize//2
            BitmapX := PlayerX + NumberingTextSize//2 + Pause_hDistanceBetweenControllerBannerElements
            ControllerNameX := BitmapX + maxImageWidthSize + Pause_hDistanceBetweenControllerBannerElements
            BannerWidth := ControllerNameX+maxControllerTextsize+Pause_SubMenu_AdditionalTextMarginContour
            Pause_ControllerFullScreenWidth := BannerWidth+8*Pause_SubMenu_FullScreenMargin
            Gdip_GraphicsClear(Pause_G29)
            pGraphUpd(Pause_G29,Pause_ControllerFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin)
            Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenTextBrushV, 0, 0, Pause_ControllerFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenRadiusofRoundedCorners)
            ;drawing the exit full screen button
            ControllerTextButtonSize := MeasureText("Restore Preferred Order", "Center r4 s" . Pause_SubMenu_FontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour 
            TextSize := MeasureText("Exit Control Config", "Center r4 s" . Pause_SubMenu_FontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour 
            ControllerTextButtonSize := If ControllerTextButtonSize > TextSize ? ControllerTextButtonSize : TextSize
            If (V2SubMenuItem = 1){
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV 
            } Else {
                color := Pause_MainMenu_LabelDisabledColor
                Optionbrush := Pause_SubMenu_DisabledBrushV         
            }
            posX := Pause_ControllerFullScreenWidth-2*Pause_SubMenu_FullScreenMargin-ControllerTextButtonSize-2*Pause_SubMenu_AdditionalTextMarginContour
            Width := ControllerTextButtonSize+2*Pause_SubMenu_AdditionalTextMarginContour
            Height := Pause_SubMenu_FontSize+2*Pause_SubMenu_AdditionalTextMarginContour
            Gdip_Alt_FillRoundedRectangle(Pause_G29, Optionbrush, posX, Pause_SubMenu_FullScreenMargin, Width, Height,Pause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(Pause_G29, "Exit Control Config", "x" . posX+Width//2 . " y" . Pause_SubMenu_FullScreenMargin+Pause_VTextDisplacementAdjust+Pause_SubMenu_AdditionalTextMarginContour . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)            
            If (V2SubMenuItem = 1)
                Gdip_Alt_DrawRoundedRectangle(Pause_G29, Pause_SubMenu_ControllerSelectedPen, posX, Pause_SubMenu_FullScreenMargin, Width, Height,Pause_SubMenu_RadiusofRoundedCorners)
            ;drawing Restore Preferred Order button
            If (V2SubMenuItem = 2) {
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV 
            } Else {
                color := Pause_MainMenu_LabelDisabledColor
                Optionbrush := Pause_SubMenu_DisabledBrushV           
            }             
            posY := Pause_SubMenu_FullScreenMargin+Pause_vDistanceBetweenButtons
            Gdip_Alt_FillRoundedRectangle(Pause_G29, Optionbrush, posX, posY, Width, Height,Pause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(Pause_G29, "Restore Preferred Order", "x" . posX+Width//2 . " y" . posY+Pause_SubMenu_AdditionalTextMarginContour+Pause_VTextDisplacementAdjust . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
            If (V2SubMenuItem = 2)
                Gdip_Alt_DrawRoundedRectangle(Pause_G29, Pause_SubMenu_ControllerSelectedPen, posX, posY, Width, Height,Pause_SubMenu_RadiusofRoundedCorners)
            ;drawing Control Banners
            BannerMargin := (Pause_ControllerFullScreenWidth-BannerWidth)//2
            PlayerX := PlayerX+BannerMargin
            BitmapX := BitmapX+BannerMargin
            ControllerNameX := ControllerNameX+BannerMargin
            If (V2SubMenuItem > 2){
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV 
            } Else {
                color := Pause_MainMenu_LabelDisabledColor
                Optionbrush := Pause_SubMenu_DisabledBrushV         
            }
            Gdip_Alt_TextToGraphics(Pause_G29, "Player", "x" . PlayerX . " y" . BannerTitleY . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
            Gdip_Alt_TextToGraphics(Pause_G29, "Controller", "x" . ControllerNameX+maxControllerTextsize//2 . " y" . BannerTitleY . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
            numberOfBannersperScreen := (baseScreenHeight-Pause_SubMenu_FullScreenMargin-BannerTitleY-Pause_vDistanceBetweenBanners)//(Pause_ControllerBannerHeight+Pause_vDistanceBetweenBanners)
            firstbanner := If (V2SubMenuItem-1 - numberOfBannersperScreen) > 0 ? (V2SubMenuItem-1 - numberOfBannersperScreen) : 1
            Loop, %numberOfBannersperScreen%
                {
                BannerPosY := BannerTitleY+Pause_vDistanceBetweenBanners+(a_index-1)*(Pause_ControllerBannerHeight+Pause_vDistanceBetweenBanners)
                If (V2SubMenuItem = a_index+2+firstbanner-1){
                    color := Pause_MainMenu_LabelSelectedColor
                    Optionbrush := Pause_SubMenu_SelectedBrushV 
                } Else {
                    color := Pause_MainMenu_LabelDisabledColor
                    Optionbrush := Pause_SubMenu_DisabledBrushV         
                }
                Gdip_Alt_FillRoundedRectangle(Pause_G29, Optionbrush, BannerMargin, BannerPosY, BannerWidth, Pause_ControllerBannerHeight,Pause_SubMenu_RadiusofRoundedCorners)
                If (V2SubMenuItem = a_index+2+firstbanner-1)
                    Gdip_Alt_DrawRoundedRectangle(Pause_G29, Pause_SubMenu_ControllerSelectedPen, BannerMargin, BannerPosY, BannerWidth, Pause_ControllerBannerHeight,Pause_SubMenu_RadiusofRoundedCorners)
                If (a_index+firstbanner-1 <= 4)
                    Gdip_Alt_TextToGraphics(Pause_G29, a_index+firstbanner-1, "x" . PlayerX . " y" . BannerPosY+Pause_VTextDisplacementAdjust+(Pause_ControllerBannerHeight-Pause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
                Else
                    Gdip_Alt_TextToGraphics(Pause_G29, ".", "x" . PlayerX . " y" . BannerPosY+Pause_VTextDisplacementAdjust+(Pause_ControllerBannerHeight-Pause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
                If joyConnectedInfo[a_index+firstbanner-1,1]
                    Gdip_Alt_DrawImage(Pause_G29, joyConnectedInfo[a_index+firstbanner-1,9], BitmapX+(maxImageWidthSize-joyConnectedInfo[a_index+firstbanner-1,10])//2, BannerPosY, joyConnectedInfo[a_index+firstbanner-1,10], Pause_ControllerBannerHeight)
                Else
                    Gdip_Alt_DrawImage(Pause_G29, controllerDisconnectedBitmap, BitmapX+(maxImageWidthSize-controllerDisconnectedBitmapW)//2, BannerPosY, controllerDisconnectedBitmapW, Pause_ControllerBannerHeight)
                Gdip_Alt_TextToGraphics(Pause_G29, joyConnectedInfo[a_index+firstbanner-1,7], "x" . ControllerNameX+maxControllerTextsize//2 . " y" . BannerPosY+Pause_VTextDisplacementAdjust+(Pause_ControllerBannerHeight-Pause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
            }
            ; drawing submenu with profile options
            If  (HSubMenuItem = 2) {
                If (V2SubMenuItem > 2){
                    possibleProfilesList := Keymapper_PauseProfileList%zz%(joyConnectedInfo[V2SubMenuItem-2,2],V2SubMenuItem-2,keymapper)
                    If  V3SubMenuItem < 1 
                        V3SubMenuItem := % possibleProfilesList.MaxIndex() 
                    If  V3SubMenuItem > % possibleProfilesList.MaxIndex() 
                        V3SubMenuItem := 1
                    secondColumnWidth := MeasureText("emulator", "Left r4 s" . Pause_SubMenu_SmallFontSize . " bold",Pause_SubMenu_Font)
                    thirdColumnWidth := 0
                    Loop, % possibleProfilesList.MaxIndex() 
                        {
                        tempWidth := MeasureText(possibleProfilesList[a_index,1], "Left r4 s" . Pause_SubMenu_SmallFontSize . " bold",Pause_SubMenu_Font)
                        if (tempWidth > thirdColumnWidth)
                            thirdColumnWidth := tempWidth
                    }
                    titleWidth := MeasureText("Choose the Profile That you want to load", "Left r4 s" . Pause_SubMenu_FontSize . " bold",Pause_SubMenu_LabelFont) + 2*Pause_Controller_Profiles_Margin 
                    profilesListWidth := if ((Pause_Controller_Profiles_First_Column_Width+secondColumnWidth+thirdColumnWidth+4*Pause_Controller_Profiles_Margin) > titleWidth) ? (Pause_Controller_Profiles_First_Column_Width+secondColumnWidth+thirdColumnWidth+4*Pause_Controller_Profiles_Margin) : titleWidth
                    Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_SelectedBrushV, BannerMargin+Pause_selectedControllerBannerDisplacement, BannerTitleY+Pause_vDistanceBetweenBanners-Pause_VTextDisplacementAdjust, profilesListWidth, (possibleProfilesList.MaxIndex())*(Pause_SubMenu_SmallFontSize + Pause_Controller_Profiles_Margin) + 2*(Pause_SubMenu_FontSize + Pause_Controller_Profiles_Margin) + Pause_Controller_Profiles_Margin,Pause_SubMenu_RadiusofRoundedCorners)
                    Gdip_Alt_TextToGraphics(Pause_G29, "Choose the Profile That you want to load:", "x" . BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_Margin . " y" . BannerTitleY+Pause_vDistanceBetweenBanners+Pause_Controller_Profiles_Margin . " Left c" . Pause_MainMenu_LabelSelectedColor . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont)
                    Gdip_Alt_TextToGraphics(Pause_G29, "Type", "x" . BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_First_Column_Width+2*Pause_Controller_Profiles_Margin . " y" . BannerTitleY+Pause_vDistanceBetweenBanners+2*Pause_Controller_Profiles_Margin+Pause_SubMenu_FontSize . " Left c" . Pause_MainMenu_LabelSelectedColor . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont)
                    Gdip_Alt_TextToGraphics(Pause_G29, "File Name", "x" . BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_First_Column_Width+secondColumnWidth+3*Pause_Controller_Profiles_Margin . " y" . BannerTitleY+Pause_vDistanceBetweenBanners+2*Pause_Controller_Profiles_Margin+Pause_SubMenu_FontSize . " Left c" . Pause_MainMenu_LabelSelectedColor . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont)
                    if !profileRecommendedBitmap
                        If FileExist(RLMediaPath . "\Menu Images\Pause\Icons\Recommended.png") 
                            profileRecommendedBitmap := Gdip_CreateBitmapFromFile(RLMediaPath . "\Menu Images\Pause\Icons\Recommended.png")
                    if !profileQuestionMarkBitmap
                        If FileExist(RLMediaPath . "\Menu Images\Pause\Icons\QuestionMark.png") 
                            profileQuestionMarkBitmap := Gdip_CreateBitmapFromFile(RLMediaPath . "\Menu Images\Pause\Icons\QuestionMark.png")    
                    if !selectedProfile[V2SubMenuItem-2,1] {
                        currentSelectedProfile := 1 
						If (keymapper = "xpadder") {
							selectedProfile[V2SubMenuItem-2,1] := 1
							selectedProfile[V2SubMenuItem-2,2] := possibleProfilesList[1,4] ;store for later use with xpadder and joytokey run functions
						} else if (keymapper="joy2key") OR (keymapper = "joytokey") {
							Loop, 16
							{
								selectedProfile[A_Index,1] := 1
								selectedProfile[A_Index,2] := possibleProfilesList[1,4] ;store for later use with xpadder and joytokey run functions
							}
						}
					} else
                        currentSelectedProfile := selectedProfile[V2SubMenuItem-2,1]
                    Loop, % possibleProfilesList.MaxIndex()
                        {
                        If (a_index = V3SubMenuItem)
                            color := Pause_MainMenu_LabelSelectedColor
                        Else If (a_index = currentSelectedProfile)
                            color := "ffffff00"
                        Else
                            color := Pause_MainMenu_LabelDisabledColor
                        If possibleProfilesList[a_index,3]
                            Gdip_Alt_DrawImage(Pause_G29, profileRecommendedBitmap, BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_Margin, BannerTitleY+Pause_vDistanceBetweenBanners+3*Pause_Controller_Profiles_Margin+2*Pause_SubMenu_FontSize + (a_index-1)*(Pause_Controller_Profiles_Margin+Pause_SubMenu_SmallFontSize)-(Pause_Controller_Profiles_First_Column_Width-Pause_SubMenu_SmallFontSize)//2, Pause_Controller_Profiles_First_Column_Width, Pause_Controller_Profiles_First_Column_Width)
                         else
                            Gdip_Alt_DrawImage(Pause_G29, profileQuestionMarkBitmap, BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_Margin, BannerTitleY+Pause_vDistanceBetweenBanners+3*Pause_Controller_Profiles_Margin+2*Pause_SubMenu_FontSize + (a_index-1)*(Pause_Controller_Profiles_Margin+Pause_SubMenu_SmallFontSize)-(Pause_Controller_Profiles_First_Column_Width-Pause_SubMenu_SmallFontSize)//2, Pause_Controller_Profiles_First_Column_Width, Pause_Controller_Profiles_First_Column_Width) 
                        Gdip_Alt_TextToGraphics(Pause_G29, possibleProfilesList[a_index,2], "x" . BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_First_Column_Width+2*Pause_Controller_Profiles_Margin . " y" . BannerTitleY+Pause_vDistanceBetweenBanners+3*Pause_Controller_Profiles_Margin+2*Pause_SubMenu_FontSize + (a_index-1)*(Pause_Controller_Profiles_Margin+Pause_SubMenu_SmallFontSize) . " Left c" . color . " r4 s" . Pause_SubMenu_SmallFontSize . " bold", Pause_SubMenu_Font)
                        Gdip_Alt_TextToGraphics(Pause_G29, possibleProfilesList[a_index,1], "x" . BannerMargin+Pause_selectedControllerBannerDisplacement+Pause_Controller_Profiles_First_Column_Width+secondColumnWidth+3*Pause_Controller_Profiles_Margin . " y" . BannerTitleY+Pause_vDistanceBetweenBanners+3*Pause_Controller_Profiles_Margin+2*Pause_SubMenu_FontSize + (a_index-1)*(Pause_Controller_Profiles_Margin+Pause_SubMenu_SmallFontSize) . " Left c" . color . " r4 s" . Pause_SubMenu_SmallFontSize . " bold", Pause_SubMenu_Font)
                    }
                }
            } else {
                V3SubMenuItem := 1
            }
            ;drawing moving selected controller banner
            If (V2SubMenuItem <= 2) or (HSubMenuItem = 2)
                SelectedController := ""
            If SelectedController {
                BannerPosY := BannerTitleY+Pause_vDistanceBetweenBanners+(V2SubMenuItem-2-firstbanner+1-1)*(Pause_ControllerBannerHeight+Pause_vDistanceBetweenBanners)
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV 
                Gdip_Alt_FillRoundedRectangle(Pause_G29, Optionbrush, BannerMargin+Pause_selectedControllerBannerDisplacement, BannerPosY+Pause_selectedControllerBannerDisplacement, BannerWidth, Pause_ControllerBannerHeight,Pause_SubMenu_RadiusofRoundedCorners)
                Gdip_Alt_DrawRoundedRectangle(Pause_G29, Pause_SubMenu_ControllerSelectedPen, BannerMargin+Pause_selectedControllerBannerDisplacement, BannerPosY+Pause_selectedControllerBannerDisplacement, BannerWidth, Pause_ControllerBannerHeight,Pause_SubMenu_RadiusofRoundedCorners)
                Gdip_Alt_TextToGraphics(Pause_G29, ".", "x" . PlayerX+Pause_selectedControllerBannerDisplacement . " y" . BannerPosY+(Pause_ControllerBannerHeight-Pause_SubMenu_FontSize)//2+Pause_selectedControllerBannerDisplacement . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
                Gdip_Alt_DrawImage(Pause_G29, joyConnectedInfo[SelectedController,9], BitmapX+Pause_selectedControllerBannerDisplacement, BannerPosY+Pause_selectedControllerBannerDisplacement, joyConnectedInfo[SelectedController,10], Pause_ControllerBannerHeight)
                Gdip_Alt_TextToGraphics(Pause_G29, joyConnectedInfo[SelectedController,7], "x" . ControllerNameX+maxControllerTextsize//2+Pause_selectedControllerBannerDisplacement . " y" . BannerPosY+(Pause_ControllerBannerHeight-Pause_SubMenu_FontSize)//2+Pause_selectedControllerBannerDisplacement . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold", Pause_SubMenu_LabelFont, 0, 0)
            }          
            Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,(baseScreenWidth-Pause_ControllerFullScreenWidth)//2, Pause_SubMenu_FullScreenMargin, Pause_ControllerFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        } Else {
            V2SubMenuItem := 1   
        }
    }
    If (PauseMediaObj["Controller"].TotalLabels)
        TextImagesAndPDFMenu("Controller")
Return

CheckConnectedJoys:
    If !joyConnectedInfo
        joyConnectedInfo:=[]  ; joyConnectedInfo[port,1] = number_of_buttons    joyConnectedInfo[port,2] = OemName   joyConnectedInfo[A_Index,3] Mid   joyConnectedInfo[A_Index,4] Pid    joyConnectedInfo[A_Index,5] Guid    joyConnectedInfo[port,6] = CustomJoyName     joyConnectedInfo[A_Index,7] Name to be used on menu joyConnectedInfo[A_Index,8] Path to image    joyConnectedInfo[A_Index,9] bitmap pointer    yConnectedInfo[A_Index,10] bitmap width   
	joystickArray := GetJoystickArray%zz%()
    Loop 16  ; Query each joystick number to find out which ones exist.
        {
        currentController := A_Index
        Loop, 7
            joyConnectedInfo[currentController,A_Index] := ""
        controllerName := joystickArray[currentController,1]
		Mid := joystickArray[currentController,2]
		Pid := joystickArray[currentController,3]
		GUID := joystickArray[currentController,4]
		If controllerName
            {
            GetKeyState, buttonsNumber, %currentController%JoyButtons
			joyConnectedInfo[currentController,1] := buttonsNumber
            joyConnectedInfo[currentController,2] := controllerName
			joyConnectedInfo[currentController,3] := Mid
			joyConnectedInfo[currentController,4] := Pid
			joyConnectedInfo[currentController,5] := GUID
            joyConnectedInfo[currentController,6] := CustomJoyNameArray[controllerName]
            joyConnectedInfo[currentController,7] := If joyConnectedInfo[currentController,6] ? joyConnectedInfo[currentController,6] : joyConnectedInfo[currentController,2]
        }
    }
Return


CheckJoyPresses:
    If SelectedController
        Return
    Loop, 16
        {
        If 	joyConnectedInfo[A_Index,1]
            {
            joy_buttons := joyConnectedInfo[A_Index,1]
            JoystickNumber := A_Index
            Loop, % joy_buttons
                {
                GetKeyState, joy%a_index%, %JoystickNumber%joy%a_index%
                If (joy%a_index% = "D")
                    {
                    If (JoystickNumber >= firstbanner) and (JoystickNumber < firstbanner + numberOfBannersperScreen) {
                        ControllerGrowSize := 0
                        TotalGrowSize := Pause_Controller_Joy_Selected_Grow_Size*2
                        BannerPosY := BannerTitleY+Pause_vDistanceBetweenBanners+(JoystickNumber-firstbanner)*(Pause_ControllerBannerHeight+Pause_vDistanceBetweenBanners)
                        Loop, % TotalGrowSize {    
                            If a_index <= % TotalGrowSize//2
                                ControllerGrowSize++
                            Else
                                ControllerGrowSize--   
                            Gdip_GraphicsClear(Pause_G30)
                            pGraphUpd(Pause_G30,joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, Pause_ControllerBannerHeight+TotalGrowSize)
                            Gdip_Alt_DrawImage(Pause_G30, joyConnectedInfo[JoystickNumber,9], 0, 0, joyConnectedInfo[JoystickNumber,10]+ControllerGrowSize*2, Pause_ControllerBannerHeight+ControllerGrowSize*2)
                            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, (baseScreenWidth-Pause_ControllerFullScreenWidth)//2+BitmapX+(maxImageWidthSize-joyConnectedInfo[JoystickNumber,10])//2-ControllerGrowSize,Pause_SubMenu_FullScreenMargin+BannerPosY-ControllerGrowSize, joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, Pause_ControllerBannerHeight+TotalGrowSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                        }
                        Gdip_GraphicsClear(Pause_G30) 
                        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, (baseScreenWidth-Pause_ControllerFullScreenWidth)//2+BitmapX+(maxImageWidthSize-joyConnectedInfo[JoystickNumber,10])//2-TotalGrowSize//2,Pause_SubMenu_FullScreenMargin+BannerPosY-TotalGrowSize//2, joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, Pause_ControllerBannerHeight+TotalGrowSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                    }
                }
            }
        }
    }
Return


;-------Save and Load State Sub Menu-------
SaveState:
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Save the Game")
        if (Pause_SaveStateScreenshot = "true")
            SaveStateBackgroundFile := RIni_GetKeyValue("Stat_sys",dbName,"SaveState" . VSubMenuItem . "Screenshot", false, false, false)
        If SaveStateBackgroundFile
            {
            SaveStateBackgroundBitmap := Gdip_CreateBitmapFromFile(Pause_SaveScreenshotPath . "\" . SaveStateBackgroundFile)
            Gdip_GraphicsClear(Pause_G22) 
            Gdip_Alt_DrawImage(Pause_G22, SaveStateBackgroundBitmap, 0, 0, baseScreenWidth, baseScreenHeight)
            Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        } Else {
            Gdip_GraphicsClear(Pause_G22) 
            Gdip_Alt_DrawImage(Pause_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
            Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    } Else {
        Gdip_GraphicsClear(Pause_G22) 
        Gdip_Alt_DrawImage(Pause_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
    gosub, StateMenuList
Return

LoadState:
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Load the Game")
        SaveStateBackgroundFile := RIni_GetKeyValue("Stat_sys",dbName,"SaveState" . VSubMenuItem . "Screenshot", false, false, false)
        If SaveStateBackgroundFile
            {
            SaveStateBackgroundBitmap := Gdip_CreateBitmapFromFile(Pause_SaveScreenshotPath . "\" . SaveStateBackgroundFile)
            Gdip_GraphicsClear(Pause_G22) 
            Gdip_Alt_DrawImage(Pause_G22, SaveStateBackgroundBitmap, 0, 0, baseScreenWidth, baseScreenHeight)
            Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        } Else {
            Gdip_GraphicsClear(Pause_G22) 
            Gdip_Alt_DrawImage(Pause_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
            Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    } Else {
        Gdip_GraphicsClear(Pause_G22) 
        Gdip_Alt_DrawImage(Pause_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        Alt_UpdateLayeredWindow(Pause_hwnd22, Pause_hdc22, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
    gosub, StateMenuList
Return

StateMenuList:
    SlotEmpty := true
    color := Pause_MainMenu_LabelDisabledColor
    Optionbrush := Pause_SubMenu_DisabledBrushV
    Pause_State_DistBetweenLabelandHour := 50
    WidthofStateText := MeasureText("Save State XX", "Left r4 s" . Pause_SubMenu_LabelFontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour
    posStateX := round(Pause_State_HMargin+WidthofStateText/2)
    posStateX2 := Pause_State_HMargin+WidthofStateText+Pause_State_DistBetweenLabelandHour
    posStateY := Pause_State_VMargin
    posStateY2 := Pause_State_VMargin+Pause_SubMenu_FontSize-Pause_SubMenu_SmallFontSize
    Loop, % PauseMediaObj[SelectedMenuOption].TotalLabels
    {    
    If(VSubMenuItem = A_index ){
        color := Pause_MainMenu_LabelSelectedColor
        Optionbrush := Pause_SubMenu_SelectedBrushV
        }
    If( A_index >= VSubMenuItem){
		OptionsState := "x" . posStateX . " y" . posStateY . " Center c" . color . " r4 s" . Pause_SubMenu_LabelFontSize . " bold"
		OptionsState2 := "x" . posStateX2 . " y" . posStateY2 . " Left c" . color . " r4 s" . Pause_SubMenu_SmallFontSize . " bold"
        Gdip_Alt_FillRoundedRectangle(Pause_G27, Optionbrush, Pause_State_HMargin, posStateY-Pause_SubMenu_AdditionalTextMarginContour+Pause_VTextDisplacementAdjust, WidthofStateText, Pause_SubMenu_FontSize+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
        If(SelectedMenuOption="SaveState"){
            StateLabel := "Save State "A_Index
        } Else {
            StateLabel := "Load State "A_Index
        }    
        Gdip_Alt_TextToGraphics(Pause_G27, StateLabel, OptionsState, Pause_SubMenu_LabelFont, 0, 0)
        ReadSaveTime := RIni_GetKeyValue("Stat_sys",dbName,"SaveState" . A_index . "SaveTime", "Empty Slot", "Empty Slot", "Empty Slot")
        Gdip_Alt_TextToGraphics(Pause_G27, ReadSaveTime, OptionsState2, Pause_SubMenu_Font, 0, 0)
        posStateY := posStateY+Pause_State_VdistBetwLabels
        posStateY2 := posStateY2+Pause_State_VdistBetwLabels
        color := Pause_MainMenu_LabelDisabledColor
        Optionbrush := Pause_SubMenu_DisabledBrushV
        }
    }
    If(SelectedMenuOption="LoadState"){
        ReadSaveTime := RIni_GetKeyValue("Stat_sys",dbName,"SaveState" . VSubMenuItem . "SaveTime", "Empty Slot", "Empty Slot", "Empty Slot")
        If(ReadSaveTime<>"Empty Slot")
            SlotEmpty := false
    }
Return


;-------Change Disc Sub Menu-------
ChangeDisc:
    SetTimer, DiscChangeUpdate, 30  ;setting timer for disc change animations
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Load Disc")
    }
    EnableDiscChangeUpdate := 0
    discAngle := 0
    If (Pause_ChangeDisc_SelectedEffect = "grow") {
        Gdip_GraphicsClear(Pause_G30)
        Pause_Growing := ""
        b := 1
    }
    if !(changeDiscMenuLoaded = true)
        {
        PauseDiscChangetotalUsedWidth := 0
        Loop, 2 {
            If FileExist(multiGameImgPath . "\" . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . "\" . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
            Else If FileExist(multiGameImgPath . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
            Else If FileExist(multiGameImgPath . "\" . systemName . "\" . _Default . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . "\" . systemName . "\" . _Default . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
            Else If FileExist(multiGameImgPath . "\_Default" . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . "\_Default" . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"     
        }
        Pause_ChangeDisc_ImageAdjustV := []
        Pause_ChangeDisc_ImageAdjustH := []
        Pause_ChangeDisc_ImageAdjust := []
        if (path := feMedia["ArtWork"][feDiscArtworkLabel].Path1)
            SplitPath, path, , feDiscChangeDir
        for index, element in romTable
            {
            Gdip_DisposeImage(romTable[A_Index, 17])
            If (FileExist(RLMediaPath . "\MultiGame\" . systemName . "\" . romTable[A_Index, 3] . "\*.png") && (Pause_ChangeDisc_UseGameArt = "true" )) {
                gameArtArray := []
                Loop, % RLMediaPath . "\MultiGame\" . systemName . "\" . romTable[A_Index, 3] . "\*.png"
                    gameArtArray.Insert(A_LoopFileFullPath)
                Random, RndmgameArt, 1, % gameArtArray.MaxIndex()
                gameArtFile := gameArtArray[RndmgameArt]
                romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(gameArtFile)
                romTable[A_Index,16] := "Yes"
            } Else If (FileExist(feDiscChangeDir . "\" . romTable[A_Index, 3] . ".png") && (Pause_ChangeDisc_UseGameArt = "true" )) {
                romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(feDiscChangeDir . "\" . romTable[A_Index, 3] . ".png")
                romTable[A_Index,16] := "Yes"
            } Else {
                Gdip_DisposeImage(romTable[A_Index, 18])
                romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(Image_1)
                romTable[A_Index, 18] := Gdip_CreateBitmapFromFile(Image_2)
            }
            Gdip_GetImageDimensions(romTable[A_Index, 17], Pause_DiscChange_ArtW, Pause_DiscChange_ArtH)
            romTable[A_Index,12] := Pause_DiscChange_ArtW, romTable[A_Index,13] := Pause_DiscChange_ArtH
            Pause_ChangeDisc_ImageAdjustH[A_Index] := ((Pause_SubMenu_Width - (romTable.MaxIndex()+1)*Pause_ChangingDisc_GrowSize)/romTable.MaxIndex())/romTable[A_Index,12]
            Pause_ChangeDisc_ImageAdjustV[A_Index] := (Pause_SubMenu_Height-2*Pause_ChangeDisc_VMargin-Pause_ChangeDisc_TextDisttoImage-Pause_SubMenu_FontSize)/romTable[A_Index,13]
            Pause_ChangeDisc_ImageAdjust[A_Index] := if (Pause_ChangeDisc_ImageAdjustV[A_Index] < Pause_ChangeDisc_ImageAdjustH[A_Index]) ? Pause_ChangeDisc_ImageAdjustV[A_Index] : Pause_ChangeDisc_ImageAdjustH[A_Index]
            romTable[A_Index,14] := round(romTable[A_Index,12]*Pause_ChangeDisc_ImageAdjust[A_Index]), romTable[A_Index,15] := round(romTable[A_Index,13]*Pause_ChangeDisc_ImageAdjust[A_Index])
            If (Pause_ChangeDisc_SelectedEffect = "rotate")
                {
                Gdip_GetRotatedDimensions(romTable[A_Index, 14], romTable[A_Index, 15], 90, Pause_DiscChange_RW%A_Index%, Pause_DiscChange_RH%A_Index%)
                Pause_DiscChange_RW%A_Index% := if (Pause_DiscChange_RW%A_Index% > romTable[A_Index, 14]) ? Pause_DiscChange_RW%A_Index%* : romTable[A_Index, 14], Pause_DiscChange_RH%A_Index% := if (Pause_DiscChange_RH%A_Index% > romTable[A_Index, 15]) ? Pause_DiscChange_RH%A_Index% : romTable[A_Index, 15]
            }
            PauseDiscChangetotalUsedWidth += romTable[A_Index,14]
        }
        PauseDiscChangetotalUnusedWidth := Pause_SubMenu_Width - PauseDiscChangetotalUsedWidth
        PauseDiscChangeremainingUnusedWidth := PauseDiscChangetotalUnusedWidth * ( 1 - ( Pause_ChangeDisc_SidePadding * 2 ))
        PauseDiscChangepaddingSpotsNeeded := romTable.MaxIndex() - 1
        PauseDiscChangeimageSpacing := round(PauseDiscChangeremainingUnusedWidth/PauseDiscChangepaddingSpotsNeeded)
        changeDiscMenuLoaded := true
    }
    PauseDiscChangeimageXcurrent := Pause_ChangeDisc_SidePadding * PauseDiscChangetotalUnusedWidth ;in respect to the top left of the sub menu window
    for index, element in romTable {
        color := Pause_MainMenu_LabelDisabledColor
        romTable[A_Index,10] := PauseDiscChangeimageXcurrent
        romTable[A_Index,11] :=  (Pause_SubMenu_Height - romTable[A_Index,15] - Pause_SubMenu_FontSize - Pause_ChangeDisc_TextDisttoImage)//2 + Pause_SubMenu_FontSize+Pause_ChangeDisc_TextDisttoImage
        If(VSubMenuItem=0){
            SetTimer, DiscChangeUpdate, off
            Gdip_ResetWorldTransform(Pause_G30)
            Gdip_TranslateWorldTransform(Pause_G30, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Pause_G30, pauseScreenRotationAngle)
            Gdip_GraphicsClear(Pause_G30)
            pGraphUpd(Pause_G30,Pause_SubMenu_Width, Pause_SubMenu_Height)
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            Gdip_Alt_DrawImage(Pause_G27, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[A_Index,14], romTable[A_Index,15])
        } Else If(HSubMenuItem = A_index){    
            color := Pause_MainMenu_LabelSelectedColor
            Gdip_GraphicsClear(Pause_G30)
            Gdip_ResetWorldTransform(Pause_G30)
            Gdip_TranslateWorldTransform(Pause_G30, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Pause_G30, pauseScreenRotationAngle)
            pGraphUpd(Pause_G30,Pause_SubMenu_Width, Pause_SubMenu_Height)
            Gdip_Alt_DrawImage(Pause_G30, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[A_Index,14], romTable[A_Index,15])
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        } Else {
            Gdip_Alt_DrawImage(Pause_G27, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[A_Index,14], romTable[A_Index,15])
        }
        posDiscChangeTextX := PauseDiscChangeimageXcurrent
        posDiscChangeTextY := (Pause_SubMenu_Height - romTable[A_Index,15] - Pause_SubMenu_FontSize - Pause_ChangeDisc_TextDisttoImage)//2
		OptionsDiscChange := "x" . posDiscChangeTextX . " y" . posDiscChangeTextY . " Center c" . color . " r4 s" . Pause_SubMenu_FontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, romTable[A_Index,5], OptionsDiscChange, Pause_SubMenu_Font, romTable[A_Index,14], romTable[A_Index,15])
        ;Pause_DiscChange_Art%A_Index%X := PauseimageXcurrent
        If (A_index <= PauseDiscChangepaddingSpotsNeeded)
            PauseDiscChangeimageXcurrent:= PauseDiscChangeimageXcurrent+ romTable[A_Index,14]+PauseDiscChangeimageSpacing
    }
    If (VSubMenuItem=1){
        EnableDiscChangeUpdate := 1
    }
Return    
 

DiscChangeUpdate:
    If !(SelectedMenuOption="ChangeDisc"){
        pGraphUpd(Pause_G30,Pause_SubMenu_Width, Pause_SubMenu_Height)
        Gdip_GraphicsClear(Pause_G30)
        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        SetTimer, DiscChangeUpdate, Off 
        Return
    }
    If (EnableDiscChangeUpdate = 1){
        If ((VSubMenuItem=1)and(SelectedMenuOption="ChangeDisc")){
            If (Pause_ChangeDisc_SelectedEffect = "grow") {
                Sleep, 5
                If !Pause_Growing
                    SetTimer, DiscChangeGrowAnimation, -1
            } Else If (Pause_ChangeDisc_SelectedEffect = "rotate" && romTable[HSubMenuItem, 16]) {
                Gdip_GraphicsClear(Pause_G30)
                pGraphUpd(Pause_G30,Pause_DiscChange_RW%HSubMenuItem%, Pause_DiscChange_RH%HSubMenuItem%)
                discAngle := (discAngle > 360) ? 2 : discAngle+2
                Gdip_ResetWorldTransform(Pause_G30)
                Gdip_TranslateWorldTransform(Pause_G30, Pause_DiscChange_RW%HSubMenuItem%//2, Pause_DiscChange_RH%HSubMenuItem%//2)
                Gdip_RotateWorldTransform(Pause_G30, discAngle)
                Gdip_TranslateWorldTransform(Pause_G30, -Pause_DiscChange_RW%HSubMenuItem%//2, -Pause_DiscChange_RH%HSubMenuItem%//2)
                Gdip_TranslateWorldTransform(Pause_G30, xTranslation, yTranslation)
                Gdip_RotateWorldTransform(Pause_G30, pauseScreenRotationAngle)
                Gdip_Alt_DrawImage(Pause_G30, romTable[HSubMenuItem, 17], (Pause_DiscChange_RW%HSubMenuItem%-romTable[HSubMenuItem, 14]), (Pause_DiscChange_RH%HSubMenuItem%-romTable[HSubMenuItem, 15]), romTable[HSubMenuItem, 14], romTable[HSubMenuItem, 15])
                Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width+romTable[HSubMenuItem, 10]-1, baseScreenHeight-Pause_SubMenu_Height+romTable[HSubMenuItem, 11]-1, Pause_DiscChange_RW%HSubMenuItem%, Pause_DiscChange_RH%HSubMenuItem%,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            } Else If (Pause_ChangeDisc_SelectedEffect = "rotate" && !romTable[HSubMenuItem, 16]) {
                Gdip_GraphicsClear(Pause_G30)
                pGraphUpd(Pause_G30,Pause_SubMenu_Width, Pause_SubMenu_Height)
                Gdip_ResetWorldTransform(Pause_G30)
                Gdip_TranslateWorldTransform(Pause_G30, xTranslation, yTranslation)
                Gdip_RotateWorldTransform(Pause_G30, pauseScreenRotationAngle)
                Gdip_Alt_DrawImage(Pause_G30, romTable[HSubMenuItem, 18], romTable[HSubMenuItem, 10],  romTable[HSubMenuItem, 11], romTable[HSubMenuItem,14], romTable[HSubMenuItem,15], 0, 0, round(romTable[HSubMenuItem,14]/Pause_ChangeDisc_ImageAdjust[HSubMenuItem]), round(romTable[HSubMenuItem,15]/Pause_ChangeDisc_ImageAdjust[HSubMenuItem]))
                Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            } 
        }
    }
Return

DiscChangeGrowAnimation:
    If(EnableDiscChangeUpdate = 1){
        Pause_Growing := 1
        While (b <= Pause_ChangingDisc_GrowSize) {
            Gdip_GraphicsClear(Pause_G30)
            pGraphUpd(Pause_G30,Pause_SubMenu_Width, Pause_SubMenu_Height)
            Gdip_Alt_DrawImage(Pause_G30, (If romTable[HSubMenuItem, 16] ? (romTable[HSubMenuItem, 17]):(romTable[HSubMenuItem, 18])), romTable[HSubMenuItem,10]-(b//2), romTable[ HSubMenuItem,11]-(b//2), romTable[HSubMenuItem,14]+b, romTable[HSubMenuItem,15]+b, 0, 0, romTable[HSubMenuItem,14]//Pause_ChangeDisc_ImageAdjust[HSubMenuItem], romTable[HSubMenuItem,15]//Pause_ChangeDisc_ImageAdjust[HSubMenuItem])
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            b+=2
        }
        b := 0
    }
Return

;-------Settings Sub Menu-------
Settings:
    locklaunchValues := "false|true|password|directonly"
    StringSplit, locklaunchValue, locklaunchValues, |
    ButtonToggleONBitmap := Gdip_CreateBitmapFromFile(ToggleONImage)
    ButtonToggleONBitmapW := Gdip_GetImageWidth(ButtonToggleONBitmap), OptionScale(ButtonToggleONBitmapW, Pause_XScale)
    ButtonToggleONBitmapH := Gdip_GetImageHeight(ButtonToggleONBitmap), OptionScale(ButtonToggleONBitmapH, Pause_XScale)
    ButtonToggleOFFBitmap := Gdip_CreateBitmapFromFile(ToggleOFFImage)
    color7zCleanupTitle := Pause_SubMenu_SoundDisabledColor
    colorLockLaunchTitle := Pause_SubMenu_SoundDisabledColor 
    ; LockLaunch toggle
    Loop, 4
        {
        if (currentLockLaunch=locklaunchValue%a_index%){
            currentLockLaunchLabel := locklaunchValue%a_index%
            currentLockLaunchIndex := A_Index
        }
    }
    If(VSubMenuItem=1){
        colorLockLaunchTitle := Pause_SubMenu_SoundSelectedColor
        HelpText1 := "False = game lanches normaly."
        HelpText2 := "True = Locked from all forms of launching. Use this for games that do not work correctly."
        HelpText3 := "Password = You need to provide the Launch Password to be able to play."
        HelpText4 := "directonly = Cannot launch to play, but can launch into Pause direct mode to view media."
        SubMenuHelpText("Select if you want to lock this game from launch. " . HelpText%currentLockLaunchIndex%)
    }
    posLockLaunchTitleX := Pause_Settings_HMargin
    posLockLaunchTitleY := Pause_Settings_VMargin
	textOptionsLockLaunch := "x" . posLockLaunchTitleX . " y" . posLockLaunchTitleY . " Left c" . colorLockLaunchTitle . " r4 s" . Pause_Settings_OptionFontSize . " bold"
    Gdip_Alt_TextToGraphics(Pause_G27, "Lock Launch:", textOptionsLockLaunch, Pause_SubMenu_Font, 0, 0)
    WidthofLockLaunchText := MeasureText("Lock Launch:", "Left r4 s" . Pause_Settings_OptionFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
    posLockLaunchTitleX := posLockLaunchTitleX+WidthofLockLaunchText+Pause_Settings_Margin
	textLabelOptions := "x" . posLockLaunchTitleX . " y" . posLockLaunchTitleY . " Left c" . colorLockLaunchTitle . " r4 s" . Pause_Settings_OptionFontSize . " bold"
    Gdip_Alt_TextToGraphics(Pause_G27, currentLockLaunchLabel, textLabelOptions, Pause_SubMenu_Font, 0, 0)
    ; 7zCleanup toggle
    if ((found7z="true") and (sevenZEnabled = "true"))  {
        if (current7zDelTemp="true")
        {
            current7zDelTempLabel := "ON"
            CurrentButton7zCleanupBitmap := ButtonToggleONBitmap
        } else {
            current7zDelTempLabel := "OFF"
            CurrentButton7zCleanupBitmap := ButtonToggleOFFBitmap
        }
        If(VSubMenuItem=2){
            color7zCleanupTitle := Pause_SubMenu_SoundSelectedColor
            SubMenuHelpText("Select if you want to disable the deletion of the 7z extracted file for this game if you are going to play it consecutively.")
        }
        pos7zCleanupTitleX := Pause_Settings_HMargin
        pos7zCleanupTitleY := Pause_Settings_VMargin + Pause_Settings_VdistBetwLabels
		textOptions7zCleanup := "x" . pos7zCleanupTitleX . " y" . pos7zCleanupTitleY . " Left c" . color7zCleanupTitle . " r4 s" . Pause_Settings_OptionFontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, "7z Cleanup:", textOptions7zCleanup, Pause_SubMenu_Font, 0, 0)
        Widthof7zCleanupText := MeasureText("7z Cleanup:", "Left r4 s" . Pause_Settings_OptionFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_DrawImage(Pause_G27, CurrentButton7zCleanupBitmap, pos7zCleanupTitleX+Widthof7zCleanupText+Pause_Settings_Margin, pos7zCleanupTitleY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)  
        pos7zCleanupTitleX := round(pos7zCleanupTitleX+Widthof7zCleanupText+Pause_Settings_Margin+ButtonToggleONBitmapW+Pause_Settings_Margin)
		textLabelOptions := "x" . pos7zCleanupTitleX . " y" . pos7zCleanupTitleY . " Left c" . color7zCleanupTitle . " r4 s" . Pause_Settings_OptionFontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, current7zDelTempLabel, textLabelOptions, Pause_SubMenu_Font, 0, 0)
    }
return

;-------Sound Control Sub Menu-------
Sound:
    SoundBarHeight := round(Pause_SoundBar_SingleBarHeight + (100/Pause_SoundBar_vol_Step)*Pause_SoundBar_HeightDifferenceBetweenBars)
    SoundBarWidth := round((100/Pause_SoundBar_vol_Step)*Pause_SoundBar_SingleBarWidth+((100/Pause_SoundBar_vol_Step)-1)*Pause_SoundBar_SingleBarSpacing) 
    SoundBitmap := Gdip_CreateBitmapFromFile(SoundImage)
    SoundBitmapW := Gdip_GetImageWidth(SoundBitmap), SoundBitmapH := Gdip_GetImageHeight(SoundBitmap)
    OptionScale(SoundBitmapW,Pause_XScale)
    OptionScale(SoundBitmapH,Pause_XScale)
    MuteBitmap := Gdip_CreateBitmapFromFile(MuteImage)
    ButtonToggleONBitmap := Gdip_CreateBitmapFromFile(ToggleONImage)
    ButtonToggleONBitmapW := Gdip_GetImageWidth(ButtonToggleONBitmap), ButtonToggleONBitmapH := Gdip_GetImageHeight(ButtonToggleONBitmap)
    OptionScale(ButtonToggleONBitmapW,Pause_XScale)
    OptionScale(ButtonToggleONBitmapH,Pause_XScale)
    ButtonToggleOFFBitmap := Gdip_CreateBitmapFromFile(ToggleOFFImage)
    colorMuteTitle := Pause_SubMenu_SoundDisabledColor 
    colorInGameMusicTitle := Pause_SubMenu_SoundDisabledColor
    colorShuffleTitle := Pause_SubMenu_SoundDisabledColor
    colorSoundBarTitle := Pause_SubMenu_SoundDisabledColor 
    If(VSubMenuItem=1){
        colorSoundBarTitle := Pause_SubMenu_SoundSelectedColor
        If (Pause_VolumeMaster > 0)
            SoundPlay %Pause_MenuSoundPath%\submenu.wav
    }
    If(VSubMenuItem=2)
        SoundPlay %Pause_MenuSoundPath%\submenu.wav
    If(VSubMenuItem=3){
        SoundPlay %Pause_MenuSoundPath%\submenu.wav
        CurrentMusicButton := HSubmenuitemSoundVSubmenuitem3 - currentPlayindex + 3 
        If  CurrentMusicButton < 1 
            currentPlayindex := currentPlayindex-4
        If  CurrentMusicButton > 4
            currentPlayindex := currentPlayindex+4
        CurrentMusicButton := HSubmenuitemSoundVSubmenuitem3 - currentPlayindex + 3
        CurrentMusicButton := Round(CurrentMusicButton)
    }
    getMute(CurrentMuteState)
    If(CurrentMuteState=1){
        SoundMuteLabel := "ON"
        CurrentButtonMuteBitmap := ButtonToggleONBitmap
        CurrentSoundBitmap := MuteBitmap
    } Else {
        SoundMuteLabel := "OFF"
        CurrentButtonMuteBitmap := ButtonToggleOFFBitmap
        CurrentSoundBitmap := SoundBitmap
    } 
    If Pause_VolumeMaster=0
        CurrentSoundBitmap := MuteBitmap
    posSoundBarTextX := round((Pause_SubMenu_Width-SoundBarWidth)/2-SoundBitmapW-Pause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap)
    posSoundBarTextY := round((Pause_SubMenu_Height-SoundBarHeight-Pause_SubMenu_SoundMuteButtonVDist-Pause_SubMenu_SoundMuteButtonFontSize)/2-Pause_SubMenu_SoundMuteButtonFontSize)
	If(Pause_CurrentPlaylist<>""){
        posSoundBarTextY := round((Pause_SubMenu_Height-SoundBarHeight-Pause_SubMenu_SoundMuteButtonVDist-Pause_SubMenu_SoundMuteButtonFontSize-Pause_SubMenu_MusicPlayerVDist-Pause_SubMenu_SizeofMusicPlayerButtons)/2-Pause_SubMenu_SoundMuteButtonFontSize)
        posMusicButtonsY := posSoundBarTextY+SoundBarHeight+Pause_SubMenu_SoundMuteButtonVDist+Pause_SubMenu_SoundMuteButtonFontSize+Pause_SubMenu_MusicPlayerVDist 
        Loop, 4
            {
            posMusicButton%a_index%X := round((Pause_SubMenu_Width-(4*Pause_SubMenu_SizeofMusicPlayerButtons+3*Pause_SubMenu_SpaceBetweenMusicPlayerButtons))/2+(a_index-1)*(Pause_SubMenu_SizeofMusicPlayerButtons + Pause_SubMenu_SpaceBetweenMusicPlayerButtons))
            try CurrentMusicPlayStatus := wmpMusic.playState
            If (a_index = 3) and (CurrentMusicPlayStatus = 3)
                PauseMusicBitmap%a_index% := Gdip_CreateBitmapFromFile(PauseMusicImage5)
            Else
                PauseMusicBitmap%a_index% := Gdip_CreateBitmapFromFile(PauseMusicImage%a_index%)
            Gdip_Alt_DrawImage(Pause_G27,PauseMusicBitmap%a_index%,posMusicButton%a_index%X,posMusicButtonsY,Pause_SubMenu_SizeofMusicPlayerButtons,Pause_SubMenu_SizeofMusicPlayerButtons)
            If((VsubMenuItem = 3) and (CurrentMusicButton = a_index)){
                pGraphUpd(Pause_G30,Pause_SubMenu_SizeofMusicPlayerButtons+Pause_Sound_MarginBetweenButtons, Pause_SubMenu_SizeofMusicPlayerButtons+Pause_Sound_MarginBetweenButtons)
                If (PreviousCurrentMusicButton<>CurrentMusicButton){ 
                    GrowSize := 1
                    While GrowSize <= Pause_Sound_Buttons_Grow_Size {
                        Gdip_GraphicsClear(Pause_G30)
                        Gdip_Alt_DrawImage(Pause_G30,PauseMusicBitmap%CurrentMusicButton%,Pause_Sound_Buttons_Grow_Size-GrowSize,Pause_Sound_Buttons_Grow_Size-GrowSize,Pause_SubMenu_SizeofMusicPlayerButtons+2*GrowSize,Pause_SubMenu_SizeofMusicPlayerButtons+2*GrowSize)
                        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-Pause_Sound_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posMusicButtonsY-Pause_Sound_Buttons_Grow_Size), Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size, Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                        GrowSize+= Pause_SoundButtonGrowingEffectVelocity
                    }
                    Gdip_GraphicsClear(Pause_G30)
                    If(GrowSize<>15){
                        Gdip_Alt_DrawImage(Pause_G30,PauseMusicBitmap%CurrentMusicButton%,0,0,Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size,Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size)
                        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-Pause_Sound_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posMusicButtonsY-Pause_Sound_Buttons_Grow_Size), Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size, Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                    }
                } Else {
                    Gdip_Alt_DrawImage(Pause_G30,PauseMusicBitmap%CurrentMusicButton%,0,0,Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size,Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size)
                    Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-Pause_Sound_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posMusicButtonsY-Pause_Sound_Buttons_Grow_Size), Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size, Pause_SubMenu_SizeofMusicPlayerButtons+2*Pause_Sound_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                }
                PreviousCurrentMusicButton := CurrentMusicButton   
            }
        }
    }
    Gdip_Alt_DrawImage(Pause_G27, CurrentSoundBitmap, posSoundBarTextX, round(posSoundBarTextY+Pause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight-(SoundBitmapH+Pause_SoundBar_SingleBarHeight)/2), SoundBitmapW, SoundBitmapH)
	OptionsSoundBar := "x" . posSoundBarTextX . " y" . posSoundBarTextY . " Left c" . colorSoundBarTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
    Gdip_Alt_TextToGraphics(Pause_G27, "Master Sound Control:", OptionsSoundBar, Pause_SubMenu_Font, 0, 0)
    ; Mute toggle
    If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=1)
        colorMuteTitle := Pause_SubMenu_SoundSelectedColor
    posMuteX := posSoundBarTextX + Pause_Sound_MarginBetweenButtons
    If(Pause_CurrentPlaylist<>"")
        posMuteX := posSoundBarTextX - Pause_Sound_MarginBetweenButtons
    posMuteY := posSoundBarTextY+Pause_SubMenu_SoundMuteButtonFontSize + SoundBarHeight+Pause_SubMenu_SoundMuteButtonVDist
	OptionsSoundMute := "x" . posMuteX . " y" . posMuteY . " Left c" . colorMuteTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
    Gdip_Alt_TextToGraphics(Pause_G27, "Mute Status:", OptionsSoundMute, Pause_SubMenu_Font, 0, 0)
    WidthofMuteText := MeasureText("Mute Status:", "Left r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
    Gdip_Alt_DrawImage(Pause_G27, CurrentButtonMuteBitmap, posMuteX+WidthofMuteText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)  
    posMuteX := round(posMuteX+WidthofMuteText+ButtonToggleONBitmapW+Pause_Sound_Margin)
	OptionsSoundButton := "x" . posMuteX . " y" . posMuteY . " Left c" . colorMuteTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
    Gdip_Alt_TextToGraphics(Pause_G27, SoundMuteLabel, OptionsSoundButton, Pause_SubMenu_Font, 0, 0)
    ; In Game Music Toggle
    If(Pause_CurrentPlaylist<>""){
        If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=2)
            colorInGameMusicTitle := Pause_SubMenu_SoundSelectedColor
        If(Pause_KeepPlayingAfterExitingPause="true"){
            InGameMusic := "ON"
            CurrentButtonInGameMusic := ButtonToggleONBitmap
        } Else {
            InGameMusic := "OFF"
            CurrentButtonInGameMusic := ButtonToggleOFFBitmap
        }
        posInGameMusicX := posMuteX + Pause_Sound_InGameMusic_Margin
		OptionsInGameMusic := "x" . posInGameMusicX . " y" . posMuteY . " Left c" . colorInGameMusicTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, "In Game Music:", OptionsInGameMusic, Pause_SubMenu_Font, 0, 0)
        WidthofInGameMusicText := MeasureText("In Game Music:", "Left r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold",Pause_SubMenu_Font)+       Pause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_DrawImage(Pause_G27, CurrentButtonInGameMusic, posInGameMusicX+WidthofInGameMusicText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)       
        posInGameMusicX := round(posInGameMusicX+WidthofInGameMusicText+ButtonToggleONBitmapW+Pause_Sound_Margin)
		OptionsInGameMusicButton := "x" . posInGameMusicX . " y" . posMuteY . " Left c" . colorInGameMusicTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, InGameMusic, OptionsInGameMusicButton, Pause_SubMenu_Font, 0, 0)    

        ; Shuffle Toggle
        If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=3)
            colorShuffleTitle := Pause_SubMenu_SoundSelectedColor
        If(Pause_EnableShuffle="true"){
            ShuffleText := "ON"
            CurrentButtonShuffle := ButtonToggleONBitmap
        } Else {
            ShuffleText := "OFF"
            CurrentButtonShuffle := ButtonToggleOFFBitmap
        }
        posShuffleX := posInGameMusicX + Pause_Sound_InGameMusic_Margin
		OptionsShuffle := "x" . posShuffleX . " y" . posMuteY . " Left c" . colorShuffleTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, "Shuffle:", OptionsShuffle, Pause_SubMenu_Font, 0, 0)
        WidthofShuffleText := MeasureText("Shuffle:", "Left r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold",Pause_SubMenu_Font)+       Pause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_DrawImage(Pause_G27, CurrentButtonShuffle, posShuffleX+WidthofShuffleText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)       
        posShuffleX := round(posShuffleX+WidthofShuffleText+ButtonToggleONBitmapW+Pause_Sound_Margin)
		OptionsShuffleButton := "x" . posShuffleX . " y" . posMuteY . " Left c" . colorShuffleTitle . " r4 s" . Pause_SubMenu_SoundMuteButtonFontSize . " bold"
        Gdip_Alt_TextToGraphics(Pause_G27, ShuffleText, OptionsShuffleButton, Pause_SubMenu_Font, 0, 0)        
    }
    Loop, % (100/Pause_SoundBar_vol_Step) { ;empty Sound Bar Progress
        DrawSoundEmptyProgress(Pause_G27, round((Pause_SubMenu_Width-SoundBarWidth)/2+(A_Index - 1) * (Pause_SoundBar_SingleBarWidth+Pause_SoundBar_SingleBarSpacing)), posSoundBarTextY+Pause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight, Pause_SoundBar_SingleBarWidth, Pause_SoundBar_SingleBarHeight+Pause_SoundBar_HeightDifferenceBetweenBars*A_Index)
    }
    Loop, % (Pause_VolumeMaster // Pause_SoundBar_vol_Step){ ;full Sound Bar Progress
        SetFormat Integer, Hex
        SoundBarAlpha:= round((A_Index/Pause_VolumeMaster)*(255-150)+150)
        SetFormat Integer, D
        SoundBarBodyColor := "14CB14" ;CB1414 - RED  
        SoundBarBottomEffectColor := "003E00" ; 3E0000 -RED
        PrimaryColorSoundBar := SoundBarAlpha SoundBarBodyColor
        SecondaryColorSoundBar := SoundBarAlpha SoundBarBottomEffectColor 
        DrawSoundFullProgress(Pause_G27, round((Pause_SubMenu_Width-SoundBarWidth)/2+(A_Index - 1) * (Pause_SoundBar_SingleBarWidth+Pause_SoundBar_SingleBarSpacing)), posSoundBarTextY+Pause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight, Pause_SoundBar_SingleBarWidth, Pause_SoundBar_SingleBarHeight+Pause_SoundBar_HeightDifferenceBetweenBars*A_Index,PrimaryColorSoundBar,SecondaryColorSoundBar)
    }
    posVolX := round((Pause_SubMenu_Width-SoundBarWidth)/2+SoundBarWidth+Pause_SubMenu_SoundDisttoSoundLevel) 
    posVolY := posSoundBarTextY+Pause_SubMenu_SoundMuteButtonFontSize
	OptionsSound := "x" . posVolX . " y" . posVolY . " Center c" . colorSoundBarTitle . " r4 s" . Pause_SubMenu_SmallFontSize . " bold"
    soundtext := round(Pause_VolumeMaster) "%"
    If (Pause_VolumeMaster=0){
    soundtext = Mute    
    }
    Gdip_Alt_TextToGraphics(Pause_G27, soundtext, OptionsSound, "Arial")
    If (Pause_CurrentPlaylist<>"")
        settimer, UpdateMusicPlayingInfo, 100, Period
    Else 
        gosub, UpdateMusicPlayingInfo
Return


;-------Videos Sub Menu-------
Videos:
    try CurrentMusicPlayStatus := wmpMusic.playState
    If (CurrentMusicPlayStatus = 3) {
        try wmpMusic.controls.pause  
        MusicPausedonVideosMenu := true
    }        
    TextImagesAndPDFMenu("Videos")
Return


;-------High Score Sub Menu-------
HighScore:
    posHighScoreX := 0
    line := 0
    StringSplit, FirstLineContents, HighScoreText, ¡
    StringReplace, FirstLineContents1,FirstLineContents1,|,|,UseErrorLevel
    numberofcolumns := ErrorLevel+1
    Loop, % numberofcolumns
        {
        If(FullScreenView <> 1){
            If (a_index=1)
                PosX := round((Pause_SubMenu_Width)/(numberofcolumns*2))
            Else
                PosX := PosX + 2*round((Pause_SubMenu_Width)/(numberofcolumns*2))
            posHighScoreX%a_index% := PosX
        } Else {
            If (a_index=1)
                PosX := round((Pause_SubMenu_HighScoreFullScreenWidth)/(numberofcolumns*2))
            Else
                PosX := PosX + 2*round((Pause_SubMenu_HighScoreFullScreenWidth)/(numberofcolumns*2))
            posHighScoreX%a_index% := PosX
        }
    }
    If(FullScreenView <> 1){
        posHighScoreY1 := Pause_SubMenu_HighScore_SuperiorMargin
        posHighScoreY2 := Pause_SubMenu_HighScore_SuperiorMargin+2*Pause_SubMenu_HighScoreTitleFontSize
    } Else {
        posHighScoreY1 := 2*Pause_SubMenu_FullScreenMargin
        posHighScoreY2 := 2*Pause_SubMenu_FullScreenMargin+2*Pause_SubMenu_HighScoreTitleFontSize
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenTextBrushV, 0, 0, Pause_SubMenu_HighScoreFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenRadiusofRoundedCorners)
    }
    Loop, parse, HighScoreText,¡,
        {
        line++
        If(line=1){
            color := Pause_SubMenu_HighScoreTitleFontColor
            Loop, parse, a_loopfield,|,
                {
                column++
                posHighScoreX := posHighScoreX%column%
				OptionsHighScore1 := "x" . posHighScoreX . " y" . posHighScoreY1 . " Center c" . color . " r4 s" . Pause_SubMenu_HighScoreTitleFontSize . " bold"
                If FullScreenView<>1
                    Gdip_Alt_TextToGraphics(Pause_G27, a_loopfield, OptionsHighScore1, Pause_SubMenu_Font)
                Else
                    Gdip_Alt_TextToGraphics(Pause_G29, a_loopfield, OptionsHighScore1, Pause_SubMenu_Font)
            }
        } Else If (line >= VSubMenuItem+1){
            If(line=VSubMenuItem+1){
                color :=Pause_SubMenu_HighScoreSelectedFontColor    
            } Else {
                color := Pause_SubMenu_HighScoreFontColor       
            }
            IfInString, a_loopfield, %Pause_SubMenu_HighlightPlayerName%
                {
                color := Pause_SubMenu_HighlightPlayerFontColor                 
            }
            Loop, parse, a_loopfield,|,
                {
                column++
                HighScoreitem := A_LoopField
                If(column=1){
                    If(A_LoopField=1)
                        HighScoreitem := HighScoreitem "st"
                    If(A_LoopField=2)
                        HighScoreitem := HighScoreitem "nd"
                    If(A_LoopField=3)
                        HighScoreitem := HighScoreitem "rd"
                    If(A_LoopField>3)
                        HighScoreitem := HighScoreitem "th"                        
                }
                posHighScoreX := posHighScoreX%column%
				OptionsHighScore2 := "x" . posHighScoreX . " y" . posHighScoreY2 . " Center c" . color . " r4 s" . Pause_SubMenu_HighScoreFontSize . " bold"
                If FullScreenView<>1
                    Gdip_Alt_TextToGraphics(Pause_G27, HighScoreitem, OptionsHighScore2, Pause_SubMenu_Font)
                Else
                    Gdip_Alt_TextToGraphics(Pause_G29, HighScoreitem, OptionsHighScore2, Pause_SubMenu_Font)
                }
        posHighScoreY2 := round(posHighScoreY2+1.5*Pause_SubMenu_HighScoreFontSize)
        }
    column = 0
    }
    If(FullScreenView=1){      
        Pause_SubMenu_FullScreenHelpBoxHeight := 4*Pause_SubMenu_FullScreenFontSize
        Pause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up or Down to move between High Scores", "Left r4 s" . Pause_SubMenu_FullScreenFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, round((Pause_SubMenu_HighScoreFullScreenWidth-Pause_SubMenu_FullScreenHelpBoxWidth)/2), baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-5*Pause_SubMenu_FullScreenFontSize, Pause_SubMenu_FullScreenHelpBoxWidth,Pause_SubMenu_FullScreenHelpBoxHeight,Pause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(Pause_SubMenu_HighScoreFullScreenWidth/2)
        posFullScreenTextY := round(baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-4*Pause_SubMenu_FullScreenFontSize-Pause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText := "x" . posFullScreenTextX . " y" . posFullScreenTextY . " Center c" . Pause_SubMenu_FullScreenFontColor . " r4 s" . Pause_SubMenu_FullScreenFontSize . " bold"
        TotaltxtPages := % TotalFullScreenV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up or Down to move between High Scores
        Gdip_Alt_TextToGraphics(Pause_G29, CurrentHelpText, OptionsFullScreenText, Pause_SubMenu_Font, 0, 0)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,round((baseScreenWidth-Pause_SubMenu_HighScoreFullScreenWidth)/2), Pause_SubMenu_FullScreenMargin, Pause_SubMenu_HighScoreFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    } Else If ((VSubMenuItem<>0) and (HSubMenuItem=1)){
            CurrentHelpText = Press Select Key to go FullScreen
            SubMenuHelpText(CurrentHelpText)
    }
Return



;-------Artwork Sub Menu-------
Artwork:
    TextImagesAndPDFMenu("Artwork")
Return


;-------Moves List Sub Menu-------
MovesList:
    current_item := VSubMenuItem
    If(VSubMenuItem = 0){
        current_item := 1
        V2SubMenuItem := 1
    }
    color := Pause_MainMenu_LabelDisabledColor
    Optionbrush := Pause_SubMenu_DisabledBrushV
    posMovesListLabelY := Pause_MovesList_VMargin
    MaxMovesListLabelWidth := Pause_SubMenu_MinimumTextBoxWidth
    Loop, % PauseMediaObj["MovesList"].TotalLabels
        {
        MovesListLabelWidth := MeasureText(MovesListLabel%A_index%, "Left r4 s" . Pause_SubMenu_LabelFontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour
        If (MovesListLabelWidth>MaxMovesListLabelWidth){
        MaxMovesListLabelWidth := MovesListLabelWidth
        }    
    }   
    posMovesListLabelX := round(Pause_MovesList_HMargin+MaxMovesListLabelWidth/2)
    Loop, % PauseMediaObj["MovesList"].TotalLabels
        {
        If( A_index >= VSubMenuItem){   
            If((HSubMenuItem=1)and(A_index=VSubMenuItem)){
                V2SubMenuItem := 1
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV
            }
            OptionsMovesListLabel := "x" . posMovesListLabelX . " y" . posMovesListLabelY . " Center c" . color . " r4 s" . Pause_SubMenu_LabelFontSize . " bold"
            Gdip_Alt_FillRoundedRectangle(Pause_G27, Optionbrush, round(posMovesListLabelX-MaxMovesListLabelWidth/2), posMovesListLabelY-Pause_SubMenu_AdditionalTextMarginContour+Pause_VTextDisplacementAdjust, MaxMovesListLabelWidth, Pause_SubMenu_FontSize+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(Pause_G27, MovesListLabel%A_index%, OptionsMovesListLabel, Pause_SubMenu_LabelFont, 0, 0)
            posMovesListLabelY := posMovesListLabelY+Pause_MovesList_VdistBetwLabels
            color := Pause_MainMenu_LabelDisabledColor
            Optionbrush := Pause_SubMenu_DisabledBrushV
        }
    }
    If(FullScreenView=1)
        TotalMovesListPages := % %SelectedMenuOption%TotalNumberofFullScreenPages%current_item%
    Else
        TotalMovesListPages := % %SelectedMenuOption%TotalNumberofPages%current_item%
    If (V2SubMenuItem > TotalMovesListPages)
            V2SubMenuItem := TotalMovesListPages
    If(FullScreenView=1){
        FirstLine := (V2SubMenuItem-1) * LinesperFullScreenPage%SelectedMenuOption% + 1
        LastLine := FirstLine + LinesperFullScreenPage%SelectedMenuOption% - 1
        Gdip_GraphicsClear(Pause_G29)
        pGraphUpd(Pause_G29,Pause_SubMenu_MovesListFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin)
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenTextBrushV, 0, 0, Pause_SubMenu_MovesListFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenRadiusofRoundedCorners)
    } Else {
        FirstLine := (V2SubMenuItem-1)*LinesperPage%SelectedMenuOption% + 1
        LastLine := FirstLine + LinesperPage%SelectedMenuOption% - 1
    } 
    MovesListLineCount := 0
    validLineCount := 0
    posMovesListY := Pause_MovesList_VMargin
    stringreplace, AuxMovesListItem%current_item%, MovesListItem%current_item%, `r`n,¿,all
    Loop, parse, AuxMovesListItem%current_item%, ¿
        {
        If A_LoopField contains %Lettersandnumbers%  
            {
            validLineCount++  
            If((validLineCount >= FirstLine) and (validLineCount <= LastLine)){
                MovesListLineCount++
                If FullScreenView<>1
                    posMovesListX := round(posMovesListLabelX+MaxMovesListLabelWidth/2+Pause_MovesList_HdistBetwLabelsandMovesList)
                Else
                    posMovesListX := Pause_MovesList_HFullScreenMovesMargin
                color2 := Pause_MainMenu_LabelDisabledColor
                If(HSubMenuItem=2){
                    color2 := Pause_MainMenu_LabelSelectedColor
                }
                MovesListCurrentLine  := A_LoopField
                StringCaseSense, On
                replace := {"_a":"#a","_b":"#b","_c":"#c","_d":"#d","_e":"#e","_f":"#f","_g":"#g","_h":"#h","_i":"#i","_j":"#j","_k":"#k","_l":"#l","_m":"#m","_n":"#n","_o":"#o","_p":"#p","_q":"#q","_r":"#r","_s":"#s","_t":"#t","_u":"#u","_v":"#v","_w":"#w","_x":"#x","_y":"#y","_z":"#z","^s":"@S","_?":"_;","^*":"^X"} ; Dealing with altered filenames due to the impossibility of using a lower and upper case file names on the same directory (_letter lower cases are transformed in #letter)  
                For what, with in replace
                    StringReplace, MovesListCurrentLine, MovesListCurrentLine, %what%, %with%, All
                
                Loop, parse, CommandDatImageFileList, `,
                    {
                    Stringreplace, MovesListCurrentLine, MovesListCurrentLine, %A_loopfield%, ¡%A_loopfield%¡ ,all
                }
                MovesListCurrentLine := "¡" . MovesListCurrentLine . "¡" 
                Stringreplace, MovesListCurrentLine, MovesListCurrentLine, ¡¡, ¡ ,all
                StringTrimLeft, MovesListCurrentLine, MovesListCurrentLine, 1
                StringTrimRight, MovesListCurrentLine, MovesListCurrentLine, 1
                Loop, parse, MovesListCurrentLine, ¡
                    {
                    OptionsMovesList := "x" . posMovesListX . " y" . posMovesListY . " Left c" . color2 . " r4 s" . Pause_MovesList_SecondaryFontSize . " bold"
                    If(A_LoopField<>""){
                        If A_LoopField contains %CommandDatImageFileList%
                            {
                            currentbitmap := A_LoopField
                            Loop, parse, CommandDatImageFileList, `,
                                {
                                currentbitmapindex := A_index
                                If(A_LoopField=currentbitmap){
                                    CurrentBitmapW := Gdip_GetImageWidth(CommandDatBitmap%currentbitmapindex%), CurrentBitmapH := Gdip_GetImageHeight(CommandDatBitmap%currentbitmapindex%)
                                    ResizedBitmapH := Pause_MovesList_VImageSize
                                    ResizedBitmapW := round((Pause_MovesList_VImageSize/CurrentBitmapH)*CurrentBitmapW)
                                    If FullScreenView<>1
                                        Gdip_Alt_DrawImage(Pause_G27,CommandDatBitmap%currentbitmapindex%,posMovesListX,round(posMovesListY-ResizedBitmapH/2+Pause_MovesList_SecondaryFontSize/2),ResizedBitmapW,ResizedBitmapH)
                                    Else
                                        Gdip_Alt_DrawImage(Pause_G29,CommandDatBitmap%currentbitmapindex%,posMovesListX,round(posMovesListY-ResizedBitmapH/2+Pause_MovesList_SecondaryFontSize/2),ResizedBitmapW,ResizedBitmapH)
                                    AddposMovesListX := ResizedBitmapW
                                    break                                            
                                }
                            }
                        } Else {
                            If (InStr(A_LoopField, ":")=1) ;Underlining title that starts and ends with ":" 
                                If (InStr(A_LoopField, ":",false,0)>StrLen(A_LoopField)-2)
                                    OptionsMovesList := "x" . posMovesListX . " y" . posMovesListY . " Left c" . color2 . " r4 s" . Pause_MovesList_SecondaryFontSize . " Underline"
                            If FullScreenView<>1
                                Gdip_Alt_TextToGraphics(Pause_G27, A_LoopField, OptionsMovesList, Pause_SubMenu_Font, 0, 0)
                            Else
                                Gdip_Alt_TextToGraphics(Pause_G29, a_loopfield, OptionsMovesList, Pause_SubMenu_Font)                            
                            AddposMovesListX := MeasureText(A_LoopField, "Left r4 s" . Pause_MovesList_SecondaryFontSize . " bold",Pause_SubMenu_Font)
                        }
                        posMovesListX := posMovesListX+AddposMovesListX
                    }
                }
                posMovesListY := posMovesListY+Pause_MovesList_VdistBetwMovesListLabels
            }
        }
    }
    StringCaseSense, Off
    If(FullScreenView <> 1){
        If((VSubMenuItem<>0) and (HSubMenuItem=2)){
            CurrentHelpText := "Press Select Key to go FullScreen - Page " . V2SubMenuItem . " of " . TotalMovesListPages
            SubMenuHelpText(CurrentHelpText)
        } Else If ((VSubMenuItem<>0) and (HSubMenuItem=1)){
            CurrentHelpText := "Press Left of Right to Select the Moves List - Page " . V2SubMenuItem . " of " . TotalMovesListPages
            SubMenuHelpText(CurrentHelpText)
        } Else {            
        Gdip_GraphicsClear(Pause_G33)
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    } Else {
        Pause_SubMenu_FullScreenHelpBoxHeight := 5*Pause_SubMenu_FullScreenFontSize
        Pause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up for Page Up or Press Down for Page Down", "Left r4 s" . Pause_SubMenu_FullScreenFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, round((Pause_SubMenu_MovesListFullScreenWidth-Pause_SubMenu_FullScreenHelpBoxWidth)/2), baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-6*Pause_SubMenu_FullScreenFontSize, Pause_SubMenu_FullScreenHelpBoxWidth,Pause_SubMenu_FullScreenHelpBoxHeight,Pause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(Pause_SubMenu_MovesListFullScreenWidth/2)
        posFullScreenTextY := round(baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-5*Pause_SubMenu_FullScreenFontSize-Pause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText := "x" . posFullScreenTextX . " y" . posFullScreenTextY . " Center c" . Pause_SubMenu_FullScreenFontColor . " r4 s" . Pause_SubMenu_FullScreenFontSize . " bold"
        CurrentHelpText := "Press Select Key to Exit Full Screen`nPress Up for Page Up or Press Down for Page Down`nPage " . V2SubMenuItem . " of " . TotalMovesListPages
        Gdip_Alt_TextToGraphics(Pause_G29, CurrentHelpText, OptionsFullScreenText, Pause_SubMenu_Font, 0, 0)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,round((baseScreenWidth-Pause_SubMenu_MovesListFullScreenWidth)/2), Pause_SubMenu_FullScreenMargin, Pause_SubMenu_MovesListFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
Return

       

;-------Statistics Sub Menu-------
Statistics:
    SetTimer, UpdateStatsScrollingText, off
    Gdip_GraphicsClear(Pause_G30)
    Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    Statistics_TitleLabel_1 := "General Statistics:"
    Statistics_TitleLabel_3 := "System Top Ten:"
    Statistics_TitleLabel_6 := "Global Top Ten:"
    Statistics_Label_List := "General_Statistics|Global_Last_Played_Games|System_Top_Ten_(Most_Played)|System_Top_Ten_(Times_Played)|System_Top_Ten_(Average_Time)|Global_Top_Ten_(System_Most_Played)|Global_Top_Ten_(Most_Played)|Global_Top_Ten_(Times_Played)|Global_Top_Ten_(Average_Time)"
    Statistics_Label_Name_List := "Game Statistics|Last Played Games|Most Played Games|Number of Times Played|Average Time Played|Systems Most Played|Most Played Games|Number of Times Played|Average Time Played"
    Statistics_var_List_1 := "Game Name|System Name|Number_of_Times_Played|Last_Time_Played|Average_Time_Played|Total_Time_Played|System_Total_Played_Time|Total_Global_Played_Time"
    Statistics_var_List_2 := "1|2|3|4|5|6|7|8|9|10"
    Loop, 7
        {
        current := A_index + 2
        Statistics_var_List_%current% := "1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th"
        ;Statistics_var_List_%current% := "1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place "
    }
    color := Pause_MainMenu_LabelDisabledColor
    color2 := Pause_MainMenu_LabelDisabledColor
    color3 := Pause_Statistics_TitleFontColor
    Optionbrush := Pause_SubMenu_DisabledBrushV
    posStatisticsLabelY := Pause_Statistics_VMargin
    StatisticsLabelCount := 0
    NumberofDrawns := 0
    MaxStatisticsLabelWidth := Pause_SubMenu_MinimumTextBoxWidth
    Loop, parse, Statistics_Label_Name_List, |
    {
        StatisticsLabelCount++
        Statistics_Label_Name_%a_index% := A_LoopField  
        StatisticsLabelWidth := MeasureText(A_LoopField, "Left r4 s" . Pause_SubMenu_LabelFontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour
        If (StatisticsLabelWidth>MaxStatisticsLabelWidth){
			MaxStatisticsLabelWidth := StatisticsLabelWidth
        }    
    }      
    posStatisticsLabelX := round(Pause_Statistics_HMargin+MaxStatisticsLabelWidth/2)
    StatisticsTablecount := 0
    Loop, parse, Statistics_Label_List, |
        {
        If(Statistics_TitleLabel_%a_index%<>""){
            posStatisticsTitleLabelX := round(Pause_Statistics_HMargin/2)
			OptionsStatisticsTitleLabel := "x" . posStatisticsTitleLabelX . " y" . posStatisticsLabelY . " Left c" . Pause_MainMenu_LabelDisabledColor . " r4 s" . Pause_SubMenu_LabelFontSize . " bold"
            Gdip_Alt_TextToGraphics(Pause_G27, Statistics_TitleLabel_%A_index%, OptionsStatisticsTitleLabel, Pause_SubMenu_LabelFont, 0, 0)
            posStatisticsLabelY := posStatisticsLabelY+Pause_Statistics_VdistBetwLabels
        }
        If(A_index >= VSubMenuItem){
            If((HSubMenuItem=1)and(A_index=VSubMenuItem)){
                V2SubMenuItem := 1
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV
                Current_Label := A_LoopField
                current_item := A_index
            }
			OptionsStatisticsLabel := "x" . posStatisticsLabelX . " y" . posStatisticsLabelY . " Center c" . color . " r4 s" . Pause_SubMenu_LabelFontSize . " bold"
            Gdip_Alt_FillRoundedRectangle(Pause_G27, Optionbrush, round(posStatisticsLabelX-MaxStatisticsLabelWidth/2), posStatisticsLabelY-Pause_SubMenu_AdditionalTextMarginContour+Pause_VTextDisplacementAdjust, MaxStatisticsLabelWidth, Pause_SubMenu_FontSize+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(Pause_G27, Statistics_Label_Name_%a_index%, OptionsStatisticsLabel, Pause_SubMenu_LabelFont, 0, 0)
            posStatisticsLabelY := posStatisticsLabelY+Pause_Statistics_VdistBetwLabels
            color := Pause_MainMenu_LabelDisabledColor
            Optionbrush := Pause_SubMenu_DisabledBrushV
        }
    }  
    If(FullScreenView=1){
        Gdip_GraphicsClear(Pause_G29)
        pGraphUpd(Pause_G29, Pause_SubMenu_StatisticsFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin)
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenTextBrushV, 0, 0, Pause_SubMenu_StatisticsFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenRadiusofRoundedCorners)
        posStatisticsTableTitleY := 4*Pause_SubMenu_FullScreenMargin
        posStatisticsTableY := 4*Pause_SubMenu_FullScreenMargin+2*Pause_Statistics_TitleFontSize
        posStatisticsTableX := 4*Pause_SubMenu_FullScreenMargin
        posStatisticsTableX3 := Pause_SubMenu_StatisticsFullScreenWidth-4*Pause_SubMenu_FullScreenMargin
    } Else {
        posStatisticsTableTitleY := Pause_Statistics_VMargin
        posStatisticsTableY := Pause_Statistics_VMargin+2*Pause_Statistics_TitleFontSize
        posStatisticsTableX := round(posStatisticsLabelX+MaxStatisticsLabelWidth/2+Pause_Statistics_DistBetweenLabelsandTable)
        posStatisticsTableX3 := Pause_SubMenu_Width-Pause_Statistics_DistBetweenLabelsandTable
    }
    posStatisticsTableX2 := round((posStatisticsTableX + posStatisticsTableX3)/2+Pause_Statistics_Middle_Column_Offset)
    OptionsStatisticsTableTitle := "x" . posStatisticsTableX . " y" . posStatisticsTableTitleY . " Left c" . Pause_Statistics_TitleFontColor . " r4 s" . Pause_Statistics_TableFontSize . " bold"
    OptionsStatisticsTableTitle2 := "x" . posStatisticsTableX2 . " y" . posStatisticsTableTitleY . " Center c" . Pause_Statistics_TitleFontColor . " r4 s" . Pause_Statistics_TableFontSize . " bold"
    OptionsStatisticsTableTitle3 := "x" . posStatisticsTableX3 . " y" . posStatisticsTableTitleY . " Right c" . Pause_Statistics_TitleFontColor . " r4 s" . Pause_Statistics_TableFontSize . " bold"
    If(VSubMenuItem=0){
        Current_Label := "General_Statistics"
        current_item := 1
    }
    stringreplace, Current_Label_Without_Parenthesis, Current_Label, (,,all
    stringreplace, Current_Label_Without_Parenthesis, Current_Label_Without_Parenthesis, ),,all
    If(Current_Label="General_Statistics"){
        current_column1_Title := "Game Statistics"
    } Else If (Current_Label="Global_Last_Played_Games"){
        current_column1_Title := "Last Played Games"
        current_column2_Title := ""
        current_column3_Title := "System Name"
        current_column3_TitleExtra := "Last Time Played"
    }Else{
        current_column1_Title := "Rank"
        If(Current_Label="Global_Top_Ten_(System_Most_Played)")
            current_column2_Title := "System"
        Else
            current_column2_Title := "Game"
        If((Current_Label="System_Top_Ten_(Most_Played)")or(Current_Label="Global_Top_Ten_(Most_Played)")){
            current_column3_Title := "Total Time"
        } If Else ((Current_Label="System_Top_Ten_(Times_Played)")or(Current_Label="Global_Top_Ten_(Times_Played)")){
            current_column3_Title := "Number of Times"
        } If Else ((Current_Label="System_Top_Ten_(Average_Time)")or(Current_Label="Global_Top_Ten_(Average_Time)")) {
            current_column3_Title := "Average Time"
        }
    }
    ; Drawing Title
    If !(Current_Label="General_Statistics"){
        If (FullScreenView=1){
            Gdip_Alt_TextToGraphics(Pause_G29, current_column2_Title, OptionsStatisticsTableTitle2, Pause_SubMenu_Font, 0, 0)
            Gdip_Alt_TextToGraphics(Pause_G29, current_column3_Title, OptionsStatisticsTableTitle3, Pause_SubMenu_Font, 0, 0)
        } Else {
            Gdip_Alt_TextToGraphics(Pause_G27, current_column2_Title, OptionsStatisticsTableTitle2, Pause_SubMenu_Font, 0, 0)
            Gdip_Alt_TextToGraphics(Pause_G27, current_column3_Title, OptionsStatisticsTableTitle3, Pause_SubMenu_Font, 0, 0)
        }
    }   
    If (Current_Label="Global_Last_Played_Games") {
        If (FullScreenView=1)
            Gdip_Alt_TextToGraphics(Pause_G29, current_column3_TitleExtra, "x" . posStatisticsTableX3 . " y" . posStatisticsTableTitleY+Pause_Statistics_VdistBetwTableLines . " Right c" . Pause_Statistics_TitleFontColor . " r4 s" . Pause_Statistics_TableFontSize . " bold", Pause_SubMenu_Font, 0, 0)
        else
            Gdip_Alt_TextToGraphics(Pause_G27, current_column3_TitleExtra, "x" . posStatisticsTableX3 . " y" . posStatisticsTableTitleY+Pause_Statistics_VdistBetwTableLines . " Right c" . Pause_Statistics_TitleFontColor . " r4 s" . Pause_Statistics_TableFontSize . " bold", Pause_SubMenu_Font, 0, 0)
        posStatisticsTableY := posStatisticsTableY+Pause_Statistics_VdistBetwTableLines 
    }
    If(FullScreenView=1)    
        Gdip_Alt_TextToGraphics(Pause_G29, current_column1_Title, OptionsStatisticsTableTitle, Pause_SubMenu_Font, 0, 0)  
    Else
        Gdip_Alt_TextToGraphics(Pause_G27, current_column1_Title, OptionsStatisticsTableTitle, Pause_SubMenu_Font, 0, 0)              
    ;Drawing Table contents
    Loop, parse, Statistics_var_List_%current_item%,| 
        {
        StatisticsTablecount++
        stringreplace, current_column1, a_loopfield, _, %a_space%,all
        If(((V2SubMenuItem = A_index ) and (HSubMenuItem=2)) or (FullScreenView=1))
            color2 := Pause_MainMenu_LabelSelectedColor
        If(A_index >= V2SubMenuItem){  
            ; Column 2 and 3 values
            If(Current_Label="General_Statistics"){
                If(A_index=1)
                    current_column3 := gameInfo["Name"].Value
                Else If(A_index=2)
                    current_column3 := SystemName
                Else {
                    current_column3_Label := "Value_" . Current_Label_Without_Parenthesis . "_Statistic_" . A_index-2
                    current_column3 := %current_column3_Label%
                }
            } Else If (Current_Label="Global_Last_Played_Games"){
                current_column1_Label := "Value_" . Current_Label_Without_Parenthesis . "_Name_" . A_index
                current_column3_Label := "Value_" . Current_Label_Without_Parenthesis . "_System_" . A_index
                current_column1 := %current_column1_Label%
                current_column3 := %current_column3_Label%
            } Else {
                current_column2_Label := "Value_" . Current_Label_Without_Parenthesis . "_Name_" . A_index
                current_column3_Label := "Value_" . Current_Label_Without_Parenthesis . "_Number_" . A_index
                current_column2 := %current_column2_Label%
                current_column3 := %current_column3_Label%                
            }  
            ; Max Size for columns
            If(Current_Label="General_Statistics"){
                statsTextSpace := posStatisticsTableX3 - posStatisticsTableX - Pause_Statistics_MarginBetweenTableColumns - MeasureText(current_column1, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
                currentTextSize := MeasureText(current_column3, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
            } Else if (Current_Label="Global_Last_Played_Games"){
                statsTextSpace := posStatisticsTableX3 - posStatisticsTableX - Pause_Statistics_MarginBetweenTableColumns - MeasureText(current_column1, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
                currentTextSize := MeasureText(current_column3, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
            } else {
                statsTextSpace1 := posStatisticsTableX2 - posStatisticsTableX - Pause_Statistics_MarginBetweenTableColumns - MeasureText(current_column1, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
                statsTextSpace2 := posStatisticsTableX3 - posStatisticsTableX2 - Pause_Statistics_MarginBetweenTableColumns - MeasureText(current_column3, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
                statsTextSpace := 2* ((statsTextSpace1<statsTextSpace2) ? statsTextSpace1 : statsTextSpace2)
                currentTextSize := MeasureText(current_column2, "c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold",Pause_SubMenu_Font)
            }
            ; Text Options
			OptionsStatisticsTable := "x" . posStatisticsTableX . " y" . posStatisticsTableY . " Left c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold"
            If ((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")) {
                OptionsStatisticsTable3 := "x" . posStatisticsTableX3-Pause_Statistics_MarginBetweenTableColumns-statsTextSpace . " y" . posStatisticsTableY . " w" . statsTextSpace . " h" . Pause_Statistics_TableFontSize . " Right c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold"
            } else {
                OptionsStatisticsTable2 := "x" . posStatisticsTableX2-statsTextSpace//2 . " y" . posStatisticsTableY . " w" . statsTextSpace . " h" . Pause_Statistics_TableFontSize . " Center c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold"
                OptionsStatisticsTable3 := "x" . posStatisticsTableX3 . " y" . posStatisticsTableY . " Right c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold"
            }
            ; Draw Column 1
            If(Current_Label="Global_Last_Played_Games"){
                If (FullScreenView=1)
                    Gdip_Alt_TextToGraphics(Pause_G29, current_column1, OptionsStatisticsTable, Pause_SubMenu_Font, 0, 0)   
                else
                    Gdip_Alt_TextToGraphics(Pause_G27, current_column1, OptionsStatisticsTable, Pause_SubMenu_Font, 0, 0)   
            } Else {
                If (FullScreenView=1)
                    Gdip_Alt_TextToGraphics(Pause_G29, current_column1, OptionsStatisticsTable, Pause_SubMenu_Font, 0, 0)  
                Else 
                    Gdip_Alt_TextToGraphics(Pause_G27, current_column1, OptionsStatisticsTable, Pause_SubMenu_Font, 0, 0)
            }
            ; Draw Column 2 and 3
            If((V2SubMenuItem = A_index ) and (HSubMenuItem=2)){ ; test if current text fits. If not, do a scrolling text effect
                if ( currentTextSize <= statsTextSpace) { ; draw normaly the text on screen
                    If((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")){
                        if  (FullScreenView=1)
                            Gdip_Alt_TextToGraphics(Pause_G29, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)  
                        else
                            Gdip_Alt_TextToGraphics(Pause_G27, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)        
                    } else {
                        If(FullScreenView=1)   
                            Gdip_Alt_TextToGraphics(Pause_G29, current_column2, OptionsStatisticsTable2, Pause_SubMenu_Font, 0, 0) 
                        Else
                            Gdip_Alt_TextToGraphics(Pause_G27, current_column2, OptionsStatisticsTable2, Pause_SubMenu_Font, 0, 0)   
                    }
                } else { ; start scrolling text effect	
                    initStatsPixels := 0
                    xIncrementStatsScroll := 0
                    yStatsScroll := posStatisticsTableY
                    colorStatsScroll := color2
                    sizeStatsScroll := Pause_Statistics_TableFontSize
                    If((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")){
                        textStatsScroll := current_column3
                        xStatsScroll := posStatisticsTableX3-statsTextSpace
                    } else {
                        textStatsScroll := current_column2
                        xStatsScroll := posStatisticsTableX2-statsTextSpace//2
                    }
                    SetTimer, UpdateStatsScrollingText, 20
                }
            } else {
                If((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")){
                    if  (FullScreenView=1)
                        Gdip_Alt_TextToGraphics(Pause_G29, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)  
                    else
                        Gdip_Alt_TextToGraphics(Pause_G27, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)        
                } else {
                    If(FullScreenView=1)   
                        Gdip_Alt_TextToGraphics(Pause_G29, current_column2, OptionsStatisticsTable2, Pause_SubMenu_Font, 0, 0) 
                    Else
                        Gdip_Alt_TextToGraphics(Pause_G27, current_column2, OptionsStatisticsTable2, Pause_SubMenu_Font, 0, 0)   
                }
            }
            If(VSubMenuItem > 2){
                If(FullScreenView=1)    
                    Gdip_Alt_TextToGraphics(Pause_G29, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)     
                else
                    Gdip_Alt_TextToGraphics(Pause_G27, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0) 
            }
            posStatisticsTableY := posStatisticsTableY+Pause_Statistics_VdistBetwTableLines            
            ; Extra Info
            If(VSubMenuItem > 6){
                current_column2_Label := % "Value_" . Current_Label_Without_Parenthesis . "_System_" . A_index
                current_column2 := % %current_column2_Label%
				OptionsStatisticsTable2 := "x" . posStatisticsTableX2 . " y" . posStatisticsTableY . " Center c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold"
                If(FullScreenView<>1)    
                    Gdip_Alt_TextToGraphics(Pause_G27, current_column2, OptionsStatisticsTable2, Pause_SubMenu_Font, 0, 0)   
                Else
                    Gdip_Alt_TextToGraphics(Pause_G29, current_column2, OptionsStatisticsTable2, Pause_SubMenu_Font, 0, 0)   
                posStatisticsTableY := posStatisticsTableY+Pause_Statistics_VdistBetwTableLines
            }            
            If(VSubMenuItem = 2){
                current_column3_Label := % "Value_" . Current_Label_Without_Parenthesis . "_Date_" . A_index
                current_column3 := % %current_column3_Label%
				OptionsStatisticsTable3 := "x" . posStatisticsTableX3 . " y" . posStatisticsTableY . " Right c" . color2 . " r4 s" . Pause_Statistics_TableFontSize . " bold"
                If(FullScreenView<>1)    
                    Gdip_Alt_TextToGraphics(Pause_G27, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)                     
                Else
                    Gdip_Alt_TextToGraphics(Pause_G29, current_column3, OptionsStatisticsTable3, Pause_SubMenu_Font, 0, 0)                     
                posStatisticsTableY := posStatisticsTableY+Pause_Statistics_VdistBetwTableLines
            }
            color2 := Pause_MainMenu_LabelDisabledColor
        }
    }
    If(FullScreenView <> 1){
        If((VSubMenuItem<>0) and (HSubMenuItem=2)){
            SubMenuHelpText("Press Select Key to go FullScreen")
        } Else If ((VSubMenuItem<>0) and (HSubMenuItem=1)){
            CurrentHelpText := "Press Left or Right to Select the Statistics"
            SubMenuHelpText(CurrentHelpText)
        } Else {            
        Gdip_GraphicsClear(Pause_G33)
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    } Else {
        Pause_SubMenu_FullScreenHelpBoxHeight := 4*Pause_SubMenu_FullScreenFontSize
        Pause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up or Down to move between Statistics", "Left r4 s" . Pause_SubMenu_FullScreenFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, round((Pause_SubMenu_MovesListFullScreenWidth-Pause_SubMenu_FullScreenHelpBoxWidth)/2), baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-5*Pause_SubMenu_FullScreenFontSize, Pause_SubMenu_FullScreenHelpBoxWidth,Pause_SubMenu_FullScreenHelpBoxHeight,Pause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(Pause_SubMenu_MovesListFullScreenWidth/2)
        posFullScreenTextY := round(baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-4*Pause_SubMenu_FullScreenFontSize-Pause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText := "x" . posFullScreenTextX . " y" . posFullScreenTextY . " Center c" . Pause_SubMenu_FullScreenFontColor . " r4 s" . Pause_SubMenu_FullScreenFontSize . " bold"
        CurrentHelpText := "Press Select Key to Exit Full Screen`nPress Up or Down to move between Statistics"
        Gdip_Alt_TextToGraphics(Pause_G29, CurrentHelpText, OptionsFullScreenText, Pause_SubMenu_Font, 0, 0)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,round((baseScreenWidth-Pause_SubMenu_StatisticsFullScreenWidth)/2), Pause_SubMenu_FullScreenMargin, Pause_SubMenu_StatisticsFullScreenWidth, baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
Return 
            
UpdateStatsScrollingText:
    scrollingVelocity := 2
	xIncrementStatsScroll := (-xIncrementStatsScroll >= WidthStatsScrollingText3) ? initStatsPixels : xIncrementStatsScroll-scrollingVelocity
	initStatsPixels := statsTextSpace
    Gdip_GraphicsClear(Pause_G30)
    pGraphUpd(Pause_G30,statsTextSpace,sizeStatsScroll)
    WidthStatsScrollingText := Gdip_Alt_TextToGraphics(Pause_G30, textStatsScroll, "x" . xIncrementStatsScroll . " y0 Left c" . colorStatsScroll . " r4 s" . sizeStatsScroll . " Bold", Pause_SubMenu_Font, (xIncrementStatsScroll < 0) ? initStatsPixels-xIncrementStatsScroll : initStatsPixels, sizeStatsScroll)
    StringSplit, WidthStatsScrollingText, WidthStatsScrollingText, |
    if (FullScreenView=1)
        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, (baseScreenWidth-Pause_SubMenu_StatisticsFullScreenWidth)//2+xStatsScroll, Pause_SubMenu_FullScreenMargin+yStatsScroll, statsTextSpace, sizeStatsScroll,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    else
        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width+xStatsScroll, baseScreenHeight-Pause_SubMenu_Height+yStatsScroll, statsTextSpace, sizeStatsScroll,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
Return      



;-------Guides Sub Menu-------
Guides:
    TextImagesAndPDFMenu("Guides")
Return

;-------Manuals Sub Menu-------
Manuals:
    TextImagesAndPDFMenu("Manuals")
Return

;-------History dat Sub Menu-------
History:
    TextImagesAndPDFMenu("History")
Return

;-----------------COMMANDS-------------
MoveRight:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If (VSubMenuItem=0){
        If (SelectedMenuOption:="Videos"){
            AnteriorFilePath := ""
            V2Submenuitem := 1
            try CurrentVideoPlayStatus := wmpVideo.playState
            If(CurrentVideoPlayStatus=3) {
                try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
                RLLog.Debug(A_ThisLabel . " - VideoPosition at main menu change:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%)
                try wmpVideo.controls.stop
            }
            if MusicPausedonVideosMenu
                {
                try wmpMusic.controls.play
                MusicPausedonVideosMenu := false                    
            }
            Gui,Pause_GUI31: Show, Hide
            Gui, Pause_GUI32: Show
        }
        Pause_MainMenuItem := Pause_MainMenuItem+1
        HSubMenuItem := 1
        Gdip_GraphicsClear(Pause_G29)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29, baseScreenWidth - Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height,Pause_SubMenu_Width,Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G33)
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G34)
        Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gosub MainMenuSwap
        Gdip_GraphicsClear(Pause_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        RLLog.Info(A_ThisLabel . " - Loaded Main Menu Bar. Current Main Menu Label: " Pause_MainMenuSelectedLabel)
        If (SubMenuDrawn=1){
            Gdip_GraphicsClear(Pause_G26)
            Alt_UpdateLayeredWindow(Pause_hwnd26, Pause_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            Gdip_GraphicsClear(Pause_G27)
            Alt_UpdateLayeredWindow(Pause_hwnd27, Pause_hdc27,baseScreenWidth-Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            SubMenuDrawn := 0
        }
    } Else If (SelectedMenuOption="Sound") and (VSubMenuItem=1){
        Pause_VolumeMaster := round(Pause_VolumeMaster + Pause_SoundBar_vol_Step)+0
        Pause_VolumeMaster := round(Pause_VolumeMaster//Pause_SoundBar_vol_Step*Pause_SoundBar_vol_Step)+0 ;Avoiding volume increase in non multiple steps
        If  Pause_VolumeMaster < 0 
            Pause_VolumeMaster := 0
        If  Pause_VolumeMaster > 100
            Pause_VolumeMaster := 100
        setVolume(Pause_VolumeMaster)
        gosub, DrawSubMenu
    } Else {
        If((FullScreenView = 1) and (ZoomLevel <> 100)){
            HorizontalPanFullScreen := HorizontalPanFullScreen-Pause_SubMenu_FullScreenPanSteps
            gosub, DrawSubMenu            
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="MovesList")){
            V2SubMenuItem := V2SubMenuItem+1
            Gosub SubMenuSwap 
            gosub, DrawSubMenu   
        } Else If ((FullScreenView = 1) and ((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork")) and (CurrentFileExtension = "txt")){
            V2SubMenuItem := V2SubMenuItem+1
            If  V2SubMenuItem < 1 
            V2SubMenuItem := TotaltxtPages
            If  (V2SubMenuItem > TotaltxtPages)
            V2SubMenuItem := 1
            Gosub SubMenuSwap 
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% := V2SubMenuItem
            gosub, DrawSubMenu
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="HighScore")){
            VSubMenuItem := VSubMenuItem+1
            Gosub SubMenuSwap   
            gosub, DrawSubMenu
        } Else If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){   
            If (V2SubMenuItem > 2)
                HSubMenuItem := HSubMenuItem+1
            Else 
                HSubMenuItem := 1
            Gosub SubMenuSwap
            gosub, DrawSubMenu
        } Else {
            HSubMenuItem := HSubMenuItem+1
            Gosub SubMenuSwap 
            if (VSubMenuItem >= 0)
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% := HSubMenuItem            
            gosub, DrawSubMenu
        }
    }
    If (SelectedMenuOption<>"Sound")
        settimer, UpdateMusicPlayingInfo, off
    If (SelectedMenuOption<>"Videos")
        settimer, UpdateVideoPlayingInfo, off
    DirectionCommandRunning := false   
Return


MoveLeft:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If(VSubMenuItem=0){
        If (SelectedMenuOption:="Videos"){
            AnteriorFilePath := ""
            V2Submenuitem := 1
            try CurrentVideoPlayStatus := wmpVideo.playState
            If(CurrentVideoPlayStatus=3) {
                try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
                RLLog.Debug(A_ThisLabel . " - VideoPosition at main menu change:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%)
                try wmpVideo.controls.stop
            }
            if MusicPausedonVideosMenu
                {
                try wmpMusic.controls.play
                MusicPausedonVideosMenu := false                    
            }
            Gui,Pause_GUI31: Show, Hide
            Gui, Pause_GUI32: Show
        }
        Pause_MainMenuItem := Pause_MainMenuItem-1
        HSubMenuItem=1
        Gdip_GraphicsClear(Pause_G29)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29, baseScreenWidth - Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height,Pause_SubMenu_Width,Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
        Gdip_GraphicsClear(Pause_G33)
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G34)
        Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gosub MainMenuSwap
        Gdip_GraphicsClear(Pause_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        RLLog.Info(A_ThisLabel . " - Loaded Main Menu Bar. Current Main Menu Label: " Pause_MainMenuSelectedLabel)
        If(SubMenuDrawn=1){
            Gdip_GraphicsClear(Pause_G26)
            Alt_UpdateLayeredWindow(Pause_hwnd26, Pause_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            Gdip_GraphicsClear(Pause_G27)
            Alt_UpdateLayeredWindow(Pause_hwnd27, Pause_hdc27,baseScreenWidth-Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            SubMenuDrawn=0
        }
    } Else If (SelectedMenuOption="Sound") and (VSubMenuItem=1){
        Pause_VolumeMaster := round(Pause_VolumeMaster - Pause_SoundBar_vol_Step)+0
        Pause_VolumeMaster := round(Pause_VolumeMaster//Pause_SoundBar_vol_Step*Pause_SoundBar_vol_Step)+0 ;Avoiding volume decreae in non multiple steps
        If  Pause_VolumeMaster < 0 
            Pause_VolumeMaster := 0
        If  Pause_VolumeMaster > 100
            Pause_VolumeMaster := 100
        setVolume(Pause_VolumeMaster)
        gosub, DrawSubMenu
    } Else {
        If((FullScreenView = 1) and (ZoomLevel <> 100)){
            HorizontalPanFullScreen := HorizontalPanFullScreen+Pause_SubMenu_FullScreenPanSteps
            gosub, DrawSubMenu
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="MovesList")){
            V2SubMenuItem := V2SubMenuItem-1
            Gosub SubMenuSwap
            gosub, DrawSubMenu
        } Else If ((FullScreenView = 1) and ((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork")) and (CurrentFileExtension = "txt")){
            V2SubMenuItem := V2SubMenuItem-1
            If  V2SubMenuItem < 1 
            V2SubMenuItem := TotaltxtPages
            If  (V2SubMenuItem > TotaltxtPages)
            V2SubMenuItem := 1
            Gosub SubMenuSwap 
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% := V2SubMenuItem
            gosub, DrawSubMenu
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="HighScore")){
            VSubMenuItem := VSubMenuItem-1
            Gosub SubMenuSwap
            gosub, DrawSubMenu
        } Else If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){   
            If (V2SubMenuItem > 2)
                HSubMenuItem := HSubMenuItem-1
            Else 
                HSubMenuItem := 1
            Gosub SubMenuSwap
            gosub, DrawSubMenu
        } Else {
            HSubMenuItem := HSubMenuItem-1
            Gosub SubMenuSwap
            if (VSubMenuItem >= 0)
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% := HSubMenuItem
            gosub, DrawSubMenu
        }
    }
    If (SelectedMenuOption<>"Sound")
        settimer, UpdateMusicPlayingInfo, off
    If (SelectedMenuOption<>"Videos")
        settimer, UpdateVideoPlayingInfo, off
    DirectionCommandRunning := false   
Return

MoveUp:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If (SelectedMenuOption="Shutdown"){
        DirectionCommandRunning := false   
        Return
    }
    If((FullScreenView = 1) and (ZoomLevel <> 100)){
        VerticalPanFullScreen := VerticalPanFullScreen+Pause_SubMenu_FullScreenPanSteps       
        gosub, DrawSubMenu
        DirectionCommandRunning := false   
        Return
    }
    Previous_VSubMenuItem := VSubMenuItem
    If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
        VSubMenuItem := VSubMenuItem+1
        if (HSubMenuItem=2) {
            V3SubMenuItem := V3SubMenuItem-1
        } else {
            V2SubMenuItem := V2SubMenuItem-1
			If  V2SubMenuItem < 1 
				V2SubMenuItem := 18
			If  V2SubMenuItem > 18
				V2SubMenuItem := 1
        }
    }
    VSubMenuItem := VSubMenuItem-1
    If((SelectedMenuOption="Statistics")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
    }
    If((SelectedMenuOption="MovesList")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
        If  V2SubMenuItem < 1 
            V2SubMenuItem := TotalMovesListPages
        If  (V2SubMenuItem > TotalMovesListPages)
            V2SubMenuItem := 1
    }
    If(((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork"))and(HSubMenuItem>1)and (VSubMenuItem>=0)){
        If((!(CurrentFileExtension ="pdf")) and (!(PauseMediaObj[SelectedMenuOption][CurrentLabelName].Type="ImageGroup")) and (!(CurrentCompressedFileExtension="true"))){
            VSubMenuItem := VSubMenuItem+1
        }
        If(CurrentFileExtension ="txt")
        {   if (TotaltxtPages>1)
            {   V2SubMenuItem := V2SubMenuItem-1
                If  V2SubMenuItem < 1 
                    V2SubMenuItem := TotaltxtPages
                If  (V2SubMenuItem > TotaltxtPages)
                    V2SubMenuItem := 1
            } else
                VSubMenuItem := VSubMenuItem-1
        }
        If (VSubMenuItem>=0)
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% := V2SubMenuItem
    }
    If((SelectedMenuOption="Videos") and (HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
        If  V2SubMenuItem < 1 
            V2SubMenuItem := 5
        If  V2SubMenuItem > 5
            V2SubMenuItem := 1
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% := V2SubMenuItem
    }
    Gosub SubMenuSwap
    If((Previous_VSubMenuItem = 0) or (VSubMenuItem = 0)){
        HSubMenuItem := 1
        Gdip_GraphicsClear(Pause_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        RLLog.Info(A_ThisLabel . " - Loaded Main Menu Bar. Current Main Menu Label: " Pause_MainMenuSelectedLabel)
    }
    If (SelectedMenuOption="Sound"){
        If (VSubMenuItem = 3){
            currentPlayindex := HSubmenuitemSoundVSubmenuitem3           
        } Else {
            PreviousCurrentMusicButton := ""
            Gdip_GraphicsClear(Pause_G30)
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    }
    If (SelectedMenuOption="Videos"){
        If (HSubMenuItem <> 2){
            Gdip_GraphicsClear(Pause_G30)
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    }
    gosub, DrawSubMenu  
    DirectionCommandRunning := false  
Return

MoveDown:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If (SelectedMenuOption="Shutdown"){
        DirectionCommandRunning := false   
        Return
    }
    If((FullScreenView = 1) and (ZoomLevel <> 100)){
        VerticalPanFullScreen := VerticalPanFullScreen-Pause_SubMenu_FullScreenPanSteps     
        gosub, DrawSubMenu
        DirectionCommandRunning := false   
        Return
    }
    Previous_VSubMenuItem := VSubMenuItem
    If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
        VSubMenuItem := VSubMenuItem-1
        if (HSubMenuItem=2) {
            V3SubMenuItem := V3SubMenuItem+1
        } else {
            V2SubMenuItem := V2SubMenuItem+1
			If  V2SubMenuItem < 1 
				V2SubMenuItem := 18
			If  V2SubMenuItem > 18
				V2SubMenuItem := 1
        }
    }
    VSubMenuItem := VSubMenuItem+1
    If((SelectedMenuOption="Statistics")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
    }
    If((SelectedMenuOption="MovesList")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
        If  V2SubMenuItem < 1 
            V2SubMenuItem := TotalMovesListPages
        If  (V2SubMenuItem > TotalMovesListPages)
            V2SubMenuItem := 1
    }
    If(((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork"))and (HSubMenuItem>1) and (VSubMenuItem>=0)){
        If((CurrentFileExtension <> "pdf") and (!(PauseMediaObj[SelectedMenuOption][CurrentLabelName].Type="ImageGroup")) and (CurrentCompressedFileExtension<> "true")){
            VSubMenuItem := VSubMenuItem-1
        }
        If(CurrentFileExtension ="txt")
        {   if (TotaltxtPages>1)
            {   V2SubMenuItem := V2SubMenuItem+1
                If  V2SubMenuItem < 1 
                    V2SubMenuItem := TotaltxtPages
                If  (V2SubMenuItem > TotaltxtPages)
                    V2SubMenuItem := 1
            } else
                VSubMenuItem := VSubMenuItem+1
        }
        If (VSubMenuItem>=0)
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% := V2SubMenuItem
    }
    If((SelectedMenuOption="Videos") and (HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
        If  V2SubMenuItem < 1 
            V2SubMenuItem := 5
        If  V2SubMenuItem > 5
            V2SubMenuItem := 1
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% := V2SubMenuItem
    }
    Gosub SubMenuSwap
    If((Previous_VSubMenuItem = 0) or (VSubMenuItem = 0)){
        HSubMenuItem := 1
         Gdip_GraphicsClear(Pause_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        RLLog.Info(A_ThisLabel . " - Loaded Main Menu Bar. Current Main Menu Label: " Pause_MainMenuSelectedLabel)
    }
    If (SelectedMenuOption="Sound"){
        If (VSubMenuItem = 3){
            currentPlayindex := HSubmenuitemSoundVSubmenuitem3            
        } Else {
            PreviousCurrentMusicButton := "" 
            Gdip_GraphicsClear(Pause_G30)
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    }
    If (SelectedMenuOption="Videos"){
        If (HSubMenuItem <> 2){
            Gdip_GraphicsClear(Pause_G30)
            Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    }
    gosub, DrawSubMenu  
    DirectionCommandRunning := false   
Return


BacktoMenuBar:
    If (SelectedMenuOption = "Shutdown")
        Return
    If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1))
        settimer, CheckJoyPresses, off
    VSubMenuItem := 0
    HSubMenuItem := 1
    Gdip_GraphicsClear(Pause_G30)
    Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    If(FullScreenView = 1){
        Gdip_GraphicsClear(Pause_G29)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G33)
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
        FullScreenView := 0   
    }
    If (SelectedMenuOption:="Videos"){
        AnteriorFilePath := ""
        V2Submenuitem := 1
        HSubMenuItem := 1
        try CurrentVideoPlayStatus := wmpVideo.playState
        If(CurrentVideoPlayStatus=3) {
            try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
            RLLog.Debug(A_ThisLabel . " - VideoPosition at back to main menu:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%)
            try wmpVideo.controls.stop
        }
        Gui,Pause_GUI31: Show, Hide
        Gui, Pause_GUI32: Show
    }
    gosub, DrawSubMenu 
    Gdip_GraphicsClear(Pause_G25)
    Gosub DrawMainMenuBar
    Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    RLLog.Info(A_ThisLabel . " - Loaded Main Menu Bar. Current Main Menu Label: " Pause_MainMenuSelectedLabel)
Return


MainMenuSwap:
    MenuChanged := 1
    VSubMenuItem := 0
    HSubMenuItem := 1
    FullScreenView := 0
    If !submenuMouseClickChange
        SoundPlay %Pause_MenuSoundPath%\menu.wav
    Else
        submenuMouseClickChange := ""
    If  Pause_MainMenuItem = 0
        Pause_MainMenuItem := TotalMainMenuItems
    If  (Pause_MainMenuItem = TotalMainMenuItems + 1)
        Pause_MainMenuItem := 1
    Loop, parse, Pause_MainMenu_Itens,|
    {
        If (Pause_MainMenuItem = a_Index) { 
            StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
        }
    }
Return


SubMenuSwap:
	totalMediaLabels := (PauseMediaObj[SelectedMenuOption].TotalLabels) ? PauseMediaObj[SelectedMenuOption].TotalLabels : 0
    If((SelectedMenuOption="SaveState")or(SelectedMenuOption="LoadState")or(SelectedMenuOption="HighScore")){
        If  VSubMenuItem < 0 
            VSubMenuItem := totalMediaLabels
        If  (VSubMenuItem > totalMediaLabels)
            VSubMenuItem := 0
    }
    If(SelectedMenuOption="ChangeDisc"){
        If  HSubMenuItem < 1 
            HSubMenuItem := PauseMediaObj[SelectedMenuOption].TotalLabels
        If  (HSubMenuItem > PauseMediaObj[SelectedMenuOption].TotalLabels)
            HSubMenuItem := 1  
        If  VSubMenuItem < 0 
            VSubMenuItem := 1
        If  VSubMenuItem > 1
            VSubMenuItem := 0
    }
    If(SelectedMenuOption="Sound"){
        currentObj := {}
        currentObj["TotalLabels"] := 2
        TotalVSubMenuItem2SoundItems := 1
        If(Pause_CurrentPlaylist<>""){
            currentObj["TotalLabels"] := 3
            TotalVSubMenuItem2SoundItems := 3
        }
        PauseMediaObj.Insert("Sound", currentObj) 
        If  VSubMenuItem < 0 
            VSubMenuItem := totalMediaLabels
        If  (VSubMenuItem > totalMediaLabels)
            VSubMenuItem := 0
        If(VSubMenuItem=2){
            If  HSubMenuItem < 1 
                HSubMenuItem := TotalVSubMenuItem2SoundItems
            If  (HSubMenuItem > TotalVSubMenuItem2SoundItems)
                HSubMenuItem := 1
        }
    }
    If(SelectedMenuOption="Settings"){
        if ((found7z="true") and (sevenZEnabled = "true"))
            maxItems := 2
        else
            maxItems := 1
        If  VSubMenuItem < 0 
            VSubMenuItem := maxItems
        If  (VSubMenuItem > maxItems)
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="MovesList"){
        If  HSubMenuItem < 1 
            HSubMenuItem := 2
        If  HSubMenuItem > 2
            HSubMenuItem := 1  
        If  VSubMenuItem < 0 
            VSubMenuItem := totalMediaLabels
        If  (VSubMenuItem > totalMediaLabels)
            VSubMenuItem := 0
        If  V2SubMenuItem < 1 
            V2SubMenuItem := TotalMovesListPages
        If  (V2SubMenuItem > TotalMovesListPages)
            V2SubMenuItem := 1
    }
    If(SelectedMenuOption="Statistics"){
        If  HSubMenuItem < 1 
            HSubMenuItem := 2
        If  HSubMenuItem > 2
            HSubMenuItem := 1  
        If  VSubMenuItem < 0 
            VSubMenuItem := % StatisticsLabelCount
        If  VSubMenuItem > % StatisticsLabelCount
            VSubMenuItem := 0
        If  V2SubMenuItem < 1 
            V2SubMenuItem := % StatisticsTablecount
        If  V2SubMenuItem > % StatisticsTablecount
            V2SubMenuItem := 1
    }    
    If((SelectedMenuOption="Guides")or(SelectedMenuOption="Artwork")or(SelectedMenuOption="History")or(SelectedMenuOption="Manuals")){
        If  HSubMenuItem < 0
            HSubMenuItem := 1
        If  HSubMenuItem > % TotalCurrentPages
            HSubMenuItem := 1 
        If  VSubMenuItem < 0
            VSubMenuItem := totalMediaLabels
        If  (VSubMenuItem > totalMediaLabels)
            VSubMenuItem := 0
    }
    If(SelectedMenuOption="Controller"){
        If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
            If  HSubMenuItem < 0
                HSubMenuItem := 2
            If  HSubMenuItem > 2
                HSubMenuItem := 1
        } else {
            If  HSubMenuItem < 0
                HSubMenuItem := 1
            If  HSubMenuItem > % TotalCurrentPages
                HSubMenuItem := 1 
            
        }
        If (keymapperEnabled = "true") {
            If  (VSubMenuItem < -1)
                VSubMenuItem := totalMediaLabels
            If  (VSubMenuItem > totalMediaLabels)
                VSubMenuItem := -1
        } Else {
            If  VSubMenuItem < 0
                VSubMenuItem := totalMediaLabels
            If  (VSubMenuItem > totalMediaLabels)
                VSubMenuItem := 0            
        }
    }    
    If(SelectedMenuOption="Videos"){
        If  VSubMenuItem < 0
            VSubMenuItem := totalMediaLabels
        If  (VSubMenuItem > totalMediaLabels)
            VSubMenuItem := 0
        
        If  HSubMenuItem < 1
            HSubMenuItem := 2
        If  HSubMenuItem > 2
            HSubMenuItem := 1         
    }
    If(VSubMenuItem=0){
        If not(SelectedMenuOption="Sound"){
            Gdip_GraphicsClear(Pause_G29)
            Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            Gdip_GraphicsClear(Pause_G33)
            Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
            Gdip_GraphicsClear(Pause_G34)
            Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
        FullScreenView := 0  
    }
Return


ToggleItemSelectStatus:
    If (SelectedMenuOption = "Shutdown") {
        If !(rlMode = "pause")
            close_emulator := true
        gosub, ExitPause
    }
    If(SelectedMenuOption="LoadState"){ 
        If SlotEmpty
            Return
        ItemSelected := 1
        gosub, ExitPause
    }
    If(SelectedMenuOption="SaveState"){ 
        ItemSelected := 1
        gosub, ExitPause
    }
    If(SelectedMenuOption="ChangeDisc"){
        gosub, DisableKeys
        SetTimer, UpdateDescription, off
        SetTimer, DiscChangeUpdate, off
        ItemSelected := 1
        selectedRom:=romTable[HSubMenuItem,1]	; need to convert this for the next line to work
        selectedRomNum:=romTable[HSubMenuItem,5]	; Store selected rom's Media and number
        RLLog.Debug(A_ThisLabel . " - SelectGame - User selected to load: " . selectedRom)
        SplitPath, selectedRom,,Pause_RomPath,Pause_RomExt,Pause_DbName
        Pause_RomExt := "." . Pause_RomExt	; need to add the period back in otherwise ByRef on the 7z call doesn't work
        ;creating Disc Changing Screen
        Loop, 9 {
            If not (A_Index=8) {
                CurrentGUI := A_Index+23
                Gdip_GraphicsClear(Pause_G%CurrentGUI%)
                Alt_UpdateLayeredWindow(Pause_hwnd%CurrentGUI%, Pause_hdc%CurrentGUI%, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            }
        }
        pGraphUpd(Pause_G24,baseScreenWidth,baseScreenHeight)
        DiscChangeTextWidth := MeasureText("Changing Disc", "Left r4 s" . Pause_MainMenu_LabelFontsize . " bold",Pause_MainMenu_LabelFont)        
        Gdip_Alt_FillRoundedRectangle(Pause_G24, BlackGradientBrush, (baseScreenWidth-DiscChangeTextWidth)//2-Pause_ChangingDisc_Margin//2, (baseScreenHeight-Pause_MainMenu_LabelFontsize)//2-Pause_ChangingDisc_Margin//2, DiscChangeTextWidth+Pause_ChangingDisc_Margin, Pause_MainMenu_LabelFontsize+Pause_ChangingDisc_Margin,Pause_ChangingDisc_Rounded_Corner)
        Gdip_Alt_TextToGraphics(Pause_G24, "Changing Disc", "x" . (baseScreenWidth-DiscChangeTextWidth)//2 . "y" . (baseScreenHeight-Pause_MainMenu_LabelFontsize)//2 . "Centre c" . Pause_MainMenu_LabelSelectedColor . "r4 s" . Pause_MainMenu_LabelFontsize . " bold", Pause_MainMenu_LabelFont)	
        Alt_UpdateLayeredWindow(Pause_hwnd24, Pause_hdc24, 0, 0, baseScreenWidth, baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        If (sevenZEnabled = "true")	; Only need to continue If 7z support is turned on, this check is in case emu supports loading of compressed roms. No need to decompress our rom If it does
            {	
            If StringUtils.Contains(Pause_RomExt,sevenZFormats)	; Check If our selected rom is compressed.
                {	
                RLLog.Debug(A_ThisLabel . " - SelectGame - This game needs 7z to load. Sending it off for extraction: " . Pause_RomPath . "\" . Pause_DbName . Pause_RomExt)
                7z%HSubMenuItem% := 7z(Pause_RomPath, Pause_DbName, Pause_RomExt, sevenZExtractPath, "pause")	; Send chosen game to 7z for processing. We get back the same vars but updated to the new location.
                selectedRom := Pause_RomPath . "\" . Pause_DbName . Pause_RomExt
                RLLog.Debug(A_ThisLabel . " - SelectGame - Returned from 7z extraction, path to new rom is: " . selectedRom)
                romTable[HSubMenuItem,19] := Pause_RomPath	; storing path to extracted rom in column 19 so 7zCleanUp knows to delete it later
                RLLog.Debug(A_ThisLabel . " - SelectGame - Stored """ . Pause_RomPath . """ for deletion in 7zCleanup.")
            } Else {
                RLLog.Debug(A_ThisLabel . " - SelectGame - This game does not need 7z. Sending it directly to the emu or to Virtual Drive If required.")
            }
            RLLog.Debug(A_ThisLabel . " - SelectGame - Ended")
        }
        Gosub, ExitPause
    }
    If(( (SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork") or (SelectedMenuOption="Statistics") or (SelectedMenuOption="MovesList") or (SelectedMenuOption="HighScore")) and (VSubMenuItem > 0)){
        If(FullScreenView = 1){
            If(SelectedMenuOption="MovesList"){
                AdjustedPage := % (((V2SubMenuItem-1)*(PauseMediaObj[SelectedMenuOption].txtFSLines))/PauseMediaObj[SelectedMenuOption].txtLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
            }
            If(((SelectedMenuOption="Manuals") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="Guides") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="History") and (CurrentFileExtension = "txt"))){
                AdjustedPage := % (((V2SubMenuItem-1)*(PauseMediaObj[SelectedMenuOption].txtFSLines))/PauseMediaObj[SelectedMenuOption].txtLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
                HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% :=  V2SubMenuItem
            }
            SetTimer, ClearFullScreenHelpText1, off
            SetTimer, ClearFullScreenHelpText2, off
            Gdip_GraphicsClear(Pause_G29)
            Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)    
            FullScreenView := 0
            gosub, DrawSubMenu
        } Else {
            If ((CurrentFileExtension = "txt") and (HSubMenuItem=1)) 
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% := 2
            If(SelectedMenuOption="MovesList"){
                if (HSubMenuItem=1)
                    HSubMenuItem := 2
                AdjustedPage := % (((V2SubMenuItem-1)*(PauseMediaObj[SelectedMenuOption].txtLines))/PauseMediaObj[SelectedMenuOption].txtFSLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
            }
            If(((SelectedMenuOption="Manuals") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="Guides") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="History") and (CurrentFileExtension = "txt"))){
                AdjustedPage := % (((V2SubMenuItem-1)*(PauseMediaObj[SelectedMenuOption].txtLines))/PauseMediaObj[SelectedMenuOption].txtFSLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
                HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            }                
            FullScreenView := 1
            ZoomLevel := 100
            gosub, DrawSubMenu
        }
    } 
    If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1)){
        If(FullScreenView = 1) {
            If (V2SubMenuItem = 1){
                Gdip_GraphicsClear(Pause_G29)
                Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)  
                FullScreenView=0
                settimer, CheckJoyPresses, off
            } Else If(V2SubMenuItem = 2){
                LoadPreferredControllers%zz%(JoyIDsPreferredControllers)
                RunKeymapper%zz%("menu",keymapper)
                Loop, 10 { ;Activating Pause Screen
                    CurrentGUI := A_Index+21
                    WinActivate, pauseLayer%CurrentGUI%
                }
                gosub, DrawSubMenu 
            } Else If(V2SubMenuItem > 2){
                If (HSubMenuItem = 2) {
                    currentSelectedJoy := V2SubMenuItem-2
                    currentSelectedProfileNumber := V3SubMenuItem
					KeymapperProfileChangeInPause := 1
                    if !selectedProfile
                        selectedProfile := []
					If (keymapper = "xpadder") {
						selectedProfile[V2SubMenuItem-2,1] := V3SubMenuItem
						selectedProfile[V2SubMenuItem-2,2] := possibleProfilesList[V3SubMenuItem,4] ;store for later use with xpadder and joytokey run functions
					} else if (keymapper="joy2key") OR (keymapper = "joytokey") {
						Loop, 16
						{
							selectedProfile[A_Index,1] := V3SubMenuItem
							selectedProfile[A_Index,2] := possibleProfilesList[V3SubMenuItem,4] ;store for later use with xpadder and joytokey run functions
						}
					}
                    currentSelectedProfileFileName := possibleProfilesList[V3SubMenuItem,1] ;FileName
                    currentSelectedProfileFolderType := possibleProfilesList[V3SubMenuItem,2] ;FolderType
                    currentSelectedProfileControllerSpecificBoolean := possibleProfilesList[V3SubMenuItem,3] ;Controller_specific_Boolean
                    currentSelectedProfileFilePath := possibleProfilesList[V3SubMenuItem,4] ;FilePath
                    HSubMenuItem := 1
                    gosub, DrawSubMenu 
                } else {
                    If (JoyIDsEnabled = "true") {
                        If SelectedController 
                            {
                            Mid1 := joyConnectedInfo[SelectedController,3]
                            Pid1 := joyConnectedInfo[SelectedController,4]
                            Guid1 := joyConnectedInfo[SelectedController,5]
                            ChangeJoystickID%zz%(Mid1,Pid1,GUID1,V2SubMenuItem-2)
                            Mid2 := joyConnectedInfo[V2SubMenuItem-2,3]
                            Pid2 := joyConnectedInfo[V2SubMenuItem-2,4]
                            Guid2 := joyConnectedInfo[V2SubMenuItem-2,5]
                            ChangeJoystickID%zz%(Mid2,Pid2,GUID2,SelectedController)
                            RunKeymapper%zz%("menu",keymapper)
                            SelectedController := ""
                            Loop, 10 { ;Activating Pause Screen
                                CurrentGUI := A_Index+21
                                WinActivate, pauseLayer%CurrentGUI%
                            }
                            gosub, DrawSubMenu 
                        } Else {
                            SelectedController := V2SubMenuItem-2
                            gosub, DrawSubMenu 
                        }
                    } Else {
                        tooltip, Enable JoyIDs to be able to change the controller order 
                        settimer,EndofToolTipDelay, -2000   
                    }
                }
            }
        } Else {
            gosub, CheckConnectedJoys
            Loop, 16
                {
                If (joyConnectedInfo[A_Index,1]) {
                   joyConnectedExist := true
                   break
                }
            }
            If joyConnectedExist
                {
                FullScreenView := 1
                gosub, DrawSubMenu 
                settimer, CheckJoyPresses, 50
            } Else {
                CoordMode, ToolTip, Screen
                tooltip, You need at least one connected controller to use this menu!, baseScreenWidth//2, baseScreenHeight//2
                setTimer, EndofToolTipDelay, -1000
            }
            joyConnectedExist := ""
        }
    }
    If(SelectedMenuOption="Sound"){
        If (VSubMenuItem=2){
            If (HSubmenuitemSoundVSubmenuitem2=1){
                getMute(CurrentMuteStatus)
                If (CurrentMuteStatus=1)
                    setMute(0)
                Else
                    setMute(1)
            } Else If (HSubmenuitemSoundVSubmenuitem2=2){
                If (Pause_KeepPlayingAfterExitingPause="false")
                    Pause_KeepPlayingAfterExitingPause:="true"
                Else
                    Pause_KeepPlayingAfterExitingPause:="false"
            } Else {
                If(Pause_EnableShuffle="false") {
                    Pause_EnableShuffle:="true"
                    try wmpMusic.Settings.setMode("shuffle",true)
                } Else {
                    Pause_EnableShuffle:="false"
                    try wmpMusic.Settings.setMode("shuffle",false)
                }
            }
            gosub, DrawSubMenu
        }
        If (VSubMenuItem=3){
            If (CurrentMusicButton=1)
                try wmpMusic.controls.stop   
            If (CurrentMusicButton=2)               
                try wmpMusic.controls.previous
            If (CurrentMusicButton=3) {
                try CurrentMusicPlayStatus := wmpMusic.playState
                If (CurrentMusicPlayStatus = 3)
                    try wmpMusic.controls.pause   
                Else
                    try wmpMusic.controls.play 
                gosub, DrawSubMenu
            }
            If (CurrentMusicButton=4)            
                try wmpMusic.controls.next            
        }
    }
    If (SelectedMenuOption="Settings"){
        If (VSubMenuItem=1){
            if (currentLockLaunchIndex<4) {
                updatedIndex := currentLockLaunchIndex + 1
                currentLockLaunch := locklaunchValue%updatedIndex%
            } else 
                currentLockLaunch := locklaunchValue1
            gosub, DrawSubMenu
        }If (VSubMenuItem=2){
            If (current7zDelTemp = "true")
                current7zDelTemp := "false"
            Else
                current7zDelTemp := "true"
            gosub, DrawSubMenu
        }
    }
    If((SelectedMenuOption="Videos")and (VSubMenuItem > 0)){
        If((VSubMenuItem > 0)){
            If(FullScreenView = 1){
                If(Pause_Active=true)
                    gosub, EnableKeys
                Gdip_GraphicsClear(Pause_G30)
                Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, baseScreenWidth-Pause_SubMenu_Width, baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                try wmpvideo.fullScreen := false
                FullScreenView = 0
            } Else if (HSubMenuItem=1) {
                    If(Pause_Active=true)
                        gosub, DisableKeys 
                    XHotKeywrapper(exitEmulatorKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(pauseKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON") 
                    try wmpvideo.fullScreen := true
                    FullScreenView := 1 
            } Else {
                try CurrentVideoPlayStatus := wmpVideo.playState
                If(V2SubMenuItem=1)
                    If(CurrentVideoPlayStatus=3)                
                        try wmpVideo.controls.pause 
                    Else
                        try wmpVideo.controls.play 
                If(V2SubMenuItem=2) {               
                    If(Pause_Active=true)
                        gosub, DisableKeys 
                    XHotKeywrapper(exitEmulatorKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(pauseKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON") 
                    try wmpvideo.fullScreen := true
                    FullScreenView := 1 
                }
                If(V2SubMenuItem=3) {  
                    SaveActualStateHSubmenuitem := HSubmenuitem
                    SaveActualStateVSubmenuitem := VSubmenuitem
                    SaveActualStateV2Submenuitem := V2Submenuitem
                    FFRWtimeractualstate := (FFRWtimeractualstate=true)?false:true  
                    If FFRWtimeractualstate {
                        settimer, RewindTimer, 100, Period
                    } Else {
                        AcumulatedRewindFastForwardJumpSeconds = 0
                        settimer, RewindTimer, off
                    }
                }                    
                If(V2SubMenuItem=4) { 
                    SaveActualStateHSubmenuitem := HSubmenuitem
                    SaveActualStateVSubmenuitem := VSubmenuitem
                    SaveActualStateV2Submenuitem := V2Submenuitem
                    FFRWtimeractualstate := (FFRWtimeractualstate=true)?false:true  
                    If FFRWtimeractualstate {
                        settimer, FastForwardTimer, 100, Period
                    } Else {
                        AcumulatedRewindFastForwardJumpSeconds = 0
                        settimer, FastForwardTimer, off
                    }
                } 
                If(V2SubMenuItem=5) {               
                    try wmpVideo.controls.stop
                    VideoPosition%videoplayingindex% := 0
                }
            }
            gosub, DrawSubMenu
        }
    } 
    If(Pause_EnableMouseControl = "true") {
        If (FullScreenView = 1) {
            Gdip_GraphicsClear(Pause_G32)
            Gdip_Alt_DrawImage(Pause_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
            Alt_UpdateLayeredWindow(Pause_hwnd32, Pause_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,Pause_MouseControlTransparency,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)        
        } Else {
            Gdip_GraphicsClear(Pause_G32)
            Gdip_Alt_DrawImage(Pause_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
            Alt_UpdateLayeredWindow(Pause_hwnd32, Pause_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,Pause_MouseControlTransparency,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)        
        }
    }
Return

RewindTimer:
FastForwardTimer:
    If ((SaveActualStateHSubmenuitem = HSubmenuitem) and (SaveActualStateVSubmenuitem = VSubmenuitem) and (SaveActualStateV2Submenuitem = V2Submenuitem)) {
        AcumulatedRewindFastForwardJumpSeconds += Pause_SubMenu_VideoRewindFastForwardJumpSeconds
        If (AcumulatedRewindFastForwardJumpSeconds<60) {
            Secondstojump := 1
        } Else If (AcumulatedRewindFastForwardJumpSeconds<180) {
            Secondstojump := 2
        } Else If (AcumulatedRewindFastForwardJumpSeconds<360) {
            Secondstojump := 3
        } Else If (AcumulatedRewindFastForwardJumpSeconds<600) {
            Secondstojump := 4
        } Else {
            Secondstojump := Pause_SubMenu_VideoRewindFastForwardJumpSeconds
        }
        Secondstojump += 0
        try wmpVideo.Controls.CurrentPosition += (A_ThisLabel="RewindTimer"? -Secondstojump:Secondstojump)
        FFRWtimeractualstate := true
    } Else {
        FFRWtimeractualstate := false
        AcumulatedRewindFastForwardJumpSeconds = 0
        settimer, FastForwardTimer, off
        settimer, RewindTimer, off
    }
Return

TogglePauseMenuStatus:
    If !(Pause_Running){
        gosub, Pause_Main
    } Else {
        If(Pause_Active){
            If ((disableActivateBlackScreen) and (Pause_Disable_Menu="true")) or (ErrorExit) {
                gosub, SimplifiedExitPause
            } Else {
                gosub, ExitPause
            }
        }
    }
Return

ZoomIn:
    If((FullScreenView = 1) and !(CurrentFileExtension = "txt")){
        ZoomLevel := ZoomLevel+Pause_SubMenu_FullScreenZoomSteps
        gosub, DrawSubMenu
    }
Return

ZoomOut:
    If((FullScreenView = 1) and !(CurrentFileExtension = "txt")){
        If(ZoomLevel>100+Pause_SubMenu_FullScreenZoomSteps){
            ZoomLevel := ZoomLevel-Pause_SubMenu_FullScreenZoomSteps
        } Else {
            HorizontalPanFullScreen := 0
            VerticalPanFullScreen := 0
            ZoomLevel := 100
        }
        gosub, DrawSubMenu
    }
Return


;-----------------EXIT PAUSE------------
ExitPause:
    BroadcastMessage("RocketLauncher Message: Resuming Game.")
    if (FunctionRunning)
        Return
    if initialLockLaunch
     if !(initialLockLaunch=currentLockLaunch)
        IniWrite, %currentLockLaunch%, % A_ScriptDir . "\Settings\" . systemName . "\Game Options.ini", %dbName%, Lock_Launch
    if !(sevenZDelTemp=current7zDelTemp)
        IniWrite, %current7zDelTemp%, % A_ScriptDir . "\Settings\" . systemName . "\Game Options.ini", %dbName%, 7z_Delete_Temp
    RLLog.Info(A_ThisLabel . " - Closing Pause")
    gosub, DisableKeys
    RLLog.Debug(A_ThisLabel . " - Disabled Keys while exiting")
    Pause_Active:=false
    If not(Pause_MuteSound="true"){ 
        If (Pause_MuteWhenLoading="true"){ ;Mute when exiting Pause to avoiding sound stuttering
            getMute(PauseEmuInitialMuteState,emulatorVolumeObject)
            If !(PauseEmuInitialMuteState){
                setMute(1,emulatorVolumeObject)
                RLLog.Debug(A_ThisLabel . " - Muting emulator sound while Pause is loaded. Emulator mute status: " getMute(,emulatorVolumeObject) " (1 is mutted)")
            }
        }
    }    
    if (pauseOnPrimaryMonitor) {
        settimer, UpdateMusicPlayingInfo, off
        settimer, UpdateVideoPlayingInfo, off
    }
    try CurrentMusicPlayStatus := wmpMusic.playState
    If (Pause_KeepPlayingAfterExitingPause="false"){
        If (CurrentMusicPlayStatus=3){
            try wmpMusic.controls.pause
            RLLog.Debug(A_ThisLabel . " - Pausing music")
        }
    }
    If (SelectedMenuOption="Videos") {
        try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
        RLLog.Debug(A_ThisLabel . " - VideoPosition at Pause exit:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%) 
        try wmpVideo.controls.stop
        try wmpVideo.close
    }
    If !disableLoadScreen {
        Gdip_GraphicsClear(Pause_G21)
        If(Pause_MainMenu_GlobalBackground ="true"){
            Gdip_Alt_FillRectangle(Pause_G21, Pause_Load_Background_Brush, 0, 0, loadBaseScreenWidth+1, loadBaseScreenHeight+1,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight)
            Gdip_Alt_TextToGraphics(Pause_G21, Pause_AuxiliarScreen_ExitText, OptionsLoadPause, Pause_AuxiliarScreen_Font, 0, 0,,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight)
        }
        Alt_UpdateLayeredWindow(Pause_hwnd21, Pause_hdc21, 0, 0, loadBaseScreenWidth, loadBaseScreenHeight,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)          
    }
    if (pauseOnPrimaryMonitor) {
        RLLog.Debug(A_ThisLabel . " - Disabling timers")
        SetTimer, UpdateDescription, off
        SetTimer, SubMenuUpdate, off
        SetTimer, DiscChangeUpdate, off
        SetTimer, Clock, off
    }
    If romTable.MaxIndex() { ; Resetting romtable changes made by Pause If the game is a multiple dics game
        for index, element in romTable
            {
            current := A_Index
            Loop, 19 
                {
                If (A_Index > 6 && A_Index != 19)	; do not wipe column 19 which has 7zCleanup data

                    romTable[current, A_Index] := ""
            }
        }
    }
    if Pause_ChangeRes
        SetDisplaySettings(Pause_MonitorRestorObj)	; return monitor state to previous parameters
    If !disableLoadScreen
        If !disableActivateBlackScreen
            WinActivate, PauseBlackScreen
    if (pauseOnPrimaryMonitor) {
        Loop, 12
            {
            If not (A_Index=10) {
                CurrentGUI := A_Index+21
                SelectObject(Pause_hdc%CurrentGUI%, Pause_obm%CurrentGUI%)
                DeleteObject(Pause_hbm%CurrentGUI%)
                DeleteDC(Pause_hdc%CurrentGUI%)
                Gdip_DeleteGraphics(Pause_G%CurrentGUI%)
                Gui, Pause_GUI%CurrentGUI%: Destroy
            }
        }
        If(PauseMediaObj["Videos"].TotalLabels >0)
            Gui, Pause_GUI31: Destroy
        RLLog.Debug(A_ThisLabel . " - Guis destroyed")
        Gdip_DeleteBrush(BlackGradientBrush), Gdip_DeleteBrush(PBRUSH), Gdip_DeleteBrush(Pause_SubMenu_BackgroundBrushV), Gdip_DeleteBrush(Pause_SubMenu_SelectedBrushV), Gdip_DeleteBrush(Pause_SubMenu_DisabledBrushV), Gdip_DeleteBrush(Pause_BackgroundBrushV), Gdip_DeleteBrush(Pause_SubMenu_GuidesSelectedBrushV), Gdip_DeleteBrush(Pause_SubMenu_ManualsSelectedBrushV), Gdip_DeleteBrush(Pause_SubMenu_HistorySelectedBrushV), Gdip_DeleteBrush(Pause_SubMenu_ControllerSelectedBrushV), Gdip_DeleteBrush(Pause_SubMenu_ArtworkSelectedBrushV),Gdip_DeleteBrush(Pause_SubMenu_FullScreenTextBrushV), Gdip_DeleteBrush(Pause_SubMenu_FullScreenBrushV), Gdip_DeleteBrush(Pause_7zProgress_BackgroundBrush), Gdip_DeleteBrush(Pause_7zProgress_BarBackBrush), Gdip_DeleteBrush(Pause_7zProgress_BarBrush) 
        RLLog.Debug(A_ThisLabel . " - Brushes deleted")
        Gdip_DisposeImage(MainMenuBackgroundBitmap), Gdip_DisposeImage(LogoImageBitmap), Gdip_DisposeImage(PauseImageBitmap), Gdip_DisposeImage(SoundBitmap), Gdip_DisposeImage(MuteBitmap), Gdip_DisposeImage(ButtonToggleONBitmap), Gdip_DisposeImage(ButtonToggleOFFBitmap), Gdip_DisposeImage(CurrentBitmap), Gdip_DisposeImage(SelectedBitmap), Gdip_DisposeImage(pGameScreenshot), Gdip_DisposeImage(SaveStateBackgroundBitmap) 
        Loop, 5
            Gdip_DisposeImage(PauseMusicBitmap%A_Index%)
        Loop, 6 
            Gdip_DisposeImage(PauseVideoBitmap%A_Index%)
        Loop, %TotalCommandDatImageFiles% {
            Gdip_DisposeImage(CommandDatBitmap%A_index%)
        }
        If(Pause_EnableMouseControl = "true") {
            Gdip_DisposeImage(MouseFullScreenMaskBitmap), Gdip_DisposeImage(MouseFullScreenOverlayBitmap), Gdip_DisposeImage(MouseClickImageBitmap)
        }
        for index, element in romTable
            {
            Gdip_DisposeImage(romTable[A_Index, 17]), Gdip_DisposeImage(romTable[A_Index, 18])
        }
        RLLog.Debug(A_ThisLabel . " - Disposed images")
    }
    If !(rlMode = "pause") 
        {
        If (keymapperEnabled = "true") {
            If (KeymapperProfileChangeInPause = 1) {
                SplitPath, keymapperFullPath, keymapperExe, keymapperPath, keymapperExt
                If (keymapper = "xpadder") {
                    Loop, 16
                    {
                        ControllerName := joystickArray[A_Index,1]
                        If ControllerName {
                            If !ProfilesInIdOrder
                                ProfilesInIdOrder := selectedProfile[A_Index,2]
                            Else
                                ProfilesInIdOrder .= "|" . selectedProfile[A_Index,2]
                        }
                    }
                    RunXpadder%zz%(keymapperPath,keymapperExe,ProfilesInIdOrder,joystickArray)
                    ProfilesInIdOrder := "" 		;clear so this variable doesn't grow by duplication on 2nd or more closings of Pause
                } Else If (keymapper="joy2key") OR (keymapper = "joytokey") {
                    RunJoyToKey%zz%(keymapperPath,keymapperExe,selectedProfile[1,2])
                    }
            } Else If (keymapperRocketLauncherProfileEnabled = "true") {
                RunKeymapper%zz%("load",keymapper)
            }
            If !disableLoadScreen
                If !disableActivateBlackScreen
                    WinActivate, PauseBlackScreen
        }
        If (keymapperAHKMethod = "External")
            RunAHKKeymapper%zz%("load")
    }
	If !disableSuspendEmu  ;Unsuspending Emulator Process 
        {
        ProcRes(emulatorProcessName)
        RLLog.Debug(A_ThisLabel . " - Emulator process started")
    }
    If !disableRestoreEmu  ;Restoring emulator
        {
        timeout := A_TickCount
        sleep, 200
        WinRestore, ahk_ID %emulatorID%
        IfWinNotActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
            {
            Loop{
                sleep, 200
                WinRestore, ahk_ID %emulatorID%
                sleep, 200
                WinActivate, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                IfWinActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                    {
                    break
                    }
            If(timeout<A_TickCount-3000)
                    break
            sleep, 200
            }
            RLLog.Debug(A_ThisLabel . " - Emulator screen reactivated")
        }
    }
    gosub, RestoreEmu
    RLLog.Debug(A_ThisLabel . " - Loaded emulator specific module restore commands")
    Pause_EndTime := A_TickCount
	LEDBlinky("ROM")	; trigger ledblinky profile change if enabled
	KeymapperProfileSelect("RESUME", keyboardEncoder, winIPACFullPath, "ipc", "keyboard")
	KeymapperProfileSelect("RESUME", "UltraMap", ultraMapFullPath, "ugc")
    RLLog.Debug(A_ThisLabel . " - Setting Pause starting end for subtracting from statistics played time: " Pause_EndTime)
    TotalElapsedTimeinPause :=  If TotalElapsedTimeinPause ? TotalElapsedTimeinPause + (Pause_EndTime-Pause_BeginTime)//1000 : (Pause_EndTime-Pause_BeginTime)//1000
    If !disableLoadScreen {
        If ( !((ItemSelected=1) and (SelectedMenuOption="ChangeDisc")) or ((ItemSelected=1) and (SelectedMenuOption="ChangeDisc") and !(forceMGGuiDestroy)) ) {
            SelectObject(Pause_hdc21, Pause_obm21)
            DeleteObject(Pause_hbm21)
            DeleteDC(Pause_hdc21)
            Gdip_DeleteGraphics(Pause_G21)
            Gui, Pause_GUI21: Destroy  
        }
    }
    RLLog.Debug(A_ThisLabel . " - Black Screen Gui destroyed")
    If !(rlMode = "pause") {
		CustomFunction.PostPauseStop() ; stoping pause user functions here so they are triggered right before Pause closes
        XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
        XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","ON")
        If mgEnabled = true
            XHotKeywrapper(mgKey,"StartMulti","ON")
        If (bezelEnabled = true) and (bezelPath = true)
        {	Gosub, EnableBezelKeys%zz%	; turning on the bezel keys
            if %ICRandomSlideShowTimer%
                SetTimer, randomICChange%zz%, %ICRandomSlideShowTimer%
            if ICRightMenuDraw 
                Gosub, EnableICRightMenuKeys%zz%
            if ICLeftMenuDraw
                Gosub, EnableICLeftMenuKeys%zz%
            if (bezelBackgroundsList.MaxIndex() > 1)
                if bezelBackgroundChangeDur
                    settimer, BezelBackgroundTimer%zz%, %bezelBackgroundChangeDur%
            ;reloading the top most bezel layers
            Loop, 8 { 
                index := a_index + 2
                Gui, Bezel_GUI%index%: Show
            }
            WinActivate, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
        }
        RLLog.Debug(A_ThisLabel . " - Enabled exit emulator, bezel, and multigame keys")
        Gosub, SendCommandstoEmulator
        if filesToBeDeleted
            {
            remainingFilesToBeDeleted := ""
            StringTrimRight, filesToBeDeleted, filesToBeDeleted, 1 
            Loop, parse, filesToBeDeleted,|, 
                {
                if FileExist(A_LoopField)
                    {
                    FileDelete, % A_LoopField
                    if ErrorLevel
                        remainingFilesToBeDeleted .= A_LoopField . "|"
                }
            }
            filesToBeDeleted := remainingFilesToBeDeleted
        }
    }
    If !disableLoadScreen {
        If ((ItemSelected=1) and (SelectedMenuOption="ChangeDisc") and (forceMGGuiDestroy)) {
            SelectObject(Pause_hdc21, Pause_obm21)
            DeleteObject(Pause_hbm21)
            DeleteDC(Pause_hdc21)
            Gdip_DeleteGraphics(Pause_G21)
            Gui, Pause_GUI21: Destroy  
        }
    }
    If close_emulator {
        RLLog.Info(A_ThisLabel . " - Exiting Emulator From Pause")
        gosub, CloseProcess
        WinWaitClose, ahk_id  %emulatorID%
    }
    If((Pause_MuteWhenLoading="true") or (Pause_MuteSound="true")){
        If !(PauseEmuInitialMuteState){
            getMute(CurrentMuteState,emulatorVolumeObject)
            If(CurrentMuteState=1){
                setMute(0,emulatorVolumeObject)
                RLLog.Debug(A_ThisLabel . " - Unmuting emulator sound while Pause is loaded. Emulator mute status: " getMute(,emulatorVolumeObject) " (0 is unmutted)")
            }
        }
    }
    If (emuIdleShutdown and emuIdleShutdown != "ERROR")	; turn on emuIdleShutdown while in Pause
		SetTimer, EmuIdleCheck%zz%, On
    setVolume(Pause_VolumeMaster) ; making sure that changes on sound menu are updated   
    RLLog.Info(A_ThisLabel . " - Pause Closed")
    Pause_Running := false
Return


SimplifiedExitPause:
    If !disableSuspendEmu    
        {
        ProcRes(emulatorProcessName)
        RLLog.Debug(A_ThisLabel . " - Emulator process started")
        timeout := A_TickCount
        sleep, 200
        WinRestore, ahk_ID %emulatorID%
        IfWinNotActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
            {
            Loop{
                sleep, 200
                WinRestore, ahk_ID %emulatorID%
                sleep, 200
                WinActivate, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                IfWinActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                    {
                    break
                    }
            If(timeout<A_TickCount-3000)
                    break
            sleep, 200
            }
            RLLog.Debug(A_ThisLabel . " - Emulator screen reactivated")
        }
    }
    gosub, RestoreEmu
    If((Pause_MuteWhenLoading="true") or (Pause_MuteSound="true")){ ;Unmute If initial state is unmuted
        If !(PauseEmuInitialMuteState){
            getMute(CurrentMuteState,emulatorVolumeObject)
            If(CurrentMuteState=1){
                setMute(0,emulatorVolumeObject)
                RLLog.Debug(A_ThisLabel . " - Unmuting emulator sound while Pause is loaded. Emulator mute status: " getMute(,emulatorVolumeObject) " (0 is unmutted)")
            }
        }  
    }    
    If !disableLoadScreen {
        SelectObject(Pause_hdc21, Pause_obm21)
        DeleteObject(Pause_hbm21)
        DeleteDC(Pause_hdc21)
        Gdip_DeleteGraphics(Pause_G21)
        Gui, Pause_GUI21: Destroy  
    }
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
    XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","ON")
    If (mgEnabled = "true")
        XHotKeywrapper(mgKey,"StartMulti","ON")
	If (bezelEnabled = "true")
	{	Gosub, EnableBezelKeys%zz%	; turning on the bezel keys
        if %ICRandomSlideShowTimer%
			SetTimer, randomICChange%zz%, %ICRandomSlideShowTimer%
        if ICRightMenuDraw 
            Gosub, EnableICRightMenuKeys%zz%
        if ICLeftMenuDraw
            Gosub, EnableICLeftMenuKeys%zz%
        if (bezelBackgroundsList.MaxIndex() > 1)
            if bezelBackgroundChangeDur
                settimer, BezelBackgroundTimer%zz%, %bezelBackgroundChangeDur%
	}
	RLLog.Debug(A_ThisLabel . " - Enabled exit emulator, bezel, and multigame keys")
    Pause_Active:=false
    Pause_Running:=false
Return

SendCommandstoEmulator:
    If (ItemSelected = 1){
        If((SelectedMenuOption="SaveState")or(SelectedMenuOption="LoadState")){ 
            If(A_KeyDelay<Pause_SetKeyDelay) 
                SetKeyDelay(Pause_SetKeyDelay)
            currentLabel := SelectedMenuOption . "Slot" . VSubMenuItem
            if IsLabel(currentLabel) 
                {
                Gosub %currentLabel%
                If(SelectedMenuOption="SaveState") {
                    SaveTime := "This game was saved in " A_DDDD ", " A_MMMM " " A_DD ", " A_YYYY ", at " A_Hour ":" A_Min ":" A_Sec  
                    RIni_SetKeyValue("Stat_Sys",dbName, SelectedMenuOption . VSubMenuItem . "SaveTime",SaveTime) ; makes sure that save state info is saved on statistics update   
                    IniWrite, %SaveTime%, %Pause_GameStatistics%\%systemName%.ini, %dbName%, %SelectedMenuOption%%VSubMenuItem%SaveTime ; saves save state info between Pause menu calls
                } 
            } else {
                Loop, parse, pause%SelectedMenuOption%KeyCodes,|, 
                {
                    If(VSubMenuItem=A_Index){
                        If(SelectedMenuOption="SaveState") {
                            SaveTime := "This game was saved in " A_DDDD ", " A_MMMM " " A_DD ", " A_YYYY ", at " A_Hour ":" A_Min ":" A_Sec  
                            RIni_SetKeyValue("Stat_Sys",dbName, SelectedMenuOption . VSubMenuItem . "SaveTime",SaveTime) ; makes sure that save state info is saved on statistics update   
                            IniWrite, %SaveTime%, %Pause_GameStatistics%\%systemName%.ini, %dbName%, %SelectedMenuOption%%VSubMenuItem%SaveTime ; saves save state info between Pause menu calls
                        }         
                        KeySelected:=A_LoopField
                        break
                    }
                }
                sleep, %Pause_DelaytoSendKeys%
                Loop, parse, KeySelected,;, 
                {
                    If InStr(A_LoopField,"Sleep"){
                        StringReplace, SleepPeriod, A_LoopField, Sleep, , all
                        Sleep, %SleepPeriod%
                    } Else {
                        Send, , %A_LoopField%
                    }
                }
                RLLog.Info(SelectedMenuOption " KeySelected " KeySelected " sent to the emulator")
            }
            If(SelectedMenuOption="SaveState") and (Pause_SaveStateScreenshot = "true") {
                gosub, SaveScreenshot  
                filesToBeDeleted .=  Pause_SaveScreenshotPath . "\" . SaveStateBackgroundFile . "|"
                RIni_SetKeyValue("Stat_Sys",dbName, "SaveState" . VSubMenuItem . "Screenshot",CurrentScreenshotFileName) ; makes sure that save state info is saved on statistics update   
                IniWrite, %CurrentScreenshotFileName%, %Pause_GameStatistics%\%systemName%.ini, %dbName%, SaveState%VSubMenuItem%Screenshot ; saves save state info between Pause menu calls
            }
            SetKeyDelay(SavedKeyDelay)
        }
        If(SelectedMenuOption="ChangeDisc"){
            If statisticsEnabled = true
                gosub, UpdateStatistics
            gameSectionStartTime := A_TickCount
            gameSectionStartHour := A_Now
            RLLog.Debug(A_ThisLabel . " - PauseExit - Processing MultiGame label in module.")
            gosub, MultiGame%zz%
            RLLog.Debug(A_ThisLabel . " - PauseExit - Finished Processing MultiGame label.")
        }
    }
Return


;--- Change Disc Labels

Pause_UpdateFor7z:
	Gosub, Pause_ProgressBarAnimation	; Calling Pause progress bar animation
Return

Pause_ProgressBarAnimation:
	; start the progress bar animation Loop
	RLLog.Info(A_ThisLabel . " - Pause_ProgressBarAnimation - Started")
    Pause_7zProgress_BarX := (baseScreenWidth - Pause_7zProgress_BarW)//2 - Pause_7zProgress_BarBackgroundMargin 
    Pause_7zProgress_BarY := 3*(baseScreenHeight)//4 - (Pause_7zProgress_BarH+Pause_7zProgress_BarBackgroundMargin)//2
    Text1Option := Pause_7zProgress_BarText1Options . " s" . Pause_7zProgress_BarText1FontSize
    Text2Option := Pause_7zProgress_BarText2Options . " s" . Pause_7zProgress_BarText2FontSize
    currentFloat := A_FormatFloat 
	SetFormat, Float, 3.2	; required otherwise calculations below falsely trigger
	Pause_7zProgress_FinishedBar := 0
    pGraphUpd(Pause_G25,Pause_7zProgress_BarW+2*Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarH+2*Pause_7zProgress_BarBackgroundMargin)
    Loop {
		Gdip_GraphicsClear(Pause_G25)
		; Updating 7z extraction info
		romExPercentageAndFile := RLObject.getExtractionSize(sevenZRomPath, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Progress (Accurate Method))
		Loop, Parse, romExPercentageAndFile, |	; StringSplit oddly doesn't work for some unknown reason, must resort to a parsing Loop instead
			If A_Index = 1
			{
				romExCurSize := A_LoopField									; Store bytes extracted
				percentage := (A_LoopField / romExSize) * 100	; Calculate percentage extracted
			} Else If A_Index = 2
				romExFile := A_LoopField
		; Drawing progress Bar
		
		; Drawing Bar Background
		Pause_7zProgress_BackgroundBrush := Gdip_BrushCreateSolid("0x" . Pause_7zProgress_BarBackgroundColor)
		Pause_7zProgress_BarBackBrush := Gdip_BrushCreateSolid("0x" . Pause_7zProgress_BarBackColor)
		Pause_7zProgress_BarBrush := Gdip_BrushCreateHatch(0x00000000, "0x" . Pause_7zProgress_BarColor, Pause_7zProgress_BarHatchStyle) 
		Gdip_Alt_FillRoundedRectangle(Pause_G25, Pause_7zProgress_BackgroundBrush, 0, 0, Pause_7zProgress_BarW+2*Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarH+2*Pause_7zProgress_BarBackgroundMargin,Pause_7zProgress_BarBackgroundRadius)
		Gdip_Alt_FillRoundedRectangle(Pause_G25, Pause_7zProgress_BarBackBrush, Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarW, Pause_7zProgress_BarH, Pause_7zProgress_BarR)
		; Drawing Progress Bar
		If percentage > 100
			percentage := 100
		If(Pause_7zProgress_BarW*percentage/100<3*Pause_7zProgress_BarR)	; avoiding glitch in rounded rectangle drawing when they are too small
			currentRBar := Pause_7zProgress_BarR * ((Pause_7zProgress_BarW*percentage/100)/(3*Pause_7zProgress_BarR))
		Else
			currentRBar := Pause_7zProgress_BarR
		Gdip_Alt_TextToGraphics(Pause_G25, round(percentage) . "%", "x" round(Pause_7zProgress_BarBackgroundMargin+Pause_7zProgress_BarW*percentage/100) " y" (Pause_7zProgress_BarBackgroundMargin-Pause_7zProgress_Text_Offset)//2 . " " . Text1Option, Pause_7zProgress_Font, 0, 0)
		If percentage < 100
			If (fadeBarInfoText = "true")
				Gdip_Alt_TextToGraphics(Pause_G25, Pause_7zProgress_BarText1, "x" Pause_7zProgress_BarBackgroundMargin+Pause_7zProgress_BarW " y" Pause_7zProgress_BarBackgroundMargin+Pause_7zProgress_BarH+(Pause_7zProgress_BarBackgroundMargin-Pause_7zProgress_Text_Offset)//2 . " " . Text1Option, Pause_7zProgress_Font, 0, 0)
		Else {	; bar is at 100%
			Pause_7zProgress_FinishedBar:= 1
			RLLog.Debug(A_ThisLabel . " - Pause_ProgressBarAnimation - Bar reached 100%")
			If (fadeBarInfoText = "true")
				Gdip_Alt_TextToGraphics(Pause_G25, Pause_7zProgress_BarText2, "x" Pause_7zProgress_BarBackgroundMargin+Pause_7zProgress_BarW " y" Pause_7zProgress_BarBackgroundMargin+Pause_7zProgress_BarH+(Pause_7zProgress_BarBackgroundMargin-Pause_7zProgress_Text_Offset)//2 . " " . Text2Option, Pause_7zProgress_Font, 0, 0)
		}
		Gdip_Alt_FillRoundedRectangle(Pause_G25, Pause_7zProgress_BarBrush, Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarW*percentage/100, Pause_7zProgress_BarH,currentRBar)
		Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,Pause_7zProgress_BarX,Pause_7zProgress_BarY, Pause_7zProgress_BarW+2*Pause_7zProgress_BarBackgroundMargin, Pause_7zProgress_BarH+2*Pause_7zProgress_BarBackgroundMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
		Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
		If !ErrorLevel ; bar is at 100% or 7z is already closed or user interrupted fade, so break out
		{	RLLog.Debug(A_ThisLabel . " - Pause_ProgressBarAnimation - 7z.exe is no longer running, breaking out of progress loop.")
			Break
		}
		If Pause_7zProgress_FinishedBar
			Break
	}
	SetFormat, Float, %currentFloat%	; restore previous float
	RLLog.Info(A_ThisLabel . " - Pause_ProgressBarAnimation - Ended")
Return

;-----------------SUB MENU LIST AND DRAWING FUNCTIONS------------

LoadMediaAssetsFiles(path, fileExtensions, assetType, SubMenuName, ByRef MediaList){
    Global sevenZFormatsNoP, Supported_Images, RLMediaPath, sevenZPath, Pause_LoadPDFandCompressedFilesatStart, systemName
    if FileExist(path) {
        Loop, % path . "\*", 1 
        {
            if InStr(A_LoopFileAttrib, "D") { ; it is a folder
                folderName := A_LoopFileName
                Loop % A_LoopFileLongPath . "\*.*"
                {   
                    If A_LoopFileExt in %Supported_Images%
                    {
                        currentobj := {}
                        currentobj["Label"] := folderName
                        if MediaList[folderName].Label
                        {   currentobj := MediaList[folderName]
                            currentobj.TotalItems := currentobj.TotalItems+1
                        } else {
                            currentobj.TotalItems := 1
                        }
                        currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
                        currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
                        currentobj["AssetType"] := assetType
                        if (currentobj.TotalItems>1)
                            currentobj["Type"] := "ImageGroup"
                        MediaList.Insert(currentobj["Label"], currentobj)
                    }
                }
            } else if InStr(A_LoopFileAttrib, "A") { ; it is a file
                If A_LoopFileExt in %sevenZFormatsNoP%,cbr,cbz
                {
                    If FileExist(sevenZPath)
                    {
                        CurrentExtension := A_LoopFileExt
                        CurrentFile :=  A_LoopFileFullPath
                        CurrentFileName := A_LoopFileName
                        TempCompressedListofFiles := StdoutToVar_CreateProcess(sevenZPath . " l """ . CurrentFile . """")
                        Loop, parse, Supported_Images,`,,
                        {
                            If TempCompressedListofFiles contains %A_LoopField%
                            {
                                SplitPath, CurrentFile, ,,,FileNameWithoutExtension
                                currentobj := {}
                                currentobj["Label"] := FileNameWithoutExtension
                                if MediaList[FileNameWithoutExtension].Label
                                {   currentobj := MediaList[FileNameWithoutExtension]
                                    currentobj.TotalItems := currentobj.TotalItems+1
                                } else {
                                    currentobj.TotalItems := 1
                                }
                                currentobj["Path" . currentobj.TotalItems] := CurrentFile
                                currentobj["Ext" . currentobj.TotalItems] := CurrentExtension
                                currentobj["AssetType"] := assetType
                                MediaList.Insert(currentobj["Label"], currentobj)  
                                If(Pause_LoadPDFandCompressedFilesatStart = "true"){
                                    Pause_7zExtractDir := RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . FileNameWithoutExtension
                                    RunWait, %sevenZPath% e "%CurrentFile%" -aoa -o"%Pause_7zExtractDir%",,Hide ; perform the extraction and overwrite all
                                    currentobj := MediaList[FileNameWithoutExtension]
                                    Loop, % RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . FileNameWithoutExtension . "\*.*"
                                        {
                                        currentobj["Path" . a_index] := A_LoopFileLongPath
                                        currentobj["Ext" . a_index] := A_LoopFileExt
                                        currentobj["AssetType"] := assetType
                                        currentobj["TotalItems"] := a_index
                                    }
                                    if (currentobj.TotalItems>1)
                                        currentobj["Type"] := "ImageGroup"
                                    MediaList.Insert(currentobj["Label"], currentobj)                                      
                                }
                            }
                        }
                    }
                } Else if A_LoopFileExt in %fileExtensions% 
                    {
                    SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                    currentobj := {}
                    currentobj["Label"] := FileNameWithoutExtension
                    if MediaList[FileNameWithoutExtension].Label
                    {   currentobj := MediaList[FileNameWithoutExtension]
                        currentobj.TotalItems := currentobj.TotalItems+1
                    } else {
                        currentobj.TotalItems := 1
                    }
                    currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
                    currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
                    currentobj["AssetType"] := assetType
                    if  (A_LoopFileExt = "txt"){
                        FileRead, txtContents, % A_LoopFileFullPath
                        currentobj["txtContents"] := txtContents
                    }
                    MediaList.Insert(currentobj["Label"], currentobj)  
                }
            }
        }            
    }
Return 
}

CreateSubMenuMediaObject(SubMenuName){
    Global systemName, dbName, RLMediaPath, Supported_Images, Supported_Extensions, DescriptionNameWithoutDisc, Totaldiscsofcurrentgame, ListofSupportedVideos, gameInfo, Pause_UseParentGameMediaAssets
    RLMediaList := {}
    if (SubMenuName="Videos")
        currentExtensions := ListofSupportedVideos
    else
        currentExtensions := Supported_Extensions
    ; Loop RocketLauncher\Media\Sony Playstation\Final Fantasy VII (USA) (Disc x)\ 
    LoadMediaAssetsFiles(RLMediaPath . "\" . SubMenuName . "\" . systemName . "\" . dbName, currentExtensions, "game", SubMenuName, RLMediaList)
    ; Loop RocketLauncher\Media\Sony Playstation\Final Fantasy VII (USA)\ 
    If (Totaldiscsofcurrentgame>1)
        LoadMediaAssetsFiles(RLMediaPath . "\" . SubMenuName . "\"  . systemName . "\" . DescriptionNameWithoutDisc, currentExtensions, "game", SubMenuName, RLMediaList)
    ; Parent game Assets 
    if (Pause_UseParentGameMediaAssets="true")
        if (gameInfo["CloneOf"].Value)
            LoadMediaAssetsFiles(RLMediaPath . "\" . SubMenuName . "\"  . systemName . "\" . gameInfo["CloneOf"].Value, currentExtensions, "game", SubMenuName, RLMediaList)
    ; Loop RocketLauncher\Media\Sony Playstation\_Default\ 
    LoadMediaAssetsFiles(RLMediaPath . "\" . SubMenuName . "\"  . systemName . "\_Default", currentExtensions, "system", SubMenuName, RLMediaList)
    ; Loop RocketLauncher\Media\_Default\ 
    LoadMediaAssetsFiles(RLMediaPath . "\" . SubMenuName . "\"  . "_Default", currentExtensions, "system", SubMenuName, RLMediaList)
    Return RLMediaList    
}

PostProcessingMediaObject(feMedia, ByRef PauseMediaObj){
    Global Pause_MainMenu_Itens, keymapperEnabled, systemName
    Global Pause_Artwork_VMargin, Pause_Controller_VMargin, Pause_Guides_VMargin, Pause_Manuals_VMargin, Pause_Videos_VMargin, logLevel
    Global Pause_SubMenu_Height, Pause_SubMenu_SmallFontSize, baseScreenHeight, Pause_SubMenu_FullScreenMargin, Pause_SubMenu_LabelFontSize, Pause_SubMenu_LabelFont, Pause_SubMenu_AdditionalTextMarginContour, Pause_SubMenu_MinimumTextBoxWidth, Pause_SubMenu_Font
    Global RLObject, Pause_SubMenu_PdfDpiResolution, Pause_LoadPDFandCompressedFilesatStart, RLMediaPath, pdfMaxHeight, Pause_PDF_Page_Layout
    ; Load FrontEnd Assets
    for SubMenuLabel, element2 in feMedia
    {   for index, element in element2
        {   if (element.Label)
            {   currentobj := feMedia[SubMenuLabel][element.Label]
				if (PauseMediaObj[SubMenuLabel][element.Label].Label)
                {   currentobj.Insert(currentobj["Label"], PauseMediaObj[SubMenuLabel][element.Label]) 
                    currentobj.TotalItems := currentobj.TotalItems+1
                }
                PauseMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj) 
            }
        }
    }  
    ; PostProcesing variables
    objAux := [] ;auxiliar array
    TotalLabels := []
    for SubMenuLabel, element2 in PauseMediaObj
        {        
        VMargin := % Pause_%SubMenuLabel%_VMargin
        PauseMediaObj[SubMenuLabel].maxLabelSize := Pause_SubMenu_MinimumTextBoxWidth
        PauseMediaObj[SubMenuLabel].txtLines := round((Pause_SubMenu_Height-2*VMargin-2*Pause_SubMenu_SmallFontSize)/(Pause_SubMenu_SmallFontSize)) ;Number of Lines per page
        PauseMediaObj[SubMenuLabel].txtFSLines := round((baseScreenHeight - 4*Pause_SubMenu_FullScreenMargin-2*Pause_SubMenu_SmallFontSize)/(Pause_SubMenu_SmallFontSize)) ;Number of lines in Full Screen 
        mediaAssetsLog := ""
        count := 0
        for index, element in element2
        {   ; total labels in sub menu
            if element.Label
            {   ;total elements
                if SubMenuLabel in Artwork,Controller,Guides,Manuals,Videos,History
                    {
                    count++
                    TotalLabels[SubMenuLabel] := count
                    objAux[SubMenuLabel,count] := PauseMediaObj[SubMenuLabel][element.Label].Label
                }
                ;maxlabelsize
                FontListWidth := MeasureText(element.Label, "Left r4 s" . Pause_SubMenu_LabelFontSize . " bold",Pause_SubMenu_LabelFont)+Pause_SubMenu_AdditionalTextMarginContour
                If(FontListWidth>PauseMediaObj[SubMenuLabel].maxLabelSize)
                    PauseMediaObj[SubMenuLabel].maxLabelSize := FontListWidth
                ; txt files post processing
                if (element.Ext1 = "txt") {
                    currentobj := PauseMediaObj[SubMenuLabel][element.Label]
                    ;Counting total number of pages in txt files
                    currentobj["txtWidth"] := MeasureText(currentobj.txtContents, "Left r4 s" . Pause_SubMenu_SmallFontSize . " Regular",Pause_SubMenu_Font)
                    count1 := 1
                    count2 := 1
                    txtContents := currentobj.txtContents
                    Loop, parse, txtContents, `n, `r  
                        {
                        FirstLine := (count1-1)* PauseMediaObj[SubMenuLabel].txtLines
                        LastLine := FirstLine + PauseMediaObj[SubMenuLabel].txtLines
                        FullScreenFirstLine := % (count2-1) * PauseMediaObj[SubMenuLabel].txtFSLines
                        FullScreenLastLine := % FullScreenFirstLine + PauseMediaObj[SubMenuLabel].txtFSLines
                        currentobj["Page" . count1] := currentobj["Page" . count1] . A_LoopField . "`r`n" 
                        If(A_index >= FirstLine){
                            If(A_index > LastLine){
                                count1++
                            }
                        }
                        currentobj["FSPage" . count2] := currentobj["FSPage" . count2] . A_LoopField . "`r`n" 
                        If(A_index >= FullScreenFirstLine){
                            If(A_index > FullScreenLastLine){
                                count2++
                            }
                        }
                    }          
                    currentobj["TotalV2SubMenuItems"] := count1
                    currentobj["TotalFSV2SubMenuItems"] := count2 
                    PauseMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj) 
                } else if (element.Ext1 = "pdf"){
                    currentobj := PauseMediaObj[SubMenuLabel][element.Label]
                    If(Pause_LoadPDFandCompressedFilesatStart = "true"){ ; loading pdfs at startup
                        IfNotExist, % RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label
                            FileCreateDir, % RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label
                        RLObject.generatePngFromPdf(element.Path1, RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label, Pause_SubMenu_PdfDpiResolution,pdfMaxHeight,1,0,Pause_PDF_Page_Layout)
                        if !(FileExist(RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label)){
                            RLLog.Warning("RocketLauncher does not have the correct permission to create the temporary pdf extraction folder on the bellow location and because of that pdf files will not appear on the pause menu.`r`n`t`t`t`t`t " . RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label)
                        } else if !(FileExist(RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label . "\*.png")){
                            RLLog.Warning("RocketLauncher does not have the correct permission to write files to the bellow location and because of that pdf files will not appear on the pause menu.`r`n`t`t`t`t`t " . RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label)
                        }
                        currentobj := PauseMediaObj[SubMenuLabel][element.Label]
                        Loop, % RLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label . "\*.*"
                            {
                            currentobj["Path" . a_index] := A_LoopFileLongPath
                            currentobj["Ext" . a_index] := A_LoopFileExt
                            currentobj["TotalItems"] := a_index
                        }
                        if (currentobj.TotalItems>1)
                            currentobj["Type"] := "ImageGroup"
                    } else 
                        currentobj["TotalItems"] := RLObject.getPdfPageCount(element.Path1,Pause_PDF_Page_Layout)
                    PauseMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj) 
                }
                if (logLevel>=5){
                    loop, % (PauseMediaObj[SubMenuLabel][element.Label].TotalItems)
                        mediaAssetsLog := % mediaAssetsLog . "`r`n`t`t`t`t`tAsset Label: " . element.Label . " | Asset Path" . a_index . ":  " . element["Path" . a_index] . " | Asset Extension" . a_index . ":  " . element["Ext" . a_index]
                }
            }
        }
        ; Removing empty menus
        if !(TotalLabels[SubMenuLabel])
            if !(((SubMenuLabel="Controller") and (keymapperEnabled = "true")) or (SubMenuLabel="HighScore"))
                StringReplace, Pause_MainMenu_Itens, Pause_MainMenu_Itens, %SubMenuLabel%|,
        if mediaAssetsLog
            RLLog.Debug(A_ThisLabel . " - Media assets found on submenu: " . SubMenuLabel . mediaAssetsLog)
    }
    ; Correspondence between label index and label name 
    for SubMenuLabel, element2 in objAux
    {   for index, element in element2
        {   PauseMediaObj[SubMenuLabel][index] := objAux[SubMenuLabel][index]
        }
        PauseMediaObj[SubMenuLabel].TotalLabels := TotalLabels[SubMenuLabel]
    }
    ; Moving Screenshot Label to the end of the artwork assets list
    count := 0
    if PauseMediaObj["Artwork"].Screenshots.Label
    {
        loop, % PauseMediaObj["Artwork"].TotalLabels
        {
            if (PauseMediaObj["Artwork"][a_index]="Screenshots")
                keyScreenshotsFound := true
            if keyScreenshotsFound
                PauseMediaObj["Artwork"][a_index] := PauseMediaObj["Artwork"][a_index+1]
        }
        PauseMediaObj["Artwork"][PauseMediaObj["Artwork"].TotalLabels] := "Screenshots"
    }
Return
}

loadHistoryDataInfo(){
	Global Pause_HistoryDatPath, systemName, dbName, gameInfo 
    RLMediaList := {}   
    IniRead, historyDatSystemName, %Pause_HistoryDatPath%\System Names.ini, Settings, %systemName%, %A_Space%
    IniRead, romNameToSearch, %Pause_HistoryDatPath%\%systemName%.ini, %dbName%, Alternate_Rom_Name, %A_Space%
    if !romNameToSearch
        romNameToSearch := dbName
    FileRead, historyContents, %Pause_HistoryDatPath%\History.dat
    FoundPos := RegExMatch(historyContents, "i)" . "\$\s*" . historyDatSystemName . "\s*=\s*.*\b" . romNameToSearch . "\b\s*,")
    If !FoundPos {
        If (gameInfo["CloneOf"].Label)
            FoundPos := RegExMatch(historyContents, "i)" . "\$\s*" . historyDatSystemName . "\s*=\s*.*\b" . gameInfo["CloneOf"].Value . "\b\s*,")
    }
    If FoundPos
        {
        FoundPos2 := RegExMatch(historyContents, "i)\$end",EndString,FoundPos)
        StringMid, HistoryDataText, historyContents, % FoundPos, % FoundPos2-FoundPos
        historySectionNumber := 1
        Loop, parse, HistoryDataText, `n, `r  
            {
            if historyDatSectionName%historySectionNumber% := historyDatSection(A_LoopField)
                {
                currentHistorySectionNumber := historySectionNumber
                historySectionNumber++
            } else if (historySectionNumber>1) {
                HistoryFileTxtContents%currentHistorySectionNumber% := % HistoryFileTxtContents%currentHistorySectionNumber% . "`n`r" . A_LoopField
            }
        }
        count := 0
        loop, % currentHistorySectionNumber
            {
            if ((!(InStr(historyDatSectionName%A_Index%, "SOURCES"))) and (historyDatSectionName%A_Index%)) {
                count++
                currentobj := {}
                currentobj["Label"] := historyDatSectionName%A_Index%
                currentobj["txtContents"] := RegExReplace(HistoryFileTxtContents%count%,"^\s+|\s+$")
                currentobj["Ext1"] := "txt"
                RLMediaList.Insert(currentobj["Label"], currentobj)  
            }
        }
    }
    Return RLMediaList
}

historyDatSection(line){
	line := RegExReplace(line,"^\s+|\s+$")  ; remove leading and trailing
	if InStr(line, "$bio")
		Return "DESCRIPTION"
	if !( InStr(line, "-") = 1 )
		Return 0
	if !( InStr(line, "-",false,0) = StrLen(line) )
		Return 0
	StringTrimLeft, line, line, 1
	StringTrimRight, line, line, 1
	line:=RegExReplace(line,"^\s+|\s+$")  ; remove leading and trailing
	sectionName := line
	StringReplace, line, line, %A_SPACE%, , All
	If line is upper
		Return %sectionName%
	else
		Return 0
Return
}
     

      
TextImagesAndPDFMenu(SubMenuName)
{   Global
    FunctionRunning := true ;error check function running (necessary to avoid exiting Pause in the middle of function running)
    CurrentLabelNumber := VSubMenuItem ;initializing variables
    If(VSubMenuItem < 1){
        CurrentLabelNumber := 1
    }
    CurrentLabelName := PauseMediaObj[SubMenuName][CurrentLabelNumber]
    CurrentFilePath := PauseMediaObj[SubMenuName][CurrentLabelName].Path1
    CurrentFileExtension := PauseMediaObj[SubMenuName][CurrentLabelName].Ext1
    If not((SelectedMenuOption="Videos") or (VSubMenuItem=-1)){
        HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        V2Submenuitem := % HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem%
    }
    HMargin := % Pause_%SubMenuName%_HMargin
    HdistBetwLabelsandPages := % Pause_%SubMenuName%_HdistBetwLabelsandPages
    VMargin := % Pause_%SubMenuName%_VMargin
    VdistBetwLabels := Pause_%SubMenuName%_VdistBetwLabels
    TempPath := % Pause_%SubMenuName%TempPath
    PageNumberFontColor := % Pause_%SubMenuName%_PageNumberFontColor
    HdistBetwPages := % Pause_%SubMenuName%_HdistBetwPages
    color := Pause_MainMenu_LabelDisabledColor ;drawing Label List
    Optionbrush := Pause_SubMenu_DisabledBrushV
    posSubMenuY1 := % Pause_%SubMenuName%_VMargin
    MaxFontListWidth := PauseMediaObj[SubMenuName].maxLabelSize
    posPageX := HMargin+MaxFontListWidth+HdistBetwLabelsandPages
    posPageY := VMargin
    showItemLabel := % Pause_%SubMenuName%_Item_Labels
    Loop, % PauseMediaObj[SubMenuName].TotalLabels
    {
        posSubMenuX1 := round(HMargin+MaxFontListWidth/2)
        If (VSubMenuItem = A_index ){
            If (SelectedMenuOption="Videos") and  (HSubmenuitem=2) {
                color := Pause_MainMenu_LabelDisabledColor
                Optionbrush := Pause_SubMenu_DisabledBrushV
            } Else {
                color := Pause_MainMenu_LabelSelectedColor
                Optionbrush := Pause_SubMenu_SelectedBrushV                
            }
        }    
        If( A_index >= VSubMenuItem){  
            Options1 := "x" . posSubMenuX1 . " y" . posSubMenuY1 . " Center c" . color . " r4 s" . Pause_SubMenu_LabelFontSize . " bold"
            Gdip_Alt_FillRoundedRectangle(Pause_G27, Optionbrush, round(posSubMenuX1-MaxFontListWidth/2), posSubMenuY1+Pause_VTextDisplacementAdjust-Pause_SubMenu_AdditionalTextMarginContour, MaxFontListWidth, Pause_SubMenu_FontSize+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(Pause_G27, PauseMediaObj[SubMenuName][a_index], Options1, Pause_SubMenu_LabelFont, 0, 0)
            posSubMenuY1 := posSubMenuY1+VdistBetwLabels
            color := Pause_MainMenu_LabelDisabledColor
            Optionbrush := Pause_SubMenu_DisabledBrushV
        }
    }
    ;If video file:  
    If CurrentFileExtension in %ListofSupportedVideos%    
        {
        If !(FullScreenView){
            If !(AnteriorFilePath = CurrentFilePath) {
                try CurrentVideoPlayStatus := wmpVideo.playState
                If(CurrentVideoPlayStatus=3) {
                    try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
                    RLLog.Debug(A_ThisLabel . " - VideoPosition at video change in videos menu:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%)
                    try wmpVideo.controls.stop
                    timeout:= A_TickCount
                    Loop
                        {
                        try CurrentVideoPlayStatus := wmpVideo.playState
                        If(CurrentVideoPlayStatus=1)
                            break
                        If(timeout<A_TickCount-2000)
                            break
                    }
                }
                Gui,Pause_GUI31: Show, Hide
                Gui, Pause_GUI32: Show
                try wmpVideo.Url := CurrentFilePath
                try wmpVideo.controls.play ;Workaround because I am still not able to figure out how to set the wmpVideo.currentMedia := 
                try wmpVideo.controls.pause
                RLLog.Debug(A_ThisLabel . " - Playing Video File: " CurrentFilePath)
                VideoH := Pause_SubMenu_Height-2*Pause_Videos_VMargin ;Calculating the Video Position and size If I am not able to acquire the real video size 
                VideoW := round(16*VideoH/9)
                If(VideoW > Pause_SubMenu_Width-3*Pause_Videos_HMargin+PauseMediaObj[SubMenuName].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour + Pause_SubMenu_SpaceBetweenLabelsandVideoButtons+Pause_SubMenu_SizeofVideoButtons){
                    VideoW := Pause_SubMenu_Width-3*Pause_Videos_HMargin+PauseMediaObj[SubMenuName].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour + Pause_SubMenu_SpaceBetweenLabelsandVideoButtons+Pause_SubMenu_SizeofVideoButtons
                    VideoH := round(9*VideoW/16)
                }
                VideoX := baseScreenWidth-Pause_SubMenu_Width+Pause_Videos_HMargin+ PauseMediaObj[SubMenuName].maxLabelSize +2*Pause_SubMenu_AdditionalTextMarginContour +Pause_SubMenu_SpaceBetweenLabelsandVideoButtons+Pause_SubMenu_SizeofVideoButtons+((Pause_SubMenu_Width-(Pause_Videos_HMargin+PauseMediaObj[SubMenuName].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour +Pause_SubMenu_SpaceBetweenLabelsandVideoButtons+Pause_SubMenu_SizeofVideoButtons))-VideoW)//2
                VideoY := baseScreenHeight-Pause_SubMenu_Height+VMargin + round((Pause_SubMenu_Height-2*Pause_Videos_VMargin-VideoH)/2)
                timeout := A_TickCount ;Calculating the real Video Position and size (two seconds timeout If not able to acquire video size)
                VideoRealH := 0
                VideoRealW := 0
                Loop
                    {
                    try VideoRealH := wmpVideo.currentMedia.imageSourceHeight
                    try VideoRealW := wmpVideo.currentMedia.imageSourceWidth
                    If((VideoRealH<>0) and (VideoRealW<>0))
                        break
                    If(timeout<A_TickCount-2000)
                        break
                }
                If((VideoRealH<>0) and (VideoRealW<>0)){
                    VideoH := Pause_SubMenu_Height-2*Pause_Videos_VMargin
                    VideoW := round(VideoRealW/(VideoRealH/VideoH))
                    If(VideoW > Pause_SubMenu_Width-3*Pause_Videos_HMargin-PauseMediaObj[SubMenuName].maxLabelSize-2*Pause_SubMenu_AdditionalTextMarginContour){
                        VideoW := Pause_SubMenu_Width-3*Pause_Videos_HMargin-PauseMediaObj[SubMenuName].maxLabelSize-2*Pause_SubMenu_AdditionalTextMarginContour
                        VideoH := round(VideoRealH/(VideoRealW/VideoW)) 
                    }
                    VideoX := baseScreenWidth-Pause_SubMenu_Width+Pause_Videos_HMargin+PauseMediaObj[SubMenuName].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour +Pause_SubMenu_SpaceBetweenLabelsandVideoButtons+Pause_SubMenu_SizeofVideoButtons+((Pause_SubMenu_Width-(Pause_Videos_HMargin+PauseMediaObj[SubMenuName].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour +Pause_SubMenu_SpaceBetweenLabelsandVideoButtons+Pause_SubMenu_SizeofVideoButtons))-VideoW)//2
                    VideoY :=  baseScreenHeight-Pause_SubMenu_Height+VMargin + round((Pause_SubMenu_Height-2*Pause_Videos_VMargin-VideoH)/2)
                }
                WindowCoordUpdate(VideoX,VideoY,VideoW,VideoH,pauseScreenRotationAngle)
                GuiControl, Pause_GUI31: Move, wmpVideo, x0 y0 w%VideoW% h%VideoH% ;Resizing and showing window and playing video
                try wmpVideo.controls.play
                If (VSubMenuItem=0)
                    currentvideoposition := VideoPosition1
                Else 
                    currentvideoposition := VideoPosition%VSubMenuItem%                    
                currentvideoposition += 0
                try wmpVideo.Controls.CurrentPosition += currentvideoposition
                RLLog.Debug(A_ThisLabel . " - Jumping to VideoPosition:" "VideoPosition"VSubMenuItem " " VideoPosition%VSubMenuItem%)
                VideoX := VideoX+monitorTable[pauseMonitor].Left
                VideoY := VideoY+monitorTable[pauseMonitor].Top
                Gui, Pause_GUI31: Show, x%VideoX% y%VideoY% w%VideoW% h%VideoH%
                Gui, Pause_GUI32: Show
                If (VSubmenuitem=0)
                    videoplayingindex := 1
                Else
                    videoplayingindex := VSubMenuItem
            }
            AnteriorFilePath := CurrentFilePath
            If (VSubmenuitem) {
                posVideoButtonsX := Pause_Videos_HMargin+PauseMediaObj[SubMenuName].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour + Pause_SubMenu_SpaceBetweenLabelsandVideoButtons
                Loop, 5
                    {
                    posVideoButton%a_index%Y := Pause_Videos_VMargin + (a_index-1)*(Pause_SubMenu_SizeofVideoButtons + Pause_SubMenu_SpaceBetweenVideoButtons)
                    try CurrentVideoPlayStatus := wmpVideo.playState
                    If (a_index=1) and (CurrentVideoPlayStatus=3)
                        PauseVideoBitmap%a_index% := Gdip_CreateBitmapFromFile(PauseVideoImage6)
                    Else
                        PauseVideoBitmap%a_index% := Gdip_CreateBitmapFromFile(PauseVideoImage%a_index%)
                    Gdip_Alt_DrawImage(Pause_G27,PauseVideoBitmap%a_index%,posVideoButtonsX,posVideoButton%a_index%Y,Pause_SubMenu_SizeofVideoButtons,Pause_SubMenu_SizeofVideoButtons)
                    If(HsubMenuItem = 2){
                        If (V2Submenuitem = a_index){
                            pGraphUpd(Pause_G30,round(Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size), round(Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size))
                            If (PreviousVideoButton<>V2Submenuitem){ 
                                GrowSize := 1
                                While GrowSize <= Pause_Video_Buttons_Grow_Size {
                                    Gdip_GraphicsClear(Pause_G30)
                                    Gdip_Alt_DrawImage(Pause_G30,PauseVideoBitmap%V2Submenuitem%,Pause_Video_Buttons_Grow_Size-GrowSize,Pause_Video_Buttons_Grow_Size-GrowSize,Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size)
                                    Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posVideoButtonsX-Pause_Video_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-Pause_Video_Buttons_Grow_Size), Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size, Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                                    GrowSize+= Pause_VideoButtonGrowingEffectVelocity
                                }
                                Gdip_GraphicsClear(Pause_G30)
                                If(GrowSize<>15){
                                    Gdip_Alt_DrawImage(Pause_G30,PauseVideoBitmap%V2Submenuitem%,0,0,Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size)
                                    Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posVideoButtonsX-Pause_Video_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-Pause_Video_Buttons_Grow_Size), Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size, Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                                }
                            } Else {
                                Gdip_Alt_DrawImage(Pause_G30,PauseVideoBitmap%V2Submenuitem%,0,0,Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size)
                                Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posVideoButtonsX-Pause_Video_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-Pause_Video_Buttons_Grow_Size), Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size, Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                            }
                        }
                    } Else {
                        Gdip_GraphicsClear(Pause_G30)
                        Alt_UpdateLayeredWindow(Pause_hwnd30, Pause_hdc30, round(baseScreenWidth-Pause_SubMenu_Width+posVideoButtonsX-Pause_Video_Buttons_Grow_Size), round(baseScreenHeight-Pause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-Pause_Video_Buttons_Grow_Size), Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size, Pause_SubMenu_SizeofVideoButtons+2*Pause_Video_Buttons_Grow_Size,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                    }
                    PreviousVideoButton := V2Submenuitem
                }
            }
        settimer, UpdateVideoPlayingInfo, 100, Period
        }
    }    
    ;If txt file:
    If(CurrentFileExtension = "txt"){
        If(FullScreenView <> 1){
            ;TotaltxtPages := % TotalV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
            TotaltxtPages := PauseMediaObj[SubMenuName][CurrentLabelName].TotalV2SubMenuItems
        } Else {
            ;TotaltxtPages := % TotalFullScreenV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
            TotaltxtPages := PauseMediaObj[SubMenuName][CurrentLabelName].TotalFSV2SubMenuItems
        }
        If (HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem% > TotaltxtPages) {
            HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem% = % TotaltxtPages
            V2Submenuitem := % HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem%
        }
        TotalCurrentPages := 2
        ;TextWidth := % FileTxtWidth%CurrentLabelNumber%
        TextWidth := PauseMediaObj[SubMenuName][CurrentLabelName].txtWidth
        posPageText2X := 2*HMargin+MaxFontListWidth
        posPageText2Y := VMargin
        colorText := Pause_MainMenu_LabelDisabledColor
        If(FullScreenView <> 1){
            Width := Pause_SubMenu_Width-3*HMargin-MaxFontListWidth
            Height := Pause_SubMenu_Height-2*VMargin
            If(TextWidth<Width){
                posPageText2X := round(2*HMargin+MaxFontListWidth+(Width-TextWidth)/2)
            }  
            If(HSubMenuItem=2){
                colorText := Pause_MainMenu_LabelSelectedColor
            }   
            OptionsText2 = x%posPageText2X% y%posPageText2Y% Left c%colorText% r4 s%Pause_SubMenu_SmallFontSize% Regular
            ;Gdip_Alt_TextToGraphics(Pause_G27, %SubMenuName%FileTxtContents%CurrentLabelNumber%Page%V2SubMenuItem%, OptionsText2, Pause_SubMenu_Font, Width, Height)
            Gdip_Alt_TextToGraphics(Pause_G27, PauseMediaObj[SubMenuName][CurrentLabelName]["Page" .  V2SubMenuItem], OptionsText2, Pause_SubMenu_Font, Width, Height)
            Gdip_GraphicsClear(Pause_G29)
            Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,baseScreenWidth - HelpTextLenghtWidth - 2*Pause_SubMenu_AdditionalTextMarginContour,baseScreenHeight- Pause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_HelpFontSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    }
    ;If pdf file:
    If (CurrentFileExtension = "pdf"){
        If (HSubMenuItem=0){
            HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem% := 1
            HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        }
        TotalCurrentPages := PauseMediaObj[SubMenuName][CurrentLabelName].TotalItems 
        ;TotalCurrentPages := % TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber% 
        IfNotExist, % RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName
            FileCreateDir, % RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName 
        if !(FileExist(RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName)){
            RLLog.Warning("RocketLauncher does not have the correct permission to create the temporary pdf extraction folder on the bellow location and because of that pdf files will not appear on the pause menu.`r`n`t`t`t`t`t " . RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName)
        }
        if !((Pause_LoadPDFOnLabel="true") and (VSubMenuItem < 1))
        {   
            Loop, %TotalCurrentPages%
            {   
                If(A_index >= HSubMenuItem){
                    If(A_index > TotalCurrentPages){
                        AllPagesLoaded%CurrentLabelNumber% := true
                    }
                    If(posPageX > Pause_SubMenu_Width){
                        break   
                    }
                    If !(AllPagesLoaded%CurrentLabelNumber% = true){
                        IfNotExist, % RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\" . "page" . A_Index . ".png"
                            {
                            if (FullScreenView = 1){
                                loadingPageTextWidth := MeasureText("Loading New Page", "Center r4 s" . Pause_SubMenu_FullScreenFontSize . " bold",Pause_SubMenu_Font)
                                Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, round((baseScreenWidth-Pause_SubMenu_FullScreenMargin)/2 - loadingPageTextWidth/2 - Pause_SubMenu_AdditionalTextMarginContour), round((baseScreenHeight-Pause_SubMenu_FullScreenMargin)/2 - Pause_SubMenu_FullScreenFontSize), loadingPageTextWidth+2*Pause_SubMenu_AdditionalTextMarginContour, 2*Pause_SubMenu_FullScreenFontSize,Pause_SubMenu_FullScreenRadiusofRoundedCorners)
                                loadingPageTextOptions := "x" . round((baseScreenWidth-Pause_SubMenu_FullScreenMargin)/2) . " y" . round((baseScreenHeight-Pause_SubMenu_FullScreenMargin)/2 - Pause_SubMenu_FullScreenFontSize/2) . " Center c" . Pause_SubMenu_FullScreenFontColor . " r4 s" . Pause_SubMenu_FullScreenFontSize . "bold"
                                Gdip_Alt_TextToGraphics(Pause_G29, "Loading New Page", loadingPageTextOptions, Pause_SubMenu_Font, 0, 0)
                                Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                            } 
                            SubMenuHelpText("Please wait while pdf pages are loaded")
                            Alt_UpdateLayeredWindow(Pause_hwnd27, Pause_hdc27,baseScreenWidth-Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height, Pause_SubMenu_Width, Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
                            RLLog.Debug(A_ThisLabel . " - Loaded PDF page " A_Index " and update " SelectedMenuOption " SubMenu.")
                            RLObject.generatePngFromPdf(CurrentFilePath, RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName, Pause_SubMenu_PdfDpiResolution,pdfMaxHeight,a_index,a_index,Pause_PDF_Page_Layout)
                            if !(FileExist(RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\*.png")){
                                RLLog.Warning("RocketLauncher does not have the correct permission to write files to the bellow location and because of that pdf files will not appear on the pause menu.`r`n`t`t`t`t`t " . RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName)
                            }
                        }  
                    }
                    CurrentImage%a_index% := RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\" . "page" . A_Index . ".png"
                    Gdip_DisposeImage(CurrentBitmap)
                    CurrentBitmap := Gdip_CreateBitmapFromFile(CurrentImage%a_index%)
                    If(HSubMenuItem = a_index){
                        SelectedImage := % CurrentImage%a_index%
                    }
                    BitmapW := Gdip_GetImageWidth(CurrentBitmap), BitmapH := Gdip_GetImageHeight(CurrentBitmap) 
                    resizedBitmapH := Pause_SubMenu_Height-2*VMargin-2*Pause_SubMenu_AdditionalTextMarginContour
                    resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
                    If(resizedBitmapW > (Pause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth-2*Pause_SubMenu_AdditionalTextMarginContour)){
                        resizedBitmapW := Pause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth
                        resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW)) 
                    }        
                    If((VSubMenuItem <> 0) and (HSubMenuItem = a_index)){
                        Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_%SubMenuName%SelectedBrushV, posPageX, round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
                    }
                    Gdip_Alt_DrawImage(Pause_G27, CurrentBitmap, posPageX+Pause_SubMenu_AdditionalTextMarginContour, round((Pause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
                    if (showItemLabel = "true")
                    {   posPageTextX := posPageX+round((resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour)/2)
                        posPageTextY := Pause_SubMenu_Height-VMargin-Pause_SubMenu_AdditionalTextMarginContour-2*Pause_SubMenu_SmallFontSize
                        OptionsPage1 := "x" . posPageTextX . " y" . posPageTextY . " Center c" . PageNumberFontColor . " r4 s" . Pause_SubMenu_SmallFontSize . " bold"
                        Gdip_Alt_TextToGraphics(Pause_G27, "Page " . a_index, OptionsPage1, Pause_SubMenu_Font, 0, 0)
                    }
                    If(VSubMenuItem = 0){
                        Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_DisabledBrushV, posPageX, round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
                    }
                    If((VSubMenuItem <> 0) and (HSubMenuItem <> a_index)){
                        Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_DisabledBrushV, posPageX, round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
                    }
                    posPageX := posPageX+resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour+HdistBetwPages                
                }
            }  
        }
    }
    ;If Compressed file
    If CurrentFileExtension in %sevenZFormatsNoP%,cbr,cbz
    {
        CurrentCompressedFileExtension = true
        Pause_7zExtractDir := RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName
        SubMenuHelpText("Please wait while compressed images are loaded")
        RunWait, %sevenZPath% e "%CurrentFilePath%" -aoa -o"%Pause_7zExtractDir%",,Hide ; perform the extraction and overwrite all
        currentobj := {}
        currentobj := PauseMediaObj[SubMenuName][CurrentLabelName]
        Loop, % RLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\*.*"
            {
            currentobj["Path" . a_index] := A_LoopFileLongPath
            currentobj["Ext" . a_index] := A_LoopFileExt
            currentobj["TotalItems"] := a_index
            sleep, 500
        }
        if (currentobj.TotalItems>1)
            currentobj["Type"]:="ImageGroup"
        PauseMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj)             
    } Else {
        CurrentCompressedFileExtension := "false"
    }
    
    ;If image folder or compressed images:
    If ((PauseMediaObj[SubMenuName][CurrentLabelName].Type="ImageGroup") or (CurrentCompressedFileExtension="true")){
    ;If((PauseMediaObj[SubMenuLabel][CurrentLabelName].Path2) or (CurrentCompressedFileExtension="true")){
        If (HSubMenuItem=0){
            HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem% := 1
            HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        }
        TotalCurrentPages := PauseMediaObj[SubMenuName][CurrentLabelName].TotalItems   
        ;TotalCurrentPages := % TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber%  
        Loop % TotalCurrentPages
        {
            If(A_index >= HSubMenuItem){
                If (posPageX > Pause_SubMenu_Width){
                    break   
                }
                CurrentImage%a_index% := PauseMediaObj[SubMenuName][CurrentLabelName]["Path" . a_index]
                ;CurrentImage%a_index% := % %SubMenuName%File%CurrentLabelNumber%File%a_index%
                Gdip_DisposeImage(CurrentBitmap)
                CurrentBitmap := Gdip_CreateBitmapFromFile(CurrentImage%a_index%)
                If(HSubMenuItem = a_index){
                    SelectedImage := % CurrentImage%a_index%
                }
                BitmapW := Gdip_GetImageWidth(CurrentBitmap), BitmapH := Gdip_GetImageHeight(CurrentBitmap)        
                resizedBitmapH := Pause_SubMenu_Height-2*VMargin-2*Pause_SubMenu_AdditionalTextMarginContour
                resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
                If(resizedBitmapW > (Pause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth-2*Pause_SubMenu_AdditionalTextMarginContour)){
                    resizedBitmapW := Pause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth
                    resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW)) 
                }        
                If((VSubMenuItem > 0) and (HSubMenuItem = a_index)){
                    Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_%SubMenuName%SelectedBrushV, posPageX, round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
                }
                Gdip_Alt_DrawImage(Pause_G27, CurrentBitmap, posPageX+Pause_SubMenu_AdditionalTextMarginContour, round((Pause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
                if (showItemLabel = "true")
                {   SplitPath, CurrentImage%a_index%, , , , FileNameText
                    posPageTextX := posPageX+Pause_SubMenu_AdditionalTextMarginContour
                    posPageTextY := Pause_SubMenu_Height-VMargin-Pause_SubMenu_AdditionalTextMarginContour-1.3*Pause_SubMenu_SmallFontSize-Pause_SubMenu_SmallFontSize*(ceil(MeasureText(FileNameText, "Left r4 s" . Pause_SubMenu_SmallFontSize . " bold",Pause_SubMenu_Font)/resizedBitmapW))
                    OptionsPage1 := "x" . posPageTextX . " y" . posPageTextY . " w" . resizedBitmapW . " Center c" . PageNumberFontColor . " r4 s" . Pause_SubMenu_SmallFontSize . " bold"
                    Gdip_Alt_TextToGraphics(Pause_G27, FileNameText, OptionsPage1, Pause_SubMenu_Font, 0, 0)
                }
                If (VSubMenuItem <= 0){
                    Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_DisabledBrushV, posPageX, round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
                }
                If ((VSubMenuItem <> 0) and (HSubMenuItem <> a_index)){
                    Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_DisabledBrushV, posPageX, round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
                }
                posPageX := posPageX+resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour+HdistBetwPages                
            }
        }  
    } else If CurrentFileExtension in %Supported_Images% ;If image file:
        { 
        TotalCurrentPages := 1
        SelectedImage := CurrentFilePath
        Gdip_DisposeImage(SelectedBitmap)
        SelectedBitmap := Gdip_CreateBitmapFromFile(SelectedImage)
        BitmapW := Gdip_GetImageWidth(SelectedBitmap), BitmapH := Gdip_GetImageHeight(SelectedBitmap) 
        resizedBitmapH := Pause_SubMenu_Height-2*VMargin-2*Pause_SubMenu_AdditionalTextMarginContour
        resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
        If (resizedBitmapW > (Pause_SubMenu_Width-2*HMargin-HMargin-MaxFontListWidth-2*Pause_SubMenu_AdditionalTextMarginContour)){
            resizedBitmapW := Pause_SubMenu_Width-2*HMargin-HMargin-MaxFontListWidth
            resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW)) 
        }         
        If (FullScreenView <> 1){
            Gdip_Alt_FillRoundedRectangle(Pause_G27, Pause_SubMenu_DisabledBrushV, round((Pause_SubMenu_Width-resizedBitmapW+MaxFontListWidth+HMargin)/2-Pause_SubMenu_AdditionalTextMarginContour), round((Pause_SubMenu_Height-resizedBitmapH)/2-Pause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*Pause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_DrawImage(Pause_G27, SelectedBitmap, round((Pause_SubMenu_Width+MaxFontListWidth+HMargin-resizedBitmapW)/2), round((Pause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
        }
    }
    ;full screen view
    If (VSubMenuItem>=0){
    If (FullScreenView = 1){
        Gdip_GraphicsClear(Pause_G29)
        pGraphUpd(Pause_G29,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin) 
        If CurrentFileExtension in %ListofSupportedVideos%    
            {
        } Else If(CurrentFileExtension = "txt"){
            If (HSubMenuItem=2){
            Width := baseScreenWidth - 4*Pause_SubMenu_FullScreenMargin
            Height := baseScreenHeight - 4*Pause_SubMenu_FullScreenMargin
            posTextFullScreenX := 2*Pause_SubMenu_FullScreenMargin 
            posTextFullScreenY := 2*Pause_SubMenu_FullScreenMargin
            If (TextWidth<Width){
                posTextFullScreenX := round(2*Pause_SubMenu_FullScreenMargin + (Width-TextWidth)/2)
            }           
            colorText := Pause_MainMenu_LabelSelectedColor
            Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenTextBrushV, posTextFullScreenX-Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenMargin, TextWidth+2*Pause_SubMenu_FullScreenMargin, Height+2*Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenRadiusofRoundedCorners)
            OptionsTextFullScreen := "x" . posTextFullScreenX . " y" . posTextFullScreenY . " Left c" . colorText . " r4 s" . Pause_SubMenu_SmallFontSize . " Regular"
            textFullScreen := PauseMediaObj[SubMenuName][CurrentLabelName]["FSPage" .  V2SubMenuItem]
            ;textFullScreen := %SubMenuName%FileTxtContents%CurrentLabelNumber%FullScreenPage%V2SubMenuItem%
            Gdip_Alt_TextToGraphics(Pause_G29, PauseMediaObj[SubMenuName][CurrentLabelName]["FSPage" .  V2SubMenuItem], OptionsTextFullScreen, Pause_SubMenu_Font, Width, Height)
            If Pause_SubMenu_FullSCreenHelpTextTimer
                { 
                Pause_SubMenu_FullScreenHelpBoxHeight := 5*Pause_SubMenu_FullScreenFontSize
                Pause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up for Page Up or Press Down for Page Down", "Left r4 s" . Pause_SubMenu_FullScreenFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
                Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, round((baseScreenWidth-Pause_SubMenu_FullScreenHelpBoxWidth)/2-Pause_SubMenu_FullScreenMargin), baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-6*Pause_SubMenu_FullScreenFontSize, Pause_SubMenu_FullScreenHelpBoxWidth,Pause_SubMenu_FullScreenHelpBoxHeight,Pause_SubMenu_FullScreenRadiusofRoundedCorners)
                posFullScreenTextX := round(baseScreenWidth/2-Pause_SubMenu_FullScreenMargin)
                posFullScreenTextY := round(baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-5*Pause_SubMenu_FullScreenFontSize-Pause_SubMenu_FullScreenFontSize/2)
                OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%Pause_SubMenu_FullScreenFontColor% r4 s%Pause_SubMenu_FullScreenFontSize% bold
                CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up for Page Up or Press Down for Page Down`nPage %V2SubMenuItem% of %TotaltxtPages%
                Gdip_Alt_TextToGraphics(Pause_G29, CurrentHelpText, OptionsFullScreenText, Pause_SubMenu_Font, 0, 0)
                if !(Pause_SubMenu_FullSCreenHelpTextTimer="always"){
                    savedHSubMenuItem := HSubMenuItem
                    savedVSubMenuItem := VSubMenuItem
                    savedV2SubMenuItem := V2SubMenuItem
                    SetTimer, ClearFullScreenHelpText1, -%Pause_SubMenu_FullSCreenHelpTextTimer% 
                }
            }
            Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
            } Else {
                Gdip_GraphicsClear(Pause_G29)
                Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
                FullScreenView := 0
            }
        } Else {
            Gdip_DisposeImage(SelectedBitmap)
            SelectedBitmap := Gdip_CreateBitmapFromFile(SelectedImage)
            BitmapW := Gdip_GetImageWidth(SelectedBitmap), BitmapH := Gdip_GetImageHeight(SelectedBitmap) 
            resizedBitmapH := baseScreenHeight - 2*Pause_SubMenu_FullScreenMargin
            resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
            If (resizedBitmapW > baseScreenWidth - 2*Pause_SubMenu_FullScreenMargin){
                resizedBitmapW := baseScreenWidth - 2*Pause_SubMenu_FullScreenMargin
                resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW))
            }
            Gdip_Alt_DrawImage(Pause_G29, SelectedBitmap, round((baseScreenWidth-resizedBitmapW)/2-Pause_SubMenu_FullScreenMargin+HorizontalPanFullScreen+(resizedBitmapW-resizedBitmapW*ZoomLevel/100)/2), round((baseScreenHeight-resizedBitmapH)/2-Pause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2), round(resizedBitmapW*ZoomLevel/100), round(resizedBitmapH*ZoomLevel/100))
            If Pause_SubMenu_FullSCreenHelpTextTimer
                {
                Pause_SubMenu_FullScreenHelpBoxHeight := 7*Pause_SubMenu_FullScreenFontSize
                Pause_SubMenu_FullScreenHelpBoxWidth := MeasureText("(Press Zoom In or Zoom Out Keys to Change Zoom Level)", "Left r4 s" . Pause_SubMenu_FullScreenFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour
                Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, round((baseScreenWidth-Pause_SubMenu_FullScreenHelpBoxWidth)/2-Pause_SubMenu_FullScreenMargin), baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-8*Pause_SubMenu_FullScreenFontSize, Pause_SubMenu_FullScreenHelpBoxWidth,Pause_SubMenu_FullScreenHelpBoxHeight,Pause_SubMenu_FullScreenRadiusofRoundedCorners)
                posFullScreenTextX := round(baseScreenWidth/2-Pause_SubMenu_FullScreenMargin)
                posFullScreenTextY := round(baseScreenHeight-2*Pause_SubMenu_FullScreenMargin-7*Pause_SubMenu_FullScreenFontSize-Pause_SubMenu_FullScreenFontSize/2)
                OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%Pause_SubMenu_FullScreenFontColor% r4 s%Pause_SubMenu_FullScreenFontSize% bold
                Gdip_Alt_TextToGraphics(Pause_G29, "Press Select Key to Exit Full Screen`nPress Left or Right to Change Pages while 100% Zoom`nZoom Level: " . ZoomLevel . "%`n(Press Zoom In or Zoom Out Keys to Change Zoom Level)`n(Press Up, Down Left or Right to Pan in Zoom Mode)", OptionsFullScreenText, Pause_SubMenu_Font, 0, 0)
                if (showItemLabel = "true")
                {   SplitPath, SelectedImage, , , , FileNameText
                    posPageTextX := (baseScreenWidth-2*Pause_SubMenu_FullScreenMargin) //2
                    posPageTextY := Pause_SubMenu_FullScreenMargin > round((baseScreenHeight-resizedBitmapH)/2-Pause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2)+Pause_SubMenu_SmallFontSize//2 ? Pause_SubMenu_FullScreenMargin : round((baseScreenHeight-resizedBitmapH)/2-Pause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2)+Pause_SubMenu_SmallFontSize//2
                    OptionsPage1 := "x" . posPageTextX . " y" . posPageTextY . " Center c" . PageNumberFontColor . " r4 s" . Pause_SubMenu_SmallFontSize . " bold"
                    Gdip_Alt_FillRectangle(Pause_G29, Pause_SubMenu_FullScreenBrushV, posPageTextX-(round( MeasureText(FileNameText, "Left r4 s" . Pause_SubMenu_SmallFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour))//2, posPageTextY-Pause_SubMenu_SmallFontSize//2, round( MeasureText(FileNameText, "Left r4 s" . Pause_SubMenu_SmallFontSize . " bold",Pause_SubMenu_Font)+Pause_SubMenu_AdditionalTextMarginContour), Pause_SubMenu_SmallFontSize+Pause_SubMenu_AdditionalTextMarginContour)
                    Gdip_Alt_TextToGraphics(Pause_G29, FileNameText, OptionsPage1, Pause_SubMenu_Font, 0, 0)
                }
                if !(Pause_SubMenu_FullSCreenHelpTextTimer="always"){
                    savedHSubMenuItem := HSubMenuItem
                    savedVSubMenuItem := VSubMenuItem
                    savedV2SubMenuItem := V2SubMenuItem
                    SetTimer, ClearFullScreenHelpText2, -%Pause_SubMenu_FullSCreenHelpTextTimer% 
                }
            }
            Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
        SubMenuHelpText("Press Select Key to exit FullScreen")
    } Else If(VSubMenuItem <> 0){
        If (CurrentFileExtension = "txt"){
            If (HSubMenuItem=1){
                CurrentHelpText := "Press Left or Right to Select the Text Information - Page " . V2SubMenuItem . " of " . TotaltxtPages
                SubMenuHelpText(CurrentHelpText)
            } Else {
                CurrentHelpText := "Press Select Key to go FullScreen - Page " . V2SubMenuItem . " of " . TotaltxtPages
                SubMenuHelpText(CurrentHelpText)
            }
        } Else {
            If not (SelectedMenuOption="Videos")
                SubMenuHelpText("Press Select Key to go FullScreen")
        }
    } Else {
        Gdip_GraphicsClear(Pause_G29)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G33)
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33,0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G34)
        Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        FullScreenView := 0
    }
    }
   FunctionRunning := false
Return    
}

ClearFullScreenHelpText1:
    if (savedHSubMenuItem=HSubMenuItem) and (savedVSubMenuItem=VSubMenuItem) and (savedV2SubMenuItem=V2SubMenuItem) {
        Gdip_GraphicsClear(Pause_G29)
        pGraphUpd(Pause_G29,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin) 
        Gdip_Alt_FillRoundedRectangle(Pause_G29, Pause_SubMenu_FullScreenTextBrushV, posTextFullScreenX-Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenMargin, TextWidth+2*Pause_SubMenu_FullScreenMargin, Height+2*Pause_SubMenu_FullScreenMargin, Pause_SubMenu_FullScreenRadiusofRoundedCorners)
        Gdip_Alt_TextToGraphics(Pause_G29, textFullScreen, OptionsTextFullScreen, Pause_SubMenu_Font, Width, Height)
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
    }
Return


ClearFullScreenHelpText2:
    if (savedHSubMenuItem=HSubMenuItem) and (savedVSubMenuItem=VSubMenuItem) and (savedV2SubMenuItem=V2SubMenuItem) {
        Gdip_GraphicsClear(Pause_G29)
        pGraphUpd(Pause_G29,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin)
        Gdip_Alt_DrawImage(Pause_G29, SelectedBitmap, round((baseScreenWidth-resizedBitmapW)/2-Pause_SubMenu_FullScreenMargin+HorizontalPanFullScreen+(resizedBitmapW-resizedBitmapW*ZoomLevel/100)/2), round((baseScreenHeight-resizedBitmapH)/2-Pause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2), round(resizedBitmapW*ZoomLevel/100), round(resizedBitmapH*ZoomLevel/100))
        Alt_UpdateLayeredWindow(Pause_hwnd29, Pause_hdc29,Pause_SubMenu_FullScreenMargin,Pause_SubMenu_FullScreenMargin,baseScreenWidth-2*Pause_SubMenu_FullScreenMargin,baseScreenHeight-2*Pause_SubMenu_FullScreenMargin,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
Return


ReadMovesListInformation() ;Reading Moves List info
{
    Global
    count:=0
    Loop {
        MovesListItem%A_index%  := StrX( RomCommandDatText ,  "$cmd" ,N,4, "$end",1,4,  N )
        If (!(MovesListItem%A_index%))
            break
        count++
        MovesListLabel%A_index%:=StrX(MovesListItem%A_index%,"[",1,1,"]",1,1)	
        StringReplace, MovesListItem%A_index%, MovesListItem%A_index%, % MovesListLabel%A_index%,, All
        StringReplace, MovesListItem%A_index%, MovesListItem%A_index%, [],, All
        MovesListItem%A_index%:=RegExReplace(MovesListItem%A_index%,"^\s*","") ; remove leading
        MovesListItem%A_index%:=RegExReplace(MovesListItem%A_index%,"\s*$","") ; remove trailing
        StringReplace, MovesListLabel%A_index%, MovesListLabel%A_index%,-,, All
        StringReplace, MovesListLabel%A_index%, MovesListLabel%A_index%, —,, All
    }
    currentObj := {}
    currentObj["TotalLabels"] := count
    PauseMediaObj.Insert("MovesList", currentObj)
    If (PauseMediaObj["MovesList"].TotalLabels<>0){    ;Loading button images
        If FileExist(Pause_MovesListImagePath . "\" . systemName . "\"  . dbName . "\*.png")
            Pause_MovesListCurrentPath := Pause_MovesListImagePath . "\" . systemName . "\"  . dbName . "\"
        Else If FileExist(Pause_MovesListImagePath . "\" . systemName . "\"  . DescriptionNameWithoutDisc . "\*.png")
            Pause_MovesListCurrentPath := Pause_MovesListImagePath . "\" . systemName . "\"  . DescriptionNameWithoutDisc . "\"
        Else If FileExist(Pause_MovesListImagePath . "\" . systemName . "\_Default\*.png")
            Pause_MovesListCurrentPath := Pause_MovesListImagePath . "\" . systemName . "\_Default\"
        Else FileExist(Pause_MovesListImagePath . "\_Default\*.png")
            Pause_MovesListCurrentPath := Pause_MovesListImagePath . "\_Default\"
        RLLog.Debug(A_ThisLabel . " - Moves List icons path: " . Pause_MovesListCurrentPath)
        Loop, %Pause_MovesListCurrentPath%\*.png, 0
            { 
            StringTrimRight, FileNameWithoutExtension, A_LoopFileName, 4 
            CommandDatImageFileList .= FileNameWithoutExtension . "`,"
            CommandDatfile%A_index% = %A_LoopFileFullPath%
            CommandDatBitmap%A_index% := Gdip_CreateBitmapFromFile(CommandDatfile%A_index%)
            TotalCommandDatImageFiles++
            }
        VMargin := % Pause_%temp_mainmenulabel%_VMargin ;Number of Lines per page
        LinesperPage%temp_mainmenulabel% := floor((Pause_SubMenu_Height-VMargin)/Pause_MovesList_VdistBetwMovesListLabels)
        LinesperFullScreenPage%temp_mainmenulabel% := floor((baseScreenHeight - 4*Pause_SubMenu_FullScreenMargin  - 5*Pause_SubMenu_FullScreenFontSize)/Pause_MovesList_VdistBetwMovesListLabels)  ;Number of lines in Full Screen
        Loop, % PauseMediaObj["MovesList"].TotalLabels ;Total number of pages
            {
            currentLabelNumber := A_index
            stringreplace, TempAuxMovesListItem%currentLabelNumber%, MovesListItem%currentLabelNumber%, `r`n,¿,all
            Loop, parse, TempAuxMovesListItem%currentLabelNumber%, ¿
                {
                If A_LoopField contains %Lettersandnumbers%  
                    {
                    %temp_mainmenulabel%TotalNumberofLines%currentLabelNumber%++
                }
            }
            %temp_mainmenulabel%TotalNumberofPages%currentLabelNumber% = % %temp_mainmenulabel%TotalNumberofLines%currentLabelNumber% / LinesperPage%temp_mainmenulabel% 
            %temp_mainmenulabel%TotalNumberofFullScreenPages%currentLabelNumber% = % %temp_mainmenulabel%TotalNumberofLines%currentLabelNumber% / LinesperFullScreenPage%temp_mainmenulabel% 
            %temp_mainmenulabel%TotalNumberofPages%currentLabelNumber% := ceil(%temp_mainmenulabel%TotalNumberofPages%currentLabelNumber%)
            %temp_mainmenulabel%TotalNumberofFullScreenPages%currentLabelNumber% := ceil(%temp_mainmenulabel%TotalNumberofFullScreenPages%currentLabelNumber%)
        }
    }
Return
}


CreatingStatisticsVariablestoSubmenu()
    {
    Global
    If(Initial_General_Statistics_Statistic_1=0){
        Value_General_Statistics_Statistic_1 := "Never"
    } Else If (Initial_General_Statistics_Statistic_1=1) {
        Value_General_Statistics_Statistic_1 := Initial_General_Statistics_Statistic_1 . " time"
    } Else {
        Value_General_Statistics_Statistic_1 := Initial_General_Statistics_Statistic_1 . " times"
    }  
    If(Initial_General_Statistics_Statistic_2=0){
        Value_General_Statistics_Statistic_2 := "Never"
    } Else {
        FormatTime, Value_General_Statistics_Statistic_2, %gameSectionStartHour%, dddd MMMM d, yyyy hh:mm:ss tt
    }
    If (Initial_General_Statistics_Statistic_3>0)
        Value_General_Statistics_Statistic_3 := GetTimeString(Initial_General_Statistics_Statistic_3) . " per session"
    Value_General_Statistics_Statistic_4 := GetTimeString(Initial_General_Statistics_Statistic_4)
    Value_General_Statistics_Statistic_5 := GetTimeString(Initial_General_Statistics_Statistic_5)
    Value_General_Statistics_Statistic_6 := GetTimeString(Initial_General_Statistics_Statistic_6) 
    Loop, 10 {
        Value_System_Top_Ten_Most_Played_Name_%a_index% := Initial_System_Top_Ten_Most_Played_Name_%a_index%
        Value_System_Top_Ten_Most_Played_Number_%a_index% := GetTimeString(Initial_System_Top_Ten_Most_Played_Number_%a_index%)
        Value_System_Top_Ten_Times_Played_Name_%a_index% := Initial_System_Top_Ten_Times_Played_Name_%a_index%
        If(Initial_System_Top_Ten_Times_Played_Number_%a_index% = 1){
            Value_System_Top_Ten_Times_Played_Number_%a_index% := Initial_System_Top_Ten_Times_Played_Number_%a_index% . " time"
        }
        If (Initial_System_Top_Ten_Times_Played_Number_%a_index% > 1){
            Value_System_Top_Ten_Times_Played_Number_%a_index% := Initial_System_Top_Ten_Times_Played_Number_%a_index% . " times"
        }
        Value_System_Top_Ten_Average_Time_Name_%a_index% := Initial_System_Top_Ten_Average_Time_Name_%a_index%
        If (Initial_System_Top_Ten_Average_Time_Number_%a_index%>0)
            Value_System_Top_Ten_Average_Time_Number_%a_index% := GetTimeString(Initial_System_Top_Ten_Average_Time_Number_%a_index%) . " per session"

        Value_Global_Last_Played_Games_System_%a_index% := Initial_Global_Last_Played_Games_System_%a_index%
        Value_Global_Last_Played_Games_Name_%a_index% := Initial_Global_Last_Played_Games_Name_%a_index% 
        Value_Global_Last_Played_Games_Date_%a_index% := Initial_Global_Last_Played_Games_Date_%a_index%
        Value_Global_Top_Ten_System_Most_Played_Name_%a_index% := Initial_Global_Top_Ten_System_Most_Played_Name_%a_index%
        Value_Global_Top_Ten_System_Most_Played_Number_%a_index% := GetTimeString(Initial_Global_Top_Ten_System_Most_Played_Number_%a_index%)
        Value_Global_Top_Ten_Most_Played_System_%a_index% := Initial_Global_Top_Ten_Most_Played_System_%a_index%
        Value_Global_Top_Ten_Most_Played_Name_%a_index% := Initial_Global_Top_Ten_Most_Played_Name_%a_index%
        Value_Global_Top_Ten_Most_Played_Number_%a_index% := GetTimeString(Initial_Global_Top_Ten_Most_Played_Number_%a_index%)
        Value_Global_Top_Ten_Times_Played_System_%a_index% := Initial_Global_Top_Ten_Times_Played_System_%a_index%
        Value_Global_Top_Ten_Times_Played_Name_%a_index% := Initial_Global_Top_Ten_Times_Played_Name_%a_index%
        If(Initial_Global_Top_Ten_Times_Played_Number_%a_index% = 1){
            Value_Global_Top_Ten_Times_Played_Number_%a_index% := Initial_Global_Top_Ten_Times_Played_Number_%a_index% . " time"
        }
        If (Initial_Global_Top_Ten_Times_Played_Number_%a_index% > 1){
            Value_Global_Top_Ten_Times_Played_Number_%a_index% := Initial_Global_Top_Ten_Times_Played_Number_%a_index% . " times"
        }
        Value_Global_Top_Ten_Average_Time_System_%a_index% := Initial_Global_Top_Ten_Average_Time_System_%a_index%
        Value_Global_Top_Ten_Average_Time_Name_%a_index% := Initial_Global_Top_Ten_Average_Time_Name_%a_index%
        If (Initial_Global_Top_Ten_Average_Time_Number_%a_index%>0)
            Value_Global_Top_Ten_Average_Time_Number_%a_index% := GetTimeString(Initial_Global_Top_Ten_Average_Time_Number_%a_index%) . " per session"
    }
Return
}

;--------------------

SubMenuHelpText(HelpText) ;SubMenu Help Text drawn function
    {
    Global
    Gdip_GraphicsClear(Pause_G33)
    HelpTextLenghtWidth := MeasureText(HelpText, "Left r4 s" . Pause_SubMenu_HelpFontSize . " Regular",Pause_SubMenu_HelpFont)
    pGraphUpd(Pause_G33,HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_HelpFontSize)
    posHelpX := round(HelpTextLenghtWidth/2 + Pause_SubMenu_AdditionalTextMarginContour)
    OptionsHelp = x%posHelpX% y0 Center c%Pause_MainMenu_LabelDisabledColor% r4 s%Pause_SubMenu_HelpFontSize% Regular
    Gdip_Alt_FillRectangle(Pause_G33, Pause_SubMenu_DisabledBrushV, 0, 0, HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour, Pause_SubMenu_HelpFontSize)
    Gdip_Alt_TextToGraphics(Pause_G33, HelpText, OptionsHelp, Pause_SubMenu_HelpFont, 0, 0)
    Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33,baseScreenWidth - HelpTextLenghtWidth - 2*Pause_SubMenu_AdditionalTextMarginContour - Pause_SubMenu_HelpRightMargin,baseScreenHeight- Pause_SubMenu_HelpFontSize - Pause_SubMenu_HelpBottomMargin,HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_HelpFontSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    Return    
}

DisableKeys:
    FunctionRunning := true ;error check function running (necessary to avoid exiting Pause in the middle of function running)
    RLLog.Debug(A_ThisLabel . " - Disable Pause Keys")
    XHotKeywrapper(navLeftKey,"MoveLeft","OFF")
    XHotKeywrapper(navRightKey,"MoveRight","OFF")
    XHotKeywrapper(navUpKey,"MoveUp","OFF")
    XHotKeywrapper(navDownKey,"MoveDown","OFF")
    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","OFF")
    XHotKeywrapper(navP2LeftKey,"MoveLeft","OFF")
    XHotKeywrapper(navP2RightKey,"MoveRight","OFF")
    XHotKeywrapper(navP2UpKey,"MoveUp","OFF")
    XHotKeywrapper(navP2DownKey,"MoveDown","OFF")
    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","OFF")
    XHotKeywrapper(pauseBackToMenuBarKey,"BacktoMenuBar","OFF")
    XHotKeywrapper(pauseZoomInKey,"ZoomIn","OFF")
    XHotKeywrapper(pauseZoomOutKey,"ZoomOut","OFF")
    XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","OFF")
    XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","OFF")
    If(Pause_EnableMouseControl = "true")
        hotkey, LButton, pauseMouseClick, Off
    RLLog.Debug(A_ThisLabel . " - Pause Keys Disabled")
    FunctionRunning := false
Return

EnableKeys:
    FunctionRunning := true ;error check function running (necessary to avoid exiting Pause in the middle of function running)
    RLLog.Debug(A_ThisLabel . " - Enable Pause Keys")
    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON")
    XHotKeywrapper(navLeftKey,"MoveLeft","ON")
    XHotKeywrapper(navRightKey,"MoveRight","ON")
    XHotKeywrapper(navUpKey,"MoveUp","ON")
    XHotKeywrapper(navDownKey,"MoveDown","ON")
    XHotKeywrapper(pauseBackToMenuBarKey,"BacktoMenuBar","ON")
    XHotKeywrapper(pauseZoomInKey,"ZoomIn","ON")
    XHotKeywrapper(pauseZoomOutKey,"ZoomOut","ON")
    XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
    XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","ON")
    XHotKeywrapper(navP2LeftKey,"MoveLeft","ON")
    XHotKeywrapper(navP2RightKey,"MoveRight","ON")
    XHotKeywrapper(navP2UpKey,"MoveUp","ON")
    XHotKeywrapper(navP2DownKey,"MoveDown","ON")
    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON") 
    If(Pause_EnableMouseControl = "true")
        hotkey, LButton, pauseMouseClick, On
    RLLog.Debug(A_ThisLabel . " - Pause Keys Enabled")
    FunctionRunning := false
Return


LoadExternalVariables:
;-----------------------------------------------------------------------------------------------------------------------------------------
 ; Paths
;-----------------------------------------------------------------------------------------------------------------------------------------
    SplitPath, pauseHiToTextPath, , pauseHitoTextDir
    ;Pause General Media Paths
    Pause_MenuSoundPath := RLMediaPath . "\Sounds\Menu"
    Pause_MouseSoundPath := RLMediaPath . "\Sounds\Mouse"
    Pause_IconsImagePath := RLMediaPath . "\Menu Images\Pause\Icons"
    Pause_MouseOverlayPath := RLMediaPath . "\Menu Images\Pause\Mouse Overlay"
    ;Pause Menu Media Paths
    Pause_ControllerPath := RLMediaPath . "\Controller"
    If !FileExist(Pause_ControllerPath)
		FileCreateDir, %Pause_ControllerPath%
    Pause_ControllerTempPath := RLMediaPath . "\Controller\Temp\" . systemName
    Pause_ArtworkPath := RLMediaPath . "\Artwork"
    If !FileExist(Pause_ArtworkPath)
		FileCreateDir, %Pause_ArtworkPath%
    Pause_ArtworkTempPath := RLMediaPath . "\Artwork\Temp\" . systemName
    Pause_GuidesPath := RLMediaPath . "\Guides"
    If !FileExist(Pause_GuidesPath)
		FileCreateDir, %Pause_GuidesPath%
    Pause_GuidesTempPath := RLMediaPath . "\Guides\Temp\" . systemName
    Pause_ManualsPath := RLMediaPath . "\Manuals\"
    If !FileExist(Pause_ManualsPath)
		FileCreateDir, %Pause_ManualsPath%
    Pause_ManualsTempPath := RLMediaPath . "\Manuals\Temp\" . systemName
    Pause_VideosPath := RLMediaPath . "\Videos"
    If !FileExist(Pause_VideosPath)
		FileCreateDir, %Pause_VideosPath%
    multiGameImgPath := RLMediaPath . "\MultiGame"
    If !FileExist(multiGameImgPath)
        FileCreateDir, %multiGameImgPath%
    Pause_BackgroundsPath := RLMediaPath . "\Backgrounds"
    If !FileExist(Pause_BackgroundsPath)
        FileCreateDir, %Pause_BackgroundsPath%
    Pause_MusicPath := RLMediaPath . "\Music"
    If !FileExist(Pause_MusicPath)
        FileCreateDir, %Pause_MusicPath%
    Pause_MovesListImagePath := RLMediaPath . "\Moves List"
    If !FileExist(Pause_MovesListImagePath)
		FileCreateDir, %Pause_MovesListImagePath%
    Pause_HistoryDatPath := RLDataPath . "\History"
    If !FileExist(Pause_HistoryDatPath)
		FileCreateDir, %Pause_HistoryDatPath%
    Pause_KeymapperMediaPath := RLMediaPath . "\Keymapper"
    ;Pause Data paths    
    Pause_GameInfoPath := RLDataPath . "\Game Info"
    If !FileExist(Pause_GameInfoPath)
		FileCreateDir, %Pause_GameInfoPath%
    Pause_MovesListDataPath := RLDataPath . "\Moves List"
    If !FileExist(Pause_MovesListDataPath)
		FileCreateDir, %Pause_MovesListDataPath%
    Pause_GameStatistics := RLDataPath . "\Statistics"
    If !FileExist(Pause_GameStatistics)
		FileCreateDir, %Pause_GameStatistics%
    Pause_SaveScreenshotPath := RLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots"
    ;Pause files:
    Pause_StatisticsFile := Pause_GameStatistics . "\" . systemName . ".ini" 
    if (RIni_Read("Stat_Sys",Pause_StatisticsFile) = -11) {
       RIni_Create("Stat_Sys")
    }
    Pause_GlobalStatisticsFile := Pause_GameStatistics . "\Global Statistics.ini"
    ;Cheking Pause files existence
    If !FileExist(sevenZPath)
        RLLog.Error(A_ThisLabel . " - 7z.exe not found")
    If !FileExist(Pause_MenuSoundPath . "\menu.wav")
        RLLog.Error(A_ThisLabel . " - Pause source sound files not found")
    If !FileExist(Pause_IconsImagePath . "\Pause.png")
        RLLog.Error(A_ThisLabel . " - Pause source image files not found")    
    If !FileExist(Pause_MovesListDataPath . "\*.dat")
        RLLog.Error(A_ThisLabel . " - No Moves List files available")
    RLLog.Info(A_ThisLabel . " - RocketLauncher HitoText Path:          " pauseHiToTextPath)
    RLLog.Info(A_ThisLabel . " - RocketLauncher 7z Path:                " sevenZPath)
    ;Settings hardcoded
    ;Mouse Click Sound
    Pause_MouseClickSound := "false" ; not reliable
    ;SubMenu
    Pause_SubMenu_Pen_Width := 7
    Pause_Logo_Image_Margin := 25
    Pause_MainMenu_Info_Margin := 15
	Pause_Controller_Profiles_Margin := 15
	Pause_Controller_Profiles_First_Column_Width := 40
	Pause_Controller_Joy_Selected_Grow_Size := 7
	Pause_Settings_Margin := 15
	Pause_Sound_MarginBetweenButtons := 40
	Pause_Sound_Buttons_Grow_Size := 20
	Pause_Sound_Margin := 15
	Pause_Sound_InGameMusic_Margin := 125
	Pause_Statistics_Middle_Column_Offset := -40
    Pause_Statistics_MarginBetweenTableColumns := 10
    Pause_ChangingDisc_GrowSize := 30
    Pause_ChangingDisc_Rounded_Corner := 7
	Pause_ChangingDisc_Margin := 15
	Pause_Video_Buttons_Grow_Size := 20
    Pause_VTextDisplacementAdjust := 5
	; 7z Progress Bar Options:
    Pause_7zProgress_BarW := 800
    Pause_7zProgress_BarH := 45
    Pause_7zProgress_BarBackgroundMargin := 55
    Pause_7zProgress_BarBackgroundRadius := 15
    Pause_7zProgress_BarR := 15
    Pause_7zProgress_BarBackgroundColor := "BB000000"
    Pause_7zProgress_BarBackColor := "BB555555"
    Pause_7zProgress_BarColor := "DD00BFFF"
    Pause_7zProgress_BarHatchStyle := 3
    Pause_7zProgress_BarText1FontSize := 30
    Pause_7zProgress_BarText2FontSize := 30
    Pause_7zProgress_BarText1Options := "cFFFFFFFF r4 Right Bold"
    Pause_7zProgress_BarText1 := "Loading Game"
    Text2Option := "cFFFFFFFF r4 Right Bold"
    Pause_7zProgress_BarText2 := "Extraction Complete"
    Pause_7zProgress_Font := "BEBAS NEUE"
    Pause_7zProgress_Text_Offset := 30
	;Loading ini settings
    Pause_ControllerMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Controller_Menu_Enabled", "true")  
    Pause_ChangeDiscMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "ChangeDisc_Menu_Enabled", "true")  
    Pause_SaveandLoadMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "SaveandLoad_Menu_Enabled", "true")  
    Pause_HighScoreMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "HighScore_Menu_Enabled", "true")  
    Pause_ArtworkMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Artwork_Menu_Enabled", "true")  
    Pause_GuidesMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Guides_Menu_Enabled", "true")  
    Pause_ManualsMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Manuals_Menu_Enabled", "true")  
    Pause_HistoryMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "History_Menu_Enabled", "true")  
    Pause_SoundMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Sound_Menu_Enabled", "true")  
    Pause_SettingsMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Settings_Menu_Enabled", "true")  
    Pause_VideosMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Videos_Menu_Enabled", "true")
    Pause_StatisticsMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Statistics_Menu_Enabled", "true")  
    Pause_MovesListMenuEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "MovesList_Menu_Enabled", "true")  
    Pause_ShutdownLabelEnabled := RIniPauseLoadVar("P","P_sys", "General Options", "Shutdown_Label_Enabled", "true")  
    Pause_LoadPDFandCompressedFilesatStart := RIniPauseLoadVar("P","P_sys", "General Options", "Load_PDF_and_Compressed_Files_at_Pause_First_Start", "false")
    Pause_PDF_Page_Layout := RIniPauseLoadVar("P","P_sys", "General Options", "PDF_Page_Layout", "frompdf") 
    Pause_SubMenu_PdfDpiResolution := RIniPauseLoadVar("P","P_sys", "General Options", "Pdf_Dpi_Resolution", "72")
    pdfMaxHeight := RIniPauseLoadVar("P","P_sys", "General Options", "PDF_Max_Height", "1080")
    Pause_MuteWhenLoading := RIniPauseLoadVar("P","P_sys", "General Options", "Mute_when_Loading_Pause", "true") 
    Pause_MuteSound := RIniPauseLoadVar("P","P_sys", "General Options", "Mute_Sound", "false") 
    Pause_Disable_Menu := RIniPauseLoadVar("P","P_sys", "General Options", "Disable_Pause_Menu", "true") 
    Pause_EnableMouseControl := RIniPauseLoadVar("P","P_sys", "General Options", "Enable_Mouse_Control", "false")  
    Pause_SupportAdditionalImageFiles := RIniPauseLoadVar("P","P_sys", "General Options", "Support_Additional_Image_Files", "true") 
    Pause_Screenshot_Extension := RIniPauseLoadVar("P","P_sys", "General Options", "Screenshot_Extension", "jpg") ;Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
    Pause_Screenshot_JPG_Quality := RIniPauseLoadVar("P","P_sys", "General Options", "Screenshot_JPG_Quality", "100") ;If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
    Pause_UseParentGameMediaAssets := RIniPauseLoadVar("P","P_sys", "General Options", "Pause_Use_Parent_Game_Media_Assets", "true")  
    Pause_LoadPDFOnLabel := RIniPauseLoadVar("P","P_sys", "General Options", "Pause_Load_PDF_On_Label", "false")
    ;Main Menu Options
    Pause_MainMenu_GlobalBackground := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Enable_Global_Background", "true")  
    Pause_MainMenu_BackgroundAlign := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Background_Align_Image", "Align to Top Left")  
    Pause_MainMenu_ShowClock := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Enable_Clock", "true")
    Pause_MainMenu_ClockFont := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Clock_Font", "Bebas Neue")
    Pause_MainMenu_ClockFontSize := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Clock_Font_Size", "25")
    Pause_MainMenu_LabelFont := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_Text_Font", "Bebas Neue")
    Pause_MainMenu_LabelFontsize := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_Text_Font_Size", "75")
    Pause_MainMenu_LabelSelectedColor := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_Text_Selected_Color", "ffffffff")
    Pause_MainMenu_LabelDisabledColor := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_Text_Disabled_Color", "44ffffff")
    Pause_MainMenu_HdistBetwLabels := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_Horizontal_Distance_Between_Labels", "160")
    Pause_MainMenu_BarHeight := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_Height", "90")
    Pause_MainMenu_BarGradientBrush1 := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_GradientBrush1", "6f000000")
    Pause_MainMenu_BarGradientBrush2 := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Main_Bar_GradientBrush2", "ff000000")
    Pause_MainMenu_Background_Color := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Background_Color", "ff000000")
    Pause_MainMenu_BackgroundBrush := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Background_Brush", "aa000000") 
    Pause_MainMenu_Info_Labels := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Items", "Publisher|Developer|Company|Released|Year|Systems|Genre|Perspective|GameType|Language|Score|Controls|Players|NumPlayers|Series|Rating|Description")
    Pause_MainMenu_Info_Font := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Font", "Arial")
    Pause_MainMenu_Info_FontSize := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Font_Size", "22")
    Pause_MainMenu_Info_FontColor := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Font_Color", "ffffffff")
    Pause_MainMenu_Info_Description_Font := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Description_Font", "Arial")
    Pause_MainMenu_Info_Description_FontSize := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Description_Font_Size", "22")
    Pause_MainMenu_Info_Description_FontColor := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Description_Font_Color", "ffffffff")
    Pause_MainMenu_DescriptionScrollingVelocity := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Game_Info_Description_Scrolling_Velocity", "2")
    Pause_MainMenu_UseScreenshotAsBackground := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Use_Screenshot_As_Background", "false") 
    Pause_MouseControlTransparency := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Mouse_Control_Overlay_Transparency", "50")
    Pause_MainMenu_BarVerticalOffset := RIniPauseLoadVar("P","P_sys", "Main Menu Appearance Options", "Bar_Vertical_Offset", "0")
    ;SubMenu General Options
    Pause_SubMenu_Appearance_Duration := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Appearance_Duration", "300")
    Pause_SubMenu_AdditionalTextMarginContour := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Additional_Text_Margin_Contour", "15")
    Pause_SubMenu_MinimumTextBoxWidth := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Minimum_Text_Box_Width", "270")
    Pause_SubMenu_DelayinMilliseconds := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Appearance_Delay_in_Milliseconds", "500")
    Pause_SubMenu_TopRightChamfer := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Top_Right_Chamfer_Size", "40")
    Pause_SubMenu_Width := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Width", "1350|1020")
    Pause_SubMenu_Height := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Height", "450|700")
    Pause_SubMenu_BackgroundBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Background_Brush", "44000000")
    Pause_SubMenu_LabelFont := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Label_Font", "Bebas Neue")
    Pause_SubMenu_LabelFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Label_Font_Size", "37")
    Pause_SubMenu_Font := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Content_Font", "Lucida Console")
    Pause_SubMenu_FontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Content_Font_Size", "30")
    Pause_SubMenu_SmallFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Content_Small_Font_Size", "22")
    Pause_SubMenu_HelpFont := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Help_Font", "Bebas Neue")
    Pause_SubMenu_HelpFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Help_Font_Size", "22")
    Pause_SubMenu_HelpBottomMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Help_Bottom_Margin", "0")
    Pause_SubMenu_HelpRightMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Help_Right_Margin", "0")
    Pause_SubMenu_SelectedBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Selected_Brush", "cc000000")
    Pause_SubMenu_DisabledBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Disabled_Brush", "44000000")
    Pause_SubMenu_RadiusofRoundedCorners := RIniPauseLoadVar("P","P_sys", "SubMenu Appearance Options", "Radius_of_Rounded_Corners", "15") 
    ;SubMenu FullScreen Options
    Pause_SubMenu_FullScreenMargin := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Margin", "25") 
    Pause_SubMenu_FullScreenRadiusofRoundedCorners := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Radius_of_Rounded_Corners", "15") 
    Pause_SubMenu_FullScreenBrush := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Background_Brush", "88000000") 
    Pause_SubMenu_FullScreenTextBrush := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Legend_Text_Brush", "DD000015") 
    Pause_SubMenu_FullScreenFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Legend_Text_Font_Color", "ffffffff") 
    Pause_SubMenu_FullScreenFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Legend_Text_Font_Size", "22") 
    Pause_SubMenu_FullScreenZoomSteps := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Zoom_Steps", "25") 
    Pause_SubMenu_FullScreenPanSteps := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Pan_Steps", "120") 
    Pause_SubMenu_FullSCreenHelpTextTimer := RIniPauseLoadVar("P","P_sys", "SubMenu FullScreen Appearance Options", "Full_Screen_Help_Text_Timer", "2000") 
    ;Save and Load State Options 
    Pause_State_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Save and Load State Appearance Options", "Vertical_Distance_Between_Labels", "75")
    Pause_State_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Save and Load State Appearance Options", "Horizontal_Margin", "200")
    Pause_State_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Save and Load State Appearance Options", "Vertical_Margin", "90")
    Pause_DelaytoSendKeys := RIniPauseLoadVar("P","P_sys", "SubMenu Save and Load State Appearance Options", "Delay_to_Send_Keys", "500")
    Pause_SetKeyDelay := RIniPauseLoadVar("P","P_sys", "SubMenu Save and Load State Appearance Options", "Set_Key_Delay", "200")
    Pause_SaveStateScreenshot := RIniPauseLoadVar("P","P_sys", "SubMenu Save and Load State Appearance Options", "Enable_Save_State_Screenshot", "true") 
    ;Settings Menu Options
    Pause_Settings_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Settings Appearance Options", "Vertical_Distance_Between_Labels", "75")
    Pause_Settings_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Settings Appearance Options", "Horizontal_Margin", "200")
    Pause_Settings_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Settings Appearance Options", "Vertical_Margin", "90")
    Pause_Settings_OptionFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Settings Appearance Options", "Option_Font_Size", "22")
    ;Sound Menu Options
    Pause_SoundBar_SingleBarWidth := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Single_Bar_Width", "25")
    Pause_SoundBar_SingleBarSpacing := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Single_Bar_Spacing", "7")
    Pause_SoundBar_SingleBarHeight := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Single_Bar_Height", "45")
    Pause_SoundBar_HeightDifferenceBetweenBars := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Height_Difference_Between_Bars", "3")
    Pause_SoundBar_vol_Step := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Volume_Steps", "5")
    Pause_SubMenu_SoundSelectedColor := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Selected_Color", "ffffffff")
    Pause_SubMenu_SoundDisabledColor := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Disabled_Color", "44ffffff")
    Pause_SubMenu_SoundMuteButtonFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Mute_Button_Font_Size", "20")
    Pause_SubMenu_SoundMuteButtonVDist := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Sound_Mute_Button_Vertical_Distance", "75|100")
    Pause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Space_Between_Sound_Bar_and_Sound_Bitmap", "55")
    Pause_SubMenu_SoundDisttoSoundLevel := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Sound_Distance_to_Sound_Level", "15")
    Pause_MusicPlayerEnabled := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Enable_Music_Player", "true")
    Pause_PlaylistExtension := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Playlist_Extension", "m3u")
    Pause_MusicFilesExtension := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Music_Files_Extension", "mp3|m4a|wav|mid|wma")
    Pause_EnableMusicOnStartup := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Enable_Music_on_Pause_Startup", "true")
    Pause_KeepPlayingAfterExitingPause := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Keep_Playing_after_Exiting_Pause", "false")
    Pause_EnableShuffle := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Enable_Shuffle", "true")
    Pause_EnableLoop := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Enable_Loop", "true")
    Pause_ExternalPlaylistPath := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "External_Playlist_Path", "")
    Pause_SubMenu_SpaceBetweenMusicPlayerButtons := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Space_Between_Music_Player_Buttons", "65")
    Pause_SubMenu_SizeofMusicPlayerButtons := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Size_of_Music_Player_Buttons", "65")
    Pause_SubMenu_MusicPlayerVDist := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Music_Player_Vertical_Distance", "75|100")
    Pause_SoundButtonGrowingEffectVelocity := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Sound_Button_Growing_Velocity", "1") 
    Pause_MusicPlayerVolumeLevel := RIniPauseLoadVar("P","P_sys", "SubMenu Sound Control Appearance Options", "Music_Player_Volume_Level", "100")
    ;Change Disc Options
    Pause_ChangeDisc_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Change Disc Appearance Options", "Vertical_Margin", "45")
    Pause_ChangeDisc_TextDisttoImage := RIniPauseLoadVar("P","P_sys", "SubMenu Change Disc Appearance Options", "Text_Distance_to_Image", "30") 
    Pause_ChangeDisc_UseGameArt := RIniPauseLoadVar("P","P_sys", "SubMenu Change Disc Appearance Options", "Use_Game_Art_for_Disc_Image", "true") 
    Pause_ChangeDisc_SelectedEffect := RIniPauseLoadVar("P","P_sys", "SubMenu Change Disc Appearance Options", "Selected_Disc_Effect", "rotate") 
    Pause_ChangeDisc_SidePadding := RIniPauseLoadVar("P","P_sys", "SubMenu Change Disc Appearance Options", "Side_Padding", "0.2") 
    ;High Score Options
    Pause_SubMenu_HighlightPlayerName := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Highlighted_Player_Name", "GEN") 
    Pause_SubMenu_HighlightPlayerFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Highlighted_Player_Font_Color", "ff00ffff") 
    Pause_SubMenu_HighScoreFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Font_Color", "ffffffff") 
    Pause_SubMenu_HighScoreFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Font_Size", "22") 
    Pause_SubMenu_HighScoreTitleFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Title_Font_Size", "30") 
    Pause_SubMenu_HighScoreTitleFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Title_Font_Color", "ffffff00") 
    Pause_SubMenu_HighScoreSelectedFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Selected_Font_Color", "ffff00ff") 
    Pause_SubMenu_HighScore_SuperiorMargin := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Superior_Margin", "45")
    Pause_SubMenu_HighScoreFullScreenWidth := RIniPauseLoadVar("P","P_sys", "SubMenu HighScore Appearance Options", "Full_Screen_Width", "1000") 
    ;Moves List Options
    Pause_MovesList_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Vertical_Margin", "45") 
    Pause_MovesList_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Horizontal_Margin", "40") 
    Pause_MovesList_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_MovesList_HdistBetwLabelsandMovesList := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Horizontal_Distance_Between_Labels_and_MovesList", "125") 
    Pause_MovesList_VdistBetwMovesListLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Vertical_Distance_Between_Moves_Lines", "60") 
    Pause_MovesList_SecondaryFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Secondary_Font_Size", "22")
    Pause_MovesList_VImageSize := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Vertical_Move_Image_Size", "55") 
    Pause_SubMenu_MovesListFullScreenWidth := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Full_Screen_Width", "1000")
    Pause_MovesList_HFullScreenMovesMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Moves List Appearance Options", "Horizontal_Full_Screen_Moves_Margin", "270")
    ;Statistics Menu Options
    Pause_Statistics_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Vertical_Margin", "45")  
    Pause_Statistics_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Horizontal_Margin", "40") 
    Pause_Statistics_TableFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Table_Font_Size", "22") 
    Pause_Statistics_DistBetweenLabelsandTable := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Distance_Between_Labels_and_Table", "55") 
    Pause_Statistics_VdistBetwTableLines := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Vertical_Distance_Between_Table_Lines", "45") 
    Pause_Statistics_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_Statistics_TitleFontSize := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Title_Font_Size", "30") 
    Pause_Statistics_TitleFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Title_Font_Color", "ffffff00") 
    Pause_SubMenu_StatisticsFullScreenWidth := RIniPauseLoadVar("P","P_sys", "SubMenu Statistics Appearance Options", "Full_Screen_Width", "1000") 
    ;Guides Menu Options
    Pause_Guides_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Vertical_Margin", "45") 
    Pause_Guides_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Horizontal_Margin", "40") 
    Pause_Guides_HdistBetwPages := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    Pause_SubMenu_GuidesSelectedBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Selected_Brush", "33ffff00") 
    Pause_Guides_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_Guides_HdistBetwLabelsandPages := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    Pause_Guides_PageNumberFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Page_Number_Font_Color", "00000000") 
    Pause_Guides_Item_Labels := RIniPauseLoadVar("P","P_sys", "SubMenu Guides Appearance Options", "Show_Item_Labels", "true") 
    ;Manuals Menu Options
    Pause_Manuals_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Vertical_Margin", "45") 
    Pause_Manuals_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Horizontal_Margin", "40") 
    Pause_Manuals_HdistBetwPages := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    Pause_SubMenu_ManualsSelectedBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Selected_Brush", "33ffff00") 
    Pause_Manuals_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_Manuals_HdistBetwLabelsandPages := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    Pause_Manuals_PageNumberFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Page_Number_Font_Color", "00000000") 
    Pause_Manuals_Item_Labels := RIniPauseLoadVar("P","P_sys", "SubMenu Manuals Appearance Options", "Show_Item_Labels", "true") 
    ;History Menu Options
    Pause_History_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Vertical_Margin", "45") 
    Pause_History_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Horizontal_Margin", "40") 
    Pause_History_HdistBetwPages := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    Pause_SubMenu_HistorySelectedBrush := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Selected_Brush", "33ffff00") 
    Pause_History_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_History_HdistBetwLabelsandPages := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    Pause_History_PageNumberFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu History Appearance Options", "Page_Number_Font_Color", "00000000") 
    ;Controller Menu Options
    Pause_Controller_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Vertical_Margin", "45") 
    Pause_Controller_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Horizontal_Margin", "40") 
    Pause_Controller_HdistBetwPages := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    Pause_SubMenu_ControllerSelectedBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Selected_Brush", "33ffff00") 
    Pause_Controller_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_Controller_HdistBetwLabelsandPages := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    Pause_Controller_PageNumberFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Page_Number_Font_Color", "00000000") 
    Pause_Controller_Item_Labels := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Show_Item_Labels", "true") 
    Pause_ControllerBannerHeight := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Controller_Banner_Height", "60") 
    Pause_vDistanceBetweenButtons := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Buttons", "120") 
    Pause_vDistanceBetweenBanners := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Banners", "45") 
    Pause_hDistanceBetweenControllerBannerElements := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Controller_Banner_Elements", "55") 
    Pause_selectedControllerBannerDisplacement := RIniPauseLoadVar("P","P_sys", "SubMenu Controller Appearance Options", "Selected_Controller_Banner_Displacement", "25") 
    ;Artwork Menu Options
    Pause_Artwork_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Vertical_Margin", "45") 
    Pause_Artwork_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Horizontal_Margin", "40") 
    Pause_Artwork_HdistBetwPages := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    Pause_SubMenu_ArtworkSelectedBrush := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Selected_Brush", "33ffff00") 
    Pause_Artwork_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_Artwork_HdistBetwLabelsandPages := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    Pause_Artwork_PageNumberFontColor := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Page_Number_Font_Color", "00000000") 
    Pause_Artwork_Item_Labels := RIniPauseLoadVar("P","P_sys", "SubMenu Artwork Appearance Options", "Show_Item_Labels", "true") 
    ;Videos Menu Options
    Pause_SupportedVideos := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Supported_Videos", "avi|wmv|mp4")
    Pause_Videos_VMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Vertical_Margin", "45") 
    Pause_Videos_HMargin := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Horizontal_Margin", "40") 
    Pause_Videos_VdistBetwLabels := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    Pause_EnableVideoLoop := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Enable_Loop", "true") 
    Pause_SubMenu_VideoRewindFastForwardJumpSeconds := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Video_Seconds_to_Jump_in_Rewind_and_Fast_Forward_Buttons", "5") 
    Pause_VideoButtonGrowingEffectVelocity := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Video_Button_Growing_Velocity", "1") 
    Pause_SubMenu_SizeofVideoButtons := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Size_of_Video_Player_Buttons", "60") 
    Pause_SubMenu_SpaceBetweenVideoButtons := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Space_Between_Video_Player_Buttons", "20") 
    Pause_SubMenu_SpaceBetweenLabelsandVideoButtons := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Space_Between_Label_and_Video_Player_Buttons", "45") 
    Pause_VideoPlayerVolumeLevel := RIniPauseLoadVar("P","P_sys", "SubMenu Videos Appearance Options", "Video_Player_Volume_Level", "100") 
    ;Start and exit screen
    Pause_AuxiliarScreen_StartText := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Loading_Text", "Loading Pause") 
    Pause_AuxiliarScreen_ExitText := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Exiting_Text", "Exiting Pause") 
    Pause_AuxiliarScreen_Font := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Font", "Bebas Neue") 
    Pause_AuxiliarScreen_FontSize := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Font_Size", "45") 
    Pause_AuxiliarScreen_FontColor := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Font_Color", "ff222222") 
    Pause_AuxiliarScreen_ExitTextMargin := RIniPauseLoadVar("P","P_sys", "Start and Exit Screen", "Text_Margin", "65") 
    ;Check font
    CheckFont(Pause_7zProgress_Font)
    CheckFont(Pause_MainMenu_ClockFont)
    CheckFont(Pause_MainMenu_LabelFont)
    CheckFont(Pause_MainMenu_Info_Font)
    CheckFont(Pause_MainMenu_Info_Description_Font)
    CheckFont(Pause_SubMenu_LabelFont)
    CheckFont(Pause_SubMenu_Font)
    CheckFont(Pause_SubMenu_HelpFont)
    CheckFont(Pause_AuxiliarScreen_Font)
    ; Saving values to ini file
    RIni_Write("P",Pause_GlobalFile,"`r`n",1,1,1)
    RIni_Write("P_sys",Pause_SystemFile,"`r`n",1,1,1)
    ;logging all Pause Vars
    RLLog.Debug(A_ThisLabel . " - Pause variables values: " . PauseVarLog)
Return

RIniPauseLoadVar(gRIniVar,sRIniVar,section,key,gdefaultvalue:="",sdefaultvalue:="use_global",preferDefault:="") {
    Global
    value :=  RIniLoadVar(gRIniVar,sRIniVar,section,key,gdefaultvalue,sdefaultvalue,preferDefault)
    PauseVarLog .= "`r`n`t`t`t`t`t" . "[" . section . "] " . key . " = " . value
	Return value
}  

PauseOptionsScale(){
	global
    ; HardCoded Parameters
    OptionScale(Pause_SubMenu_Pen_Width, Pause_XScale)
    OptionScale(Pause_Logo_Image_Margin, Pause_XScale)
    OptionScale(Pause_MainMenu_Info_Margin, Pause_XScale)
    OptionScale(Pause_Controller_Profiles_Margin, Pause_XScale)
    OptionScale(Pause_Controller_Profiles_First_Column_Width, Pause_XScale)
    OptionScale(Pause_Controller_Joy_Selected_Grow_Size, Pause_XScale)
    OptionScale(Pause_Settings_Margin, Pause_XScale)
    OptionScale(Pause_Sound_MarginBetweenButtons, Pause_XScale)
    OptionScale(Pause_Sound_Buttons_Grow_Size, Pause_XScale)
    OptionScale(Pause_Sound_Mute_Margin, Pause_XScale)
    OptionScale(Pause_Sound_InGameMusic_Margin, Pause_XScale)
    OptionScale(Pause_Statistics_Middle_Column_Offset, Pause_XScale)
    OptionScale(Pause_Statistics_MarginBetweenTableColumns, Pause_XScale)
    OptionScale(Pause_ChangingDisc_GrowSize, Pause_XScale)
    OptionScale(Pause_ChangingDisc_Rounded_Corner, Pause_XScale)
	OptionScale(Pause_ChangingDisc_Margin, Pause_XScale)
	OptionScale(Pause_Video_Buttons_Grow_Size, Pause_XScale)
    OptionScale(Pause_VTextDisplacementAdjust, Pause_YScale)
    OptionScale(Pause_7zProgress_BarW, Pause_XScale)
    OptionScale(Pause_7zProgress_BarH, Pause_YScale)
    OptionScale(Pause_7zProgress_BarBackgroundMargin, Pause_XScale)
    OptionScale(Pause_7zProgress_BarBackgroundRadius, Pause_XScale)
    OptionScale(Pause_7zProgress_BarR, Pause_XScale)
    OptionScale(Pause_7zProgress_BarText1FontSize, Pause_YScale)
    OptionScale(Pause_7zProgress_BarText2FontSize, Pause_YScale)
    OptionScale(Pause_7zProgress_Text_Offset, Pause_YScale)
    ; Ini Loaded Parameters
    OptionScale(Pause_MainMenu_ClockFontSize, Pause_YScale)
    OptionScale(Pause_MainMenu_LabelFontsize, Pause_YScale)
    OptionScale(Pause_MainMenu_HdistBetwLabels, Pause_XScale)
    OptionScale(Pause_MainMenu_BarHeight, Pause_YScale)
    OptionScale(Pause_MainMenu_Info_FontSize, Pause_YScale)
    OptionScale(Pause_MainMenu_Info_Description_FontSize, Pause_YScale)
    OptionScale(Pause_MainMenu_DescriptionScrollingVelocity, Pause_XScale)
    OptionScale(Pause_SubMenu_AdditionalTextMarginContour, Pause_XScale)
    OptionScale(Pause_SubMenu_MinimumTextBoxWidth, Pause_XScale)
    OptionScale(Pause_SubMenu_TopRightChamfer, Pause_XScale)
    OptionScale(Pause_SubMenu_Width, Pause_XScale)
    OptionScale(Pause_SubMenu_Height, Pause_YScale)
    OptionScale(Pause_SubMenu_LabelFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_FontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_SmallFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_HelpFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_HelpBottomMargin, Pause_YScale)
    OptionScale(Pause_SubMenu_HelpRightMargin, Pause_XScale)
    OptionScale(Pause_SubMenu_RadiusofRoundedCorners, Pause_XScale)
    OptionScale(Pause_SubMenu_FullScreenMargin, Pause_XScale)
    OptionScale(Pause_SubMenu_FullScreenRadiusofRoundedCorners, Pause_XScale)
    OptionScale(Pause_SubMenu_FullScreenFontSize, Pause_YScale)
    OptionScale(Pause_State_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_State_HMargin, Pause_XScale)
    OptionScale(Pause_State_VMargin, Pause_YScale)
    OptionScale(Pause_Settings_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_Settings_HMargin, Pause_XScale)
    OptionScale(Pause_Settings_VMargin, Pause_YScale)
    OptionScale(Pause_Settings_OptionFontSize, Pause_YScale)
    OptionScale(Pause_SoundBar_SingleBarWidth, Pause_XScale)
    OptionScale(Pause_SoundBar_SingleBarSpacing, Pause_XScale)
    OptionScale(Pause_SoundBar_SingleBarHeight, Pause_YScale)
    OptionScale(Pause_SoundBar_HeightDifferenceBetweenBars, Pause_YScale)
    OptionScale(Pause_SubMenu_SoundMuteButtonFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_SoundMuteButtonVDist, Pause_YScale)
    OptionScale(Pause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap, Pause_XScale)
    OptionScale(Pause_SubMenu_SoundDisttoSoundLevel, Pause_XScale)
    OptionScale(Pause_SubMenu_SpaceBetweenMusicPlayerButtons, Pause_XScale)
    OptionScale(Pause_SubMenu_SizeofMusicPlayerButtons, Pause_XScale)
    OptionScale(Pause_SubMenu_MusicPlayerVDist, Pause_YScale)
    OptionScale(Pause_ChangeDisc_VMargin, Pause_YScale)
    OptionScale(Pause_ChangeDisc_TextDisttoImage, Pause_YScale)
    OptionScale(Pause_SubMenu_HighScoreFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_HighScoreTitleFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_HighScore_SuperiorMargin, Pause_YScale)
    OptionScale(Pause_SubMenu_HighScoreFullScreenWidth, Pause_XScale)
    OptionScale(Pause_MovesList_VMargin, Pause_YScale)
    OptionScale(Pause_MovesList_HMargin, Pause_XScale)
    OptionScale(Pause_MovesList_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_MovesList_HdistBetwLabelsandMovesList, Pause_XScale)
    OptionScale(Pause_MovesList_VdistBetwMovesListLabels, Pause_YScale)
    OptionScale(Pause_MovesList_SecondaryFontSize, Pause_YScale)
    OptionScale(Pause_MovesList_VImageSize, Pause_YScale)
    OptionScale(Pause_SubMenu_MovesListFullScreenWidth, Pause_XScale)
    OptionScale(Pause_MovesList_HFullScreenMovesMargin, Pause_XScale)
    OptionScale(Pause_Statistics_VMargin, Pause_YScale)
    OptionScale(Pause_Statistics_HMargin, Pause_XScale)
    OptionScale(Pause_Statistics_TableFontSize, Pause_YScale)
    OptionScale(Pause_Statistics_DistBetweenLabelsandTable, Pause_XScale)
    OptionScale(Pause_Statistics_VdistBetwTableLines, Pause_YScale)
    OptionScale(Pause_Statistics_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_Statistics_TitleFontSize, Pause_YScale)
    OptionScale(Pause_SubMenu_StatisticsFullScreenWidth, Pause_XScale)
    OptionScale(Pause_Guides_VMargin, Pause_YScale)
    OptionScale(Pause_Guides_HMargin, Pause_XScale)
    OptionScale(Pause_Guides_HdistBetwPages, Pause_XScale)
    OptionScale(Pause_Guides_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_Guides_HdistBetwLabelsandPages, Pause_XScale)
    OptionScale(Pause_Manuals_VMargin, Pause_YScale)
    OptionScale(Pause_Manuals_HMargin, Pause_XScale)
    OptionScale(Pause_Manuals_HdistBetwPages, Pause_XScale)
    OptionScale(Pause_Manuals_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_Manuals_HdistBetwLabelsandPages, Pause_XScale)
    OptionScale(Pause_History_VMargin, Pause_YScale)
    OptionScale(Pause_History_HMargin, Pause_XScale)
    OptionScale(Pause_History_HdistBetwPages, Pause_XScale)
    OptionScale(Pause_History_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_History_HdistBetwLabelsandPages, Pause_XScale)
    OptionScale(Pause_Controller_VMargin, Pause_YScale)
    OptionScale(Pause_Controller_HMargin, Pause_XScale)
    OptionScale(Pause_Controller_HdistBetwPages, Pause_XScale)
    OptionScale(Pause_Controller_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_Controller_HdistBetwLabelsandPages, Pause_XScale)
    OptionScale(Pause_ControllerBannerHeight, Pause_YScale)
    OptionScale(Pause_vDistanceBetweenButtons, Pause_YScale)
    OptionScale(Pause_vDistanceBetweenBanners, Pause_YScale)
    OptionScale(Pause_hDistanceBetweenControllerBannerElements, Pause_XScale)
    OptionScale(Pause_selectedControllerBannerDisplacement, Pause_XScale)
    OptionScale(Pause_Artwork_VMargin, Pause_YScale)
    OptionScale(Pause_Artwork_HMargin, Pause_XScale)
    OptionScale(Pause_Artwork_HdistBetwPages, Pause_XScale)
    OptionScale(Pause_Artwork_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_Artwork_HdistBetwLabelsandPages, Pause_XScale)
    OptionScale(Pause_Videos_VMargin, Pause_YScale)
    OptionScale(Pause_Videos_HMargin, Pause_XScale)
    OptionScale(Pause_Videos_VdistBetwLabels, Pause_YScale)
    OptionScale(Pause_SubMenu_SizeofVideoButtons, Pause_XScale)
    OptionScale(Pause_SubMenu_SpaceBetweenVideoButtons, Pause_YScale)
    OptionScale(Pause_SubMenu_SpaceBetweenLabelsandVideoButtons, Pause_XScale)
    OptionScale(Pause_AuxiliarScreen_FontSize, Pause_YScale)
    OptionScale(Pause_AuxiliarScreen_ExitTextMargin, Pause_XScale)
Return	
}  

;-----------------SOUND CONTROL FUNCTIONS------------
;Draw the colored progress bars.
DrawSoundFullProgress(G, X, Y, W, H, color1, color2) {
   PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W-5, H, color1, color2)
   Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W, H, 3)
   PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W//2, H, 0xAAFFFFFF, 0x11FFFFFF)
   Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W//2, H, 3)
   PPEN := Gdip_CreatePen(0x22000000, 1)
   Gdip_Alt_DrawRoundedRectangle(G, PPEN, X-W, Y-H, W, H, 3)
}

;Draw the blank progress bars.
DrawSoundEmptyProgress(G, X, Y, W, H) {
    PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W-5, H, 0xFF8E8F8E, 0xFF565756)
    Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W, H, 3)
    PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W//2, H, 0xAAFFFFFF, 0x11FFFFFF)
    Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W//2, H, 3)
    PPEN := Gdip_CreatePen(0x22000000, 1)
    Gdip_Alt_DrawRoundedRectangle(G, PPEN, X-W, Y-H, W, H, 3)
}

;Main Menu Clock
Clock:
    Gdip_GraphicsClear(Pause_G28)
    FormatTime, CurrentTime, %A_Now%, dddd MMMM d, yyyy hh:mm:ss tt
    CurrentTimeTextLenghtWidth := MeasureText(CurrentTime, "Left r4 s" . Pause_MainMenu_ClockFontSize . " Regular",Pause_MainMenu_ClockFont)
    pGraphUpd(Pause_G28,CurrentTimeTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_MainMenu_ClockFontSize)
    posCurrentTimeX := CurrentTimeTextLenghtWidth + Pause_SubMenu_AdditionalTextMarginContour
    OptionsCurrentTime = x%posCurrentTimeX% y0 Right c%Pause_MainMenu_LabelDisabledColor% r4 s%Pause_MainMenu_ClockFontSize% Regular
    Gdip_Alt_FillRectangle(Pause_G28, Pause_SubMenu_DisabledBrushV, 0, 0, CurrentTimeTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour, Pause_MainMenu_ClockFontSize)
    Gdip_Alt_TextToGraphics(Pause_G28, CurrentTime, OptionsCurrentTime, Pause_MainMenu_ClockFont, 0, 0)
    Alt_UpdateLayeredWindow(Pause_hwnd28, Pause_hdc28,baseScreenWidth - CurrentTimeTextLenghtWidth - 2*Pause_SubMenu_AdditionalTextMarginContour,0,CurrentTimeTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_MainMenu_ClockFontSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
Return 

;-----------------MUSIC PLAYER------------
Pause_MusicPlayer:
    If (Pause_Loaded <> 1){
        try wmpMusic := ComObjCreate("WMPlayer.OCX")
        catch e
            RLLog.Debug(A_ThisLabel . " - A Windows Media Player Music exception was thrown: " . e)
        try ComObjConnect(wmpMusic, "wmpMusic_")
        catch e
            RLLog.Debug(A_ThisLabel . " - A Windows Media Player Music exception was thrown: " . e)
        try wmpMusic.settings.enableErrorDialogs := false
        ;loading music player paths
		If Pause_ExternalPlaylistPath
			If (FileExist(Pause_ExternalPlaylistPath))
				Pause_CurrentPlaylist := Pause_ExternalPlaylistPath            
        If !Pause_CurrentPlaylist
            Loop, % Pause_MusicPath . "\" . systemName . "\" . dbName . "\*." . Pause_PlaylistExtension, 0
                Pause_CurrentPlaylist := A_LoopFileFullPath
        If !Pause_CurrentPlaylist {
            Loop, % Pause_MusicPath . "\" . systemName . "\" . dbName . "\*.*", 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %Pause_MusicPath%\%systemName%\%dbName%\                        
                    FileAppend, %CurrentMusicfile%`r`n, %Pause_MusicPath%\%systemName%\%dbName%\%dbName%.m3u
                }
            If (FileExist(Pause_MusicPath . "\" . systemName . "\"  . dbName . "\" . dbName . ".m3u")) {
                Pause_PlaylistExtension := "m3u"
                Pause_CurrentPlaylist := Pause_MusicPath . "\" . systemName . "\"  . dbName . "\" . dbName . ".m3u"
            }
        }
        If !Pause_CurrentPlaylist
            Loop, % Pause_MusicPath . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\*." . Pause_PlaylistExtension, 0
                Pause_CurrentPlaylist := A_LoopFileFullPath
        If !Pause_CurrentPlaylist {
            Loop, % Pause_MusicPath . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\*.*", 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %Pause_MusicPath%\%systemName%\%DescriptionNameWithoutDisc%\                        
                    FileAppend, %CurrentMusicfile%`r`n, %Pause_MusicPath%\%systemName%\%DescriptionNameWithoutDisc%\%dbName%.m3u
                }
            If (FileExist(Pause_MusicPath . "\" . systemName . "\"  . DescriptionNameWithoutDisc . "\" . dbName . ".m3u")) {
                Pause_PlaylistExtension := "m3u"
                Pause_CurrentPlaylist := Pause_MusicPath . "\" . systemName . "\"  . DescriptionNameWithoutDisc . "\" . dbName . ".m3u"
            }
        }
        If !Pause_CurrentPlaylist
            Loop, % Pause_MusicPath . "\" . systemName . "\_Default\*." . Pause_PlaylistExtension, 0
                Pause_CurrentPlaylist := A_LoopFileFullPath
        If !Pause_CurrentPlaylist {
            Loop, % Pause_MusicPath . "\" . systemName . "\_Default\*.*", 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %Pause_MusicPath%%systemName%\_Default\                        
                    FileAppend, %CurrentMusicfile%`r`n, %Pause_MusicPath%%systemName%\_Default\default.m3u
                }
            If (FileExist(Pause_MusicPath . "\" . systemName . "\_Default\default.m3u")) {
                Pause_PlaylistExtension := "m3u"
                Pause_CurrentPlaylist := Pause_MusicPath . systemName . "\_Default\default.m3u"
            }
        }
        If !Pause_CurrentPlaylist
            Loop, % Pause_MusicPath . "\_Default\*." . Pause_PlaylistExtension, 0
                Pause_CurrentPlaylist := A_LoopFileFullPath
        If !Pause_CurrentPlaylist {
            Loop, % Pause_MusicPath . "\_Default\*.*", 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %Pause_MusicPath%_Default\                        
                    FileAppend, %CurrentMusicfile%`r`n, %Pause_MusicPath%_Default\default.m3u
                }
            If (FileExist(Pause_MusicPath . "\_Default\default.m3u")) {
                Pause_PlaylistExtension := "m3u"
                Pause_CurrentPlaylist := Pause_MusicPath . "\_Default\default.m3u"
            }
        }
        ;loading music player songs
        try wmpMusic.settings.volume := Pause_MusicPlayerVolumeLevel
        try wmpMusic.settings.autoStart := false
        try wmpMusic.Settings.setMode("shuffle",false)
        If (Pause_EnableMusicOnStartup = "true") and (PauseInitialMuteState<>1)
            try wmpMusic.settings.autoStart := true
        try wmpMusic.uimode := "invisible"
        If (Pause_EnableLoop="true")
            try wmpMusic.Settings.setMode("Loop",true)
        If (Pause_EnableShuffle="true")
            try wmpMusic.Settings.setMode("shuffle",true)
        try wmpMusic.Url := Pause_CurrentPlaylist
        If (Pause_CurrentPlaylist<>""){
            ;musicPlayerImages
            PauseMusicImage1 := Pause_IconsImagePath . "\MusicPlayerStop.png"
            PauseMusicImage2 := Pause_IconsImagePath . "\MusicPlayerPrevious.png"
            PauseMusicImage3 := Pause_IconsImagePath . "\MusicPlayerPlay.png"
            PauseMusicImage4 := Pause_IconsImagePath . "\MusicPlayerNext.png"
            PauseMusicImage5 := Pause_IconsImagePath . "\MusicPlayerPause.png"
        }
        If not wmpVersion {
            try wmpVersion := wmpMusic.versionInfo
            RLLog.Debug(A_ThisLabel . " - Windows Media Player Version: " . wmpVersion)
        }
    } Else {
        try CurrentMusicPlayStatus := wmpMusic.playState
        If (Pause_EnableMusicOnStartup = "true")
            If (CurrentMusicPlayStatus=2)
                try wmpMusic.controls.play
    }
Return


UpdateMusicPlayingInfo:
    If (UpdateMusicPlayingInfoRunning)
        return
    UpdateMusicPlayingInfoRunning := true
    If (SelectedMenuOption="Sound"){
        Gdip_GraphicsClear(Pause_G33)
        pGraphUpd(Pause_G33,Pause_SubMenu_Width,Pause_SubMenu_Height)
        Gdip_GraphicsClear(Pause_G34)
        pGraphUpd(Pause_G34,Pause_SubMenu_Width,Pause_SubMenu_Height)
        MusicPlayerTextX := round((Pause_SubMenu_Width)/2) 
        MusicPlayerTextY := posSoundBarTextY+SoundBarHeight+Pause_SubMenu_SoundMuteButtonVDist+Pause_SubMenu_SoundMuteButtonFontSize+Pause_SubMenu_MusicPlayerVDist + Pause_SubMenu_SizeofMusicPlayerButtons + Pause_SubMenu_SmallFontSize
        OptionsMusicPlayerText = x%MusicPlayerTextX% y%MusicPlayerTextY% Center c%Pause_MainMenu_LabelDisabledColor% r4 s%Pause_SubMenu_SmallFontSize% bold
        try CurrentMusicPlayStatus := wmpMusic.playState
        try CurrentMusicPositionString := wmpMusic.controls.currentPositionString
        try CurrentMusicStatusDescription := wmpMusic.status
        try CurrentMusicDurationString := wmpMusic.currentMedia.durationString
        If ((CurrentMusicPositionString<>"") and ((CurrentMusicPlayStatus=2) or (CurrentMusicPlayStatus=3))) {
            Gdip_Alt_TextToGraphics(Pause_G34, CurrentMusicStatusDescription . " - " . CurrentMusicPositionString . " (" . CurrentMusicDurationString . ")", OptionsMusicPlayerText, Pause_SubMenu_Font, 0, 0)
            Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, baseScreenWidth - Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height,Pause_SubMenu_Width,Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
        If(VSubMenuItem=0){
            Gdip_GraphicsClear(Pause_G33)     
            Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        } Else {
            If(VSubMenuItem = 1){
                HelpText := "Press Left or Right to Change the Volume Level"
            }
            If(VSubMenuItem = 2) and (HSubmenuitemSoundVSubmenuitem2=1){
                HelpText := "Press Select to Change Mute Status"
            }
            If(VSubMenuItem = 2) and (HSubmenuitemSoundVSubmenuitem2=2){
                HelpText := "Press Select to Enable Music While Playing the Game"
            }
            If(VSubMenuItem = 3){
                HelpText := "Press Select to Choose Music Control Option"
            }
            HelpTextLenghtWidth := MeasureText(HelpText, "Left r4 s" . Pause_SubMenu_HelpFontSize . " Regular",Pause_SubMenu_HelpFont)
            posHelpX := round(HelpTextLenghtWidth/2 + Pause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y0 Center c%Pause_MainMenu_LabelDisabledColor% r4 s%Pause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(Pause_G33, Pause_SubMenu_DisabledBrushV, 0, 0, HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour, Pause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(Pause_G33, HelpText, OptionsHelp, Pause_SubMenu_HelpFont, 0, 0)
            Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, baseScreenWidth - HelpTextLenghtWidth - 2*Pause_SubMenu_AdditionalTextMarginContour - Pause_SubMenu_HelpRightMargin,baseScreenHeight- Pause_SubMenu_HelpFontSize - Pause_SubMenu_HelpBottomMargin,HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_HelpFontSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    } Else {
        Gdip_GraphicsClear(Pause_G33)     
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G34) 
        Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    }
    UpdateMusicPlayingInfoRunning := false
Return


UpdateVideoPlayingInfo:
    If (UpdateVideoPlayingInfoRunning)
        return
    UpdateVideoPlayingInfoRunning := true
    If (SelectedMenuOption="Videos") and (VSubMenuItem <> 0){
        Gdip_GraphicsClear(Pause_G33)
        pGraphUpd(Pause_G33,Pause_SubMenu_Width,Pause_SubMenu_Height)
        Gdip_GraphicsClear(Pause_G34)
        pGraphUpd(Pause_G34,Pause_SubMenu_Width,Pause_SubMenu_Height)
        VideoPlayerTextX := (2*Pause_Videos_HMargin + PauseMediaObj["Videos"].maxLabelSize + 2*Pause_SubMenu_AdditionalTextMarginContour) + (Pause_SubMenu_Width - (2*Pause_Videos_HMargin+PauseMediaObj["Videos"].maxLabelSize+2*Pause_SubMenu_AdditionalTextMarginContour)) // 2 
        VideoPlayerTextY := Pause_SubMenu_SmallFontSize // 2
        OptionsVideoPlayerText = x%VideoPlayerTextX% y%VideoPlayerTextY% Center c%Pause_MainMenu_LabelDisabledColor% r4 s%Pause_SubMenu_SmallFontSize% bold
        try CurrentVideoPlayStatus := wmpVideo.playState
        try CurrentVideoPositionString := wmpVideo.controls.currentPositionString
        try CurrentVideoStatusDescription := wmpVideo.status
        try CurrentVideoDurationString := wmpVideo.currentMedia.durationString
        If ((CurrentVideoPositionString<>"") and ((CurrentVideoPlayStatus=2) or (CurrentVideoPlayStatus=3))){
            Gdip_Alt_TextToGraphics(Pause_G34, CurrentVideoStatusDescription . " - " . CurrentVideoPositionString . " (" . CurrentVideoDurationString . ")", OptionsVideoPlayerText, Pause_SubMenu_Font, 0, 0)
            Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, baseScreenWidth - Pause_SubMenu_Width,baseScreenHeight-Pause_SubMenu_Height,Pause_SubMenu_Width,Pause_SubMenu_Height,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
        If(VSubMenuItem=0){
            Gdip_GraphicsClear(Pause_G33)     
            Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        } Else {
            If(HSubMenuItem = 1){
                VideoHelpText := "Press Up or Down to Select the Video and Left or Right to Control the Video Playing"
            } Else If(HSubMenuItem = 2) {
                If (V2SubMenuItem=1){
                    If(CurrentVideoPlayStatus=3) {               
                        VideoHelpText := "Press Select to Pause Video Playing"
                    } Else {
                        VideoHelpText := "Press Select to Resume Playing Video"
                    }
                } Else If (V2SubMenuItem=2) {
                    VideoHelpText := "Press Select to go to Full Screen"
                } Else If (V2SubMenuItem=3) {
                    VideoHelpText := "Press Select to Rewind the Video " . Pause_SubMenu_VideoRewindFastForwardJumpSeconds " seconds"
                } Else If (V2SubMenuItem=4) {
                    VideoHelpText := "Press Select to Fast Forward " . Pause_SubMenu_VideoRewindFastForwardJumpSeconds " seconds"
                } Else If (V2SubMenuItem=5) {
                    VideoHelpText := "Press Select to Stop Video"
                }
            }
            HelpTextLenghtWidth := MeasureText(VideoHelpText, "Left r4 s" . Pause_SubMenu_HelpFontSize . " Regular",Pause_SubMenu_HelpFont)
            posHelpX := round(HelpTextLenghtWidth/2 + Pause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y0 Center c%Pause_MainMenu_LabelDisabledColor% r4 s%Pause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(Pause_G33, Pause_SubMenu_DisabledBrushV, 0, 0, HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour, Pause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(Pause_G33, VideoHelpText, OptionsHelp, Pause_SubMenu_HelpFont, 0, 0)
            Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, baseScreenWidth - HelpTextLenghtWidth - 2*Pause_SubMenu_AdditionalTextMarginContour - Pause_SubMenu_HelpRightMargin,baseScreenHeight- Pause_SubMenu_HelpFontSize - Pause_SubMenu_HelpBottomMargin,HelpTextLenghtWidth+2*Pause_SubMenu_AdditionalTextMarginContour,Pause_SubMenu_HelpFontSize,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        }
    } Else {
        Gdip_GraphicsClear(Pause_G33)   
        Alt_UpdateLayeredWindow(Pause_hwnd33, Pause_hdc33, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
        Gdip_GraphicsClear(Pause_G34)   
        Alt_UpdateLayeredWindow(Pause_hwnd34, Pause_hdc34, 0,0,baseScreenWidth,baseScreenHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle) 
    }
    UpdateVideoPlayingInfoRunning := false
Return

  
SaveScreenshot:
    CoordMode, ToolTip
    ToolTip
    Pause_SaveScreenshotPath := RLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots\"
        If !FileExist(Pause_SaveScreenshotPath)
            FileCreateDir, %Pause_SaveScreenshotPath%
    if !Pause_Screenshot_Extension
        {
        ; Loading Pause ini keys 
        Pause_GlobalFile := A_ScriptDir . "\Settings\Global Pause.ini" 
        Pause_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\Pause.ini" 
        If (RIni_Read("P",Pause_GlobalFile) = -11) {
            RLLog.Debug(A_ThisLabel . " - Global Pause.ini file not found, creating a new one.")
            RIni_Create("P")
        }
        If (RIni_Read("P_sys",Pause_SystemFile) = -11) {
            IfNotExist, % A_ScriptDir . "\Settings\" . systemName
                FileCreateDir, % A_ScriptDir . "\Settings\" . systemName
            RLLog.Debug(A_ThisLabel . " - " . A_ScriptDir . "\Settings\" . systemName . "\Pause.ini file not found, creating a new one.")
            RIni_Create("P_sys")
        }
        Pause_Screenshot_Extension := RIniPauseLoadVar("P","P_sys", "General Options", "Screenshot_Extension", "jpg") ;Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
        Pause_Screenshot_JPG_Quality := RIniPauseLoadVar("P","P_sys", "General Options", "Screenshot_JPG_Quality", "100") ;If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
    }
    CurrentScreenshotFileName := A_Now . "." . Pause_Screenshot_Extension
    pToken := Gdip_Startup()
    CaptureScreen(Pause_SaveScreenshotPath . "\" . CurrentScreenshotFileName,  "0|0|" . A_ScreenWidth . "|" . A_ScreenHeight , Pause_Screenshot_JPG_Quality)
    ToolTip, Screenshot saved (%Pause_SaveScreenshotPath%\%CurrentScreenshotFileName%), 0,baseScreenHeight
    settimer,EndofToolTipDelay, -2000   
    If Pause_Loaded
        {
        If(Pause_ArtworkMenuEnabled="true"){
            ;reseting menu variables
            ArtworkList =
            Loop, % PauseMediaObj["Artwork"].TotalLabels 
                {
                FileCount := a_index
                ArtworkFileExtension%FileCount% =
                ArtworkFile%FileCount% =
                ArtworkCompressedFile%FileCount%Loaded =
                TotalSubMenuArtworkPages%FileCount% =
                Loop, % TotalSubMenuArtworkPages%FileCount%
                    {
                    %SubMenuName%File%FileCount%File%a_index% =
                }
                TotalSubMenuArtworkPages%FileCount% =
            }
            ;creating an Artwork object to show the new screenshot
            if !PauseMediaObj
                PauseMediaObj := []
            if PauseMediaObj["Artwork"].Screenshots.Label
                {
                currentobj := PauseMediaObj["Artwork"].Screenshots
                currentobj["TotalItems"] := currentobj.TotalItems+1
                currentobj["Type"] := "ImageGroup"
            } else {
                if PauseMediaObj["Artwork"].TotalLabels
                {
                    currentobj := {}
                    currentobj["Label"] := "Screenshots"
                    currentobj["TotalItems"] := 1
                    PauseMediaObj["Artwork"].TotalLabels := PauseMediaObj["Artwork"].TotalLabels+1
                    PauseMediaObj["Artwork"][PauseMediaObj["Artwork"].TotalLabels] := currentobj["Label"]
                }
            }
            currentobj["Path" . currentobj.TotalItems] := Pause_SaveScreenshotPath . "\" . CurrentScreenshotFileName
            currentobj["Ext" . currentobj.TotalItems] := Pause_Screenshot_Extension
            PauseMediaObj["Artwork"].Insert(currentobj["Label"], currentobj)
            ;updating artwork menu If active
            If Pause_Running
                If(SelectedMenuOption="Artwork")
                    gosub, DrawSubMenu
            If Pause_MainMenu_Itens not contains Artwork
                {
                Pause_MainMenu_Itens .= "|Artwork" 
                TotalMainMenuItems++
                Gdip_GraphicsClear(Pause_G25)
                Gosub DrawMainMenuBar
                Alt_UpdateLayeredWindow(Pause_hwnd25, Pause_hdc25,0,round((baseScreenHeight-Pause_MainMenu_BarHeight)/2)+Pause_MainMenu_BarVerticalOffset, baseScreenWidth, Pause_MainMenu_BarHeight,,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
            }
        }
    }
Return

CaptureScreen(fileName,screen,quality:=100)
{
    Global
    raster := 0x40000000 + 0x00CC0020
    screenBitmapPointer := Gdip_BitmapFromScreen(screen,raster)
    Gdip_SaveBitmapToFile(screenBitmapPointer, fileName, quality)
    Gdip_DisposeImage(screenBitmapPointer)
    return
}

EndofToolTipDelay:
	ToolTip
Return


;Mouse Control
pauseMouseClick:
    submenuMouseClickChange := 1
    Gdip_GraphicsClear(Pause_G32)
    If (FullScreenView = 1)
        Gdip_Alt_DrawImage(Pause_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
    Else
        Gdip_Alt_DrawImage(Pause_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)	
    If(Pause_MouseClickSound = "true") {
        Random, MouseRndmSound, 1, % MouseSoundsAr.MaxIndex()
        MouseRndmSoundPath := Pause_MouseSoundPath . "\" . MouseSoundsAr[MouseRndmSound]
        RLLog.Debug(A_ThisLabel . " - Selected Mouse Click Sound: " . MouseRndmSoundPath)
    }
    CoordMode, Mouse, Screen 
    MouseGetPos, ClickX, ClickY
    if (pauseScreenRotationAngle=0) {
        ClickY := ClickY - (monitorTable[pauseMonitor].Height-MouseOverlayH)
    } else if (pauseScreenRotationAngle=90) {
        Gdip_Alt_GetRotatedDimensions(ClickX, ClickY, pauseScreenRotationAngle, ClickX, ClickY)
        ClickY := MouseOverlayH - ClickY
    } else if (pauseScreenRotationAngle=180){
        ClickX := ClickX - (monitorTable[pauseMonitor].Width - MouseOverlayW)
        ClickX := MouseOverlayW - ClickX
        ClickY := MouseOverlayH - ClickY
    } else if (pauseScreenRotationAngle=270) {
        ClickX := ClickX - (monitorTable[pauseMonitor].Width - MouseOverlayH)
        ClickY := ClickY - (monitorTable[pauseMonitor].Height-MouseOverlayW)
        X := ClickY
        ClickY := ClickX
        ClickX := MouseOverlayW - X
    } 
    if (ClickX>MouseOverlayW) or (ClickY>MouseOverlayH)
        Return        
    If (FullScreenView = 1)
        MouseMaskColor := Gdip_GetPixel( MouseFullScreenMaskBitmap, ClickX, ClickY)
    Else
        MouseMaskColor := Gdip_GetPixel( MouseMaskBitmap, ClickX, ClickY)	
    SetFormat Integer, Hex
    MouseMaskColor += 0
    SetFormat Integer, D
    If (MouseMaskColor=0xFFFF0000) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseRndmSound
            SoundPlay, %MouseRndmSoundPath%, Wait
        gosub, MoveUp
    } Else If (MouseMaskColor=0xFF00FFFF) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, MoveRight
    } Else If (MouseMaskColor=0xFF0000FF) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, MoveDown
    } Else If (MouseMaskColor=0xFF00FF00) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, MoveLeft
    } Else If (MouseMaskColor=0xFFFF00FF) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, ToggleItemSelectStatus
    } Else If (MouseMaskColor=0xFFFFFF00) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, TogglePauseMenuStatus
    } Else If (MouseMaskColor=0xFFFF6400) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, BacktoMenuBar
    } Else If (MouseMaskColor=0xFF00FF64) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, SaveScreenshot
    } Else If (MouseMaskColor=0xFF6400FF) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, ZoomIn
    } Else If (MouseMaskColor=0xFF0064FF) {
        Gdip_Alt_DrawImage(Pause_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, ZoomOut
    }
    Alt_UpdateLayeredWindow(Pause_hwnd32, Pause_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,Pause_MouseControlTransparency,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)
    settimer, ClearMouseClickImages, -500
Return


ClearMouseClickImages:
    Gdip_GraphicsClear(Pause_G32)
    If (FullScreenView = 1)
        Gdip_Alt_DrawImage(Pause_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
    Else
        Gdip_Alt_DrawImage(Pause_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)	
    Alt_UpdateLayeredWindow(Pause_hwnd32, Pause_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,Pause_MouseControlTransparency,monitorTable[pauseMonitor].Left,monitorTable[pauseMonitor].Top,pauseScreenRotationAngle)        
Return


; Windows Media Player Error handling (NOT WORKING)
wmpVideo_Error(wmpVideo) {
	Global RLLog
    try max := wmpVideo.error.errorCount
    try ErrorDescription := wmpVideo.error.item(max-1).errorDescription
    RLLog.Debug(A_ThisLabel . " - A Windows Media Player Video exception was thrown: " . ErrorDescription)
Return
} 

wmpMusic_Error(wmpMusic) {
	Global RLLog
    try max := wmpMusic.error.errorCount
    try ErrorDescription := wmpMusic.error.item(max-1).errorDescription
    RLLog.Debug(A_ThisLabel . " - A Windows Media Player Music exception was thrown: " . ErrorDescription)
Return
} 

    
loadingText(message) ;dynamic loading text
    {
    Global
    Pause_LoadingMessage_Font := "Bebas Neue"
    Pause_LoadingMessage_FontSize := "20"
    Pause_LoadingMessage_FontColor := "ff222222"
    OptionScale(Pause_LoadingMessage_FontSize, Pause_Load_YScale)
    Gdip_GraphicsClear(Pause_G21b)
    messageLenghtWidth := MeasureText(message, "Left r4 s" . Pause_LoadingMessage_FontSize . " Regular",Pause_LoadingMessage_Font)
    pGraphUpd(Pause_G21b,messageLenghtWidth, Pause_LoadingMessage_FontSize)
    ;pGraphUpd(Pause_G21b,loadBaseScreenWidth,loadBaseScreenHeight)
    messageTextOptions = x0 y0 Left c%Pause_LoadingMessage_FontColor% r4 s%Pause_LoadingMessage_FontSize% Regular
    Gdip_Alt_TextToGraphics(Pause_G21b, message, messageTextOptions, Pause_LoadingMessage_Font, 0, 0,,loadXTranslation,loadYTranslation,loadBaseScreenWidth,loadBaseScreenHeight)
    Alt_UpdateLayeredWindow(Pause_hwnd21b, Pause_hdc21b, Pause_AuxiliarScreen_ExitTextMargin, loadBaseScreenHeight - Pause_AuxiliarScreen_ExitTextMargin//2 - Pause_LoadingMessage_FontSize//2,messageLenghtWidth,Pause_LoadingMessage_FontSize,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)
    
    
    /*
    x:=Pause_AuxiliarScreen_ExitTextMargin
    Y:=loadBaseScreenHeight - Pause_AuxiliarScreen_ExitTextMargin//2 - Pause_LoadingMessage_FontSize//2
    W:=messageLenghtWidth
    h:= Pause_LoadingMessage_FontSize
    WindowCoordUpdate(X,Y,W,H,screenRotationAngle,loadXTranslation,loadYTranslation)
    UpdateLayeredWindow(hwnd, hdc, X+monitorLeft, Y+monitorTop, W, H, Alpha)	
    */
    ;Alt_UpdateLayeredWindow(hwnd, hdc,X="", Y="",W="",H="",Alpha=255,monitorLeft=0,monitorTop=0,rotationAngle=0,xTransl=0,yTransl=0
    ;Alt_UpdateLayeredWindow(Pause_hwnd21b, Pause_hdc21b, Pause_AuxiliarScreen_ExitTextMargin, loadBaseScreenHeight - Pause_AuxiliarScreen_ExitTextMargin//2 - Pause_LoadingMessage_FontSize//2,messageLenghtWidth,Pause_LoadingMessage_FontSize,,0,0,screenRotationAngle,loadXTranslation,loadYTranslation)
    Return    
}
