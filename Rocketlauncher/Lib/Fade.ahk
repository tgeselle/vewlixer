MCRC := "2AFE2D51"
MVersion := "1.2.3"

FadeInStart(){
	Gosub, FadeInStart
	Gosub, CoverFE
}
FadeInExit(){
	Gosub, FadeInExit
	;SetTimer, FadeInExit, -1	; so we can have emu launch while waiting for fade delay to end
	CustomFunction.PostLoad()
}
FadeOutStart(){
	Gosub, FadeOutStart
}
FadeOutExit(){
	Gui, 20: Destroy
	Gosub, FadeOutExit
}

CoverFE:
	RLLog.Debug(A_ThisLabel . " - Started")
	StringTrimRight, fadeLyr1ColorAlpha, fadeLyr1Color, 6
	fadeLyr1ColorAlpha := "0x" . fadeLyr1ColorAlpha
	StringTrimLeft, fadeLyr1ColorClr, fadeLyr1Color, 2
	Gui, 20: New, -Caption +ToolWindow +OwnDialogs %fadeClickThrough%
	Gui, 20: Color, %fadeLyr1ColorClr%
	Gui, 20: Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, CoverFE
	WinSet, Transparent, 0x%fadeLyr1ColorAlpha%, A
	If (hideFE = "true")
		FadeApp("ahk_pid " . frontendPID,"out")
	If (suspendFE = "true" && !FrontEndProcess.Suspended)
		FrontEndProcess.ProcessSuspend()
	RLLog.Debug(A_ThisLabel . " - Ended")
Return

CloseFadeIn:
	RLLog.Debug(A_ThisLabel . " - Started")
	fadeInActive:=	; interrupts the fade loop if it is checking this var
	fadeInEndTime := fadeInEndTime - A_TickCount	; turns off user set FadeInDelay by increasing the var checked in the timer
	t1 := 100	; sets image-based fade animation to the last loop (100%) and completes animation
	layer3Percentage := 100
	Process("Exist", "7z.exe")
	If ErrorLevel {
		7zCanceled := 1
		Process("Close", "7z.exe")	; if 7z is running and extracting a game, it force closes 7z and returns to the front end (acts as a 7z cancel)
		RLLog.Error(A_ThisLabel . " - User cancelled 7z extraction. Ending RocketLauncher and returning to Front End")
		Process("WaitClose", "7z.exe")	; wait until 7z is closed so we don't try to delete files too fast
		Sleep, 200	; just force a little more time to help prevent files from still being locked
		7zCleanUp()	; must delete partially extracted file
		ExitModule()
	}
	RLLog.Debug(A_ThisLabel . " - Ended")
Return
CloseFadeOut:
	RLLog.Debug(A_ThisLabel . " - Started")
	fadeOutEndTime := A_TickCount
	t2 := 100
	RLLog.Debug(A_ThisLabel . " - Ended")
Return

; Might need this for MG support also
AnykeyFadeBypass:
	If (A_TimeIdlePhysical <= anykeyStart) {	; If our current idle time is less then the amount we started, user must of pressed a key and we should exit fade
		RLLog.Info(A_ThisLabel . " - User interrupted Fade_" . anykeyMethod . ". No longer idle. Skipping to " . (If anykeyMethod = "in" ? "FadeInExit" : "FadeOutExit"))
		fadeInterrupted := 1
		SetTimer, AnykeyFadeBypass, Off	; shut off this timer
		Goto, % (If anykeyMethod = "in" ? "CloseFadeIn" : "CloseFadeOut")
	}

	Loop % InterruptMouseButtons.MaxIndex()
	{	currentJoy := A_index
		GetKeyState, mbtn, % InterruptMouseButtons[A_Index]	; get state for each mouse button
		If (mbtn = "D") {
			RLLog.Info(A_ThisLabel . " - User interrupted Fade_" . anykeyMethod . ". Mouse button pressed. Skipping to " . (If anykeyMethod = "in" ? "FadeInExit" : "FadeOutExit"))
			fadeInterrupted := 1
			SetTimer, AnykeyFadeBypass, Off	; shut off this timer
			Goto, % (If anykeyMethod = "in" ? "CloseFadeIn" : "CloseFadeOut")
		}
	}

	Loop 16  ; Query each joystick number to find out which ones exist.
	{	GetKeyState, JoyName, %A_Index%JoyName
		If JoyName <>
		{	JoystickNumber := A_Index
			Break
		}
	}
	If (JoystickNumber > 0)
	{	Loop, % JoystickNumber
		{	currentJoy := A_index
			GetKeyState, joy_buttons, %currentJoy%JoyButtons
			buttons_down := false
			Loop, % joy_buttons
			{	GetKeyState, joy%a_index%, %currentJoy%joy%a_index%
				If (joy%A_Index% = "D")
				{	RLLog.Info(A_ThisLabel . " - User interrupted Fade_" . anykeyMethod . ". Joystick interrupted fade. Skipping to " . (If anykeyMethod = "in" ? "FadeInExit" : "FadeOutExit"))
					buttons_down := true
					fadeInterrupted := 1
					SetTimer, AnykeyFadeBypass, Off	; shut off this timer
					Goto, % (If anykeyMethod = "in" ? "CloseFadeIn" : "CloseFadeOut")
					Break
				}
			}
			If (buttons_down = true)
				Break
		}					
	}
Return

CustomKeyFadeBypass:
	RLLog.Info(A_ThisLabel . " - User interrupted Fade_" . customKeyMethod . ", skipping to " . (If customKeyMethod = "in" ? "FadeInExit" : "FadeOutExit"))
	fadeInterrupted := 1
	Goto, % (If customKeyMethod = "in" ? "CloseFadeIn" : "CloseFadeOut")
Return

UpdateFadeFor7z:
	Gosub, %fadeLyr37zAnimation%	; Calling user set animation function for 7z
Return

UpdateFadeForNon7z:
	Gosub, %fadeLyr3Animation%	; Calling user set animation function for 7z when no 7z extraction took place
