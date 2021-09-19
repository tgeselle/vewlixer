MCRC := "CEEB60A2"
MVersion := "1.5.1"

StartModule(){
	Global gameSectionStartTime,gameSectionStartHour,skipChecks,dbName,romPath,romPathOrig,romName,romExtension,romFoundByExt,systemName,MEmu,MEmuV,MURL,MAuthor,MVersion,MCRC,MID,iCRC,MSystem,romMapTable,romMappingLaunchMenuEnabled,romMenuRomName,sevenZEnabled,hideCursor,cursorSize,toggleCursorKey,servoStikEnabled,ledblinkyEnabled,winVer,setResolution,frontendPath,frontendExe,FrontEndProcess,modulePath,moduleName,dialogOpen,dialogStart,zz
	Global mgEnabled,mgOnLaunch,mgCandidate,mgLaunchMenuActive,MultiGame_Running,keyboardEncoder,keyboardEncoderEnabled,ultraMapFullPath,winIPACFullPath
	Global rIniIndex,globalPluginsFile,sysPluginsFile,moduleIni
	RLLog.Info(A_ThisFunc . " - Started")
	
	MSystemStr := StringUtils.ObjToStr(MSystem)
	MURLStr := StringUtils.ObjToStr(MURL)
	MAuthorStr := StringUtils.ObjToStr(MAuthor)
	RLLog.Info(A_ThisFunc . " - MEmu: " . MEmu . "`r`n`t`t`t`t`tMEmuV: " . MEmuV . "`r`n`t`t`t`t`tMURL: " . MURLStr . "`r`n`t`t`t`t`tMAuthor: " . MAuthorStr . "`r`n`t`t`t`t`tMVersion: " . MVersion . "`r`n`t`t`t`t`tMCRC: " . MCRC . "`r`n`t`t`t`t`tiCRC: " . iCRC . "`r`n`t`t`t`t`tMID: " . MID . "`r`n`t`t`t`t`tMSystem: " . MSystemStr)

	If InStr(MSystemStr,systemName)
		RLLog.Info(A_ThisFunc . " - You have a supported System Name for this module: """ . systemName . """")
	Else
		RLLog.Warning(A_ThisFunc . " - You have an unsupported System Name for this module: """ . systemName . """. Only the following System Names are suppported: """ . MSystem . """")

	winVer := If A_Is64bitOS ? "64" : "32"	; get windows version

	dialogOpen := LocaleUtils.i18n("dialog.open")	; Looking up local translations
	dialogStart := LocaleUtils.i18n("dialog.start")

	;-----------------------------------------------------------------------------------------------------------------------------------------
	 ; Plugin Specific Settings from Settings \ Global Plugins.ini and Settings \ %systemName% \ Plugins.ini
	;-----------------------------------------------------------------------------------------------------------------------------------------
	rIniIndex := {}	; initialize the RIni array
	globalPluginsFile := A_ScriptDir . "\Settings\Global Plugins.ini"
	If !FileExist(globalPluginsFile)
		FileAppend,, %globalPluginsFile%	; create blank ini
	RIni_Read("GlobalPluginsIni",globalPluginsFile)
	rIniIndex["GlobalPluginsIni"] := globalPluginsFile	; assign to array

	sysPluginsFile := A_ScriptDir . "\Settings\" . systemName . "\Plugins.ini"
	If !FileExist(sysPluginsFile)
		FileAppend,, %sysPluginsFile%	; create blank ini
	RIni_Read("SystemPluginsIni",sysPluginsFile)
	rIniIndex["SystemPluginsIni"] := sysPluginsFile	; assign to array

	Gosub, PluginInit	; initialize plugin vars
	; Gosub, ReadFEGameInfo	; read plugin data
	;-----------------------------------------------------------------------------------------------------------------------------------------

	If (mgEnabled = "true" && mgOnLaunch = "true" && mgCandidate) {	; only if user has mgOnLaunch enabled
		mgLaunchMenuActive := true
		RLLog.Debug(A_ThisFunc . " - MultiGame_On_Launch execution started.")
		Gosub, StartMulti
		Sleep, 200
		Loop {
			If !MultiGame_Running
				Break
		}
		mgLaunchMenuActive := false
		RLLog.Debug(A_ThisFunc . " - MultiGame_On_Launch execution ended.")
	}
	If (romMappingLaunchMenuEnabled = "true" && romMapTable.MaxIndex()) { ; && romMapMultiRomsFound)
		CreateRomMappingLaunchMenu%zz%(romMapTable)
	}
	; msgbox dbName: %dbName%`nromName: %romName%`nromMenuRomName: %romMenuRomName%`nsevenZEnabled: %sevenZEnabled%`nskipChecks: %skipChecks%
	If (skipChecks != "false" && romMenuRomName && sevenZEnabled = "false")	; this is to support the scenario where Rom Map Launch Menu can send a rom that does not exist on disk or in the archive (mame clones)
	{	RLLog.Debug(A_ThisFunc . " - Setting romName to the game picked from the Launch Menu: " . romMenuRomName)
		romName := romMenuRomName
	} Else If romName && romMapTable.MaxIndex()
	{	RLLog.Debug(A_ThisFunc . " - Leaving romName as is because Rom Mapping filled it with an Alternate_Rom_Name: " . romName)
		romName := romName	; When Rom Mapping is used but no Alternate_Archive_Name key exists yet Alternate_Rom_Name key(s) were used.
	} Else If romMapTable.MaxIndex()
	{	RLLog.Debug(A_ThisFunc . " - Not setting romName because Launch Menu was used and 7z will take care of it.")
		romName := "" 	; If a romMapTable exists with roms, do not fill romName yet as 7z will take care of that.
	} Else If (romFoundByExt = "true")
	{	RLLog.Debug(A_ThisFunc . " - Not setting romName because Rom was found by matching its extension.")
	} Else
	{	RLLog.Debug(A_ThisFunc . " - Setting romName to the dbName sent to RocketLauncher: " . dbName)
		romName := dbName	; Use dbName if previous checks are false
	}

	romPathOrig := romPath	; storing original rom path for any modules or features that need this before 7z updates it.

	If (setResolution != "")
		SetDisplaySettings(setResolution)

	If RegExMatch(hideCursor,"i)true|do_not_restore")
		SystemCursor("Off")
	Else If RegExMatch(hideCursor,"i)custom|custom_do_not_restore") {
		cursor := GetRLMediaFiles("Cursors","cur|ani") ;load cursor file for the system if they exist
		If cursor
			SetSystemCursor(Cursor,cursorSize,cursorSize) ; replace system cursors
	}
	If toggleCursorKey
		XHotKeywrapper(toggleCursorKey,"ToggleCursor")
	If (ledblinkyEnabled = "All")
		LEDBlinky("START")
	KeymapperProfileSelect("START", keyboardEncoder, %keyboardEncoder%FullPath, "ipc", "keyboard")
	KeymapperProfileSelect("START", "UltraMap", ultraMapFullPath, "ugc")
	If (servoStikEnabled = 4 || servoStikEnabled = 8)
		ServoStik(servoStikEnabled)	; handle servostiks on start

	FrontEndProcess := new Process(frontendPath . "\" . frontendExe)

	GlobalModuleIni := modulePath . "\" . moduleName . ".ini"
	SystemModuleIni := modulePath . "\" . systemName . ".ini"
	RomModuleIni := modulePath . "\" . systemName . "\" . dbName . ".ini"
	moduleIni := new RIniFile("Module","RomModuleIni>" . RomModuleIni . "|SystemModuleIni>" . SystemModuleIni . "|GlobalModuleIni>" . GlobalModuleIni)		; create module ini object, order = priority

	; romName := If romName ? romName : If romMapTable.MaxIndex() ? "" : dbName	; OLD METHOD, keeping this here until the split apart conditionals have been tested enough. ; if romName was filled at some point, use it, Else If a romMapTable exists with roms, do not fill romName yet as 7z will take care of that. Use dbName if previous checks are false
	Gui, show,Hide,RocketLauncherMessageReceiver ; creating hidden GUI to receive RocketLauncher messages 
	OnMessage(0x4a, "ReceiveMessage")
	BroadcastMessage("RocketLauncher Message: Welcome! :)")
	gameSectionStartTime := A_TickCount
	gameSectionStartHour := A_Now
	; msgbox % "romPath: " . romPath . "`nromName: " . romName . "`nromExtension: " . romExtension . "`nromMenuRomName: " . romMenuRomName . "`nromMapTable.MaxIndex(): " . romMapTable.MaxIndex()
	RLLog.Info(A_ThisFunc . " - Ended")
}

; ExitModule function in case we need to call anything on the module's exit routine, like UpdateStatistics for Pause or UnloadKeymapper
ExitModule(){
	Global statisticsEnabled,keymapperEnabled,keymapper,keymapperAHKMethod,keymapperLoaded,logShowCommandWindow,pToken,cmdWindowObj,mouseCursorHidden,cursor,hideCursor,rocketLauncherIsExiting,servoStikExitMode,ledblinkyEnabled,zz
	Global JoyIDsEnabled,JoyIDsPreferredControllersOnExit,keyboardEncoder,keyboardEncoderEnabled,ultraMapFullPath,winIPACFullPath
	Global suspendFE,FrontEndProcess,hideFE
	RLLog.Info(A_ThisFunc . " - Started")
	rocketLauncherIsExiting := 1	; notifies rest of the thread that the exit routine was triggered
	If (statisticsEnabled = "true")
		Gosub, UpdateStatistics
	If (keymapperEnabled = "true" && keymapperLoaded)
		RunKeyMapper%zz%("unload",keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("unload")
	If (JoyIDsEnabled = "true" && JoyIDsPreferredControllersOnExit)
		LoadPreferredControllers%zz%(JoyIDsPreferredControllersOnExit)
	If (hideCursor = "custom" and cursor)
		RestoreCursors()	; retore default system cursors
	If mouseCursorHidden	; just in case
		SystemCursor("On")
	If (ledblinkyEnabled = "All")
		LEDBlinky("END")
	CustomFunction.PostExit()
	KeymapperProfileSelect("END", keyboardEncoder, %keyboardEncoder%FullPath, "ipc", "keyboard")
	KeymapperProfileSelect("END", "UltraMap", ultraMapFullPath, "ugc")
	If (servoStikExitMode = 4 || servoStikExitMode = 8)
		ServoStik(servoStikExitMode)	; handle servostiks on exit
	If (logShowCommandWindow = "true")
		Loop {
			If !cmdWindowObj[A_Index,"Name"]
				Break
			Else {
				RLLog.Debug(A_ThisFunc . " - Closing command window: " . cmdWindowObj[A_Index,"Name"] . " PID: " . cmdWindowObj[A_Index,"PID"])
				cmdWindow.Process("Close", cmdWindowObj[A_Index,"Name"])	; close each opened cmd.exe
			}
		}
	If (suspendFE = "true" && FrontEndProcess.Suspended)
		FrontEndProcess.ProcessResume()
	If (hideFE = "true") {
		If !FrontEndProcess.PID
			FrontEndProcess.GetProcessID()
		FadeApp("ahk_pid " . FrontEndProcess.PID,"in")
	}
	BroadcastMessage("RocketLauncher Message: Goodbye! :(")
	Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the thread
	RLLog.Info(A_ThisFunc . " - Ended")
	RLLog.Close("End of Module Logs")
	ExitApp
}

WinWait(winTitle,winText:="",secondsToWait:=30,excludeTitle:="",excludeText:=""){
	Global detectFadeErrorEnabled,logLevel
	If logLevel > 3
		GetActiveWindowStatus()
	RLLog.Info(A_ThisFunc . " - Waiting for """ . winTitle . """")
	WinWait, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	curErr := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
	If logLevel > 3
		GetActiveWindowStatus()
	If (curErr and detectFadeErrorEnabled = "true")
		ScriptError("There was an error waiting for the window """ . winTitle . """. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
	Else If (curErr and detectFadeErrorEnabled != "true")
		RLLog.Error("There was an error waiting for the window """ . winTitle . """. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.")
	Return curErr
}

WinWaitActive(winTitle,winText:="",secondsToWait:=30,excludeTitle:="",excludeText:=""){
	Global detectFadeErrorEnabled,logLevel,emulatorProcessID,emulatorVolumeObject,emulatorInitialMuteState,fadeMuteEmulator,fadeIn
	If (logLevel > 3)
		GetActiveWindowStatus()
	RLLog.Info(A_ThisFunc . " - Waiting for """ . winTitle . """")
	WinWaitActive, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	curErr := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
	If (logLevel > 3)
		GetActiveWindowStatus()
	If (curErr and detectFadeErrorEnabled = "true")
		ScriptError("There was an error waiting for the window """ . winTitle . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
	Else If (curErr and detectFadeErrorEnabled != "true")
		RLLog.Error(A_ThisFunc . " - There was an error waiting for the window """ . winTitle . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.")
	If !curErr
		{
		WinGet emulatorProcessID, PID, %winTitle%
		emulatorVolumeObject := GetVolumeObject(emulatorProcessID)
		If ((fadeMuteEmulator = "true") and (fadeIn = "true")){
			getMute(emulatorInitialMuteState, emulatorVolumeObject)
			setMute(1, emulatorVolumeObject)
		}
	}
	Return curErr
}

WinWaitClose(winTitle,winText:="",secondsToWait:="",excludeTitle:="",excludeText:=""){
	RLLog.Info(A_ThisFunc . " - Waiting for """ . winTitle . """ to close")
	WinWaitClose, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	Return ErrorLevel
}

WinClose(winTitle,winText:="",secondsToWait:="",excludeTitle:="",excludeText:=""){
	RLLog.Info(A_ThisFunc . " - Closing: " . winTitle)
	WinClose, %winTitle%, %winText% , %secondsToWait%, %excludeTitle%, %excludeText%
	If (secondsToWait = "" || !secondsToWait)
		secondsToWait := 2	; need to always have some timeout for this command otherwise it will wait forever
	WinWaitClose, %winTitle%, %winText% , %secondsToWait%, %excludeTitle%, %excludeText%	; only WinWaitClose reports an ErrorLevel
	Return ErrorLevel
}

WinActivate(WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="")
{
	RLLog.Info(A_ThisFunc . " - Activating " . WinTitle . " " . WinText . " " . ExcludeTitle . " " . ExcludeText)
	WinActivate,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	Return ErrorLevel
}

WinGet(cmd,WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="",log:=1)
{
	WinGet,OutputVar,%cmd%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	If log
		RLLog.Trace(A_ThisFunc . " - Retrieved """ . OutputVar . """ from " . WinTitle . A_Space . WinText)
	Return OutputVar
}

WinGetTitle(WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="",log:=1)
{
	WinGetTitle,OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	If log
		RLLog.Trace(A_ThisFunc . " - Retrieved """ . OutputVar . """ from " . WinTitle . A_Space . WinText)
	Return OutputVar
}

WinGetPos(ByRef x,ByRef y,ByRef w,ByRef h,WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="",log:=1)
{
	WinGetPos,x,y,w,h,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	If log
		RLLog.Trace(A_ThisFunc . " - Retrieved x:" . x . " y:" . y . " w: " . w . " h: " . h . " from " . WinTitle . A_Space . WinText)
	Return
}

WinHide(WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="")
{
	RLLog.Trace(A_ThisFunc . " - Hiding window " . WinTitle . A_Space . WinText)
	WinHide,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	Return ErrorLevel
}

WinMenuSelectItem(WinTitle,WinText:="",Menu:="",SubMenu1:="",SubMenu2:="",SubMenu3:="",SubMenu4:="",SubMenu5:="",SubMenu6:="",ExcludeTitle:="",ExcludeText:="")
{
	If (!Menu || !SubMenu1)
		ScriptError("Menu and SubMenu are required for WinMenuSelectItem")
	RLLog.Debug(A_ThisFunc . " - Selecting " . Menu . " -> " . SubMenu1 . (SubMenu2 ? " -> " . SubMenu2 : "") . (SubMenu3 ? " -> " . SubMenu3 : "") . (SubMenu4 ? " -> " . SubMenu4 : "") . (SubMenu5 ? " -> " . SubMenu5 : "") . (SubMenu6 ? " -> " . SubMenu6 : ""))
	WinMenuSelectItem,%WinTitle%,%WinText%,%Menu%,%SubMenu1%,%SubMenu2%,%SubMenu3%,%SubMenu4%,%SubMenu5%,%SubMenu6%,%ExcludeTitle%,%ExcludeText%
	Return ErrorLevel
}

WinMove(x,y,w:="",h:="",WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:="",log:=1)
{
	If WinTitle
		WinMove,%WinTitle%,%WinText%,%x%,%y%,%w%,%h%,%ExcludeTitle%,%ExcludeText%
	Else
		WinMove,%x%,%y%
	If log
		RLLog.Trace(A_ThisFunc . " - Moved " . WinTitle . A_Space . WinText . " to  x:" . x . " y:" . y . " w: " . w . " h: " . h)
	Return
}

WinRestore(WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="")
{
	RLLog.Trace(A_ThisFunc . " - Restoring window " . WinTitle . A_Space . WinText)
	WinRestore,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	Return ErrorLevel
}

WinSet(Attribute,Value,WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="")
{
	RLLog.Trace(A_ThisFunc . " - Setting " . Attribute . " to " . Value . " on window " . WinTitle . A_Space . WinText)
	WinSet,%Attribute%,%Value%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	Return ErrorLevel
}

WinShow(WinTitle,WinText:="",ExcludeTitle:="",ExcludeText:="")
{
	RLLog.Trace(A_ThisFunc . " - Unhiding window " . WinTitle . A_Space . WinText)
	WinShow,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	Return ErrorLevel
}

RunWait(target,workingDir:="",options:=0,ByRef outputVarPID:=""){
	Global errorLevelReporting
	options := If options = 1 ? "useErrorLevel" : options	; enable or disable error level
	RLLog.Info(A_ThisFunc . " - Started - running: " . workingDir . "\" . target)
	RunWait, %target%, %workingDir%, %options%, outputVarPID
	curErr := ErrorLevel	; store error level immediately
	RLLog.Debug(A_ThisFunc . " - """ . target . """ Process ID: " . outputVarPID . " and ErrorLevel reported as: " . curErr)
	Return curErr
}

; To disable inputBlocker on a specific Run call, set inputBlocker to 0, or to force it a specified amount of seconds (upto 30), set it to that amount.
; By default, options will enable all calls of Run() to return errorlevel within the function. However, it will only be returned if errorLevelReporting is true
; bypassCmdWindow - some apps will never work with the command window, like xpadder. enable this argument on these Run calls so it doesn't get caught here
Run(target,workingDir:="",options:=0,ByRef outputVarPID:="",inputBlocker:=1,bypassCmdWindow:=0,disableLogging:=0){
	Static cmdWindowCount
	Global logShowCommandWindow,logCommandWindow,cmdWindowObj,blockInputTime,blockInputFile,errorLevelReporting
	options := If options = 1 ? "useErrorLevel" : options	; enable or disable error level
	If disableLogging
		RLLog.Info(A_ThisFunc . " - Running hidden executable in " . workingDir)
	Else
		RLLog.Info(A_ThisFunc . " - Running: " . workingDir . "\" . target)
	If (blockInputTime && inputBlocker = 1)	; if user set a block time, use the user set length
		blockTime := blockInputTime
	Else If (inputBlocker > 1)	; if module called for a block, use that amount
		blockTime := inputBlocker
	Else	; do not block input
		blockTime := ""
	If blockTime
	{	RLLog.Info(A_ThisFunc . " - Blocking Input for: " . blockTime . " seconds")
		Run, %blockInputFile% %blockTime%
	}
	If !cmdWindowObj
		cmdWindowObj := Object()	; initialize object, this is used so all the command windows can be properly closed on exit
	If (logShowCommandWindow = "true" && !bypassCmdWindow) {
		Run, %ComSpec% /k, %workingDir%, %options%, outputVarPID	; open a command window (cmd.exe), starting in the directory of the target executable
		curErr := ErrorLevel	; store error level immediately
		If errorLevelReporting = true
		{	RLLog.Debug(A_ThisFunc . " - Error Level for " . ComSpec . " reported as: " . curErr)
			errLvl := curErr	; allows the module to handle the error level
		}
		RLLog.Info(A_ThisFunc . " - Showing Command Window to troubleshoot launching. ProcessID: " . outputVarPID)
		WinWait, ahk_pid %outputVarPID%
		WinActivate, ahk_pid %outputVarPID%
		WinWaitActive, ahk_pid %outputVarPID%,,2
		If ErrorLevel {
			WinSet, AlwaysOnTop, On, ahk_pid %outputVarPID%
			WinActivate, ahk_pid %outputVarPID%
			WinWaitActive, ahk_pid %outputVarPID%,,2
			If ErrorLevel
				ScriptError("Could not put focus onto the command window. Please try turning off Fade In if you have it enabled in order to see it")
		}
		WinGet, procName, ProcessName, ahk_pid %outputVarPID%	; get the name of the process (which should usually be cmd.exe)
		mapObjects[currentObj,"type"] := "database"
		cmdWindowCount++
		cmdWindowObj[cmdWindowCount,"Name"] := procName	; store the ProcessName being ran
		cmdWindowObj[cmdWindowCount,"PID"] := outputVarPID	; store the PID of the application being ran
		foundPos := RegExMatch(target,".*\.(exe|bat)",targetExeOnly)	; grab only the exe or bat file from the supplied target
		exeLen := StrLen(targetExeOnly)		; get length of exe name
		params := SubStr(target, exeLen+1)	; grab optional params out of supplied target
		If InStr(targetExeOnly, A_Space)
			target := """" . targetExeOnly . """" . params
		If (logCommandWindow = "true")
			SendInput, {Raw}%target% 1>"%A_ScriptDir%\command_%cmdWindowCount%_output.log" 2>"%A_ScriptDir%\command_%cmdWindowCount%_error.log"	; send the text to the command window and log the output to file
		Else
			SendInput, {Raw}%target%	; send the text to the command window and run it
		Send, {Enter}
	} Else {
		Run, %target%, %workingDir%, %options%, outputVarPID
		curErr := ErrorLevel	; store error level immediately
		If errorLevelReporting = true
		{	RLLog.Debug(A_ThisFunc . " - Error Level for " . target . " reported as: " . curErr)
			errLvl := curErr	; allows the module to handle the error level
		}
	}
	If disableLogging
		RLLog.Debug(A_ThisFunc . " - ""Hidden executable"" Process ID: " . outputVarPID)
	Else
		RLLog.Debug(A_ThisFunc . " - """ . target . """ Process ID: " . outputVarPID)
	Return errLvl
}

; Replaces standard ahk IniRead calls
; Will not let ERROR be returned, returns no value instead
; If errormsg is set, will trigger ScriptError instead of returning no or default value
IniRead(file,section,key,defaultvalue:="",errorMsg:="") {
	IniRead, v, %file%, %section%, %key%, %defaultvalue%
	; msgbox % v
	RLLog.Debug(A_ThisFunc . " - SECTION: [" . section . "] - KEY: " . key . " - VALUE: " . v . " - FILE: " . file)
	If (v = "ERROR" || v = A_Space) {	; if key does not exist or is a space, delete ERROR as the value
		If errorMsg
			ScriptError(errorMsg)
		Else {
			If (defaultValue := A_Space)	; this prevents the var from existing when it's actually blank
				defaultValue := ""
			Return defaultValue
		}
	}
	Return v
}

; Replaces standard ahk IniWrite calls
; compare = if used, only writes new value if existing value differs
IniWrite(value,file,section,key,compare:="") {
	If compare {
		IniRead, v, %file%, %section%, %key%
		If (v != value) {
			IniWrite, %value%, %file%, %section%, %key%
			err := ErrorLevel
			RLLog.Info(A_ThisFunc . " - ini updated due to differed value. SECTION: [" . section . "] - KEY: " . key . " - Old: " . v . " | New: " . value)
		} Else
			RLLog.Debug(A_ThisFunc . " - ini value already correct. SECTION: [" . section . "] - KEY: " . key . " - Value: " . value)
	} Else {
		IniWrite, %value%, %file%, %section%, %key%
		err := ErrorLevel
		RLLog.Info(A_ThisFunc . " - SECTION: [" . section . "] - KEY: " . key . " - VALUE: " . value . " - FILE: " . file)
	}
	If err
		RLLog.Error(A_ThisFunc . " - There was an error writing to the ini")
	Return err	; returns 1 if there was an error
}

Process(cmd,name,cmdParam:=""){
	RLLog.Info(A_ThisFunc . " - " . cmd . A_Space . name . A_Space . cmdParam)
	Process, %cmd%, %name%, %cmdParam%
	Return ErrorLevel
}

ControlGetText(Control,WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:="",log:=1)
{
	If !WinTitle
		ScriptError("WinTitle is required for Control.GetText")
	ControlGetText, OutPutVar , % Control, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
	If log
		RLLog.Trace(A_ThisFunc . " - Retrieved text """ . OutPutVar . """ from " . WinTitle . A_Space . WinText)
	If ErrorLevel
		RLLog.Trace(A_ThisFunc . " - There was an error retrieving the text")
	Return OutPutVar
}

ControlSetText(Control,NewText:="",WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:="",log:=1)
{
	If !WinTitle
		ScriptError("WinTitle is required for ControlSetText")
	If log
		RLLog.Trace(A_ThisFunc . " - Setting control """ . Control . " on " . WinTitle . A_Space . WinText)
	ControlSetText, % Control, % NewText, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
	Return ErrorLevel
}

SetKeyDelay(delay:="",pressDur:="",play:="") {
	Global pressDuration
	If (delay = "")	; -1 is the default delay for play mode and 10 for event mode when none is supplied
		delay := (If play = "" ? 10 : -1)
	If (pressDur = "")	; -1 is the default pressDur when none is supplied
		pressDur := -1

	RLLog.Debug(A_ThisFunc . " - Current delay is " . A_KeyDelay  . ". Current press duration is " . pressDuration . ". Delay will now be set to """ . delay . """ms for a press duration of """ . pressDur . """")
	SetKeyDelay, %delay%, %pressDur%, %play%
	pressDuration := pressDur	; this is so the current pressDuration can be monitored outside the function
}

; Mainly used in modules to read module.ini settings so multiple sections of an ini can be read of the same key name
; section: Allows | separated values so multiple sections can be checked.
IniReadCheck(file,section,key,defaultvalue:="",errorMsg:="",logType:="") {
	Loop, Parse, section, |
	{	section%A_Index% := A_LoopField	; keep each parsed section in its own var
		If iniVar != ""	; if last loop's iniVar has a value, update this loop's default value with it
			defaultValue := If A_Index = 1 ? defaultValue : iniVar	; on first loop, default value will be the one sent to the function, on following loops it gets the value from the previous loop
		IniRead, iniVar, %file%, % section%A_Index%, %key%, %defaultvalue%
		If (IniVar = "ERROR" || iniVar = A_Space)	; if key does not exist or is a space, delete ERROR as the value
			iniVar := ""
		If (A_Index = 1 && iniVar = ""  and !logType) {
			If errorMsg
				ScriptError(errorMsg)
			Else
				IniWrite, %defaultValue%, %file%, % section%A_Index%, %key%
			Return defaultValue
		}
		If logType	; only log if logType set
		{	logAr := ["Module","Bezel"]
			RLLog.Info(logAr[logType] . " Setting - [" . section%A_Index% . "] - " . key . ": " . iniVar)
		}
		If (iniVar != "")	; if IniVar contains a value, update the lastIniVar
			lastIniVar := iniVar
	}
	If defaultValue = %A_Space%	; this prevents the var from existing when it's actually blank
		defaultValue := ""
	Return If A_Index = 1 ? iniVar : If lastIniVar != "" ? lastIniVar : defaultValue	; if this is the first loop, always return the iniVar. If any other loop, return the lastinivar if it was filled, otherwise send the last updated defaultvalue
}

MaximizeWindow(WinTitle, keepAspectRatio:="true", removeTitle:="true", removeBorder:="true", removeToggleMenu:="true") {
	RLLog.Info(A_ThisFunc . " - Started to process window """ . winTitle . """")
	If (removeTitle = "true")
		WinSet("Style", "-0xC00000", WinTitle)	;Removes the titlebar of the game window
	If (removeBorder = "true")
		WinSet("Style", "-0x40000", WinTitle)	;Removes the border of the game window
	If (removeToggleMenu = "true") {
		WinID := WinGet( "ID", WinTitle)
		ToggleMenu(WinID)
    }

	If (keepAspectRatio = "true") {
		WinGetPos(appX, appY, appWidth, appHeight, WinTitle)
		widthMaxPercenty := ( A_ScreenWidth / appWidth )
		heightMaxPercenty := ( A_ScreenHeight / appHeight )

		If  ( widthMaxPercenty < heightMaxPercenty )
			percentToEnlarge := widthMaxPercenty
		Else
			percentToEnlarge := heightMaxPercenty

		appWidthNew := appWidth * percentToEnlarge
		appHeightNew := appHeight * percentToEnlarge

		
		currentFloat := A_FormatFloat 
		SetFormat,Float,0.0	; set float to whole numbers only
		appY := MiscUtils.Transform("Round", appY)
		appWidthNew := MiscUtils.Transform("Round", appWidthNew, 2)
		appHeightNew := MiscUtils.Transform("Round", appHeightNew, 2)
		appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
		appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
		SetFormat,Float,%currentFloat%	; return format to previous state
	}
	Else {
		appXPos := 0
		appYPos := 0
		appWidthNew := A_ScreenWidth
		appHeightNew := A_ScreenHeight
	}
	MoveWindow(WinTitle,appXPos,appYPos,appWidthNew,appHeightNew)
	RLLog.Info(A_ThisFunc . " - Ended")
}

MoveWindow(winTitle,X,Y,W,H,timeLimit:=2000,ignoreWin:=""){  ; assures that a window is moved to the desired position within a timeout
	RLLog.Info(A_ThisFunc . " - Moving window " . winTitle . " to X=" . X . ", Y=" . Y . ", W=" . W . " H=" . H)
	WinMove(X,Y,W,H,winTitle,"",ignoreWin)
	;check If window moved
	timeout := A_TickCount
	Loop
	{	WinGetPos(Xgot, Ygot, Wgot, Hgot, winTitle,"", ignoreWin)
	
		If ((Xgot=X) and (Ygot=Y) and (Wgot=W) and (Hgot=H)){
			RLLog.Info(A_ThisFunc . " - Successful: Window " . winTitle . " moved to X=" . X . ", Y=" . Y . ", W=" . W . " H=" . H)
			error := 0
			Break
		}
		If (timeout<A_TickCount-timeLimit){
			RLLog.Warning(A_ThisFunc . " - Failed: Window " . winTitle . " at X=" . Xgot . ", Y=" . Ygot . ", W=" . Wgot . " H=" . Hgot)
			error := 1
			Break
		}
		Sleep, 200
		WinMove(X,Y,W,H,winTitle,"",ignoreWin)
	}
	Return error
}

; Purpose: Handle an emulators Open Rom window when CLI is not an option
; Returns 1 when successful
OpenROM(windowName,selectedRomName) {
	RLLog.Info(A_ThisFunc . " - Started")
	Global MEmu,moduleName
	WinWait(windowName)
	WinWaitActive(windowName)
	state := 0
	Loop, 150	; 15 seconds
	{	ControlSetText("Edit1", selectedRomName, windowName)
		edit1Text := ControlGetText("Edit1", windowName)
		If (edit1Text = selectedRomName) {
			state := 1
			RLLog.Debug(A_ThisFunc . " - Successfully set romName into """ . windowName . """ in " . A_Index . " " . (If A_Index = 1 ? "try." : "tries."))
			Break
		}
		Sleep, 100
	}
	If (state != 1)
		ScriptError("Tried for 15 seconds to send the romName to " . MEmu . " but was unsuccessful. Please try again with Fade and Bezel disabled and put the " . moduleName . " in windowed mode to see if the problem persists.", 10)
	PostMessage,0x111, 1,,, %windowName%	; Select Open
	RLLog.Info(A_ThisFunc . " - Ended")
	Return state
}

GetActiveWindowStatus(){
	dWin := A_DetectHiddenWindows	; store current value to return later
	MiscUtils.DetectHiddenWindows("On")
	activeWinHWND := WinExist("A")
	WinGet, procPath, ProcessPath, ahk_id %activeWinHWND%
	WinGet, procID, PID, ahk_id %activeWinHWND%
	WinGet, winState, MinMax, ahk_id %activeWinHWND%
	WinGetClass, winClass, ahk_id %activeWinHWND%
	WinGetTitle, winTitle, ahk_id %activeWinHWND%
	WinGetPos, X, Y, W, H, ahk_id %activeWinHWND%
	RLLog.Debug(A_ThisFunc . " - Title: " . winTitle . " | Class: " . winClass . " | State: " . winState . " | X: " . X . " | Y: " . Y . " | Width: " . W . " | Height: " . H . " | Window HWND: " . activeWinHWND . " | Process ID: " . procID . " | Process Path: " . procPath)
	MiscUtils.DetectHiddenWindows(dWin)	; restore prior state
}

; CheckFile Usage:
; file = file to be checked if it exists
; msg = the error msg you want displayed on screen if you don't want the default "file not found"
; timeout = gets passed to ScriptError(), the amount of time you want the error to show on screen
; crc = If this is a an AHK library only, provide a crc so it can be validated
; crctype = default empty and crc is not checked. Use 0 for AHK libraries and RocketLauncher extension files. Use 1 for module crc checks..
; logerror = default empty will give a log error instead of stopping with a scripterror
; allowFolder = allows folders or files w/o an extension to be checked. By default a file must have an extension.
CheckFile(file,msg:="",timeout:=6,crc:="",crctype:="",logerror:="",allowFolder:=0){
	Global logIncludeFileProperties
	exeFileInfo := "
	( LTrim
	FileDescription
	FileVersion
	InternalName
	LegalCopyright
	OriginalFilename
	ProductName
	ProductVersion
	CompanyName
	PrivateBuild
	SpecialBuild
	LegalTrademarks
	)"

	RLLog.Info(A_ThisFunc . " - Checking if " . file . " exists")
	SplitPath, file, fileName, filePath, fileExt, fileNameNoExt
	If !FileExist(filePath . "\" . fileName)
		If FileExist(filePath . "\" . fileNameNoExt . " (Example)." . fileExt) {
			FileCopy, %filePath%\%fileNameNoExt% (Example).%fileExt%, %filePath%\%fileName%
			If ErrorLevel
				RLLog.Error(A_ThisFunc . " - Found an example for this file, but did not have permissions to retore it: " . filePath . "\" . fileNameNoExt . " (Example)." . fileExt)
			Else
				RLLog.Warning(A_ThisFunc . " - Restored this file from its example: " . filePath . "\" . fileNameNoExt . " (Example)." . fileExt)
		} Else {
			If msg
				ScriptError(msg, timeout)
			Else
				ScriptError("Cannot find " . file, timeout)
		}
	If (!fileExt && !allowFolder)
		ScriptError("This is a folder and must point to a file instead: " . file, timeout)

	If (crctype = 0 Or crctype = 1) {
		CRCResult := RLObject.checkModuleCRC("" . file . "",crc,crctype)
		If (CRCResult = -1)
			RLLog.Error("CRC Check - " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Library" : "Extension") . " file not found.")
		Else If (CRCResult = 0)
			If (crctype = 1)
				RLLog.Warning("CRC Check - CRC does not match official module and will not be supported. Continue using at your own risk.")
			Else If logerror
				RLLog.Error("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Library" : "Extension") . ". Please re-download this file to continue using RocketLauncher: " . file)
			Else
				ScriptError("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Library" : "Extension") . ". Please re-download this file to continue using RocketLauncher: " . file)
		Else If (CRCResult = 1)
			RLLog.Debug("CRC Check - CRC matches, this is an official unedited " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Library" : "Extension") . ".")
		Else If (CRCResult = 2)
			RLLog.Error("CRC Check - No CRC defined on the header for: " . file)
	}

	If (logIncludeFileProperties = "true")
	{	If exeAtrib := FileGetVersionInfo_AW(file, exeFileInfo, "`n")
			Loop, Parse, exeAtrib, `n
				logTxt .= (If A_Index=1 ? "":"`n") . "`t`t`t`t`t" . A_LoopField
		FileGetSize, fileSize, %file%
		FileGetTime, fileTimeC, %file%, C
		FormatTime, fileTimeC, %fileTimeC%, M/d/yyyy - h:mm:ss tt
		FileGetTime, fileTimeM, %file%, M
		FormatTime, fileTimeM, %fileTimeM%, M/d/yyyy - h:mm:ss tt
		logTxt .= (If logTxt ? "`r`n":"") . "`t`t`t`t`tFile Size:`t`t`t" . fileSize . " bytes"
		logTxt .= "`r`n`t`t`t`t`tCreated:`t`t`t" . fileTimeC
		logTxt .= "`r`n`t`t`t`t`tModified:`t`t`t" . fileTimeM
		RLLog.Debug(A_ThisFunc . " - Attributes:`r`n" . logTxt)
	}
	Return %file%
}

CheckFolder(folder,msg:="",timeout:=6,crc:="",crctype:="",logerror:="") {
   Return CheckFile(folder,msg,timeout,crc,crctype,logerror,1)
}

; ScriptError usage:
; error = error text
; timeout = duration in seconds error will show
; w = width of error box
; h = height of error box
; txt = font size
ScriptError(error,timeout:=6,w:=800,h:=225,txt:=20,noexit:=""){
	Global RLMediaPath,exitEmulatorKey,RLFile,RLErrSoundPath,logShowCommandWindow,cmdWindowObj,scriptErrorTriggered,errorSounds
	Global screenRotationAngle,baseScreenWidth,baseScreenHeight,xTranslation,yTranslation,XBaseRes,YBaseRes

	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
	XHotKeywrapper(exitEmulatorKey,"CloseError","ON")
	Hotkey, Esc, CloseError
	Hotkey, Enter, CloseError
	
	If !pToken := Gdip_Startup(){	; Start gdi+
		MsgBox % "Gdiplus failed to start. Please ensure you have gdiplus on your system"
		ExitApp
	}

	timeout *= 1000	; converting to seconds
	;Acquiring screen info for dealing with rotated menu drawings
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
		XBaseRes := 1920, YBaseRes := 1080
	If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
		XBaseRes := 1080, YBaseRes := 1920
	If !errorXScale 
		errorXScale := baseScreenWidth/XBaseRes
	If !errorYScale
		errorYScale := baseScreenHeight/YBaseRes
	Error_Warning_Width := w
    Error_Warning_Height := h
    Error_Warning_Pen_Width := 7
    Error_Warning_Rounded_Corner := 30
    Error_Warning_Margin := 30
    Error_Warning_Bitmap_Size := 125
    Error_Warning_Text_Size := txt
    OptionScale(Error_Warning_Width, errorXScale)
    OptionScale(Error_Warning_Height, errorYScale)
    OptionScale(Error_Warning_Pen_Width, errorXScale)    
    OptionScale(Error_Warning_Rounded_Corner, errorXScale)  
    OptionScale(Error_Warning_Margin, errorXScale)    
    OptionScale(Error_Warning_Bitmap_Size, errorXScale)
    OptionScale(Error_Warning_Text_Size, errorYScale)

	;Create error GUI
	Gui, Error_GUI: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop
	Gui, Error_GUI: Margin,0,0
	Gui, Error_GUI: Show,, ErrorLayer
	Error_hwnd := WinExist()
	Error_hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
	Error_hdc := CreateCompatibleDC()
	Error_obm := SelectObject(Error_hdc, Error_hbm)
	Error_G := Gdip_GraphicsFromhdc(Error_hdc)
	Gdip_SetSmoothingMode(Error_G, 4)
	Gdip_TranslateWorldTransform(Error_G, xTranslation, yTranslation)
	Gdip_RotateWorldTransform(Error_G, screenRotationAngle)
	pGraphUpd(Error_G,baseScreenWidth, baseScreenHeight)

	;Create GUI elements
	pBrush := Gdip_BrushCreateSolid("0xFF000000")	; Painting the background color
	Gdip_Alt_FillRectangle(Error_G, pBrush, -1, -1, baseScreenWidth+1, baseScreenHeight+1)	; draw the background first on layer 1 first, layer order matters!!
	brushWarningBackground := Gdip_CreateLineBrushFromRect(0, 0, Error_Warning_Width, Error_Warning_Height, 0xff555555, 0xff050505)
	penWarningBackground := Gdip_CreatePen(0xffffffff, Error_Warning_Pen_Width)
	Gdip_Alt_FillRoundedRectangle(Error_G, brushWarningBackground, (baseScreenWidth - Error_Warning_Width)//2, (baseScreenHeight - Error_Warning_Height)//2, Error_Warning_Width, Error_Warning_Height, Error_Warning_Rounded_Corner)
	Gdip_Alt_DrawRoundedRectangle(Error_G, penWarningBackground, (baseScreenWidth - Error_Warning_Width)//2, (baseScreenHeight - Error_Warning_Height)//2, Error_Warning_Width, Error_Warning_Height, Error_Warning_Rounded_Corner)
	WarningBitmap := Gdip_CreateBitmapFromFile(RLMediaPath . "\Menu Images\RocketLauncher\Warning.png")
	Gdip_Alt_DrawImage(Error_G,WarningBitmap, round((baseScreenWidth - Error_Warning_Width)//2 + Error_Warning_Margin),round(baseScreenHeight/2 - Error_Warning_Bitmap_Size/2),Error_Warning_Bitmap_Size,Error_Warning_Bitmap_Size)
	Gdip_Alt_TextToGraphics(Error_G, error, "x" round((baseScreenWidth-Error_Warning_Width)//2+Error_Warning_Bitmap_Size+Error_Warning_Margin) " y" round((baseScreenHeight-Error_Warning_Height)//2+Error_Warning_Margin) " Left vCenter cffffffff r4 s" Error_Warning_Text_Size " Bold",, round((Error_Warning_Width - 2*Error_Warning_Margin - Error_Warning_Bitmap_Size)) , round((Error_Warning_Height - 2*Error_Warning_Margin)))

	startTime := A_TickCount
	Loop{	; fade in
		t := ((TimeElapsed := A_TickCount-startTime) < 300) ? (255*(timeElapsed/300)) : 255
		Alt_UpdateLayeredWindow(Error_hwnd,Error_hdc, 0, 0, baseScreenWidth, baseScreenHeight,t)
		If (t >= 255)
			Break
	}

	; Generate a random sound to play on a script error
	erSoundsAr:=[]	; initialize the array to store error sounds
	Loop, %RLErrSoundPath%\error*.mp3
		erSoundsAr.Insert(A_LoopFileName)	; insert each found error sound into an array
	Random, erRndmSound, 1, % erSoundsAr.MaxIndex()	; randomize what sound to play
	RLLog.Debug(A_ThisFunc . " - Playing error sound: " . erSoundsAr[erRndmSound])
	setMute(0,emulatorVolumeObject)
	If (errorSounds = "true")
		SoundPlay % If erSoundsAr.MaxIndex() ? (RLErrSoundPath . "\" . erSoundsAr[erRndmSound]):("*-64"), wait	; play the random sound if any exist, or default to the Asterisk windows sound
	If noexit {	; do not close thread, continue with script and let it handle the exiting
		scriptErrorTriggered := 1
		Return
	}
	7zCleanUp()	; clean up 7z if necessary
	Sleep, %timeout%

	CloseError:
		endTime := A_TickCount
		Loop {	; fade out
			t := ((TimeElapsed := A_TickCount-endTime) < 300) ? (255*(1-timeElapsed/300)) : 0
			Alt_UpdateLayeredWindow(Error_hwnd,Error_hdc, 0, 0, baseScreenWidth, baseScreenHeight,t)
			If (t <= 0)
				Break
		}

		XHotKeywrapper(exitEmulatorKey,"CloseError","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(WarningBitmap), SelectObject(Error_hdc, Error_obm), DeleteObject(Error_hbm), DeleteDC(Error_hdc), Gdip_DeleteGraphics(Error_G)
		Gui, ErrorGUI_10: Destroy
		RLLog.Error("ScriptError - " . error)
		
		ExitModule()	; attempting to use this method which has the small chance to cause an infinite ScriptError loop, but no need to duplicate code to clean up on errors
		; Below cleanup exists because we can't call other functions that may cause additional scripterrors and put the thread in an infinite loop
		; If logShowCommandWindow = true
		; {	for index, element in cmdWindowObj
				; Process, Close, % cmdWindowObj[A_Index,1]	; close each opened cmd.exe
		; }
		; ExitApp
}

; Log usage:
; txt = text I want to log
; lvl = the lvl to log the text at
; notime = only used for 1st and last lines of the log so a time is not inserted when I inset the BBCode [code] tags. Do not use this param
; dump = tells the function to write the log file at the end. Do not use this param
; firstLog = tells the function to not insert a time when the first log is made, instead puts an N/A. Do not use this param
; Log() in the module thread requires `r`n at the end of each line, where it's not needed in the RocketLauncher thread
Log(txt,lvl:=1,notime:="",dump:="",firstLog:=""){
	Static log
	Static lastLog
	Static x := ["Info","Warning","Error","Debug","Trace"]
	Global logFile,logLevel,logLabel,logShowDebugConsole
	RLLog[x[lvl]](txt)
}

; Rini returns -2 if section does not exist
; Rini returns -3 if key does not exist
; Rini returns -10 if an invalid reference var for the ini file was used
; Rini returns empty value if key exists with no value
; rIniIndex := Object(1,globalRLFile,2,sysRLFile,3,globalEmuFile,4,sysEmuFile,5,RLFile,6,gamesFile)
; preferDefault - On rare occasions we may want to set a default value w/o wanting rini to return an error value of -2 or -3. Used for JoyIDs_Preferred_Controllers
RIniLoadVar(gRIniVar,sRIniVar,section,key,gdefaultvalue:="",sdefaultvalue:="use_global",preferDefault:="") {
	Global rIniIndex
	If (gRIniVar != "GlobalRLIni")	; do not create missing sections or keys for games.ini
	{	globalValue := RIni_GetKeyValue(gRIniVar,section,key,If preferDefault ? gdefaultvalue : "")
		globalValue := globalValue	; trims whitespace
		If RegExMatch(globalValue,"-2|-3")	; if global ini key does not exist, create the key
		{	RIni_SetKeyValue(gRIniVar,section,key,gdefaultvalue)
			RIni_Write(gRIniVar,rIniIndex[gRIniVar],"`r`n",1,1,1)
			globalValue := gdefaultvalue	; set to default value because it did not exist
			RLLog.Warning(A_ThisFunc . " - Created missing Global ini key: """ . key . """ in section: """ . section . """ in """ . rIniIndex[gRIniVar] . """")
		}
		If sRIniVar	; != ""	; only create system sections or keys for inis that use them
		{	systemValue := RIni_GetKeyValue(sRIniVar,section,key,If preferDefault ? sdefaultvalue : "")
			systemValue := systemValue	; trims whitespace
			If RegExMatch(systemValue,"-2|-3")	; if system ini key does not exist, create the key
			{	RIni_SetKeyValue(sRIniVar,section,key,sdefaultvalue)
				RIni_Write(sRIniVar,rIniIndex[sRIniVar],"`r`n",1,1,1)
				systemValue := sdefaultvalue	; set to default value because it did not exist
				RLLog.Warning(A_ThisFunc . " - Created missing System ini key: """ . key . """ in section: """ . section . """ in """ . rIniIndex[sRIniVar] . """")
			}
			Return If systemValue = "use_global" ? globalValue : systemValue	; now compare global & system keys to get final value
		}
		Return globalValue	; return globalValue when not using globa/system inis, like RLFile (rIniIndex 5)
	}
	iniVar := RIni_GetKeyValue(gRIniVar,section,key,gdefaultvalue)	; lookup key from ini and return it
	iniVar := Trim(iniVar)	; trims whitespace
	Return iniVar
}

RIniReadCheck(rIniVar,section,key,defaultvalue:="",errorMsg:="") {
	Global rIniIndex
	iniVar := RIni_GetKeyValue(rIniVar,section,key)	; lookup key from ini and return it
	iniVar := Trim(iniVar)	; trims whitespace
	If (iniVar = -2 or iniVar = -3 or iniVar = "") {
		If (iniVar != "") {	; with rini, no need write to ini file if value is returned empty, we already know the section\key exists with no value
			RLLog.Warning(A_ThisFunc . " - Created missing RocketLauncher ini key: """ . key . """ in section: """ . section . """ in """ . rIniIndex[rIniVar] . """")
			RIni_SetKeyValue(rIniVar,section,key,defaultvalue)
			RIni_Write(rIniVar,rIniIndex[rIniVar],"`r`n",1,1,1)	; write blank section, blank key, and space between sections
		}
		If errorMsg
			ScriptError(errorMsg)
		Return defaultValue
	}
	Return iniVar
}

CheckFont(font) {
	If !(Gdip_FontFamilyCreate(font))
		ScriptError("The Font """ . font . """ is not installed on your system. Please install the font or change it in RocketLauncherUI.")
}

; Toggles hiding/showing a MenuBar
; Usage: Provide the window's PID of the window you want to toggle the MenuBar
; used in BGB & nulldc module and bezel
ToggleMenu(hWin){
	Static hMenu, visible
	RLLog.Info(A_ThisFunc . " - Started")
	If (hMenu = "")
		hMenu := DllCall("GetMenu", "uint", hWin)	; store the menubar ID so it can be restored later
	hMenuCur := DllCall("GetMenu", "uint", hWin)
	timeout := A_TickCount
	If !hMenuCur {
		Loop {
			;ToolTip, menubar is hidden`, bringing it back`nhMenuCur: %hMenuCur%`n%A_Index%
			hMenuCur := DllCall("GetMenu", "uint", hWin)
			If hMenuCur {
				RLLog.Debug(A_ThisFunc . " - MenuBar is now visible for " . hWin)
				Break	; menubar is now visible, break out
			}
			DllCall("SetMenu", "uint", hWin, "uint", hMenu)
			If (timeout < A_TickCount - 500) {	; prevents an infinite loop and breaks after 2 seconds
				RLLog.Warning(A_ThisFunc . " - Timed out trying to restore MenuBar for " . hWin)
				Break
			}
		}
	} Else {
		Loop {	; menubar is visible
			;ToolTip, menubar is visible`, hiding it`nhMenuCur: %hMenuCur%`n%A_Index%
			hMenuCur := DllCall("GetMenu", "uint", hWin)
			If !hMenuCur {
				RLLog.Debug(A_ThisFunc . " - MenuBar is now hidden for " . hWin)
				Break	; menubar is now hidden, break out
			}
			DllCall("SetMenu", "uint", hWin, "uint", 0)
			If (timeout < A_TickCount - 500) {	; prevents an infinite loop and breaks after 2 seconds
				RLLog.Warning(A_ThisFunc . " - Timed out trying to hide MenuBar for " . hWin)
				Break
			}
		}
	}
	RLLog.Info(A_ThisFunc . " - Ended")
}
; Original function but somestimes does not work, which is why the new function loops above
ToggleMenuOld(hWin){
	Static hMenu, visible
	If (hMenu = "")
		hMenu := DllCall("GetMenu", "uint", hWin)
	If !visible
			DllCall("SetMenu", "uint", hWin, "uint", hMenu)
	Else
		DllCall("SetMenu", "uint", hWin, "uint", 0)
	visible := !visible
}

; Function to pause and wait for a user to press any key to continue.
; IdleCheck usage:
; t = timeout in ms to break out of function
; m = the method - can be "P" (physical) or "L" (logical)
; s = sleep or how fast the function checks for idle state
; Exits when state is no longer idle or times out
IdleCheck(t:="",m:="L",s:=200){
	timeIdlePrev := 0
	startTime := A_TickCount
	While timeIdlePrev < (If m = "L" ? A_TimeIdle : A_TimeIdlePhysical){
		timeIdlePrev := If m = "L" ? A_TimeIdle : A_TimeIdlePhysical
		If (t && A_TickCount-startTime >= t)
			Return "Timed Out"
		Sleep s
	}
	Return A_PriorKey
}

; This function looks through all defined romPaths and romExtensions for the provided rom file
; Returns a path to the rom where it was found
; Returns nothing if not found
RomNameExistCheck(file,archivesOnly:="") {
	Global romPathFromIni,romExtensions,sevenZFormats
	Loop, Parse,  romPathFromIni, |	; for each rom path defined
	{	tempRomPath := A_LoopField	; assigning this to a var so it can be accessed in the next loop
		Loop, Parse, romExtensions, |	; for each extension defined
		{	If (archivesOnly != "")
				If !InStr(sevenZFormats,A_LoopField)	; if rom extension is not an archive type, skip this rom
					Continue
			; msgbox % tempRomPath . "\" . file . "." . tempRomExtension
			RLLog.Debug(A_ThisFunc . " - Looking for rom: " . tempRomPath . "\" . file . "." . A_LoopField)
			If FileExist( tempRomPath . "\" . file . "." . A_LoopField ) {
				RLLog.Info(A_ThisFunc . " - Found rom: " . tempRomPath . "\" . file . "." . A_LoopField)
				Return tempRomPath . "\" . file . "." . A_LoopField	; return path if file exists
			}
			RLLog.Debug(A_ThisFunc . " - Looking for rom: " . tempRomPath . "\" . file . "\" . file . "." . A_LoopField)
			If FileExist( tempRomPath . "\" . file . "\" . file . "." . A_LoopField ) {	; check one folder deep of the rom's name in case user keeps each rom in a folder
				RLLog.Info(A_ThisFunc . " - Found rom: " . tempRomPath . "\" . file . "\" . file . "." . A_LoopField)
				Return tempRomPath . "\" . file . "\" . file . "." . A_LoopField	; return path if file exists
			}
		}
	}
	RLLog.Warning(A_ThisFunc . " - Could not find """ . file . """ in any of your Rom Paths with any defined Rom Extensions")
	Return
}

; Shared romTable function and label for Pause and MG which calculates what roms have multiple discs. Now available on every launch to support some custom uses for loading multiple disks on some older computer systems
CreateMGRomTable:
	RLLog.Info(A_ThisLabel . " - Started")
	If !mgCandidate {
		RLLog.Info(A_ThisLabel . " - Ended - This rom does not qualify for MultiGame")
		Return
	}
	If !IsObject(romTable)
	{	RLLog.Debug(A_ThisLabel . " - romTable does not exist, creating one for """ . dbName . """")
		romTable := CreateRomTable(dbName)
	} Else
		RLLog.Debug(A_ThisLabel . " - romTable already exists, skipping table creation.")
	RLLog.Info(A_ThisLabel . " - Ended")
Return

CreateRomTable(table) {
	Global romPathFromIni,dbName,romExtensionOrig,sevenZEnabled,romTableStarted,romTableComplete,romTableCanceled,rocketLauncherIsExiting,mgCandidate
	romTableStarted := 1
	romTableCanceled := ""
	romTableComplete := ""
	If rocketLauncherIsExiting {
		romTableCanceled := 1	; set this so the RomTableCheck is canceled and doesn't get stuck in an infinite loop
		RLLog.Info(A_ThisFunc . " - RocketLauncher is currently exiting, skipping romTable creation")
		Return
	}
	If !mgCandidate {
		romTableCanceled := 1	; set this so the RomTableCheck is canceled and doesn't get stuck in an infinite loop
		RLLog.Info(A_ThisFunc . " - This rom does not qualify for MultiGame")
		Return
	}
	RLLog.Info(A_ThisFunc . " - Started")

	romCount := 0	; initialize the var and reset it, needed in case GUI is used more then once in a session
	table := []	; initialize and empty the table
	typeArray := ["(Disc","(Disk","(Cart","(Tape","(Cassette","(Part","(Side"]
	regExCheck = i)\s\(Disc\s[^/]*|\s\(Disk\s[^/]*|\s\(Cart\s[^/]*|\s\(Tape\s[^/]*|\s\(Cassette\s[^/]*|\s\(Part\s[^/]*|\s\(Side\s[^/]*
	dbNamePre := RegExReplace(dbName, regExCheck)	; removes the last set of parentheses if Disc,Tape, etc is in them. A Space must exist before the "(" and after the word Disc or Tape, followed by the number. This is the HS2 standard
	Loop % typeArray.MaxIndex() ; loop each item in our array
	{	If matchedRom	; Once we matched our game to the typeArray, no need to search for another. This allows the loop to break out.
			Break
		indexTotal ++
		RLLog.Debug(A_ThisFunc . " - Checking for match: """ . dbName . """ and """ . typeArray[A_Index] . """")
		If dbName contains % typeArray[A_Index]	; find the item in our array that matches our rom
		{	RLLog.Debug(A_ThisFunc . " - """ . dbName . """ contains """ . typeArray[A_Index] . """")
			typeArrayIndex := A_Index
			Loop, Parse, romPathFromIni, |
			{	indexTotal ++
				currentPath := A_LoopField 
				RLLog.Debug(A_ThisFunc . " - Checking New Rom path: " . currentPath)
				RLLog.Debug(A_ThisFunc . " - Now looping in: " . currentPath  . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . "*")
				Loop, % currentPath . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . "*", 1,1	; we now know to only look for files & folders that have our rom & media type in them.
				{	indexTotal ++
					RLLog.Debug(A_LoopFileFullPath)
					RLLog.Debug(A_ThisFunc . " - Looking for: " . currentPath . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . "*." . A_LoopFileExt)
					If romExtensionOrig contains % A_LoopFileExt	; Now we narrow down to all matching files using our original extension. Next we use this data to build an array of our files to populate the GUI.
					{	romCount += 1
						matchedRom := 1	; Allows to break out of the loops once we matched our rom
						table[romCount,1] := A_LoopFileFullPath	; Store A_LoopFileFullPath (full file path and file) in column 1
						table[romCount,2] := A_LoopFileName	; Store A_LoopFileName (the full filename and extension) in column 2
						table[romCount,3] := RegExReplace(table[romCount, 2], "\..*")	; Store the filename with media type # but w/o an extension in column 3
						pos := RegExMatch(table[romCount,2], regExCheck)	; finds position of our multi media type so we can trim away and generate the imageText and check if rom is part of a set. This pulls only the filenames out of the table in column 2.
						uncleanTxt:= SubStr(table[romCount,2], pos + 1)	; remove everything but the media type and # and ext from our file name
						table[romCount,4] := dbNamePre	; store dbName w/o the media type and #, used for Pause and updating statistics in column 4
						table[romCount,5] := RegExReplace(uncleanTxt, "\(|\)|\..*")	; clean the remainder, removing () and ext, then store it as column 5 in our table to be used for our imageText, this is the media type and #
						table[romCount,6] := SubStr(table[romCount,5],1,4)	; copies just the media type to column 6
						RLLog.Debug(A_ThisFunc . " - Adding found game to Rom Table: " . A_LoopFileFullPath)
					}
				}
			}
		}
	}
	romTableComplete := 1	; flag to tell the RomTableCheck the function is complete in case no romTable was created for non-MG games
	romTableStarted := ""
	RLLog.Info(A_ThisFunc . " - Ended`, " . IndexTotal . " Loops to create table.")
	Return table
}

; Function that gets called in some modules to wait for romTable creation if the module bases some conditionals off whether this table exists or not
RomTableCheck() {
	Global systemName,mgEnabled,pauseEnabled,romTable,romTableStarted,romTableComplete,romTableCanceled,mgCandidate,dbName
	If mgCandidate { ; && (pauseEnabled = "true" || mgEnabled = "true")) {
		; If (!romTableStarted && !IsObject(romTable))
			; romTable := CreateRomTable(dbName)
			
		RLLog.Info(A_ThisFunc . " - Started")
		; PauseGlobalIni := A_ScriptDir . "\Settings\Global Pause.ini"		; Pause keys have not been read into memory yet, so they must be read here so RocketLauncher knows whether to run the below loop or not
		; PauseSystemIni := A_ScriptDir . "\Settings\" . systemName . "\Pause.ini" 
		; IniRead, changeDiscMenuG, %PauseGlobalIni%, General Options, ChangeDisc_Menu_Enabled
		; IniRead, changeDiscMenuS, %PauseSystemIni%, General Options, ChangeDisc_Menu_Enabled
		; changeDiscMenu := If changeDiscMenuS = "use_global" ? changeDiscMenuG : changeDiscMenuS	; calculate to use system or global setting

		; If (mgEnabled = "true" || changeDiscMenu = "true") {
			; RLLog.Debug(A_ThisFunc . " - MultiGame and/or Pause's Change Disc Menu is enabled so checking if romTable exists yet.")
			If !romTable.MaxIndex()
				RLLog.Debug(A_ThisFunc . " - romTable does not exist yet, waiting until it does to continue loading the module.")
			Loop {
				If romTableComplete {	; this var gets created when CreateRomTable is complete in case this is not an MG game
					RLLog.Debug(A_ThisFunc . " - Detected CreateRomTable is finished processing. Continuing with module thread.")
					Break
				} Else If romTableCanceled {	; this var gets created when CreateRomTable is cancelled in cases it is no longer needed
					RLLog.Debug(A_ThisFunc . " - Detected CreateRomTable is no longer needed. Continuing with module thread.")
					Break
				} Else	If (A_Index > 200) {	; if 20 seconds pass by, log there was an issue and continue w/o romTable
				RLLog.Error(A_ThisFunc . " - Creating the romTable took longer than 20 seconds. Continuing with module thread without waiting for the table's creation.")
					Break
				} Else
					Sleep, 100
			}
		; }
		RLLog.Info(A_ThisFunc . " - Ended")
	} Else
		RLLog.Info(A_ThisFunc . " - This game is not a candidate for MG or Change DIsc menu.")
}

; Allows changing LEDBlinky's active profile
; mode can be RL or Rom which tells LEDBlinky what profile to load
; Ledblinky's ini gets loaded on start, so this function will never touch it
LEDBlinky(mode) {
	Global ledblinkyEnabled,ledblinkySystemName,ledblinkyFullPath,ledblinkyProfilePath,ledblinkyRLProfile,dbName,systemName,romName
	Static ledblinkyExists,ledblinkyExe,ledblinkyPath
	If (ledblinkyEnabled != "false")
	{
		If !ledblinkyExists {	; Make sure LEDBlinky exists first before trying to use it
			If FileExist(ledblinkyFullPath) {
				ledblinkyExists := 1
				SplitPath,ledblinkyFullPath,ledblinkyExe,ledblinkyPath

			} Else
				ScriptError("You are trying to use LEDBlinky support but could not locate it here: " . ledblinkyFullPath)
		}
		RLLog.Info(A_ThisFunc . " - Started, sending mode " . mode)

		If (mode = "START")
			Run(ledblinkyExe . " """ . (If romName ? romName : dbName) . """ """ . (If ledblinkySystemName ? ledblinkySystemName : systemName) . """", ledblinkyPath)	; Game Start Event
		Else If (mode = "END")
			Run(ledblinkyExe . " 4"	, ledblinkyPath)	; Game Stop Event
		Else If (mode = "RL")
			Run(ledblinkyExe . " 15 RocketLauncher RocketLauncher", ledblinkyPath)	; Load RocketLauncher profile. "15" Tells ledblinky to skip all game start options and only light the controls.
		Else If (mode = "ROM")
			Run(ledblinkyExe . " 15 """ . (If romName ? romName : dbName) . """ """ . (If ledblinkySystemName ? ledblinkySystemName : systemName) . """", ledblinkyPath)	; return to rom profile. If within the module, romName can be used, otherwise default to dbName.
		Else
			RLLog.Error(A_ThisFunc . " - Unsupported use of LEDBlinky - UNKNOWN MODE SUPPLIED: """ . mode . """")
		RLLog.Info(A_ThisFunc . " - Ended")
	}
}

; Allows changing WinIPAC's and UltraMap's active profile, among any other tools thrown at it that would utilize similar profile structure
; mode = can be START, END, RL or RESUME which represents what part of RL is called the function and what profiles will be loaded
; tool = the name of the tool or folder that will be searched in and checked if that setting is enabled. Ex: WinIPAC or UltraMap
; path = because of how the function supports multiple scenarios, the fullpath to the exe must be provided. Not through making it Global as variables like %prefix%FullPath cannot be made global 
; ext = extension of the profiles to look for
; type = used to basically force special modes (only keyboard for now) so the function can support multiple scenarios that all use the same folder structures for profiles
KeymapperProfileSelect(mode,tool,path,ext,type:="") {
	Global keyboardEncoderEnabled,ultraMapEnabled,profilePath,keymapperFrontEndProfileName,systemName,emuName,dbName
	Global keymapperProfiles

	If !keymapperProfiles
		keymapperProfiles := {}	; create initial object
	
	If (type = "keyboard")
		prefix := "keyboardEncoder"
	Else
		prefix := tool
	
	If (%prefix%Enabled = "true") {
		keymapperProfiles[tool,"Enabled"] := "true"
		RLLog.Info(tool . " - Started with mode: " . mode)
		If !keymapperProfiles[tool,"Exist"] {	; Make sure the tool exists first before trying to use it
			If FileExist(path) {
				keymapperProfiles[tool,"Exist"] := 1
				keymapperProfiles[tool,"FullPath"] := path
				SplitPath,path,exe,path
				keymapperProfiles[tool,"Exe"] := exe
				keymapperProfiles[tool,"Path"] := path
				keymapperProfiles[tool,"Ext"] := "." . ext
				keymapperProfiles[tool,"ProfilePath"] := profilePath . "\" . tool
				keymapperProfiles[tool,"RLProfile"] := keymapperProfiles[tool,"ProfilePath"] . "\RocketLauncher"
				keymapperProfiles[tool,"FEProfile"] := keymapperProfiles[tool,"ProfilePath"] . "\" . keymapperFrontEndProfileName
				keymapperProfiles[tool,"DefaultProfile"] := keymapperProfiles[tool,"ProfilePath"] . "\_Default"
				keymapperProfiles[tool,"SystemProfile"] := keymapperProfiles[tool,"ProfilePath"] . "\" . systemName
				keymapperProfiles[tool,"EmuProfile"] := keymapperProfiles[tool,"ProfilePath"] . "\" . emuName
				keymapperProfiles[tool,"RomProfile"] := keymapperProfiles[tool,"ProfilePath"] . "\" . systemName . "\" . dbName
				; msgbox % "fullPath: " . keymapperProfiles[tool,"FullPath"] . "`nexe: " . keymapperProfiles[tool,"Exe"] . "`npath: " . keymapperProfiles[tool,"Path"] . "`nExt: " . keymapperProfiles[tool,"Ext"] . "`nProfilePath: " . keymapperProfiles[tool,"ProfilePath"] . "`nRLProfile: " . keymapperProfiles[tool,"RLProfile"] . "`nFEProfile: " . keymapperProfiles[tool,"FEProfile"] . "`nDefaultProfile: " . keymapperProfiles[tool,"DefaultProfile"] . "`nSystemProfile: " . keymapperProfiles[tool,"SystemProfile"] . "`nEmuProfile: " . keymapperProfiles[tool,"EmuProfile"] . "`nRomProfile: " . keymapperProfiles[tool,"RomProfile"]
			} Else {
				RLLog.Warning(tool . " - You have your path set to " . %prefix% . " defined, but it could not be found here: " . path)
				keymapperProfiles[tool,"Enabled"] := "false"
			}
		}

		If (mode = "START")
		{	RLLog.Debug(tool . " - Searching for profiles")
			If FileExist(keymapperProfiles[tool,"RomProfile"] . keymapperProfiles[tool,"Ext"]) {
				profile := keymapperProfiles[tool,"RomProfile"] . keymapperProfiles[tool,"Ext"]
			} Else If FileExist(keymapperProfiles[tool,"EmuProfile"] . keymapperProfiles[tool,"Ext"]) {
				profile := keymapperProfiles[tool,"EmuProfile"] . keymapperProfiles[tool,"Ext"]
			} Else If FileExist(keymapperProfiles[tool,"SystemProfile"] . keymapperProfiles[tool,"Ext"]) {
				profile := keymapperProfiles[tool,"SystemProfile"] . keymapperProfiles[tool,"Ext"]
			} Else If FileExist(keymapperProfiles[tool,"DefaultProfile"] . keymapperProfiles[tool,"Ext"]) {
				profile := keymapperProfiles[tool,"DefaultProfile"] . keymapperProfiles[tool,"Ext"]
			} Else {
				RLLog.Debug(tool . " - No profiles found")
				Return
			}
			keymapperProfiles[tool,"LastProfile"] := profile
		} Else If (mode = "END")
		{	RLLog.Debug(tool . " - Searching for your Front End profile")
			If FileExist(keymapperProfiles[tool,"FEProfile"] . keymapperProfiles[tool,"Ext"]) {
				profile := keymapperProfiles[tool,"FEProfile"] . keymapperProfiles[tool,"Ext"]
			} Else {
				RLLog.Debug(tool . " - Profile not found")
				Return
			}
		} Else If (mode = "RL")
		{	RLLog.Debug(tool . " - Searching for your RocketLauncher profile")
			If FileExist(keymapperProfiles[tool,"RLProfile"] . keymapperProfiles[tool,"Ext"]) {
				profile := keymapperProfiles[tool,"RLProfile"] . keymapperProfiles[tool,"Ext"]
			} Else {
				RLLog.Debug(tool . " - Profile not found")
				Return
			}
		} Else If (mode = "RESUME")
		{	RLLog.Debug(tool . " - Restoring to your last profile")
			If keymapperProfiles[tool,"LastProfile"]	; only restore to a previous profile if one was found on start
				profile := keymapperProfiles[tool,"LastProfile"]
			Else {
				RLLog.Debug(tool . " - A profile was not loaded on start, skipping any profile loading")
				Return
			}
		} Else
			RLLog.Warning(tool . " - Unsupported mode: " . mode)

		RLLog.Debug(tool . " - Loading found profile: " . profile)
		Run(keymapperProfiles[tool,"Exe"] . " """ . profile . """" . (If tool = "UltraMap" ? " /logerrors " . keymapperProfiles[tool,"Path"] . "\UltraMapLog.log" : ""), keymapperProfiles[tool,"Path"])	; If there was a problem loading a profile, WinIPAC will pop up with a box saying so with this title/class: "WinIPAC - Downloading ahk_class ThunderRT6FormDC". It does not return any error codes unfortunately. UltraMap requires errors to be logged otherwise it pops up with an error dialog.
		RLLog.Info(tool . " - Ended")
	}
}

; Function to measure the size of an text
MeasureText(Text,Options,Font:="Arial",Width:="", Height:="", ReturnMode:="W", ByRef H:="", ByRef W:="", ByRef X:="", ByRef Y:="", ByRef Chars:="", ByRef Lines:=""){
	hdc_MeasureText := GetDC("MeasureText_hwnd")
	G_MeasureText := Gdip_GraphicsFromHDC(hdc_MeasureText)
	RECTF_STR := Gdip_TextToGraphics(G_MeasureText, Text, Options, Font, Width, Height, 1)
	StringSplit,RCI,RECTF_STR, |
	W := Ceil(RCI3)
	H := Ceil(RCI4) 
	X := Ceil(RCI1)
	Y := Ceil(RCI2)
	Chars := Ceil(RCI5)
	Lines := Ceil(RCI6)
	DeleteDC(hdc_MeasureText), Gdip_DeleteGraphics(G_MeasureText)
	Return (ReturnMode="X") ? X : (ReturnMode="Y") ? Y :(ReturnMode="W") ? W :(ReturnMode="H") ? H : (ReturnMode="Chars") ? Chars : Lines
}


; Function that allows making applications transparent so they can be hidden completely w/o moving them
FadeApp(title,direction,time:=0){
	startTime := A_TickCount
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		WinSet, Transparent, %t%, %title%
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0) {
			If (direction = "in")
				WinSet, Transparent, Off, %title%
			Break
		}
	}
	RLLog.Info(A_ThisFunc . " - " . (If direction = "out" ? "Hiding Frontend by making it transparent" : "Showing Frontend and removing transparency"))
}

SplitPath(in,Byref outFileName,Byref outPath,Byref outExt,Byref outNameNoExt,Byref outDrive) {
	StringUtils.SplitPath(in,Byref outFileName,Byref outPath,Byref outExt,Byref outNameNoExt,Byref outDrive)
	Return
}

; Converts a relative path to an absolute one
GetFullName(relativePath) {
	Global rlPath
	absPath := RLObject.getFullPathFromRelative(rlPath,relativePath)
	Return absPath
}

; Converts a relative path to an absolute one after providing the base path
AbsoluteFromRelative(basePath, relativePath)
{
	absPath := RLObject.getFullPathFromRelative(basePath,relativePath)
	Return absPath
}

; FileGetVersionInfo_AW which gets file attributes
FileGetVersionInfo_AW( peFile:="", StringFileInfo:="", Delimiter:="|") {
	Static CS, HexVal, Sps="                        ", DLL="Version\"
	If ( CS = "" )
		CS := A_IsUnicode ? "W" : "A", HexVal := "msvcrt\s" (A_IsUnicode ? "w": "" ) "printf"
	If ! FSz := DllCall( DLL "GetFileVersionInfoSize" CS , Str,peFile, UInt,0 )
		Return "", DllCall( "SetLastError", UInt,1 )
	VarSetCapacity( FVI, FSz, 0 ), VarSetCapacity( Trans,8 * ( A_IsUnicode ? 2 : 1 ) )
	DllCall( DLL "GetFileVersionInfo" CS, Str,peFile, Int,0, UInt,FSz, UInt,&FVI )
	If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,"\VarFileInfo\Translation", UIntP,Translation, UInt,0 )
		Return "", DllCall( "SetLastError", UInt,2 )
	If ! DllCall( HexVal, Str,Trans, Str,"%08X", UInt,NumGet(Translation+0) )
		Return "", DllCall( "SetLastError", UInt,3 )
	Loop, Parse, StringFileInfo, %Delimiter%
	{ subBlock := "\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\" A_LoopField
		If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,SubBlock, UIntP,InfoPtr, UInt,0 )
			Continue
		Value := DllCall( "MulDiv", UInt,InfoPtr, Int,1, Int,1, "Str"  )
		Info  .= Value ? ( ( InStr( StringFileInfo,Delimiter ) ? SubStr( A_LoopField Sps,1,24 ) . A_Tab : "" ) . Value . Delimiter ) : ""
	} StringTrimRight, Info, Info, 1
	Return Info
}

GetOSVersion() {
    VarSetCapacity(v,148), NumPut(148,v)
    DllCall("GetVersionEx", "uint", &v)
    ; Return formatted version string similar to A_AhkVersion.
    ; Assume build number will never be more than 4 characters.
    return    NumGet(v,4) ; major
        . "." NumGet(v,8) ; minor
        . "." SubStr("0000" NumGet(v,12), -3) ; build
}

; Returns system paths
; For example, GetCommonPath("LOCAL_APPDATA") will return the full path to yout local appdata folder: C:\Users\NAME\AppData\Local
GetCommonPath(csidl) {
	Static init 
	If !init 
	{
		CSIDL_APPDATA                 := 0x001A     ; Application Data, new for NT4 
		CSIDL_COMMON_APPDATA          := 0x0023     ; All Users\Application Data 
		CSIDL_COMMON_DOCUMENTS        := 0x002e     ; All Users\Documents 
		CSIDL_DESKTOP                 := 0x0010     ; C:\Documents and Settings\username\Desktop 
		CSIDL_FONTS                   := 0x0014     ; C:\Windows\Fonts 
		CSIDL_LOCAL_APPDATA           := 0x001C     ; non roaming, user\Local Settings\Application Data 
		CSIDL_MYMUSIC                 := 0x000d     ; "My Music" folder 
		CSIDL_MYPICTURES              := 0x0027     ; My Pictures, new for Win2K 
		CSIDL_PERSONAL                := 0x0005     ; My Documents 
		CSIDL_PROGRAM_FILES_COMMON    := 0x002b     ; C:\Program Files\Common 
		CSIDL_PROGRAM_FILES           := 0x0026     ; C:\Program Files 
		CSIDL_PROGRAMS                := 0x0002     ; C:\Documents and Settings\username\Start Menu\Programs 
		CSIDL_RESOURCES               := 0x0038     ; %windir%\Resources\, For theme and other windows resources. 
		CSIDL_STARTMENU               := 0x000b     ; C:\Documents and Settings\username\Start Menu 
		CSIDL_STARTUP                 := 0x0007     ; C:\Documents and Settings\username\Start Menu\Programs\Startup. 
		CSIDL_SYSTEM                  := 0x0025     ; GetSystemDirectory() 
		CSIDL_WINDOWS                 := 0x0024     ; GetWindowsDirectory() 
	} 
	val := CSIDL_%csidl% 
	VarSetCapacity(fpath, 256) 
	DllCall("shell32\SHGetFolderPathA", "uint", 0, "int", val, "uint", 0, "int", 0, "str", fpath) 
	Return %fpath% 
}

; StrX function because some modules use it and Pause needs it for XML reading
StrX( H,BS:="",BO:=0,BT:=1,ES:="",EO:=0,ET:=1,ByRef N:="" ) {
	Return SubStr(H,P:=(((Z:=StrLen(ES))+(X:=StrLen(H))+StrLen(BS)-Z-X)?((T:=InStr(H,BS,0,((BO
	 <0)?(1):(BO))))?(T+BT):(X+1)):(1)),(N:=P+((Z)?((T:=InStr(H,ES,0,((EO)?(P+1):(0))))?(T-P+Z
	 +(0-ET)):(X+P)):(X)))-P)
}

HexCompareWrite(file,Pos,Value){
	If (value = "") {
		RLLog.Warning(A_ThisFunc . " - NULL value supplied")
		Return
	}
	curBin := BinRead(file,nvramData,1,Pos)	; read binary
	Bin2Hex(curHex,nvramData,curBin)	; convert to hex
	If (curHex != value) {
		RLLog.Debug(A_ThisFunc . " - Changing " . curHex . " to " . value . " in: " . file)
		Hex2Bin(binData,value)
		BinWrite(file,binData,1,Pos)
	}	
}

; Debug console handler
DebugMessage(str) {
	Global rlTitle,rlVersion
	Static rlDebugConsoleStdout
	If !rlDebugConsoleStdout
		DebugConsoleInitialize(rlDebugConsoleStdout, rlTitle . " v" . rlVersion . " Debug Console")	; start console window if not yet started
	str .= "`n"		; add line feed
	FileAppend %str%, CONOUT$
	; FileAppend  %str%`n, *	; Works with SciTE and similar editors.
	; OutputDebug %str%`n	; Works with Visual Studio and DbgView.
	WinSet, Bottom,, ahk_id %rlDebugConsoleStdout%	; keep console on bottom
}

DebugConsoleInitialize(ByRef handle, title:="") {
	; two calls to open, no error check (it's debug, so you know what you are doing)
	DllCall("AttachConsole", int, -1, int)
	DllCall("AllocConsole", int)

	DllCall("SetConsoleTitle", "str", (If title ? title : a_scriptname))		; Set the title
	handle := DllCall("GetStdHandle", "int", -11)		; get the handle
	WinSet, Bottom,, ahk_id %handle%		; make sure it's on the bottom
	Return
}

;Sends a command to the active window using AHK key names. It will always send down/up keypresses for better compatibility
;A special command {Wait} can be used to force a sleep of the time defined by WaitTime
;WaitCommandOffset will affect all Wait events passed in the Command string by this amount
SendCommand(Command, SendCommandDelay:=2000, WaitTime:=500, WaitBetweenSends:=0, Delay:=50, PressDuration:=-1, WaitCommandOffset:=0) {
	RLLog.Info(A_ThisFunc . " - Started")
	RLLog.Debug(A_ThisFunc . " - Command: " . Command . "`r`n`t`t`t`t`tSendCommandDelay: " . SendCommandDelay . "`r`n`t`t`t`t`tWaitTime: " . WaitTime . "`r`n`t`t`t`t`tWaitBetweenSends: " . WaitBetweenSends . "`r`n`t`t`t`t`tDelay: " . Delay . "`r`n`t`t`t`t`tPressDuration: " . PressDuration . "`r`n`t`t`t`t`tWaitCommandOffset: " . WaitCommandOffset)
	ArrayCount := 0 ;Keeps track of how many items are in the array.
	InsideBrackets := 0 ;If 1 it means the current array item starts with {
	SavedKeyDelay := A_KeyDelay ;Saving previous key delay and setting the new one
	SetKeyDelay, %Delay%, %PressDuration%
	Sleep, %SendCommandDelay% ;Wait before starting to send any command

	If (WaitCommandOffset = "")
		WaitCommandOffset := 0 ;Just to make sure this is always set otherwise wait commands won't work

	;Create an array with each command as an array element
	Loop, % StrLen(Command)
	{	StrValue := SubStr(Command,A_Index,1)
	; {	StringMid, StrValue, Command, A_Index, 1
		If (StrValue != A_Space || InsideBrackets = 1)	; Spaces must be allowed when inside brackets so we can issue {Shift Down} for instance
		{	If (InsideBrackets = 0)
				ArrayCount += 1  
			If (StrValue = "{")
			{	If (InsideBrackets = 1)
					ScriptError("Non-Matching brackets detected in the SendCommand parameter, please correct it")
				Else
					InsideBrackets := 1
			} Else If (StrValue = "}")
			{	If (InsideBrackets = 0)
					ScriptError("Non-Matching brackets detected in the SendCommand parameter, please correct it")
				Else
					InsideBrackets := 0
			}
			Array%ArrayCount% := Array%ArrayCount% . StrValue ;Update the array data
		}
	}

	;Loop through the array and send the commands
	Loop % ArrayCount
	{	element := Array%A_Index%

		If (WaitBetweenSends = 1)
			Sleep, %WaitTime%

		;Particular cases check if the commands already come with down or up suffixes on them and if so send the commands directly without appending Up/Down
		If RegExMatch(element,"i)Down}")
		{	If (element != "{Down}")
			{	Send, %element%
				continue
			}
		}
		Else If RegExMatch(element,"i)Up}")
		{	If (element != "{Up}")
			{	Send, %element%
				Continue
			}
		}
		Else If (element = "{Wait}") ;Special non-ahk tag to issue a sleep
		{	NewWaitTime := WaitTime + WaitCommandOffset
			Sleep, %NewWaitTime%
			Continue
		}
		Else If RegExMatch(element,"i)\{Wait:")
		{	;Wait for a specified amount of time {Wait:xxx}
			; StringMid, NewWaitTime, element, 7, StrLen(element) - 7
			NewWaitTime := SubStr(element,7,StrLen(element) - 7)
			NewWaitTime := NewWaitTime + WaitCommandOffset
			Sleep, %NewWaitTime%
			Continue
		}

		;the rest of the commands, send a keypress with down and up suffixes
		If RegExMatch(element,"}")
		{	StrElement := SubStr(element,1,StrLen(element) - 1)
		; {	StringLeft, StrElement, element, StrLen(element) - 1
			Send, %StrElement% down}%StrElement% up}
		} Else
			Send, {%element% down}{%element% up}
	}
	;Restore key delay values
	SetKeyDelay(SavedKeyDelay, -1)
	RLLog.Info(A_ThisFunc . " - Ended")
}

; Purpose: Tell a ServoStik to transition to 4 or 8-way mode
; Parameters:
; 	direction = Can be 4 or 8, self-explanatory
ServoStik(direction) {
	Global PacDriveDllFile,servoStikEnabled
	RLLog.Info(A_ThisFunc . " - Started")
	Static dllExists
	If !RegExMatch(direction,"4|8")
	{
		RLLog.Warning(A_ThisFunc . " - """ . direction . """ is not a supported direction for ServoSticks. Only 4 and 8 are supported. Leaving your ServoStik as is.")
		Return
	}
	If !dllExists {
		CheckFile(pacDrivedllFile, "Following file is required for RocketLauncher ServoStik support, but could not be found:`n" . pacDrivedllFile)
		dllExists := 1	; do not run this check again
	}
	pacDriveLoadModule := DllCall("LoadLibrary", "Str", PacDriveDllFile)  ; Avoids the need for ahk to load and free the dll's library multiple times
	pacInitialize := DllCall(PacDriveDllFile . "\PacInitialize")	; Initialize all PacDrive, PacLED64 and U-HID Devices and return the amount connected to system
	If !pacInitialize {
		RLLog.Warning(A_ThisFunc . " - No devices found on system")
		RLLog.Info(A_ThisFunc . " - Ended")
		Return
	} Else
		RLLog.Info(A_ThisFunc . " - " . pacInitialize . " devices found on system. If you have multiple devices, this should list more than one and may not specifically mean a ServoStik was found")

	result := DllCall(PacDriveDllFile . "\PacSetServoStik" . direction . "Way")	; Tell ServoStiks to change to desired direction
	If !result
		RLLog.Error(A_ThisFunc . " - There was a problem telling your ServoStik(s) to go " . direction . "-Way")
	Else
		RLLog.Info(A_ThisFunc . " - ServoStik(s) were told to go " . direction . "-Way")
	; pacDriveUnloadModule := DllCall("FreeLibrary", "UInt", pacDriveLoadModule)  ; To conserve memory, the DLL is unloaded after using it.
	RLLog.Info(A_ThisFunc . " - Ended")
}

GetTimeString(time) {
	If (time<0)
		Return time
	If time is not number
		Return time
	Days := time // 86400
	Hours := Mod(time, 86400) // 3600
	Minutes := Mod(time, 3600) // 60
	Seconds := Mod(time, 60)
	If (Days<>0) {
		If Strlen(Hours) = 1
			Hours = 0%Hours%
		If Strlen(Minutes) = 1
			Minutes = 0%Minutes%
		If Strlen(Seconds) = 1
			Seconds = 0%Seconds%
		TimeString = %Days%d %Hours%h %Minutes%m %Seconds%s
	} Else If (Hours<>0) {
		If Strlen(Minutes) = 1
			Minutes = 0%Minutes%
		If Strlen(Seconds) = 1
			Seconds = 0%Seconds%
		TimeString = %Hours%h %Minutes%m %Seconds%s
	} Else If (Minutes<>0) {
		If Strlen(Seconds) = 1
			Seconds = 0%Seconds%
		TimeString = %Minutes%m %Seconds%s
	} Else If (Seconds<>0)
		TimeString = %Seconds%s
	Else
		TimeString := ""
	Return TimeString
}

ReplaceFileNameInvalidChar(ByRef hastack,list,replaceChar){
	Loop, Parse, list, `,
		StringReplace, hastack, hastack, %a_loopfield%, %replaceChar%, All
	Return hastack
}


;-------------------------------------------------------------------------------------------------------------
;-------------------------------------------- RL Media Functions ---------------------------------------------
;-------------------------------------------------------------------------------------------------------------
rndRLMediaLogoPath(assetType){
	Global RLMedia, feMedia, gameInfo
	If !(RLMedia)
		RLMedia := loadRLMediaLogos(gameInfo)
	LogoImageList := []
	for index, element in RLMedia["Logos"]
		If (element.Label)
			If (element.AssetType=assetType)
				Loop, % element.TotalItems    
					LogoImageList.Insert(element["Path" . a_index])
	If !(LogoImageList[1])
		for index, element in feMedia["Logos"]
			If (element.Label)
				If (element.AssetType=assetType)
					Loop, % element.TotalItems    
						LogoImageList.Insert(element["Path" . a_index])
	If (LogoImageList[1]) {   
		Random, RndmLogoImage, 1, % LogoImageList.MaxIndex()
		Return LogoImageList[RndmLogoImage]
    }
}

LoadRLMediaLogos(gameInfoObj){
	Global RLMediaPath, RLMedia, systemname, dbname, romTable, mgCandidate
	RLMedia := {}
	LogoList := "Genre|Rating|Developer|Publisher|Year"
	Loop, Parse, LogoList, |
	{	If (gameInfoObj[A_LoopField].Value){
			%A_LoopField% := gameInfoObj[A_LoopField].Value
			If (A_LoopField = "Genre"){
				ReplaceFileNameInvalidChar(%A_LoopField%,"/,|","\") ;Replacing invalid file name characters by folder separator ("\")
				ReplaceFileNameInvalidChar(%A_LoopField%,"*","-") ;Replacing invalid file name characters by hippens ("-")
			} Else
				ReplaceFileNameInvalidChar(%A_LoopField%,"/,*,|","-") ;Replacing invalid file name characters by hippens ("-")
			ReplaceFileNameInvalidChar(%A_LoopField%,":"," - ") ;Replacing invalid file name characters by hippens ("-")
			ReplaceFileNameInvalidChar(%A_LoopField%,"?," . """" . ",<,>","") ;Replacing invalid file name characters by hippens ("-")
			%A_LoopField% :=RegExReplace(%A_LoopField%,"^\s+|\s+(?=\s)|\s$") ;remove double white spaces
			If (FileExist(RLMediaPath . "\" . A_LoopField . "\" . systemname . "\" . dbname . "\" . %A_LoopField% . ".*"))
				%A_LoopField%Path := RLMediaPath . "\" . A_LoopField . "\" . systemname . "\" . dbname . "\" . %A_LoopField% . ".*"
			Else If (FileExist(RLMediaPath . "\" . A_LoopField . "\" . systemname . "\_Default\" . %A_LoopField% . ".*"))
				%A_LoopField%Path := RLMediaPath . "\" . A_LoopField . "\" . systemname . "\_Default\" . %A_LoopField% . ".*"
			Else
				%A_LoopField%Path := RLMediaPath . "\" . A_LoopField . "\_Default\" . %A_LoopField% . ".*"
		}
	}
	RLMedia.Logos := BuildAssetsTable(GenrePath . "|" . RatingPath . "|" . DeveloperPath . "|" . PublisherPath . "|" . YearPath,"Genre Logo|Rating Logo|Developer Logo|Publisher Logo|Year Logo","genre|rating|developer|publisher|year","png|bmp|gif|jpg|tif") 
	systemLogoPath := RLMediaPath . "\Logos\" . systemname . "\_Default\"
	gameLogoPath1 := RLMediaPath . "\Logos\" . systemname . "\" . dbname . "\"
	;Description name without (Disc X)
	If (!romTable && mgCandidate)
		romTable := CreateRomTable(dbName)
	Totaldiscsofcurrentgame := romTable.MaxIndex()
	If (Totaldiscsofcurrentgame > 1) { 
		DescriptionNameWithoutDisc := romTable[1,4]	
		gameLogoPath2 := RLMediaPath . "\Logos\" . systemname . "\" . DescriptionNameWithoutDisc . "\"
	}
	RLMedia.Logos := BuildAssetsTable(systemLogoPath . "|" . gameLogoPath1 . "|" . gameLogoPath2,"System Logo|Game Logo|Game Logo","system|game|game","png|bmp|gif|jpg|tif",RLMedia.Logos) 
	Return RLMedia
}

; Inject a shared function for Pause and Fade which adjusts the background image positioning
; Usage, params 1-4 are byref so supply the var you want to be filled with the calculated positions and size. Next 2 are the original pics width and height. Last is the position the user wants.
GetBGPicPosition(ByRef retX,ByRef retY,ByRef retW,ByRef retH,w,h,pos){
	Global baseScreenWidth, baseScreenHeight 
	widthMaxPercent := ( baseScreenWidth / w )	; get the percentage needed to maximumise the image so it reaches the screen's width
	heightMaxPercent := ( baseScreenHeight / h )
	If (pos = "Stretch and Lose Aspect") {	; image is stretched to screen, loosing aspect
		retW := baseScreenWidth
		retH := baseScreenHeight
		retX := 0
		retY := 0
	} Else If (pos = "Stretch and Keep Aspect") {	; image is stretched to Center screen, keeping aspect
		percentToEnlarge := If (widthMaxPercent < heightMaxPercent) ? widthMaxPercent : heightMaxPercent	; this basicallys says if the width's max reaches the screen's width first, use the width's percentage instead of the height's
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( baseScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center Width") {	; image is stretched to Center screen's width, keeping aspect
		percentToEnlarge := widthMaxPercent	; increase the image size by the percentage it takes to reaches the screen's width, cropping may occur on top and bottom
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( baseScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center Height") {	; image is stretched to Center screen's height, keeping aspect
		percentToEnlarge := heightMaxPercent	; increase the image size by the percentage it takes to reaches the screen's height, cropping may occur on left and right
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( baseScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center") {	; original image size and aspect
		retX := ( baseScreenWidth / 2 ) - ( w / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( h / 2 )	; find where to place the Y of the image
	} Else If (pos = "Align to Bottom Left") {	; place the pic so the bottom left corner matches the screen's bottom left corner
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retY := baseScreenHeight - retH
	} Else If (pos = "Align to Bottom Right") {	; place the pic so the bottom right corner matches the screen's bottom right corner
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retX := baseScreenWidth - retW
		retY := baseScreenHeight - retH
	} Else If (pos = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retX := baseScreenWidth - retW
	} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
	}
}

; Usage, params 1&2 are byref so supply the var you want to be filled with the calculated positions. Next 4 are the original pics xy,w,h. Last is the position the user wants.
GetFadePicPosition(ByRef retX, ByRef retY,x,y,w,h,pos){
	Global baseScreenWidth, baseScreenHeight 
	If (pos = "Stretch and Lose Aspect"){   ; image is stretched to screen, loosing aspect
		retX := 0
		retY := 0
	} Else If (pos = "Stretch and Keep Aspect")  {	; image is stretched to screen, keeping aspect
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))	
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else If (pos = "Center") {
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else If (pos = "Top Left Corner") {
		retX := 0
		retY := 0
	} Else If (pos = "Top Right Corner") {
		retX := baseScreenWidth - w
		retY := 0
	} Else If (pos = "Bottom Left Corner") {
		retX := 0
		retY := baseScreenHeight - h
	} Else If (pos = "Bottom Right Corner") {
		retX := baseScreenWidth - w
		retY := baseScreenHeight - h
	} Else If (pos = "Top Center") {
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))
		retY := 0
	} Else If (pos = "Bottom Center") {
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))
		retY := baseScreenHeight - h
	} Else If (pos = "Left Center") {
		retX := 0
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else If (pos = "Right Center") {
		retX := baseScreenWidth - w
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else {
		retX := x
		retY := y
	}
}

GetRLMediaFiles(mediaType,supportedFileTypes,returnArray:=0) {
	RLLog.Info(A_ThisFunc . " - Started")
	Global RLMediaPath,dbName,systemName,romTable,mgCandidate
	If (!romTable && mgCandidate)
		romTable:=CreateRomTable(dbName)
	DescriptionNameWithoutDisc := romTable[1,4]
	romFolder := RLMediaPath . "\" . mediaType . "\" . systemName . "\" . dbName . "\"
	romDisckLessFolder := RLMediaPath . "\" . mediaType . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\"
	systemFolder := RLMediaPath . "\" . mediaType . "\" . systemName . "\_Default\"
	globalFolder := RLMediaPath . "\" . mediaType . "\_Default\"
	imagesArray := []
	Loop, Parse, supportedFileTypes, |
		If FileExist(romFolder . "*." . A_LoopField) {
			Loop % romFolder . "*." . A_LoopField
				imagesArray[A_Index] := A_LoopFileFullPath
		}
	If imagesArray.MaxIndex() <= 0
		Loop, Parse, supportedFileTypes, |
			If FileExist(romDisckLessFolder . "*." . A_LoopField) {
				Loop % romDisckLessFolder . "*." . A_LoopField
					imagesArray[A_Index] := A_LoopFileFullPath
			}
	If imagesArray.MaxIndex() <= 0
		Loop, Parse, supportedFileTypes, |
			If FileExist(systemFolder . "*." . A_LoopField) {
				Loop % systemFolder . "*." . A_LoopField
					imagesArray[A_Index] := A_LoopFileFullPath
			}
	If imagesArray.MaxIndex() <= 0 
		Loop, Parse, supportedFileTypes, |
			If FileExist(globalFolder . "*." . A_LoopField) {
				Loop % globalFolder . "*." . A_LoopField
					imagesArray[A_Index] := A_LoopFileFullPath
			}
	If returnArray {
		RLLog.Info(A_ThisFunc . " - Ended, returning array")
		Return imagesArray
	}
	Else {
		Random, RndmImagePic, 1, % imagesArray.MaxIndex()
		picFile := imagesArray[RndmImagePic]
		RLLog.Info(A_ThisFunc . " - Ended, randomized RocketLauncher " . mediaType . " file selected: " . picFile)
		Return picFile
	}
}


;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- DXWnd Functions -----------------------------------------
;-------------------------------------------------------------------------------------------------------------

; If you provide a value, DxwndIniRW assumes you want to write to the ini
; If no value is provided, DxwndIniRW assumes you want to read from the ini and returns the value
; DxwndIniRW is only used to read and write settings to dxwnd.ini
; DxwndRun is for launching dxwnd
; DxwndClose is for closing dxwnd
; DxwndUpdateIniPath is for updating the dxwndIni variable
DxwndIniRW(sec:="",key:="",val:="", default:="", cTarget:="") {
	RLLog.Info(A_ThisFunc . " - Started")
	Global dxwndIni,romName
	Static pos,iniExists
	If !iniExists {
		CheckFile(dxwndIni)
		iniExists := 1	; do not run this check again
	}
	If !pos {	; the current romName or cTarget position has not been found, loop through the ini to find it first
		targetGame := If cTarget ? cTarget : romName
		Loop {
			pos := a_index-1
			IniRead, dxwndName, %dxwndIni%, target, title%pos%
			If (dxwndName = targetGame)
				Break
			If (dxwndName = "ERROR")
				ScriptError("There was a problem finding """ . targetGame . """ in the DXWnd Ini. Please make sure you have added this game to DXWnd before attempting to launch DXWnd through it.")
		}
	}
	errLvl := Process("Exist", "dxwnd.exe")	; Make sure dxwnd is not running first so settings don't get reverted
	If errLvl {
		DxwndClose()
		Process("WaitClose", "dxwnd.exe")
	}
	If val {
		IniWrite, %val%, %dxwndIni%, %sec%, %key%%pos%
		RLLog.Debug(A_ThisFunc . " - Wrote """ . val . """ to game #" . pos)
	} Else {
		IniRead, val, %dxwndIni%, %sec%, %key%%pos%
		RLLog.Debug(A_ThisFunc . " - Read """ . val . """")
		RLLog.Info(A_ThisFunc . " - Ended")
		Return val
	}
	RLLog.Info(A_ThisFunc . " - Ended")
}

DxwndRun(ByRef outPID:="") {
	RLLog.Info(A_ThisFunc . " - Started")
	Global dxwndFullPath,dxwndExe,dxwndPath,dxwndIni
	Static exeExists
	If !exeExists {
		CheckFile(dxwndFullPath, "Following file is required for DXWnd support, but its file could not be found:`n" . dxwndFullPath)
		exeExists := 1	; do not run this check again
	}
	If !dxwndExe
		SplitPath, dxwndFullPath, dxwndExe, dxwndPath
	SplitPath, dxwndIni, dxwndIniFile

	Run(dxwndExe . " /T /C:""" . dxwndIniFile . """", dxwndPath, "Min", outPID)
	errLvl := Process("Wait", dxwndExe, 10)	; waiting 10 seconds for dxwnd to start
	If (errLvl = "")
		ScriptError("DXWnd did not start after waiting for 10 seconds. Please check you can run it manually and try again.")
	Else
		RLLog.Info(A_ThisFunc . " - DxwndRun is now running")
	RLLog.Info(A_ThisFunc . " - Ended")
}

DxwndClose() {
	RLLog.Info(A_ThisFunc . " - Started")
	Global dxwndFullPath,dxwndExe,dxwndPath
	If !dxwndExe
		SplitPath, dxwndFullPath, dxwndExe, dxwndPath
	MessageUtils.PostMessage("0x111", "32810","","","ahk_exe " . dxwndExe)	; this tells dxwnd to close itself
	Process("WaitClose", dxwndExe, 1)	; waits 1 second for dxwnd to close
	errLvl := Process("Exist", dxwndExe)	; checks if dxwnd is still running
	If errLvl
		Process("Close", dxwndExe)	; only needed when RocketLauncher is not ran as admin or RocketLauncher cannot close dxwnd for some reason
	RLLog.Info(A_ThisFunc . " - Ended")
}

DxwndUpdateIniPath() {
	Global dxwndFullPath,dxwndPath,dxwndIni,systemName
	SplitPath,dxwndFullPath,,dxwndPath

	If FileExist( dxwndPath . "\" . systemName . ".ini" )
		dxwndIni := dxwndPath . "\" . systemName . ".ini"
	Else
		dxwndIni := dxwndPath . "\dxwnd.ini"

	RLLog.Info(A_ThisFunc . " - DxwndIni set to " . dxwndIni)
}

;-------------------------------------------------------------------------------------------------------------
;----------------------------------- Cursor Control Functions ------------------------------------
;-------------------------------------------------------------------------------------------------------------

ToggleCursor:
	RLLog.Info(A_ThisLabel . " - Hotkey """ . toggleCursorKey . """ pressed, toggling cursor visibility")
	SystemCursor("Toggle")
Return

; Function to hide/unhide the mouse cursor
SystemCursor(OnOff:=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{	Global mouseCursorHidden
	Static AndMask, XorMask, cursor, h_cursor
		,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
		, b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
		, h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
	If (OnOff = "Init" or OnOff = "I" or cursor = "")	   ; init when requested or at first call
	{
		cursor := "h"	; active default cursors
		VarSetCapacity( h_cursor,4444, 1 )
		VarSetCapacity( AndMask, 32*4, 0xFF )
		VarSetCapacity( XorMask, 32*4, 0 )
		system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
		StringSplit c, system_cursors, `,
		Loop %c0%
		{
			h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
			h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
			b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
				, "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
		}
	}
	If (OnOff = 0 or OnOff = "Off" or cursor = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T")){
		cursor := "b"	; use blank cursors
		RLLog.Info(A_ThisFunc . " - Hiding mouse cursor")
		CoordMode, Mouse	; Also lets move it to the side since some emu's flash a cursor real quick even if we hide it.
		MouseMove, 0, 0, 0
	} Else {
		cursor := "h"	; use the saved cursors
		SPI_SETCURSORS := 0x57	; Emergency restore cursor, just in case something goes wrong
		DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
		mouseCursorHidden := ""
		RLLog.Info(A_ThisFunc . " - Restoring mouse cursor")
	}
	
	Loop %c0%
	{
		h_cursor := DllCall( "CopyImage", "uint",%cursor%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
		DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
	}
}

SetSystemCursor(Cursor:="",cx:=0,cy:=0) {
	BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init

	SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
	,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
	,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
	,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

	If (Cursor = "") ; empty, so create blank cursor
	{
		RLLog.Debug(A_ThisFunc . " - Creating blank cursor")
		VarSetCapacity(AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0)
		BlankCursor := 1 ; flag for later
	}
	Else If (SubStr(Cursor,1,4) = "IDC_") ; load system cursor
	{
		RLLog.Debug(A_ThisFunc . " - Loading system cursor")
		Loop, Parse, SystemCursors, `,
		{
			CursorName := SubStr(A_Loopfield, 6, 15)	; get the cursor name, no trailing space with substr
			CursorID := SubStr(A_Loopfield, 1, 5)	; get the cursor id
			SystemCursor := 1
			If (CursorName = Cursor) {
				CursorHandle := DllCall("LoadCursor", Uint,0, Int,CursorID)
				Break
			}
		}
		If (CursorHandle = "")	; invalid cursor name given
		{
			RLLog.Warning(A_ThisFunc . " - Invalid cursor name supplied: """ . CursorHandle . """")
			; Msgbox,, SetCursor, Error: Invalid cursor name
			CursorHandle := "Error"
		}
	}
	Else If FileExist(Cursor)
	{
		RLLog.Debug(A_ThisFunc . " - Found this cursor: """ . Cursor . """")
		SplitPath, Cursor,,, Ext	; auto-detect type
		If (Ext = "ico")
			uType := 0x1
		Else If RegExMatch("cur|ani","i)" . Ext)
			uType := 0x2
		Else	; invalid file ext
		{
			RLLog.Warning(A_ThisFunc . " - Invalid cursor extension: """ . Ext . """")
			; Msgbox,, SetCursor, Error: Invalid file type
			CursorHandle := "Error"
		}
		FileCursor := 1
	}
	Else
	{
		RLLog.Warning(A_ThisFunc . " - Invalid cursor name or path: """ . Cursor . """")
		; Msgbox,, SetCursor, Error: Invalid file path or cursor name
		CursorHandle := "Error"	; raise for later
	}
	If (CursorHandle != "Error")
	{
		Loop, Parse, SystemCursors, `,
		{
			If (BlankCursor = 1)
			{
				Type := "BlankCursor"
				%Type%%A_Index% := DllCall("CreateCursor", Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask)
				CursorHandle := DllCall("CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0)
				DllCall("SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5))
			}
			Else If (SystemCursor = 1)
			{
				Type := "SystemCursor"
				CursorHandle := DllCall("LoadCursor", Uint,0, Int,CursorID)
				%Type%%A_Index% := DllCall("CopyImage", Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0)
				CursorHandle := DllCall("CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0)
				DllCall("SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5))
			}
			Else If (FileCursor = 1)
			{
				Type := "FileCursor"
				%Type%%A_Index% := DllCall("LoadImage", UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10)
				DllCall("SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5))
			}
		}
	}
}

RestoreCursors() {
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

;-------------------------------------------------------------------------------------------------------------
;------------------ Read and Write Wrapper Functions for IniFileEdit ------------------
;-------------------------------------------------------------------------------------------------------------

; Usage - Read and Write to config files that are not valid inis with [sections], like RetroArch's cfg

; cfgFile - path to the file to read, only need to send this once, it stays in memory until SavePropertiesCfg is used
; Returns a reference number to the array where the cfg is stored in memory so multiple files can be edited at once
LoadProperties(cfgFile) {
	RLLog.Info(A_ThisFunc . " - Started and loading this cfg into memory: " . cfgFile)
	cfgtable := Object()
	Loop, Read, %cfgFile% ; This loop retrieves each line from the file, one at a time.
		cfgtable.Insert(A_LoopReadLine) ; Append this line to the array.
	RLLog.Info(A_ThisFunc . " - Ended")
	Return cfgtable
}

; cfgFile - path to the file to read, only need to send this once, it stays in memory until SavePropertiesCfg is used
; cfgArray - reference number of array in memory that should be saved to the cfgFile
SaveProperties(cfgFile,cfgArray) {
	RLLog.Info(A_ThisFunc . " - Started and saving this cfg to disk: " . cfgFile)
	FileDelete, %cfgFile%
	Loop % cfgArray.MaxIndex()
	{	element := cfgArray[A_Index]
		trimmedElement := LTrim(element)
		finalCfg .= trimmedElement . "`n"
	}
	FileAppend, %finalCfg%, %cfgFile%
	RLLog.Info(A_ThisFunc . " - Ended")
}

; cfgArray - reference number of array in memory that you want to read
; keyName = key whose value you want to read
; Separator = the separator to use, defaults to =
ReadProperty(cfgArray,keyName,Separator:="=") {
	RLLog.Debug(A_ThisFunc . " - Started")
	Loop % cfgArray.MaxIndex()
	{	element := cfgArray[A_Index]
		trimmedElement := Trim(element)
		;MsgBox % "Element number " . A_Index . " is " . element

		StringGetPos, pos, trimmedElement, [
		If (pos = 0)
			Break	; Section was found, do not search anymore, global section has ended

		If element contains %Separator%
		{	StringSplit, keyValues, element, %Separator%
			CfgValue := Trim(keyValues1)
			If (CfgValue = keyName)
				Return Trim(keyValues2)	; Found it & trim any whitespace
		}
	}
	RLLog.Debug(A_ThisFunc . " - Ended")
}

; cfgArray - reference number of array in memory that you want to read
; keyName = key whose value you want to write
; Value = value that you want to write to the keyName
; AddSpaces = If the seperator (=) has spaces on either side, set this parameter to 1 and it will wrap the seperator in spaces
; AddQuotes = If the Value needs to be wrapped in double quotes (like in retroarch's config), set this parameter to 1
; Separator = the separator to use, defaults to =
WriteProperty(cfgArray,keyName,Value,AddSpaces:=0,AddQuotes:=0,Separator:="=") {
	added := 0
	Loop % cfgArray.MaxIndex()
	{	lastIndex := A_Index
		element := cfgArray[A_Index]
		trimmedElement := Trim(element)

		StringGetPos, pos, trimmedElement, [
		If (pos = 0)
		{	lastIndex := lastIndex - 1	; Section was found, do not search anymore
			Break
		}

		If element contains %Separator%
		{	StringSplit, keyValues, element, %Separator%
			CfgValue := Trim(keyValues1)
			If (CfgValue = keyName)
			{	cfgArray[A_Index] := CfgValue . (If AddSpaces=1 ? (" " . Separator . " ") : Separator) . (If AddQuotes=1 ? ("""" . Value . """") : Value)	; Found it
				added := 1
				Break
			}
		}
	}
	If (added = 0)
		cfgArray.Insert(lastIndex+1, keyName . (If AddSpaces=1 ? (" " . Separator . " ") : Separator) . (If AddQuotes=1 ? ("""" . Value . """") : Value))	; Add the new entry to the file
	RLLog.Debug(A_ThisFunc . " - Writing - " . keyName . ": " . value)
}

;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- Player Select Menu --------------------------------------
;-------------------------------------------------------------------------------------------------------------

; function to create a small menu with the number of players option
NumberOfPlayersSelectionMenu(maxPlayers:=4) {
	Global screenRotationAngle,baseScreenWidth,baseScreenHeight,xTranslation,yTranslation
	Global navSelectKey,navUpKey,navDownKey,navP2SelectKey,navP2UpKey,navP2DownKey,exitEmulatorKey,exitEmulatorKey
	Global keymapper,keymapperEnabled,keymapperRocketLauncherProfileEnabled
	If !pToken
		pToken := Gdip_Startup()
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
	Loop, 2 {
		Gui, playersMenu_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Gui, playersMenu_GUI%A_Index%: Margin,0,0
		Gui, playersMenu_GUI%A_Index%: Show,, playersMenuLayer%A_Index%
		playersMenu_hwnd%A_Index% := WinExist()
		playersMenu_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		playersMenu_hdc%A_Index% := CreateCompatibleDC()
		playersMenu_obm%A_Index% := SelectObject(playersMenu_hdc%A_Index%, playersMenu_hbm%A_Index%)
		playersMenu_G%A_Index% := Gdip_GraphicsFromhdc(playersMenu_hdc%A_Index%)
		Gdip_SetSmoothingMode(playersMenu_G%A_Index%, 4)
		Gdip_TranslateWorldTransform(playersMenu_G%A_Index%, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(playersMenu_G%A_Index%, screenRotationAngle)
	}
	;Initializing parameters
	playersMenuTextFont := "Bebas Neue" 
	CheckFont(playersMenuTextFont)
	playersMenuSelectedTextSize := 50
	playersMenuSelectedTextColor := "FFFFFFFF"
	playersMenuDisabledTextColor := "FFAAAAAA"
	playersMenuDisabledTextSize := 30
	playersMenuMargin := 50
	playersMenuSpaceBtwText := 30
	playersMenuCornerRadius := 10
	;menu scalling factor
	XBaseRes := 1920, YBaseRes := 1080
    If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
        XBaseRes := 1080, YBaseRes := 1920
    If !playersMenuXScale 
		playersMenuXScale := baseScreenWidth/XBaseRes
    If !playersMenuYScale
		playersMenuYScale := baseScreenHeight/YBaseRes
	OptionScale(playersMenuSelectedTextSize, playersMenuYScale)
	OptionScale(playersMenuDisabledTextSize, playersMenuYScale)
	OptionScale(playersMenuMargin, playersMenuXScale)
	OptionScale(playersMenuSpaceBtwText, playersMenuYScale)
	OptionScale(playersMenuCornerRadius, playersMenuXScale)	
	playersMenuW := MeasureText("X Players", "Left r4 s" . playersMenuSelectedTextSize . " Bold",playersMenuTextFont) + 2*playersMenuMargin
	playersMenuH := maxPlayers*playersMenuSelectedTextSize + (maxPlayers-1)*playersMenuSpaceBtwText + 2*playersMenuMargin
	playersMenuX := (baseScreenWidth-playersMenuW)//2
	playersMenuY := (baseScreenHeight-playersMenuH)//2
	playersMenuBackgroundBrush := Gdip_BrushCreateSolid("0xDD000000")
	pGraphUpd(playersMenu_G1,playersMenuW,playersMenuH)
	pGraphUpd(playersMenu_G2,playersMenuW,playersMenuH)
	;Drawing Background
	Gdip_Alt_FillRoundedRectangle(playersMenu_G1, playersMenuBackgroundBrush, 0, 0, playersMenuW, playersMenuH,playersMenuCornerRadius)
	Alt_UpdateLayeredWindow(playersMenu_hwnd1, playersMenu_hdc1, playersMenuX, playersMenuY, playersMenuW, playersMenuH)
    ;Drawing choice list   
	SelectedNumberofPlayers := 1
	gosub, DrawPlayersSelectionMenu
	;Enabling Keys
	If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true")
        RunKeymapper%zz%("menu",keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("menu")
	Gosub, EnablePlayersMenuKeys
	LEDBlinky("RL")	; trigger ledblinky profile change if enabled
	;Waiting for menu to exit
	Loop
	{	If PlayersMenuExit
			Break
		Sleep, 100
	}
	LEDBlinky("ROM")	; trigger ledblinky profile change if enabled
	Return SelectedNumberofPlayers
	;labels to treat menu changes
	DrawPlayersSelectionMenu:
		currentY := 0
		Gdip_GraphicsClear(playersMenu_G2)
		Loop, % maxPlayers
		{
			If (a_index=SelectedNumberofPlayers) {
				currentTextSize := playersMenuSelectedTextSize
				currentTextColor := playersMenuSelectedTextColor
				currentTextStyle := "bold"
			} Else {
				currentTextSize := playersMenuDisabledTextSize
				currentTextColor := playersMenuDisabledTextColor
				currentTextStyle := "normal"
			}
			If (a_index=1)
				currentText := "1 Player"
			Else
				currentText := a_index . " Players"
			currentY := playersMenuMargin + (a_index-1)*(playersMenuSelectedTextSize+playersMenuSpaceBtwText)+(playersMenuSelectedTextSize-currentTextSize)//2
			Gdip_Alt_TextToGraphics(playersMenu_G2, currentText, "x0 y" . currentY . " Center c" . currentTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, playersMenuTextFont, playersMenuW, playersMenuSelectedTextSize)
		}
		Alt_UpdateLayeredWindow(playersMenu_hwnd2, playersMenu_hdc2, playersMenuX, playersMenuY, playersMenuW, playersMenuH)
	Return
	EnablePlayersMenuKeys:
		XHotKeywrapper(navSelectKey,"PlayersMenuSelect","ON") 
		XHotKeywrapper(navUpKey,"PlayersMenuUP","ON")
		XHotKeywrapper(navDownKey,"PlayersMenuDown","ON")
		XHotKeywrapper(navP2SelectKey,"PlayersMenuSelect","ON") 
		XHotKeywrapper(navP2UpKey,"PlayersMenuUP","ON")
		XHotKeywrapper(navP2DownKey,"PlayersMenuDown","ON")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
		XHotKeywrapper(exitEmulatorKey,"ClosePlayersMenu","ON")
	Return
	DisablePlayersMenuKeys:
		XHotKeywrapper(navSelectKey,"PlayersMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"PlayersMenuUP","OFF")
		XHotKeywrapper(navDownKey,"PlayersMenuDown","OFF")
		XHotKeywrapper(navP2SelectKey,"PlayersMenuSelect","OFF") 
		XHotKeywrapper(navP2UpKey,"PlayersMenuUP","OFF")
		XHotKeywrapper(navP2DownKey,"PlayersMenuDown","OFF")
		XHotKeywrapper(exitEmulatorKey,"ClosePlayersMenu","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
	Return
	PlayersMenuUP:
		SelectedNumberofPlayers--
		If (SelectedNumberofPlayers<1)
			SelectedNumberofPlayers:=maxPlayers
		gosub, DrawPlayersSelectionMenu
	Return
	PlayersMenuDown:
		SelectedNumberofPlayers++
		If (SelectedNumberofPlayers>maxPlayers)
			SelectedNumberofPlayers:=1
		gosub, DrawPlayersSelectionMenu
	Return
	ClosePlayersMenu:
		ClosedPlayerMenu := true
	PlayersMenuSelect:
		Gosub, DisablePlayersMenuKeys
		Gdip_DeleteBrush(playersMenuBackgroundBrush)
		Loop, 2 {
			SelectObject(playersMenu_hdc%A_Index%, playersMenu_obm%A_Index%)
			DeleteObject(playersMenu_hbm%A_Index%)
			DeleteDC(playersMenu_hdc%A_Index%)
			Gdip_DeleteGraphics(playersMenu_G%A_Index%)
			Gui, playersMenu_GUI%A_Index%: Destroy
		}
		If ClosedPlayerMenu
		{	RLLog.Info(A_ThisLabel . "User cancelled the launch at the Player Select Menu")
			PlayersMenuExit := true
			ExitModule()
		} Else
			RLLog.Info(A_ThisLabel . "Number of Players Selected: " . SelectedNumberofPlayers)
		If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true")
			RunKeymapper%zz%("load", keymapper)
		If keymapperAHKMethod = External
			RunAHKKeymapper%zz%("load")
		PlayersMenuExit := true
	Return
}


;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- HideApp Functions ---------------------------------------
;-------------------------------------------------------------------------------------------------------------

;vars in HideApp object
WinTitle := ""
ExcludeTitle := ""
HideMethod := ""
HideStatus := ""

HideAppStart(ByRef hideObj, enabled:="", ms:=2)
{
	If (enabled && enabled != "false")
	{
		RLLog.Info(A_ThisFunc . " - Starting HideAppTimer, scanning for windows defined every " . ms . "ms")
		; First rebuild the single line object into a better one that's easier to track and work with
		newObject := Object()
		For windowObj, HideMethod in hideObj	; enumerate through each window object supplied and create new object with only required parameters
		{	currentObj++
			newObject[currentObj,"WinTitle"] := windowObj.WinTitle.GetWindowTitle()
			newObject[currentObj,"ExcludeTitle"] := windowObj.ExcludeTitle
			newObject[currentObj,"HideMethod"] := HideMethod
			newObject[currentObj,"HideStatus"] := ""	; default is 0 (0 = not hidden yet, 1 = hidden already)
			; msgbox % "HideAppStart`nWinTitle: " . windowObj.WinTitle . "`nHideMethod: " . HideMethod
		}
		; msgbox % "HideAppStart`nWinTitle: " . newObject[1].WinTitle . "`nHideMethod: " . newObject[1].HideMethod
		hideObj := newObject	; overwrite hideObj with the updated one that will be tracked
		; SetTimer, timerFunction, %ms%
		; this.SetTimerF("timerFunction",ms,Object(1,hideObj),10) ;create a higher priority timer
		; TimerUtils.SetTimerF("WindowUtils.HideAppTimer",ms,Object(1,hideObj),10)	; create a high priority timer
		TimerUtils.SetTimerF("HideAppTimer",ms,Object(1,hideObj),10)	; create a high priority timer
		; SetTimerF("HideAppTimer",ms,Object(1,hideObj),10)	; create a high priority timer
		RLLog.Info(A_ThisFunc . " - Ended")
	}
}

HideAppEnd(ByRef hideObj, enabled:="")
{
	If (hideObj && enabled && enabled != "false")
	{
		RLLog.Info(A_ThisFunc . " - Stopping HideAppTimer and unhiding flagged windows")
		; TimerUtils.SetTimerF("WindowUtils.HideAppTimer","off")
		TimerUtils.SetTimerF("HideAppTimer","off")
		; SetTimerF("HideAppTimer","off")
		Loop % hideObj.MaxIndex()
		{
			If (hideObj[A_Index,"HideMethod"] && hideObj[A_Index,"HideStatus"]) { 	; if one of the windows was hidden and needs to be unhidden
				WinSet, Transparent, Off, % hideObj[A_Index,"WinTitle"]
				RLLog.Info(A_ThisFunc . " - Revealed window: """ . hideObj[A_Index,"WinTitle"] . """")
			}
		}
		RLLog.Info(A_ThisFunc . " - Ended")
	}
}

HideAppTimer(ByRef obj)
{
	Static timerIndex
	Loop % obj.MaxIndex()
	{
		If !obj[A_Index,"HideStatus"]
		{
			If (A_DetectHiddenWindows != "On") {
				RLLog.Debug(A_ThisFunc . " - Turning on DetectHiddenWindows window as it's needed to hide apps")
				MiscUtils.DetectHiddenWindows("On")
			}
			If WinExist(obj[A_Index,"WinTitle"])
			{
				timerIndex++
				WinSet, Transparent, 0, % obj[A_Index,"WinTitle"]
				RLLog.Debug(A_ThisFunc . " - Trying to hide window [" . timerIndex . "]: """ . obj[A_Index,"WinTitle"] . """")
				WinGet, currentTran, Transparent, % obj[A_Index,"WinTitle"]
				If (currentTran = 0)
					obj[A_Index,"HideStatus"] := 1	; update object that this window is now hidden
			}
		}
	}
	Return
}

SetTimerF( Function, Period:=0, ParmObject:=0, Priority:=0 ) {
	Static current,tmrs:=[] ;current will hold timer that is currently running
	If IsFunc( Function ) {
		If IsObject(tmr:=tmrs[Function]) ;destroy timer before creating a new one
			ret := DllCall( "KillTimer", UInt,0, PTR, tmr.tmr)
			, DllCall("GlobalFree", PTR, tmr.CBA)
			, tmrs.Remove(Function) 
		If (Period = 0 || Period = "off")
			Return ret ;Return as we want to turn off timer
		; create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
		tmr:=tmrs[Function]:={func:Function,Period:Period="on" ? 250 : Period,Priority:Priority
								,OneTime:Period<0,params:IsObject(ParmObject)?ParmObject:Object()
								,Tick:A_TickCount}
		tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
		Return !!(tmr.tmr  := DllCall("SetTimer", PTR,0, PTR,0, UInt
								, (Period && Period!="On") ? Abs(Period) : (Period := 250)
								, PTR,tmr.CBA,"PTR")) ;Create Timer and return true if a timer was created
								, tmr.Tick:=A_TickCount
	}
	tmr := Object(A_EventInfo) ;A_Event holds object which contains timer information
	If IsObject(tmr) {
		DllCall("KillTimer", PTR,0, PTR,tmr.tmr) ;deactivate timer so it does not run again while we are processing the function
		If (current && tmr.Priority<current.priority) ;Timer with higher priority is already current so return
			Return (tmr.tmr:=DllCall("SetTimer", PTR,0, PTR,0, UInt, 100, PTR,tmr.CBA,"PTR")) ;call timer again asap
		current:=tmr
		,tmr.tick:=ErrorLevel :=Priority ;update tick to launch function on time
		,tmr.func(tmr.params*) ;call function
		If (tmr.OneTime) ;One time timer, deactivate and delete it
			Return DllCall("GlobalFree", PTR,tmr.CBA)
		,tmrs.Remove(tmr.func)
		tmr.tmr:= DllCall("SetTimer", PTR,0, PTR,0, UInt ;reset timer
		,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), PTR,tmr.CBA,"PTR")
		current:="" ;reset timer
	}
}

;-----	BEING REMOVED ONCE ALL MODULES UPDATED TO USE HIDEAPP -----
; Default is 2ms so it picks up windows as soon as possible
HideEmuStart(ms:=2) {
	Global hideEmu,hideEmuObj
	If (hideEmu = "true")
	{	RLLog.Info(A_ThisFunc . " - Starting HideEmuTimer, scanning for windows defined in hideEmuObj every " . ms . "ms")
		; First rebuild the single line object into a better one that's easier to track and work with
		newObject := Object()
		For key, value in hideEmuObj
		{	currentObj++
			newObject[currentObj,"window"] := key
			newObject[currentObj,"method"] := value
			newObject[currentObj,"status"] := ""	; default is 0 (0 = not hidden yet, 1 = hidden already)
		}
		hideEmuObj := newObject	; overwrite hideEmuObj with the updated one
		; SetTimer, HideEmuTimer, %ms%
		SetTimerF("HideEmuTimer",ms,Object(1,hideEmuObj),10) ;create a higher priority timer
		RLLog.Info(A_ThisFunc . " - Ended")
	}
}

HideEmuEnd() {
	Global hideEmu
	Global hideEmuObj
	ToolTip
	If (hideEmu = "true")
	{	RLLog.Info(A_ThisFunc . " - Stopping HideEmuTimer and unhiding flagged windows")
		; SetTimer, HideEmuTimer, Off
		SetTimerF("HideEmuTimer","off")
		For key, value in hideEmuObj
			If (hideEmuObj[A_Index,"method"] && hideEmuObj[A_Index,"status"]) { 	; if one of the windows was hidden and needs to be unhidden
				WinSet, Transparent, Off, % hideEmuObj[A_Index,"window"]
				RLLog.Info("HideEmu - Revealed window: " . hideEmuObj[A_Index,"window"])
			}
		RLLog.Info(A_ThisFunc . " - Ended")
	}
}

; HideEmuTimer(ByRef obj) {
	; RLLog.Debug("HideEmuTimer - running")
	; For key, value in obj
	; {
		; If !obj[A_Index,"status"]
		; {	If (A_DetectHiddenWindows != "On")
				; MiscUtils.DetectHiddenWindows("On")
			; If WinExist(obj[A_Index,"window"])
			; {	WinSet, Transparent, 0, % obj[A_Index,"window"]
				; RLLog.Debug("HideEmu - Found a new window to hide: " . obj[A_Index,"window"])
				; WinGet, currentTran, Transparent, % obj[A_Index,"window"]
				; If (currentTran = 0)
					; obj[A_Index,"status"] := 1	; update object that this window is now hidden
			; }
		; }
	; }
	; Return
; }
HideEmuTimer(ByRef obj) {
	For key, value in obj
	{
		If !obj[A_Index,"HideStatus"]
		{	If (A_DetectHiddenWindows != "On")
				MiscUtils.DetectHiddenWindows("On")
			If WinExist(obj[A_Index,"WinTitle"])
			{	WinSet, Transparent, 0, % obj[A_Index,"WinTitle"]
				RLLog.Debug(A_ThisFunc . " - Found a new window to hide: " . obj[A_Index,"WinTitle"])
				WinGet, currentTran, Transparent, % obj[A_Index,"WinTitle"]
				If (currentTran = 0)
					obj[A_Index,"HideStatus"] := 1	; update object that this window is now hidden
			}
		}
	}
	Return
}

; Legacy label version
HideEmuTimer:
	For key, value in hideEmuObj
	{	If !hideEmuObj[A_Index,"status"]
		{	If (A_DetectHiddenWindows != "On")
				MiscUtils.DetectHiddenWindows("On")
			; msgbox % hideEmuObj[A_Index,"window"]
			If WinExist(hideEmuObj[A_Index,"window"])
			{	WinSet, Transparent, 0, % hideEmuObj[A_Index,"window"]
				RLLog.Debug(A_ThisLabel . " - Found a new window to hide: " . hideEmuObj[A_Index,"window"],4)
				WinGet, currentTran, Transparent, % hideEmuObj[A_Index,"window"]
				If (currentTran = 0)
					hideEmuObj[A_Index,"status"] := 1	; update object that this window is now hidden
			}
		}
	}
Return


;-------------------------------------------------------------------------------------------------------------
;---------------------------------------- Decryption Functions -------------------------------------
;-------------------------------------------------------------------------------------------------------------

Decrypt(T,key)                   ; Text, key-name
{
   Local p, i, L, u, v, k5, a, c

   StringLeft p, T, 8
   If p is not xdigit            ; if no IV: Error
   {
      ErrorLevel := 1
      Return
   }
   StringTrimLeft T, T, 8        ; remove IV from text (no separator)
   k5 = 0x%p%                    ; set new IV
   p := 0                        ; counter to be Encrypted
   i := 9                        ; pad-index, force restart
   L := ""                       ; processed text
   k0 := %key%0
   k1 := %key%1
   k2 := %key%2
   k3 := %key%3
   Loop % StrLen(T)
   {
      i++
      IfGreater i,8, {           ; all 9 pad values exhausted
         u := p
         v := k5                 ; IV
         p++                     ; increment counter
         TEA(u,v, k0,k1,k2,k3)
         Stream9(u,v)            ; 9 pads from Encrypted counter
         i := 0
      }
      StringMid c, T, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                          ; chars > 126 or < 31 unchanged
         a -= s%i%
         IfLess a, 32, SetEnv, a, % a+95
         c := Chr(a)
      }
      L := L . c                 ; attach Encrypted character
   }
   Return L
}

TEA(ByRef y,ByRef z,k0,k1,k2,k3) ; (y,z) = 64-bit I/0 block
{                                ; (k0,k1,k2,k3) = 128-bit key
   IntFormat := A_FormatInteger
   SetFormat Integer, D          ; needed for decimal indices
   s := 0
   d := 0x9E3779B9
   Loop 32
   {
      k := "k" . s & 3           ; indexing the key
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
   SetFormat Integer, %IntFormat%
   y += 0
   z += 0                        ; Convert to original ineger format
}

Stream9(x,y)                     ; Convert 2 32-bit words to 9 pad values
{                                ; 0 <= s0, s1, ... s8 <= 94
   Local z                       ; makes all s%i% global
   s0 := Floor(x*0.000000022118911147) ; 95/2**32
   Loop 8
   {
      z := (y << 25) + (x >> 7) & 0xFFFFFFFF
      y := (x << 25) + (y >> 7) & 0xFFFFFFFF
      x := z
      s%A_Index% := Floor(x*0.000000022118911147)
   }
}


;-------------------------------------------------------------------------------------------------------------
;------------------------------------ Registry Access Functions ----------------------------------
;-------------------------------------------------------------------------------------------------------------

RegRead(RootKey, SubKey, ValueName := "", RegistryVersion:="32")
{	Global winVer
	RLLog.Info(A_ThisFunc . " - Reading from Registry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",RegistryVersion=" . RegistryVersion)
        If (RegistryVersion = "Auto") ;Try finding the correct registry reading based on the windows version
        {
            If (winVer = "64")
                If !OutputVar := RegRead(RootKey, SubKey, ValueName, "64")
                OutputVar := RegRead(RootKey, SubKey, ValueName, "32")
            Else
                OutputVar := RegRead(RootKey, SubKey, ValueName)
        }
	Else If (RegistryVersion = "32")
		RegRead, OutputVar, %RootKey%, %SubKey%, %ValueName%
	Else
		OutputVar := RegRead64(RootKey, SubKey, ValueName)
	RLLog.Info(A_ThisFunc . " - Registry Read finished, returning " . OutputVar)
	Return OutputVar
}

RegWrite(ValueType, RootKey, SubKey, ValueName := "", Value := "", RegistryVersion:="32")
{
	RLLog.Info(A_ThisFunc . " - Writing to Registry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",Value=" . Value . ",ValueType=" . ValueType . ",RegistryVersion=" . RegistryVersion)
	If (RegistryVersion = "32")
		RegWrite, %ValueType%, %RootKey%, %SubKey%, %ValueName%, %Value%
	Else
		RegWrite64(ValueType, RootKey, SubKey, ValueName, Value)
	RLLog.Info(A_ThisFunc . " - Registry Write finished")
}

;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- Display Resolution Functions ----------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Grab current display settings for each monitor
; Returns object:
;	obj[#] = Display Number
;	obj[#].Name = Display's Name as known in windows. Ex: \\.\DISPLAY1
;	obj[#].Width = Display's Width
;	obj[#].Height = Display's Height
;	obj[#].BitDepth = Display's BitDepth
;	obj[#].Frequency = Display's Frequency
;	obj[#].Orientation = Display's Orientation
;	obj[#].Left = Where this display's Left position starts
;	obj[#].Right = Where this display's Right position ends
;	obj[#].Top = Where this display's Top position starts
;	obj[#].Bottom = Where this display's Bottom position ends
;	obj[#].WorkingWidth = Display's Working Width. This is the usable space w/o the task bar
;	obj[#].WorkingHeight = Display's Working Height
GetDisplaySettings() {
	obj := Object()
	monOrientation := Object(0,"Landscape",1,"Portrait",2,"Landscape (Flipped)",3,"Portrait (Flipped)")
	getDisplaySettingsObj := Object(1,"Width",2,"Height",3,"BitDepth",4,"Frequency",5,"Orientation")
	SysGet, MonitorCount, 80	; MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	Loop, %MonitorCount% ; get each monitor's stats for the log
	{
		SysGet, MonitorName, MonitorName, %A_Index%
		SysGet, Monitor, Monitor, %A_Index%
		SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
		currentobj:={}
		currentobj.Number := A_Index		; this is the monitor #, an integer
		currentobj.Name := MonitorName		; store monitor's name as it is known as in Windows
		monDetails := RLObject.getDisplaySettings(MonitorName)	; return 0 if something went wrong, like an invalid displayName is passed. Otherwise it returns a string with this format "width|height|bits|frequency|orientation"
		Loop, Parse, monDetails, |
			currentObj[getDisplaySettingsObj[A_Index]] := A_LoopField	; parse RLObject's return and store into the object
		currentobj.Orientation := monOrientation[currentobj.Orientation]		; replace orientation integer with name from object instead
		currentobj.Left := MonitorLeft		; store where this monitor's Left position starts
		currentobj.Right := MonitorRight	; store where this monitor's Right position ends
		currentobj.Top := MonitorTop		; store where this monitor's Top position starts
		currentobj.Bottom := MonitorBottom	; store where this monitor's Bottom position ends
		currentobj.WorkingWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft		; store this monitor's working width
		currentobj.WorkingHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop		; store this monitor's working height
		obj.Insert(currentobj["Number"], currentobj)
		RLLog.Debug(A_ThisFunc . " - Monitor #" . A_Index . " (" . MonitorName . "): " . MonitorRight - MonitorLeft . "x" . MonitorBottom - MonitorTop . " (" . MonitorWorkAreaRight - MonitorWorkAreaLeft . "x" . MonitorWorkAreaBottom - MonitorWorkAreaTop . " work) [" . currentobj.BitDepth . "bit] [" . currentobj.Frequency . "hz] [" . currentobj.Orientation . "] " . (If MonitorPrimary = A_Index ? " (Primary)" : ""))
	}
	Return obj
}

; This function will take the | delimited user settings from theses places:
; A) RLUI for all monitor/resolution settings and break it apart so it can be used in the various display functions then sent to the DLL
; B) Module when called to change the display setting(s)
; It supports multiple monitors and parameters for each
; array = | delimted string in this order where each monitor is delimted by ; monNumber|monWidth|monHeight|monBitDepth|monFrequency
; Example = 1|1600|1200|32|60&2|1024|768|32|60
ConvertToMonitorObject(array) {
	Global monitorTable
	displaySettingsObj := Object(1,"Name",2,"Width",3,"Height",4,"BitDepth",5,"Frequency")
	obj := Object()
	Loop, Parse, array, &
	{
		currentobj:={}
		currentobj.Number := A_Index	; this is the monitor #, an integer
		Loop, Parse, A_LoopField, |
		{
			If !A_LoopField {
				RLLog.Error(A_ThisFunc . " - " . displaySettingsObj[A_Index] . " not supplied in array. Object creation terminated.")
				Return
			}
			currentobj[displaySettingsObj[A_Index]] := If displaySettingsObj[A_Index] = "Name" && !InStr(A_LoopField,"DISPLAY") ? "\\.\DISPLAY" . A_LoopField : A_LoopField
		}
		obj.Insert(currentobj["Number"], currentobj)
	}
	Return obj
}

; Handle the supplied object by first checking if parameters are supported by the monitor, then setting them.
; This is the function that will be called in features and modules to change display settings.
SetDisplaySettings(monObj) {
	Global monitorTable
	RLLog.Info(A_ThisFunc . " - Started")
	currentMon := GetDisplaySettings()	; get current parameters to see if res needs to be changed or it can be skipped
	Loop % monObj.MaxIndex()
	{
		; msgbox % "SetDisplaySettings`n`nobj[" . A_Index . "].Name: " . monObj[A_Index].Name . "`nobj.Width: " . monObj[A_Index].Width . "`nobj.Height: " . monObj[A_Index].Height . "`nobj.BitDepth: " . monObj[A_Index].BitDepth . "`nobj.Frequency: " . monObj[A_Index].Frequency
		x := CheckDisplaySettings(monObj[A_Index].Name,monObj[A_Index].Width,monObj[A_Index].Height,monObj[A_Index].BitDepth,monObj[A_Index].Frequency)
		If x {
			If ((monObj[A_Index].Width = currentMon[A_Index].Width) && (monObj[A_Index].Height = currentMon[A_Index].Height) && (monObj[A_Index].BitDepth = currentMon[A_Index].BitDepth) && (monObj[A_Index].Frequency = currentMon[A_Index].Frequency)) {
				RLLog.Info(A_ThisFunc . " - Not changing " . monObj[A_Index].Name . " as it is already set to " . monObj[A_Index].Width . "x" . monObj[A_Index].Height . " " . monObj[A_Index].BitDepth . "bit " . monObj[A_Index].Frequency . "hz")
			} Else {
				RLLog.Info(A_ThisFunc . " - Changing " . monObj[A_Index].Name . " to " . monObj[A_Index].Width . "x" . monObj[A_Index].Height . " " . monObj[A_Index].BitDepth . "bit " . monObj[A_Index].Frequency . "hz")
				ChangeDisplaySettings(monObj[A_Index].Name,monObj[A_Index].Width,monObj[A_Index].Height,monObj[A_Index].BitDepth,monObj[A_Index].Frequency)
				; Update monitorTable with new settings so it stays current
				SysGet, Monitor, Monitor, %A_Index%
				SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
				monitorTable[A_Index].Width := monObj[A_Index].Width
				monitorTable[A_Index].Height := monObj[A_Index].Height
				monitorTable[A_Index].BitDepth := monObj[A_Index].BitDepth
				monitorTable[A_Index].Frequency := monObj[A_Index].Frequency
				monitorTable[A_Index].Left := MonitorLeft
				monitorTable[A_Index].Right := MonitorRight
				monitorTable[A_Index].Top := MonitorTop
				monitorTable[A_Index].Bottom := MonitorBottom
				monitorTable[A_Index].WorkingWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
				monitorTable[A_Index].WorkingHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
			}
		} Else
			RLLog.Warning(A_ThisFunc . " - " . monObj[A_Index].Name . " does not support " . monObj[A_Index].Width . "x" . monObj[A_Index].Height . " " . monObj[A_Index].BitDepth . "bit " . monObj[A_Index].Frequency . "hz")
	}
	RLLog.Info(A_ThisFunc . " - Ended")
}

; Change screen resolution to supplied parameters
; Do not call this function directly, allow SetDisplaySettings to handle it
; n = Display Name
; w = Screen Width
; h = Screen Height
; b = Bit Depth
; f = Frequency
ChangeDisplaySettings(n,w,h,b,f) {
	Return RLObject.changeDisplaySettings(n,w,h,b,f)
}

; Check monitor if it can support the screen parameters supplied
; Do not call this function directly, allow SetDisplaySettings to handle it
; Use this before calling ChangeDisplaySettings
; n = Display Name
; w = Screen Width
; h = Screen Height
; b = Bit Depth
; f = Frequency
CheckDisplaySettings(n,w,h,b,f) {
	Return RLObject.checkDisplaySettings(n,w,h,b,f)
}

; http://www.autohotkey.com/forum/topic8355.html
; ChangeDisplaySettings( sW, sH, cD, rR ) { ; Change Screen Resolution
	; VarSetCapacity(dM,156,0), NumPut(156,dM,36)
	; DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&dM ), NumPut(0x5c0000,dM,40)
	; NumPut(cD,dM,104),  NumPut(sW,dM,108),  NumPut(sH,dM,112),  NumPut(rR,dM,120)
	; Return DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
; }

; Acquire display "index" screen resolution (index=0,1,...)
; GetDisplaySettings(Index) {
	; VarSetCapacity(device_mode,156,0)
	; success:=DllCall("EnumDisplaySettings","uint",0,"uint",Index-1,"uint",&device_mode)
	; If (ErrorLevel or !success)
		; Return "Break"
	; Out_1:=NumGet(&device_mode,108,"uint4")	;width
	; Out_2:=NumGet(&device_mode,112,"uint4")	;height
	; Out_3:=NumGet(&device_mode,104,"uint4")	;quality
	; Out_4:=NumGet(&device_mode,120,"uint4")	;frequency
	; Return Out_1 "|" Out_2 "|" Out_3 "|" Out_4
; } ; out "Break"

; Acquire current display screen resolution (1=width	2=height	3=quality	4=frequency)
; CurrentDisplaySettings(in:=0) {
	; VarSetCapacity(device_mode,156,0),NumPut(156,2,&device_mode,36)
	; success := DllCall("EnumDisplaySettings","uint",0,"uint",-1,"uint",&device_mode)
	; Out_1:=NumGet(&device_mode,108,"uint4")	;width
	; Out_2:=NumGet(&device_mode,112,"uint4")	;height
	; Out_3:=NumGet(&device_mode,104,"uint4")	;quality
	; Out_4:=NumGet(&device_mode,120,"uint4")	;frequency
	; If in = 0
		; Return Out_1 "|" Out_2 "|" Out_3 "|" Out_4
	; Else Return (Out_%in%)
; }

; Check if a given screen resolution is supported by the monitor, and if not, choose the nearest one that is
; desiredResTable uses the object defined by ConvertToMonitorObject 
CheckForNearestSupportedRes(monNumber,desiredResTable){
	RLLog.Info(A_ThisFunc . " - Started")
	If !desiredResTable {
		RLLog.Error(A_ThisFunc . " - Supplied desired resolution does not contain any data.")
		Return
	}
	listOfSupportedRes := EnumDisplaySettings(monNumber)
	If !listOfSupportedRes
	{	RLLog.Error(A_ThisFunc . " - Ended, was supplied a monitor number that is not attached to this system: " . monNumber)
		Return
	}
	If RegExMatch(listOfSupportedRes, "i)" desiredResTable[monNumber].Width . "\|" . desiredResTable[monNumber].Height . "\|" . desiredResTable[monNumber].BitDepth . "\|" . desiredResTable[monNumber].Frequency)
	{	RLLog.Info(A_ThisFunc . " - Ended, this resolution is already supported by this display: " . desiredResTable[monNumber].Width . "|" . desiredResTable[monNumber].Height . "|" . desiredResTable[monNumber].BitDepth . "|" . desiredResTable[monNumber].Frequency)
		Return desiredResTable
	}
	RLLog.Debug(A_ThisFunc . " - This resolution is not directly supported by your monitor, finding the closest match.")
	SupportedResObj := {}
	nearestSupportedRes := {}
	Loop, Parse, listOfSupportedRes, `,
	{
		currentRes := A_Index
		SupportedResObj[currentRes] := {}
		StringSplit,curRes,A_LoopField,|
		SupportedResObj[currentRes].Width := curRes1
		SupportedResObj[currentRes].Height := curRes2
		SupportedResObj[currentRes].BitDepth := curRes3
		SupportedResObj[currentRes].Frequency := curRes4
		SupportedResObj[currentRes]["Distance"] := {}
		SupportedResObj[currentRes]["Distance"].Width := SupportedResObj[currentRes].Width - desiredResTable[monNumber].Width
		SupportedResObj[currentRes]["Distance"].Height := SupportedResObj[currentRes].Height - desiredResTable[monNumber].Height
		SupportedResObj[currentRes]["Distance"].BitDepth := SupportedResObj[currentRes].BitDepth - desiredResTable[monNumber].BitDepth
		SupportedResObj[currentRes]["Distance"].Frequency := SupportedResObj[currentRes].Frequency - desiredResTable[monNumber].Frequency
	}
	previousDeviation := 10**9
	Loop, %currentRes%
	{
		currentDeviation := 100*SupportedResObj[A_Index]["Distance"].Width*SupportedResObj[A_Index]["Distance"].Width + 100*SupportedResObj[A_Index]["Distance"].Height*SupportedResObj[A_Index]["Distance"].Height + 10*SupportedResObj[A_Index]["Distance"].BitDepth*SupportedResObj[A_Index]["Distance"].BitDepth + SupportedResObj[A_Index]["Distance"].Frequency*SupportedResObj[A_Index]["Distance"].Frequency
		If (currentDeviation < previousDeviation) {
			previousDeviation := currentDeviation
			nearestSupportedRes.Width :=  SupportedResObj[A_Index].Width
			nearestSupportedRes.Height :=  SupportedResObj[A_Index].Height
			nearestSupportedRes.BitDepth :=  SupportedResObj[A_Index].BitDepth
			nearestSupportedRes.Frequency :=  SupportedResObj[A_Index].Frequency
		}
	}
	supportedRes := ConvertToMonitorObject(monNumber . "|" . nearestSupportedRes.Width . "|" . nearestSupportedRes.Height . "|" . nearestSupportedRes.BitDepth . "|"  nearestSupportedRes.Frequency)	; convert to object
	RLLog.Info(A_ThisFunc . " - Ended, closest match found is: " . supportedRes[monNumber].Width . "|" . supportedRes[monNumber].Height . "|" . supportedRes[monNumber].BitDepth . "|"  supportedRes[monNumber].Frequency)
	Return supportedRes
}

; Enumerate Supported Screen Resolutions
; display = the number of the monitor to enumerate supported resolutions for. 1 = Display 1, 2 = display 2, etc
; Returns | delimited list of all supported settings
EnumDisplaySettings(display) {
	VarSetCapacity(DM,156,0), NumPut(156,&DM,36, "UShort")
	DllCall( "EnumDisplaySettings", str,"\\.\DISPLAY" Display, UInt,-1, UInt,&DM )
	CS:=NumGet(DM,108) "|" NumGet(DM,112) "|" NumGet(DM,104) "|" NumGet(DM,120)
	Loop
		If DllCall( "EnumDisplaySettings", str,"\\.\DISPLAY" Display, UInt,A_Index-1, UInt,&DM )
		{	EDS:=NumGet(DM,108) "|" NumGet(DM,112) "|" NumGet(DM,104) "|" NumGet(DM,120)
			DS.=(!InStr(DS,EDS) ? "," EDS : "")
		} Else
			Break
	StringReplace, DS, DS, %CS%|, %CS%||, All
	Return SubStr(DS,2)
}

OptionScale(ByRef option, scale){ ;selects portrait specifc option value if needed and scales variable to adjust to screen resolution
	Global screenRotationAngle
	If InStr(option,"|")
	{
		StringSplit, opt, option, |
		If ((opt2) and (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270)))))
			option := If (SubStr(opt2, 0)="p") ? opt2 : round(opt2 * scale)
		Else
			option := If (SubStr(opt1, 0)="p") ? opt1 : round(opt1 * scale)
	} Else
		option := If (SubStr(option, 0)="p") ? option : round(option * scale)
} 



TextOptionScale(ByRef Option,XScale, YScale){
	RegExMatch(Option, "i)X([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Option, "i)Y([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Option, "i)W([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|W([\-\d\.]+)(p*)", Width)
	RegExMatch(Option, "i)H([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|H([\-\d\.]+)(p*)", Height)
	RegExMatch(Option, "i)S([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|S([\-\d\.]+)", Size)
	xposValue := SubStr(xpos, 2), yposValue := SubStr(ypos, 2), WidthValue := SubStr(Width, 2), HeightValue := SubStr(Height, 2), SizeValue := SubStr(Size, 2)
	OptionScale(xposValue, XScale)
	OptionScale(yposValue, YScale)
	OptionScale(WidthValue, XScale)
	OptionScale(HeightValue, YScale)
	OptionScale(SizeValue, YScale)
	Option := RegExReplace(Option, "i)X([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|X([\-\d\.]+)(p*)", "x" .  xposValue)
	Option := RegExReplace(Option, "i)Y([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|Y([\-\d\.]+)(p*)", "y" .  yposValue)
	Option := RegExReplace(Option, "i)W([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|W([\-\d\.]+)(p*)", "w" .  WidthValue)
	Option := RegExReplace(Option, "i)H([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|H([\-\d\.]+)(p*)", "h" .  HeightValue)
	Option := RegExReplace(Option, "i)S([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|S([\-\d\.]+)", "s" .  SizeValue)
}

;-------------------------------------------------------------------------------------------------------------
;---------------------------- Open And Close Process Functions ----------------------------
;-------------------------------------------------------------------------------------------------------------

ProcSus(PID_or_Name) {
	If InStr(PID_or_Name, ".") {
		Process, Exist, %PID_or_Name%
		PID_or_Name := ErrorLevel
	}
	If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID_or_Name)) {
		RLLog.Info(A_ThisFunc . " - Process """ . PID_or_Name . """ not found")
		Return -1
	}
	RLLog.Info(A_ThisFunc . " -  Suspending Process: " . PID_or_Name)
	DllCall("ntdll.dll\NtSuspendProcess", "Int", h), DllCall("CloseHandle", "Int", h)
}

ProcRes(PID_or_Name) {
	If InStr(PID_or_Name, ".") {
		Process, Exist, %PID_or_Name%
		PID_or_Name := ErrorLevel
	}
	If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID_or_Name)) {
		RLLog.Info(A_ThisFunc . " - Process """ . PID_or_Name . """ not found")
		Return -1
	}
	RLLog.Info(A_ThisFunc . " -  Resuming Process: " . PID_or_Name)
	DllCall("ntdll.dll\NtResumeProcess", "Int", h), DllCall("CloseHandle", "Int", h)
}

;-------------------------------------------------------------------------------------------------------------
;--------------------------------------- Validate IP Functions ---------------------------------------
;-------------------------------------------------------------------------------------------------------------

ValidIP(a) {
   Loop, Parse, a, .
   {
      If A_LoopField is digit
         If A_LoopField between 0 and 255
            e++
      c++
   }
   Return, e = 4 AND c = 4
}

ValidPort(a) {
	If a is digit
		If a between 0 and 65535
			e++
   Return e
}

GetPublicIP() {
	UrlDownloadToFile, http://www.rlauncher.com/ipcheck/myip.php, %A_Temp%\myip.txt
	FileRead, extIP, %A_Temp%\myip.txt
	Return extIP
}

GetLocalIP() {
	array := []
	objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
	colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
	while colItems[objItem]
	{
		array[A_Index,1] := objItem.Description[0]
		array[A_Index,2] := objItem.IPAddress[0]
		array[A_Index,3] := objItem.IPSubnet[0]
		array[A_Index,4] := objItem.DefaultIPGateway[0]
		array[A_Index,5] := objItem.DNSServerSearchOrder[0]
		array[A_Index,6] := objItem.MACAddress[0]
		array[A_Index,7] := objItem.DHCPEnabled[0]
	}
	Return array
}


;-------------------------------------------------------------------------------------------------------------
;------------------------------------------- Rotate Screen Functions -------------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Options:
; method = irotate, display, or shortcut
; degrees = 0, 90, 180, 270

Rotate(method:="irotate", degrees:=0) {
	RLLog.Info(A_ThisFunc . " -  Started")
	Global moduleExtensionsPath
	arrowKeys := { 0: "Up", 1: "Right", 2: "Down", 3: "Left" }
	If !RegExMatch(method,"i)irotate|display|shortcut")
		ScriptError("""" . method . """ is not a valid rotate method, Please choose either ""irotate"" or ""display""")
	If !RegExMatch(degrees,"0|90|180|270")
		ScriptError("""" . degrees . """ is not a valid degree to rotate to, Please choose either 0, 90, 180, or 270")
	rotateExe := CheckFile(moduleExtensionsPath . "\" . method . ".exe")	; check If the exe to our RotateMethod method exists
	If (method = "irotate") {
		RLLog.Info(A_ThisFunc . " -  Rotating display using irotate.exe to " . degrees . " degrees")
		Run(rotateExe . " /rotate=" degrees " /exit", moduleExtensionsPath)
	} Else If (method = "display") {
		RLLog.Info(A_ThisFunc . " -  Rotating display using display.exe to " . degrees . " degrees")
		Run(rotateExe . " /rotate:" degrees, moduleExtensionsPath)
	} Else If (method = "shortcut") {
		RLLog.Info(A_ThisFunc . " -  Rotating display using shortcut keys to " . degrees . " degrees")
		Send, % "{LControl Down}{LAlt Down}{"	. arrowKeys[degrees // 90] . " Down}{LControl Up}{LAlt Up}{"	. arrowKeys[degrees // 90] . " Up}" 
	}
	RLLog.Info(A_ThisFunc . " -  Ended")
}


;-------------------------------------------------------------------------------------------------------------
;-------------------------------------------- Database Asset Building ------------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Builds an object filled with the FE's assets
BuildAssetsTable(list,label,AssetType,extensions:="",obj:=""){
	RLLog.Info(A_ThisFunc . " - Started - Building Table for: " . label)
	Global logLevel
	StringReplace, extensionsReplaced, extensions, |, `,,All
	If !(obj)
		obj := {}
	StringSplit, labelArray, label, |,
	StringSplit, AssetTypeArray, AssetType, |,
	Loop, Parse, list,|
	{	If !(labelArray%A_Index% = "#disabled#")
		{
			RLLog.Debug(A_ThisFunc . " - Searching for a " . labelArray%A_Index% . ": " . A_LoopField)
			currentLabel := labelArray%A_Index%
			currentAssetType := AssetTypeArray%A_index% 
			RASHNDOCT := FileExist(A_LoopField)
			If InStr(RASHNDOCT, "D") { ; it is a folder
				folderName := A_LoopFileName
				Loop, % A_LoopField . "\*.*"
				{   If RegExMatch(extensions,"i)" . A_LoopFileExt)
					{	currentobj := {}
						If (currentLabel="keepFileName")
							currentobj["Label"] := folderName
						Else
							currentobj["Label"] := currentLabel
						If obj[currentLabel].Label
						{   currentobj := obj[currentLabel]
							currentobj.TotalItems := currentobj.TotalItems+1
						} Else {
							currentobj.TotalItems := 1
							obj.TotalLabels := if obj.TotalLabels ? obj.TotalLabels + 1 : 1
							obj[obj.TotalLabels] := currentobj.Label
						}
						currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
						currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
						currentobj["AssetType"] := currentAssetType
						currentobj["Type"] := "ImageGroup"
						obj.Insert(currentobj["Label"], currentobj)
					}
				}
			} Else If InStr(RASHNDOCT, "A") { ; it is a file
				SplitPath, A_LoopField, , currentDir,, FileNameWithoutExtension
				Loop, Parse, extensionsReplaced,`,
				{
					If FileExist(currentDir . "\" . FileNameWithoutExtension . "." . A_LoopField)
					{	currentobj := {}
						If (currentLabel="keepFileName")
							currentobj["Label"] := FileNameWithoutExtension
						Else
							currentobj["Label"] := currentLabel
						If obj[FileNameWithoutExtension].Label
						{   currentobj := obj[FileNameWithoutExtension]
							currentobj.TotalItems := currentobj.TotalItems+1
						} Else {
							currentobj.TotalItems := 1
							obj.TotalLabels := if obj.TotalLabels ? obj.TotalLabels + 1 : 1
							obj[obj.TotalLabels] := currentobj.Label
						}
						currentobj["Path" . currentobj.TotalItems] := currentDir . "\" . FileNameWithoutExtension . "." . A_LoopField
						currentobj["Ext" . currentobj.TotalItems] := A_LoopField
						currentobj["AssetType"] := currentAssetType
						obj.Insert(currentobj["Label"], currentobj)  
					}
				}
			}
		} Else
			RLLog.Warning(A_ThisFunc . " - This asset has been disabled: " . labelArray%A_Index%)

	}
	If (logLevel>=5){
		for index, element in obj
		{	Loop, % obj[element.Label].TotalItems
				mediaAssetsLog := % mediaAssetsLog . "`r`n`t`t`t`t`tAsset Label: " . element.Label . " | Asset Path" . a_index . ":  " . element["Path" . a_index] . " | Asset Extension" . a_index . ":  " . element["Ext" . a_index] . " | Asset Type" . a_index . ":  " . element["AssetType"]
		}
		If mediaAssetsLog
            RLLog.Debug(A_ThisFunc . " - Media assets found: " . mediaAssetsLog)
	}
	RLLog.Info(A_ThisFunc . " - Ended")
	Return obj
}

BuildAssetsTableOld(list,label,AssetType,extensions:=""){
	Global logLevel
	RLLog.Info(A_ThisFunc . " - Started - Building Table for: " . label)
	StringReplace, extensionsReplaced, extensions, |, `,,All
	obj:={}
	StringSplit, labelArray, label, |,
	StringSplit, AssetTypeArray, AssetType, |,
	Loop, Parse, list,|
	{	labelIndex++
		If !(labelArray%labelIndex% = "#disabled#")
		{
			RLLog.Debug(A_ThisFunc . " - Searching for a " . labelArray%labelIndex% . ": " . A_LoopField)
			currentLabel := labelArray%labelIndex%
			currentAssetType := AssetTypeArray%A_index% 
			RASHNDOCT := FileExist(A_LoopField)
			If InStr(RASHNDOCT, "D") { ; it is a folder
				folderName := A_LoopFileName
				Loop, % A_LoopField . "\*.*"
				{   If RegExMatch(extensions,"i)" . A_LoopFileExt)
					{	currentobj := {}
						If (currentLabel="keepFileName")
							currentobj["Label"] := folderName
						Else
							currentobj["Label"] := currentLabel
						If obj[currentLabel].Label
						{   currentobj := obj[currentLabel]
							currentobj.TotalItems := currentobj.TotalItems+1
						} Else {
							currentobj.TotalItems := 1
							obj.TotalLabels := if obj.TotalLabels ? obj.TotalLabels + 1 : 1
							obj[obj.TotalLabels] := currentobj.Label
						}
						currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
						currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
						currentobj["AssetType"] := currentAssetType
						currentobj["Type"] := "ImageGroup"
						obj.Insert(currentobj["Label"], currentobj)
					}
				}
			} Else If InStr(RASHNDOCT, "A") { ; it is a file
				SplitPath, A_LoopField, , currentDir,, FileNameWithoutExtension
				Loop, Parse, extensionsReplaced,`,
				{
					If (InStr(extensionsReplaced , ",") && A_Index >= 2) {
						labelIndex++	; need to advance the label by one each time a new extension is used
						currentLabel := labelArray%labelIndex%
					}
					If FileExist(currentDir . "\" . FileNameWithoutExtension . "." . A_LoopField)
					{	currentobj := {}
						If (currentLabel="keepFileName")
							currentobj["Label"] := FileNameWithoutExtension
						Else
							currentobj["Label"] := currentLabel
						If obj[FileNameWithoutExtension].Label
						{   currentobj := obj[FileNameWithoutExtension]
							currentobj.TotalItems := currentobj.TotalItems+1
						} Else {
							currentobj.TotalItems := 1
							obj.TotalLabels := if obj.TotalLabels ? obj.TotalLabels + 1 : 1
							obj[obj.TotalLabels] := currentobj.Label
						}
						currentobj["Path" . currentobj.TotalItems] := currentDir . "\" . FileNameWithoutExtension . "." . A_LoopField
						currentobj["Ext" . currentobj.TotalItems] := A_LoopField
						currentobj["AssetType"] := currentAssetType
						obj.Insert(currentobj["Label"], currentobj)  
					}
				}
			}
		} Else
			RLLog.Warning(A_ThisFunc . " - This asset has been disabled: " . labelArray%labelIndex%)

	}
	If (logLevel>=5){
		for index, element in obj
		{	Loop, % obj[element.Label].TotalItems
				mediaAssetsLog := % mediaAssetsLog . "`r`n`t`t`t`t`tAsset Label: " . element.Label . " | Asset Path" . a_index . ":  " . element["Path" . a_index] . " | Asset Extension" . a_index . ":  " . element["Ext" . a_index] . " | Asset Type" . a_index . ":  " . element["AssetType"]
		}
		If mediaAssetsLog
            RLLog.Debug(A_ThisFunc . " - Media assets found: " . mediaAssetsLog)
	}
	RLLog.Info(A_ThisFunc . " - Ended")
	Return obj
}


;-------------------------------------------------------------------------------------------------------------
;-------------------------------------- Broadcast and Message Receiving --------------------------------------
;-------------------------------------------------------------------------------------------------------------
ReceiveMessage(wParam, lParam) ; receive messages from other programs 
{	Global Pause_Active,Pause_Running,systemName,gameInfo
	;Global ; it is necessary to use global if the var definition part is uncommented  
	StringAddress := NumGet(lParam + 8)  
    StringLength := DllCall("lstrlen", UInt, StringAddress)
    If (StringLength <= 0)
		RLLog.Info(A_ThisFunc . " - A blank string message was received by RocketLauncher or there was an error.")
	Else
    {	VarSetCapacity(CopyOfData, StringLength)
        DllCall("lstrcpy", "str", CopyOfData, "uint", StringAddress) 
		StringSplit, Data, CopyOfData, |
		If (Data1)
		{	
			If (Data1="command") {  ; predefined commands
				If (Data2="RLPause") {
					If (Pause_Active){
						Gosub, TogglePauseMenuStatus
						RLLog.Info(A_ThisFunc . " - RocketLauncher received the windows message to unpause the game: " . Data2)
					} Else If !(Pause_Running) {
						Gosub, TogglePauseMenuStatus
						RLLog.Info(A_ThisFunc . " - RocketLauncher received the windows message to pause the game: " . Data2)
					}
				} Else If (Data2="RLSelect") {
					If (Pause_Active){
						Gosub, ToggleItemSelectStatus
					}
				} Else If (Data2="RLUp") {
					If (Pause_Active){
						Gosub, MoveUp
					}
				} Else If (Data2="RLDown") {
					If (Pause_Active){
						Gosub, MoveDown
					}
				} Else If (Data2="RLLeft") {
					If (Pause_Active){
						Gosub, MoveLeft
					}
				} Else If (Data2="RLRight") {
					If (Pause_Active){
						Gosub, MoveRight
					}
				} Else If (Data2="RLExit") {
					Gosub, CloseProcess
				} Else {
					RLLog.Info(A_ThisFunc . "R - ocketLauncher received the windows message to run a inexistent command: " . Data2)
				}
			} Else If (Data1="ping") {
				BroadcastMessage("RocketLauncher Message System is Available.") 
			} Else If (Data1="Which system?") {
				BroadcastMessage("RocketLauncher Message. Current System: " . systemName) 
			} Else If (Data1="Which game?") {
				BroadcastMessage("RocketLauncher Message. Current Game: " . gameInfo["Name"].Value)
			}
			/*} if (Data1="runlabel") {
				if IsLabel(Data2) {
					RLLog.Info("RocketLauncher received the windows message to run the label: " . Data2)
					gosub, %Data2%
				} Else {
					RLLog.Info("RocketLauncher received the windows message to run a inexistent label: " . Data2)
				}
			} Else If (Data1="setvar") {
				RLLog.Info("RocketLauncher received the windows message to set the variable named " . Data2 . " to the value = " . Data3)
				%Data2% := Data3
			*/
		} Else
			RLLog.Info(A_ThisFunc . " - RocketLauncher does not recognize the pure string message sent as a valid command: " . CopyOfData)
	}
    Return true
}

BroadcastMessage(StringToSend) {
	Global broadcastWindowTitle
	If broadcastWindowTitle {
		VarSetCapacity(CopyDataStruct, 12, 0)  
		NumPut(StrLen(StringToSend) + 1, CopyDataStruct, 4)
		NumPut(&StringToSend, CopyDataStruct, 8)  
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		MiscUtils.DetectHiddenWindows("On")
		SetTitleMatchMode 2
		; If (BroadcastWindowTitle="All"){
			; RLLog.Info("BroadcastMessage - Sending message """ . StringToSend . """ to all windows.")
			; SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_id 0xFFFF
		If InStr(BroadcastWindowTitle, "|") {
			Loop, Parse, BroadcastWindowTitle, |, %A_Space%
			{	RLLog.Info(A_ThisFunc . " - Sending message """ . StringToSend . """ to " . A_LoopField . " window.")
				SendMessage, 0x4a, 0, &CopyDataStruct,, % BroadcastWindowTitle
			}				
		} Else If (BroadcastWindowTitle){
			If (WinExist(BroadcastWindowTitle) != "0x0") {
				RLLog.Info(A_ThisFunc . " - Sending message """ . StringToSend . """ to " . BroadcastWindowTitle . " window.")
				SendMessage, 0x4a, 0, &CopyDataStruct,, % BroadcastWindowTitle
			} Else
				RLLog.Warning(A_ThisFunc . " - Could not broadcast message """ . StringToSend . """ to " . BroadcastWindowTitle . " because the window could not be found.")
		} Else
			RLLog.Debug(A_ThisFunc . " - Message was not broadcasted because the lack of a valid window target.")
		MiscUtils.DetectHiddenWindows(Prev_DetectHiddenWindows)
		SetTitleMatchMode %Prev_TitleMatchMode%
		Return ErrorLevel  ; Return SendMessage's reply back to our caller.
	}
}


;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- Split Screen Module Support ------------------------------------------
;-------------------------------------------------------------------------------------------------------------

; SplitScreenPos function
; Returns an object with the screen coordinates (posArray[screen number].x, posArray[screen number].y, posArray[screen number].w and posArray[screen number].h) for placing split screen emulator screens. 
; Supports up to 8 screens
; splitScreen2PlayersMode can be Vertical or Horizontal
; splitScreen3PlayersMode can be P1top, P1left, P1right, P1bottom
; maxPlayersPerMonitor defines the maximun amount of player screens to be placed at each monitor. For example, "1|2|3" means that screen 1 will only have the player 1, screen 2 will have the player 2 and 3 and screen 3 will have the players 4, 5 and 6 screens. If the current available monitors is not able to show the selected number of players, the code will automatically increase the screen 1 amount of screens untill all players are displayed
SplitScreenPos(numberofPlayers,splitScreen2PlayersMode:="Horizontal",splitScreen3PlayersMode:="P1top",maxPlayersPerMonitor:="4|4|4"){
	Global monitorTable
	RLLog.Info(A_ThisFunc . " - Started")
	;Making sure to distribute screens only on current available monitors and find out how many monitors are needed to show the selected number of players
	monitor := []
	StringSplit,playerPerMonitor,maxPlayersPerMonitor,|  
	Loop, % monitorTable.MaxIndex()
	{	monitor[a_index] := {}
		currentNumberOfPlayers := playerPerMonitor%a_index% 
		accumulatedPlayers += currentNumberOfPlayers
		If (accumulatedPlayers>numberofPlayers)
			currentNumberOfPlayers := numberofPlayers - (accumulatedPlayers-currentNumberOfPlayers)
		monitor[a_index].numberOfPlayers := currentNumberOfPlayers
	}
	If (accumulatedPlayers<numberofPlayers){
		Loop, % (numberofPlayers-accumulatedPlayers)
		{	count1++  
			If ( count1 > monitorTable.MaxIndex() )
				count1 := 1
			monitor[count1].numberOfPlayers += 1
		}
	}
	;Defining splitscreen positions
	posArray := []
	Loop, % numberofPlayers
		posArray[a_index] := {}
	count := 0
	Loop, % monitor.MaxIndex()
	{	currentMonitor := a_index
		If (monitor[currentMonitor].numberOfPlayers = 1){
			posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top , posArray[count+1].W := monitorTable[currentMonitor].Width , posArray[count+1].H := monitorTable[currentMonitor].Height
		} Else If (monitor[currentMonitor].numberOfPlayers = 2){
			If (splitScreen2PlayersMode = "Vertical"){
				posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top , posArray[count+1].W := monitorTable[currentMonitor].Width//2 , posArray[count+1].H := monitorTable[currentMonitor].Height
				posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+2].Y := monitorTable[currentMonitor].Top , posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height
			} Else {
				posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top , posArray[count+1].W := monitorTable[currentMonitor].Width , posArray[count+1].H := monitorTable[currentMonitor].Height//2
				posArray[count+2].X := monitorTable[currentMonitor].Left , posArray[count+2].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 , posArray[count+2].W := monitorTable[currentMonitor].Width , posArray[count+2].H := monitorTable[currentMonitor].Height//2
			}
		} Else If (monitor[currentMonitor].numberOfPlayers = 3){
			If (splitScreen3PlayersMode = "P1left"){
				posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top , posArray[count+1].W := monitorTable[currentMonitor].Width//2 , posArray[count+1].H := monitorTable[currentMonitor].Height
				posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+2].Y := monitorTable[currentMonitor].Top , posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
				posArray[count+3].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+3].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 , posArray[count+3].W := monitorTable[currentMonitor].Width//2 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			} Else If (splitScreen3PlayersMode = "P1bottom") {
				posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+1].W := monitorTable[currentMonitor].Width , posArray[count+1].H := monitorTable[currentMonitor].Height//2
				posArray[count+2].X := monitorTable[currentMonitor].Left , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
				posArray[count+3].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+3].Y := monitorTable[currentMonitor].Top ,	posArray[count+3].W := monitorTable[currentMonitor].Width//2 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			} Else If (splitScreen3PlayersMode = "P1right") {
				posArray[count+1].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width//2 , posArray[count+1].H := monitorTable[currentMonitor].Height
				posArray[count+2].X := monitorTable[currentMonitor].Left , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
				posArray[count+3].X := monitorTable[currentMonitor].Left , posArray[count+3].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+3].W := monitorTable[currentMonitor].Width//2 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			} Else { ;top
				posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width , posArray[count+1].H := monitorTable[currentMonitor].Height//2
				posArray[count+2].X := monitorTable[currentMonitor].Left , posArray[count+2].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
				posArray[count+3].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+3].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+3].W := monitorTable[currentMonitor].Width//2 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			}
		} Else If (monitor[currentMonitor].numberOfPlayers = 4){
			posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width//2 , posArray[count+1].H := monitorTable[currentMonitor].Height//2
			posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
			posArray[count+3].X := monitorTable[currentMonitor].Left , posArray[count+3].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+3].W := monitorTable[currentMonitor].Width//2 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			posArray[count+4].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+4].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+4].W := monitorTable[currentMonitor].Width//2 , posArray[count+4].H := monitorTable[currentMonitor].Height//2
		} Else If (monitor[currentMonitor].numberOfPlayers = 5){
			posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width//2 , posArray[count+1].H := monitorTable[currentMonitor].Height//2
			posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//2 , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//2 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
			posArray[count+3].X := monitorTable[currentMonitor].Left , posArray[count+3].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+3].W := monitorTable[currentMonitor].Width//3 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			posArray[count+4].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//3 , posArray[count+4].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+4].W := monitorTable[currentMonitor].Width//3 , posArray[count+4].H := monitorTable[currentMonitor].Height//2
			posArray[count+5].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//3 , posArray[count+5].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+5].W := monitorTable[currentMonitor].Width//3 , posArray[count+5].H := monitorTable[currentMonitor].Height//2
		} Else If (monitor[currentMonitor].numberOfPlayers = 6){
			posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width//3 , posArray[count+1].H := monitorTable[currentMonitor].Height//2
			posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//3 , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//3 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
			posArray[count+3].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//3 , posArray[count+3].Y := monitorTable[currentMonitor].Top ,	posArray[count+3].W := monitorTable[currentMonitor].Width//3 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			posArray[count+4].X := monitorTable[currentMonitor].Left , posArray[count+4].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+4].W := monitorTable[currentMonitor].Width//3 , posArray[count+4].H := monitorTable[currentMonitor].Height//2
			posArray[count+5].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//3 , posArray[count+5].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+5].W := monitorTable[currentMonitor].Width//3 , posArray[count+5].H := monitorTable[currentMonitor].Height//2
			posArray[count+6].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//3 , posArray[count+6].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+6].W := monitorTable[currentMonitor].Width//3 , posArray[count+6].H := monitorTable[currentMonitor].Height//2			
		} Else If (monitor[currentMonitor].numberOfPlayers = 7){
			posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width//3 , posArray[count+1].H := monitorTable[currentMonitor].Height//2
			posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//3 , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//3 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
			posArray[count+3].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//3 , posArray[count+3].Y := monitorTable[currentMonitor].Top ,	posArray[count+3].W := monitorTable[currentMonitor].Width//3 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			posArray[count+4].X := monitorTable[currentMonitor].Left , posArray[count+4].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+4].W := monitorTable[currentMonitor].Width//4 , posArray[count+4].H := monitorTable[currentMonitor].Height//2
			posArray[count+5].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//4 , posArray[count+5].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+5].W := monitorTable[currentMonitor].Width//4 , posArray[count+5].H := monitorTable[currentMonitor].Height//2
			posArray[count+6].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//4 , posArray[count+6].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+6].W := monitorTable[currentMonitor].Width//4 , posArray[count+6].H := monitorTable[currentMonitor].Height//2
			posArray[count+7].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*3//4 , posArray[count+7].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+7].W := monitorTable[currentMonitor].Width//4 , posArray[count+7].H := monitorTable[currentMonitor].Height//2
		} Else If (monitor[currentMonitor].numberOfPlayers = 8){
			posArray[count+1].X := monitorTable[currentMonitor].Left , posArray[count+1].Y := monitorTable[currentMonitor].Top ,	posArray[count+1].W := monitorTable[currentMonitor].Width//4 , posArray[count+1].H := monitorTable[currentMonitor].Height//2
			posArray[count+2].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//4 , posArray[count+2].Y := monitorTable[currentMonitor].Top ,	posArray[count+2].W := monitorTable[currentMonitor].Width//4 , posArray[count+2].H := monitorTable[currentMonitor].Height//2
			posArray[count+3].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//4 , posArray[count+3].Y := monitorTable[currentMonitor].Top ,	posArray[count+3].W := monitorTable[currentMonitor].Width//4 , posArray[count+3].H := monitorTable[currentMonitor].Height//2
			posArray[count+4].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*3//4 , posArray[count+4].Y := monitorTable[currentMonitor].Top ,	posArray[count+4].W := monitorTable[currentMonitor].Width//4 , posArray[count+4].H := monitorTable[currentMonitor].Height//2
			posArray[count+5].X := monitorTable[currentMonitor].Left , posArray[count+5].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+5].W := monitorTable[currentMonitor].Width//4 , posArray[count+5].H := monitorTable[currentMonitor].Height//2
			posArray[count+6].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width//4 , posArray[count+6].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+6].W := monitorTable[currentMonitor].Width//4 , posArray[count+6].H := monitorTable[currentMonitor].Height//2
			posArray[count+7].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*2//4 , posArray[count+7].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+7].W := monitorTable[currentMonitor].Width//4 , posArray[count+7].H := monitorTable[currentMonitor].Height//2
			posArray[count+8].X := monitorTable[currentMonitor].Left+monitorTable[currentMonitor].Width*3//4 , posArray[count+8].Y := monitorTable[currentMonitor].Top+monitorTable[currentMonitor].Height//2 ,	posArray[count+8].W := monitorTable[currentMonitor].Width//4 , posArray[count+8].H := monitorTable[currentMonitor].Height//2
		} Else {
			RLLog.Warning(A_ThisFunc . " - " . monitor[currentMonitor].numberOfPlayers . " is a nonsupported number of players for the split screen position calculation function.")
		}
		Loop, %	monitor[currentMonitor].numberOfPlayers
			RLLog.Debug(A_ThisFunc . " - Player " . count+a_index . " window position: X=" . posArray[count+a_index].X . ", Y=" . posArray[count+a_index].Y . ", W=" . posArray[count+a_index].W . ", H=" . posArray[count+a_index].H)
		count += monitor[currentMonitor].numberOfPlayers
		If (count >= numberofPlayers)
			Break
	}
	RLLog.Info(A_ThisFunc . " - Ended")
	Return posArray
}
