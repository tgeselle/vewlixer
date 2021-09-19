MEmu := "Atomulator"
MEmuV := "v1.13"
MURL := ["http://acornatom.co.uk/"]
MAuthor := ["Xttx"]
MVersion := "1.0"
MCRC := "EDB12D49"
iCRC := "D5D08A2D"
MID := "635737244662418638"
MSystem := ["Acorn Atom"]
;----------------------------------------------------------------------------
; Notes:
; The module needs to be rewritten to use SendCommand() instead of Send
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

BlockInput, On	; It appears that your Front End and xpadder needs to be ran as administrator for this command to function.

BlockUserInputTime = 3000	; default for all systems

hideEmuObj := Object("Atomulator ahk_class WindowsApp",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

settingsFile := modulePath . "\" . moduleName . ".ini"

; General Settings
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

; Rom Settings
FileName := IniReadCheck(settingsFile, romName, "FileName",A_Space,,1)
LoadMethod := IniReadCheck(settingsFile, romName, "LoadMethod",A_Space,,1)

; Emu config settings
cfgFile := CheckFile(emuPath . "\atom.cfg","Cannot find " . emuPath . "\atom.cfg. Please run the emulator manually first so it is created.")
cfgArray := LoadProperties(cfgFile)


WriteProperty(cfgArray, "bbcbasic", "0", 1)
If romExtension Contains .40t,.dsk,.ssd,.dsd,.fdi
{
	WriteProperty(cfgArray, "disc0", romPath . "\" . romName . romExtension, 1)
	WriteProperty(cfgArray, "ramrom_enable", "0", 1)
	WriteProperty(cfgArray, "ramrom_jumpers", "4", 1)
}
Else If romExtension Contains .uef,.csw
{
	WriteProperty(cfgArray, "disc1", romPath . "\" . romName . romExtension, 1)
}
Else
{
	WriteProperty(cfgArray, "mmc_path", romPath, 1)
	WriteProperty(cfgArray, "ramrom_enable", "1", 1)
	WriteProperty(cfgArray, "ramrom_jumpers", "4", 1)
}
SaveProperties(cfgFile,cfgArray)
BezelStart()
HideEmuStart()
Run(executable, emuPath)

WinWait("Atomulator ahk_class WindowsApp")
WinWaitActive("Atomulator ahk_class WindowsApp")
BezelDraw()
Sleep 100
SetKeyDelay(50, 150)

If (FileName && romExtension Contains .40t,.dsk,.ssd,.dsd,.fdi)
{
	Send {LShift Down}{sc028}{LShift Up}
	Send dos
	Send {Enter}
	Send {LShift Down}{sc028}{LShift Up}
	Send %FileName%
	Send {Enter}
}
Else	; Else If romExtension Contains .uef,.csw
{
	If (romExtension = ".")
	{
		romNameWithExtension := romName
	}
	Else
	{
		romNameWithExtension := romName . romExtension
	}	
	StringLower, romName_lower, romNameWithExtension

	If (LoadMethod = "gamename")
	{
		Send {LShift Down}{sc028}{LShift Up}
		Send %romName_lower%
		Send {Enter}
	}
	Else If (LoadMethod = "run")
	{
		Send {LShift Down}{sc028}{LShift Up}
		Send run
		Send {LShift Down}{2}{LShift Up}
		Send %romName_lower%
		Send {LShift Down}{2}{LShift Up}
		Send {Enter}
		Send run
		Send {Enter}
	}
	Else If (LoadMethod = "load")
	{
		Send load
		Send {LShift Down}{2}{LShift Up}
		Send %romName_lower%
		Send {LShift Down}{2}{LShift Up}
		Send {Enter}
		Sleep 100
		Send run
		Send {Enter}
	}
	Else
	{
		Send {LShift Down}{sc028}{LShift Up}
		Send load
		Send {LShift Down}{2}{LShift Up}
		Send %romName_lower%
		Send {LShift Down}{2}{LShift Up}
		Send {Enter}
		Sleep 100
		Send run
		Send {Enter}
	}
}

HideEmuEnd()

; Set fullscreen If needed
If (Fullscreen = "true")
	WinMenuSelectItem, Atomulator ahk_class WindowsApp,, Settings, Video, Fullscreen

Sleep, BlockUserInputTime
BlockInput, OFF

BezelDraw()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Atomulator ahk_class WindowsApp")
Return
