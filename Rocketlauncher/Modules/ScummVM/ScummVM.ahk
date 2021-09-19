MEmu := "ScummVM"
MEmuV := "v1.7.0"
MURL := ["http://scummvm.org/"]
MAuthor := ["djvj","brolly"]
MVersion := "2.1.5"
MCRC := "F6092CC4"
iCRC := "58B0E4D6"
MID := "635038268922749586"
MSystem := ["ScummVM","Microsoft MS-DOS"]
;----------------------------------------------------------------------------
; Notes:
; If your games are compressed archives, set your Rom_Path to the folder with all your games and Rom_Extension to just the archive type.
; Set Skipchecks to "Rom Extension" for this system If your roms are compressed archives and also turn on 7z support.
; If your games are already uncompressed into their own folders, set Skipchecks to "Rom Only" so RocketLauncher knows not to look for rom files.
;
; ScummVM will save the scummvm.ini file to %AppData%\ScummVM\scummvm.ini
; To add multiple games to ScummVM, put the mouse on top of the "Add Game" button and press Shift, the button caption will change to Mass Add, then click the button 
; and navigate to the main folder where you have all your uncompressed ScummVM games.
;
; You can set your Save/Load/Menu hotkeys below to access them in game.
; The hotkeys will be processed by xHotkey, so they can be defined just like you would your Exit_Emulator_Key (like with delays or multiple sets of keys)
;
; If you prefer a portable ScummVM, place your scummvm.ini somewhere Else, like in the emulator's folder and set CustomConfig's path to this file. It will work with the ini from there instead of your appdata folder.
;
; You can manually map your database rom names to archive files If you keep your games compressed and have the files named differently from your database by putting a file named ZipMapping.ini in the modules folder (or ZipMapping - SystemName.ini), this file contents should be as follows:
; [mapping]
; romName=zipFileName
;
; Launch Method 1 - Rom_Path has archived games inside a zip, 7z, rar, etc
; Set Skipchecks to Rom Extension and enable 7z
; Launch Method 2 - Rom_Path has each game inside its own folder and uncompressed
; Set Skipchecks to Rom Only and disable 7z
; Launch Method 3 - Rom_Path has archived games inside a zip, 7z, rar, etc, all named from the scummvm torrent that does not match the names on your xml
; Set Skipchecks to Rom Extension, enable 7z, enable Rom Mapping. Make sure a proper mapping ini exists in the appropriate settings Rom Mapping folder and it contains all the correct mapping info.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"SDL_app"))		; instantiate primary emulator window object

scummDefaultConfigFile := A_AppData . "\ScummVM\scummvm.ini"	; ScummVM's default ini file it creates on first launch
customConfigFile := moduleIni.Read("Settings", "CustomConfig",,,1)	; Set the path to a custom config file and the module will use this instead of the ScummVM's default one
customConfigFile := GetFullName(customConfigFile)	; convert relative path to absolute
configFile := CheckFile(If customConfigFile ? customConfigFile : scummDefaultConfigFile)	; checks If either the default config file or the custom one exists
Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
LaunchMode := moduleIni.Read(romName . "|Settings", "LaunchMode", "Auto",,1)
GraphicFilter := moduleIni.Read(romName . "|Settings", "GraphicFilter", "Normal",,1)
TargetName := moduleIni.Read(romName, "TargetName", romName,,1)
ForceExtractionToRomPath := moduleIni.Read(romName . "|Settings", "ForceExtractionToRomPath", "false",,1)
BezelDelay := moduleIni.Read(romName . "|Settings", "BezelDelay", "0",,1)

SaveKey := moduleIni.Read("Settings", "SaveKey","1",,1)		; hotkey to save state
LoadKey := moduleIni.Read("Settings", "LoadKey","2",,1)		; hotkey to load state
MenuKey := moduleIni.Read("Settings", "MenuKey","p",,1)		; hotkey to access the ScummVM menu

BezelStart()

