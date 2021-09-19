MCRC := "AF761A46"
MVersion := "1.2.11"

BezelEnabled(){
	Global bezelEnabled,bezelPath
	If (bezelEnabled = "true" && bezelPath)
		Return 1
}

BezelGUI(){
	Global
	If (bezelEnabled := "true"){
		RLLog.Info(A_ThisFunc . " - Started")
		; creating GUi elements and pointers
		; Bezel_GUI1 - Black Background
		; Bezel_GUI2 - Background
		; Bezel_GUI3 - Shader
		; Bezel_GUI4 - Overlay
		; Bezel_GUI5 - Bezel Image
		; Bezel_GUI6 - Instruction Card
		; Bezel_GUI7 - Instruction Card Left Menu Background
		; Bezel_GUI8 - Instruction Card Left Menu List
		; Bezel_GUI9 - Instruction Card Right Menu Background
		; Bezel_GUI10 - Instruction Card Right Menu List
		Loop, 10 { 
			If (a_index = 1) {
				Gui, Bezel_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow 
			} Else {
				OwnerGUI := A_Index - 1
				if (a_index=2)
					Gui, Bezel_GUI%A_Index%: +OwnerBezel_GUI%OwnerGUI% +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow			
				else if (a_index=3) or (a_index=4)
					Gui, Bezel_GUI%A_Index%: +OwnerBezel_GUI%OwnerGUI% +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop +E0x20
				else
					Gui, Bezel_GUI%A_Index%: +OwnerBezel_GUI%OwnerGUI% +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
			}
			Gui, Bezel_GUI%A_Index%: Margin,0,0
			Gui, Bezel_GUI%A_Index%: Show,, BezelLayer%A_Index%
			Bezel_hwnd%A_Index% := WinExist()
		}
		RLLog.Info(A_ThisFunc . " - Ended")	
	}
}

