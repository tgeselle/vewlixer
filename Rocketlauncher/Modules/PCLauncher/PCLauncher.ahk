MEmu := "PCLauncher"
MEmuV := "N/A"
MURL := ["http://www.rlauncher.com/wiki/index.php?title=PCLauncher"]
MAuthor := ["djvj"]
MVersion := "2.2.7"
MCRC := "5814E2E"
iCRC := "28F444EF"
MID := "635243126483565041"
MSystem := ["American Laser Games","Arcade PC","Doujin Soft","Examu eX-BOARD","Fan Remakes","Games for Windows","Konami e-Amusement","Konami Bemani","Microsoft Windows","PCLauncher","PC Games","Singstar","Steam","Steam Big Picture","Taito Type X","Taito Type X2","Touhou","Touhou Project","Ultrastar","Ultrastar Deluxe","Windows Games"]
;----------------------------------------------------------------------------
; Notes:
; Use the examples in the ini, in your Modules\PCLauncher\ folder, to add more applications.
; PCLauncher supports per-System inis. Copy your PCLauncher ini in the same folder and rename it to match the System's Name. Use this if you have games with the same name across multiple systems.
; Read the tooltips for each module setting in RocketLauncherUI for the definitions of each key and help using them.
; For information on how to use this module and what all the settings do, please see http://www.rlauncher.com/wiki/index.php?title=PCLauncher
;----------------------------------------------------------------------------
StartModule()

