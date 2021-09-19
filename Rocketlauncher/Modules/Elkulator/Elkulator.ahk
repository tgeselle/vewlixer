MEmu := "Elkulator"
MEmuV := "v1.0"
MURL := ["http://elkulator.acornelectron.co.uk/"]
MAuthor := ["brolly"]
MVersion := "1.0.0"
MCRC := "782C6FC"
iCRC := "B707731D"
MID := "635871547400102282"
MSystem := ["Acorn Electron"]
;----------------------------------------------------------------------------
; Notes:
;
; Most disk games will boot by issuing a SHIFT+F12 (which corresponds to a SHIFT+BREAK) on a real Electron
; For those that don't you will need to set the appropriate CHAIN or RUN commands in RLUI
; Common load commands are:
; CH."$.HAVEN"
; CH."$.MENU"
;
; If you need to find the correct CHAIN command for a game, load the disk on the emulator and type:
; *DISC
; *CAT
; Then check the name of the executable file. That's what you need to use for the CHAIN command.
;
; Compilations (Like PCW Games Collection) will always load first game, if you want to play following game, 
; reset machine and type CHAIN"" again.
;
; Alt+Esc exits the emulator when running in fullscreen
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
configFile := emuPath . "\elk.cfg"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FilterType := IniReadCheck(settingsFile, "Settings", "FilterType","1",,1)
TapeSpeed := IniReadCheck(settingsFile, "Settings" . "|" . romName, "TapeSpeed","2",,1)
WriteProtectDrives := IniReadCheck(settingsFile, "Settings" . "|" . romName, "WriteProtectDrives","true",,1)
ChainCommand := IniReadCheck(settingsFile, romName, "ChainCommand","",,1)
RunCommand := IniReadCheck(settingsFile, romName, "RunCommand","",,1)
CustomCommand := IniReadCheck(settingsFile, romName, "CustomCommand","",,1)
TapeLoadingMethod := IniReadCheck(settingsFile, romName, "TapeLoadingMethod","CHAIN",,1)
MultipleDiskDrive := IniReadCheck(settingsFile, romName, "MultipleDiskDrive","0",,1)

hideEmuObj := Object("ahk_class ElkWindow",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

If !RegExMatch(romExtension,"i)\.ssd|\.dsd|\.adf|\.adl|\.uef")
	ScriptError("The extension " . romExtension . " is not one of the known supported extensions for this emulator.")

If !FileExist(configFile)
	ScriptError("elk.cfg was not found at " . configFile)

configIni := LoadProperties(configFile)	; load the config into memory

If (romExtension = ".uef") { ;Tape
	WriteProperty(configIni, "tapespeed", TapeSpeed)
	WriteProperty(configIni, "plus3", "0")
} Else If (romExtension = ".adf" or romExtension = ".adl") { ;ADFS disk
	WriteProperty(configIni, "plus3", "1")
	WriteProperty(configIni, "adfsena", "1")
	WriteProperty(configIni, "dfsena", "0")
} Else If (romExtension = ".dsd" or romExtension = ".ssd") { ;DFS disk
	WriteProperty(configIni, "plus3", "1")
	WriteProperty(configIni, "adfsena", "0")
	WriteProperty(configIni, "dfsena", "1")
} Else {
	ScriptError("Module doesn't support the following romExtension : '" . romExtension . "'")
}

WriteProperty(configIni, "win_resize", "1")
WriteProperty(configIni, "filter", FilterType)
WriteProperty(configIni, "defaultwriteprotect", If WriteProtectDrives = "true" ? "1" : "0")

;MultiGame support for disk games (load both disks in the 2 drives)
If (romExtension != ".uef") {
	RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
	romCount := romTable.MaxIndex()
	If RegExMatch(romName,"i)\(Disk 1\)")
	{
		If (romCount > 1)
			SecondDisk := romTable[2,1]
	}
}

If (romExtension != ".uef") {
	WriteProperty(configIni, "discname_0", romPath . "\" . romName . romExtension)
	If (SecondDisk)
		WriteProperty(configIni, "discname_1", SecondDisk)
	Else
		WriteProperty(configIni, "discname_1", "")
}

SaveProperties(configFile,configIni)	; save changes to elk.cfg

BezelStart()
HideEmuStart()

Run(executable . " " . Fullscreen . Params, emuPath)

WinActivate, ahk_class ElkWindow
WinWaitActive("ahk_class ElkWindow")

If (WriteProtectDrives = "false")
{
	PostMessage, 0x111, 40037,,,ahk_class ElkWindow
	PostMessage, 0x111, 40038,,,ahk_class ElkWindow
}

If (romExtension = ".uef") {
	PostMessage, 0x111, 40011,,,ahk_class ElkWindow
	OpenROM("ahk_class #32770", romPath . "\" . romName . romExtension)

	If (TapeLoadingMethod = "RUN")
		SendCommand("oscli{vkDEsc028}run{vkDEsc028}{Enter}")
	Else
		SendCommand("ch.{Shift down}22{Shift up}{Enter}")
}
Else {
	If (ChainCommand)
		SendCommand("ch." . ChainCommand . "{Enter}")
	Else If (RunCommand)
		SendCommand("oscli{vkDEsc028}run " . RunCommand . "{vkDEsc028}{Enter}")
	Else If (CustomCommand)
		SendCommand(CustomCommand . "{Enter}")
	Else {
		SendCommand("{Shift down}{F12 down}{F12 up}{Shift up}",1000,,,200,200)
		;SendCommandDelay=2000, WaitTime=500, WaitBetweenSends=0, Delay=50, PressDuration=-1
	}
}
If (Fullscreen = "true")
	PostMessage, 0x111, 40070,,,ahk_class ElkWindow

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
Return
RestoreEmu:
Return

MultiGame:
	If (romExtension = ".uef")
		Control := "40011"
	Else
		Control := If MultipleDiskDrive = "0" ? "40031" : "40032"

	PostMessage, 0x111, %Control%,,, ahk_class ElkWindow
	OpenROM("ahk_class #32770", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class ElkWindow")
Return
