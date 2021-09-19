MCRC := "DDD3CBBB"
MVersion := "1.0.8"

CreateRomMappingLaunchMenu(table){
	Global
	Log("CreateRomMappingLaunchMenu - Started")
	; Returning if only one rom is found
	If (table.MaxIndex()=1) {
		Log("CreateRomMappingLaunchMenu - Skipping Rom Map Menu because there was only one possible selection on the menu.")
		Return
	}
	;initializing gdi plus
	If !pToken
		pToken := Gdip_Startup()
	; Creating Menu GUIs
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
	Loop, 6 { 
        CurrentGUI := A_Index
        If (A_Index=1)
			Gui, RomSelect_GUI%CurrentGUI%: -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Else {
			OwnerGUI := CurrentGUI - 1
			Gui, RomSelect_GUI%CurrentGUI%: +OwnerRomSelect_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
		}
		Gui, RomSelect_GUI%CurrentGUI%: Margin,0,0
		Gui, RomSelect_GUI%CurrentGUI%: Show,, RomSelect_Layer%CurrentGUI%
		RomSelect_hwnd%CurrentGUI% := WinExist()
		RomSelect_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		RomSelect_hdc%CurrentGUI% := CreateCompatibleDC()
		RomSelect_obm%CurrentGUI% := SelectObject(RomSelect_hdc%CurrentGUI%, RomSelect_hbm%CurrentGUI%)
		RomSelect_G%CurrentGUI% := Gdip_GraphicsFromhdc(RomSelect_hdc%CurrentGUI%)
		Gdip_SetSmoothingMode(RomSelect_G%CurrentGUI%, 4)
		Gdip_TranslateWorldTransform(RomSelect_G%CurrentGUI%, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(RomSelect_G%CurrentGUI%, screenRotationAngle)
	}
	pGraphUpd(RomSelect_G1,baseScreenWidth,baseScreenHeight)
	pGraphUpd(RomSelect_G2,baseScreenWidth,baseScreenHeight)
	;Setting Scale Res Factors
	XBaseRes := 1920, YBaseRes := 1080
    if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
        XBaseRes := 1080, YBaseRes := 1920
    if !romMappingXScale 
		romMappingXScale := baseScreenWidth/XBaseRes
    if !romMappingYScale
		romMappingYScale := baseScreenHeight/YBaseRes
	;Resizing Menu items
	TextOptionScale(romMappingTextOptions, romMappingXScale,romMappingYScale)
	TextOptionScale(romMappingGameInfoTextOptions, romMappingXScale,romMappingYScale)
	TextOptionScale(romMappingGameNameTextOptions, romMappingXScale,romMappingYScale)
	OptionScale(romMappingMenuWidth, romMappingXScale)
	OptionScale(romMappingMenuMargin, romMappingXScale)
	OptionScale(romMappingTextSizeDifference, romMappingXScale)
	OptionScale(romMappingTextMargin, romMappingXScale)
	OptionScale(romMappingMenuFlagWidth, romMappingXScale)
	OptionScale(romMappingMenuFlagSeparation, romMappingXScale)
	;Parsing text color and size
	RegExMatch(romMappingTextOptions,"i)c[a-zA-Z0-9]+",romMappingSelectTextColor)
	StringTrimLeft, romMappingSelectTextColor, romMappingSelectTextColor, 1
	RegExMatch(romMappingTextOptions,"i)s[0-9]+",romMappingTextSize)
	StringTrimLeft, romMappingTextSize, romMappingTextSize, 1
	RegExMatch(romMappingTitleTextOptions,"i)s[0-9]+",romMappingTitleTextSize)
	StringTrimLeft, romMappingTitleTextSize, romMappingTitleTextSize, 1
	RegExMatch(romMappingTitle2TextOptions,"i)s[0-9]+",romMappingTitle2TextSize)
	StringTrimLeft, romMappingTitle2TextSize, romMappingTitle2TextSize, 1
	;hardcoded options
	romMappingButtonCornerRadius := 15
	romMappingButtonCornerRadius2 := 15
	romMappingBackgroundCornerRadius := 15
	romMappingButtonBrushW := 800
	romMappingButtonBrushH := 225
	scrollingVelocity := 2
	scrollStopTime := 3000
	romMappingContainerCountourPen := "66000000"
	romMappingContainerOuterCountourPen := "BB000000"
	romMappingContainerBrushBackground := "33000000"
	romMappingContainerBorderSize := 5
	romMappingContainerCountourPen := Gdip_CreatePen("0x" . romMappingContainerCountourPen, romMappingContainerBorderSize)
	romMappingContainerOuterCountourPen := Gdip_CreatePen("0x" . romMappingContainerOuterCountourPen, romMappingContainerBorderSize)
	romMappingContainerBrushBackground  := Gdip_BrushCreateSolid("0x" . romMappingContainerBrushBackground)
	OptionScale(romMappingContainerBrushSize, romMappingXScale)
	OptionScale(romMappingButtonCornerRadius, romMappingXScale)
	OptionScale(romMappingButtonCornerRadius2, romMappingXScale)
	OptionScale(romMappingButtonBrushW, romMappingXScale)
	OptionScale(romMappingButtonBrushH, romMappingYScale)
	pGraphUpd(RomSelect_G3,romMappingMenuWidth,baseScreenHeight)
	pGraphUpd(RomSelect_G4,romMappingMenuWidth-2*romMappingTextMargin,romMappingTextSize)
	;Drawing Menu
	VDistBtwRomNames := baseScreenHeight//(romMappingNumberOfGamesByScreen+1)
	romMappingBackgroundBrush := Gdip_BrushCreateSolid("0x" . romMappingBackgroundBrush)	
	romMappingButtonBrush1 := Gdip_CreateLineBrushFromRect(0, 0, romMappingButtonBrushW, romMappingButtonBrushH, "0x" . romMappingButtonBrush1, "0x" . romMappingButtonBrush1)
	romMappingButtonBrush2 := Gdip_CreatePen("0x" . romMappingButtonBrush2, romMappingButtonCornerRadius2)
	romMappingColumnBrush1 := Gdip_BrushCreateSolid("0x" . romMappingColumnBrush)
	StringTrimLeft, romMappingColumnBrushTransp, romMappingColumnBrush, 2
	romMappingColumnBrush2 := Gdip_CreateLineBrushFromRect(0, 0, romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2, "0x00" . romMappingColumnBrushTransp, "0x" . romMappingColumnBrush)
	romMappingColumnBrush3 := Gdip_CreateLineBrushFromRect(0, 0, romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2, "0x00" . romMappingColumnBrushTransp, "0x" . romMappingColumnBrush)
	; Search for Background Artwork
	romMappingBG := GetRLMediaFiles("Backgrounds","png|gif|tif|bmp|jpg")
	;Drawing Background Image
	If romMappingBG {
        romMappingBGBitmap := Gdip_CreateBitmapFromFile(romMappingBG)
        Gdip_GetImageDimensions(romMappingBGBitmap, BitmapW, BitmapH)
        GetBGPicPosition(romMappingBGPicXNew,romMappingBGYNew,romMappingBGWNew,romMappingBGHNew,BitmapW,BitmapH,romMappingBackgroundAlign)	; get the background pic's new position and size
        If (romMappingBackgroundAlign = "Stretch and Lose Aspect") {	 
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, 0, 0, baseScreenWidth+1, baseScreenHeight+1, 0, 0, BitmapW, BitmapH)
        } Else If (romMappingBackgroundAlign = "Stretch and Keep Aspect" Or romMappingBackgroundAlign = "Center Width" Or romMappingBackgroundAlign = "Center Height" Or romMappingBackgroundAlign = "Align to Bottom Left" Or romMappingBackgroundAlign = "Align to Bottom Right") {
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, romMappingBGPicXNew, romMappingBGYNew, romMappingBGWNew+1, romMappingBGHNew+1, 0, 0, BitmapW, BitmapH)
        } Else If (romMappingBackgroundAlign = "Center") {	; original image size and aspect
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, romMappingBGPicXNew, romMappingBGYNew, BitmapW+1, BitmapH+1, 0, 0, BitmapW, BitmapH)
        } Else If (romMappingBackgroundAlign = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, romMappingBGPicXNew, 0,romMappingBGWNew+1,romMappingBGHNew, 0, 0, BitmapW, BitmapH)
        } Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, 0, 0,romMappingBGWNew+10,romMappingBGHNew+1, 0, 0, BitmapW, BitmapH)
        }
    }	
	;Drawing Background Brush
	Gdip_Alt_FillRectangle(RomSelect_G1, romMappingBackgroundBrush, 0, 0, baseScreenWidth, baseScreenHeight)
	; fading in the launch menu
	mapStartTime := A_TickCount
	Loop{
		tMap := ((mapTimeElapsed := A_TickCount-mapStartTime) < fadeInDuration) ? 255*(mapTimeElapsed/fadeInDuration) : 255
		Alt_UpdateLayeredWindow(RomSelect_hwnd1, RomSelect_hdc1, 0, 0, baseScreenWidth, baseScreenHeight, tMap)	; to fade in, set transparency to 0 at first
		If tMap >= 255
			Break
	}
	;Removing parent game if user wants and rom mapping sceneario 6 is active
	if (romMapScenario=6)
		if (romMappingHideParent="true")
			table.Remove(1)	
	;Creating Main Game List Object
	currentSelectedRom := 1
	mainTable := {}
	mainTable := table
	;Drawing Title Text
	LeftTextContainerWidth := baseScreenWidth-romMappingMenuMargin//2-romMappingMenuMargin//2-romMappingMenuWidth-romMappingMenuMargin
	TitleTextHeight := MeasureText("CHOOSE YOUR GAME!!!",romMappingTitleTextOptions,romMappingTitleTextFont,LeftTextContainerWidth, "", "H")
	TitleTextContainerHeight := TitleTextHeight + 2*romMappingTextMargin + romMappingTitle2TextSize
	Gdip_Alt_FillRoundedRectangle(RomSelect_G1, romMappingContainerBrushBackground, romMappingMenuMargin//2, baseScreenHeight-romMappingMenuMargin//2-TitleTextContainerHeight, LeftTextContainerWidth, TitleTextContainerHeight, romMappingBackgroundCornerRadius)
	Gdip_Alt_TextToGraphics(RomSelect_G1, "CHOOSE YOUR GAME!!!", "x" . romMappingMenuMargin//2+romMappingTextMargin . " y" . baseScreenHeight-romMappingMenuMargin//2-TitleTextContainerHeight+romMappingTextMargin . " Center " . romMappingTitleTextOptions, romMappingTitleTextFont, LeftTextContainerWidth)
	; Drawing normal rom mapping list with minimun information
	windowTransparency := 0
	currentGameInfo := []
	currentTableLabel = mainTable
	If (romMappingDefaultMenuList = "FullList"){
		for index, element in mainTable
		{	If (element.namingConvention="Tosec") 
				currentGameInfo := createTosecTable(element.romName,true)
			else if (element.namingConvention="NoIntro")
				currentGameInfo := createNoIntroTable(element.romName,true)
			else
				currentGameInfo := createFrontEndTable(element.romName)
			gameinfotext := gameinfotext(currentGameInfo)
			mainTable[index].gameinfotext := gameinfotext
			mainTable[index].displayName := currentGameInfo[1,2,1]
		}
		currentTable := %currentTableLabel%
		drawnRomSelectColumn(currentTableLabel)
		Alt_UpdateLayeredWindow(RomSelect_hwnd1, RomSelect_hdc1, 0, 0, baseScreenWidth, baseScreenHeight)
		XHotKeywrapper(navSelectKey,"SelectRom","ON")
		XHotKeywrapper(navUpKey,"SelectRomMenuMoveUp","ON")
		XHotKeywrapper(navDownKey,"SelectRomMenuMoveDown","ON")
		XHotKeywrapper(navP2SelectKey,"SelectRom","ON") 
		XHotKeywrapper(navP2UpKey,"SelectRomMenuMoveUp","ON")
		XHotKeywrapper(navP2DownKey,"SelectRomMenuMoveDown","ON")
		XHotKeywrapper(exitEmulatorKey,"CloseRomLaunchMenu")
	}	
	;Creating Filtered Game List Object and updating complete information on normal table
	filteredTable := {}
	FilterArr := []
	for index, element in mainTable
	{	showInfo := if (element.showInfo="") ? "HistoryDatDescription|HistoryDatTechnical|HistoryDatTrivia|HistoryDatSeries|HighScores" : element.showInfo 
		If (element.namingConvention="Tosec") {
			currentGameInfo := createTosecTable(element.romName)
			mainTable[index].language := currentGameInfo[8,2,1] ; game Language Flag
			mainTable[index].goodDump := currentGameInfo[24,2,1]
		} else if (element.namingConvention="NoIntro") {
			currentGameInfo := createNoIntroTable(element.romName)
			mainTable[index].language := currentGameInfo[2,2,1] ; game Language Flag	
			If !currentGameInfo[8,2,1]
				mainTable[index].goodDump := true ; good dump	
		} else
			currentGameInfo := createFrontEndTable(element.romName)
		currentGameInfo := addHistoryDatInfo(element.romName,showInfo,currentGameInfo)
		currentGameInfo := addHighScoreInfo(element.romName,showInfo,currentGameInfo)
		gameinfotext := gameinfotext(currentGameInfo)
		mainTable[index].gameinfotext := gameinfotext
		mainTable[index].displayName := currentGameInfo[1,2,1]
		If element.namingConvention
		{	FilterArr := iniFilterInfo(element.namingConvention,element.iniFile) ;reading filter info
			If FilterPass(element.namingConvention,FilterArr, currentGameInfo)	
				countFilteredGame++
		} else
			countFilteredGame++
		filteredTable[countFilteredGame] := mainTable[index]
		if ((mainTable[index].language) or (!(mainTable[index].goodDump)))
			redrawnRomSelectColumn := true
	}
	;Automatically select rom if only one filtered option is found
	If (romMappingSingleFilteredRomAutomaticLaunch="true")
		If (filteredTable.MaxIndex()=1){
			Log("RomMappingLaunchMenu - Launching single filtered rom.")
			currentTableLabel = filteredTable
			currentTable := %currentTableLabel%
			gosub, SelectRom
			if (fadeIn="false")
				DestroyRomMappingLaunchMenu()
			Return
		}
	; Removing filtered table if it doesn't filter anything
	If (filteredTable.MaxIndex()=mainTable.MaxIndex())
		filteredTable := {}
	;Setting current showed list
	If filteredTable.MaxIndex()
		If (romMappingDefaultMenuList = "FilteredList")
			If !(filteredTable.MaxIndex()=mainTable.MaxIndex()){
				currentTableLabel = filteredTable
				redrawnRomSelectColumn := true
			}
	currentTable := %currentTableLabel%
	;Enabling Hotkeys
	XHotKeywrapper(navSelectKey,"SelectRom","ON")
	XHotKeywrapper(navUpKey,"SelectRomMenuMoveUp","ON")
	XHotKeywrapper(navDownKey,"SelectRomMenuMoveDown","ON")
	XHotKeywrapper(navLeftKey,"toggleList","ON")
	XHotKeywrapper(navRightKey,"toggleList","ON")
    XHotKeywrapper(navP2SelectKey,"SelectRom","ON") 
    XHotKeywrapper(navP2UpKey,"SelectRomMenuMoveUp","ON")
    XHotKeywrapper(navP2DownKey,"SelectRomMenuMoveDown","ON")
	XHotKeywrapper(navP2LeftKey,"toggleList","ON")
    XHotKeywrapper(navP2RightKey,"toggleList","ON")
	XHotKeywrapper(exitEmulatorKey,"CloseRomLaunchMenu", "ON")
	If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true") {
		Log("CreateRomMappingLaunchMenu - Running keymapper to load the ""menu"" profile.",5)
        RunKeymapper%zz%("menu",keymapper)
	}
	;Loading Language Flags Bitmaps
	Loop, %RLMediaPath%\Menu Images\Rom Mapping Launch Menu\Language Flags\*.png
		{
		SplitPath, A_LoopFileFullPath, , , , currentFileName
		Bitmap%currentFileName% := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
	}
	;Loading Warning bitmap
	bitmapNoGoodDump := Gdip_CreateBitmapFromFile( RLMediaPath . "\Menu Images\Rom Mapping Launch Menu\Icons\no Good Dump.png")
	;Redrawing Select Menu if necessary
	if (redrawnRomSelectColumn)
		drawnRomSelectColumn(currentTableLabel)
	else
		DrawRomMapGameInfo()
	;finalizing 
	romMapLaunchMenuCreated := 1	; let other features know the menu was created
	LEDBlinky("RL")	; trigger ledblinky profile change if enabled
	KeymapperProfileSelect("RL", keyboardEncoderEnabled, winIPACFullPath, "ipc", "keyboard")
	KeymapperProfileSelect("RL", "UltraMap", ultraMapFullPath, "ugc")
	Log("CreateRomMappingLaunchMenu - Ended")
	Loop {
		If romMappingMenuExit
			Break
		Sleep, 100	; don't allow it to bog the cpu down
	}
	if (fadeIn="false")
		DestroyRomMappingLaunchMenu()
	LEDBlinky("ROM")	; trigger ledblinky profile change if enabled
	KeymapperProfileSelect("RESUME", keyboardEncoderEnabled, winIPACFullPath, "ipc", "keyboard")
	KeymapperProfileSelect("RESUME", "UltraMap", ultraMapFullPath, "ugc")
Return
}


