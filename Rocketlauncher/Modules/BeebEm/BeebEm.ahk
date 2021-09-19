MEmu := "BeebEm"
MEmuV := "v4.14"
MURL := ["http://www.mkw.me.uk/beebem/index.html"]
MAuthor := ["brolly"]
MVersion := "1.0.5"
MCRC := "1A1517E0"
iCRC := "8E9F265F"
MID := "635599773229077671"
MSystem := ["Acorn BBC Micro"]
;----------------------------------------------------------------------------
; Notes:
; Start BeebEm and go to Options-Preference Options-Select User Data Folder
; Make sure you set your user data folder to Emulator_Path\UserData
;
; Supported Models:
; BBC Model B
; BBC Model B + Integra-B
; BBC Model B Plus
; BBC Master 128
;
; To list the contents of a disk drive so you can find the executable file type:
; *DISK (or *DR.0 or *DR.1 depending on the drive you want to use)
; *CAT
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
configFile := emuPath . "\UserData\Preferences.cfg"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ShowFPS := IniReadCheck(settingsFile, "Settings", "ShowFPS","00",,1)
EmulatedDriveSounds := IniReadCheck(settingsFile, "Settings", "EmulatedDriveSounds","00",,1)
Model := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Model","0",,1)
TapeSpeed := IniReadCheck(settingsFile, "Settings" . "|" . romName, "TapeSpeed","ee02",,1)
SetTube := IniReadCheck(settingsFile, "Settings" . "|" . romName, "SetTube","false",,1)
WriteProtectDrives := IniReadCheck(settingsFile, "Settings" . "|" . romName, "WriteProtectDrives","true",,1)
ChainCommand := IniReadCheck(settingsFile, romName, "ChainCommand","",,1)
RunCommand := IniReadCheck(settingsFile, romName, "RunCommand","",,1)
CustomCommand := IniReadCheck(settingsFile, romName, "CustomCommand","",,1)
TapeLoadingMethod := IniReadCheck(settingsFile, romName, "TapeLoadingMethod","CHAIN",,1)
RomCfgFile := IniReadCheck(settingsFile, romName, "RomCfgFile","",,1)
AutobootDisk := IniReadCheck(settingsFile, romName, "AutobootDisk","true",,1)
MultipleDiskDrive := IniReadCheck(settingsFile, romName, "MultipleDiskDrive","0",,1)

StringUpper RunCommand, RunCommand