BezelStart(Mode:="",parent:="",angle:="",rom:=""){
	Global
	If (bezelEnabled = "true"){
		RLLog.Info(A_ThisFunc . " - Started")
			;Defining Bezel Mode
		If !Mode
			bezelMode = Normal
		Else If (Mode = "fixResMode")
			bezelMode = fixResMode
		Else If (Mode = "layout")
			bezelLayoutFile = %rom%
		Else If RegExMatch(Mode, "^\d+$")
			bezelMode = MultiScreens	
		Else
			RLLog.Error(A_ThisFunc . " - Invalid Bezel mode defined on the module.")
		;Choosing to use layout files or normal bezel
		If bezelLayoutFile	
			{
			If !FileExist( emuPath . "\artwork\" . bezelLayoutFile . ".zip") and !FileExist( emuPath . "\artwork\" . parent . ".zip")
				{
				RLLog.Info(A_ThisFunc . " - Layout mode selected but no MAME or MESS layout file found. Using RocketLauncher Bezel normal mode instead.")
				bezelMode = Normal
				bezelLayoutFile =
			} Else {
				RLLog.Info(A_ThisFunc . " - MAME or MESS layout file (" . emuPath . "\artwork\" . bezelLayoutFile . ".zip" . " or " . emuPath . "\artwork\" . parent . ".zip" . ") already exists. Bezel addon will exit without doing any change to the emulator launch.")
				useBezels := " -use_bezels"
				Return
			}
		}
		RLLog.Debug(A_ThisFunc . " - Bezel mode " . bezelMode . " selected.")
		;Check for old modules error 
		IfWinNotExist, BezelLayer1
			ScriptError("You have an old incompatible module version.`n`r`n`rUpdate your modules before running RocketLauncher again!!!")
		; -------------- Read ini options and define default values
		Bezel_GlobalFile := A_ScriptDir . "\Settings\Global Bezel.ini" 
		Bezel_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\Bezel.ini" 
		Bezel_RomFile := A_ScriptDir . "\Settings\" . systemName . "\" . dbname . "\Bezel.ini" 
		If (RIni_Read("bezelGlobalRini",Bezel_GlobalFile) = -11)
			RIni_Create("bezelGlobalRini")
		If (RIni_Read("bezelSystemRini",Bezel_SystemFile) = -11)
			RIni_Create("bezelSystemRini")
		If (RIni_Read("BezelRomRini",Bezel_RomFile) = -11)
			RIni_Create("BezelRomRini")
		;[Settings]
		bezelMonitor := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Settings", "Game_Monitor","")
		bezelFileExtensions := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Settings", "Bezel_Supported_Image_Files","png|gif|tif|bmp|jpg")
		bezelDelay := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Settings", "Bezel_Delay","0")
		;[Bezel Change]
		bezelChangeDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Bezel Change", "Bezel_Transition_Duration","500")
		bezelSaveSelected := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini","Bezel Change","Bezel_Save_Selected","false")
		extraFullScreenBezel := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini","Bezel Change","Extra_FullScreen_Bezel","false") 
		;[Background]
		bezelBackgroundChangeDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Background_Change_Timer","0") ; 0 If disabled, number If you want the bezel background to change automatically at each x miliseconds
		bezelBackgroundTransition := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Background_Transition_Animation","fade") ; none or fade
		bezelBackgroundTransitionDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Background_Transition_Duration","500") ; determines the duration of fade bezel background transition
		bezelUseBackgrounds := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Use_Backgrounds","false") ; determines the duration of fade bezel background transition
		;[Bezel Change Keys]
		nextBezelKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Bezel Change Keys", "Next_Bezel_Key", "") 
		previousBezelKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Bezel Change Keys", "Previous_Bezel_Key","")
		If (bezelICEnabled = "true") {
			;[Instruction Cards General Settings]
			positionIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Positions","topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter") ; (1-8 positions) can be topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter
			animationIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Transition_Animation","fade") ; can be none, fade, slideIn, slideOutandIn
			ICChangeDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Transition_Duration","500")
			enableICChangeSound := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Enable_Transition_Sound","true") ; It searches for sound files named ICslideIn.mp3, ICslideOut.mp3, ICFadeOut.mp3, ICFadeIn.mp3 or ICChange.mp3 on the default global, default system and rom bezel folders to be played while changing the ICs
			ICScaleFactor := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Scale_Factor","ScreenHeight") ;you can choose between a number (1 to keep the original image size), or the words: ScreenHeight, ScreenWidth, HalfScreenHeight, HalfScreenWidth, OneThirdScreenHeight and OneThirdScreenWidth in order to resize the image in relation to the screen size. The default value is ScreenHeight that will work better in any resolution with a two ICs option (also the default one). 
			ICSaveSelected := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini","Instruction Cards General Settings","IC_Save_Selected","false")
			;[Instruction Cards Menu]
			leftMenuPositionsIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Left_Menu_Positions","topLeft|leftCenter|bottomLeft|bottomCenter") ; (1-8 positions) can be topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter
			ICleftMenuListItems := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Left_Menu_Number_of_List_Items","7")
			rightMenuPositionsIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Right_Menu_Positions","topRight|rightCenter|bottomRight|topCenter") ; (1-8 positions) can be topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter 
			ICrightMenuListItems := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Right_Menu_Number_of_List_Items","7")
			;[Instruction Cards Visibility]
			displayICOnStartup := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Visibility", "IC_Display_Card_on_Startup","false")  
			ICRandomSlideShowTimer := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Visibility", "IC_Random_Slide_Show_Timer","0")  
			toogleICVisibilityKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Visibility", "IC_Toggle_Visibility_Key","") 
			;[Instruction Cards Keys Change Mode 1]
			leftICMenuKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 1", "IC_Left_Menu_Key","")
			rightICMenuKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 1", "IC_Right_Menu_Key","")
			;[Instruction Cards Keys Change Mode 2]
			changeActiveICKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 2", "IC_Change_Active_Instruction_Card_Key","")
			previousICKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 2", "IC_Previous_Instruction_Card_Key","")
			nextICKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 2", "IC_Next_Instruction_Card_Key","")
			;[Instruction Cards Keys Change Mode 3]
			previousIC1Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_1_Previous_Key","")
			previousIC2Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_2_Previous_Key","")
			previousIC3Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_3_Previous_Key","")
			previousIC4Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_4_Previous_Key","")
			previousIC5Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_5_Previous_Key","")
			previousIC6Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_6_Previous_Key","")
			previousIC7Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_7_Previous_Key","")
			previousIC8Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_8_Previous_Key","")
			nextIC1Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_1_Next_Key","")
			nextIC2Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_2_Next_Key","")
			nextIC3Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_3_Next_Key","")
			nextIC4Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_4_Next_Key","")
			nextIC5Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_5_Next_Key","")
			nextIC6Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_6_Next_Key","")
			nextIC7Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_7_Next_Key","")
			nextIC8Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_8_Next_Key","")
		}
		; Saving values to ini file
		RIni_Write("bezelGlobalRini",Bezel_GlobalFile,"`r`n",1,1,1)
		IfNotExist, % A_ScriptDir . "\Settings\" . systemName 
			FileCreateDir, % A_ScriptDir . "\Settings\" . systemName 
		RIni_Write("bezelSystemRini",Bezel_SystemFile,"`r`n",1,1,1)
		;logging all Bezel Options
		RLLog.Trace(A_ThisFunc . " - Bezel variable values: " . BezelVarLog)
		; -------------- End of Read ini options and define default values
		;Adding the key modifier ~ to all bezel and IC keys
		nextBezelKey := if (nextBezelKey) ? xHotKeyVarEdit(nextBezelKey,"nextBezelKey","~","Add") : ""
		previousBezelKey := if (previousBezelKey) ? xHotKeyVarEdit(previousBezelKey,"previousBezelKey","~","Add") : ""
		leftICMenuKey := if (leftICMenuKey) ? xHotKeyVarEdit(leftICMenuKey,"leftICMenuKey","~","Add") : ""
		rightICMenuKey := if (rightICMenuKey) ? xHotKeyVarEdit(rightICMenuKey,"rightICMenuKey","~","Add") : ""
		changeActiveICKey := if (changeActiveICKey) ? xHotKeyVarEdit(changeActiveICKey,"changeActiveICKey","~","Add") : ""
		previousICKey := if (previousICKey) ? xHotKeyVarEdit(previousICKey,"previousICKey","~","Add") : ""
		nextICKey := if (nextICKey) ? xHotKeyVarEdit(nextICKey,"nextICKey","~","Add") : ""
		previousIC1Key := if (previousIC1Key) ? xHotKeyVarEdit(previousIC1Key,"previousIC1Key","~","Add") : ""
		previousIC2Key := if (previousIC2Key) ? xHotKeyVarEdit(previousIC2Key,"previousIC2Key","~","Add") : ""
		previousIC3Key := if (previousIC3Key) ? xHotKeyVarEdit(previousIC3Key,"previousIC3Key","~","Add") : ""
		previousIC4Key := if (previousIC4Key) ? xHotKeyVarEdit(previousIC4Key,"previousIC4Key","~","Add") : ""
		previousIC5Key := if (previousIC5Key) ? xHotKeyVarEdit(previousIC5Key,"previousIC5Key","~","Add") : ""
		previousIC6Key := if (previousIC6Key) ? xHotKeyVarEdit(previousIC6Key,"previousIC6Key","~","Add") : ""
		previousIC7Key := if (previousIC7Key) ? xHotKeyVarEdit(previousIC7Key,"previousIC7Key","~","Add") : ""
		previousIC8Key := if (previousIC8Key) ? xHotKeyVarEdit(previousIC8Key,"previousIC8Key","~","Add") : ""
		nextIC1Key := if (nextIC1Key) ? xHotKeyVarEdit(nextIC1Key,"nextIC1Key","~","Add") : ""
		nextIC2Key := if (nextIC2Key) ? xHotKeyVarEdit(nextIC2Key,"nextIC2Key","~","Add") : ""
		nextIC3Key := if (nextIC3Key) ? xHotKeyVarEdit(nextIC3Key,"nextIC3Key","~","Add") : ""
		nextIC4Key := if (nextIC4Key) ? xHotKeyVarEdit(nextIC4Key,"nextIC4Key","~","Add") : ""
		nextIC5Key := if (nextIC5Key) ? xHotKeyVarEdit(nextIC5Key,"nextIC5Key","~","Add") : ""
		nextIC6Key := if (nextIC6Key) ? xHotKeyVarEdit(nextIC6Key,"nextIC6Key","~","Add") : ""
		nextIC7Key := if (nextIC7Key) ? xHotKeyVarEdit(nextIC7Key,"nextIC7Key","~","Add") : ""
		nextIC8Key := if (nextIC8Key) ? xHotKeyVarEdit(nextIC8Key,"nextIC8Key","~","Add") : ""
		;Setting Bezel Monitor
		If (bezelMonitor="")
            bezelMonitor = primMonitor
        ;reseting to primary monitor if bezel monitor chosen is higher than the monitors currently available
        If (bezelMonitor > monitorTable.MaxIndex())
            bezelMonitor := primMonitor
		RLLog.Info(A_ThisFunc . " - Game will be moved to monitor " . bezelMonitor . " if RL finds a valid bezel to be show.")
		;initializing gdi plus
		If !pToken
			pToken := Gdip_Startup()
		;Loading Bezel parameters and images
		;Checking If game is vertical oriented
		If (angle != 180 && ((angle=90) or (angle=270) or (angle))) {
			vertical := "true"
			RLLog.Debug(A_ThisFunc . " - Assuming that game has vertical orientation. Bezel will search on the extra folder Vertical in order to find assets.")
		} Else {
			vertical := "false"
			RLLog.Debug(A_ThisFunc . " - Assuming that game has horizontal orientation.")
		}
		;Read Bezel Image
		If (bezelMode = "MultiScreens"){
			bezelNumberOfScreens := mode
			bezelPath := BezelFilesPath("Bezel [" . bezelNumberOfScreens . "S]",bezelFileExtensions)
		} Else {
			bezelPath := BezelFilesPath("Bezel",bezelFileExtensions,true)
		}
		;-----Loading Image Files into ARRAYs for bezel/background/overlay/instruction card
		If bezelPath 
			{
			bezelCheckPosTimeout = 5000
			;Setting bezel aleatory choosed file
			bezelImagesList := []
			If (bezelMode = "MultiScreens")
				{
				Loop, Parse, bezelFileExtensions,|
					Loop, % bezelPath . "\Bezel [" . bezelNumberOfScreens . "S]*." . A_LoopField
						bezelImagesList.Insert(A_LoopFileFullPath)
			} Else {
				Loop, Parse, bezelFileExtensions,|
					Loop, % bezelPath . "\Bezel*." . A_LoopField
						If !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
							bezelImagesList.Insert(A_LoopFileFullPath)
			}
			Random, RndmBezel, 1, % bezelImagesList.MaxIndex()
			If ( (extraFullScreenBezel = "true") or (extraFullScreenBezel = "fill") or (RegExMatch(extraFullScreenBezel, "i)[0-9]+x[0-9]+")) ){
				RLLog.Info(A_ThisFunc . " - Adding extra fullscreen fake bezel image")
				RLLog.Warning(A_ThisFunc . " - This could prevent real bezels froms showing! Disable extraFullScreenBezel setting to restore real bezels if you don't want to use the bezel fullscreen mode.")
				bezelImagesList.Insert("fakeFullScreenBezel")
			}
			If (bezelSaveSelected="true"){
				bezelSelectedIndex := RIni_GetKeyValue("BezelRomRini","Bezel Change","Initial_Bezel_Index")
				If !((bezelSelectedIndex = -2) or (bezelSelectedIndex = -3)){
					If (bezelSelectedIndex > bezelImagesList.MaxIndex())
						RIni_SetKeyValue("BezelRomRini","Bezel Change","Initial_Bezel_Index",RndmBezel) 
					else
						RndmBezel := bezelSelectedIndex
				}
			}
			bezelImageFile := bezelImagesList[RndmBezel]
			SplitPath, bezelImageFile, bezelImageFileName 
			RLLog.Info(A_ThisFunc . " - Loading Bezel image: " . bezelImageFile)
			;Setting overlay aleatory choosed file (only searches overlays at the bezel.png folder)
			bezelOverlaysList := []
			If FileExist(bezelPath . "\Overlay" . SubStr(bezelImageFileName,6)) {
				bezelOverlaysList.Insert(bezelPath . "\Overlay" . SubStr(bezelImageFileName,6))
				bezelOverlayFile := % bezelPath . "\Overlay" . SubStr(bezelImageFileName,6)
				RLLog.Info(A_ThisFunc . " - Loading Overlay image with the same name of the bezel image: " . bezelOverlayFile)
			} Else {
				If (bezelMode = "MultiScreens")
					{
					Loop, Parse, bezelFileExtensions,|
						Loop, % bezelPath . "\Overlay [" . bezelNumberOfScreens . "S]*." . A_LoopField
							bezelOverlaysList.Insert(A_LoopFileFullPath)
				} Else {
					Loop, Parse, bezelFileExtensions,|
						Loop, % bezelPath . "\Overlay*." . A_LoopField
							If !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
								 bezelOverlaysList.Insert(A_LoopFileFullPath)
				}
				Random, RndmBezelOverlay, 1, % bezelOverlaysList.MaxIndex()
				bezelOverlayFile := bezelOverlaysList[RndmBezelOverlay]
				If FileExist(bezelOverlayFile)
					RLLog.Info(A_ThisFunc . " - Loading Overlay image: " . bezelOverlayFile)
			}
		} Else {
			If ( (extraFullScreenBezel = "true") or (extraFullScreenBezel = "fill") or (RegExMatch(extraFullScreenBezel, "i)[0-9]+x[0-9]+")) ){
				RLLog.Info(A_ThisFunc . " - Adding extra fullscreen fake bezel image")
				bezelImagesList := []
				bezelPath := "fakeFullScreenBezel"
				RndmBezel := 1
				bezelImageFile := "fakeFullScreenBezel"
				bezelImagesList.Insert("fakeFullScreenBezel")
			}
		}
		;initializing IC settings
		If (bezelICEnabled = "true") {
			;Loading bezel instruction card files
			bezelICPath := BezelFilesPath("Instruction Card",bezelFileExtensions)		
			If (bezelICPath) {
				;Acquiring screen info for dealing with rotated menu drawings
				Gdip_Alt_GetRotatedDimensions(monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height, screenRotationAngle, baseScreenWidth, baseScreenHeight)
				Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
				xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
				Loop, 5 { 
					CurrentGUI := a_index + 3
					Gdip_TranslateWorldTransform(Bezel_G%CurrentGUI%, xTranslation, yTranslation)
					Gdip_RotateWorldTransform(Bezel_G%CurrentGUI%, screenRotationAngle)
				}
				;Resizing Menu items
				XBaseRes := 1920, YBaseRes := 1080
				If (((monitorTable[bezelMonitor].Width < monitorTable[bezelMonitor].Height) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((monitorTable[bezelMonitor].Width > monitorTable[bezelMonitor].Height) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
					XBaseRes := 1080, YBaseRes := 1920
				ICMenuScreenScallingFactor := baseScreenHeight/YBaseRes
				OptionScale(IC%currentICMenu%MenuListX, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuListY, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuListWidth, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuListHeight, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuListTextSize, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuListDisabledTextSize, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuPositionTextX, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuPositionTextY, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuPositionTextWidth, ICMenuScreenScallingFactor)
				OptionScale(IC%currentICMenu%MenuPositionTextHeight, ICMenuScreenScallingFactor)
				OptionScale(bezelIC%currentICMenu%MenuBitmapW, ICMenuScreenScallingFactor)
				OptionScale(bezelIC%currentICMenu%MenuBitmapH, ICMenuScreenScallingFactor)
				pGraphUpd(Bezel_G6,baseScreenWidth,baseScreenHeight)
				pGraphUpd(Bezel_G7,bezelICLeftMenuBitmapW,bezelICLeftMenuBitmapH)
				pGraphUpd(Bezel_G8,ICLeftMenuListWidth,ICLeftMenuListTextSize)
				pGraphUpd(Bezel_G9,bezelICRightMenuBitmapW,bezelICRightMenuBitmapH)
				pGraphUpd(Bezel_G10,ICRightMenuListWidth,ICRightMenuListTextSize)
				;List of available IC images
				bezelICImageList := []
				Loop, Parse, bezelFileExtensions,|
					Loop, %bezelICPath%\Instruction Card*.%A_LoopField%
						bezelICImageList.Insert(A_LoopFileFullPath)
				Loop, % bezelICImageList.MaxIndex()
					ICLogFilesList := ICLogFilesList . "`r`n`t`t`t`t`t" . bezelICImageList[a_index]
				RLLog.Debug(A_ThisFunc . " - Instruction Card images found: " . ICLogFilesList)
				;IC Position Array
				listofPosibleICPositions = topLeft,topRight,bottomLeft,bottomRight,topCenter,leftCenter,rightCenter,bottomCenter
				listofPossibleICScale = HalfScreenHeight|HalfScreenWidth|OneThirdScreenHeight|OneThirdScreenWidth|ScreenHeight|ScreenWidth
				StringSplit, positionICArray, positionIC, |, 
				;IC Array	
				defaultICScaleFactor := ICScaleFactor
				bezelICArray := [] ;bezelICArray[screenICPositionIndex, ICimageIndex, Attribute]
				activeIC := 1
				selectedICimage := []
				prevselectedICimage := []
				selectedRightMenuItem := []
				selectedLeftMenuItem := []
				maxICimage := []
				currentImage := 0
				Loop, 8
					{
					currentImage := 0
					currentICPositionIndex := a_index
					Loop, % bezelICImageList.MaxIndex()
						{
						currentBezelICFileName := bezelICImageList[a_index]
						SplitPath, currentBezelICFileName, , , , currentPureFileName
						postionNotDefined := false
						If currentPureFileName not contains %listofPosibleICPositions%
							postionNotDefined := true
						If ( ( (positionICArray%currentICPositionIndex%) and (InStr(currentPureFileName,positionICArray%currentICPositionIndex%)) ) or (postionNotDefined = true) ) 
							{
							currentImage++
							bezelICArray[currentICPositionIndex,currentImage,1] := currentBezelICFileName ; path to instruction card image
							bezelICArray[currentICPositionIndex,currentImage,2] := Gdip_CreateBitmapFromFile(currentBezelICFileName) ;bitmap pointer
							;image size
							ICScaleFactor := defaultICScaleFactor
							Loop, parse, listofPossibleICScale,|,
							{
								If InStr(currentPureFileName,A_LoopField)
								{
								ICScaleFactor := A_LoopField
								RLLog.Trace(A_ThisFunc . " - ICScaleFactor set by instruction card file name: " . ICScaleFactor)
								Break
								}
							}
							If (ICScaleFactor="ScreenHeight")
								ICScaleFactor := baseScreenHeight/Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])
							Else If (ICScaleFactor="ScreenWidth")
								ICScaleFactor := baseScreenWidth/Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])	
							Else If (ICScaleFactor="HalfScreenHeight")
								ICScaleFactor := baseScreenHeight/2/Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])	
							Else If (ICScaleFactor="HalfScreenWidth")
								ICScaleFactor := baseScreenWidth/2/Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])	
							Else If (ICScaleFactor="OneThirdScreenHeight")
								ICScaleFactor := baseScreenHeight/3/Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])	
							Else If (ICScaleFactor="OneThirdScreenWidth")
								ICScaleFactor := baseScreenWidth/3/Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])	
							Else 
								ICScaleFactor := ICScaleFactor	
							bezelICArray[currentICPositionIndex,currentImage,3] := round(Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])*ICScaleFactor) ; width of instruction card image
							bezelICArray[currentICPositionIndex,currentImage,4] := round(Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])*ICScaleFactor) ; height of instruction card image
							;clean name
							StringTrimLeft, currentLabel, currentPureFileName,16
							replace := {"topLeft":"","topRight":"","bottomLeft":"","bottomRight":"","topCenter":"","leftCenter":"","rightCenter":"","bottomCenter":""} ; Removing place strings from name
							For what, with in replace
								If InStr(currentLabel,what)
									StringReplace, currentLabel, currentLabel, %what%, %with%, All
							replace := {"HalfScreenHeight":"","HalfScreenWidth":"","OneThirdScreenHeight":"","OneThirdScreenWidth":"","ScreenHeight":"","ScreenWidth":""} ; Removing scale factor from name
							For what, with in replace
								If InStr(currentLabel,what)
									StringReplace, currentLabel, currentLabel, %what%, %with%, All
							currentLabel:=RegExReplace(currentLabel,"\(.*\)","") ; remove anything inside parentesis
							currentLabel:=RegExReplace(currentLabel,"^\s*","") ; remove leading
							currentLabel:=RegExReplace(currentLabel,"\s*$","") ; remove trailing
							bezelICArray[currentICPositionIndex,currentImage,5] := currentLabel ;clean Name
						}
					}
					bezelICArray[currentICPositionIndex,0,5] := "None"
					selectedICimage[currentICPositionIndex] := 0
					prevselectedICimage[currentICPositionIndex] := 0
					selectedRightMenuItem[currentICPositionIndex] := 0
					selectedLeftMenuItem[currentICPositionIndex] := 0
					maxICimage[currentICPositionIndex] := currentImage
					currentImage := 0
					ICVisibilityOn := true
				}
				If enableICChangeSound
					{
					currentPath := BezelFilesPath("ICslideIn","mp3")
					If currentPath
						slideInICSound := currentPath . "\ICslideIn.mp3"
					currentPath := BezelFilesPath("ICslideOut","mp3")
					If currentPath
						slideOutICSound := currentPath . "\ICslideOut.mp3"
					currentPath := BezelFilesPath("ICFadeOut","mp3")
					If currentPath
						fadeOutICSound := currentPath . "\ICFadeOut.mp3"
					currentPath := BezelFilesPath("ICFadeIn","mp3")
					If currentPath
						fadeOutICSound := currentPath . "\ICFadeIn.mp3"
					currentPath := BezelFilesPath("ICChange","mp3")
					If currentPath
						changeICSound := currentPath . "\ICChange.mp3"
				}
				;initializing IC menus
				StringReplace, leftMenuPositionsIC, leftMenuPositionsIC,|,`,, all
				StringReplace, rightMenuPositionsIC, rightMenuPositionsIC,|,`,, all
				Loop, 8
					{
					If positionICArray%a_index% in %leftMenuPositionsIC%
						{
						If bezelICArray[a_index,1,1]
							{
							leftMenuActiveIC := a_index
							Break
						}
					}
				}
				Loop, 8
					{
					If positionICArray%a_index% in %rightMenuPositionsIC%
						{
						If bezelICArray[a_index,1,1]
							{
							rightMenuActiveIC := a_index
							Break
						}
					}
				}
				;loading menu parameters
				menuSelectedItem := []	
				Loop, 2
					{
					If (a_index=1)
						currentICMenu := "Left" 
					Else 
						currentICMenu := "Right" 
					bezelIC%currentICMenu%MenuList := []
					bezelICMenuPath := BezelFilesPath("IC Menu " . currentICMenu, bezelFileExtensions)
					If !bezelICMenuPath
						{
						CreateICMenuBitmap(currentICMenu)
						bezelICMenuPath := RLMediaPath . "\Bezels\_Default"
					}
					Loop, Parse, bezelFileExtensions,|
						Loop, % bezelICMenuPath . "\IC Menu " . currentICMenu . "*." . A_LoopField
							bezelIC%currentICMenu%MenuList.Insert(A_LoopFileFullPath)
					Random, RndmbezelICMenu, 1, % bezelIC%currentICMenu%MenuList.MaxIndex()
					;File and bitmap pointers
					bezelIC%currentICMenu%MenuFile := bezelIC%currentICMenu%MenuList[RndmbezelICMenu]
					bezelIC%currentICMenu%MenuBitmap := Gdip_CreateBitmapFromFile(bezelIC%currentICMenu%MenuFile)
					Gdip_GetImageDimensions(bezelIC%currentICMenu%MenuBitmap, bezelIC%currentICMenu%MenuBitmapW, bezelIC%currentICMenu%MenuBitmapH)
					;Ini appearance options
					currentICMenuFile := bezelIC%currentICMenu%MenuList[RndmbezelICMenu]
					SplitPath, currentICMenuFile,,,,ICMenuFileNameNoExt
					BezelICMenuIniFile := bezelICMenuPath . "\" . ICMenuFileNameNoExt . ".ini"
					If (RIni_Read("bezelICRini" . currentICMenu,BezelICMenuIniFile) = -11)
						RIni_Create("bezelICRini" . currentICMenu)
					IC%currentICMenu%MenuListTextFont := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Font","Bebas Neue")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Font",IC%currentICMenu%MenuListTextFont) ; set value If ini not found
					IC%currentICMenu%MenuListTextAlignment := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Alignment","Center")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Alignment",IC%currentICMenu%MenuListTextAlignment) ; set value If ini not found
					IC%currentICMenu%MenuListTextSize := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Text_Size","50")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Text_Size",IC%currentICMenu%MenuListTextSize) ; set value If ini not found
					IC%currentICMenu%MenuListDisabledTextSize := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Size","30")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Size",IC%currentICMenu%MenuListDisabledTextSize) ; set value If ini not found
					IC%currentICMenu%MenuListTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Selected_Text_Color","FF000000")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Selected_Text_Color",IC%currentICMenu%MenuListTextColor) ; set value If ini not found
					IC%currentICMenu%MenuListDisabledTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Color","FFCCCCCC")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Color",IC%currentICMenu%MenuListDisabledTextColor) ; set value If ini not found
					IC%currentICMenu%MenuListCurrentTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Current_Text_Color","FFFF00FF")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Current_Text_Color",IC%currentICMenu%MenuListCurrentTextColor) ; set value If ini not found
					IC%currentICMenu%MenuListX := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_X_position","20")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_X_position",IC%currentICMenu%MenuListX) ; set value If ini not found
					IC%currentICMenu%MenuListY := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_Y_position","20")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_Y_position",IC%currentICMenu%MenuListY) ; set value If ini not found
					IC%currentICMenu%MenuListWidth := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Width","260")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Width",IC%currentICMenu%MenuListWidth) ; set value If ini not found
					IC%currentICMenu%MenuListHeight := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Height","360")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Height",IC%currentICMenu%MenuListHeight) ; set value If ini not found
					IC%currentICMenu%MenuPositionTextFont := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Font","Bebas Neue")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Font",IC%currentICMenu%MenuPositionTextFont) ; set value If ini not found
					IC%currentICMenu%MenuPositionTextAlignment := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Alignment","Right")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Alignment",IC%currentICMenu%MenuPositionTextAlignment) ; set value If ini not found
					IC%currentICMenu%MenuPositionTextSize := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Size","20")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Size",IC%currentICMenu%MenuPositionTextSize) ; set value If ini not found				
					IC%currentICMenu%MenuPositionTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Color","FFFFFFFF")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Color",IC%currentICMenu%MenuPositionTextColor) ; set value If ini not found	
					IC%currentICMenu%MenuPositionTextX := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_X_position",0)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_X_position",IC%currentICMenu%MenuPositionTextX) ; set value If ini not found
					IC%currentICMenu%MenuPositionTextY := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_Y_position",bezelIC%currentICMenu%MenuBitmapH-IC%currentICMenu%MenuPositionTextSize)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_Y_position",IC%currentICMenu%MenuPositionTextY) ; set value If ini not found
					IC%currentICMenu%MenuPositionTextWidth := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Width",bezelIC%currentICMenu%MenuBitmapW)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Width",IC%currentICMenu%MenuPositionTextWidth) ; set value If ini not found
					IC%currentICMenu%MenuPositionTextHeight := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Height",IC%currentICMenu%MenuPositionTextSize)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Height",IC%currentICMenu%MenuPositionTextHeight) ; set value If ini not found
					; Saving values to ini file
					RIni_Write("bezelICRini" . currentICMenu,BezelICMenuIniFile,"`r`n",1,1,1)
				}
			}
		}
		If bezelPath 
			{	
			If !(bezelImageFile = "fakeFullScreenBezel"){	
				; creating bitmap pointers
				bezelBitmap := Gdip_CreateBitmapFromFile(bezelImageFile)
				Gdip_GetImageDimensions(bezelBitmap, origbezelImageW, origbezelImageH)
				If bezelOverlayFile
					bezelOverlayBitmap := Gdip_CreateBitmapFromFile(bezelOverlayFile)	
				;background
				SplitPath, bezelImageFile, bezelImageFileName 
				bezelBackgroundFileList := []
				If FileExist(bezelPath . "\Background" . SubStr(bezelImageFileName,6,StrLen(bezelImageFileName)-9) . ".*") {
					Loop, Parse, bezelFileExtensions,|
						If FileExist(bezelPath . "\Background" . SubStr(bezelImageFileName,6,StrLen(bezelImageFileName)-9) . "." . A_LoopField) 
							bezelBackgroundFileList.Insert(bezelPath . "\Background" . SubStr(bezelImageFileName,6,StrLen(bezelImageFileName)-9) . "." . A_LoopField)
					Random, RndBezelBackground, 1, % bezelBackgroundFileList.MaxIndex()
					bezelBackgroundfile := bezelBackgroundFileList[RndBezelBackground]
					RLLog.Info(A_ThisFunc . " - Loading Background image with the same name of the bezel image: " . bezelBackgroundFile)
				} Else {
					bezelBackgroundPath := BezelFilesPath("Background",bezelFileExtensions,false,If (bezelUseBackgrounds="true") ? true : false)
					If (bezelBackgroundPath)
					{ 	bezelBackgroundFileList := []
						Loop, Parse, bezelFileExtensions,|
							Loop, % bezelBackgroundPath . "\" . "Background*." . A_LoopField
								If (!(FileExist(bezelBackgroundPath . "\Bezel" . SubStr(A_LoopFileName,11,StrLen(A_LoopFileName)-14) . ".*")))
								bezelBackgroundFileList.Insert(A_LoopFileFullPath)
						Random, RndBezelBackground, 1, % bezelBackgroundFileList.MaxIndex()
						bezelBackgroundfile := bezelBackgroundFileList[RndBezelBackground]
						RLLog.Info(A_ThisFunc . " - Loading Background image: " . bezelBackgroundFile)
					}
				}
				If (bezelBackgroundFile)
					bezelBackgroundBitmap := Gdip_CreateBitmapFromFile(bezelBackgroundFile)
				;show background GUI
				Gui, Bezel_GUI1: Show, na
			}
			;Setting ini file with bezel coordinates and reading its values
			bezelMonitorWidth := monitorTable[bezelMonitor].Width
			bezelMonitorHeight := monitorTable[bezelMonitor].Height
			If (bezelImageFile = "fakeFullScreenBezel"){
				If ( RegExMatch(extraFullScreenBezel, "i)[0-9]+x[0-9]+") ){
					StringSplit, aspect, extraFullScreenBezel, x, %A_Space% ; aspect1 = width, aspect2 = height
					widthMaxPerc := ( monitorTable[bezelMonitor].Width / aspect1 )
					heightMaxPerc := ( monitorTable[bezelMonitor].Height / aspect2 )
					scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
					bezelScreenWidth := Round(aspect1*scaleFactor)
					bezelScreenHeight := Round(aspect2*scaleFactor)
					bezelScreenX := monitorTable[bezelMonitor].Left + ( monitorTable[bezelMonitor].Width - bezelScreenWidth )//2
					bezelScreenY := monitorTable[bezelMonitor].Top + ( monitorTable[bezelMonitor].Height - bezelScreenHeight )//2
					origbezelImageW := monitorTable[bezelMonitor].Width
					origbezelImageH := monitorTable[bezelMonitor].Height
					bezelOrigIniScreenX1 := bezelScreenX
					bezelOrigIniScreenY1 := bezelScreenY
					bezelOrigIniScreenX2 := bezelScreenX+bezelScreenWidth
					bezelOrigIniScreenY2 := bezelScreenY+bezelScreenHeight
				} else {
					bezelScreenX := monitorTable[bezelMonitor].Left
					bezelScreenY := monitorTable[bezelMonitor].Top
					bezelScreenWidth := monitorTable[bezelMonitor].Width
					bezelScreenHeight := monitorTable[bezelMonitor].Height
					origbezelImageW := monitorTable[bezelMonitor].Width
					origbezelImageH := monitorTable[bezelMonitor].Height
					bezelOrigIniScreenX1 := bezelScreenX
					bezelOrigIniScreenY1 := bezelScreenY
					bezelOrigIniScreenX2 := bezelScreenX+bezelScreenWidth
					bezelOrigIniScreenY2 := bezelScreenY+bezelScreenHeight
				}
			} Else {		
				ReadBezelIniFile()
				bezelScreenX1 := bezelOrigIniScreenX1
				bezelScreenY1 := bezelOrigIniScreenY1
				bezelScreenX2 := bezelOrigIniScreenX2
				bezelScreenY2 := bezelOrigIniScreenY2	
				bezelImageW := origbezelImageW
				bezelImageH := origbezelImageH 
				; calculating BezelCoordinates
				If (bezelMode = "Normal")
					BezelCoordinates("Normal")
				Else If (bezelMode = "MultiScreens")
					BezelCoordinates("MultiScreens")
			}
		}
		If ((bezelPath) or (bezelICPath)){
			;force windowed mode
			If !disableForceFullscreen
				Fullscreen := false
		}
		RLLog.Info(A_ThisFunc . " - Ended")
	}
