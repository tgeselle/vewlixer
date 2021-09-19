MEmu := "OpenMSX"
MEmuV := "v0.11.0"
MURL := ["http://openmsx.sourceforge.net/"]
MAuthor := ["brolly"]
MVersion := "2.0.6"
MCRC := "69E24425"
iCRC := "FBC1AD5F"
MID := "635403946322405220"
MSystem := ["Microsoft MSX","Microsoft MSX2","Microsoft MSX2+","Microsoft MSX Turbo-R","Pioneer Palcom LaserDisc"]
;----------------------------------------------------------------------------
; Notes:
; Make sure you have the bios for the system/model you are trying to emulate inside share/machines.
; You can find roms for several systems here: http://www.msxarchive.nl/pub/msx/emulator/
;
; For emulating the Pioneer Palcom LaserDisc system you must have the PX-7 bios inside share/machines/Pioneer_PX-7/roms
;
; A file named boot_script.txt will be created in your emulator path every time you start a game. If you have any file with the 
; same name there make sure you rename it to something else or it will get overwritten.
;
; About C-BIOS Machines:
; C-BIOS is a minimal implementation of the MSX BIOS, allowing some games to be played without an original MSX BIOS ROM image.
; It only supports cart games. It's highly suggested that you use a real machine instead of one of the C-BIOS implementations.
;
; Key remapping:
; If you want to remap any keys you can do it directly on OpenMSX just create a folder named remaps in the emulator folder. Inside 
; that folder create SYSTEMNAME.txt files depending on the system and you can also create a GLOBAL.txt file with remaps that you want 
; to use for any system of this module. Read the emulator docs for details on how to create remaps, for example:
; bind PAGEUP "set pause on"
; bind ESCAPE "quit"
;
; MSX Turbo-R Machines : Panasonic_FS-A1GT & Panasonic_FS-A1ST
; MSX2+ Machines : Sony_HB-F1XDJ, Sanyo_PHC-70FD, Sanyo_PHC-70FD2, Sanyo_PHC-35J, Panasonic_FS-A1FX, Panasonic_FS-A1WSX, Panasonic_FS-A1WX
; MSX Machines with Disk Drives : National_CF-3300 & Gradiente_Expert_DD_Plus
;
; Floppy Drive Extensions : Sony_HBD-F1 ;can also be attached to a machine by using "-ext Sony_HB-501P" and then -diska cli can be used
;
; Some cart games support saving directly to the cart as they contain embedded SRAM, in other cases they require a PAC or FMPAC extension.
; For such games make sure you select that extension in order to be able to save. Files will be saved to 
; %USERPROFILE%\Documents\openMSX\persistent\pac\untitled1 (or fmpac\untitled1)
;
; If you want to double check if your extensions loaded properly, start the console by pressing F10 and then type list_extensions.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"SDL_app"))	; instantiate primary emulator window object
emuConsoleWindow := new Window(new WindowTitle(,"ConsoleWindowClass"))

sysTypes := Object("Pioneer Palcom LaserDisc","palcom","Microsoft MSX","msx","Microsoft MSX2","msx2","Microsoft MSX2+","msx2+","Microsoft MSX Turbo-R","turbor")
sysIdent := sysTypes[systemName]
If !sysIdent
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this OpenMSX module: " . moduleName)

defaultMachines := Object("palcom","Pioneer_PX-7","msx","Sony_HB-501P","msx2","Sony_HB-F900","msx2+","Panasonic_FS-A1WSX","turbor","Panasonic_FS-A1GT")
defaultmach := defaultMachines[sysIdent]

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, SevenZExtractPath)

If (sysIdent = "msx") ;For Disk games in MSX1 we will need a specific model with disk drives
	If StringUtils.Contains(romExtension,"\.dsk|\.dmk")
		defaultExtensionCart := "Sony_HBD-F1"

