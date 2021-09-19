MEmu := "Oricutron"
MEmuV := "v1.2"
MURL := ["http://www.petergordon.org.uk/oricutron/"]
MAuthor := ["wahoobrian"]
MVersion := "1.0.1"
MCRC := "B44EC4F9"
iCRC := "DEB8CEB4"
MID := "635752966432690239"
MSystem := ["Tangerine Oric"]
;----------------------------------------------------------------------------
; Notes:
; Enter the UI by pressing F1. 
;
; Supported emulation modes via CLI:
; -atmos                Emulate Atmos
; -oric1                Emulate Oric-1
; -o16k                 Emulate Oric-1 16k
; -telestrat            Emulate Telestrat
; -pravetz              Emulate Pravetz 8D
;
; More CLI commands can be found in Readme.txt
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"Oricutron 1.2 ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","false",,1)
MachineType := IniReadCheck(settingsFile, romName, "MachineType","oric1",,1)
ManualTapeLoad := IniReadCheck(settingsFile, romName, "ManualTapeLoad","false",,1)
Command := IniReadCheck(settingsFile, romName, "Command","",,1)

BezelStart("FixResMode")

cliOptions := If (Fullscreen="true") ? "-f " : "-w "
cliOptions := cliOptions . " -m" . MachineType
fullRomPath := romPath . "\" . romName . romExtension

If RegExMatch(romExtension,"i)\.tap|\.wav")
{	If (ManualTapeLoad = "false")
		cliOptions := cliOptions . " --turbotape on -t """ . fullRomPath
}
Else If RegExMatch(romExtension,"i)\.dsk")
	cliOptions := cliOptions . " -d """ . fullRomPath
Else  
	ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`dsk,tap,wav")

HideEmuStart()
Run(executable . " " . cliOptions, emuPath)
WinWait("Oricutron 1.2 ahk_class SDL_app")
WinWaitActive("Oricutron 1.2 ahk_class SDL_app")
BezelDraw()

If (ManualTapeLoad = "true")
{
	Sleep, 4000 ;give time for machine to boot
	Send, {F1} ; Open Settings
	Sleep, 1000
	Send, {t} ; Open Insert Tape dialog
	OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)
	SendCommand("{LShift Down}CLOAD{vkDEsc028}{vkDEsc028}{LShift Up}", 500)
	SendCommand("{Enter}", 500)
	SendCommand("{Enter}", 500)
}

If (StrLen(Command) > 0)
{ 
	Sleep, 4000 ;give time for machine to boot 
	SendCommand(Command, 2000)
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	SendCommand("{F1}", 500)
	SendCommand("0", 500)
	OpenROM(dialogOpen . " ahk_class #32770", selectedRom)
	WinActivate, ahk_class SDL_app
	Send {Enter}	
Return

CloseProcess:
	FadeOutStart()
	WinClose("Oricutron 1.2 ahk_class SDL_app")
Return