Return

FadeInStart:
	If (fadeIn = "true")
	{	RLLog.Debug(A_ThisLabel . " - Started")
		If !pToken := Gdip_Startup()	; Start gdi+
			ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")

		If mgEnabled = true
			XHotKeywrapper(mgKey,"StartMulti","OFF")
		If pauseEnabled = true
			XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
		; XHotKeywrapper(exitEmulatorKey,"CloseFadeIn","ON")
		
		If (fadeInterruptKey = "anykey") {	; if user wants anykey to be able to disrupt fade, use this label
			RLLog.Debug(A_ThisLabel . " - Any key will interrupt this fade process")
			anykeyStart := A_TimeIdlePhysical	; store current idle time so AnykeyFadeBypass timer knows if it has been reset
			anykeyMethod := "in"	; this tells AnykeyFadeBypass if we are in fadeIn or fadeOut so it knows what label to advance to
			SetTimer, AnykeyFadeBypass, 100	; idle check timer should run every 200ms and to check if user has pressed a key causing idletime to reset
		} Else If fadeInterruptKey {	; set custom interrupt key only
			RLLog.Debug(A_ThisLabel . " - Only these keys will interrupt this fade process: " . fadeInterruptKey)
			customKeyMethod := "in"
			XHotKeywrapper(fadeInterruptKey,"CustomKeyFadeBypass","ON")
		} Else {
			RLLog.Debug(A_ThisLabel . " - No keys were set to interrupt fade so ability to interrupt fade is disabled")
		}
		
		;Acquiring screen info for dealing with rotated menu drawings
		Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
		Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
		xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
		If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270)))){
			temp := fadeWidthBaseRes , fadeWidthBaseRes := fadeHeightBaseRes , fadeHeightBaseRes := temp
		}
		fadeXScale := baseScreenWidth/fadeWidthBaseRes
		fadeYScale := baseScreenHeight/fadeHeightBaseRes
		RLLog.Trace(A_ThisLabel . " - Fade screen scale factor: X=" . fadeXScale . ", Y= " . fadeYScale)
		OptionScale(fadeLyr2X, fadeXScale)
		OptionScale(fadeLyr2Y, fadeYScale)
		OptionScale(fadeLyr2W, fadeXScale)
		OptionScale(fadeLyr2H, fadeYScale)
		OptionScale(fadeLyr2PicPad, fadeXScale) ;could be Y also
	
		fadeInLyr1File := GetFadePicFile("Layer 1",if (fadeUseBackgrounds="true") ? true : false)
		If fadeLyr2Prefix
			fadeInLyr2File := GetFadePicFile(fadeLyr2Prefix)
		
		; Create canvas for the two first fade in screens
		Loop, 2 { 
        CurrentGUI := A_Index
			If (A_Index=1)
                Gui, Fade_GUI%CurrentGUI%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop %fadeClickThrough%
			Else {
				OwnerGUI := CurrentGUI - 1
                Gui, Fade_GUI%CurrentGUI%: +OwnerFade_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop %fadeClickThrough%
			}
            Gui, Fade_GUI%CurrentGUI%: Margin,0,0
            Gui, Fade_GUI%CurrentGUI%: Show,, fadeLayer%CurrentGUI%
            Fade_hwnd%CurrentGUI% := WinExist()
            Fade_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            Fade_hdc%CurrentGUI% := CreateCompatibleDC()
            Fade_obm%CurrentGUI% := SelectObject(Fade_hdc%CurrentGUI%, Fade_hbm%CurrentGUI%)
            Fade_G%CurrentGUI% := Gdip_GraphicsFromhdc(Fade_hdc%CurrentGUI%)
            Gdip_SetInterpolationMode(Fade_G%CurrentGUI%, 7)
            Gdip_SetSmoothingMode(Fade_G%CurrentGUI%, 4)
			Gdip_TranslateWorldTransform(Fade_G%CurrentGUI%, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Fade_G%CurrentGUI%, screenRotationAngle)
        }	
		fadeLyr1CanvasX := 0 , fadeLyr1CanvasY := 0
		fadeLyr1CanvasW := baseScreenWidth, fadeLyr1CanvasH := baseScreenHeight
		pGraphUpd(Fade_G1,fadeLyr1CanvasW,fadeLyr1CanvasH)
		pBrush := Gdip_BrushCreateSolid("0x" . fadeLyr1Color)
		Gdip_Alt_FillRectangle(Fade_G1, pBrush, -1, -1, baseScreenWidth+2, baseScreenHeight+2)
		
		If FileExist(fadeInLyr1File)	; If a layer 1 image exists, let's get its dimensions
		{	fadeLyr1Pic := Gdip_CreateBitmapFromFile(fadeInLyr1File)
			Gdip_GetImageDimensions(fadeLyr1Pic, fadeLyr1PicW, fadeLyr1PicH)
			fadeLyr1PicW := Round(fadeLyr1PicW * fadeXScale)
			fadeLyr1PicH := Round(fadeLyr1PicH * fadeYScale)
			GetBGPicPosition(fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew,fadeLyr1PicHNew,fadeLyr1PicW,fadeLyr1PicH,fadeLyr1AlignImage)	; get the background pic's new position and size
			If (fadeLyr1AlignImage = "Stretch and Lose Aspect") {	; 
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew+1,fadeLyr1PicHNew+1)
			} Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right") {
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew, fadeLyr1PicYNew, fadeLyr1PicWNew+1, fadeLyr1PicHNew+1)
			} Else If (fadeLyr1AlignImage = "Center") {	; original image size and aspect
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew, fadeLyr1PicYNew, fadeLyr1PicW+1, fadeLyr1PicH+1)
			} Else If (fadeLyr1AlignImage = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew, 0,fadeLyr1PicWNew+1,fadeLyr1PicHNew)
			} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, 0, 0,fadeLyr1PicWNew+1,fadeLyr1PicHNew+1)
			}
		}
		
		If FileExist(fadeInLyr2File)	; If a layer 2 image exists, let's get its dimensions
		{	fadeLyr2Pic := Gdip_CreateBitmapFromFile(fadeInLyr2File)
			Gdip_GetImageDimensions(fadeLyr2Pic, fadeLyr2PicW, fadeLyr2PicH)
			; find Width and Height
			If (fadeLyr2Pos = "Stretch and Lose Aspect"){
				fadeLyr2PicW := baseScreenWidth
				fadeLyr2PicH := baseScreenHeight
				fadeLyr2PicPadX := 0 , fadeLyr2PicPadY := 0
			} Else If (fadeLyr2Pos = "Stretch and Keep Aspect"){	
				widthMaxPercent := ( baseScreenWidth / fadeLyr2PicW )	; get the percentage needed to maximumise the image so it reaches the screen's width
				heightMaxPercent := ( baseScreenHeight / fadeLyr2PicH )
				percentToEnlarge := If (widthMaxPercent < heightMaxPercent) ? widthMaxPercent : heightMaxPercent	; this basicallys says if the width's max reaches the screen's width first, use the width's percentage instead of the height's
				fadeLyr2PicW := Round(fadeLyr2PicW * percentToEnlarge)	
				fadeLyr2PicH := Round(fadeLyr2PicH * percentToEnlarge)	
				fadeLyr2PicPadX := 0 , fadeLyr2PicPadY := 0
			} Else {
				If (!(fadeLyr2W)) and (!(fadeLyr2H)){
					fadeLyr2PicW := Round(fadeLyr2PicW * fadeXScale * fadeLyr2Adjust)
					fadeLyr2PicH := Round(fadeLyr2PicH * fadeYScale * fadeLyr2Adjust)
				} Else If (fadeLyr2W) and (!(fadeLyr2H)){
					fadeLyr2PicH := Round( fadeLyr2PicH * (fadeLyr2PicW / Round(fadeLyr2PicW * fadeLyr2Adjust)) )
					fadeLyr2PicW := Round(fadeLyr2W * fadeLyr2Adjust)
				} Else If (!(fadeLyr2W)) and (fadeLyr2H){
					fadeLyr2PicW := Round( fadeLyr2PicW * (fadeLyr2PicH / Round(fadeLyr2H * fadeLyr2Adjust)) )
					fadeLyr2PicH := Round(fadeLyr2H * fadeLyr2Adjust)
				} Else {
					fadeLyr2PicW := Round(fadeLyr2W * fadeLyr2Adjust)
					fadeLyr2PicH := Round(fadeLyr2H * fadeLyr3Adjust)	
				}
			}
			GetFadePicPosition(fadeLyr2PicX,fadeLyr2PicY,fadeLyr2X,fadeLyr2Y,fadeLyr2PicW,fadeLyr2PicH,fadeLyr2Pos)
			; figure out what quadrant the layer 2 image is in, so we know to apply a + or - pad value so the user does not have to
			If fadeLyr2Pos in No Alignment,Center,Top Left Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad, fadeLyr2PicPadY:=fadeLyr2PicPad
			Else If fadeLyr2Pos = Top Center
				fadeLyr2PicPadX:=0, fadeLyr2PicPadY:=fadeLyr2PicPad
			Else If fadeLyr2Pos = Left Center
				fadeLyr2PicPadX:=fadeLyr2PicPad, fadeLyr2PicPadY:=0
			Else If fadeLyr2Pos = Top Right Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad*-1, fadeLyr2PicPadY:=fadeLyr2PicPad
			Else If fadeLyr2Pos = Right Center
				fadeLyr2PicPadX:=fadeLyr2PicPad*-1, fadeLyr2PicPadY:=0
			Else If fadeLyr2Pos = Bottom Left Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad, fadeLyr2PicPadY:=fadeLyr2PicPad*-1
			Else If fadeLyr2Pos = Bottom Center
				fadeLyr2PicPadX:=0, fadeLyr2PicPadY:=fadeLyr2PicPad*-1
			Else If fadeLyr2Pos = Bottom Right Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad*-1, fadeLyr2PicPadY:=fadeLyr2PicPad*-1
			fadeLyr2CanvasX := fadeLyr2PicX + fadeLyr2PicPadX , fadeLyr2CanvasY := fadeLyr2PicY + fadeLyr2PicPadY
			fadeLyr2CanvasW := fadeLyr2PicW, fadeLyr2CanvasH := fadeLyr2PicH
			pGraphUpd(Fade_G2,fadeLyr2CanvasW,fadeLyr2CanvasH)
			Gdip_Alt_DrawImage(Fade_G2, fadeLyr2Pic, 0, 0, fadeLyr2PicW, fadeLyr2PicH)
		}

		%fadeInTransitionAnimation%("in",fadeInDuration)

		fadeInEndTime := A_TickCount + fadeInDelay

		fadeOptionsScale() ; scale fade options to adjust for user resolution
		
		; Create canvas for all remaining fade in screens
		Loop, 6 { 
			OwnerGUI := CurrentGUI
			If (A_Index=1) { ; creating layer 3 static
				OwnerGUI := 2
				CurrentGUI := "3Static"   
			} Else If  (A_Index=2) { ; creating layer 3
				CurrentGUI := A_Index+1   
			} Else ; creating layer 4 to 7
				CurrentGUI := A_Index+1   
			Gui, Fade_GUI%CurrentGUI%: +OwnerFade_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop %fadeClickThrough%
			Gui, Fade_GUI%CurrentGUI%: Margin,0,0
            Gui, Fade_GUI%CurrentGUI%: Show,, fadeLayer%CurrentGUI%
            Fade_hwnd%CurrentGUI% := WinExist()
            Fade_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            Fade_hdc%CurrentGUI% := CreateCompatibleDC()
            Fade_obm%CurrentGUI% := SelectObject(Fade_hdc%CurrentGUI%, Fade_hbm%CurrentGUI%)
            Fade_G%CurrentGUI% := Gdip_GraphicsFromhdc(Fade_hdc%CurrentGUI%)
            Gdip_SetInterpolationMode(Fade_G%CurrentGUI%, 7)
            Gdip_SetSmoothingMode(Fade_G%CurrentGUI%, 4)
			Gdip_TranslateWorldTransform(Fade_G%CurrentGUI%, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Fade_G%CurrentGUI%, screenRotationAngle)
        }

		If (sevenZEnabled != "true") or (sevenZEnabled = "true" && found7z != "true") or (rlMode="fade7z") {
			GoSub, %fadeLyr3Animation%
		}
		RLLog.Debug(A_ThisLabel . " - Ended")
	}
	; Tacking on these features below so they trigger at the desired positions during launch w/o a need for additional calls in each module
	If (!romTable && mgCandidate)
		SetTimer, CreateMGRomTable, -1

	DxwndUpdateIniPath()

	If (romMappingLaunchMenuEnabled = "true" && romMapLaunchMenuCreated) ; && romMapMultiRomsFound)
		DestroyRomMappingLaunchMenu()

	CustomFunction.PreStart() ; starting global user functions here so they are triggered after fade screen is up