Return 
}


BezelDraw(){
	Global
	CustomFunction.PreBezelDraw(fullscreen)
	If (bezelEnabled = "true"){
		RLLog.Info(A_ThisFunc . " - Started")
		If bezelDelay
			Sleep % bezelDelay
		;------------ bezelMode bezelLayoutFile
		If bezelLayoutFile	
			Return
		If bezelPath 
			{
			If !(bezelLoaded) {				
				; creating GUi elements and pointers
				Loop, 10 { 
					Bezel_hbm%A_Index% := CreateDIBSection(monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
					Bezel_hdc%A_Index% := CreateCompatibleDC()
					Bezel_obm%A_Index% := SelectObject(Bezel_hdc%A_Index%, Bezel_hbm%A_Index%)
					Bezel_G%A_Index% := Gdip_GraphicsFromhdc(Bezel_hdc%A_Index%)
					Gdip_SetSmoothingMode(Bezel_G%A_Index%, 4)
				}
			}
			Gdip_GraphicsClear(Bezel_G1)
			Gdip_GraphicsClear(Bezel_G2)
			Gdip_GraphicsClear(Bezel_G3)
			Gdip_GraphicsClear(Bezel_G4)
			Gdip_GraphicsClear(Bezel_G5)
			;recalculating coordinates for the case of resolution change (or for the first time for the case of fixresmode)
			If ((bezelMode = "Normal") or (bezelMode = "MultiScreens")) {
				if ((bezelMonitorWidth != monitorTable[bezelMonitor].Width) or (bezelMonitorHeight = monitorTable[bezelMonitor].Height)) {			
					If (bezelImageFile = "fakeFullScreenBezel"){
						If ( RegExMatch(extraFullScreenBezel, "i)[0-9]+x[0-9]+") ){
							StringSplit, aspect, extraFullScreenBezel, x, %A_Space% ; aspect1 = width, aspect2 = height
							widthMaxPerc := ( monitorTable[bezelMonitor].Width / aspect1 )
							heightMaxPerc := ( monitorTable[bezelMonitor].Height / aspect2 )
							scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
							bezelScreenWidth := Round(aspect1*scaleFactor)
							bezelScreenHeight := Round(aspect2*scaleFactor)
							bezelScreenX := monitorTable[bezelMonitor].Left + ( monitorTable[bezelMonitor].Width - bezelScreenWidth )//2
							bezelScreenY := monitorTable[bezelMonitor].Top + ( monitorTable[bezelMonitor].Height - bezelScreenHeight )//2
							origbezelImageW := monitorTable[bezelMonitor].Width
							origbezelImageH := monitorTable[bezelMonitor].Height
							bezelOrigIniScreenX1 := bezelScreenX
							bezelOrigIniScreenY1 := bezelScreenY
							bezelOrigIniScreenX2 := bezelScreenX+bezelScreenWidth
							bezelOrigIniScreenY2 := bezelScreenY+bezelScreenHeight
						} else {
							bezelScreenX := monitorTable[bezelMonitor].Left
							bezelScreenY := monitorTable[bezelMonitor].Top
							bezelScreenWidth := monitorTable[bezelMonitor].Width
							bezelScreenHeight := monitorTable[bezelMonitor].Height
							origbezelImageW := monitorTable[bezelMonitor].Width
							origbezelImageH := monitorTable[bezelMonitor].Height
							bezelOrigIniScreenX1 := bezelScreenX
							bezelOrigIniScreenY1 := bezelScreenY
							bezelOrigIniScreenX2 := bezelScreenX+bezelScreenWidth
							bezelOrigIniScreenY2 := bezelScreenY+bezelScreenHeight
						}
					} Else {		
						ReadBezelIniFile()
						bezelScreenX1 := bezelOrigIniScreenX1
						bezelScreenY1 := bezelOrigIniScreenY1
						bezelScreenX2 := bezelOrigIniScreenX2
						bezelScreenY2 := bezelOrigIniScreenY2	
						bezelImageW := origbezelImageW
						bezelImageH := origbezelImageH 
						; calculating BezelCoordinates
						If (bezelMode = "Normal")
							BezelCoordinates("Normal")
						Else If (bezelMode = "MultiScreens")
							BezelCoordinates("MultiScreens")
					}
				}
			} else if (bezelMode = "fixResMode") {
				If !(bezelLoaded) {				
					WinGet emulatorID, ID, A
					RLLog.Info(A_ThisFunc . " - Emulator does not support custom made resolution. Game screen will be centered at the emulator resolution and the bezel png will be drawn around it. The bezel image will be croped If its resolution is bigger them the screen resolution.")
					X:="" , Y:="" , W:="" , H:=""
					timeout := A_TickCount
					Loop 
						{
						Sleep, 50
						WinGetPos, bezelScreenX, bezelScreenY, bezelScreenWidth, bezelScreenHeight, A
						If bezelScreenX and bezelScreenY and bezelScreenWidth and bezelScreenHeight
							Break
						if(timeout < A_TickCount - bezelCheckPosTimeout)
							Break
					}
					RLLog.Trace(A_ThisFunc . " - Emulator Screen Position: left=" . bezelScreenX . " top=" . bezelScreenY . " width=" . bezelScreenWidth . " height=" . bezelScreenHeight)
				}
				BezelCoordinates("fixResMode")
				RLLog.Info(A_ThisFunc . " - Screen Offset: left=" . bezelLeftOffset . " top=" . bezelTopOffset . " right=" . bezelRightOffset . " bottom=" . bezelBottomOffset)
			}
			;Loading shader
			if (shaderObj){		
				If (bezelMode = "MultiScreens"){
					shaderBitmap := []
					Loop, % bezelNumberOfScreens 
					{	shaderBitmap[a_index] := CreateShaderBitmap(bezelScreen%A_Index%W, bezelScreen%A_Index%H, vertical)
						Gdip_DrawImage(Bezel_G3, shaderBitmap[a_index], bezelScreen%A_Index%X1, bezelScreen%A_Index%Y1,bezelScreen%A_Index%W,bezelScreen%A_Index%H)
					}
				} else {
					shaderBitmap := CreateShaderBitmap(bezelScreenWidth, bezelScreenHeight, vertical)
					Gdip_DrawImage(Bezel_G3, shaderBitmap, bezelScreenX, bezelScreenY, bezelScreenWidth, bezelScreenHeight)
				}
				RLLog.Info(A_ThisFunc . " - Loading Shader: " . RLMediaPath . "\Shaders\" . shaderName)
			}
			;loading bezel background
			pBrush := Gdip_BrushCreateSolid("0xff000000")
			Gdip_Alt_FillRectangle(Bezel_G1, pBrush, -1, -1, monitorTable[bezelMonitor].Width+2, monitorTable[bezelMonitor].Height+2)
			If !(bezelLoaded) {				
				UpdateLayeredWindow(Bezel_hwnd1, Bezel_hdc1,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
			}
			If (bezelBackgroundFile) {
				Gdip_DrawImage(Bezel_G2, bezelBackgroundBitmap, 0, 0,monitorTable[bezelMonitor].Width+1,monitorTable[bezelMonitor].Height+1)        
				RLLog.Trace(A_ThisFunc . " - Background Screen Position: BezelImage left=" . 0 . " top=" . 0 . " right=" . monitorTable[bezelMonitor].Width . " bottom=" . monitorTable[bezelMonitor].Height)
			}
			If !(bezelLoaded) {				
				UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
			}
			;------------ bezelMode MultiScreens
			If (bezelMode = "MultiScreens") {
				; Disable windows components
				; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
				var := "BezelLabel"
				If IsLabel(var)
					gosub, %var%
				Loop, %bezelNumberOfScreens%
				{
					currentScreen := a_index
					currentEmulatorID := Screen%currentScreen%ID

					If (!hideDecoratorsAfterWindowMove) 
						HideWindowDecorators(currentEmulatorID,disableHideBorderScreen%currentScreen%,disableHideTitleBarScreen%currentScreen%,disableHideToggleMenuScreen%currentScreen%,hideBorderFirstScreen%currentScreen%)

					;Moving emulator Window to predefined bezel position
					screenPositionLogList := screenPositionLogList . "`r`n`t`t`t`t`tScreen " . currentScreen . ": left=" . bezelScreen%currentScreen%X1 . " top=" . bezelScreen%currentScreen%Y1 . " right=" . (bezelScreen%currentScreen%X1+bezelScreen%currentScreen%W) . " bottom=" . (bezelScreen%currentScreen%Y1+bezelScreen%currentScreen%H)
					If !disableWinMove
						WinMove, % "ahk_id " . Screen%currentScreen%ID, , % bezelScreen%currentScreen%X1, % bezelScreen%currentScreen%Y1, % bezelScreen%currentScreen%W, % bezelScreen%currentScreen%H
				}
				If !disableWinMove
				{
					;check If windows moved
					Sleep, 200
					Loop, %bezelNumberOfScreens%
						{			
						currentScreen := a_index
						MoveWindow("ahk_id " . Screen%currentScreen%ID,bezelScreen%currentScreen%X1,bezelScreen%currentScreen%Y1,bezelScreen%currentScreen%W,bezelScreen%currentScreen%H,bezelCheckPosTimeout)
					}
				}
				If (hideDecoratorsAfterWindowMove) 
				{
					Loop, %bezelNumberOfScreens%
					{
						currentScreen := a_index
						currentEmulatorID := Screen%currentScreen%ID
						HideWindowDecorators(currentEmulatorID,disableHideBorderScreen%currentScreen%,disableHideTitleBarScreen%currentScreen%,disableHideToggleMenuScreen%currentScreen%,hideBorderFirstScreen%currentScreen%)
					}
				}
			;------------ bezelMode Normal
			} Else If (bezelMode = "Normal") {
				WinGet emulatorID, ID, A
				;BezelCoordinates("Normal")
				RLLog.Info(A_ThisFunc . " - Bezel Screen Offset: left=" . bezelLeftOffset . " top=" . bezelTopOffset . " right=" . bezelRightOffset . " bottom=" . bezelBottomOffset)
				; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
				var := "BezelLabel"
				If IsLabel(var)
					gosub, %var%
				; list of windows manipulation options that can be enabled/disabled on the BezelLabel (they are enable as default)
				If (!hideDecoratorsAfterWindowMove) 
					HideWindowDecorators(emulatorID,disableHideBorder,disableHideTitleBar,disableHideToggleMenu,hideBorderFirst)
				;Moving emulator Window to predefined bezel window 
				If !disableWinMove
					MoveWindow("ahk_id " . emulatorID,bezelScreenX,bezelScreenY,bezelScreenWidth,bezelScreenHeight,bezelCheckPosTimeout)
				If (hideDecoratorsAfterWindowMove) 
					HideWindowDecorators(emulatorID,disableHideBorder,disableHideTitleBar,disableHideToggleMenu,hideBorderFirst)
			;------------ bezelMode fixResMode
			} Else If (bezelMode = "fixResMode") {  ; Define coordinates for emulators that does not support custom made resolutions. 
				; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
				var := "BezelLabel"
				If IsLabel(var)
					gosub, %var%
				; list of windows manipulation options that can be enabled/disabled on the BezelLabel (they are enable as default)
				If (!hideDecoratorsAfterWindowMove) 
					HideWindowDecorators(emulatorID,disableHideBorder,disableHideTitleBar,disableHideToggleMenu,hideBorderFirst)
				;Moving emulator Window to predefined bezel window 
				If !disableWinMove
					{
					WinGetPos("", "", Wgot, Hgot, "ahk_id " . emulatorID)
					MoveWindow("ahk_id " . emulatorID,bezelScreenX,bezelScreenY,Wgot,Hgot,bezelCheckPosTimeout)
				}
				If (hideDecoratorsAfterWindowMove) 
					HideWindowDecorators(emulatorID,disableHideBorder,disableHideTitleBar,disableHideToggleMenu,hideBorderFirst)
			}
			;Drawing Shader Image above screen
			if (shaderObj)
				If !(bezelLoaded)
					UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
			;Drawing Overlay Image above screen
			If bezelOverlayFile
				{
				If (bezelMode = "MultiScreens") {
					Loop, %bezelNumberOfScreens%
						Gdip_DrawImage(Bezel_G4, bezelOverlayBitmap, bezelScreen%A_Index%X1, bezelScreen%A_Index%Y1,bezelScreen%A_Index%W,bezelScreen%A_Index%H)     		
					If !bezelLoaded
						UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
				} Else {
					Gdip_DrawImage(Bezel_G4, bezelOverlayBitmap, 0, 0,bezelScreenWidth,bezelScreenHeight)        
					If !bezelLoaded
						UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight)
					RLLog.Trace(A_ThisFunc . " - Overlay Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight))
				}
			}
			;Drawing Bezel GUI
			If !(bezelImageFile = "fakeFullScreenBezel"){
				Gdip_DrawImage(Bezel_G5, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)        
				If !bezelLoaded
					UpdateLayeredWindow(Bezel_hwnd5, Bezel_hdc5,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
				RLLog.Trace(A_ThisFunc . " - Bezel Image Screen Position: BezelImage left=" . bezelImageX . " top=" . bezelImageY . " right=" . (bezelImageX+bezelImageW) . " bottom=" . (bezelImageY+bezelImageH))
				If (bezelMode = "MultiScreens")
					RLLog.Debug(A_ThisFunc . " - Game Screen Position:" . screenPositionLogList)
				Else
					RLLog.Trace(A_ThisFunc . " - Game Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight))
			}
			If !bezelLoaded
				{
				;Initializing Instruction Cards Keys
				Gosub, EnableBezelKeys
				;Initializing bezel change
				If (bezelImagesList.MaxIndex() > 1) {
					If nextBezelKey
						{
						XHotKeywrapper(nextBezelKey,"nextBezel")
					}
					If previousBezelKey
						{
						XHotKeywrapper(previousBezelKey,"previousBezel")
					}
				}
				;Creating bezel background timer
				If (bezelBackgroundFileList.MaxIndex() > 1)
					If (bezelBackgroundChangeDur)
						settimer, BezelBackgroundTimer, %bezelBackgroundChangeDur%
				If bezelICPath
					{
					If ((ICSaveSelected="true") and (FileExist(Bezel_RomFile))) {
						Loop, 8
							If maxICimage[a_index]
								{
								selectedIndex := RIni_GetKeyValue("BezelRomRini","Instruction Cards","Initial_Card_" . a_index . "_Index")
								selectedICimage[a_index] := If (selectedIndex = -2) or (selectedIndex = -3) ? 1 :  selectedIndex
							}
					}
					If (displayICOnStartup = "true") {
						Loop, 8
							{
							If !(selectedICimage[a_index]) 
								selectedICimage[a_index] := 1
							If maxICimage[a_index]
								{
								DrawIC()
							}
						}
					} Else If (displayICOnStartup = "Random") {
						gosub, randomICChange
					}
					If %ICRandomSlideShowTimer%
						SetTimer, randomICChange, %ICRandomSlideShowTimer%
				}
			}
		}
		bezelLoaded := true
		RLLog.Info(A_ThisFunc . " - Ended")
	}
Return
}

BezelExit(){
	Global
	If (bezelEnabled = "true"){
		RLLog.Info(A_ThisFunc . " - Started")
		;Deleting pointers and destroying GUis
		Loop, 9 {
			SelectObject(Bezel_hdc%A_Index%, Bezel_obm%A_Index%)
			DeleteObject(Bezel_hbm%A_Index%)
			DeleteDC(Bezel_hdc%A_Index%)
			Gdip_DeleteGraphics(Bezel_G%A_Index%)
			Gui, Bezel_GUI%A_Index%: Destroy
		}
		If bezelPath 
			{
			RLLog.Info(A_ThisFunc . " - Removing bezel image components to exit RocketLauncher.")
			If bezelBitmap
				Gdip_DisposeImage(bezelBitmap)
			If bezelBackgroundFile
				Gdip_DisposeImage(bezelBackgroundBitmap)
			If bezelOverlayFile
				Gdip_DisposeImage(bezelOverlayBitmap) 
			If shaderBitmap
				Gdip_DisposeImage(shaderBitmap) 
			If BezelBackgroundChangeLoaded
				Gdip_DisposeImage(preRndBezelBackground) 
			If bezelICPath
				{
				Loop, 8
					{
					currentICPositionIndex := a_index
					Loop, %numberofICImages%
						{
						If bezelICArray[currentICPositionIndex,a_index,2]
							Gdip_DisposeImage(bezelICArray[currentICPositionIndex,a_index,2])
					}
				}
			}
			If (bezelSaveSelected="true") {
				RIni_SetKeyValue("BezelRomRini","Bezel Change","Initial_Bezel_Index",RndmBezel)	
				updateBezel_RomFile := true
			}
		}
		If bezelICPath
			{
			If (ICSaveSelected="true"){
				Loop, 8
					RIni_SetKeyValue("BezelRomRini","Instruction Cards","Initial_Card_" . a_index . "_Index",selectedICimage[a_index])
				updateBezel_RomFile := true
			}
		}
		If updateBezel_RomFile
			{
			SplitPath, Bezel_RomFile, , Bezel_RomFilePath
			FileCreateDir, % Bezel_RomFilePath
			RIni_Write("BezelRomRini",Bezel_RomFile,"`r`n",1,1,1)
		}
		RLLog.Info(A_ThisFunc . " - Ended")
	}
Return
}


ReadBezelIniFile(){
	Global
	StringTrimRight, bezelIniFile, bezelImageFile, 4
	bezelIniFile := bezelIniFile . ".ini"
	If !FileExist(bezelIniFile)
		RLLog.Warning(A_ThisFunc . " - Bezel Ini file not found. Creating the file " . bezelIniFile . " with full screen coordinates. You should edit the ini file to enter the coordinates in pixels of the screen emulator location on the bezel image.")
	bezelOrigIniScreenX1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Top Left X Coordinate", 0)
	bezelOrigIniScreenY1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Top Left Y Coordinate", 0)
	bezelOrigIniScreenX2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Bottom Right X Coordinate", monitorTable[bezelMonitor].Width)
	bezelOrigIniScreenY2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Bottom Right Y Coordinate", monitorTable[bezelMonitor].Height)
	RLLog.Trace(A_ThisFunc . " - Bezel ini file found. Defined screen positions: X1=" . bezelOrigIniScreenX1 . " Y1=" . bezelOrigIniScreenY1 . " X2=" . bezelOrigIniScreenX2 . " Y2=" . bezelOrigIniScreenY2)
	;reading additional screens info
	If (bezelMode = "MultiScreens") {
		Loop, % bezelNumberOfScreens-1
			{
			currentScreen := a_index+1
			bezelScreen%currentScreen%X1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Top Left X Coordinate", 0)
			bezelScreen%currentScreen%Y1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Top Left Y Coordinate", 0)
			bezelScreen%currentScreen%X2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Bottom Right X Coordinate", 0)
			bezelScreen%currentScreen%Y2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Bottom Right Y Coordinate", 0)
		}
	}
Return
}

BezelCoordinates(CoordinatesMode){
	Global
	If (CoordinatesMode = "Normal"){
		; Resizing bezel transparent area to the screen resolution (image is stretched to Center screen, keeping aspect)
		widthMaxPerc := ( monitorTable[bezelMonitor].Width / bezelImageW )	; get the percentage needed to maximise the image so the higher dimension reaches the screen's edge
		heightMaxPerc := ( monitorTable[bezelMonitor].Height / bezelImageH )
		scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
		bezelImageW := Round(bezelImageW * scaleFactor)
		bezelImageH := Round(bezelImageH * scaleFactor)
		bezelImageX := Round( ( monitorTable[bezelMonitor].Width - bezelImageW ) // 2 )
		bezelImageY := Round( ( monitorTable[bezelMonitor].Height - bezelImageH ) // 2 )
		; Defining emulator position 
		bezelScreenX := Round ( bezelImageX + (bezelScreenX1 * scaleFactor) )
		bezelScreenY := Round ( bezelImageY + (bezelScreenY1 * scaleFactor) )
		bezelScreenWidth := Round( (bezelScreenX2-bezelScreenX1)* scaleFactor )
		bezelScreenHeight := Round( (bezelScreenY2-bezelScreenY1)* scaleFactor )
		; Applying offsets to correctly place the emulator If the emulator has extra window components
		bezelScreenX := If bezelLeftOffset ? bezelScreenX - bezelLeftOffset : bezelScreenX
		bezelScreenY := If bezelTopOffset ? bezelScreenY - bezelTopOffset : bezelScreenY
		bezelScreenWidth := If bezelRightOffset ? ( If bezelLeftOffset ? bezelScreenWidth + bezelRightOffset + bezelLeftOffset : bezelScreenWidth + bezelRightOffset ) : ( If bezelLeftOffset ? bezelScreenWidth + bezelLeftOffset : bezelScreenWidth )
		bezelScreenHeight := If bezelTopOffset ? ( If bezelBottomOffset ? bezelScreenHeight + bezelTopOffset + bezelBottomOffset : bezelScreenHeight + bezelTopOffset ) : ( If bezelBottomOffset ? bezelScreenHeight + bezelBottomOffset : bezelScreenHeight )
		bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
		;Displacing Bezel to chosen monitor origin
		bezelScreenX := monitorTable[bezelMonitor].Left+bezelScreenX
		bezelScreenY := monitorTable[bezelMonitor].Top+bezelScreenY
	} Else If (CoordinatesMode = "MultiScreens") {
		; Resizing bezel transparent area to the screen resolution (image is stretched to Center screen, keeping aspect)
		widthMaxPerc := ( monitorTable[bezelMonitor].Width / bezelImageW )	; get the percentage needed to maximise the image so the higher dimension reaches the screen's edge
		heightMaxPerc := ( monitorTable[bezelMonitor].Height / bezelImageH )
		scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
		bezelImageW := Round(bezelImageW * scaleFactor)
		bezelImageH := Round(bezelImageH * scaleFactor)
		bezelImageX := Round( ( monitorTable[bezelMonitor].Width - bezelImageW ) // 2 )
		bezelImageY := Round( ( monitorTable[bezelMonitor].Height - bezelImageH ) // 2 )
		; Defining emulator position 
		bezelScreen1X1 := bezelScreenX1
		bezelScreen1Y1 := bezelScreenY1
		bezelScreen1X2 := bezelScreenX2
		bezelScreen1Y2 := bezelScreenY2	
		Loop, %bezelNumberOfScreens%
			{
			bezelScreen%a_index%W := Round((bezelScreen%a_index%X2-bezelScreen%a_index%X1)*scaleFactor) 
			bezelScreen%a_index%H := Round((bezelScreen%a_index%Y2-bezelScreen%a_index%Y1)*scaleFactor) 
			bezelScreen%a_index%X1 := Round(bezelImageX+bezelScreen%a_index%X1*scaleFactor)	 
			bezelScreen%a_index%Y1 := Round(bezelImageY+bezelScreen%a_index%Y1*scaleFactor)	 
			; Applying offsets to correctly place the emulator If the emulator has extra window components
			bezelScreen%a_index%X1 := If bezelLeftOffsetScreen%a_index% ? bezelScreen%a_index%X1 - bezelLeftOffsetScreen%a_index% : bezelScreen%a_index%X1
			bezelScreen%a_index%Y1 := If bezelTopOffsetScreen%a_index% ? bezelScreen%a_index%Y1 - bezelTopOffsetScreen%a_index% : bezelScreen%a_index%Y1
			bezelScreen%a_index%W := If bezelRightOffsetScreen%a_index% ? ( If bezelLeftOffsetScreen%a_index% ? bezelScreen%a_index%W + bezelRightOffsetScreen%a_index% + bezelLeftOffsetScreen%a_index% : bezelScreen%a_index%W + bezelRightOffsetScreen%a_index% ) : ( If bezelLeftOffsetScreen%a_index% ? bezelScreen%a_index%W + bezelLeftOffsetScreen%a_index% : bezelScreen%a_index%W )
			bezelScreen%a_index%H := If bezelTopOffsetScreen%a_index% ? ( If bezelBottomOffsetScreen%a_index% ? bezelScreen%a_index%H + bezelTopOffsetScreen%a_index% + bezelBottomOffsetScreen%a_index% : bezelScreen%a_index%H + bezelTopOffsetScreen%a_index% ) : ( If bezelBottomOffsetScreen%a_index% ? bezelScreen%a_index%H + bezelBottomOffsetScreen%a_index% : bezelScreen%a_index%H )
			bezelScreen%a_index%X1 := round(bezelScreen%a_index%X1) , bezelScreen%a_index%Y1 := round(bezelScreen%a_index%Y1), bezelScreen%a_index%W := round(bezelScreen%a_index%W) , bezelScreen%a_index%H := round(bezelScreen%a_index%H)			
			;Displacing Bezel to chosen monitor origin
			bezelScreen%a_index%X1 := monitorTable[bezelMonitor].Left+bezelScreen%a_index%X1
			bezelScreen%a_index%Y1 := monitorTable[bezelMonitor].Top+bezelScreen%a_index%Y1
			RLLog.Trace(A_ThisFunc . " - Emulator Screen " . a_index . " position on bezel: X=" . bezelScreen%a_index%X1 . " Y=" . bezelScreen%a_index%Y1 . " W=" . bezelScreen%a_index%W . " H=" . bezelScreen%a_index%H)
			
		}
	} Else If (CoordinatesMode = "fixResMode") {
		bezelScreenWidth := If bezelRightOffset ? ( If bezelLeftOffset ? bezelScreenWidth - bezelRightOffset - bezelLeftOffset : bezelScreenWidth - bezelRightOffset ) : ( If bezelLeftOffset ? bezelScreenWidth - bezelLeftOffset : bezelScreenWidth )
		bezelScreenHeight := If bezelTopOffset ? ( If bezelBottomOffset ? bezelScreenHeight - bezelTopOffset - bezelBottomOffset : bezelScreenHeight - bezelTopOffset ) : ( If bezelBottomOffset ? bezelScreenHeight - bezelBottomOffset : bezelScreenHeight )
		bezelScreenX:= Round((monitorTable[bezelMonitor].Width-bezelScreenWidth)/2)
		bezelScreenY:= Round((monitorTable[bezelMonitor].Height-bezelScreenHeight)/2) 
		bezelScreenX := If bezelLeftOffset ? bezelScreenX - bezelLeftOffset : bezelScreenX
		bezelScreenY := If bezelTopOffset ? bezelScreenY - bezelTopOffset : bezelScreenY
		xScaleFactor := (bezelScreenWidth)/(bezelScreenX2-bezelScreenX1)
		yScaleFactor := (bezelScreenHeight)/(bezelScreenY2-bezelScreenY1)
		bezelImageW := Round(bezelImageW * xScaleFactor)
		bezelImageH := Round(bezelImageH * yScaleFactor) 
		bezelImageX := Round( (monitorTable[bezelMonitor].Width-(bezelScreenX2-bezelScreenX1)*xScaleFactor)//2-bezelScreenX1*xScaleFactor )
		bezelImageY := Round( (monitorTable[bezelMonitor].Height-(bezelScreenY2-bezelScreenY1)*yScaleFactor)//2-bezelScreenY1*yScaleFactor )	
		;Displacing Bezel to chosen monitor origin
		bezelScreenX := monitorTable[bezelMonitor].Left+bezelScreenX
		bezelScreenY := monitorTable[bezelMonitor].Top+bezelScreenY
	}
Return
}

BezelFilesPath(filename,fileextension,excludeScreens:=false,useBkgdPath:=false)
{	Global RLMediaPath, systemName, dbName, vertical, gameInfo, emuName
	bezelpath1 := RLMediaPath . "\Bezels\" . systemName . "\" . dbName
	If (gameInfo["Cloneof"].Value)
		bezelpath2 := RLMediaPath . "\Bezels\" . systemName . "\" . gameInfo["Cloneof"].Value
	If (useBkgdPath){
		bezelpath3 := RLMediaPath . "\Backgrounds\" . systemName . "\" . dbName
		If (gameInfo["Cloneof"].Value)
			bezelpath4 := RLMediaPath . "\Backgrounds\" . systemName . "\" . gameInfo["Cloneof"].Value
	}
	If (vertical = "true")
		bezelpath5 := RLMediaPath . "\Bezels\" . systemName . "\_Default\" . emuName . "\Vertical"
	Else
		bezelpath6 := RLMediaPath . "\Bezels\" . systemName . "\_Default\" . emuName . "\Horizontal"
	bezelpath7 := RLMediaPath . "\Bezels\" . systemName . "\_Default\" . emuName
	If (vertical = "true")
		bezelpath8 := RLMediaPath . "\Bezels\" . systemName . "\_Default\Vertical"
	Else
		bezelpath9 := RLMediaPath . "\Bezels\" . systemName . "\_Default\Horizontal"
	bezelpath10 := RLMediaPath . "\Bezels\" . systemName . "\_Default"
	If (useBkgdPath){
		If (vertical = "true")
			bezelpath11 := RLMediaPath . "\Backgrounds\" . systemName . "\_Default\Vertical"
		Else
			bezelpath12 := RLMediaPath . "\Backgrounds\" . systemName . "\_Default\Horizontal"
		bezelpath13 := RLMediaPath . "\Backgrounds\" . systemName . "\_Default"
	}
	If (vertical = "true")
		bezelpath14 := RLMediaPath . "\Bezels\_Default\Vertical"
	Else
		bezelpath15 := RLMediaPath . "\Bezels\_Default\Horizontal"
	bezelpath16 := RLMediaPath . "\Bezels\_Default"
	If (useBkgdPath){
		If (vertical = "true")
			bezelpath17 := RLMediaPath . "\Backgrounds\_Default\Vertical"
		Else
			bezelpath18 := RLMediaPath . "\Backgrounds\_Default\Horizontal"
		bezelpath19 := RLMediaPath . "\Backgrounds\_Default"
	}
	Loop, 19 {
		If bezelpath%a_index%
			{
			RLLog.Debug(A_ThisFunc . " - Looking for " . filename . " in: " . bezelpath%A_Index%)
			currentbezelpathNumber := a_index
			Loop, Parse, fileextension,|
			{	Loop % bezelpath%currentbezelpathNumber% . "\" . filename . "*." . A_LoopField
					{
					If (!(filename="Background") or ((filename="Background") and !(FileExist(bezelpath%currentbezelpathNumber% . "\Bezel" . SubStr(A_LoopFileName,11,StrLen(A_LoopFileName)-14) . ".*"))))  ;excluding bezel specific backgrounds 
						{
						If excludeScreens
							{
							If !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
								{
								RLLog.Debug(A_ThisFunc . " - Found " . filename . " art in folder: " . bezelpath%currentbezelpathNumber%)
								bezelPathFound := bezelpath%currentbezelpathNumber%
								Break
							}
						} Else {
							RLLog.Debug(A_ThisFunc . " - Found " . filename . " art in folder: " . bezelpath%currentbezelpathNumber%)
							bezelPathFound := bezelpath%currentbezelpathNumber%
							Break
						}
					}
				}
			}
			If bezelPathFound
				Break
		}
	}
	If !bezelPathFound
		RLLog.Warning(A_ThisFunc . " - Bezels are enabled, however none of the " . filename . " files, with extensions " . fileextension . " exist on the bezel folders.")
	Return bezelPathFound
}		


;Function to load ini values
RIniBezelLoadVar(gRIniVar,sRIniVar,rRIniVar,gsec,gkey,gdefaultvalue:="",ssec:=0,skey:=0,sdefaultvalue:="use_global",rdefaultvalue:="use_global") {
    Global
    If not ssec
        ssec := gsec
    If not skey
        skey := gkey
	X1 := RIni_GetKeyValue(gRIniVar,gsec,gkey)
	X1 := If (X1 = -2) or (X1 = -3) ? gdefaultvalue :  X1
	X2 := RIni_GetKeyValue(sRIniVar,ssec,skey)
	X2 := If (X2 = -2) or (X2 = -3) ? sdefaultvalue :  X2
	X3 := RIni_GetKeyValue(rRIniVar,ssec,skey)
	X3 := If (X3 = -2) or (X3 = -3) ? rdefaultvalue :  X3
	X4 := (If (X3 = "use_global")  ? (If (X2 = "use_global") ? (X1) : (X2)) : (X3))	
	RIni_SetKeyValue(gRIniVar,gsec,gkey,X1)
    RIni_SetKeyValue(sRIniVar,ssec,skey,X2)
	RIni_SetKeyValue(rRIniVar,ssec,skey,X3)
    BezelVarLog .= "`r`n`t`t`t`t`t" . "[" . gsec . "] " . gkey . " = " . X4
	Return X4
}

;Function to hide decorators for a window including the menu bar, parameters should all be boolean and not strings except windowID of course
HideWindowDecorators(windowID,disableHideBorder,disableHideTitleBar,disableHideToggleMenu,hideBorderFirst) {
	Global RLObject
	RLLog.Info(A_ThisFunc . " - Started")
	RLLog.Info(A_ThisFunc . " - disableHideBorder=" . disableHideBorder ", disableHideTitleBar=" . disableHideTitleBar . ", disableHideToggleMenu=" . disableHideToggleMenu . ", hideBorderFirst=" . hideBorderFirst)
	If !disableHideBorder && hideBorderFirst
		RLObject.hideWindowBorder(windowID)
	If !disableHideTitleBar
		RLObject.hideWindowTitleBar(windowID)
	If !disableHideToggleMenu
		ToggleMenu(windowID)
	If !disableHideBorder && !hideBorderFirst
		RLObject.hideWindowBorder(windowID)
	RLLog.Info(A_ThisFunc . " - Ended")
}

; Bezel Change Code 
BezelBackgroundTimer:
	BezelBackgroundChangeLoaded := true
	preRndBezelBackground := RndBezelBackground
	RndBezelBackground := RndBezelBackground + 1
	If (RndBezelBackground > bezelBackgroundFileList.MaxIndex())
		RndBezelBackground := 1
	prebezelBackgroundfile := bezelBackgroundFileList[preRndBezelBackground] 
	bezelBackgroundfile := bezelBackgroundFileList[RndBezelBackground]
	prebezelBackgroundBitmap := Gdip_CreateBitmapFromFile(prebezelBackgroundfile)
	bezelBackgroundBitmap := Gdip_CreateBitmapFromFile(bezelBackgroundFile)
	If (bezelBackgroundTransition="fade"){
		;fade in
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G2)
			t := If ((TimeElapsed := A_TickCount-startTime) < bezelBackgroundTransitionDur) ? ((timeElapsed/bezelBackgroundTransitionDur)) : 1
			Gdip_DrawImage(Bezel_G2, prebezelBackgroundBitmap, 0, 0,monitorTable[bezelMonitor].Width,monitorTable[bezelMonitor].Height)    
			Gdip_DrawImage(Bezel_G2, bezelBackgroundBitmap, 0, 0,monitorTable[bezelMonitor].Width,monitorTable[bezelMonitor].Height,"","","","",t) 
			UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
			If (t >= 1)
				Break
		}				
	} Else {
		Gdip_GraphicsClear(Bezel_G2)
		Gdip_DrawImage(Bezel_G2, bezelBackgroundBitmap, 0, 0,monitorTable[bezelMonitor].Width,monitorTable[bezelMonitor].Height)    
		UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)		
	}
Return


NextBezel:
PreviousBezel:
If bezelPath
	{
	if (BezelChangeRunning)
		Return
	If bezelLayoutFile
		Return
	if (bezelImagesList.MaxIndex()=1)
		Return
	BezelChangeRunning := true
	If (A_ThisLabel="NextBezel") {
		RndmBezel := RndmBezel + 1
		If (RndmBezel > bezelImagesList.MaxIndex()){
			RndmBezel := 1
		}
	} Else If (A_ThisLabel="PreviousBezel") {
		RndmBezel := RndmBezel - 1
		If (RndmBezel < 1){
			RndmBezel := bezelImagesList.MaxIndex()
		}
	}
	;fade out
	startTime := A_TickCount
	Loop {
		t := If ((TimeElapsed := A_TickCount-startTime) < bezelChangeDur) ? (255*(1-(timeElapsed/bezelChangeDur))) : 0
		If bezelBackgroundFile
			UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
		if (shaderObj)
			UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
		If bezelOverlayFile
			{
			If (bezelMode = "MultiScreens")
				UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
			Else
				UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight,t)	
		}
		If !(bezelImageFile = "fakeFullScreenBezel")
			UpdateLayeredWindow(Bezel_hwnd5, Bezel_hdc5,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
		WinSet, Transparent, %t%, ahk_id %emulatorID%
		If (t <= 0)
			Break
	}
	prevbezelImageW := origbezelImageW
	prevbezelImageH := origbezelImageH
	prevbezelOrigIniScreenX1 := bezelOrigIniScreenX1
	prevbezelOrigIniScreenY1 := bezelOrigIniScreenY1
	prevbezelOrigIniScreenX2 := bezelOrigIniScreenX2
	prevbezelOrigIniScreenY2 := bezelOrigIniScreenY2		
	bezelImageFile := bezelImagesList[RndmBezel]	
	If (bezelImageFile = "fakeFullScreenBezel"){
		RLLog.Info(A_ThisFunc . " - Loading fake full screen Bezel.")
		origbezelImageW := monitorTable[bezelMonitor].Width
		origbezelImageH := monitorTable[bezelMonitor].Height
		bezelOrigIniScreenX1 := 0
		bezelOrigIniScreenY1 := 0
		bezelOrigIniScreenX2 := monitorTable[bezelMonitor].Width
		bezelOrigIniScreenY2 := monitorTable[bezelMonitor].Height
	} Else {
		RLLog.Info(A_ThisFunc . " - Loading Bezel: " . bezelImageFile)
		bezelBitmap := Gdip_CreateBitmapFromFile(bezelImageFile)
		Gdip_GetImageDimensions(bezelBitmap, origbezelImageW, origbezelImageH)
		ReadBezelIniFile()
		;loading background
		SplitPath, bezelImageFile, bezelImageFileName 
		bezelBackgroundFileList := []
		If FileExist(bezelPath . "\Background" . SubStr(bezelImageFileName,6,StrLen(bezelImageFileName)-9) . ".*") {
			Loop, Parse, bezelFileExtensions,|
				If FileExist(bezelPath . "\Background" . SubStr(bezelImageFileName,6,StrLen(bezelImageFileName)-9) . "." . A_LoopField) 
					bezelBackgroundFileList.Insert(bezelPath . "\Background" . SubStr(bezelImageFileName,6,StrLen(bezelImageFileName)-9) . "." . A_LoopField)
			Random, RndBezelBackground, 1, % bezelBackgroundFileList.MaxIndex()
			bezelBackgroundfile := bezelBackgroundFileList[RndBezelBackground]
			RLLog.Info(A_ThisFunc . " - Loading Background image with the same name of the bezel image: " . bezelBackgroundFile)
		} Else {
			bezelBackgroundPath := BezelFilesPath("Background",bezelFileExtensions,false,If (bezelUseBackgrounds="true") ? true : false)
			If (bezelBackgroundPath)
			{ 	bezelBackgroundFileList := []
				Loop, Parse, bezelFileExtensions,|
					Loop, % bezelBackgroundPath . "\" . "Background*." . A_LoopField
						If (!(FileExist(bezelBackgroundPath . "\Bezel" . SubStr(A_LoopFileName,11,StrLen(A_LoopFileName)-14) . ".*")))
						bezelBackgroundFileList.Insert(A_LoopFileFullPath)
				Random, RndBezelBackground, 1, % bezelBackgroundFileList.MaxIndex()
				bezelBackgroundfile := bezelBackgroundFileList[RndBezelBackground]
				RLLog.Info(A_ThisFunc . " - Loading Background image: " . bezelBackgroundFile)
			}
		}
		pBrush := Gdip_BrushCreateSolid("0xff000000")
		If bezelBackgroundFile
			bezelBackgroundBitmap := Gdip_CreateBitmapFromFile(bezelBackgroundFile)
	}
	WinActivate, ahk_id %emulatorID%
	If ((prevbezelImageW=origbezelImageW) and (prevbezelImageH = origbezelImageH) and (prevbezelOrigIniScreenX1 = bezelOrigIniScreenX1) and (prevbezelOrigIniScreenY1 = bezelOrigIniScreenY1) and (prevbezelOrigIniScreenX2 = bezelOrigIniScreenX2) and (prevbezelOrigIniScreenY2 = bezelOrigIniScreenY2) )	{ ;just replace bezel image
		Gdip_GraphicsClear(Bezel_G5)
		If !(bezelImageFile = "fakeFullScreenBezel")
			Gdip_DrawImage(Bezel_G5, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)        
	} Else { ; recalculate everything bezel related
		bezelImageW := origbezelImageW 
		bezelImageH := origbezelImageH 
		bezelScreenX1 := bezelOrigIniScreenX1
		bezelScreenY1 := bezelOrigIniScreenY1
		bezelScreenX2 := bezelOrigIniScreenX2
		bezelScreenY2 := bezelOrigIniScreenY2
		ToggleMenu(emulatorID)
		If (bezelMode = "Normal")
			BezelCoordinates("Normal")
		Else If (bezelMode = "MultiScreens")
			BezelCoordinates("MultiScreens")
		BezelDraw()
	}
	;fade in
	startTime := A_TickCount
	Loop {
		t := If ((TimeElapsed := A_TickCount-startTime) < bezelChangeDur) ? (255*(timeElapsed/bezelChangeDur)) : 255
		If bezelBackgroundFile
			UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
		if (shaderObj)
			UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
		If (bezelOverlayFile) {
			If (bezelMode = "MultiScreens")
				UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
			Else
				UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight,t)	
		}
		UpdateLayeredWindow(Bezel_hwnd5, Bezel_hdc5, monitorTable[bezelMonitor].Left, monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height,t)
		WinSet, Transparent, %t%, ahk_id %emulatorID%
		If (t >= 255)
			Break
	}
	;making sure that everythign is drawn without extra transparencys
	Gdip_GraphicsClear(Bezel_G2)
	Gdip_Alt_FillRectangle(Bezel_G2, pBrush, -1, -1, monitorTable[bezelMonitor].Width+2, monitorTable[bezelMonitor].Height+2)
	If bezelBackgroundFile
		Gdip_DrawImage(Bezel_G2, bezelBackgroundBitmap, 0, 0,monitorTable[bezelMonitor].Width+1,monitorTable[bezelMonitor].Height+1)      
	UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
	if (shaderObj)
		UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
	If (bezelOverlayFile) {
		If (bezelMode = "MultiScreens")
			UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
		Else
			UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight)	
	}
	UpdateLayeredWindow(Bezel_hwnd5, Bezel_hdc5, monitorTable[bezelMonitor].Left, monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
	BezelChangeRunning := false
}	
Return


;Instruction Cards Code
toogleICVisibility:
	If ICVisibilityOn
		{
		gosub, DisableBezelKeys
		If ICRightMenuDraw 
			gosub, DisableICRightMenuKeys
		If ICLeftMenuDraw
			gosub, DisableICLeftMenuKeys
		XHotKeywrapper(toogleICVisibilityKey,"toogleICVisibility", "ON")
		startTime := A_TickCount
		Loop {
			t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight, round(255*t))
			If (t <= 0){
				Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight,  0)
				Break
			}
		}
		ICVisibilityOn := false
		} Else {
		gosub, EnableBezelKeys
		If ICRightMenuDraw 
			gosub, EnableICRightMenuKeys
		If ICLeftMenuDraw
			gosub, EnableICLeftMenuKeys
		startTime := A_TickCount
		Loop {
			t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((timeElapsed/ICChangeDur)) : 1
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight, round(255*t))
			If (t >= 1){
				Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
				Break
			}
		}
		ICVisibilityOn := true
	}
Return


nextIC1:
nextIC2:
nextIC3:
nextIC4:
nextIC5:
nextIC6:
nextIC7:
nextIC8:
previousIC1:
previousIC2:
previousIC3:
previousIC4:
previousIC5:
previousIC6:
previousIC7:
previousIC8:
	If %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
		Return
	}
	StringTrimRight, currentICChange, A_ThisLabel, 1
	StringRight, currentICChangeKeyPressed, A_ThisLabel, 1
	activeIC := 0
	ICindex := 0
	Loop, 8
		{
		If bezelICArray[a_index,1,1]
			ICindex++
		If (ICindex = currentICChangeKeyPressed)
			{
			activeIC := a_index
			Break
		}
	}
	If (currentICChange="nextIC"){
		gosub, nextIC		
	} Else {
		gosub, previousIC		
	}
Return
		
nextIC:
previousIC:
	If %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
		Return
	}
	prevSelectedICimage[activeIC] := selectedICimage[activeIC]
	If (A_ThisLabel="nextIC") {
		selectedICimage[activeIC] := selectedICimage[activeIC] + 1
		If (selectedICimage[activeIC] > maxICimage[activeIC]){
			selectedICimage[activeIC] := 0
		}
	} Else {
		selectedICimage[activeIC] := selectedICimage[activeIC] - 1
		If (selectedICimage[activeIC] < 0){
			selectedICimage[activeIC] := maxICimage[activeIC]
		}
	}
	DrawIC()
Return


changeActiveIC:
	If %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
		Return
	}
	Loop, 8 
		{
		activeIC++
		If (activeIC > 8)
		activeIC := 1
		If bezelICArray[activeIC,1,1] 
			Break
	}
	If selectedICimage[activeIC]
		{
		;grow effect
		GrowSize := 1
		While GrowSize <= 10 {
			Gdip_GraphicsClear(Bezel_G6)
			Loop, 8
				{
				If (a_index = activeIC) {
					ICposition(a_index,selectedICimage[a_index])
					Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1]-GrowSize, ICPositionArray[2]-GrowSize, bezelICArray[a_index,selectedICimage[a_index],3]+2*GrowSize, bezelICArray[a_index,selectedICimage[a_index],4]+2*GrowSize)
				} Else {
					If bezelICArray[a_index,selectedICimage[a_index],1] 
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])    
					}
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
			GrowSize++
		}
		;reset
		Gdip_GraphicsClear(Bezel_G6)
		Loop, 8
			{
			If bezelICArray[a_index,selectedICimage[a_index],1] 
				{
				ICposition(a_index,selectedICimage[a_index])
				Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
			}
		}
		Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
	}
