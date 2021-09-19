MEmu := "FS-UAE"
MEmuV := "v2.6.2"
MURL := ["http://fs-uae.net/"]
MAuthor := ["djvj","faahrev","rfancella"]
MVersion := "2.0.5"
MCRC := "F117B7BE"
iCRC := "63CE47AD"
MID := "635637153627970100"
MSystem := ["Commodore Amiga","Commodore Amiga CD32","Commodore CDTV"]
;----------------------------------------------------------------------------
; Notes:
; Command Line Options - http://fs-uae.net/options
;
; Fade-, Bezel- and MultiGame supported.
; Be sure to set the paths to the BIOS roms in the Global Module Settings in RocketLauncherUI.
;
; Extensions for Amiga are .adf, .hdf or .zip
; Extension for AmigaCD32 and CDTV is cue
;
; .hdf and .zip are not MultiGame compatible
;
; If a rom consists of multiple discs,
; the discs will be automatically added to the swap list in FS-UAE (ingame F12)
; plus:
; If the media is floppies (adf) up to 4 discs will be inserted in the drives.
; Don't forget to set MultiGame to true in RocketLauncherUI for each system you wish to use it.
;
; By pressing F12 in the game any disc can be inserted in any drive
; and savestates can be saved and loaded.
; These are saved in emu\config\save states.
;
; Be sure to use the correct format for naming the discs
;
; By default the EmuDir\config.fs-uae file will be used for setting options
; If it doesn't exist, it will be created.
;
; Note: please be patient when loading floppy games.
; Floppies are loaded in real-time for best results.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; This object controls how the module reacts to different systems. FS-UAE can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Commodore Amiga","A1200","Commodore Amiga CD32","CD32/FMV","Commodore CDTV","CDTV")
ident := mType[systemName]      ; search object for the systemName identifier FS-UAE uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module: " . moduleName)
     
settingsFile := modulePath . "\" . moduleName . ".ini"
configFile := emuPath . "\config.fs-uae"
baseDir := emuPath . "\conf"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
fullscreenRes := IniReadCheck(settingsFile, "Settings", "FullscreenResolution",,,1)
windowedRes := IniReadCheck(settingsFile, "Settings", "WindowedResolution",,,1)
a1200Rom := IniReadCheck(settingsFile, "Settings", "A1200_Rom",,,1)
cd32Rom := IniReadCheck(settingsFile, "Settings", "CD32_Rom",,,1)
cd32ExtRom := IniReadCheck(settingsFile, "Settings", "CD32_Ext_Rom",,,1)
cdTVRom := IniReadCheck(settingsFile, "Settings", "CDTV_Rom",,,1)
cdTVExtRom := IniReadCheck(settingsFile, "Settings", "CDTV_Ext_Rom",,,1)
whdBootPath := IniReadCheck(settingsFile, "Settings", "WHDBootPath", emuPath . "\Hard Disks\WHDLoad\Boot",,1)
whdBootPath := AbsoluteFromRelative(emuPath, whdBootPath)
shader := IniReadCheck(settingsFile, "Settings", "Shader",,,1)
floppySounds := IniReadCheck(settingsFile, "Settings", "FloppySounds","on",,1)
; amigaModel := IniReadCheck(settingsFile, "Settings", "AmigaModel","A1200",,1)         ; possible choices are A500+,A600,A1000,A1200,A1200/020,A3000,A4000/040,CD32,CDTV
; autoResume := IniReadCheck(settingsFile, "Settings", "autoResume","true",,1)          ; if true, will automatically save your game's state on exit and reload it on the next launch of the same game.

;clearing all settings in config for floppy, hard and cdrom, drive and image
LoopString := "floppy|hard|cdrom"
Log("Module - Started checking all drive and image values are nulled out in " . MEmu . "'s config")
Loop, 4
{	driveNumber := A_Index - 1
	Loop, parse, LoopString, |
	{	
		IniRead, driveValue, %configFile%, fs-uae, %A_LoopField%_drive_%driveNumber%
		If (driveValue != "" && driveValue != "ERROR") {
			IniWrite, %A_Space%, %configFile%, fs-uae, %A_LoopField%_drive_%driveNumber%
			Log("Module - Setting empty value for " . A_LoopField . "_drive_" . driveNumber)
		}
		Loop, 9
		{
			imageNumber := A_Index - 1
			IniRead, imageValue, %configFile%, fs-uae, %A_LoopField%_image_%imageNumber%
			If (imageValue != "" && imageValue != "ERROR") {
				IniWrite, %A_Space%, %configFile%, fs-uae, %A_LoopField%_image_%imageNumber%
				Log("Module - Setting empty value for " . A_LoopField . "_image_" . imageNumber)
			}
		}
	}
}
Log("Module - Finished checking all drive and image values")

BezelStart()