Return

FadeInExit:
	If (fadeIn = "true")
	{	RLLog.Debug(A_ThisLabel . " - Started")
		If fadeInExitDelay {	; if user wants to use a delay to let the emu load
			If !fadeInExitDelayStart {	; checking if starttime was set already, this prevents looping and restarting of this timer by pressing the interrupt key over and over
				fadeInExitDelayStart := A_TickCount
				fadeInExitDelayEnd := fadeInExitDelay + fadeInExitDelayStart	; when the sleep should end
			}
			RLLog.Debug(A_ThisLabel . " - fadeInExitDelay started")
			Loop {
				If ((A_TickCount >= fadeInExitDelayEnd) Or fadeInterrupted ) {	; if delay has been met or user cancelled by pressing a fade interrupt key break out and continue
					fadeInterrupted := ""	; reset var so we know not to start another sleep
					Break
				}
				Sleep, 100
			}
			RLLog.Debug(A_ThisLabel . " - fadeInExitDelay ended")
		}
		; XHotKeywrapper(exitEmulatorKey,"CloseFadeIn","OFF")
		If (fadeInterruptKey = "anykey")	; if user wants anykey to be able to disrupt fade, use this label
			SetTimer, AnykeyFadeBypass, Off
		Else
			XHotKeywrapper(fadeInterruptKey,"CustomKeyFadeBypass","OFF")
		
		If (fadeMuteEmulator = "true") and !(rlMode){
			If !emulatorInitialMuteState
				{
				getVolume(emulatorInitialVolume,emulatorVolumeObject) 
				setVolume(0,emulatorVolumeObject) 
				setMute(0,emulatorVolumeObject)
				SetTimer, FadeSmoothVolumeIncrease, 100
			}
		}
		
		fadeInExitComplete := true
		
		%fadeInTransitionAnimation%("out",fadeInDuration)
		
		; Clean up on exit
		Gdip_DeleteBrush(pBrush)
		Loop, 8 {
			If (A_Index=8)
				CurrentGUI := "3Static"
			Else 
				CurrentGUI := A_index
		
			Gdip_GraphicsClear(Fade_G%CurrentGUI%)	; clearing canvas for all layers
			UpdateLayeredWindow(Fade_hwnd%CurrentGUI%, Fade_hdc%CurrentGUI%, 0, 0, A_ScreenWidth, A_ScreenHeight)	; showing cleared canvas
			Gdip_DisposeImage(fadeLyr%CurrentGUI%Pic), SelectObject(Fade_hdc%CurrentGUI%, Fade_obm%CurrentGUI%), DeleteObject(Fade_hbm%CurrentGUI%), DeleteDC(Fade_hdc%CurrentGUI%), Gdip_DeleteGraphics(Fade_G%CurrentGUI%)
			Gui, Fade_GUI%CurrentGUI%: Destroy
		}
		If (mgEnabled = "true")
			XHotKeywrapper(mgKey,"StartMulti","ON")
		If (pauseEnabled = "true")
			XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","ON")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		RLLog.Debug(A_ThisLabel . " - Ended, waiting for user to close launched application")
	}
	gameSectionStartTime := A_TickCount
	gameSectionStartHour := A_Now ; These two vars are in StartModule() and here because we need a way of it always being created if the module does not have Fade support. It's more accurate if used here vs starting in StartModule()
	;if bezelPath
	;	Loop, 7 { 
	;		index := a_index + 1
	;		Gui, Bezel_GUI%index%: Show
	;	}