Return


DrawIC(){
	Global
	If (animationIC="none"){
		Gdip_GraphicsClear(Bezel_G6)
		If changeICSound
			SoundPlay, %changeICSound%
		Loop, 8
			{
			If bezelICArray[a_index,selectedICimage[a_index],1]
				{
				ICposition(a_index,selectedICimage[a_index])
				Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
			}
		}
		Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
	} Else If (animationIC="fade"){ 
		;fade out
		If prevSelectedICimage[activeIC]
			{
			If fadeOutICSound
				SoundPlay, %fadeOutICSound%
			startTime := A_TickCount
			Loop {
				Gdip_GraphicsClear(Bezel_G6)
				t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
				Loop, 8
					{
					If (activeIC = a_index) {
						ICposition(a_index,prevselectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,prevselectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,prevselectedICimage[a_index],3], bezelICArray[a_index,prevselectedICimage[a_index],4],"","","","",t)   
					} Else {
						If bezelICArray[a_index,selectedICimage[a_index],1]
							{
							ICposition(a_index,selectedICimage[a_index])
							Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
						}
					}
				}
				Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
				If (t <= 0)
					Break
			}
		}	
		;fade in
		If fadeInICSound
				SoundPlay, %fadeInICSound%
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G6)
			t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((timeElapsed/ICChangeDur)) : 1
			Loop, 8
				{
				If (activeIC = a_index) {
					ICposition(a_index,selectedICimage[a_index])
					Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4],"","","","",t) 
				} Else {
					If bezelICArray[a_index,selectedICimage[a_index],1]
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
					}
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
			If (t >= 1)
				Break
		}			
	} Else If (animationIC="slideOutandIn"){
		; slide out
		If prevSelectedICimage[activeIC]
			{
			If slideOutICSound
				SoundPlay, %slideOutICSound%
			startTime := A_TickCount
			Loop {
				Gdip_GraphicsClear(Bezel_G6)
				t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((timeElapsed/ICChangeDur)) : 1
				Loop, 8
					{
					If (activeIC = a_index) {
						ICposition(a_index,prevselectedICimage[a_index],t)
						Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,prevselectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,prevselectedICimage[a_index],3], bezelICArray[a_index,prevselectedICimage[a_index],4])
					} Else {
						If bezelICArray[a_index,selectedICimage[a_index],1]
							{
							ICposition(a_index,selectedICimage[a_index])
							Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
						}						
					}
				}
				Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
				If (t >= 1)
					Break
			}
		}
		; slide in
		If slideInICSound
			SoundPlay, %slideInICSound%
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G6)
			t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
			Loop, 8
				{
				If (a_index = activeIC) {
					ICposition(a_index,selectedICimage[a_index],t)
					Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
				} Else {
					If bezelICArray[a_index,selectedICimage[a_index],1]
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
					}						
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
			If (t <= 0)
				Break
		}
	} Else If (animationIC="slideIn"){
		; slide in
		If slideInICSound
			SoundPlay, %slideInICSound%
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G6)
			t := If ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
			Loop, 8
				{
				If (a_index = activeIC) {
					ICposition(a_index,selectedICimage[a_index],t)
					Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
				} Else {
					If bezelICArray[a_index,selectedICimage[a_index],1]
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G6, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
					}						
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, baseScreenWidth, baseScreenHeight)
			If (t <= 0)
				Break
		}	
	}