If (RomCfgFile) {
	RomCfgFile := CheckFile(emuPath . "\UserData\" . RomCfgFile)
}

hideEmuObj := Object("ahk_class BEEBWIN",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension not in .ssd,.dsd,.adl,.adf,.img,.uef
	ScriptError("The extension " . romExtension . " is not one of the known supported extensions for this emulator.")

If !FileExist(configFile)
	ScriptError("Preferences.cfg was not found at " . configFile)

If Model not in 0,1,2,3
	ScriptError("Model " . Model . " is not one of the known supported systems for this module: " . moduleName . ". Please use the option to configure the type of system needed through RocketLauncherUI.")

configIni := LoadProperties(configFile)	; load the config into memory
SetTube := If SetTube = "true" ? "01" : "00"
ShowFPS := If ShowFPS = "true" ? "01" : "00"
EmulatedDriveSounds := If EmulatedDriveSounds = "true" ? "01" : "00"
Params := Params . "-Data - -DisMenu "

If ( romExtension = ".uef" ) { ;Tape
	If (TapeLoadingMethod = "RUN") {
		Params :=  Params . " -KbdCmd ""OSCLI\s2\STAPE\s2\S\nOSCLI\s2\SRUN\s2\S\n"" "
	}
	Else {
		Params :=  Params . " -KbdCmd ""OSCLI\s2\STAPE\s2\S\nPAGE\s-\S\s6\SE00\nCH.\s22\S\n"" "
	}
	;Alternatives
	;Params :=  Params . " -KbdCmd ""OSCLI\s2\STAPE\s2\S\nOSCLI\s2\SRUN\s2\S\n"" "
	;Params :=  Params . " -KbdCmd ""\s'\STAPE\nPAGE\s-\S\s6\SE00\nCHAIN \s22\S\n"" "
	;Params :=  Params . " -KbdCmd ""\s'\STAPE\n\s'\SRUN\n"" "
} Else { ;Disk
	If (ChainCommand) {
		Params :=  Params . " -KbdCmd """ . (If Model = "3" ? "\d0600\S\d0040" : "") . "CH.\s2\S" . ChainCommand . "\s2\S\n"" " ;Loading the Master 128 OS takes longer so we need to simulate a delay before starting to send the commands otherwise not all of it will get through. Then revert it back to the default value of 40ms.
	} Else If (RunCommand) {
		Params :=  Params . " -KbdCmd """ . (If Model = "3" ? "\d0600\S\d0040" : "") . "OSCLI\s2\SRUN " . RunCommand . "\s2\S\n"" "  ;Loading the Master 128 OS takes longer so we need to simulate a delay before starting to send the commands otherwise not all of it will get through. Then revert it back to the default value of 40ms.
	} Else If (CustomCommand) {
		Params :=  Params . " -KbdCmd """ . (If Model = "3" ? "\d0600\S\d0040" : "") . CustomCommand . "\n"" "  ;Loading the Master 128 OS takes longer so we need to simulate a delay before starting to send the commands otherwise not all of it will get through. Then revert it back to the default value of 40ms.
	}
	If (AutobootDisk = "false") {
		Params := Params . " -NoAutoBoot "
	}
}
If (RomCfgFile) {
	Params := Params . " -Roms """ . RomCfgFile . """"
}

Params :=  Params . " """ . romPath . "\" . romName . romExtension . """"

;MultiGame support for disk games (load both disks in the 2 drives)
If ( romExtension != ".uef" ) {
	RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
	romCount = % romTable.MaxIndex()
	If romName contains (Disk 1)
	{
		If romCount > 1
		{
			Params := Params . " """ . romTable[2,1] . """"
		}
	}
}

;Set the properties in the preferences.cfg file
;Yes, ShowFSP is not a typo on our side. The BeebEm emulator authors made this typo so we have to use it.
WriteProperty(configIni,"ShowFSP", ShowFPS)
WriteProperty(configIni,"DiscDriveSoundEnabled", EmulatedDriveSounds)
WriteProperty(configIni,"RelaySoundEnabled", EmulatedDriveSounds)
WriteProperty(configIni,"TapeSoundEnabled", EmulatedDriveSounds)
WriteProperty(configIni,"MachineType", "0" . Model)
WriteProperty(configIni,"KeyMapping", "00009c62")
WriteProperty(configIni,"TubeEnabled", SetTube)
WriteProperty(configIni,"Tape Clock Speed", TapeSpeed)
SaveProperties(configFile,configIni)	; save changes to Preferences.cfg

BezelStart()

Fullscreen := If Fullscreen = "true" ? "-FullScreen " : ""

HideEmuStart()

Run(executable . " " . Fullscreen . Params, emuPath)

WinActivate, ahk_class BEEBWIN
WinWaitActive("ahk_class BEEBWIN")

If (WriteProtectDrives = "false")
{
	PostMessage, 0x111, 40064,,,ahk_class BEEBWIN
	PostMessage, 0x111, 40065,,,ahk_class BEEBWIN
}

If bezelPath {
	WinGetPos,,, initialwidth,, ahk_class BEEBWIN
	W:=
	timeout := A_TickCount
	Loop {
		Sleep, 50
		WinGetPos,,, W,, ahk_class BEEBWIN
		If (W != initialwidth)
			Break
		If(timeout < A_TickCount - 2000)
			Break
	}
}
Sleep, 50

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
	If ( romExtension = ".uef" )
		Control := "40108"
	Else
		Control := If MultipleDiskDrive = "1" ? "40023" : "40002"

	PostMessage, 0x111, %Control%,,, ahk_class BEEBWIN
	OpenROM("ahk_class #32770", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class BEEBWIN")
Return