Return

FadeSmoothVolumeIncrease:
	If !smoothVolumeIncreaseStartTime
		smoothVolumeIncreaseStartTime := A_TickCount
	fadeSmoothVolumeIncreasePercentage := ((A_TickCount-smoothVolumeIncreaseStartTime)/fadeInDuration)
	fadeSmoothVolumeIncreasePercentage := (fadeSmoothVolumeIncreasePercentage>=1) ? 1 : fadeSmoothVolumeIncreasePercentage
	If emulatorVolumeObject
		setVolume(Round(emulatorInitialVolume*fadeSmoothVolumeIncreasePercentage,1),emulatorVolumeObject)
	Else
		setVolume(Round(emuVolume*fadeSmoothVolumeIncreasePercentage,1),emulatorVolumeObject)
	If (fadeSmoothVolumeIncreasePercentage=1)
		SetTimer, FadeSmoothVolumeIncrease, off
Return

FadeOutStart:
	If (fadeOut = "true")
	{	RLLog.Debug(A_ThisLabel . " - Started")
		If !pToken := Gdip_Startup()	; Start gdi+
			ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")
		If (fadeMuteEmulator = "true") and !(rlMode)
			if !emulatorInitialMuteState
				setMute(1,emulatorVolumeObject)
		fadeInterrupted := ""	; need to reset this key in case Fade_In was interrupted
		If (mgEnabled = "true")
			XHotKeywrapper(mgKey,"StartMulti","OFF")
		If (pauseEnabled = "true")
			XHotKeywrapper(pauseKey,"TogglePauseMenuStatus","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
		; XHotKeywrapper(exitEmulatorKey,"CloseFadeOut","ON")
		If (fadeInterruptKey = "anykey") {	; if user wants anykey to be able to disrupt fade, use this label
			RLLog.Debug(A_ThisLabel . " - Any key will interrupt this fade process")
			anykeyStart := A_TimeIdlePhysical	; store current idle time so AnykeyFadeBypass timer knows if it has been reset
			anykeyMethod := "out"	; this tells AnykeyFadeBypass if we are in fadeIn or fadeOut so it knows what label to advance to
			SetTimer, AnykeyFadeBypass, 100	; idle check timer should run every 100ms and to check if user has pressed a key causing idletime to reset
		} Else If fadeInterruptKey {	; set custom interrupt key only
			RLLog.Debug(A_ThisLabel . " - Only these keys will interrupt this fade process: " . fadeInterruptKey)
			customKeyMethod := "out"
			XHotKeywrapper(fadeInterruptKey,"CustomKeyFadeBypass","ON")
		} Else {
			RLLog.Debug(A_ThisLabel . " - No keys were set to interrupt fade so ability to interrupt fade is disabled")
		}
		
		lyr1OutFile := GetFadePicFile("Layer -1")
		; lyr1OutFile := GetFadePicFile("Layer",-2)	; support for 2nd image on fadeOut

		If FileExist(lyr1OutFile)
		{	lyr1OutPic := Gdip_CreateBitmapFromFile(lyr1OutFile)
			Gdip_GetImageDimensions(lyr1OutPic, lyr1OutPicW, lyr1OutPicH)	; get the width and height of the background image
			lyr1OutPicW := Round(lyr1OutPicW * fadeXScale)
			lyr1OutPicH := Round(lyr1OutPicH * fadeYScale)
		}		
		;Acquiring screen info for dealing with rotated menu drawings
		If (fadeIn != "true")
			{
			Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
			Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
			xTranslation := round(xTranslation), yTranslation:=round(yTranslation)
		}		
		FadeOut_hbm1 := CreateDIBSection(A_ScreenWidth, A_ScreenHeight), FadeOut_hdc1 := CreateCompatibleDC(), FadeOut_obm1 := SelectObject(FadeOut_hdc1, FadeOut_hbm1)	; might have to use the original width / height from before the emu launched if  the screen res changed
		FadeOut_G1 := Gdip_GraphicsFromhdc(FadeOut_hdc1), Gdip_SetInterpolationMode(FadeOut_G1, 7) ;, Gdip_SetSmoothingMode(FadeOut_G1, 4)
		Gui, FadeOut_GUI1: New, +HwndFadeOut_hwnd1 +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs %fadeClickThrough%, FadeOut Layer 1	; E0x80000 required for UpdateLayeredWindow to work. Is always on top, has no taskbar entry, no caption, and msgboxes will appear on top of the GUI
		Gdip_TranslateWorldTransform(FadeOut_G1, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(FadeOut_G1, screenRotationAngle)
		fadeOutLyr1CanvasX := 0 , fadeOutLyr1CanvasY := 0
		fadeOutLyr1CanvasW := baseScreenWidth, fadeOutLyr1CanvasH := baseScreenHeight
		pGraphUpd(FadeOut_G1,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH)
		; Draw Layer 1 (Background image and color)
		pBrush := Gdip_BrushCreateSolid("0x" . fadeLyr1Color)	; Painting the background color
		Gdip_Alt_FillRectangle(FadeOut_G1, pBrush, -1, -1, baseScreenWidth+3, baseScreenHeight+3)	; draw the background first on layer 1, layer order matters!!
		If lyr1OutFile {
			GetBGPicPosition(fadeLyr1OutPicXNew,fadeLyr1OutPicYNew,fadeLyr1OutPicWNew,fadeLyr1OutPicHNew,lyr1OutPicW,lyr1OutPicH,fadeLyr1AlignImage)	; get the background pic's new position and size
			If (fadeLyr1AlignImage = "Stretch and Lose Aspect") {	; 
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, 0, 0, baseScreenWidth+3, baseScreenHeight+3)	; adding a few pixels to avoid showing background on some pcs
			} Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right") {
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, fadeLyr1OutPicXNew, fadeLyr1OutPicYNew, fadeLyr1OutPicWNew+1, fadeLyr1OutPicHNew+1)
			} Else If (fadeLyr1AlignImage = "Center") {	; original image size and aspect
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, fadeLyr1OutPicXNew, fadeLyr1OutPicYNew, lyr1OutPicW+1, lyr1OutPicH+1)
			} Else If (fadeLyr1AlignImage = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, fadeLyr1OutPicXNew, 0,fadeLyr1OutPicWNew+1,fadeLyr1OutPicHNew+1)
			} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, 0, 0,fadeLyr1OutPicWNew+1,fadeLyr1OutPicHNew+1)
			}
		}
		;Alt_UpdateLayeredWindow(FadeOut_hwnd1, FadeOut_hdc1, fadeOutLyr1CanvasX,fadeOutLyr1CanvasY,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH)

		If (fadeOutExtraScreen = "true")	; if user wants to use a temporary extra gui layer for this system right before fadeOut starts
		{	RLLog.Debug(A_ThisLabel . " - Creating temporary FadeOutExtraScreen")
			Gosub, FadeOutExtraScreen
		}
		Gui FadeOut_GUI1: Show	; show layer -1 GUI
		%fadeOutTransitionAnimation%("in",fadeOutDuration)

		fadeOutEndTime := A_TickCount + fadeOutDelay
		RLLog.Debug(A_ThisLabel . " - Ended")
	}
	HideEmuStart()	; global support for hiding emus on exit