moduleIni.CheckFile("Could not find """ . moduleIni.FileFullPath . """`n`nRocketLauncherUI will create this file when you configure your first game to be used with the " . MEmu . " module.")

Application := moduleIni.Read(dbName, "Application",,,1)
AppWaitExe := moduleIni.Read(dbName, "AppWaitExe",,,1)
DiscImage := moduleIni.Read(dbName, "DiscImage",,,1)
DXWndGame := moduleIni.Read(dbName, "DXWndGame",,,1)
DXWndMaximizeWindow := moduleIni.Read(dbName, "DXWndMaximizeWindow",,,1)
ExitMethod := moduleIni.Read(dbName, "ExitMethod",,,1)
FadeTitle := moduleIni.Read(dbName, "FadeTitle",,,1)
FadeTitleWaitTillActive := moduleIni.Read(dbName, "FadeTitleWaitTillActive","true",,1)
FadeTitleTimeout := moduleIni.Read(dbName, "FadeTitleTimeout",,,1)
FadeInExitSleep := moduleIni.Read(dbName, "FadeInExitSleep",,,1)
HideConsole := moduleIni.Read(dbName, "HideConsole",,,1)
OriginGame := moduleIni.Read(dbName, "OriginGame",,,1)
Parameters := moduleIni.Read(dbName, "Parameters",,,1)
PostLaunch := moduleIni.Read(dbName, "PostLaunch",,,1)
PostLaunchParameters := moduleIni.Read(dbName, "PostLaunchParameters",,,1)
PostLaunchSleep := moduleIni.Read(dbName, "PostLaunchSleep",,,1)
PostExit := moduleIni.Read(dbName, "PostExit",,,1)
PostExitParameters := moduleIni.Read(dbName, "PostExitParameters",,,1)
PostExitSleep := moduleIni.Read(dbName, "PostExitSleep",,,1)
PreLaunch := moduleIni.Read(dbName, "PreLaunch",,,1)
PreLaunchParameters := moduleIni.Read(dbName, "PreLaunchParameters",,,1)
PreLaunchMode := moduleIni.Read(dbName, "PreLaunchMode",,,1)
PreLaunchSleep := moduleIni.Read(dbName, "PreLaunchSleep",,,1)
SteamID := moduleIni.Read(dbName, "SteamID",,,1)
WorkingFolder := moduleIni.Read(dbName, "WorkingFolder",,,1)
bezelTopOffset := moduleIni.Read(dbName, "BezelTopOffset","0",,1)
bezelBottomOffset := moduleIni.Read(dbName, "BezelBottomOffset","0",,1)
bezelLeftOffset := moduleIni.Read(dbName, "BezelLeftOffset","0",,1)
bezelRightOffset := moduleIni.Read(dbName, "BezelRightOffset","0",,1)
BezelFixedResMode := moduleIni.Read(dbName, "BezelFixedResMode","false",,1)
HideWindowTitleBar := moduleIni.Read(dbName, "HideWindowTitleBar","true",,1)
HideWindowBorder := moduleIni.Read(dbName, "HideWindowBorder","true",,1)
HideWindowMenuBar := moduleIni.Read(dbName, "HideWindowMenuBar","true",,1)
HideDecoratorsAfterMove := moduleIni.Read(dbName, "HideDecoratorsAfterWindowMove","false",,1)
HideWindowBorderFirst := moduleIni.Read(dbName, "HideWindowBorderFirst","false",,1)
Fullscreen := moduleIni.Read(dbName, "Fullscreen",,,1)

If (!Application && !SteamID) { ; This app cannot be launched if no info exists already in the ini and this is not a steam game
	ScriptError("You have not set up " . dbName . " in RocketLauncherUI yet, so PCLauncher does not know what exe, FadeTitle, and/or SteamID to watch for.")
}

; Configuring bezel settings that would normally be set in BezelLabel
If (HideWindowTitleBar = "false")
	disableHideTitleBar := true
If (HideWindowBorder = "false")
	disableHideBorder := true
If (HideWindowMenuBar = "false")
	disableHideToggleMenu := true
If (HideDecoratorsAfterMove = "true")
	hideDecoratorsAfterWindowMove := true
If (HideWindowBorderFirst = "true")
	hideBorderFirst := true

If Fullscreen {
	;Warn user if fullscreen is set, but no custom game user function file exists for this game
	gameUserFunc := new File(libPath . "\Lib\User Functions\" . systemName . "\" . dbName . ".ahk")
	If (!gameUserFunc.Exist()) {
		RLLog.Warning("PCLauncher - You have configured a fullscreen setting for this game, but no GameUserFunction file exists at '" . gameUserFunc.FileFullPath . "' therefore the fullscreen setting won't have any effect until you create such file and implement the proper SetFullscreen function")
	}
}

BezelGUI()
FadeInStart()
If (BezelFixedResMode = "true")
	BezelStart("fixResMode")
Else
	BezelStart()

If Application {
	primaryExe := new Emulator(Application)		; instantiate primary application executable object
}

If (AppWaitExe != "") {
	AppWaitExe := new Process(AppWaitExe)
}

If FadeTitle {
	FadeTitleObj := StringUtils.ParsePCTitle(FadeTitle)
	appPrimaryWindow := new Window(new WindowTitle(FadeTitleObj.Title,FadeTitleObj.Class))	; instantiate primary application window object
}

; If Application needs a cd/dvd image in the drive, mount it in DT first
If DiscImage {
	RLLog.Info("PCLauncher - Application is a Disc Image, mounting it in DT")
	appIsImage := 1
	DiscImage := new File(GetFullName(DiscImage))	; convert a relative path defined in the PCLauncher ini to absolute
	DiscImage.CheckFile("Cannot find this DiscImage for " . dbName . ":`n" . DiscImage.FileFullPath)
	; StringUtils.SplitPath(DiscImage,"",ImagePath,ImageExt,ImageName)
	If StringUtils.Contains(DiscImage.FileExt,"mds|mdx|b5t|b6t|bwt|ccd|cue|isz|nrg|cdi|iso|ape|flac")
	{	VirtualDrive("get")	; get the vdDriveLetter
		; VirtualDrive("mount",ImagePath . "\" . ImageName . "." . ImageExt)
		VirtualDrive("mount",DiscImage.FileFullPath)
	} Else
		ScriptError("You defined a DiscImage, but it is not a supported format for this module and/or DT:`nccd,cdi,cue,iso,isz,nrg")
}

; Verify module's settings are set
CheckSettings()

If PreLaunch {
	RLLog.Info("PCLauncher - PreLaunch set by user, running: " . PreLaunch)
	PreLaunchParameters := If (!PreLaunchParameters or PreLaunchParameters="ERROR") ? "" : PreLaunchParameters
	If (preLaunchMode = "run") {
		errLevel := PreLaunchExe.Run(If PreLaunchIsURL ? "" : PreLaunchParameters,,,,,(If PreLaunchIsURL ? "" : 1))	; If this is a url, do not send params
		If errLevel
			ScriptError("There was a problem launching your PreLaunch application. Please check it is a valid executable.")
		TimerUtils.Sleep(PreLaunchSleep)
	} Else {
		errLevel := PreLaunchExe.RunWait(If PreLaunchIsURL ? "" : PreLaunchParameters,,(If PreLaunchIsURL ? "" : 1))	; If this is a url, do not send params
		If errLevel
			ScriptError("There was a problem launching your PreLaunch application. Please check it is a valid executable.")
	}
}

If (DXWndGame = "true")		; start dxwnd if needed
	DxwndRun()

Fullscreen := If BezelEnabled() ? "false" : Fullscreen
FullscreenParams := CustomFunction.SetFullscreenPreLaunch(Fullscreen)
If (FullscreenParams) {
	RLLog.Debug("PCLauncher - Setting fullscreen parameters to : " . FullscreenParams)
	Parameters .= " " . FullscreenParams
}

If StringUtils.Contains(mode,"steam|steambp")	; steam launch
	Steam(SteamID, primaryExe.FileFullPath, Parameters)
Else If (mode = "origin")		; origin launch
	Origin(primaryExe.FileName, primaryExe.FilePath, Parameters)
Else {
	If (mode = "url")
	{	RLLog.Info("PCLauncher - Launching URL.")
		errLevel := primaryExe.Run()
	} Else {	; standard launch
		RLLog.Info("PCLauncher - Launching a standard application.")
		If (HideConsole = "true" and primaryExe.FileExt = "bat") {
			RLLog.Info("PCLauncher - Hiding DOS console for bat file.")
			objShell := ComObjCreate("WScript.Shell")
			objShell.CurrentDirectory := If WorkingFolder ? WorkingFolder : primaryExe.FilePath
			errLevel := objShell.Run("""" . primaryExe.FileName . """ " . Parameters, 0, false)
		}
		Else
			errLevel := primaryExe.Run(Parameters,,,,,1,If WorkingFolder ? WorkingFolder : "")
	}
	If errLevel
		ScriptError("There was a problem launching your " . (If appIsImage ? "ImageExe" : "Application") . ". Please check it is a valid executable.")
}

