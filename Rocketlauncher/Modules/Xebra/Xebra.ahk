MEmu := "Xebra"
MEmuV := "v08/15/2013"
MURL := ["http://drhell.web.fc2.com/ps1/"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "118F359C"
iCRC := "66901F56"
MID := "635038268936701199"
MSystem := ["Sony PlayStation"]
;----------------------------------------------------------------------------
; Notes:
; Make sure you have a Playstation BIOS file in your emulator directory. The BIOS must be named OSROM with no extension.
; On first time use, 2 memory card files will be created (BU00 and BU01)
; Will load CUE and CCD files automatically, no Virtual Drive needed, but built-in image is buggy and not suggested to use it.
; Bios will load first, then the game (takes about 5 seconds)
; If you get nothing but a black screen at boot, make sure the OSROM file is an actual BIOS. If this file is not correct, no games will work.
; The suggested bios to rename to OSROM is SCPH7502 as it is the only bios that Legend of Dragoon works with.
;
; Press F12 to enable / disable gui, change video and controller settings
; F1 Save state
; F7 Load state
; If a game does not work for you, try a different RUN setting by adding it to the Settings.ini
;
; Per-Game Run setting:
; Use RocketLauncherUI to set module and per-game settings.
;
; Per-Game XEBRA.INI setup:
; On first run of this module, it will create the GameINIPath defined below and copy your XEBRA.INI there as your Default
; If you want different emu settings for a specific game, play the game and make your changes. After you exit, copy the XEBRA.INI to your GameINIPath and rename it to match the gam name in your xml.
; Example, if your game name is Final Fantasy VII (USA) (Disc 1), then you will name it Final Fantasy VII (USA) (Disc 1).INI
; Next time you play the game, the module will overwrite your XEBRA,INI with the new ini you made.
; If you want to reset your default INI, just delete it. The next time you run the module, it will create a new default INI for you.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
; HideLoading := IniReadCheck(settingsFile, "Settings", "HideLoading","false",,1)		;	Hide the Open window on disc changes
GameINIPath := IniReadCheck(settingsFile, "Settings", "GameINIPath",emuPath . "\GameINIs",,1)		 ; This is the path to your per-game XEBRA.INI(s). (default is %emuPath%\GameINIs)
defXebraINI := IniReadCheck(settingsFile, "Settings", "defXebraINI","XEBRA.default.INI",,1)	 ; Your default XEBRA.INI you want to use
AutoGameINIs := IniReadCheck(settingsFile, "Settings", "AutoGameINIs","false",,1)		 ; If true, will auto-backup your XEBRA.INI to the GameINIPath and rename it to match your game. This aids in creating per-game modules quickly. WARNING, this WILL overwrite existing backed-up game INIs.
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
memCardPath := IniReadCheck(settingsFile, "Settings", "MemCardPath", emuPath . "\memcards",,1)
memCardPath := AbsoluteFromRelative(emuPath, memCardPath)
vRun := IniReadCheck(settingsFile, romName, "run","1",,1)					 ; default is 1 (interprete)

BezelStart()

Fullscreen := If Fullscreen = "true" ? " -FULL" : ""
vRun := vRun=3 ? " -RUN3" : (vRun=2 ? " -RUN2" : " -RUN1")

; Per-Game INIs
IfNotExist, %GameINIPath%\%defXebraINI%
{	FileCreateDir, %GameINIPath%
	FileCopy, %emuPath%\XEBRA.INI, %GameINIPath%\%defXebraINI%, 1
}
gameINI := " -INI """ . GameINIPath . "\" . (If FileExist(GameINIPath . "\" . romName . ".INI") ? (romName . ".INI""") : (defXebraINI . """"))

; Memory Cards
If perGameMemCards = true
{	defaultMemCard1 := memCardPath . "\_default.BU00"	; defining default blank memory card for slot 1
	defaultMemCard2 := memCardPath . "\_default.BU10"	; defining default blank memory card for slot 2
	memCardName := If romTable[1,5] ? romTable[1,4] : romName	; defining rom name for multi disc rom
	romMemCard1 := memCardPath . "\" . memCardName . ".BU00"		; defining name for rom's memory card for slot 1
	romMemCard2 := memCardPath . "\" . memCardName . ".BU10"		; defining name for rom's memory card for slot 2
	memCard1 := emuPath . "\BU00"
	memCard2 := emuPath . "\BU10"
	IfNotExist, %memCardPath%
		FileCreateDir, %memCardPath%	; create memcard folder if it doesn't exist
	Loop 2 {
		IfNotExist, % defaultMemCard%A_Index%
			FileCopy, % memCard%A_Index%, % defaultMemCard%A_Index%	; if default cards do not exist, create them from the current memory cards
		IfExist, % romMemCard%A_Index%
		{	FileCopy, % romMemCard%A_Index%, % memCard%A_Index%		; if rom mem cards exist, copy them over to the emuPath so they can be used in game
			Log("Module - Switched memory card in Slot " . A_Index . " to: " . romMemCard%A_Index%)
		}
	}
}

; Xebra's Pause and exit commands changed in each version
FileGetSize, xebraExeSize, %emuPath%\%executable%	; Xebra does not have any file properties. The only distinguishable difference is file size
If (xebraExeSize > 200000) {			; circa 2015
	wParamPause := "00279"
	wParamExit := "00273"
} Else If (xebraExeSize > 140000) {	; circa 2011
	wParamPause := "00276"
	wParamExit := "00272"
} Else {								; circa 2013
	wParamPause := "00278"
	wParamExit := "00273"
}
Log("Module - Using wParam """ . wParamPause . """ to Pause and wParam """ . wParamExit . """ to Exit Xebra")

hideEmuObj := Object("XEBRA ahk_class #32770",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

; If ((romExtension = ".cue" || romExtension = ".ccd") && vdEnabled = "false" )
	; ScriptError("Xebra does not support mounting cue or ccd images with the built-in image handler. Please enable Virtual Drive support to load this game: " . romPath . "\" . romName . romExtension)

HideEmuStart()

; Mount the CD using Virtual Drive
If ((romExtension = ".cue" || romExtension = ".ccd") && vdEnabled = "true") {
	VirtualDrive("get")
	VirtualDrive("mount",romPath . "\" . romName . romExtension)
	usedVD := 1
	Run(executable . gameINI . Fullscreen . " -SPTI " . vdDriveLetter . vRun, emuPath)
} Else If (romExtension = ".cue") {
	ScriptError("Xebra's image handler does not work with cues. Please change your Rom Extension order so cues are last or remove them from the extension list. Or you can enable Virtual Drive support.")
} Else
	Run(executable . gameINI . Fullscreen . (If romExtension = ".cue" ? " -CUE" : "") . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("XEBRA ahk_class #32770")
WinWaitActive("XEBRA ahk_class #32770")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)

If usedVD
	VirtualDrive("unmount")

If AutoGameINIs = true
	FileCopy, %emuPath%\XEBRA.INI, %GameINIPath%\%romName%.INI, 1

If perGameMemCards = true
	Loop 2
	{	FileCopy, % memCard%A_Index%, % romMemCard%A_Index%, 1		; Backup (overwrite) the mem cards to the mem card folder for next time this game is launched
		Log("Module - Backing up Slot " . A_Index . " memory card to: " . romMemCard%A_Index%)
	}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
; HideLoading = true
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from Virtual Drive
	If usedVD {
		VirtualDrive("unmount")
		Sleep, 500	; Required to prevent your Virtual Drive from bugging
		; Mount the CD using Virtual Drive
		VirtualDrive("mount",selectedRom)
	} ;Else {	; currently not working as expected
		; If HideLoading = true
			; SetTimer, WaitForDialog, 2
		; PostMessage, 0x111, 00281,,,XEBRA ahk_class #32770	; Open Shell
		; Sleep, 500
		; PostMessage, 0x111, 00257,,,XEBRA ahk_class #32770	; Open CD-ROM Image
		; OpenROM(dialogOpen . " ahk_class #32770", selectedRom)
		; WinWaitActive("XEBRA ahk_class #32770")
		; Sleep, 1000
		; PostMessage, 0x111, 00282,,,XEBRA ahk_class #32770	; Close Shell
	; }
Return

WaitForDialog:
	IfWinNotExist, %dialogOpen% ahk_class #32770
		Return
	Else
		WinSet, Transparent, 0, %dialogOpen% ahk_class #32770
Return

CloseProcess:
	FadeOutStart()
	PostMessage, 0x111, %wParamPause%,,,XEBRA ahk_class #32770	; if we don't pause it first, xebra does not know how to exit properly.
	Log("Module - Sent command to pause Xebra so it can exit cleanly")
	Sleep, 1000
	PostMessage, 0x111, %wParamExit%,,,XEBRA ahk_class #32770	; Exit
	Log("Module - Sent command to exit Xebra")
Return
