MEmu := "Casual Games"
MEmuV := "N/A"
MURL := [""]
MAuthor := ["djvj"]
MVersion := "2.0.6"
MCRC := "8E4287F2"
iCRC := "E03C9608"
MID := "635038268877672071"
MSystem := ["PopCap","Big Fish Games"]
;----------------------------------------------------------------------------
; Notes:
; Default location for all the games will be your Rom_Path\romName\romName.exe:
; Rom_Path needs to point to a folder that contains all subfolders, one for each game, named to match your xml:
;
; Example:
; Rom_Path = C:\Roms
; romName = Alchemy Deluxe
; The module will look in C:\Roms\Alchemy Deluxe\Alchemy Deluxe.exe
;
; In each of these folders, you should have an exe named after the rom name in your xml. This means you might have to rename the exes. If a game does not like this, utilize the module setting to define a gamePath like below.
; If you don't place your games like the above example by utilizing Rom_Path, use RocketLauncherUI to create per-game exectuable paths to each game like this:
;
; Example:
; [Alchemy Deluxe]
; gamePath = C:\Roms\Alchemy Deluxe\AlcDeluxe.exe
;
; You no longer use blank txt files with this module.
; Set SkipChecks to "Rom and Emu" when using this module.
; If you have a problem with Fade In not closing after the game is up, set the FadeTitle module setting in RocketLauncherUI for that game. It works the same as PCLauncher.
; Exit the games via their main menus to guarantee high score saving. If you use your exit key, it might not save correctly. Because of this, you can keep Fade Out disabled as it would never trigger when exiting.
; If you get a security warning when you launch a game, follow this guide to disable them:
; 1 - Open Internet explorere and click the gear icon, then Internet Options.
; 2 - Goto the Security tab, click Internet and then Custom Level
; 3 - Scroll down till you see "Launching applications and unsafe files" and set it to "Enable"
; 4 - Click OK and exit out of IE.
; Alternately you can follow additional options here: http://www.sevenforums.com/tutorials/182353-open-file-security-warning-enable-disable.html
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

remapWinKeys := moduleIni.Read("Settings", "remapWinKeys", "true",,1)
gamePath := moduleIni.Read(romName, "gamePath", A_Space,,1)
fadeTitle := moduleIni.Read(romName, "FadeTitle", A_Space,,1)
forceCursor := moduleIni.Read(romName . "|Settings", "ForceCursor", "true",,1)

If StringUtils.Contains(romExtension,"\.zip|\.7z|\.rar")
	ScriptError("Compressed games are not supported in this Casual Games Module. Please extract your games to their own folder and correctly configure a gamePath in the module's ini.")

If (gamePath && (gamePath != "" || gamePath != "ERROR")) {
	gamePath := GetFullName(gamePath)
	gamePathFile := new File(gamePath)
}

If !gamePathFile.Exist() {
	RLLog.Warning("Module - GamePath is not set or is not pointing to this game correctly. Attempting to find it for you by using your Rom Path.")
	gamePathFile.__Delete()
	gamePathFile := new File(romPath . "\" . romName . ".exe")
	If gamePathFile.Exist()
		RLLog.Warning("Module - Game was found at: """ . gamePathFile.FileFullPath . """")
	Else {
		gamePathFile.__Delete()
		gamePathFile := new File(romPath . "\" . gamePathFile.FileFullPath)
		If (gamePathFile.Exist() && StringUtils.Right(gamePathFile.FileFullPath,1) != "\")
			RLLog.Warning("Module - Game was found at: " . gamePathFile.FileFullPath)
		Else {
			gamePathFile.__Delete()
			gamePathFile := new File(romPath . "\" . romName . "\" . romName . ".exe")
			If gamePathFile.Exist()
				RLLog.Warning("Module - Game was found at: " . gamePathFile.FileFullPath)
			Else
				ScriptError("Could not locate """ . romName . """ in your Rom Path or in the GamePath (Module setting) for this game. Please fix one or the other.")
		}
	}
} Else
	RLLog.Info("Module - Game was found in the user set GamePath at: " . gamePathFile.FileFullPath)

primaryExe := new Emulator(gamePathFile.FileFullPath)	; instantiate app executable object
primaryExe.CheckFile()

; This remaps windows Start keys to Return to prevent accidental leaving of game
If (remapWinKeys = "true")
{	Hotkey, RWin, WinRemap
	Hotkey, LWin, WinRemap
}

If fadeTitle {
	FadeTitleObj := StringUtils.ParsePCTitle(FadeTitle)
	appPrimaryWindow := new Window(new WindowTitle(FadeTitleObj.Title,FadeTitleObj.Class))	; instantiate primary application window object
	hideEmuObj := Object(appPrimaryWindow,1)
	HideAppStart(hideEmuObj,hideEmu)
}

errLvl := primaryExe.Run(,"UseErrorLevel")
If errLvl
	ScriptError("Failed to launch " . romName)

If fadeTitle {	; If fadeTitle is set, use that to detect the game, otherwise use the PID
	RLLog.Info("Module - FadeTitle set by user, waiting for """ . fadeTitle . """")
	appPrimaryWindow.Wait()
	appPrimaryWindow.WaitActive()
} Else {
	RLLog.Info("Module - FadeTitle not set by user, waiting for the App's PID: """ . primaryExe.PID . """")
	appPrimaryWindow := new Window(new WindowTitle(,,,,primaryExe.PID))	; instantiate primary application window object
	appPrimaryWindow.Wait()
	appPrimaryWindow.Get("ID")
	appPrimaryWindow.WinTitle.PID := ""	; remove PID from future window matches
	appPrimaryWindow.WinTitle.ID := appPrimaryWindow.ID	; inject hwnd ID so future matches use it instead
	hideEmuObj := Object(appPrimaryWindow,1)
	HideAppStart(hideEmuObj,hideEmu)
	appPrimaryWindow.Wait()
	appPrimaryWindow.WaitActive()
}
primaryExe.Process("Priority","High")

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

If (forceCursor = "true")
	SystemCursor("On")

; These conditionals are here to resolve win7 compatibility issues with these games (their exes don't close when you exit the game)
If (romName = "Super Collapse 3") {
	TimerUtils.Sleep(3000)
	SuperCollapseIIIWindow := new Window(new WindowTitle("Super Collapse! 3"))
	SuperCollapseIIIWindow.WaitNotActive()
	SuperCollapseIIIFile := new Process("SuperCollapseIII.exe")
	SuperCollapseIIIFile.Process("Close")
} Else If (romName = "Typer Shark Deluxe") {
	TimerUtils.Sleep(3000)
	TyperSharkWindow := new Window(new WindowTitle("Typer Shark Deluxe 1.02"))
	TyperSharkWindow.WaitNotActive()
	TyperSharkFile := new Process("TyperShark.exe")
	TyperSharkFile.Process("Close")
} Else
	primaryExe.Process("WaitClose")

FadeOutExit()
ExitModule()


WinRemap:
Return

CloseProcess:
	FadeOutStart()
	activeWin := WinExist("A")
	activeWindow := new Window(new WindowTitle(,,,activeWin))
	activeWindow.Get("ProcessPath")
	primaryExe.Process("Exist")
	RLLog.Debug("Module - DEBUG 5 (EXIT) - rom process: " . primaryExe.PID . " - active window HWND ID is " . activeWin . " and is located at: " . activeWindow.ProcessPath)
	appPrimaryWindow.Close()
Return