Return

FadeOutExtraScreen:
	StringTrimLeft,fadeLyr1ColorNoAlpha,fadeLyr1Color,2	; for legacy gui, we need to trim the alpha from the color as it's not supported
	Gui, FadeOutExtraScreen: New, +HwndFadeOutExtraScreen_ID +ToolWindow -Caption +AlwaysOnTop +OwnDialogs %fadeClickThrough%, FadeOutExtraScreen	; Is always on top, has no taskbar entry, no caption, and msgboxes will appear on top of the GUI
	Gui, FadeOutExtraScreen:Color, %fadeLyr1ColorNoAlpha%
	Gui, FadeOutExtraScreen:Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth% Hide
	AnimateWindow(FadeOutExtraScreen_ID, "in", "fade", 50) ; animate FadeOutExtraScreen in quickly
Return

FadeOutExit:
	CustomFunction.PostStop() ; stoping global user functions here so they are closed before fade screen exits
	If (fadeOut = "true")
	{	RLLog.Debug(A_ThisLabel . " - Started")
		If fadeOutExitDelay {	; if user wants to use a delay
			If !fadeOutExitDelayStart {	; checking if starttime was set already, this prevents looping and restarting of this timer by pressing the interrupt key over and over
				fadeOutExitDelayStart := A_TickCount
				fadeOutExitDelayEnd := fadeOutExitDelay + fadeOutExitDelayStart	; when the sleep should end
			}
			Loop {
				If ((A_TickCount >= fadeOutExitDelayEnd) Or fadeInterrupted ) {	; if delay has been met or user cancelled by pressing a fade interrupt key break out and continue
					fadeInterrupted := ""	; reset var so we know not to start another sleep
					Break
				}
				Sleep, 100
			}
		}
		; XHotKeywrapper(exitEmulatorKey,"CloseFadeOut","OFF")
		If (fadeInterruptKey = "anykey")	; if user wants anykey to be able to disrupt fade, use this label
			SetTimer, AnykeyFadeBypass, Off
		Else If fadeInterruptKey
			XHotKeywrapper(fadeInterruptKey,"CustomKeyFadeBypass","OFF")

		While fadeOutEndTime > A_TickCount {
			Sleep, 100
			Continue
		}

		%fadeOutTransitionAnimation%("out",fadeOutDuration)
		
		If (fadeMuteEmulator = "true") and !(rlMode)
			If !emulatorInitialMuteState
				setMute(0,emulatorVolumeObject)
		
		; Clean up on exit
		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(lyr1OutPic), SelectObject(FadeOut_hdc1, FadeOut_obm1), DeleteObject(FadeOut_hbm1), DeleteDC(FadeOut_hdc1), Gdip_DeleteGraphics(FadeOut_G1)
		Gui, FadeOut_GUI1: Destroy
		If GifAnimation
			{
			AniGif_DestroyControl(hAniGif1)
			Gui, Fade_GifAnim_GUI: Destroy
		}
		
		RLLog.Debug(A_ThisLabel . " - Ended")
	}
	HideEmuEnd()