Return
}

ICposition(ICSelectedIndex,ICImageSelectedIndex, step := "0"){
	Global
	If not ICPositionArray
		ICPositionArray := []
	If (positionICArray%ICSelectedIndex% = "topLeft") {
		ICPositionArray[1] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := 0	
	} Else If (positionICArray%ICSelectedIndex% = "topRight") {
		ICPositionArray[1] := round( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := 0		
	} Else If (positionICArray%ICSelectedIndex% = "bottomLeft") {
		ICPositionArray[1] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] ) 			
	} Else If (positionICArray%ICSelectedIndex% = "bottomRight") {
		ICPositionArray[1] := round( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] )			
	} Else If (positionICArray%ICSelectedIndex% = "topCenter") {
		ICPositionArray[1] := round( baseScreenWidth//2 - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3]//2 )
		ICPositionArray[2] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] )
	} Else If (positionICArray%ICSelectedIndex% = "leftCenter") {
		ICPositionArray[1] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( ( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] ) // 2 )								
	} Else If (positionICArray%ICSelectedIndex% = "rightCenter") {
		ICPositionArray[1] := round( ( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] ) + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( ( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] ) // 2 )											
	} Else { ; bottomCenter
		ICPositionArray[1] := round( ( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] ) // 2 )
		ICPositionArray[2] := round( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] )			
	}
