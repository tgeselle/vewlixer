MEmu := "Virtual Aquarius"
MEmuV := "v0.72a"
MURL := ["http://www.oocities.org/emucompboy/"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "83458490"
iCRC := "92C08CD7"
MID := "635038268931296709"
MSystem := ["Mattel Aquarius"]
;----------------------------------------------------------------------------
; Notes:
; Module requires uncompressed roms or must have 7z support enabled in RocketLauncherUI
;
; HowTo use custom controls for each game:
;	Create a "controls" folder in your emulator folder
;	Setup the default controls for your emu that you want to use for most games and exit the emu
;	Copy the default.ini in your emu folder to the controls folder you just made
;	Now run the game you want to set custom controls for and setup the new keys, then exit the emu
;	Copy the default.ini to the controls folder, but rename it to match the exact name of the game, your romName
;	Do this for each game you want custom controls for
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
controlsFolder := IniReadCheck(settingsFile, "Settings", "controlsFolder",emuPath . "\controls",,1)	; the path to your custom controls folder
cloadWaitTime := IniReadCheck(settingsFile, "Settings", "cloadWaitTime","1000",,1)

controlsFolder := GetFullName(controlsFolder) ;convert relative paths to absolute

SetKeyDelay(40)	; required otherwise emu doesn't capture keystrokes
defaultINI := CheckFile(emuPath . "\default.ini") ; emu settings stored in here

 ; copying custom controls ini to emuPath, otherwise copying default back if it exists
If FileExist(controlsFolder . "\" . romName . ".ini")
	FileCopy, %controlsFolder%\%romName%.ini, %emuPath%default.ini, 1
Else If FileExist(controlsFolder . "\default.ini")
	FileCopy, %controlsFolder%\default.ini, %emuPath%default.ini, 1

 ; forcing RAM to use 16K Expansion 
ramSetting := IniRead(defaultINI, "MEMORY", "ramexpanders")
IniRead(defaultINI, "MEMORY", "ramexpanders")
If (ramSetting != 2)
	IniWrite(2, defaultINI, "MEMORY", "ramexpanders")

BezelStart("fixResMode")

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"Virtual Aquarius ahk_class Virtual Aquarius",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

 ; checking if the BASIC cassette exists in the romPath
If (romExtension = ".caq")
	If FileExist(romPath . "\" . romName . " (BASIC)" . romExtension)
		basicRom := 1

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If (Fullscreen = "true" && romExtension = ".bin")
	Run(executable, emuPath ,"Hide") ; can only hide the emu's launch process with tapes, we need to see the emu in order to load cassettes
Else
	Run(executable,emuPath) ; windowed mode cannot hide the emu or else there will be nothing to see

WinWait("Virtual Aquarius ahk_class Virtual Aquarius")

If (romExtension = ".caq")	; handle cassette games
{	WinWait("Virtual Aquarius ahk_class Virtual Aquarius")
	WinWaitActive("Virtual Aquarius ahk_class Virtual Aquarius")
	Sleep, 500 ; waiting for emu to be ready for commands
	Send {Enter down}{Enter up}
	Sleep, %cloadWaitTime% ; waiting until Copyright shows on emu window, increase if "cload" isn't getting typed out fully
	SendCommand("cload{Enter}{Enter}{Wait:100}{Enter}") ; send cload & enter

	; loading 1st "BASIC" cassette if it exists
	If basicRom {
		WinMenuSelectItem, Virtual Aquarius ahk_class Virtual Aquarius,, File, Play Cassette File ; load a cassette game
		OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . " (BASIC)" . romExtension)
		WinWait("Virtual Aquarius ahk_class Virtual Aquarius")
		WinWaitActive("Virtual Aquarius ahk_class Virtual Aquarius")
		Sleep, 1500 ; waiting until emu loads BASIC cassette, sometimes the emu lags loading this file so need this sleep to be somewhat high
		SendCommand("run{Enter}{Wait:100}{Enter}") ; send run & enter
	}

	; loading regular cassette
	WinMenuSelectItem, Virtual Aquarius ahk_class Virtual Aquarius,, File, Play Cassette File ; load a cassette game
	OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

	If !basicRom {
		WinWait("Virtual Aquarius ahk_class Virtual Aquarius")
		WinWaitActive("Virtual Aquarius ahk_class Virtual Aquarius")
		Sleep, 1500 ; waiting until emu loads BASIC cassette, sometimes the emu lags loading this file so need this sleep to be somewhat high
		SendCommand("run{Enter}") ; send run & enter
	}
} Else If (romExtension = ".bin")	; handle tape games
{	WinMenuSelectItem, Virtual Aquarius ahk_class Virtual Aquarius,, File, Load Game ROM ; load a tape game
	OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)
	WinWait("Virtual Aquarius ahk_class Virtual Aquarius")
	WinWaitActive("Virtual Aquarius ahk_class Virtual Aquarius")
	WinMenuSelectItem, Virtual Aquarius ahk_class Virtual Aquarius,, File, Soft Reset ; reset emu
} Else
	ScriptError("Rom type " . romExtension . " is not supported by this module")

If (Fullscreen = "true")
{	Sleep, 300 ; increase if emu is not going fullscreen
	WinMenuSelectItem, Virtual Aquarius ahk_class Virtual Aquarius,, Util, Full screen mode ; go fullscreen
}

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Virtual Aquarius ahk_class Virtual Aquarius")
Return