Return

FadeInDelay:
	RLLog.Debug(A_ThisLabel . " - Started")
	While fadeInActive && (fadeInEndTime > A_TickCount) {
		Sleep, 100
		Continue
	}
	RLLog.Debug(A_ThisLabel . " - Ended")
Return

FadeLayer4Anim:
	If GifAnimation
		{
		fadeLyr4PicX := round(fadeLyr4PicX)+0 , fadeLyr4PicY := round(fadeLyr4PicY)+0 , fadeLyr4PicW := round(fadeLyr4PicW)+0 , fadeLyr4PicH := round(fadeLyr4PicH)+0 
		AniGif_LoadGifFromFile(hAniGif1, GifAnimation)
		AniGif_SetBkColor(hAniGif1, fadeTranspGifColor)
		Gui, Fade_GifAnim_GUI: Show, x%fadeLyr4PicX% y%fadeLyr4PicY% w%fadeLyr4PicW% h%fadeLyr4PicH%	
	} Else {
		Gdip_GraphicsClear(Fade_G4)
		currentFadeLyr4Image++
		If (currentFadeLyr4Image>FadeLayer4AnimTotal)
			currentFadeLyr4Image := 1
		Gdip_Alt_DrawImage(Fade_G4, FadeLayer4Anim%currentFadeLyr4Image%Pic, 0, 0, fadeLyr4PicW, fadeLyr4PicH)
		Alt_UpdateLayeredWindow(Fade_hwnd4, Fade_hdc4, fadeLyr4CanvasX,fadeLyr4CanvasY,fadeLyr4CanvasW,fadeLyr4CanvasH)
	}
Return

; Trial feature to help detect if an error has occured launching the emulator and to error out if detected. Currently disabled and might need to be placed in another thread so it can run alongside RocketLauncher
DetectFadeError:
	fadeTimeToWait += fadeInDuration	; add fade's duration
	fadeTimeToWait += fadeInDelay	; add fade's delay
	If (cpWizardEnabled = "true")
		fadeTimeToWait += cpWizardDelay	; adding delay for CPWizard
	If (vdEnabled = "true")
		fadeTimeToWait += 2000	; tacking on a couple seconds to give time for DT to mount
	fadeErrorStartTime := A_TickCount
	fadeErrorTime := fadeErrorStartTime + fadeTimeToWait + 1000	; giving 15 seconds for the emulator to launch and fade to disappear. If it goes more then that, most likely there was an issue.
	Loop {
		IfWinNotExist, Fade ahk_class AutoHotkeyGUI	; If fade gui does not exist, we know it is finished
			Break
		If (7zEnable = "true")
		{
			Process, Exist, 7z.exe
			If ErrorLevel
			{
				7zWasUsed := 1	; we know 7z was used at some point
				Continue	; 7z.exe is running, let's keep looping
			} Else If 7zWasUsed	; this will trigger if 7z.exe was found at some point, but it no longer is running
			{
				7zWasUsed := ""		; clearing var so it doesn't trigger again
				fadeErrorTime := A_TickCount + fadeInDuration + (vdEnabled = "true" ? 2000:"") + 15000 + (If (fadeInDelay>A_TickCount - fadeErrorStartTime) ? fadeInDelay - (A_TickCount - fadeErrorStartTime) : "")	; recalculating the end time in case a long 7z extraction took place.  if the 7z time > fadeindelay, we dont need to sum anything, else, we need to sum fadeindelay - time spent on 7z extraction
			}
		}
		If (A_TickCount > fadeErrorTime)
			ScriptError("There was a problem launching the application or with the module. Please disable Fade_In and get it working before turning Fade back on.")
		Sleep, 250
	}