;defaultmach := "Gradiente_Expert_DD_Plus"

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Renderer := moduleIni.Read("Settings", "Renderer","SDL",,1)
RotateMethod := moduleIni.Read("Settings", "RotateMethod",rotateMethod,,1)
HideConsole := moduleIni.Read("Settings", "HideConsole","true",,1)
FullSpeedWhenLoading := moduleIni.Read("Settings", "FullSpeedWhenLoading","true",,1)
DefaultMachine := moduleIni.Read("Settings", "DefaultMachine",defaultmach,,1)
ScalerAlgorithm := moduleIni.Read("Settings", "ScalerAlgorithm","simple",,1)
ScaleFactor := moduleIni.Read("Settings", "ScaleFactor","2",,1)
ScanlineValue := moduleIni.Read("Settings", "ScanlineValue","0",,1)
ApplyScalerOnFullscreen := moduleIni.Read("Settings", "ApplyScalerOnFullscreen","false",,1)
SoundDriver := moduleIni.Read("Settings", "SoundDriver",,,1)
HoldKeyOnBoot := moduleIni.Read(romName . "|Settings", "HoldKeyOnBoot",,,1)
Command := moduleIni.Read(romName . "|Settings", "Command",,,1)
RotateDisplay := moduleIni.Read(romName, "RotateDisplay", "0",,1)
DefaultMachine := moduleIni.Read(romName, "Machine",DefaultMachine,,1)
RomType := moduleIni.Read(romName, "RomType",,,1)
ExtensionCart := moduleIni.Read(romName, "ExtensionCart",defaultExtensionCart,,1)
ExtensionCart2 := moduleIni.Read(romName, "ExtensionCart2",,,1)
ExtensionCart3 := moduleIni.Read(romName, "ExtensionCart3",,,1)
DualDiskLoad := moduleIni.Read(romName, "DualDiskLoad","false",,1)
DiskSwapDrive := moduleIni.Read(romName, "DiskSwapDrive","A",,1)
CustomCart := moduleIni.Read(romName, "CustomCart",,,1)
UseGFX9000 := moduleIni.Read(romName, "UseGFX9000","false",,1)
GlobalJoystick1 := moduleIni.Read("Settings", "Joystick1","keyjoystick1",,1)
GlobalJoystick2 := moduleIni.Read("Settings", "Joystick2","keyjoystick2",,1)
Joystick1 := moduleIni.Read(romName, "Joystick1",GlobalJoystick1,,1)
Joystick2 := moduleIni.Read(romName, "Joystick2",GlobalJoystick2,,1)

; Generate a boot_script file
scriptName := "boot_script.txt"