Return  ICPositionArray
}


;IC Menu code

rightICMenu:
leftICMenu:
	If %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
	}
	If (A_ThisLabel="rightICMenu") {
		If ICRightMenuDraw
			{
			gosub, DisableICRightMenuKeys
			SetTimer, UpdatecurrentRightICScrollingText, off
			Gdip_GraphicsClear(Bezel_G9)
			Gdip_GraphicsClear(Bezel_G10)
			Alt_UpdateLayeredWindow(Bezel_hwnd9, Bezel_hdc9, monitorTable[bezelMonitor].Left+baseScreenWidth-bezelICRightMenuBitmapW, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICRightMenuBitmapH)//2, bezelICRightMenuBitmapW, bezelICRightMenuBitmapH)
			Alt_UpdateLayeredWindow(Bezel_hwnd10, Bezel_hdc10, monitorTable[bezelMonitor].Left+baseScreenWidth-ICMenuListX-ICMenuListWidth, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-ICMenuListTextSize//2, ICMenuListWidth, ICMenuListTextSize)				
			ICRightMenuDraw := false
		} Else {
			DrawICMenu("right")
			gosub, EnableICRightMenuKeys
			ICRightMenuDraw := true
		}
    } Else {
		If ICLeftMenuDraw
			{
			gosub, DisableICLeftMenuKeys
			SetTimer, UpdatecurrentLeftICScrollingText, off
			Gdip_GraphicsClear(Bezel_G7)
			Gdip_GraphicsClear(Bezel_G8)
			Alt_UpdateLayeredWindow(Bezel_hwnd7, Bezel_hdc7, monitorTable[bezelMonitor].Left, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2, bezelICLeftMenuBitmapW, bezelICLeftMenuBitmapH)
			Alt_UpdateLayeredWindow(Bezel_hwnd8, Bezel_hdc8, monitorTable[bezelMonitor].Left+ICMenuListX, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-ICMenuListTextSize//2, ICMenuListWidth, ICMenuListTextSize)
			ICLeftMenuDraw := false
		} Else {
			DrawICMenu("left")
			gosub, EnableICLeftMenuKeys
			ICLeftMenuDraw := true
		}
	}
Return

rightICMenuUp:
rightICMenuDown:
rightICMenuLeft:
rightICMenuRight:
leftICMenuUp:
leftICMenuDown:
leftICMenuLeft:
leftICMenuRight:
	If InStr(A_ThisLabel,"MenuUp"){
		If InStr(A_ThisLabel,"rightIC"){
				selectedRightMenuItem[rightMenuActiveIC] := selectedRightMenuItem[rightMenuActiveIC] + 1
			If (selectedRightMenuItem[rightMenuActiveIC] > maxICimage[rightMenuActiveIC])
				selectedRightMenuItem[rightMenuActiveIC] := 0	
		} Else { ;left
				selectedLeftMenuItem[leftMenuActiveIC] := selectedLeftMenuItem[leftMenuActiveIC] + 1
			If (selectedLeftMenuItem[leftMenuActiveIC] > maxICimage[leftMenuActiveIC])
				selectedLeftMenuItem[leftMenuActiveIC] := 0			
		}
	} Else If InStr(A_ThisLabel,"MenuDown"){
		If InStr(A_ThisLabel,"rightIC"){
			selectedRightMenuItem[rightMenuActiveIC] := selectedRightMenuItem[rightMenuActiveIC] - 1
			If (selectedRightMenuItem[rightMenuActiveIC] < 0)
				selectedRightMenuItem[rightMenuActiveIC] := maxICimage[rightMenuActiveIC]	
		} Else { ;left
			selectedLeftMenuItem[leftMenuActiveIC] := selectedLeftMenuItem[leftMenuActiveIC] - 1
			If (selectedLeftMenuItem[leftMenuActiveIC] < 0)
				selectedLeftMenuItem[leftMenuActiveIC] := maxICimage[leftMenuActiveIC]			
		}		
	} Else If InStr(A_ThisLabel,"MenuLeft"){ ;left key
		If InStr(A_ThisLabel,"rightIC"){ ;right menu
			Loop, 8
				{
				rightMenuActiveIC--
				If (rightMenuActiveIC < 1)
					rightMenuActiveIC := 8
				If bezelICArray[rightMenuActiveIC,1,1] 
					If positionICArray%rightMenuActiveIC% in %rightMenuPositionsIC% 
						Break
			}
		} Else { ;left menu key
			Loop, 8
				{
				leftMenuActiveIC--
				If (leftMenuActiveIC < 1)
					leftMenuActiveIC := 8
				If bezelICArray[leftMenuActiveIC,1,1] 
					If positionICArray%leftMenuActiveIC% in %leftMenuPositionsIC% 
						Break
			}		
		}
	} Else { ;Right key
		If InStr(A_ThisLabel,"rightIC"){ ;right menu
			Loop, 8 
				{
				rightMenuActiveIC++
				If (rightMenuActiveIC > 8)
					rightMenuActiveIC := 1
				If bezelICArray[rightMenuActiveIC,1,1] 
					If positionICArray%rightMenuActiveIC% in %rightMenuPositionsIC% 
						Break
			}
		} Else { ;left menu key
			Loop, 8
				{
				leftMenuActiveIC++
				If (leftMenuActiveIC > 8)
					leftMenuActiveIC := 1
				If bezelICArray[leftMenuActiveIC,1,1] 
					If positionICArray%leftMenuActiveIC% in %leftMenuPositionsIC% 
						Break
			}		
		}
	}
	If InStr(A_ThisLabel,"rightIC")
		DrawICMenu("right")
	Else ; left
		DrawICMenu("left")
Return


rightICMenuSelect:
leftICMenuSelect:
	If InStr(A_ThisLabel,"rightIC"){
		activeIC := rightMenuActiveIC
		selectedICimage[activeIC] := selectedRightMenuItem[rightMenuActiveIC]
		DrawIC()
		DrawICMenu("right")
	} Else { ; left
		activeIC := leftMenuActiveIC
		selectedICimage[activeIC] := selectedLeftMenuItem[leftMenuActiveIC]
		DrawIC()
		DrawICMenu("left")
	}
Return


DrawICMenu(side){
	Global 
	;Initializing parameters
	ICMenuListTextFont := IC%side%MenuListTextFont 
	ICMenuListTextAlignment := IC%side%MenuListTextAlignment
	ICMenuListTextSize := IC%side%MenuListTextSize 
	ICMenuListTextColor := IC%side%MenuListTextColor
	ICMenuListDisabledTextColor := IC%side%MenuListDisabledTextColor
	ICMenuListCurrentTextColor := IC%side%MenuListCurrentTextColor 
	ICMenuListDisabledTextSize   := IC%side%MenuListDisabledTextSize 
	ICMenuListItems := IC%side%MenuListItems
	ICMenuListX := IC%side%MenuListX
	ICMenuListY := IC%side%MenuListY
	ICMenuListWidth := IC%side%MenuListWidth 
	ICMenuListHeight := IC%side%MenuListHeight
	ICMenuPositionTextFont := IC%side%MenuPositionTextFont
	ICMenuPositionTextSize := IC%side%MenuPositionTextSize 
	ICMenuPositionTextColor := IC%side%MenuPositionTextColor
	ICMenuPositionTextX := IC%side%MenuPositionTextX
	ICMenuPositionTextY := IC%side%MenuPositionTextY
	ICMenuPositionTextWidth := IC%side%MenuPositionTextWidth
	ICMenuPositionTextHeight := IC%side%MenuPositionTextHeight
	ICMenuPositionTextAlignment := IC%side%MenuPositionTextAlignment
	VDistBtwICNames := ICMenuListHeight//(ICMenuListItems+1)
	menuActiveIC := %side%MenuActiveIC
	menuSelectedItem[menuActiveIC] := If selected%side%MenuItem[menuActiveIC] ? selected%side%MenuItem[menuActiveIC] : 0 
	;Drawing Menu Image
	If (side="left"){
		Gdip_GraphicsClear(Bezel_G7)
		Gdip_GraphicsClear(Bezel_G8)
		Gdip_Alt_DrawImage(Bezel_G7, bezelICLeftMenuBitmap, 0, 0, bezelICLeftMenuBitmapW, bezelICLeftMenuBitmapH)
		Gdip_Alt_TextToGraphics(Bezel_G7, positionICArray%leftMenuActiveIC%, "x" . ICMenuPositionTextX . " y" . ICMenuPositionTextY . " " . ICMenuPositionTextAlignment . " c" . ICMenuPositionTextColor . " r4 s" . ICMenuPositionTextSize . " normal", ICMenuPositionTextFont, ICMenuPositionTextWidth, ICMenuPositionTextHeight)
	} Else {
		Gdip_GraphicsClear(Bezel_G9)
		Gdip_GraphicsClear(Bezel_G10)
		Gdip_Alt_DrawImage(Bezel_G9, bezelICRightMenuBitmap, 0, 0, bezelICRightMenuBitmapW, bezelICRightMenuBitmapH)
		Gdip_Alt_TextToGraphics(Bezel_G9, positionICArray%rightMenuActiveIC%, "x" . ICMenuPositionTextX . " y" . ICMenuPositionTextY . " " . ICMenuPositionTextAlignment . " c" . ICMenuPositionTextColor . " r4 s" . ICMenuPositionTextSize . " normal", ICMenuPositionTextFont, ICMenuPositionTextWidth, ICMenuPositionTextHeight)
	}
	;Drawing IC List
	bottomtext := menuSelectedItem[menuActiveIC]
	topText := menuSelectedItem[menuActiveIC]
	Loop, % ICMenuListItems//2+1
		{
		If (a_index=1)
			{
			currentSelectedColor%side% := If (menuSelectedItem[menuActiveIC] = selectedICimage[menuActiveIC]) ? ICMenuListCurrentTextColor : ICMenuListTextColor
			currentSelectedLabel%side% := bezelICArray[menuActiveIC,menuSelectedItem[menuActiveIC],5]
			MeasureCurrentSelectedIC := MeasureText(currentSelectedLabel%side%, "Left r4 s" . ICMenuListTextSize . " bold",ICMenuListTextFont)
			If (MeasureCurrentSelectedIC <= ICMenuListWidth) {
				TextOptions := "x0 y0 " . ICMenuListTextAlignment . " c" . currentSelectedColor%side% . " r4 s" . ICMenuListTextSize . " bold"
				If (side="left") {
					SetTimer, UpdatecurrentLeftICScrollingText, off
					Gdip_GraphicsClear(Bezel_G8)
					Gdip_Alt_TextToGraphics(Bezel_G8, currentSelectedLabel%side%, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListTextSize)
				} Else {
					SetTimer, UpdatecurrentRightICScrollingText, off
					Gdip_GraphicsClear(Bezel_G10)
					Gdip_Alt_TextToGraphics(Bezel_G10, currentSelectedLabel%side%, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListTextSize)
				}
			} Else {	
				If (side="left"){
					initLeftPixels := 0
					xLeft := 0
					SetTimer, UpdatecurrentLeftICScrollingText, 20
				} Else {
					initRightPixels := 0
					xRight := 0
					SetTimer, UpdatecurrentRightICScrollingText, 20
				}
			}
		} Else {		
			bottomtext++
			bottomtext := If (bottomtext > maxICimage[menuActiveIC]) ? 0 : bottomtext
			currentColor := If (bottomtext = selectedICimage[menuActiveIC]) ? ICMenuListCurrentTextColor : ICMenuListDisabledTextColor
			currentLabel := bezelICArray[menuActiveIC,bottomtext,5]
			TextOptions := "x" . ICMenuListX . " y" . ICMenuListY+ICMenuListHeight//2-(a_index-1)*(VDistBtwICNames)-ICMenuListDisabledTextSize//2 . " " . ICMenuListTextAlignment . " c" . currentColor . " r4 s" . ICMenuListDisabledTextSize . " normal"
			If (side="left"){
				Gdip_Alt_TextToGraphics(Bezel_G7, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			} Else {
				Gdip_Alt_TextToGraphics(Bezel_G9, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			}
			topText--
			topText := If (topText < 0) ? maxICimage[menuActiveIC] : topText
			currentColor := If (topText = selectedICimage[menuActiveIC]) ? ICMenuListCurrentTextColor : ICMenuListDisabledTextColor
			currentLabel := bezelICArray[menuActiveIC,topText,5]
			TextOptions := "x" . ICMenuListX . " y" . ICMenuListY+ICMenuListHeight//2+(a_index-1)*(VDistBtwICNames)-ICMenuListDisabledTextSize//2 . " " . ICMenuListTextAlignment . " c" . currentColor . " r4 s" . ICMenuListDisabledTextSize . " normal"
			If (side="left"){
				Gdip_Alt_TextToGraphics(Bezel_G7, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			} Else {
				Gdip_Alt_TextToGraphics(Bezel_G9, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			}
		}
	}
	If (side="left"){
		Alt_UpdateLayeredWindow(Bezel_hwnd7, Bezel_hdc7, monitorTable[bezelMonitor].Left, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2, bezelICLeftMenuBitmapW, bezelICLeftMenuBitmapH)
		Alt_UpdateLayeredWindow(Bezel_hwnd8, Bezel_hdc8, monitorTable[bezelMonitor].Left+ICMenuListX, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)
	} Else {
		Alt_UpdateLayeredWindow(Bezel_hwnd9, Bezel_hdc9, monitorTable[bezelMonitor].Left+baseScreenWidth-bezelICRightMenuBitmapW, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICRightMenuBitmapH)//2, bezelICRightMenuBitmapW, bezelICRightMenuBitmapH)
		Alt_UpdateLayeredWindow(Bezel_hwnd10, Bezel_hdc10, monitorTable[bezelMonitor].Left+baseScreenWidth-bezelICRightMenuBitmapW+ICMenuListX, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)				
	}		
Return	
}

UpdatecurrentLeftICScrollingText: ;Updating scrolling IC name
    Options = y0 c%currentSelectedColorLeft% r4 s%ICMenuListTextSize% bold
	scrollingVelocity := 2
	xLeft := (-xLeft >= E3) ? initLeftPixels : xLeft-scrollingVelocity
	initLeftPixels := ICLeftMenuListWidth
    Gdip_GraphicsClear(Bezel_G8)
    E := Gdip_Alt_TextToGraphics(Bezel_G8, currentSelectedLabelLeft, "x" xLeft " " Options, ICMenuListTextFont, (xLeft < 0) ? ICLeftMenuListWidth-xLeft : ICLeftMenuListWidth, ICMenuListTextSize)
    StringSplit, E, E, |
	Alt_UpdateLayeredWindow(Bezel_hwnd8, Bezel_hdc8, monitorTable[bezelMonitor].Left+ICMenuListX, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)
Return

UpdatecurrentRightICScrollingText: ;Updating scrolling IC name
    Options = y0 c%currentSelectedColorRight% r4 s%ICMenuListTextSize% bold
	scrollingVelocity := 2
	xRight := (-xRight >= E3) ? initRightPixels : xRight-scrollingVelocity
	initRightPixels := ICRightMenuListWidth
    Gdip_GraphicsClear(Bezel_G10)
    E := Gdip_Alt_TextToGraphics(Bezel_G10, currentSelectedLabelRight, "x" xRight " " Options, ICMenuListTextFont, (xRight < 0) ? ICRightMenuListWidth-xRight : ICRightMenuListWidth, ICMenuListTextSize)
    StringSplit, E, E, |
	Alt_UpdateLayeredWindow(Bezel_hwnd10, Bezel_hdc10, monitorTable[bezelMonitor].Left+baseScreenWidth-bezelICRightMenuBitmapW+ICMenuListX, monitorTable[bezelMonitor].Top+(baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)
Return



randomICChange:
	Loop, 8
		{
		If 	maxICimage[a_index]
			{
			activeIC := a_index
			Random, ICImage, 1, % maxICimage[activeIC]
			selectedICimage[activeIC] := ICImage
			DrawIC()
		}
	}
Return


EnableBezelKeys:
	If bezelICPath
		{
		If toogleICVisibilityKey
			XHotKeywrapper(toogleICVisibilityKey,"toogleICVisibility", "ON")
		If nextICKey
			XHotKeywrapper(nextICKey,"nextIC", "ON")
		If previousICKey
			XHotKeywrapper(previousICKey,"previousIC", "ON")
		If changeActiveICKey
			XHotKeywrapper(changeActiveICKey,"changeActiveIC", "ON")
		Loop, 8
			{
			If nextIC%a_index%Key
				XHotKeywrapper(nextIC%a_index%Key,"nextIC" . A_Index, "ON")
			If previousIC%a_index%Key
				XHotKeywrapper(previousIC%a_index%Key,"previousIC" . A_Index, "ON")
		}
		If leftICMenuKey
			XHotKeywrapper(leftICMenuKey,"leftICMenu", "ON")
		If rightICMenuKey
			XHotKeywrapper(rightICMenuKey,"rightICMenu", "ON")
	}		
	If (bezelImagesList.MaxIndex() > 1) {
		If nextBezelKey
			XHotKeywrapper(nextBezelKey,"nextBezel", "ON")
		If previousBezelKey
			XHotKeywrapper(previousBezelKey,"previousBezel", "ON")
	} 
    RLLog.Trace(A_ThisLabel . " - Bezel Keys Enabled")
Return


DisableBezelKeys:
	If bezelICPath
		{
		If toogleICVisibilityKey
			XHotKeywrapper(toogleICVisibilityKey,"toogleICVisibility", "OFF")
		If nextICKey
			XHotKeywrapper(nextICKey,"nextIC", "OFF")
		If previousICKey
			XHotKeywrapper(previousICKey,"previousIC", "OFF")
		If changeActiveICKey
			XHotKeywrapper(changeActiveICKey,"changeActiveIC", "OFF")
		Loop, 8
			{
			If nextIC%a_index%Key
				XHotKeywrapper(nextIC%a_index%Key,"nextIC" . A_Index, "OFF")
			If previousIC%a_index%Key
				XHotKeywrapper(previousIC%a_index%Key,"previousIC" . A_Index, "OFF")
		}
		If leftICMenuKey
			XHotKeywrapper(leftICMenuKey,"leftICMenu", "OFF")
		If rightICMenuKey
			XHotKeywrapper(rightICMenuKey,"rightICMenu", "OFF")
	}		
	If (bezelImagesList.MaxIndex() > 1) {
		If nextBezelKey
			XHotKeywrapper(nextBezelKey,"nextBezel", "OFF")
		If previousBezelKey
			XHotKeywrapper(previousBezelKey,"previousBezel", "OFF")
	} 
    RLLog.Trace(A_ThisLabel . " - Bezel Keys Disabled")
Return

EnableICRightMenuKeys:
	XHotKeywrapper(navP2SelectKey,"rightICMenuSelect","ON") 
	XHotKeywrapper(navP2LeftKey,"rightICMenuLeft","ON")
	XHotKeywrapper(navP2RightKey,"rightICMenuRight","ON")
	XHotKeywrapper(navP2UpKey,"rightICMenuUp","ON")
	XHotKeywrapper(navP2DownKey,"rightICMenuDown","ON")
Return

DisableICRightMenuKeys:
	XHotKeywrapper(navP2SelectKey,"rightICMenuSelect","OFF") 
	XHotKeywrapper(navP2LeftKey,"rightICMenuLeft","OFF")
	XHotKeywrapper(navP2RightKey,"rightICMenuRight","OFF")
	XHotKeywrapper(navP2UpKey,"rightICMenuUp","OFF")
	XHotKeywrapper(navP2DownKey,"rightICMenuDown","OFF")
Return

EnableICLeftMenuKeys:
	XHotKeywrapper(navSelectKey,"leftICMenuSelect","ON") 
	XHotKeywrapper(navLeftKey,"leftICMenuLeft","ON")
	XHotKeywrapper(navRightKey,"leftICMenuRight","ON")
	XHotKeywrapper(navUpKey,"leftICMenuUp","ON")
	XHotKeywrapper(navDownKey,"leftICMenuDown","ON")
Return

DisableICLeftMenuKeys:
	XHotKeywrapper(navSelectKey,"leftICMenuSelect","OFF") 
	XHotKeywrapper(navLeftKey,"leftICMenuLeft","OFF")
	XHotKeywrapper(navRightKey,"leftICMenuRight","OFF")
	XHotKeywrapper(navUpKey,"leftICMenuUp","OFF")
	XHotKeywrapper(navDownKey,"leftICMenuDown","OFF")
Return


ExtraFixedResBezelGUI(){
	Global bezelEnabled, extraFixedRes_Bezel_hbm, extraFixedRes_Bezel_hdc, extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_G, monitorTable, bezelMonitor
	If (bezelEnabled = "true"){
		;Gui, extraFixedRes_Bezel_GUI: +OwnerBezel_GUI8 +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Gui, extraFixedRes_Bezel_GUI: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Gui, extraFixedRes_Bezel_GUI: Margin,0,0
		Gui, extraFixedRes_Bezel_GUI: Show,, BezelLayer11
		extraFixedRes_Bezel_hwnd := WinExist()
	}
}


ExtraFixedResBezelDraw(extraFixedResScreenID, filePreffix:="VMU", extraFixedResPosition:="TopRight",extraFixedResBezelScreenWidth:=80,extraFixedResBezelScreenHeight:=60,extraFixedResBezelRightOffset:=0,extraFixedResBezelLeftOffset:=0,extraFixedResBezelTopOffset:=0,extraFixedResBezelBottomOffset:=0){
	Global bezelEnabled, bezelPath, extraFixedRes_Bezel_hbm, extraFixedRes_Bezel_hdc, extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_G, bezelFileExtensions, monitorTable, bezelMonitor, extraFixedBezelLoaded 
	If ((bezelEnabled = "true") and (bezelPath)){
		If !(extraFixedBezelLoaded){
			extraFixedRes_Bezel_hbm := CreateDIBSection(monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
			extraFixedRes_Bezel_hdc := CreateCompatibleDC()
			extraFixedRes_Bezel_obm := SelectObject(extraFixedRes_Bezel_hdc, extraFixedRes_Bezel_hbm)
			extraFixedRes_Bezel_G := Gdip_GraphicsFromhdc(extraFixedRes_Bezel_hdc)
			Gdip_SetSmoothingMode(extraFixedRes_Bezel_G, 4)
			extraFixedBezelLoaded := true
		}
		;Check for extraFixedRes bezel file:
		extraFixedResBezelPath := BezelFilesPath(filePreffix . " Bezel",bezelFileExtensions)
		If extraFixedResBezelPath 
			{	;Setting bezel aleatory choosed file
			extraFixedResbezelImagesList := []
			Loop, Parse, bezelFileExtensions,|
				Loop, % extraFixedResBezelPath . "\" . filePreffix . " Bezel*." . A_LoopField
					If !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
						extraFixedResBezelImagesList.Insert(A_LoopFileFullPath)
			Random, RndmextraFixedResBezel, 1, % extraFixedResBezelImagesList.MaxIndex()
			extraFixedResBezelImageFile := extraFixedResBezelImagesList[RndmextraFixedResBezel]
			SplitPath, extraFixedResBezelImageFile, extraFixedResBezelImageFileName, extraFixedResBezelImageDir,,extraFixedResBezelImageFileNameNoExt
			RLLog.Info(A_ThisFunc . " - Loading extraFixedRes Bezel image: " . extraFixedResBezelImageFile)
			;Setting overlay aleatory choosed file (only searches overlays at the bezel.png folder)
			If FileExist(extraFixedResBezelPath . "\" . filePreffix . " Overlay" . SubStr(extraFixedResBezelImageFileName,StrLen(filePreffix)+7)) {
				extraFixedResBezelOverlaysList := []
				extraFixedResBezelOverlaysList.Insert(extraFixedResBezelPath . "\" . filePreffix . " Overlay" . SubStr(extraFixedResBezelImageFileName,StrLen(filePreffix)+7))
				extraFixedResBezelOverlayFile := % extraFixedResBezelPath . "\" . filePreffix . " Overlay" . SubStr(extraFixedResBezelImageFileName,StrLen(filePreffix)+7)
				extraFixedResBezelOverlayBitmap := Gdip_CreateBitmapFromFile(extraFixedResBezelOverlayFile)
				RLLog.Info(A_ThisFunc . " - Loading extraFixedRes Overlay image with the same name of the extraFixedRes bezel image: " . extraFixedResBezelOverlayFile)
			}
			;Read extraFixedRes Bezel ini coordinates
			extraFixedResBezelScreenX1 := IniReadCheck(extraFixedResBezelImageDir . "\" . extraFixedResBezelImageFileNameNoExt . ".ini", "General", "Bezel Screen Top Left X Coordinate", 0)
			extraFixedResBezelScreenY1 := IniReadCheck(extraFixedResBezelImageDir . "\" . extraFixedResBezelImageFileNameNoExt . ".ini", "General", "Bezel Screen Top Left Y Coordinate", 0)
			extraFixedResBezelScreenX2 := IniReadCheck(extraFixedResBezelImageDir . "\" . extraFixedResBezelImageFileNameNoExt . ".ini", "General", "Bezel Screen Bottom Right X Coordinate", 150)
			extraFixedResBezelScreenY2 := IniReadCheck(extraFixedResBezelImageDir . "\" . extraFixedResBezelImageFileNameNoExt . ".ini", "General", "Bezel Screen Bottom Right Y Coordinate", 100)
			; creating bitmap pointers
			extraFixedResBezelBitmap := Gdip_CreateBitmapFromFile(extraFixedResBezelImageFile)
			Gdip_GetImageDimensions(extraFixedResBezelBitmap, extraFixedResBezelImageW, extraFixedResBezelImageH)
			xScaleFactor := (extraFixedResBezelScreenWidth)/(extraFixedResBezelScreenX2-extraFixedResBezelScreenX1)
			yScaleFactor := (extraFixedResBezelScreenHeight)/(extraFixedResBezelScreenY2-extraFixedResBezelScreenY1)
			extraFixedResBezelImageW := Round(extraFixedResBezelImageW * xScaleFactor)
			extraFixedResBezelImageH := Round(extraFixedResBezelImageH * yScaleFactor) 
			If (extraFixedResPosition="TopRight")
				extraFixedResBezelImageX := monitorTable[bezelMonitor].Width - extraFixedResBezelImageW , extraFixedResBezelImageY := 0
			Else If (extraFixedResPosition="TopCenter")
				extraFixedResBezelImageX := (monitorTable[bezelMonitor].Width - extraFixedResBezelImageW)//2 , extraFixedResBezelImageY := 0				
			Else If (extraFixedResPosition="TopLeft") 
				extraFixedResBezelImageX := 0 , extraFixedResBezelImageY := 0	
			Else If (extraFixedResPosition="LeftCenter")
				extraFixedResBezelImageX := 0 , extraFixedResBezelImageY := (monitorTable[bezelMonitor].Height - extraFixedResBezelImageH)//2									
			Else If (extraFixedResPosition="BottomRight")
				extraFixedResBezelImageX := monitorTable[bezelMonitor].Width - extraFixedResBezelImageW , extraFixedResBezelImageY := monitorTable[bezelMonitor].Height - extraFixedResBezelImageH	
			Else If (extraFixedResPosition="BottomCenter")
				extraFixedResBezelImageX := (monitorTable[bezelMonitor].Width - extraFixedResBezelImageW)//2 , extraFixedResBezelImageY := monitorTable[bezelMonitor].Height - extraFixedResBezelImageH					
			Else If (extraFixedResPosition="BottomLeft")
				extraFixedResBezelImageX := 0 , extraFixedResBezelImageY := monitorTable[bezelMonitor].Height - extraFixedResBezelImageH					
			Else ; Right Center
				extraFixedResBezelImageX := monitorTable[bezelMonitor].Width - extraFixedResBezelImageW , extraFixedResBezelImageY := (monitorTable[bezelMonitor].Height - extraFixedResBezelImageH)//2
			extraFixedResBezelScreenX := extraFixedResBezelImageX + Round(extraFixedResBezelScreenX1*xScaleFactor)
			extraFixedResBezelScreenY := extraFixedResBezelImageY + Round(extraFixedResBezelScreenY1*yScaleFactor) 
			; Applying offsets to correctly place the emulator If the emulator has extra window components
			extraFixedResBezelScreenX := If extraFixedResBezelLeftOffset ? extraFixedResBezelScreenX - extraFixedResBezelLeftOffset : extraFixedResBezelScreenX
			extraFixedResBezelScreenY := If extraFixedResBezelTopOffset ? extraFixedResBezelScreenY - extraFixedResBezelTopOffset : extraFixedResBezelScreenY
			;Displacing Bezel to chosen monitor origin
			extraFixedResBezelScreenX := monitorTable[bezelMonitor].Left+extraFixedResBezelScreenX
			extraFixedResBezelScreenY := monitorTable[bezelMonitor].Top+extraFixedResBezelScreenY
			; check If window moved (maximun 5 seconds)
			X:="" , Y:="" , timeout := A_TickCount
			Sleep, 200
			Loop
				{
				Sleep, 50
				WinGetPos, X, Y, , , ahk_id %extraFixedResScreenID%
				If (X=extraFixedResBezelScreenX) and (Y=extraFixedResBezelScreenY) 
					Break
				if(timeout < A_TickCount - 5000)
					Break
				Sleep, 50
				WinMove, ahk_id %extraFixedResScreenID%, , %extraFixedResBezelScreenX%, %extraFixedResBezelScreenY%
			}
			;Drawing extraFixedRes Bezel GUI
			Gdip_DrawImage(extraFixedRes_Bezel_G, extraFixedResBezelBitmap, extraFixedResBezelImageX, extraFixedResBezelImageY,extraFixedResBezelImageW,extraFixedResBezelImageH)        
			RLLog.Trace(A_ThisFunc . " - extraFixedRes Bezel Image Screen Position: left=" . extraFixedResBezelImageX . " top=" . extraFixedResBezelImageY . " right=" . (extraFixedResBezelImageX+extraFixedResBezelImageW) . " bottom=" . (extraFixedResBezelImageY+extraFixedResBezelImageH))
			;Drawing Overlay Image above screen
			If (extraFixedResBezelOverlayFile)
			{	Gdip_DrawImage(extraFixedRes_Bezel_G, extraFixedResBezelOverlayBitmap, extraFixedResBezelImageX+Round(extraFixedResBezelScreenX1*xScaleFactor), extraFixedResBezelImageY+Round(extraFixedResBezelScreenY1*yScaleFactor) ,extraFixedResBezelScreenWidth,extraFixedResBezelScreenHeight)   
				RLLog.Trace(A_ThisFunc . " - extraFixedRes Overlay Screen Position: left=" . extraFixedResBezelImageX+Round(extraFixedResBezelScreenX1*xScaleFactor) . " top=" . extraFixedResBezelImageY+Round(extraFixedResBezelScreenY1*yScaleFactor) . " right=" . extraFixedResBezelImageX+(Round(extraFixedResBezelScreenX1*xScaleFactor)+extraFixedResBezelScreenWidth) . " bottom=" . extraFixedResBezelImageY+Round(extraFixedResBezelScreenY1*yScaleFactor)+extraFixedResBezelScreenHeight)
			}
			UpdateLayeredWindow(extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_hdc,monitorTable[bezelMonitor].Left,monitorTable[bezelMonitor].Top, monitorTable[bezelMonitor].Width, monitorTable[bezelMonitor].Height)
		}
		RLLog.Info(A_ThisFunc . " - Ended")
	}
Return
}

ExtraFixedResBezelExit(){
	Global bezelEnabled, extraFixedResBezelPath, extraFixedRes_Bezel_hbm, extraFixedRes_Bezel_obm, extraFixedRes_Bezel_hdc, extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_G, extraFixedResBezelImageFile, extraFixedResBezelBitmap, extraFixedResBezelOverlayFile, extraFixedResBezelOverlayBitmap
	If (bezelEnabled = "true"){
		SelectObject(extraFixedRes_Bezel_hdc, extraFixedRes_Bezel_obm)
		DeleteObject(extraFixedRes_Bezel_hbm)
		DeleteDC(extraFixedRes_Bezel_hdc)
		Gdip_DeleteGraphics(extraFixedRes_Bezel_G)
		Gui, extraFixedRes_Bezel_GUI: Destroy
		If extraFixedResBezelPath 
		{	If extraFixedResBezelImageFile
				Gdip_DisposeImage(extraFixedResBezelBitmap)
			If extraFixedResBezelOverlayFile
				Gdip_DisposeImage(extraFixedResBezelOverlayBitmap)	
		}
	}
Return
}

CreateICMenuBitmap(side){
	Global RLMediaPath
	pBitmap := Gdip_CreateBitmap(300, 400)
	G := Gdip_GraphicsFromImage(pBitmap)
	pBrush := Gdip_BrushCreateSolid("0xff000000")
	Gdip_FillRectangle(G, pBrush, 0, 0, 300, 400)
	pBrush2 := Gdip_BrushCreateSolid("0xffffffff")
	Gdip_FillRectangle(G, pBrush2, 20, 20, 260, 360)
	Gdip_DeleteBrush(pBrush)
	Gdip_DeleteBrush(pBrush2)
	Gdip_SaveBitmapToFile(pBitmap, RLMediaPath . "\Bezels\_Default\IC Menu " . side . ".png")
	Gdip_DisposeImage(pBitmap)
	Gdip_DeleteGraphics(G)
	Return
}