If (sevenZEnabled != "true")
	If StringUtils.Contains(romExtension,sevenZFormatsRegEx)
		ScriptError("Your rom """ . romName . """ is a compressed archive`, but you have 7z support disabled. ScummVM does not support launching compressed roms directly. Enable 7z or extract your rom.",8)

;Find the zip filename by looking it up in the ZipMapping.ini file or ZipMapping - SystemName.ini If one exists
ZimMapGlobalIni := new IniFile(modulePath . "\ZipMapping.ini")
ZimMapSystemIni := new IniFile(modulePath . "\ZipMapping - " . systemName ".ini")
ZipMappingIni := If ZimMapIni.Exist() ? ZimMapSystemIni : ZimMapGlobalIni
ZipName := ZipMappingIni.ReadCheck("mapping", romname, romname . (If romExtension ? romExtension : ".zip"),,1)

If (LaunchMode = "eXoDOS") {
	;Find and set the romPath in case we have several
	romPathFound := "false"
	If (sevenZEnabled = "true")
	{
		Loop, Parse, romPath, |
		{
			currentPath := A_LoopField
			RLLog.Debug("Module - Searching for rom " . ZipName . " in " . currentPath)
			
			ZippedPath := new Folder(currentPath . "\" . ZipName)
			If ZippedPath.Exist()
			{
				romPath := currentPath
				romPathFound := "true"
				Break
			}
			ZippedPath.__Delete()
			ZippedPath := ""
		}
		If (romPathFound != "true")
			ScriptError("Couldn't find rom " . ZipName . " in any of the defined rom paths")
	} Else {
		Loop, Parse, romPath, |
		{
			currentPath := A_LoopField
			RLLog.Debug("Module - Searching for rom " . romname . " in " . currentPath)
			TempRomPath := new Folder(currentPath . "\" . romname)
			If StringUtils.InStr(TempRomPath.Exist("folder"), "D")
			{
				romPath := currentPath
				romPathFound := "true"
				Break
			}
			TempRomPath.__Delete()
			TempRomPath := ""
		}
		If (romPathFound != "true")
			ScriptError("Couldn't find rom " . romname . " in any of the defined rom paths")
	}
	
	If (ForceExtractionToRomPath = "true") {
		RLLog.Warning("Module - ForceExtractionToRomPath is set to true, setting sevenZExtractPath to " . romPath . ". Careful when using this setting!")
		sevenZExtractPath := romPath
	}
}

;Lets split filename and extension
StringUtils.SplitPath(ZipName,,,zipExtension,zipFileName)

hideEmuObj := Object(emuPrimaryWindow,1)
;7z(romPath, romName, romExtension, sevenZExtractPath)
7z(romPath,zipFileName,"." . zipExtension,sevenZExtractPath,,If LaunchMode = "eXoDOS" ? "false" : "true")

ScummDefaultRomPath := new File (romPath . "\" . romName)

; Send ScummVM hotkeys through xHotkey so they are linked to the labels below
SaveKey := xHotKeyVarEdit(SaveKey,"SaveKey","~","Add")
LoadKey := xHotKeyVarEdit(LoadKey,"LoadKey","~","Add")
MenuKey := xHotKeyVarEdit(MenuKey,"MenuKey","~","Add")
xHotKeywrapper(SaveKey,"ScummvmSave")
xHotKeywrapper(LoadKey,"ScummvmLoad")
xHotKeywrapper(MenuKey,"ScummvmMenu")

If (LaunchMode = "ParseIni")
{	RLLog.Info("Module - Launch mode: ParseIni")
	;Try parsing the scummvm config ini file for the path
	romNameChanged := StringUtils.Replace(TargetName, A_Space, "_", "All")	; replace all spaces in the name we lookup in ScummVM's ini because ScummVM does not support spaces in the section name
	romNameChanged := StringUtils.RegExReplace(romNameChanged, "\(|\)", "_")	; replaces all parenthesis with underscores
	If (TargetName != romNameChanged)
		RLLog.Info("Module - Removed all unsupported characters from """ . TargetName . """ and using this to search for a section in ScummVM's ini: """ . romNameChanged . """")

	ScummVMConfigIni := new IniFile(configFile)
	ScummRomPath := new File(ScummVMConfigIni.ReadCheck(romNameChanged, "path",,,1))	; Grab the path in ScummVM's config
	; msgbox % scummRomPath
	If (StringUtils.SubStr(ScummRomPath.FileFullPath, 0, 1) = "\")	; scummvm doesn't like sending it paths with a \ as the last character. If it exists, remove it.
		scummRomPathEdit := StringUtils.TrimRight(ScummRomPath.FileFullPath,1)
	; msgbox % scummRomPath
	If !ScummRomPath.FileFullPath {
		RLLog.Warning("Module - Could not locate a path in ScummVM's ini for section """ . romNameChanged . """. Checking If a path exists for the dbName instead: """ . dbName . """")
		scummRomPathEdit := ScummVMConfigIni.ReadCheck(dbName, "path",,,1)	; If the romName, after removing all unsupporting characters to meet ScummVM's section name requirements, could not be found, try looking up the dbName instead
	}
	If !ScummRomPath.Exist()	; If user does not have a path set to this game in the ScummVM ini or the path does not exist that is set, attempt to send a proper one in CLI
	{	RLLog.Warning("Module - " . (If !ScummRomPath.FileFullPath ? "No path defined in ScummVM's ini" : ("The path defined in ScummVM's ini does not exist : " . ScummRomPath.FileFullPath)) . ". Attempting to find a correct path to your rom and sending that to ScummVM.")
		If (StringUtils.InStr(romPath, romName) && ScummDefaultRomPath.Exist("folder")) {	; If the romName is already in the path of the romPath and that path exists, attempt to set that as the path we send to ScummVM
			scummRomPathEdit := romPath
			RLLog.Warning("Module - Changing " . romName . " path to: " . scummRomPathEdit)
		} Else If ScummDefaultRomPath.Exist() {	; If the romPath doesn't have the romName in the path, let's add it to check If that exists and send that.
			scummRomPathEdit := ScummDefaultRomPath.FileFullPath
			RLLog.Warning("Module - Changing " . romName . " path to: " . scummRomPathEdit)
		} Else
			ScriptError("The path to """ . romName . """ was not found. Please set it correctly by manually launching ScummVM and editing this rom's path to where it can be found.")
	}
} Else If (LaunchMode = "eXoDOS") {
	RLLog.Info("Module - Launch mode: eXoDOS")
	;On eXoDOS sets game MUST be at this folder
	ScummDefaultRomPath.CheckFile()
	romNameChanged := TargetName
} Else {
	RLLog.Info("Module - Launch mode: Standard")
	;Auto mode, scummRomPath will be empty here as everything will be read from the scummvm config ini file
	romNameChanged := TargetName
}

options := " --no-console"
configFile := If customConfigFile ? " -c""" . configFile . """" : ""		; If user set a path to a custom config file
fullscreen := If Fullscreen = "true" ? " -f" : " -F"
scummRomPathEdit := If scummRomPathEdit ? " -p""" . scummRomPathEdit . """" : ""

If BezelEnabled() {
	GraphicFilter := " -gopengl_nearest"
	RLLog.Warning("Module - Forcing GraphicFilter opengl_nearest to support bezels")
} Else
	GraphicFilter := If GraphicFilter ? " -g" . GraphicFilter : ""

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(options . fullscreen . configFile . GraphicFilter . scummRomPathEdit . " " . romNameChanged)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

TimerUtils.Sleep(700) ; Necessary otherwise your Front End window flashes back into view

If BezelEnabled()
	TimerUtils.Sleep(bezelDelay)

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp(If LaunchMode = "eXoDOS" ? sevenZExtractPath . "\" . romName : "")
BezelExit()
FadeOutExit()
ExitModule()


ScummvmSave:
	KeyUtils.Send("!1")
Return
ScummvmLoad:
	KeyUtils.Send("^1")
Return
ScummvmMenu:
	KeyUtils.Send("^{F5}")
Return

HaltEmu:
	If SaveKey
		XHotKeywrapper(SaveKey,"ScummvmSave","OFF")
	If LoadKey
		XHotKeywrapper(LoadKey,"ScummvmLoad","OFF")
	If MenuKey
		XHotKeywrapper(MenuKey,"ScummvmMenu","OFF")
Return

RestoreEmu:
	If SaveKey
		XHotKeywrapper(SaveKey,"ScummvmSave","ON")
	If LoadKey
		XHotKeywrapper(LoadKey,"ScummvmLoad","ON")
	If MenuKey
		XHotKeywrapper(MenuKey,"ScummvmMenu","ON")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