Return

GetFadePicFile(preffix,useBkgdPath:=false,supportedFileTypes:="png|gif|tif|bmp|jpg"){
	Global RLMediaPath,dbName,systemName, RLMediaPath, feMedia, screenRotationAngle, gameInfo
	If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
		vertical := "true"
	fadePicPath1 := RLMediaPath . "\Fade\" . systemName . "\" . dbName . "\" . preffix	
	If (gameInfo["Cloneof"].Value)
		fadePicPath2 := RLMediaPath . "\Fade\" . systemName . "\" . gameInfo["Cloneof"].Value . "\" . preffix
	If (useBkgdPath){
		fadePicPath3 := RLMediaPath . "\Backgrounds\" . systemName . "\" . dbName . "\" . preffix
		If (gameInfo["Cloneof"].Value)
			fadePicPath4 := RLMediaPath . "\Backgrounds\" . systemName . "\" . gameInfo["Cloneof"].Value . "\" . preffix
	}
	If (vertical = "true")
		fadePicPath5 := RLMediaPath . "\Fade\" . systemName . "\_Default\Vertical" . "\" . preffix
	Else
		fadePicPath6 := RLMediaPath . "\Fade\" . systemName . "\_Default\Horizontal" . "\" . preffix
	fadePicPath7 := RLMediaPath . "\Fade\" . systemName . "\_Default" . "\" . preffix
	If (useBkgdPath){
		If (vertical = "true")
			fadePicPath8 := RLMediaPath . "\Backgrounds\" . systemName . "\_Default\Vertical" . "\" . preffix
		else
			fadePicPath9 := RLMediaPath . "\Backgrounds\" . systemName . "\_Default\Horizontal" . "\" . preffix
		fadePicPath10 := RLMediaPath . "\Backgrounds\" . systemName . "\_Default" . "\" . preffix
	}
	If (vertical = "true")
		fadePicPath11 := RLMediaPath . "\Fade\_Default\Vertical" . "\" . preffix
	Else
		fadePicPath12 := RLMediaPath . "\Fade\_Default\Horizontal" . "\" . preffix
	fadePicPath13 := RLMediaPath . "\Fade\_Default" . "\" . preffix
	If (useBkgdPath){
		If (vertical = "true")
			fadePicPath14 := RLMediaPath . "\Backgrounds\_Default\Vertical" . "\" . preffix
		Else
			fadePicPath15 := RLMediaPath . "\Backgrounds\_Default\Horizontal" . "\" . preffix
		fadePicPath16 := RLMediaPath . "\Backgrounds\_Default" . "\" . preffix
	}
	fadePicList := []	; initialize array
	Loop, 16 {
		If (fadePicPath%a_index%)
			{
			fadePicList := GetFadeDirPicFile(preffix,fadePicPath%a_index%,supportedFileTypes)
			If (fadePicList[1]) ; if we filled anything in the array, stop here, randomize pics found	, and return
				{ 	Random, RndmfadePic, 1, % fadePicList.MaxIndex()
					fadePicFile := fadePicList[RndmfadePic]
					RLLog.Info(A_ThisFunc . " - Randomized images and Fade " . name . " will use " . fadePicFile)
					break
			}
		}
	}
	Return fadePicFile
}