If PostLaunch {
	RLLog.Info("PCLauncher - PostLaunch set by user, running: " . PostLaunch)
	PostLaunchExe := new Process(PostLaunch)
	PostLaunchParameters := If (!PostLaunchParameters or PostLaunchParameters="ERROR") ? "" : PostLaunchParameters
	errLevel := PostLaunchExe.Run(If PostLaunchIsURL ? "" : PostLaunchParameters,,,,,(If PostLaunchIsURL ? "" : 1))	; If this is a url, do not send params
	If errLevel
		ScriptError("There was a problem launching your PostLaunch application. Please check it is a valid executable.")
	TimerUtils.Sleep(PostLaunchSleep)
}

If FadeTitle {
	RLLog.Info("PCLauncher - FadeTitle set by user, waiting for """ . appPrimaryWindow.WinTitle.GetWindowTitle() . """")
	
	If (FadeTitleTimeout)
		appPrimaryWindow.Wait(FadeTitleTimeout)
	Else
		appPrimaryWindow.Wait()
	
	If (FadeTitleWaitTillActive = "true")
		appPrimaryWindow.WaitActive()
} Else If AppWaitExe {
	RLLog.Info("PCLauncher - FadeTitle not set by user, but AppWaitExe is. Waiting for AppWaitExe: " . AppWaitExe.FileName)
	AppWaitExe.Process("Wait",15)
	If (AppWaitExe.PID = 0)
		ScriptError("PCLauncher - There was an error getting the Process ID of your AppWaitExe """ . AppWaitExe.FileName . """. Please try setting a FadeTitle instead.")
} Else If SteamIDExe {
	RLLog.Info("PCLauncher - FadeTitle and AppWaitExe not set by user, but SteamIDExe was found. Waiting for SteamIDExe: " . SteamIDExe.FileFullPath)
	SteamIDExe.Process("Wait",15)	; wait 15 seconds for this process to launch
	If (SteamIDExe.PID = 0)
		ScriptError("PCLauncher - There was an error getting the Process ID from your SteamIDExe for """ . dbName . """. Please try setting a FadeTitle instead.")
} Else If primaryExe.PID {
	RLLog.Info("PCLauncher - FadeTitle and AppWaitExe not set by user, but a PID for the primary application was found. Waiting for PID: " . primaryExe.PID)
	appPrimaryWindow.PID := primaryExe.PID	; store the PID of the primary exe into the window object
	appPrimaryWindow.Wait(,primaryExe.PID)	; only wait for the pid, not any other window element
	appPrimaryWindow.WaitActive(,primaryExe.PID)
} Else
	RLLog.Error("PCLauncher - FadeTitle and AppWaitExe not set by user and no AppPID found from an Application, PCLauncher has nothing to wait for")

If (DXWndGame = "true" and (DXWndMaximizeWindow = "aspect" or DXWndMaximizeWindow = "stretch"))
	appPrimaryWindow.Maximize(If (DXWndMaximizeWindow="aspect") ? "true" : "false")

BezelDraw()

TimerUtils.Sleep(FadeInExitSleep)	; PCLauncher setting for some stubborn games that keeps the fadeIn screen up a little longer
FadeInExit()

If AppWaitExe {
	If !FadeTitle {
		RLLog.Info("PCLauncher - Creating a window based on the AppWaitExe because FadeTitle was not set")
		appPrimaryWindow := new Window(new WindowTitle(,,,,AppWaitExe.PID))	; instantiate AppWaitExe window object
		appPrimaryWindow.Wait()
		appPrimaryWindow.Get("ID")
		appPrimaryWindow.WinTitle.PID := ""	; remove PID from future window matches
		appPrimaryWindow.WinTitle.ID := appPrimaryWindow.ID	; inject hwnd ID so future matches use it instead
	}
	RLLog.Info("PCLauncher - Waiting for AppWaitExe """ . AppWaitExe.FileName . """ to close.")
	AppWaitExe.Process("WaitClose")
} Else If FadeTitle {	; If fadeTitle is set and no appPID was created.
	RLLog.Info("PCLauncher - Waiting for FadeTitle """ . appPrimaryWindow.WinTitle.GetWindowTitle() . """ to close.")
	appPrimaryWindow.WaitClose()
} Else If SteamIDExe {
	RLLog.Info("PCLauncher - Waiting for SteamIDExe """ . SteamIDExe.FileName . """ to close.")
	SteamIDExe.Process("WaitClose")
} Else If primaryExe.PID {
	If !FadeTitle {
		RLLog.Info("PCLauncher - Creating a window based on the Primary Application """ . primaryExe.FileName . """ because FadeTitle nor AppWaitExe were set")
		appPrimaryWindow := new Window(new WindowTitle(,,,,primaryExe.PID))	; instantiate primary application window object
		appPrimaryWindow.Wait()
		appPrimaryWindow.Get("ID")
		appPrimaryWindow.WinTitle.PID := ""	; remove PID from future window matches
		appPrimaryWindow.WinTitle.ID := appPrimaryWindow.ID	; inject hwnd ID so future matches use it instead
	}
	RLLog.Info("PCLauncher - Waiting for the Primary Application PID """ . primaryExe.PID . """ to close.")
	primaryExe.Process("WaitClose")
} Else
	ScriptError("Could not find a proper AppWaitExe`, FadeTitle`, or AppPID (from the launched Application). Try setting either an AppWaitExe or FadeTitle so the module has something to look for.")

If PostExit {
	RLLog.Info("PCLauncher - PostExit set by user, running: " . PostExit)
	PostExitExe := new Process(PostExit)
	PostExitParameters := If (!PostExitParameters or PostExitParameters="ERROR") ? "" : PostExitParameters
	errLevel := PostExitExe.Run(If PostExitIsURL ? "" : PostExitParameters,,,,,(If PostExitIsURL ? "" : 1))	; If this is a url, do not send params
	If errLevel
		ScriptError("There was a problem launching your PostExit application. Please check it is a valid executable.")
	TimerUtils.Sleep(PostExitSleep)
}

; If Application is a cd/dvd image, unmount it in DT
If appIsImage
	VirtualDrive("unmount")

; Close steam if it was not open prior to launch, not really needed anymore because module knows how to launch if steam already running now
; If (primaryExe.PID = 0)
	; Run, Steam.exe -shutdown, %SteamPath%	; close steam

If (DXWndGame = "true")
	DxwndClose()

BezelExit()
FadeOutExit()
ExitModule()

CheckSettings() {
	Global Application,primaryExe
	Global PreLaunch,PreLaunchExe,PreLaunchIsURL
	Global PostLaunch,PostLaunchExe,PostLaunchIsURL
	Global PostExit,PostExitExe,PostExitIsURL
	Global moduleName,appIsImage,vdDriveLetter,SteamID,OriginGame,DXWndGame,mode,AppWaitExe,SteamIDExe,FadeTitle
	Global modulePath,fadeIn
	RLLog.Info("CheckSettings - Started")

	; These checks allow you to run URL and Steam browser protocol commands. Without them ahk would error out that it can't find the file. This is different than setting a SteamID but either work
	If (SteamID) {
		mode := "steam"	; setting module to use steam mode
		RLLog.Info("PCLauncher - SteamID is set, setting mode to: """ . mode . """")
	} Else If (StringUtils.SubStr(Application,1,3) = "ste") {
		mode := "steambp"	; setting module to use Steam Browser Protocol mode
		RLLog.Info("PCLauncher - Application is a Steam Browser Protocol, setting mode to: """ . mode . """")
	} Else If (StringUtils.SubStr(Application,1,4) = "http") {
		mode := "url"	; setting module to use url mode
		RLLog.Info("PCLauncher - Application is a URL, setting mode to: """ . mode . """")
	} Else If OriginGame {
		mode := "origin"	; setting module to use Origin mode
		StringUtils.BackslashCheck(primaryExe.FileFullPath,"Application")
		RLLog.Info("PCLauncher - Origin mode enabled. Will log in to Origin if required.")
	} Else If Application {
		mode := "standard"	; for standard launching
		StringUtils.BackslashCheck(primaryExe.FileFullPath,"Application")
		RLLog.Info("PCLauncher - Setting mode to: """ . mode . """")
	} Else	; error if no modes are used
		ScriptError("Please set an Application, SteamID, Steam Browser Protocol, or URL in " moduleName . ".ini for """ . dbName . """")

	If (SteamID && Application)	; do not allow 2 launching methods as module cannot know which should be used
		ScriptError("You are trying to use Steam and an Application, you must choose one or the other.")

	If ((mode = "steam" || mode = "steambp") && !AppWaitExe && !FadeTitle) { ; && fadeIn = "true") {	; If AppWaitExe or FadeTitle are defined, that will take precedence over the automatic method using the SteamIDs.ini
		SteamIDFile := new IniFile(modulePath . "\SteamIDs.ini")
		SteamIDFile.CheckFile()
		If !SteamID		; if this game does not have a SteamID defined
			StringUtils.SplitPath(Application,SteamID) ; try to grab the ID from the Application name
		SteamIDExe := SteamIDFile.ReadCheck(SteamID, "exe",,,1)
		If !SteamIDExe		; if it was still not found, error out
			ScriptError("You are using launching a Steam game but no way for the module to know what window to wait for after launching. Please set a AppWaitExe, FadeTitle, or make sure your SteamID and the correct exe is defined in the SteamIDs.ini",10)
		Else {
			RLLog.Info("PCLauncher - Found an exe in the SteamIDs.ini for this game: """ . SteamIDExe . """")
			SteamIDExe := new Process(SteamIDExe)
		}
	} Else If (mode = "url" && !AppWaitExe && !FadeTitle)
		ScriptError("You are using launching a URL but no way for the module to know what to window to wait for after launching. Please set a AppWaitExe or FadeTitle to your default application that gets launched when opening URLs.",10)
	
	If (appIsImage && !primaryExe.FilePath)	; if user only defined an exe for Application with no path, assume it will be found on the root dir of the image when mounted
		primaryExe.FilePath := vdDriveLetter . ":\"
	If (!primaryExe.FileName && mode = "standard" && (mode != "steam" || mode != "steambp"))
		ScriptError("Missing filename on the end of your Application in " . moduleName . ".ini:`n" . primaryExe.FileFullPath)
	If (!primaryExe.FileExt && mode = "standard" && (mode != "steam" || mode != "steambp"))
		ScriptError("Missing extension on your Application in " . moduleName . ".ini:`n" . primaryExe.FileFullPath)

	PreLaunchExe := AltAppCheck(PreLaunch,"PreLaunch",PreLaunchIsURL)
	PostLaunchExe := AltAppCheck(PostLaunch,"PostLaunch",PostLaunchIsURL)
	PostExitExe := AltAppCheck(PostExit,"PostExit",PostExitIsURL)

	If (mode = "standard")
		primaryExe.CheckFile("Cannot find this Application:`n" . primaryExe.FileFullPath)	; keeping this last so more descriptive errors will trigger first
	RLLog.Info("CheckSettings - Ended")
}

AltAppCheck(file,id,ByRef urlID) {
	If file {
		obj := new Process(file)
		urlID := If (StringUtils.SubStr(file,1,4)="http" || StringUtils.SubStr(file,1,3)="ste") ? 1:""
		If urlID
			RLLog.Info("PCLauncher - " . id . " is a URL or Steam Browser Protocol: " . file)
		Else {
			StringUtils.BackslashCheck(obj.FileFullPath,id)
			obj.CheckFile("Cannot find this " . id . " application:`n" . obj.FileFullPath)
		}
		Return obj
	}
}

HaltEmu:
	CustomFunction.HaltGame()
Return

RestoreEmu:
	CustomFunction.RestoreGame()
Return

CloseProcess:
	If (ExitMethod != "InGame") {
		FadeOutStart()
		If (ExitMethod = "Process Close AppWaitExe" && AppWaitExe) {
			RLLog.Info("CloseProcess - ExitMethod is ""Process Close AppWaitExe""")
			AppWaitExe.Process("Close")
		} Else If (ExitMethod = "WinClose AppWaitExe" && AppWaitExe) {
			RLLog.Info("CloseProcess - ExitMethod is ""WinClose AppWaitExe""")
			AppWaitExe.Process("Exist")
			AppWaitWindow := new Window(new WindowTitle(,,,,AppWaitExe.PID))
			AppWaitWindow.Close()
		} Else If (ExitMethod = "Process Close Application") {
			RLLog.Info("CloseProcess - ExitMethod is ""Process Close Application""")
			primaryExe.Process("Close")
		} Else If (ExitMethod = "WinClose Application" && FadeTitle) {
			RLLog.Info("CloseProcess - ExitMethod is ""WinClose Close Application""")
			appPrimaryWindow.Close()
		} Else If (ExitMethod = "Send Alt+F4") {
			RLLog.Info("CloseProcess - ExitMethod is ""Send Alt+F4""")
			KeyUtils.Send("!{F4}")
		} Else {
			RLLog.Info("CloseProcess - Default ExitMethod`, using ""WinClose""")
			appPrimaryWindow.Close()
		}
	}
Return