; Create the user-startup file to launch the game
BootScriptFile := new File(emuPath . "\" . scriptName)
BootScriptFile.Delete()

If (RotateDisplay > 0)
	Rotate(rotateMethod, RotateDisplay)

BezelStart("fixResMode")

If (Fullscreen = "true")
	BootScriptFile.Append("set fullscreen on`n")
Else
	BootScriptFile.Append("set fullscreen off`n")

If (FullSpeedWhenLoading = "true")
	BootScriptFile.Append("set fullspeedwhenloading on`n")
Else
	BootScriptFile.Append("set fullspeedwhenloading off`n")

If (Fullscreen = "false" || ApplyScalerOnFullscreen = "true")
{
	BootScriptFile.Append("set scale_algorithm " . ScalerAlgorithm . "`n")
	BootScriptFile.Append("set scale_factor " . ScaleFactor . "`n")
}
BootScriptFile.Append("set renderer " . Renderer . "`n")

If (ScanlineValue > 0)
	BootScriptFile.Append("set scanline " . ScanlineValue . "`n")

If SoundDriver
	BootScriptFile.Append("set sound_driver " . SoundDriver . "`n")

If ExtensionCart2
	BootScriptFile.Append("ext " . ExtensionCart2 . "`n")

If ExtensionCart3
	BootScriptFile.Append("ext " . ExtensionCart3 . "`n")

If (UseGFX9000 = "true") {
	BootScriptFile.Append("ext gfx9000`n")
	BootScriptFile.Append("set videosource GFX9000`n")
	BootScriptFile.Append("bind F6 cycle videosource`n") ;So you can easily cycle through videosources using F6
}

If StringUtils.Contains(romExtension,"\.cas|\.wav")
{
	HoldKeyOnBoot := ""		; Otherwise this will cause tape loading to fail
	BootScriptFile.Append("set autoruncassettes on`n")
	; newRompath := StringUtils.Replace(rompath, "\", "/", "All")	; \ characters are not accepted in the script and must be replaced by /
	; BootScriptFile.Append("cassetteplayer insert "%newRompath%/%romname%%romextension%"`n")
}

If (Joystick1 != none)
	BootScriptFile.Append("plug joyporta " . Joystick1 . "`n")
If (Joystick2 != none)
	BootScriptFile.Append("plug joyportb " . Joystick2 . "`n")

If (Joystick1 = "mouse" || Joystick2 = "mouse" || Joystick1 = "trackball" || Joystick2 = "trackball" || Joystick1 = "touchpad" || Joystick2 = "touchpad") {
	BootScriptFile.Append("set grabinput on`n")
	BootScriptFile.Append("escape_grab`n")
}

If ExtensionCart	; We should append it to the boot script because using the -ext CLI it will always try to add it to cart slot a unless the config XML specifically says slot 2
	If StringUtils.Contains(romExtension,"\.rom|\.bin")		; For other medias -ext cli will be used, see below
		If (ExtensionCart != "64KBexRAM")
			BootScriptFile.Append("ext " . ExtensionCart . "`n")

; Read remaps from remaps text files and add to BootScript File
MSXGlobalRemapFile := new File(emuPath . "\remaps\GLOBAL.txt")
MSXSystemRemapFile := new File(emuPath . "\remaps\" . SystemName . ".txt")
If MSXGlobalRemapFile.Exist()
	Loop, Read, % MSXGlobalRemapFile.FileFullPath
		BootScriptFile.Append(A_LoopReadLine . "`n")
If MSXSystemRemapFile.Exist()
	Loop, Read, % MSXSystemRemapFile.FileFullPath
		BootScriptFile.Append(A_LoopReadLine . "`n")

If (sysIdent = "palcom") {
	machinetype := "Pioneer_PX-7"
	mediatype1 := "laserdisc"
} Else If HoldKeyOnBoot {
	If (HoldKeyOnBoot = "Ctrl")
		BootScriptFile.Append("after boot {keymatrixdown 6 2; after time 15 ""keymatrixup 6 2""}`n")	; Press Ctrl wait 15 seconds of emulated time and the release it
	Else If (HoldKeyOnBoot = "Shift")
		BootScriptFile.Append("after boot {keymatrixdown 6 2; after time 15 ""keymatrixup 6 2""}`n")
}

If (!DefaultMachine)
	ScriptError("Machine Type not defined for " . sysIdent)

params := " -machine " . DefaultMachine . " -script " . scriptName
If StringUtils.Contains(romExtension,"\.rom|\.bin")
	params .= " -carta """ . romPath . "\" . romName . romExtension . """"
Else If StringUtils.Contains(romExtension,"\.dsk|\.dmk")
{
	If CustomCart
		params .= " -carta """ . romPathOrig . "\Custom Carts\" . CustomCart . """"

	If ExtensionCart
		params .= " -ext " . ExtensionCart

	params .= " -diska """ . romPath . "\" . romName . romExtension . """"
	If (DualDiskLoad = "true")
	{
		If StringUtils.Contains(romName,"\(Disk 1")
		{
			RomTableCheck()	; Make sure romTable is created already so the next line can calculate correctly
			If (romtable.MaxIndex() > 1)
			{
				romName2 := romtable[2,1] ; This should be disk 2
				params .= " -diskb """ . romName2 . """"
			}
		}
	}
} Else If StringUtils.Contains(romExtension,"\.cas|\.wav")
{
	If ExtensionCart
		params .= " -ext " . ExtensionCart

	params .= " -cassetteplayer """ . romPath . "\" . romName . romExtension . """"
}
Else If (romExtension = ".ogv")
	params .= " -laserdisc """ . romPath . "\" . romName . romExtension . """"

If RomType
	params .= " -romtype " . RomType

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(params)

;WinWait("openmsx ahk_class ConsoleWindowClass")
;WinWaitActive("openmsx ahk_class ConsoleWindowClass")
emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If (HideConsole = "true")
	emuConsoleWindow.Set("Transparent", "On")	; Makes the console window transparent so you don't see it on exit

TimerUtils.Sleep(2000)	; Needs this otherwise BezelDraw won't be able to get the correct window dimension

If Command {
	emuPrimaryWindow.WaitActive()
	KeyUtils.SetKeyDelay(50)
	KeyUtils.SendCommand(Command)
}	

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")

; Switching orientation back to normal
If (RotateDisplay > 0)
	Rotate(rotateMethod, 0)

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	If StringUtils.Contains(romExtension,"\.cas|\.wav")
	{
		newRompath := StringUtils.Replace(selectedRom, "\", "/", "All")		; \ characters are not accepted in the script and must be replaced by /
		KeyUtils.Send("{F10}")									; Open the console")
		KeyUtils.Send("cassetteplayer insert " . newRompath)	; Change tape
		KeyUtils.Send("{Enter}")
		KeyUtils.Send("{F10}")									; Close the console
	}
	Else If StringUtils.Contains(romExtension,"\.dsk|\.dmk")
	{
		DriveToUse := If DiskSwapDrive = "A" ? "diska" : "diskb"
		newRompath := StringUtils.Replace(selectedRom, "\", "/", "All")	; \ characters are not accepted in the script and must be replaced by /
		KeyUtils.Send("{F10}")							; Open the console
		KeyUtils.Send(DriveToUse . " " . newRompath)	; Change disk
		KeyUtils.Send("{Enter}")
		KeyUtils.Send("{F10}")							; Close the console
	}
Return

CloseProcess:
	FadeOutStart()
	;WinClose("openmsx ahk_class ConsoleWindowClass")
	emuPrimaryWindow.Close()
Return