GetFadeDirPicFile(name,path,supportedFileTypes:="png|gif|tif|bmp|jpg"){
	RLLog.Debug(A_ThisFunc . " - Checking if any Fade """ . name . """ media exists in: " . path . "*.*")
	fadePicList := []
	If (FileExist(path . "*.*")) {
		Loop, Parse, supportedFileTypes,|
		{	RLLog.Debug(A_ThisFunc . " - Looking for Fade """ . name . """: " . path . "*." . A_LoopField)
			Loop, % path . "*." . A_LoopField
			{	RLLog.Debug(A_ThisFunc . " - Found Fade """ . name . """: " . A_LoopFileFullPath)
				fadePicList.Insert(A_LoopFileFullPath)
			}
		}
	}
	Return fadePicList
}
	

GetFadeAnimFiles(name,num,supportedFileTypes:="png|gif|tif|bmp|jpg"){
	Global fadeImgPath,dbName,systemName,fadeSystemAndRomLayersOnly
	fileList := [fadeImgPath . "\" . systemName . "\" . dbName . "\" . name . " " . num , fadeImgPath . "\" . systemName . "\_Default\" . name . " " . num , fadeImgPath . "\_Default\" . name . " " . num] ;rom file, system file, global file
	FadeAnimGroupAr:=[]
	; searching for fade anim files
	Loop, % fileList.MaxIndex(){
		currentFile := fileList[a_index]
		Loop, Parse, supportedFileTypes, |
		{	If FileExist(currentFile . " (1)*." . A_LoopField) {
				currentExt := A_LoopField
				Loop, % currentFile . " (1)*." . currentExt
				{	currentAnimGroup++
					currentFileDescription := SubStr(A_LoopFileName, StrLen(name)+7, -4)
					Loop
					{	
					If FileExist(currentFile . " (" . a_index . ")" . currentFileDescription . "." . currentExt)
							FadeAnimGroupAr[currentAnimGroup,a_Index] := currentFile . " (" . a_index . ")" . currentFileDescription . "." . currentExt
						Else
							Break
						FadeAnimGroupAr[currentAnimGroup,"totalItems"] := a_index
					}
				}
			}
		}
		If FadeAnimGroupAr[1,1]
			Break
	}
	;choosing randomly anim group to be used
	FadeAnimAr:=[]
	If currentAnimGroup
	{	Random, RndmAnimGroup, 1, % currentAnimGroup
		Loop, % FadeAnimGroupAr[RndmAnimGroup,"totalItems"]
			FadeAnimAr[a_index] := FadeAnimGroupAr[RndmAnimGroup,a_index]
	}	
	Return FadeAnimAr
}

GetFadeGifFile(name){
	Global fadeImgPath,dbName,systemName,fadeSystemAndRomLayersOnly
	romFile := fadeImgPath . "\" . systemName . "\" . dbName . "\" . name . "*.gif"  
	systemFile := fadeImgPath . "\" . systemName . "\_Default\" . name . "*.gif"  
	globalFile := fadeImgPath . "\_Default\" . name . "*.gif"  
	GifAnimationFiles := []
	If FileExist(romFile) {
		Loop % romFile
			GifAnimationFiles.insert(A_LoopFileFullPath)
	}
	If (GifAnimationFiles.MaxIndex() <= 0) {
		If FileExist(systemFile) {
			Loop % systemFile
				GifAnimationFiles.insert(A_LoopFileFullPath)
		}
	}
	If (GifAnimationFiles.MaxIndex() <= 0) {
		If fadeSystemAndRomLayersOnly != true	; if user wants to use global files
			If FileExist(globalFile) {
				Loop % globalFile
					GifAnimationFiles.insert(A_LoopFileFullPath)
			}
	}
	If (GifAnimationFiles.MaxIndex() > 0) {
		Random, RndmGif, 1, % GifAnimationFiles.MaxIndex()
		GifFile := GifAnimationFiles[RndmGif]
	}
	Return GifFile
}


AnimateWindow(Hwnd,Direction,Type,Time:=100){
	Static Activate:=0x20000, Center:=0x10, Fade:=0x80000, Hide:=0x10000, Slide:=0x40000, RL:=0x2, LR:=0x1, BT:=0x8, TB:=0x4
	hFlags := 0
	If !Hwnd {
		RLLog.Warning(A_ThisFunc . " - No Hwnd supplied. Do not know what window to animate.")
		Return
	}
	If !Direction
		ScriptError("AnimateWindow: No direction supplied. Options are In or Out")
	If !Type
		ScriptError("AnimateWindow: No Type supplied. Options are Activate, Center, Fade, Slide, RL, LR, BT, TB. Separate multiple types with a space")
	Loop, Parse, Type, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		IfEqual, A_LoopField,,Continue
		Else hFlags |= %A_LoopField%
	IfEqual, hFlags, ,Return "Error: Some of the types are invalid"
	DllCall("AnimateWindow", "uint", Hwnd, "uint", Time, "uint", If Direction="out"?Hide|=hFlags:hFlags)	; adds the Hide type on "out" direction
	Return
}


FadeOptionsScale(){
	Global
	OptionScale(fadeLyr3StaticX, fadeXScale)
	OptionScale(fadeLyr3StaticY, fadeYScale)
	OptionScale(fadeLyr3StaticW, fadeXScale)
	OptionScale(fadeLyr3StaticH, fadeYScale)
	OptionScale(fadeLyr3StaticPicPad, fadeXScale) ;could be Y also
	OptionScale(fadeLyr3X, fadeXScale)
	OptionScale(fadeLyr3Y, fadeYScale)
	OptionScale(fadeLyr3W, fadeXScale)
	OptionScale(fadeLyr3H, fadeYScale)
	OptionScale(fadeLyr3PicPad, fadeXScale) ;could be Y also
	OptionScale(fadeLyr4X, fadeXScale)
	OptionScale(fadeLyr4Y, fadeYScale)
	OptionScale(fadeLyr4W, fadeXScale)
	OptionScale(fadeLyr4H, fadeYScale)
	OptionScale(fadeLyr4PicPad, fadeXScale)
	OptionScale(fadeBarWindowX, fadeXScale) ;could be Y also
	OptionScale(fadeBarWindowY, fadeYScale)
	OptionScale(fadeBarWindowW, fadeXScale)
	OptionScale(fadeBarWindowH, fadeYScale)
	OptionScale(fadeBarWindowR, fadeXScale) ;could be Y also
	OptionScale(fadeBarWindowM, fadeXScale) ;could be Y also
	OptionScale(fadeBarH, fadeYScale)
	OptionScale(fadeBarR, fadeXScale) ;could be Y also
	OptionScale(fadeBarXOffset, fadeXScale)
	OptionScale(fadeBarYOffset, fadeYScale)
	OptionScale(fadeRomInfoTextMargin, fadeXScale)
	TextOptionScale(fadeRomInfoText1Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText2Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText3Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText4Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText5Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText6Options,fadeXScale, fadeYScale)
	OptionScale(fadeStatsInfoTextMargin, fadeXScale) ;could be Y also
	TextOptionScale(fadeStatsInfoText1Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText2Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText3Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText4Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText5Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText6Options,fadeXScale, fadeYScale)
	OptionScale(fadeText1X, fadeXScale)
	OptionScale(fadeText1Y, fadeYScale)
	TextOptionScale(fadeText1Options,fadeXScale, fadeYScale)
	OptionScale(fadeText2X, fadeXScale)
	OptionScale(fadeText2Y, fadeYScale)
	TextOptionScale(fadeText2Options,fadeXScale, fadeYScale)
	OptionScale(fadeExtractionTimeTextX, fadeXScale)
	OptionScale(fadeExtractionTimeTextY, fadeYScale)
	TextOptionScale(fadeExtractionTimeTextOptions,fadeXScale, fadeYScale)
	Return	
}