DestroyRomMappingLaunchMenu(){
	Global
	Log("DestroyRomMappingLaunchMenu - Started",5)
	SetTimer, UpdateCurrentRomScrollingText, off
	SetTimer, UpdateGameInfoScrollingText, off
	; Destroying Menu GUIs
	mapStartTime := A_TickCount
	Loop{	; fading out the launch menu
		tMap := ((mapTimeElapsed := A_TickCount-mapStartTime) < fadeOutDuration) ? 255*(1-(mapTimeElapsed/fadeOutDuration)) : 0
		UpdateLayeredWindow(RomSelect_hwnd1, RomSelect_hdc1,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd2, RomSelect_hdc2,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd3, RomSelect_hdc3,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd4, RomSelect_hdc4,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd5, RomSelect_hdc5,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd6, RomSelect_hdc6,,,,, tMap)
		If tMap <= 0
			Break
	}
	Loop, 6 { 
        CurrentGUI := A_Index
        SelectObject(RomSelect_hdc%CurrentGUI%, RomSelect_obm%CurrentGUI%)
		DeleteObject(RomSelect_hbm%CurrentGUI%)
		DeleteDC(RomSelect_hdc%CurrentGUI%)
		Gdip_DeleteGraphics(RomSelect_G%CurrentGUI%)
		Gui, RomSelect_GUI%CurrentGUI%: Destroy
	}
	Gdip_DeleteBrush(romMappingBackgroundBrush), Gdip_DeleteBrush(romMappingButtonBrush1), Gdip_DeleteBrush(romMappingButtonBrush2), Gdip_DeleteBrush(romMappingColumnBrush1), Gdip_DeleteBrush(romMappingColumnBrush2), Gdip_DeleteBrush(romMappingColumnBrush3), Gdip_DeleteBrush(romMappingContainerBrushBackground)
	Gdip_DeletePen(romMappingContainerCountourPen), Gdip_DeletePen(romMappingContainerOuterCountourPen)
	Gdip_DisposeImage(romMappingBG)
	romMapLaunchMenuCreated :=
	Log("DestroyRomMappingLaunchMenu - Ended",5)
Return	
}