If (ident = "A1200")
{	a1200Rom := CheckFile(GetFullName(a1200Rom), "Could not find your A1200_Rom. " . systemName . " first requires the ""A1200_Rom"" to be set in RocketLauncherUI's module settings for " . MEmu . ".")
	kickstartBios := "" . a1200Rom . ""
	; fastmem := " --fast_memory=8192"
	IniWrite, 8192, %configFile%, fs-uae, fast_memory ; write fastmem size
}Else If (ident = "CD32/FMV")
{	cd32Rom := CheckFile(GetFullName(cd32Rom), "Could not find your CD32_Rom. " . systemName . " first requires the ""CD32_Rom"" to be set in RocketLauncherUI's module settings for " . MEmu . ".")
	cd32ExtRom := CheckFile(GetFullName(cd32ExtRom), "Could not find your CD32_Ext_Rom. " . systemName . " first requires the ""CD32_Ext_Rom"" to be set in RocketLauncherUI's module settings for " . MEmu . ".")
	kickstartBios := "" . cd32Rom . ""
	kickstartExtBios := "" . cd32ExtRom . ""
}Else If (ident = "CDTV")
{	cdTVRom := CheckFile(GetFullName(cdTVRom), "Could not find your CDTV_Rom. " . systemName . " first requires the ""CDTV_Rom"" to be set in RocketLauncherUI's module settings for " . MEmu . ".")
	cdTVExtRom := CheckFile(GetFullName(cdTVExtRom), "Could not find your CDTV_Ext_Rom. " . systemName . " first requires the ""CDTV_Ext_Rom"" to be set in RocketLauncherUI's module settings for " . MEmu . ".")
	kickstartBios := "" . cdTVRom . ""
	kickstartExtBios := "" . cdTVExtRom . ""
}
;amigaModel := " --amiga_model=" . ident
;fullscreen := " --fullscreen=" . (If Fullscreen = "true" ? 1 : 0)
;fullscreenMode := " --fullscreen_mode=fullscreen-window"        ; sets fullscreen windowed rather than true fullscreen

fullscreen := (If Fullscreen = "true" ? 1 : 0)
IniWrite, %fullscreen%, %configFile%, fs-uae, fullscreen
IniWrite, fullscreen-window, %configFile%, fs-uae, fullscreen_mode ; sets fullscreen windowed rather than true fullscreen
If (fullscreen = "true" && fullscreenRes != "") {
	Loop, Parse, fullscreenRes, x
		If (A_index = 1)
			fsuaeW := A_LoopField
		Else
			fsuaeH := A_LoopField
	IniWrite, %fsuaeW%, %configFile%, fs-uae, fullscreen_width
	IniWrite, %fsuaeH%, %configFile%, fs-uae, fullscreen_height
} Else If (fullscreen != "true" && windowedRes != "") {
	Loop, Parse, windowedRes, x
		If (A_index = 1)
			fsuaeW := A_LoopField
		Else
			fsuaeH := A_LoopField
	IniWrite, %fsuaeW%, %configFile%, fs-uae, window_width
	IniWrite, %fsuaeH%, %configFile%, fs-uae, window_height
}

hideEmuObj := Object(ident,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)
    
; stateName := emuPath . "\states\" . romName . ".uss"
   
If RegExMatch(romExtension,"i)\.adf|\.zip")
	gamePathMethod := "floppy_"
Else If (romExtension = ".hdf")
	gamePathMethod := "hard_"
Else If (romExtension = ".whd")
	{	gamePathMethod := "hard_"
		WHDBP := "" . WHDBootPath . """ --hard_drive_1="""
	}
Else If (romExtension = ".cue")
		gamePathMethod := "cdrom_"
Else
	ScriptError("Unsupported extension supplied: """ . romExtension . """.") ; iso is not supported or mounting will not work

gamePath := " --" . gamePathMethod . "drive_0" . "=""" . WHDBP . "" . romPath . "\" . romName . romExtension . """"

;injecting other variables in config file
IniWrite, %baseDir%, %configFile%, fs-uae, base_dir
IniWrite, %ident%, %configFile%, fs-uae, amiga_model ; write model to fs-uae
IniWrite, %kickstartBios%, %configFile%, fs-uae, kickstart_file ; write rom to fs-uae
IniWrite, %kickstartExtBios%, %configFile%, fs-uae, kickstart_ext_file ; write extended rom to fs-uae
IniWrite, %kickstartExtBios%, %configFile%, fs-uae, kickstart_ext_file ; write extended rom to fs-uae
IniWrite, %shader%, %configFile%, config, shader ; write shader to fs-uae
IniWrite, %floppySounds%, %configFile%, config, floppy_drive_0_sounds ; write floppy_drive_0_sounds to fs-uae

If RegExMatch(romTable[1,6],"i)Disk|Disc")
{	;StringTrimRight, romNameNoDisc, romName, 9	; gets gamename
	gamePath := ""
	Loop, 9
		If (romTable[A_Index,1] != "")
		{
			If (A_Index <= 4)
				gamePath .= " --" . gamePathMethod . "drive_" . A_Index-1 . "=""" . romTable[A_Index,1] . """"		; drives are loaded on runtime into floppy drives
			gamePath .= " --" . gamePathMethod . "image_" . A_Index-1 . "=""" . romTable[A_Index,1] . """"			; images are for the swap list
		}
}

HideEmuStart()
Run(executable . " " . gamePath . " " . configFile, emuPath)

/*
If (FileExist(stateName) and autoResume="true") {
	clipboard = %stateName%
	WinWait("ahk_class AmigaPowah")
	Send {F7}     ; open load state window
	WinWait("Restore a WinUAE snapshot file")
	Send ^v
	Send {Enter}
}
*/

WinWait("FS-UAE ahk_class SDL_app")
WinWaitActive("FS-UAE ahk_class SDL_app")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()

/*
GroupAdd,DIE,DIEmWin
GroupClose, DIE, A
*/

ExitModule()


CloseProcess:
	; If (FileExist(stateName) and autoResume="true")
	; Send {F5}     ; open save state window
	FadeOutStart()
	; If (FileExist(stateName) and autoResume="true") {
	; clipboard = %stateName%       ; just in case something happened to clipboard in between start of module to now
	; WinWait("Save a WinUAE snapshot file")
	; Send ^v
	; Send {Enter}
	; Sleep, 50     ; always give time for a file operation to occur before closing an app
	; }
	WinClose("FS-UAE ahk_class SDL_app")
Return