drawnRomSelectColumn(tableLabel){
	Global
	Log("drawnRomSelectColumn - Started",5)
	SetTimer, UpdateGameInfoScrollingText, off
	Gdip_GraphicsClear(RomSelect_G3)
	Gdip_GraphicsClear(RomSelect_G4)
	;Drawing Games List column
	Gdip_Alt_FillRectangle(RomSelect_G3, romMappingColumnBrush1, 0, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2, romMappingMenuWidth, VDistBtwRomNames*romMappingNumberOfGamesByScreen)
	Gdip_Alt_FillRectangle(RomSelect_G3, romMappingColumnBrush2, 0, 0,romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2)
	Gdip_Alt_FillRectangle(RomSelect_G3, romMappingColumnBrush3, 0, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2+VDistBtwRomNames*romMappingNumberOfGamesByScreen, romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2)
	bottomtext := currentSelectedRom
	topText := currentSelectedRom
	Loop, % romMappingNumberOfGamesByScreen//2+1
		{
		currentIndex := a_index
		If (a_index=1)
			{
			Gdip_Alt_FillRoundedRectangle(RomSelect_G3, romMappingButtonBrush1, romMappingTextMargin, (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin, (romMappingMenuWidth-2*romMappingTextMargin),romMappingTextSize+2*romMappingTextMargin, romMappingButtonCornerRadius)
			Gdip_Alt_DrawRoundedRectangle(RomSelect_G3, romMappingButtonBrush2, romMappingTextMargin, (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin, (romMappingMenuWidth-2*romMappingTextMargin), romMappingTextSize+2*romMappingTextMargin, romMappingButtonCornerRadius)
			currentSelectedRomText := currentTable[currentSelectedRom].displayName
			MeasureCurrentSelectedRomText := MeasureText(currentSelectedRomText, "Left r4 s" . romMappingTextSize . " Bold",romMappingTextFont)
			If (MeasureCurrentSelectedRomText<=(romMappingMenuWidth-2*romMappingTextMargin)-2*romMappingTextMargin) {
				SetTimer, UpdateCurrentRomScrollingText, off
				TextOptions := "x0 y0 Center c" . romMappingSelectTextColor . " r4 s" . romMappingTextSize . " bold"
				Gdip_Alt_TextToGraphics(RomSelect_G4, currentSelectedRomText, TextOptions, romMappingTextFont, (romMappingMenuWidth-2*romMappingTextMargin)-2*romMappingTextMargin, romMappingTextSize)
			} Else {	
				scrollTextX := 0
				initPixels := 0
				gameScrollingTextWidth := MeasureText(currentSelectedRomText," r4 s" . romMappingTextSize . " bold",romMappingTextFont)
				gameScrollingTextTimeout := A_TickCount
				SetTimer, UpdateCurrentRomScrollingText, 20
			}
			LanguageFlag := mainTable[currentSelectedRom].language
			If LanguageFlag
				{
				Loop, parse, LanguageFlag, `,
					{
					Gdip_GetImageDimensions(Bitmap%A_LoopField%, BitmapW, BitmapH)
					Gdip_Alt_DrawImage(RomSelect_G3, Bitmap%A_LoopField%, romMappingMenuWidth-romMappingTextMargin-romMappingMenuFlagWidth- (a_index-1)*(romMappingMenuFlagWidth+romMappingMenuFlagSeparation), (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin-round(romMappingMenuFlagWidth*BitmapH/BitmapW)//2,romMappingMenuFlagWidth,round(romMappingMenuFlagWidth*BitmapH/BitmapW))
				}
			}
			If !currentTable[currentSelectedRom].goodDump and ((currentTable[currentSelectedRom].namingConvention = "Tosec") or (currentTable[currentSelectedRom].namingConvention = "NoIntro")) 
				{
				Gdip_GetImageDimensions(bitmapNoGoodDump, BitmapW, BitmapH)
				Gdip_Alt_DrawImage(RomSelect_G3, bitmapNoGoodDump, romMappingMenuWidth-romMappingTextMargin-romMappingMenuFlagWidth//2, (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin-round(romMappingMenuFlagWidth*BitmapH/BitmapW)//2,romMappingMenuFlagWidth//2,round(romMappingMenuFlagWidth*BitmapH/BitmapW)//2)
			}
		} Else {
			currentromTextSize := If (romMappingTextSize-a_index*romMappingTextSizeDifference>1) ? (romMappingTextSize-a_index*romMappingTextSizeDifference) : 1
			bottomtext++
			bottomtext := If (bottomtext > currentTable.MaxIndex()) ? 1 : bottomtext
			bottomTextContainerX := (romMappingMenuWidth-2*romMappingTextMargin)-(romMappingMenuWidth-2*romMappingTextMargin)+((romMappingMenuWidth-2*romMappingTextMargin)-(romMappingMenuWidth-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize))//2+romMappingTextMargin
			bottomTextContainerY := round((baseScreenHeight-romMappingTextSize)//2+(a_index-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize))
			bottomTextContainerW := round((romMappingMenuWidth-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize))
			bottomTextContainerH := round((romMappingTextSize+2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize))
			Gdip_Alt_FillRoundedRectangle(RomSelect_G3, romMappingButtonBrush1, bottomTextContainerX, bottomTextContainerY, bottomTextContainerW, bottomTextContainerH, round(romMappingButtonCornerRadius*(currentromTextSize/romMappingTextSize)))
			TextOptions := "x" . bottomTextContainerX+romMappingTextMargin . " y" . (baseScreenHeight-romMappingTextSize)//2+(a_index-1)*(VDistBtwRomNames) . " Center c" . romMappingDisabledTextColor . " r4 s" . currentromTextSize . " normal"
			Gdip_Alt_TextToGraphics(RomSelect_G3, currentTable[bottomtext].displayName, TextOptions, romMappingTextFont, round(((romMappingMenuWidth-2*romMappingTextMargin)-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize)), currentromTextSize)
			LanguageFlag := mainTable[bottomtext].language
			If LanguageFlag
				{
				Loop, parse, LanguageFlag, `,
					{
					Gdip_GetImageDimensions(Bitmap%A_LoopField%, BitmapW, BitmapH)
					Gdip_Alt_DrawImage(RomSelect_G3, Bitmap%A_LoopField%, bottomTextContainerX+bottomTextContainerW-(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize))- (a_index-1)*(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)+romMappingMenuFlagSeparation*(currentromTextSize/romMappingTextSize)), bottomTextContainerY-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2,round(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)),round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize)))      
				}
			}
			If (!(currentTable[bottomtext].goodDump) and ((currentTable[bottomtext].namingConvention = "Tosec") or (currentTable[bottomtext].namingConvention = "NoIntro"))) 
				{
				Gdip_GetImageDimensions(bitmapNoGoodDump, BitmapW, BitmapH)
				Gdip_Alt_DrawImage(RomSelect_G3, bitmapNoGoodDump, bottomTextContainerX+bottomTextContainerW-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))//2, round((baseScreenHeight-romMappingTextSize)/2+(currentIndex-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2),(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize))//2,round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))//2)
			}
			topText--
			topText := If (topText < 1) ? currentTable.MaxIndex() : topText
			topTextContainerX := ((romMappingMenuWidth-2*romMappingTextMargin)-(romMappingMenuWidth-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize))//2
			topTextContainerY := round((baseScreenHeight-romMappingTextSize)//2-(a_index-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize))
			topTextContainerW := round((romMappingMenuWidth-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize))
			topTextContainerH := round((romMappingTextSize+2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize))
			Gdip_Alt_FillRoundedRectangle(RomSelect_G3, romMappingButtonBrush1, topTextContainerX, topTextContainerY, topTextContainerW, topTextContainerH, round(romMappingButtonCornerRadius*(currentromTextSize/romMappingTextSize)))
			TextOptions := "x" . topTextContainerX+romMappingTextMargin . " y" . (baseScreenHeight-romMappingTextSize)//2-(a_index-1)*(VDistBtwRomNames) . " Center c" . romMappingDisabledTextColor . " r4 s" . currentromTextSize . " normal"
			Gdip_Alt_TextToGraphics(RomSelect_G3, currentTable[topText].displayName, TextOptions, romMappingTextFont, round(((romMappingMenuWidth-2*romMappingTextMargin)-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize)), currentromTextSize)
			LanguageFlag := mainTable[topText].language
			If LanguageFlag
				{
				Loop, parse, LanguageFlag, `,
					{
					Gdip_GetImageDimensions(Bitmap%A_LoopField%, BitmapW, BitmapH)
					Gdip_Alt_DrawImage(RomSelect_G3, Bitmap%A_LoopField%, topTextContainerX+topTextContainerW-(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize))-(a_index-1)*(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)+romMappingMenuFlagSeparation*(currentromTextSize/romMappingTextSize)), topTextContainerY-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2,round(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)),round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize)))      
				}
			}
			If !currentTable[topText].goodDump and ((currentTable[topText].namingConvention = "Tosec") or (currentTable[topText].namingConvention = "NoIntro")) 
				{
				Gdip_GetImageDimensions(bitmapNoGoodDump, BitmapW, BitmapH)
				Gdip_Alt_DrawImage(RomSelect_G3, bitmapNoGoodDump, topTextContainerX+topTextContainerW-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))//2, round((baseScreenHeight-romMappingTextSize)/2-(currentIndex-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2),(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize))//2,round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))//2)
			}
		}	
	}
	;Update Game Info
	DrawRomMapGameInfo()
	;Update Screen
	Alt_UpdateLayeredWindow(RomSelect_hwnd3, RomSelect_hdc3, baseScreenWidth-romMappingMenuMargin-romMappingMenuWidth, 0, romMappingMenuWidth, baseScreenHeight)
	Alt_UpdateLayeredWindow(RomSelect_hwnd4, RomSelect_hdc4, baseScreenWidth-romMappingMenuMargin-romMappingMenuWidth+romMappingTextMargin+romMappingTextMargin, (baseScreenHeight-romMappingTextSize)//2, (romMappingMenuWidth-2*romMappingTextMargin)-2*romMappingTextMargin, romMappingTextSize)
	windowTransparency := 255
	Log("drawnRomSelectColumn - Ended",5)
Return	
}

DrawRomMapGameInfo(){
	Global 
	Gdip_GraphicsClear(RomSelect_G2)
	Gdip_GraphicsClear(RomSelect_G5)
	Gdip_GraphicsClear(RomSelect_G6)
	;Drawing Title text 2 help
	Title2TextOption := "x" . romMappingMenuMargin//2+romMappingTextMargin . " y" . baseScreenHeight-romMappingMenuMargin//2-romMappingTextMargin-romMappingTitle2TextSize . " Center " . romMappingTitle2TextOptions
	If (currentTableLabel="mainTable"){
		if (filteredTable.MaxIndex()>1)
			Gdip_Alt_TextToGraphics(RomSelect_G2, "Game " . currentSelectedRom . " of " . currentTable.MaxIndex() . " - Press Left or Right to go to Filtered Games List", Title2TextOption, romMappingTitle2TextFont, LeftTextContainerWidth, 0)
		else
			Gdip_Alt_TextToGraphics(RomSelect_G2, "Game " . currentSelectedRom . " of " . currentTable.MaxIndex(), Title2TextOption, romMappingTitle2TextFont, LeftTextContainerWidth, 0)
	} else 
		Gdip_Alt_TextToGraphics(RomSelect_G2, "Game " . currentSelectedRom . " of " . currentTable.MaxIndex() . " - Press Left or Right to go to Full Games List", Title2TextOption, romMappingTitle2TextFont, LeftTextContainerWidth, 0)
	; Draw game name
	displayNameTextHeight := MeasureText(currentTable[currentSelectedRom].displayName," Left " . romMappingGameNameTextOptions,romMappingGameNameTextFont,baseScreenWidth-romMappingMenuMargin-romMappingMenuMargin-romMappingMenuWidth-2*romMappingTextMargin, "", "H")
	displayNameContainerHeight := displayNameTextHeight+2*romMappingTextMargin
	Gdip_DrawRoundedRectangle(RomSelect_G2, romMappingContainerOuterCountourPen, romMappingMenuMargin//2+romMappingContainerBorderSize, romMappingMenuMargin//2+romMappingContainerBorderSize, LeftTextContainerWidth-2*romMappingContainerBorderSize, displayNameContainerHeight-2*romMappingContainerBorderSize, 2*romMappingContainerBorderSize)
	Gdip_DrawRoundedRectangle(RomSelect_G2, romMappingContainerCountourPen, romMappingMenuMargin//2+2*romMappingContainerBorderSize, romMappingMenuMargin//2+2*romMappingContainerBorderSize, LeftTextContainerWidth-4*romMappingContainerBorderSize, displayNameContainerHeight-4*romMappingContainerBorderSize, romMappingContainerBorderSize)
	Gdip_Alt_FillRoundedRectangle(RomSelect_G2, romMappingContainerBrushBackground, romMappingMenuMargin//2, romMappingMenuMargin//2, LeftTextContainerWidth, displayNameContainerHeight, romMappingBackgroundCornerRadius)
	Gdip_Alt_TextToGraphics(RomSelect_G2, currentTable[currentSelectedRom].displayName, "x" . romMappingMenuMargin//2+romMappingTextMargin+2*romMappingContainerBorderSize . " y" . romMappingMenuMargin//2+romMappingTextMargin . " Left " . romMappingGameNameTextOptions, romMappingGameNameTextFont, LeftTextContainerWidth-2*romMappingTextMargin-4*romMappingContainerBorderSize)
	; Draw game info text
	;container
	gamenInfoContainerWidth := LeftTextContainerWidth
	gamenInfoContainerHeight := baseScreenHeight - romMappingMenuMargin//2 - displayNameContainerHeight - romMappingMenuMargin//2 - TitleTextContainerHeight - romMappingMenuMargin//2 - romMappingMenuMargin//2
	pGraphUpd(RomSelect_G5,LeftTextContainerWidth,gamenInfoContainerHeight)
	Gdip_DrawRoundedRectangle(RomSelect_G5, romMappingContainerOuterCountourPen, romMappingContainerBorderSize, romMappingContainerBorderSize, LeftTextContainerWidth-2*romMappingContainerBorderSize, gamenInfoContainerHeight-2*romMappingContainerBorderSize, 2*romMappingContainerBorderSize)
	Gdip_DrawRoundedRectangle(RomSelect_G5, romMappingContainerCountourPen, 2*romMappingContainerBorderSize, 2*romMappingContainerBorderSize, LeftTextContainerWidth-4*romMappingContainerBorderSize, gamenInfoContainerHeight-4*romMappingContainerBorderSize, romMappingContainerBorderSize)
	Gdip_Alt_FillRoundedRectangle(RomSelect_G5, romMappingContainerBrushBackground, 0, 0, LeftTextContainerWidth, gamenInfoContainerHeight, romMappingBackgroundCornerRadius)
	;text
	infoLineWithoutName := SubStr( currentTable[currentSelectedRom].gameinfotext ,Instr(currentTable[currentSelectedRom].gameinfotext,"`n")+1)
	pGraphUpd(RomSelect_G6,LeftTextContainerWidth-2*romMappingTextMargin,gamenInfoContainerHeight-2*romMappingTextMargin)
	gameInfoTextHeight := MeasureText(infoLineWithoutName," Left " . romMappingGameInfoTextOptions,romMappingGameInfoTextFont,LeftTextContainerWidth-2*romMappingTextMargin-4*romMappingContainerBorderSize,"","H")
	if (gameInfoTextHeight < gamenInfoContainerHeight-2*romMappingTextMargin){
		Gdip_Alt_TextToGraphics(RomSelect_G6, infoLineWithoutName, " Left " . romMappingGameInfoTextOptions, romMappingGameInfoTextFont, LeftTextContainerWidth-2*romMappingTextMargin)
	} else {
		diffTextHeight := gameInfoTextHeight - (gamenInfoContainerHeight-2*romMappingTextMargin-4*romMappingContainerBorderSize)
		scrollTextY := 0
		gameInfoScrollingTextTimeout := A_TickCount
		SetTimer, UpdateGameInfoScrollingText, 20
	}
	Alt_UpdateLayeredWindow(RomSelect_hwnd2, RomSelect_hdc2, 0, 0, baseScreenWidth, baseScreenHeight)
	Alt_UpdateLayeredWindow(RomSelect_hwnd5, RomSelect_hdc5, romMappingMenuMargin//2, romMappingMenuMargin//2 + displayNameContainerHeight + romMappingMenuMargin//2,LeftTextContainerWidth,gamenInfoContainerHeight)
	Alt_UpdateLayeredWindow(RomSelect_hwnd6, RomSelect_hdc6, romMappingMenuMargin//2+romMappingTextMargin+2*romMappingContainerBorderSize, romMappingMenuMargin//2 + displayNameContainerHeight + romMappingMenuMargin//2+romMappingTextMargin+2*romMappingContainerBorderSize ,LeftTextContainerWidth-2*romMappingTextMargin-4*romMappingContainerBorderSize,gamenInfoContainerHeight-2*romMappingTextMargin-4*romMappingContainerBorderSize)
Return
}

UpdateGameInfoScrollingText: 
	If (-scrollTextY >= diffTextHeight) and (wait){
		gameInfoScrollingTextTimeout := A_TickCount
		wait := false
	}
	If (gameInfoScrollingTextTimeout<A_TickCount-scrollStopTime){
		scrollTextY := (-scrollTextY >= diffTextHeight) ? 0 : scrollTextY-scrollingVelocity
		wait := true
	}
	If (scrollTextY = 0) and (wait){
		gameInfoScrollingTextTimeout := A_TickCount
		wait := false
	}
	Gdip_GraphicsClear(RomSelect_G6)
	Gdip_Alt_TextToGraphics(RomSelect_G6, infoLineWithoutName, "y" . scrollTextY . " Left " . romMappingGameInfoTextOptions, romMappingGameInfoTextFont, LeftTextContainerWidth-2*romMappingTextMargin)
	Alt_UpdateLayeredWindow(RomSelect_hwnd6, RomSelect_hdc6, romMappingMenuMargin//2+romMappingTextMargin+2*romMappingContainerBorderSize, romMappingMenuMargin//2 + displayNameContainerHeight + romMappingMenuMargin//2+romMappingTextMargin+2*romMappingContainerBorderSize ,LeftTextContainerWidth-2*romMappingTextMargin-4*romMappingContainerBorderSize,gamenInfoContainerHeight-2*romMappingTextMargin-4*romMappingContainerBorderSize,windowTransparency)
Return

UpdateCurrentRomScrollingText: ;Updating scrolling rom name
    If (-scrollTextX >= gameScrollingTextWidth) and (wait2){
		gameScrollingTextTimeout := A_TickCount
		wait2 := false
	}
	If (gameScrollingTextTimeout<A_TickCount-scrollStopTime){
		scrollTextX := (-scrollTextX >= gameScrollingTextWidth) ? initPixels : scrollTextX-scrollingVelocity
		wait2 := true
	}
	initPixels := romMappingMenuWidth-2*romMappingTextMargin
    Gdip_GraphicsClear(RomSelect_G4)
    Gdip_Alt_TextToGraphics((RomSelect_G4), currentSelectedRomText, "x" scrollTextX " y0 c" . romMappingSelectTextColor . " r4 s" . romMappingTextSize . " bold", romMappingTextFont, (scrollTextX < 0) ? baseScreenWidth+romMappingTextSize-x : baseScreenWidth+romMappingTextSize, romMappingTextSize)
    Alt_UpdateLayeredWindow(RomSelect_hwnd4, RomSelect_hdc4, baseScreenWidth-romMappingMenuMargin-romMappingMenuWidth+romMappingTextMargin+romMappingTextMargin, (baseScreenHeight-romMappingTextSize)//2, (romMappingMenuWidth-2*romMappingTextMargin)-2*romMappingTextMargin, romMappingTextSize,windowTransparency)
Return

SelectRom:
	Log("SelectRom - Started",5)
	XHotKeywrapper(navSelectKey,"SelectRom","OFF")
	XHotKeywrapper(navUpKey,"SelectRomMenuMoveUp","OFF")
	XHotKeywrapper(navDownKey,"SelectRomMenuMoveDown","OFF")
	XHotKeywrapper(navLeftKey,"toggleList","OFF")
	XHotKeywrapper(navRightKey,"toggleList","OFF")
    XHotKeywrapper(navP2SelectKey,"SelectRom","OFF") 
    XHotKeywrapper(navP2UpKey,"SelectRomMenuMoveUp","OFF")
    XHotKeywrapper(navP2DownKey,"SelectRomMenuMoveDown","OFF")
	XHotKeywrapper(navP2LeftKey,"toggleList","OFF")
    XHotKeywrapper(navP2RightKey,"toggleList","OFF")
	XHotKeywrapper(exitEmulatorKey,"CloseRomLaunchMenu","OFF")
	If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true") {
		Log("SelectRom - Running keymapper to load the ""load"" profile.",5)
        RunKeymapper%zz%("load",keymapper)
	}
	romMappingMenuExit := true
	romName := currentTable[currentSelectedRom].romName
	romPath := currentTable[currentSelectedRom].romPath
	romExtension := "." . currentTable[currentSelectedRom].romExtension
	Log("SelectRom - User selected this game from the Launch Menu:" . "`r`n`t`t`t`t`t" . "Rom Name: " . romName . "`r`n`t`t`t`t`t" . "Rom Path: " . romPath . "`r`n`t`t`t`t`t" . "Rom Extension: " . romExtension,5)
	XHotKeywrapper(exitEmulatorKey,"CloseProcess")
	Log("SelectRom - Ended",5)
Return


CloseRomLaunchMenu:
	Log("CloseRomLaunchMenu - Started",5)
	Log("CloseRomLaunchMenu - User canceled out of the launch menu.",5)
	DestroyRomMappingLaunchMenu()
	ExitModule()
	Log("CloseRomLaunchMenu - Ended",5)
Return

SelectRomMenuMoveUp:
	currentSelectedRom--
	If  currentSelectedRom < 1
		currentSelectedRom := currentTable.MaxIndex()
	Log("SelectRomMenuMoveUp - Current selection changed to: " . currentTable[currentSelectedRom].displayName,5)
	drawnRomSelectColumn(currentTableLabel) 
Return

SelectRomMenuMoveDown:
	currentSelectedRom++
	If  currentSelectedRom > % currentTable.MaxIndex()
		currentSelectedRom = 1 
	Log("SelectRomMenuMoveDown - Current selection changed to: " . currentTable[currentSelectedRom].displayName,5)
	drawnRomSelectColumn(currentTableLabel) 
Return

toggleList:
	If filteredTable.MaxIndex()
		{
		currentSelectedRom := 1
		If (currentTableLabel = "mainTable")
			currentTableLabel = filteredTable
		Else
			currentTableLabel = mainTable
		currentTable := {}
		currentTable := %currentTableLabel%
		drawnRomSelectColumn(currentTableLabel) 
	}
Return

iniFilterInfo(namingConvention,iniFile){
	filterInfo := {}
	If (namingConvention="Tosec") {
		list := "Demo|Year|Publisher|System|Resolution|Origin_Country|Language|Copyright|Development_Status|Media_Type|Media_Label|Cracked_Dump|Fix_Dump|Hacked_Dump|Modified_Dump|Pirate_Dump|Translated|Trained_Dump|Over_Dump|Under_Dump|Virus_Dump|Bad_Dump|Verified_Dump"
		Loop, parse, list, |
		{	FilterArr[a_index+1] :=
			IniRead, %a_loopfield%, %iniFile%,Filter,%a_loopfield%, %a_space%
			FilterArr[a_index+1] := %a_loopfield%
		}
	} Else If (namingConvention="NoIntro") {
		list := "Language|Region|Development_Status|Version|Bios|Unlicensed_Game|Bad_or_Hacked_Dump"
		Loop, parse, list, |
		{	FilterArr[a_index+1] :=
			IniRead, value, %iniFile%,Filter,%a_loopfield%, %a_space%
			FilterArr[a_index+1] := %a_loopfield%
		}
	}
	Return filterInfo
}

FilterPass(NameConv, FilterArr, currentGameInfo){
	;Log("FilterPass - Started",5)
	filter := true
	If (NameConv="Tosec") {
		Loop, 25
			{
			currentItem := a_index+1
			currentIniFilterChoice := % FilterArr[currentItem] ; ini file filter list
			If !(currentItem=18){
				If currentIniFilterChoice
					{
					currentGameInfoList := currentGameInfo[currentItem,2,1]
					If currentGameInfoList
						{
						If (currentItem=7) or (currentItem=8) {
							Loop, parse, currentGameInfoList, -
								{
								If a_loopfield not in %currentIniFilterChoice%
									filter := false
							}
						} Else If (currentItem>=13) and (currentItem<=24) {
							If (currentIniFilterChoice="false")
								filter := false
						} Else {
							If currentGameInfoList not in %currentIniFilterChoice%
								filter := false
						}
					}
				}
			}
		}
	} 	Else If (NameConv="NoIntro") {
		Loop, 8
			{
			currentItem := a_index+1
			currentIniFilterChoice := % FilterArr[currentItem] ; ini file filter list
			If currentIniFilterChoice
				{
				currentGameInfoList := currentGameInfo[currentItem,2,1]
				If currentGameInfoList
					{
					If (currentItem=2) or (currentItem=3) {
						Loop, parse, currentGameInfoList, `,
							{
							If a_loopfield not in %currentIniFilterChoice%
								filter := false
						}
					} Else If (currentItem>=6) and (currentItem<=8) {
							If (currentIniFilterChoice="false")
								filter := false
					} Else {
						If currentGameInfoList not in %currentIniFilterChoice%
							filter := false
					}
				}
			}
		}	
	}
	;Log("FilterPass - Ended",5)
Return	filter
}

createTosecTable(GameName,nameOnly:=false){
	;Log("createTosecTable - Started",5)
	tosecTable := []
	tosecTable[1,1,1] := "Name"
	tosecTable[2,1,1] := "Demo Info"
	tosecTable[3,1,1] := "Year"
	tosecTable[4,1,1] := "Publisher"
	tosecTable[5,1,1] := "System Info"	
	tosecTable[6,1,1] := "Video Info"	
	tosecTable[7,1,1] := "Country Info"	
	tosecTable[8,1,1] := "Language Info"
	tosecTable[9,1,1] := "Copyright Status"
	tosecTable[10,1,1] := "Development Status"
	tosecTable[11,1,1] := "Media Type"
	tosecTable[12,1,1] := "Media Label"
	tosecTable[13,1,1] := "Cracked Dump" 
	tosecTable[14,1,1] := "Fix Dump" 
	tosecTable[15,1,1] := "Hacked Dump" 
	tosecTable[16,1,1] := "Modified Dump" 
	tosecTable[17,1,1] := "Pirate Dump" 
	tosecTable[18,1,1] := "Translated Dump"
	tosecTable[19,1,1] := "Trained Dump" 
	tosecTable[20,1,1] := "Over Dump"
	tosecTable[21,1,1] := "Under Dump"
	tosecTable[22,1,1] := "Virus Dump" 
	tosecTable[23,1,1] := "Bad Dump" 
	tosecTable[24,1,1] := "Verified Dump" 
	tosecTable[25,1,1] := "More Info"
	tosecTable[26,1,1] := "Non Identified Info"
	reducedText := GameName
	;game name
		RegExMatch(reducedText, "[^(]*",name)
		RegExMatch(name, "[^[]*",name)
		StringReplace,reducedText,reducedText,%name%
		gameName:=RegExReplace(name,"^\s*","") ; remove leading
		gameName:=RegExReplace(name,"\s*$","") ; remove trailing
		tosecTable[1,2,1] := name
	if (nameOnly)
		Return tosecTable
	;searching demo info
		demoList := "demo|demo-kiosk|demo-playable|demo-slideshow"
		tosecTable[2,2,1] := extractinfo(reducedText, demoList)
	;searching year 
		tosecTable[3,2,1] := extractinfo(reducedText, "[0-9][0-9][0-9][0-9][^)]*","","","",true)
		RegExMatch(tosecTable[3,2,1], "[0-9][0-9][0-9][0-9]",year) 
		If tosecTable[3,2,1]
			tosecTable[3,2,2] := year
	;searching Publisher 
		tosecTable[4,2,1] := extractinfo(reducedText, "[^)]*","","","",true)
	;Searching for System info
		systemList := "+2|+2a|+3|130XE|A1000|A1200|A1200-A4000|A2000|A2000-A3000|A2024|A2500-A3000UX|A3000|A4000|A4000T|A500|A500+|A500-A1000-A2000|A500-A1000-A2000-CDTV|A500-A1200|A500-A1200-A2000-A4000|A500-A2000|A500-A600-A2000|A570|A600|A600HD|AGA|AGA-CD32|Aladdin Deck Enhancer|CD32|CDTV|Computrainer|Doctor PC Jr.|ECS|ECS-AGA|Executive|Mega ST|Mega-STE|OCS|OCS-AGA|ORCH80|Osbourne 1|PIANO90|PlayChoice-10|Plus4|Primo-A|Primo-A64|Primo-B|Primo-B64|Pro-Primo|ST|STE|STE-Falcon|TT|TURBO-R GT|TURBO-R ST|VS DualSystem|VS UniSystem"
		systemDescriptionList := "Sinclair ZX Spectrum|Sinclair ZX Spectrum|Sinclair ZX Spectrum|Atari 8-bit|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Nintendo NES|Commodore Amiga|Commodore Amiga|Nintendo NES|Nintendo NES|Commodore Amiga|Commodore Amiga|Osborne OSBORNE 1 & Executive|Atari ST|Atari ST|Commodore Amiga|Commodore Amiga|???|Osborne OSBORNE 1 & Executive|???|Nintendo NES|???|Microkey Primo|Microkey Primo|Microkey Primo|Microkey Primo|Microkey Primo|Atari ST|Atari ST|???|Atari ST|MSX|MSX|Nintendo NES|Nintendo NES"
		tosecTable[5,2,1] := extractinfo(reducedText,systemList, systemDescriptionList, systemdescription, true)
		If tosecTable[5,2,1]
			tosecTable[5,2,2] := systemdescription
	;searching video info 
		videoList := "MCGA|CGA|EGA|HGC|MDA|NTSC-PAL|NTSC|PAL-60|PAL-NTSC|PAL|SVGA|VGA|XGA"
		tosecTable[6,2,1] := extractinfo(reducedText, videoList)
	;Searching for country info 
		countryList := "AD|AE|AF|AG|AI|AL|AM|AO|AQ|AR|AS|AT|AU|AW|AX|AZ|BA|BB|BD|BE|BF|BG|BH|BI|BJ|BL|BM|BN|BO|BQ|BR|BS|BT|BV|BW|BY|BZ|CA|CC|CD|CF|CG|CH|CI|CK|CL|CM|CN|CO|CR|CU|CV|CW|CX|CY|CZ|DE|DJ|DK|DM|DO|DZ|EC|EE|EG|EH|ER|ES|ET|FI|FJ|FK|FM|FO|FR|GA|GB|GD|GE|GF|GG|GH|GI|GL|GM|GN|GP|GQ|GR|GS|GT|GU|GW|GY|HK|HM|HN|HR|HT|HU|ID|IE|IL|IM|IN|IO|IQ|IR|IS|IT|JE|JM|JO|JP|KE|KG|KH|KI|KM|KN|KP|KR|KW|KY|KZ|LA|LB|LC|LI|LK|LR|LS|LT|LU|LV|LY|MA|MC|MD|ME|MF|MG|MH|MK|ML|MM|MN|MO|MP|MQ|MR|MS|MT|MU|MV|MW|MX|MY|MZ|NA|NC|NE|NF|NG|NI|NL|NO|NP|NR|NU|NZ|OM|PA|PE|PF|PG|PH|PK|PL|PM|PN|PR|PS|PT|PW|PY|QA|RE|RO|RS|RU|RW|SA|SB|SC|SD|SE|SG|SH|SI|SJ|SK|SL|SM|SN|SO|SR|SS|ST|SV|SX|SY|SZ|TC|TD|TF|TG|TH|TJ|TK|TL|TM|TN|TO|TR|TT|TV|TW|TZ|UA|UG|UM|US|UY|UZ|VA|VC|VE|VG|VI|VN|VU|WF|WS|YE|YT|ZA|ZM|ZW"
		countryDescriptionList := "Andorra|United Arab Emirates|Afghanistan|Antigua and Barbuda|Anguilla|Albania|Armenia|Angola|Antarctica|Argentina|American Samoa|Austria|Australia|Aruba|�and Islands|Azerbaijan|Bosnia and Herzegovina|Barbados|Bangladesh|Belgium|Burkina Faso|Bulgaria|Bahrain|Burundi|Benin|Saint Barth�my|Bermuda|Brunei Darussalam|Bolivia, Plurinational State of|Bonaire, Sint Eustatius and Saba|Brazil|Bahamas|Bhutan|Bouvet Island|Botswana|Belarus|Belize|Canada|Cocos (Keeling) Islands|Congo, the Democratic Republic of the|Central African Republic|Congo|Switzerland|C�d'Ivoire|Cook Islands|Chile|Cameroon|China|Colombia|Costa Rica|Cuba|Cape Verde|Cura�|Christmas Island|Cyprus|Czech Republic|Germany|Djibouti|Denmark|Dominica|Dominican Republic|Algeria|Ecuador|Estonia|Egypt|Western Sahara|Eritrea|Spain|Ethiopia|Finland|Fiji|Falkland Islands (Malvinas)|Micronesia, Federated States of|Faroe Islands|France|Gabon|United Kingdom|Grenada|Georgia|French Guiana|Guernsey|Ghana|Gibraltar|Greenland|Gambia|Guinea|Guadeloupe|Equatorial Guinea|Greece|South Georgia and the South Sandwich Islands|Guatemala|Guam|Guinea-Bissau|Guyana|Hong Kong|Heard Island and McDonald Islands|Honduras|Croatia|Haiti|Hungary|Indonesia|Ireland|Israel|Isle of Man|India|British Indian Ocean Territory|Iraq|Iran, Islamic Republic of|Iceland|Italy|Jersey|Jamaica|Jordan|Japan|Kenya|Kyrgyzstan|Cambodia|Kiribati|Comoros|Saint Kitts and Nevis|Korea, Democratic People's Republic of|Korea, Republic of|Kuwait|Cayman Islands|Kazakhstan|Lao People's Democratic Republic|Lebanon|Saint Lucia|Liechtenstein|Sri Lanka|Liberia|Lesotho|Lithuania|Luxembourg|Latvia|Libya|Morocco|Monaco|Moldova, Republic of|Montenegro|Saint Martin (French part)|Madagascar|Marshall Islands|Macedonia, the former Yugoslav Republic of|Mali|Myanmar|Mongolia|Macao|Northern Mariana Islands|Martinique|Mauritania|Montserrat|Malta|Mauritius|Maldives|Malawi|Mexico|Malaysia|Mozambique|Namibia|New Caledonia|Niger|Norfolk Island|Nigeria|Nicaragua|Netherlands|Norway|Nepal|Nauru|Niue|New Zealand|Oman|Panama|Peru|French Polynesia|Papua New Guinea|Philippines|Pakistan|Poland|Saint Pierre and Miquelon|Pitcairn|Puerto Rico|Palestine, State of|Portugal|Palau|Paraguay|Qatar|R�ion|Romania|Serbia|Russian Federation|Rwanda|Saudi Arabia|Solomon Islands|Seychelles|Sudan|Sweden|Singapore|Saint Helena, Ascension and Tristan da Cunha|Slovenia|Svalbard and Jan Mayen|Slovakia|Sierra Leone|San Marino|Senegal|Somalia|Suriname|South Sudan|Sao Tome and Principe|El Salvador|Sint Maarten (Dutch part)|Syrian Arab Republic|Swaziland|Turks and Caicos Islands|Chad|French Southern Territories|Togo|Thailand|Tajikistan|Tokelau|Timor-Leste|Turkmenistan|Tunisia|Tonga|Turkey|Trinidad and Tobago|Tuvalu|Taiwan, Province of China|Tanzania, United Republic of|Ukraine|Uganda|United States Minor Outlying Islands|United States|Uruguay|Uzbekistan|Holy See (Vatican City State)|Saint Vincent and the Grenadines|Venezuela, Bolivarian Republic of|Virgin Islands, British|Virgin Islands, U.S.|Viet Nam|Vanuatu|Wallis and Futuna|Samoa|Yemen|Mayotte|South Africa|Zambia|Zimbabwe"
		countryListDescArr := []
		Loop, parse, countryDescriptionList, |
			countryListDescArr[a_index] := a_loopfield
		Loop, parse, countryList, |
			%A_LoopField% := countryListDescArr[a_index]
		tosecTable[7,2,1] := extractinfo(reducedText,countryList, countryDescriptionList, countrydescription, "", true)
		If tosecTable[7,2,1]
			tosecTable[7,2,2] := countrydescription
		If !tosecTable[7,2,1]
			{
			tosecTable[7,2,1] := "US"
			tosecTable[7,2,2] := "United States"			
		} 
		If InStr(tosecTable[7,2,1],"-") 
			{
			countrylisttoparse := tosecTable[7,2,1]
			Loop, parse, countrylisttoparse, -
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				tosecTable[7,a_index+1,1] := currentField
				tosecTable[7,a_index+1,2] := %currentField%
			}
		}
	;Searching for language info
		languageList := "ab|aa|af|ak|sq|am|ar|an|hy|as|av|ae|ay|az|bm|ba|eu|be|bn|bh|bi|bs|br|bg|my|ca|ch|ce|ny|zh|cv|kw|co|cr|hr|cs|da|dv|nl|dz|en|eo|et|ee|fo|fj|fi|fr|ff|gl|ka|de|el|gn|gu|ht|ha|he|hz|hi|ho|hu|ia|id|ie|ga|ig|ik|io|is|it|iu|ja|jv|kl|kn|kr|ks|kk|km|ki|rw|ky|kv|kg|ko|ku|kj|la|lb|lg|li|ln|lo|lt|lu|lv|gv|mk|mg|ms|ml|mt|mi|mr|mh|mn|na|nv|nb|nd|ne|ng|nn|no|ii|nr|oc|oj|cu|om|or|os|pa|pi|fa|pl|ps|pt|qu|rm|rn|ro|ru|sa|sc|sd|se|sm|sg|sr|gd|sn|si|sk|sl|so|st|es|su|sw|ss|sv|ta|te|tg|th|ti|bo|tk|tl|tn|to|tr|ts|tt|tw|ty|ug|uk|ur|uz|ve|vi|vo|wa|cy|wo|fy|xh|yi|yo|za|zu"
		languageDescriptionList := "Abkhaz|Afar|Afrikaans|Akan|Albanian|Amharic|Arabic|Aragonese|Armenian|Assamese|Avaric|Avestan|Aymara|Azerbaijani|Bambara|Bashkir|Basque|Belarusian|Bengali; Bangla|Bihari|Bislama|Bosnian|Breton|Bulgarian|Burmese|Catalan;�Valencian|Chamorro|Chechen|Chichewa; Chewa; Nyanja|Chinese|Chuvash|Cornish|Corsican|Cree|Croatian|Czech|Danish|Divehi; Dhivehi; Maldivian;|Dutch|Dzongkha|English|Esperanto|Estonian|Ewe|Faroese|Fijian|Finnish|French|Fula; Fulah; Pulaar; Pular|Galician|Georgian|German|Greek, Modern|Guaran�ujarati|Haitian; Haitian Creole|Hausa|Hebrew�(modern)|Herero|Hindi|Hiri Motu|Hungarian|Interlingua|Indonesian|Interlingue|Irish|Igbo|Inupiaq|Ido|Icelandic|Italian|Inuktitut|Japanese|Javanese|Kalaallisut, Greenlandic|Kannada|Kanuri|Kashmiri|Kazakh|Khmer|Kikuyu, Gikuyu|Kinyarwanda|Kyrgyz|Komi|Kongo|Korean|Kurdish|Kwanyama, Kuanyama|Latin|Luxembourgish, Letzeburgesch|Ganda|Limburgish, Limburgan, Limburger|Lingala|Lao|Lithuanian|Luba-Katanga|Latvian|Manx|Macedonian|Malagasy|Malay|Malayalam|Maltese|Maori|Marathi (Mara?hi)|Marshallese|Mongolian|Nauru|Navajo, Navaho|Norwegian Bokm�North Ndebele|Nepali|Ndonga|Norwegian Nynorsk|Norwegian|Nuosu|South Ndebele|Occitan|Ojibwe, Ojibwa|Old Church Slavonic, Church Slavic, Church Slavonic, Old Bulgarian, Old Slavonic|Oromo|Oriya|Ossetian, Ossetic|Panjabi, Punjabi|Pali|Persian|Polish|Pashto, Pushto|Portuguese|Quechua|Romansh|Kirundi|Romanian,�Moldavian(Romanian from�Republic of Moldova)|Russian|Sanskrit (Sa?sk?ta)|Sardinian|Sindhi|Northern Sami|Samoan|Sango|Serbian|Scottish Gaelic; Gaelic|Shona|Sinhala, Sinhalese|Slovak|Slovene|Somali|Southern Sotho|Spanish; Castilian|Sundanese|Swahili|Swati|Swedish|Tamil|Telugu|Tajik|Thai|Tigrinya|Tibetan Standard, Tibetan, Central|Turkmen|Tagalog|Tswana|Tonga�(Tonga Islands)|Turkish|Tsonga|Tatar|Twi|Tahitian|Uighur, Uyghur|Ukrainian|Urdu|Uzbek|Venda|Vietnamese|Volap�k|Walloon|Welsh|Wolof|Western Frisian|Xhosa|Yiddish|Yoruba|Zhuang, Chuang|Zulu"
		countryLanguageList := "AE\ar|AL\sq|AM\hy|AR\es|AT\de|AU\en|AZ\Lt|BE\nl-fr|BG\bg|BH\ar|BN\ms|BO\es|BR\pt|BY\be|BZ\en|CA\en-fr|CB\en|CH\fr-de-it|CHS\zh|CHT\zh|CL\es|CN\zh|CO\es|CR\es|CZ\cs|DE\de|DK\da|DO\es|DZ\ar|EC\es|EE\et|EG\ar|ES\es|FI\fi-sv|FO\fo|FR\fr|GB\en|GE\ka|GR\el|GT\es|HK\zh|HN\es|HR\hr|HU\hu|ID\id|IE\en|IL\he|IN\en|IQ\ar|IR\fa|IS\is|IT\it|JM\en|JO\ar|JP\ja|KE\sw|KR\ko|KW\ar|KZ\kk|KZ\ky|LB\ar|LI\de|LT\lt|LU\fr-de|LV\lv|LY\ar|MA\ar|MC\fr|MK\mk|MN\mn|MO\zh|MV\div|MX\es|MY\ms|NI\es|NL\nl|NO\nb-nn|NZ\en|OM\ar|PA\es|PE\es|PH\en|PK\ur|PL\pl|PR\es|PT\pt|PY\es|QA\ar|RO\ro|RU\ru|SA\ar|SE\sv|SG\zh|SI\sl|SK\sk|SP\Lt|SV\es|SY\syr|TH\th|TN\ar|TR\tr|TT\en|TW\zh|UA\uk|US\en|UY\es|UZ\Lt|VE\es|VN\vi|YE\ar|ZA\en|ZW\en"
		langListDescArr := []
		Loop, parse, languageDescriptionList, |
			langListDescArr[a_index] := a_loopfield
		Loop, parse, languageList, |
			%A_LoopField% := langListDescArr[a_index]
		tosecTable[8,2,1] := extractinfo(reducedText,languageList, languageDescriptionList, languagedescription, "", true)
		If tosecTable[8,2,1]
			tosecTable[8,2,2] := languagedescription
		If !tosecTable[8,2,1]
			{
			Loop, parse, countryLanguageList, |
				{
				StringSplit, currentCountry, a_loopfield, \
				Loop  
					{
					If tosecTable[7,a_index+1,1]
						{
						If (tosecTable[7,a_index+1,1] = currentCountry1) {
							currentField := currentCountry2
							tosecTable[8,a_index+1,1] := currentField
							tosecTable[8,a_index+1,2] := %currentField%	
						}
					} Else {
						break
					}
				}
			}
		} 
		tosecTable[8,2,3] := tosecTable[8,2,1]
		If InStr(tosecTable[8,2,1],"-") 
			{
			languagelisttoparse := tosecTable[8,2,1]
			stringReplace, fullLanguageList, languagelisttoparse, -,`,,all 
			tosecTable[8,2,3] := fullLanguageList
			Loop, parse, languagelisttoparse, -
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				tosecTable[8,a_index+1,1] := currentField
				tosecTable[8,a_index+1,2] := %currentField%
			}
		}
		If !(tosecTable[8,2,1])	{
			If (tosecTable[7,2,1] = "US") {
				tosecTable[8,2,1] := "en"
				tosecTable[8,2,2] := "English"
				tosecTable[8,2,3] := "en"
			}
		} 
		;checking for multiple languages tag
		MultiLanguages := extractinfo(reducedText, "M[0-9][^)]*","", "","",true,"",true)	
		If MultiLanguages
			{
			RegExMatch(MultiLanguages, "[0-9]+",MultiLanguages) 
			tosecTable[8,2,1] := "The game is in " . MultiLanguages . " different languages"
		}
	; Copyright Status 
		CopyrightList := "CW|CW-R|FW|GW|GW-R|LW|PD"
		CopyrightDescriptionList := "Cardware|Cardware-Registered|Freeware|Giftware|Giftware-Registered|Licenceware|Public Domain"
		tosecTable[9,2,1] := extractinfo(reducedText,CopyrightList, CopyrightDescriptionList, Copyrightdescription, false)
		If tosecTable[9,2,1]
			tosecTable[9,2,2] := Copyrightdescription
	; Devstatus Status 
		DevstatusList := "alpha|beta|preview|pre-release|proto"
		DevstatusDescriptionList := "Early test build|Later, feature complete test build|Near complete build|Near complete build|Unreleased, prototype software"
		tosecTable[10,2,1] := extractinfo(reducedText,DevstatusList, DevstatusDescriptionList, Devstatusdescription, false)
		If tosecTable[10,2,1]
			tosecTable[10,2,2] := Devstatusdescription
	; MediaType
		MediaTypeList := "Disc|Disk|File|Part|Side|Tape"
		MediaTypeDescriptionList := "Optical disc based media|Magnetic disk based media|Individual files|Individual parts|Side of media|Magnetic tape based media"
		tosecTable[11,2,1] := extractinfo(reducedText,MediaTypeList, MediaTypeDescriptionList, MediaTypedescription, false, true)
		If tosecTable[11,2,1]
			tosecTable[11,2,2] := MediaTypedescription
	; Media Label
		tosecTable[12,1,1] := extractinfo(reducedText, "[^)]*")
	;Dump Info Flags
		dumpInfoList := "cr|f|h|m|p|tr|t|o|u|v|b|a|!"
		dumpInfoDescription := "Cracked|Fix|Hacked|Modified|Pirate|Translated|Trained|Over Dump (too much data dumped)|Under Dump (not enough data dumped)|Virus (infected)|Bad dump (incorrect data dumped)|Verified good dump"
		dumpInfoDescriptionArr := []
		Loop, parse, dumpInfoDescription, |
			dumpInfoDescriptionArr[a_index] := a_loopfield
		Loop, parse, dumpInfoList, |
			{
			currentDumpInfo := A_Index+12
			tempdumpinfo := extractinfo(reducedText, A_LoopField . "[^]]*",A_LoopField, "","","",true)	
			If tempdumpinfo
				{
				tosecTable[currentDumpInfo,2,1] := true
				tosecTable[currentDumpInfo,2,2] := dumpInfoDescriptionArr[a_index]
				If (currentDumpInfo=18){
					translatedInfo := tempdumpinfo
					StringReplace,tempdumpinfo,tempdumpinfo,%A_LoopField%
					tempdumpinfo:=RegExReplace(tempdumpinfo,"^\s*","") ; remove leading
					tempdumpinfo:=RegExReplace(tempdumpinfo,"\s*$","") ; remove trailing
					tosecTable[currentDumpInfo,2,1] := tempdumpinfo
					tosecTable[currentDumpInfo,2,3] := tosecTable[currentDumpInfo,2,1]
					TranslatedDumpInfo := tosecTable[currentDumpInfo,2,2] . " from " . tosecTable[8,2,2] . " to "
					tosecTable[8,2,3] := tempdumpinfo
					If InStr(tempdumpinfo,"-") 
						{
						languagelisttoparse := tempdumpinfo
						stringReplace, fullLanguageList, languagelisttoparse, -,`,,all 
						tosecTable[8,2,3] := fullLanguageList
						Loop, parse, languagelisttoparse, -
							{
							currentField := A_LoopField
							currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
							currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
							tosecTable[8,a_index+1,1] := currentField
							tosecTable[8,a_index+1,2] := %currentField%
							TranslatedDumpInfo := TranslatedDumpInfo . tosecTable[8,a_index+1,2] . "`, "
						}
						stringtrimRight, TranslatedDumpInfo, TranslatedDumpInfo, 1
						tosecTable[currentDumpInfo,2,2] := TranslatedDumpInfo
					} Else {
						tosecTable[8,2,1] := tempdumpinfo
						tosecTable[8,2,2] := %tempdumpinfo%
						tosecTable[currentDumpInfo,2,2] := TranslatedDumpInfo . tosecTable[8,2,2]	
					}
				}
			If !(currentDumpInfo=18)
				If tosecTable[currentDumpInfo,2,1]
					ExitDumpInfo := true
			}
		}
		If !ExitDumpInfo
			{
			tosecTable[24,2,1] := "!"
			tosecTable[24,2,2] := "Verified good dump"
		}
	;More info
		tosecTable[25,2,1] := extractinfo(reducedText, "[^]]*",A_LoopField, "","","",true)	
	;Non Identified
	reducedText:=RegExReplace(reducedText,"^\s*","") ; remove leading
	reducedText:=RegExReplace(reducedText,"\s*$","") ; remove trailing
	If reducedText
		tosecTable[26,2,1] := reducedText
	;Log("createTosecTable - Ended",5)
	Return tosecTable	
}
	
createNoIntroTable(GameName,nameOnly:=false){
	;Log("createNoIntroTable - Started",5)
	NoIntroTable := []
	NoIntroTable[1,1,1] := "Name"
	NoIntroTable[2,1,1] := "Language Info"
	NoIntroTable[3,1,1] := "Region Info"
	NoIntroTable[4,1,1] := "Development Status"
	NoIntroTable[5,1,1] := "Version"
	NoIntroTable[6,1,1] := "Bios"	
	NoIntroTable[7,1,1] := "Game Info"
	NoIntroTable[8,1,1] := "Dump Info"
	NoIntroTable[9,1,1] := "Additional Info"
	reducedText := GameName
	if (nameOnly){
		RegExMatch(reducedText, "[^(]*",name)
		RegExMatch(name, "[^[]*",name)
		gameName:=RegExReplace(name,"^\s*","") ; remove leading
		gameName:=RegExReplace(name,"\s*$","") ; remove trailing
		NoIntroTable[1,2,1] := name
		Return NoIntroTable	
	}
	;Bad or Hacked dump
	badDump := extractinfo(reducedText, "b","", "","","",true)	
	If badDump
		{
		NoIntroTable[8,2,1] := true
		NoIntroTable[8,2,2] := "Bad or Hacked Dump Game"
	}
	; unlicensed game
	unlGame := extractinfo(reducedText, "unl","", "","","","",true)	
	If unlGame
		{
		NoIntroTable[7,2,1] := true
		NoIntroTable[7,2,2] := "Unlicensed Game"
	}
	;BIOS
	biosDump := extractinfo(reducedText, "BIOS","", "","","",true,true)	
	If biosDump
		{
		NoIntroTable[6,2,1] := true
		NoIntroTable[6,2,2] := "Bios Dumped"
	}
	;Version
	NoIntroTable[5,2,1] := extractinfo(reducedText, "v[0-9][^)]*","", "","",true,"",true)	 
	NoIntroTable[5,2,1] := extractinfo(reducedText, "Rev[^)]*","", "","",true,"",true)	 
	; Development and/or Commercial Status
	DevstatusList := "Beta|Proto|Sample"
	DevstatusDescriptionList := "Feature complete test build|Unreleased, prototype software|Sample" 
	NoIntroTable[4,2,1] := extractinfo(reducedText,DevstatusList, DevstatusDescriptionList, Devstatusdescription, "",true,"",true)
	If NoIntroTable[4,2,1]
		NoIntroTable[4,2,2] := Devstatusdescription
	;Searching for Region info 
		regionList := "World|Europe|Asia|USA|United Arab Emirates|Albania|Asia|Austria|Australia|Bosnia and Herzegovina|Belgium|Bulgaria|Brazil|Canada|Switzerland|Chile|China|Serbia and Montenegro|Cyprus|Czech Republic|Germany|Denmark|Estonia|Egypt|Spain|Europe|Finland|France|United Kingdom|Greece|Hong Kong|Croatia|Hungary|Indonesia|Ireland|Israel|India|Iran|Iceland|Italy|Jordan|Japan|South Korea|Lithuania|Luxembourg|Latvia|Mongolia|Mexico|Malaysia|Netherlands|Norway|Nepal|New Zealand|Oman|Peru|Philippines|Poland|Portugal|Qatar|Romania|Russia|Sweden|Singapore|Slovenia|Slovakia|Thailand|Turkey|Taiwan|United States|Vietnam|Yugoslavia|South Africa"
		NoIntroTable[3,2,1] := extractinfo(reducedText,regionList, "", "", "", true,"",true)
		If InStr(NoIntroTable[3,2,1],"`,") 
			{
			regionlisttoparse := NoIntroTable[3,2,1]
			Loop, parse, regionlisttoparse, `,
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				NoIntroTable[3,a_index+1,1] := currentField
			}
		}
	;Searching for language info
		languageList := "ab|aa|af|ak|sq|am|ar|an|hy|as|av|ae|ay|az|bm|ba|eu|be|bn|bh|bi|bs|br|bg|my|ca|ch|ce|ny|zh|cv|kw|co|cr|hr|cs|da|dv|nl|dz|en|eo|et|ee|fo|fj|fi|fr|ff|gl|ka|de|el|gn|gu|ht|ha|he|hz|hi|ho|hu|ia|id|ie|ga|ig|ik|io|is|it|iu|ja|jv|kl|kn|kr|ks|kk|km|ki|rw|ky|kv|kg|ko|ku|kj|la|lb|lg|li|ln|lo|lt|lu|lv|gv|mk|mg|ms|ml|mt|mi|mr|mh|mn|na|nv|nb|nd|ne|ng|nn|no|ii|nr|oc|oj|cu|om|or|os|pa|pi|fa|pl|ps|pt|qu|rm|rn|ro|ru|sa|sc|sd|se|sm|sg|sr|gd|sn|si|sk|sl|so|st|es|su|sw|ss|sv|ta|te|tg|th|ti|bo|tk|tl|tn|to|tr|ts|tt|tw|ty|ug|uk|ur|uz|ve|vi|vo|wa|cy|wo|fy|xh|yi|yo|za|zu"
		languageDescriptionList := "Abkhaz|Afar|Afrikaans|Akan|Albanian|Amharic|Arabic|Aragonese|Armenian|Assamese|Avaric|Avestan|Aymara|Azerbaijani|Bambara|Bashkir|Basque|Belarusian|Bengali; Bangla|Bihari|Bislama|Bosnian|Breton|Bulgarian|Burmese|Catalan;�Valencian|Chamorro|Chechen|Chichewa; Chewa; Nyanja|Chinese|Chuvash|Cornish|Corsican|Cree|Croatian|Czech|Danish|Divehi; Dhivehi; Maldivian;|Dutch|Dzongkha|English|Esperanto|Estonian|Ewe|Faroese|Fijian|Finnish|French|Fula; Fulah; Pulaar; Pular|Galician|Georgian|German|Greek, Modern|Guaran�ujarati|Haitian; Haitian Creole|Hausa|Hebrew�(modern)|Herero|Hindi|Hiri Motu|Hungarian|Interlingua|Indonesian|Interlingue|Irish|Igbo|Inupiaq|Ido|Icelandic|Italian|Inuktitut|Japanese|Javanese|Kalaallisut, Greenlandic|Kannada|Kanuri|Kashmiri|Kazakh|Khmer|Kikuyu, Gikuyu|Kinyarwanda|Kyrgyz|Komi|Kongo|Korean|Kurdish|Kwanyama, Kuanyama|Latin|Luxembourgish, Letzeburgesch|Ganda|Limburgish, Limburgan, Limburger|Lingala|Lao|Lithuanian|Luba-Katanga|Latvian|Manx|Macedonian|Malagasy|Malay|Malayalam|Maltese|Maori|Marathi (Mara?hi)|Marshallese|Mongolian|Nauru|Navajo, Navaho|Norwegian Bokm�North Ndebele|Nepali|Ndonga|Norwegian Nynorsk|Norwegian|Nuosu|South Ndebele|Occitan|Ojibwe, Ojibwa|Old Church Slavonic, Church Slavic, Church Slavonic, Old Bulgarian, Old Slavonic|Oromo|Oriya|Ossetian, Ossetic|Panjabi, Punjabi|Pali|Persian|Polish|Pashto, Pushto|Portuguese|Quechua|Romansh|Kirundi|Romanian,�Moldavian(Romanian from�Republic of Moldova)|Russian|Sanskrit (Sa?sk?ta)|Sardinian|Sindhi|Northern Sami|Samoan|Sango|Serbian|Scottish Gaelic; Gaelic|Shona|Sinhala, Sinhalese|Slovak|Slovene|Somali|Southern Sotho|Spanish; Castilian|Sundanese|Swahili|Swati|Swedish|Tamil|Telugu|Tajik|Thai|Tigrinya|Tibetan Standard, Tibetan, Central|Turkmen|Tagalog|Tswana|Tonga�(Tonga Islands)|Turkish|Tsonga|Tatar|Twi|Tahitian|Uighur, Uyghur|Ukrainian|Urdu|Uzbek|Venda|Vietnamese|Volap�k|Walloon|Welsh|Wolof|Western Frisian|Xhosa|Yiddish|Yoruba|Zhuang, Chuang|Zulu"
		langListDescArr := []
		Loop, parse, languageDescriptionList, |
			langListDescArr[a_index] := a_loopfield
		Loop, parse, languageList, |
			%A_LoopField% := langListDescArr[a_index]
		NoIntroTable[2,2,1] := extractinfo(reducedText,languageList, languageDescriptionList, languagedescription, "", true)
		If NoIntroTable[2,2,1]
			NoIntroTable[2,2,2] := languagedescription
		NoIntroTable[2,2,3] := NoIntroTable[2,2,1]
		If InStr(NoIntroTable[2,2,1],"`,") 
			{
			languagelisttoparse := NoIntroTable[2,2,1]
			Loop, parse, languagelisttoparse, `,
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				NoIntroTable[2,a_index+1,1] := currentField
				NoIntroTable[2,a_index+1,2] := %currentField%
			}
		}
	; game name
	RegExMatch(reducedText, "[^(]*",name)
	RegExMatch(name, "[^[]*",name)
	StringReplace,reducedText,reducedText,%name%
	gameName:=RegExReplace(name,"^\s*","") ; remove leading
	gameName:=RegExReplace(name,"\s*$","") ; remove trailing
	NoIntroTable[1,2,1] := name
	;additional Info
	reducedText:=RegExReplace(reducedText,"^\s*","") ; remove leading
	reducedText:=RegExReplace(reducedText,"\s*$","") ; remove trailing
	If reducedText
		NoIntroTable[9,2,1] := reducedText
	;Log("createNoIntroTable - Ended",5)
	Return NoIntroTable
}	


createFrontEndTable(GameName){
	Global systemName, frontendDatabaseFields, frontendDatabaseLabels
	romMapGameInfoTable := []
	if (IsFunc("BuildDatabaseTable")) and (frontendDatabaseFields) and (frontendDatabaseLabels) {
		romMapGameInfo := Object()
		romMapGameInfo := BuildDatabaseTable%zz%(GameName,systemName,frontendDatabaseFields,frontendDatabaseLabels)
		for index, element in romMapGameInfo
		{	if ( element.Label = "Name") {
				romMapGameInfoTable[1,1,1] := element.Label
				romMapGameInfoTable[1,2,1] := element.Value
			} else {
				romMapGameInfoTable[a_index+1,1,1] := element.Label
				romMapGameInfoTable[a_index+1,2,1] := element.Value
			}
		}
	} else {
		log("CreateRomMappingLaunchMenu - the BuildDatabaseTable function or required labels (frontendDatabaseFields and frontendDatabaseLabels) were not found on the plugin file. If you want to take advantage of the game frontend info and more descriptive names on the rom mapping menu you should create a propper BuildDatabaseTable function and the variables frontendDatabaseFields and frontendDatabaseLabels.",2)
		romMapGameInfoTable[1,1,1] := "Name"
		romMapGameInfoTable[1,2,1] := GameName
	}
	Return romMapGameInfoTable
}

extractinfo(ByRef searchtext, List, DescriptionList := "", ByRef description:="", RegExCharCorrect:=false, matchOnlyInBeggining:=false, dumpInfo:=false, caseinsentitive:=false){
	;Log("extractinfo - Started",5)
	;extra conditions to speed up search
	If !searchtext
		{
		;Log("extractinfo - Ended`, no searchtext provided",5)		
		Return
	}
	;removing invalid regex characters from list
	;Log("extractinfo - Searching for """ . searchtext . """",5)
	If RegExCharCorrect
		{
		StringReplace, List, List, \, \\, All
		replace :=   {"&":"&amp;","'":"&apos;",".":"\.","*":"\*","?":"\?","+":"\+","[":"\[","{":"\{","|":"\|","(":"\(",")":"\)","^":"\^","$":"\$"}
		For what, with in replace
		StringReplace, List, List, %what%, %with%, All
	}
	;preparing list 2 If available
	If DescriptionList
		{
		List2 := []
		Loop, parse, DescriptionList, |
			List2[a_index] := A_LoopField
	}
	;acquiring text info
	Loop, parse, List, |
		{
		If RegExCharCorrect	
			StringTrimRight,currentField,A_LoopField, 1
		Else
			currentField := A_LoopField
		If dumpInfo
			searchREgEX := % "\[\s*" . currentField . "[^]]*" 
		Else If matchOnlyInBeggining
			searchREgEX := % "\(\s*" . currentField . "[^)]*" 
		Else
			searchREgEX := % "\(\s*" . currentField . "\s*\)"
		If caseinsentitive
			searchREgEX := % "i)" . searchREgEX
		Pos := RegExMatch(searchtext, searchREgEX , FullText)
		If Pos
			{
			If matchOnlyInBeggining
				FullText := FullText . ")"
			If dumpInfo
				FullText := FullText . "]"
			StringTrimLeft, Text, FullText, 1
			StringTrimRight, Text, Text, 1
			Text:=RegExReplace(Text,"^\s*","") ; remove leading
			Text:=RegExReplace(Text,"\s*$","") ; remove trailing
			foundText := Text
			StringReplace,searchtext,searchtext,%FullText%
			If DescriptionList
				description := List2[a_index]
			break
		}
	}
	;Log("extractinfo - Ended",5)
	Return foundText
}

addHistoryDatInfo(GameName,showInfo,Array){	
	Global systemName, RLDataPath
	currentIndex := % array.MaxIndex()
	; Loading history.dat info	
	IniRead, historyDatSystemName, % RLDataPath . "\History\System Names.ini", Settings, %systemName%, %A_Space%
    IniRead, romNameToSearch, % RLDataPath . "\History\" . systemName . ".ini", %GameName%, Alternate_Rom_Name, %A_Space%
	if !romNameToSearch
        romNameToSearch := GameName
    FileRead, historyContents, % RLDataPath . "\History\History.dat"
	FoundPos := RegExMatch(historyContents, "i)" . "\$\s*" . historyDatSystemName . "\s*=\s*.*\b" . romNameToSearch . "\b\s*,")
	If FoundPos
        {
        FoundPos2 := RegExMatch(historyContents, "i)\$end",EndString,FoundPos)
	    StringMid, HistoryDataText, historyContents, % FoundPos, % FoundPos2-FoundPos
        historySectionNumber := currentIndex
        Loop, parse, HistoryDataText, `n`r,`n`r  
            {
			line:=RegExReplace(A_LoopField,"^\s+|\s+$")  ; remove leading and trailing
			if historyDatSectionName%historySectionNumber% := RomMappinghistoryDatSection(line)
				{
				currentHistorySectionNumber := historySectionNumber		
				historySectionNumber++
			} else if (historySectionNumber>currentIndex) {
				HistoryFileTxtContents%currentHistorySectionNumber% := % HistoryFileTxtContents%currentHistorySectionNumber% . line
			}
		}
		loop, % historySectionNumber
			{
			if historyDatSectionName%a_index%
				if InStr(showInfo, "HistoryDat" . historyDatSectionName%a_index%)
					if !(historyDatSectionName%a_index%=0)
						if HistoryFileTxtContents%a_index%
							{
							Array[a_index,1,1] := historyDatSectionName%a_index%
							Array[a_index,2,1] := HistoryFileTxtContents%a_index%
						}
		}
	}
	return Array
}

RomMappinghistoryDatSection(line){
	line:=RegExReplace(line,"^\s+|\s+$")  ; remove leading and trailing
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


addHighScoreInfo(GameName, showInfo, Array){
	Global pauseHiToTextPath, emuPath
	currentIndex := % array.MaxIndex()
	; Adding High Score info
	if InStr(showInfo, "HighScores") {
		SplitPath, pauseHiToTextPath, , pauseHitoTextDir
		HighScoreText := StdoutToVar_CreateProcess("""" . pauseHiToTextPath . """" . " -ra " . """" . emuPath . "\hi\" . GameName . ".hi" . """","",pauseHitoTextDir) ;Loading HighScore information
		If InStr(HighScoreText, "RANK"){ ; if High score info is found compare with the exit game high score values
			Array[currentIndex+1,1,1] := "High Scores"
			Array[currentIndex+1,2,1] := "`n`r" . HighScoreText
		}
	}
	Return Array
}

gameinfotext(currentGameInfo){
	Global romMappingGameInfoTextFont, romMappingMenuMargin, romMappingMenuWidth 
	loop, % currentGameInfo.MaxIndex()
		{
		currentItem := a_index
		If RegExReplace(currentGameInfo[currentItem,2,1],"^\s+|\s+$")
			{
			GameInfocontent :=
			Loop,
				{
				If !currentGameInfo[currentItem,a_index+1,1]
				{
					break
				} Else { 
					If currentGameInfo[currentItem,a_index+1,2]
						GameInfocontent := % GameInfocontent . currentGameInfo[currentItem,a_index+1,2] . ", "
					Else
						GameInfocontent := % GameInfocontent . currentGameInfo[currentItem,a_index+1,1] . ", " 
				}
			}
			StringTrimRight,GameInfocontent,GameInfocontent,2
			GameInfoLine := % currentGameInfo[currentItem,1,1] . " = " . GameInfocontent
			GameInfoFinalcontent := % GameInfoFinalcontent . GameInfoLine . "`r`n"
		}
	}
	GameInfoFinalcontent := RegExReplace(GameInfoFinalcontent, "\R+\R", "`r`n")
	Return GameInfoFinalcontent
}
