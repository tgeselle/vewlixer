MEmu := "Hatari"
MEmuV := "v1.8.0"
MURL := ["http://hatari.tuxfamily.org/"]
MAuthor := ["djvj","wahoobrian"]
MVersion := "2.0.4"
MCRC := "99BAE087"
iCRC := "82702B7C"
MID := "635038268898109078"
MSystem := ["Atari ST"]
;----------------------------------------------------------------------------
; Notes:
; Some games require you to open the A floppy drive and double click the prg inside to launch
; Launch the hatari.exe manually and press F12 to set your Joystick configuration.  
;  Also, select a default TOS Image (see below).
; Now back at the F12 screen, click Save config and save it wherever you like.
; 
; Games have unique requirements in order to run properly.  TOS Images, memory size, machine type (ST vs STE),
; and some other not-so-common settings all must be configured properly.  These per rom settings are available
; in the ini/isd used by this module.  
;
; TOS Images
; ~~~~~~~~~~~~~~~~
; Different TOS Images (The Operating System) are required for different games.  You will need 
; to find these and store in your emulator path.  Common ones required are:
;    Tos100.img
;    Tos102.img
;    Tos102us.img
;    Tos104.img
;    Tos162.img
;    Tos206.img
;    Tos206us.img
; Find all of these, and name as above.  TOS image to use is a per game setting, default is Tos206.img.
; You can download them here:
; http://www.avtandil.narod.ru/tose.html
;
; Harddrive images  
; ~~~~~~~~~~~~~~~~
;     Images can be a folder in your rom path with all the hard disk files within, or can be zipped up in which 
;     case you'll need to enable 7z support.  
;     Hatari must have a generic BOOT.ST loaded into drive A in order for the game to start automatically,
;     so make sure you include one as part of your hard disk image folder/zip file.
;
;     The file DESKTOP.INF within the harddrive image contains an entry for what program to execute from 
;     the harddrive image.  For example:
;
;     #Z 01 C:\RUNME.TOS@ 
;
;     This entry means that that ST will look for, and automatically execute "RUNME.TOS" at startup.  
;     RUNME.TOS will be a file within your harddrive image.
;
;     In order to be able to run the Hard drive images the recommended method is to leave skipchecks disabled 
;     and enabled Match Extension instead. In this case make sure you also add .inf to the emulator's rom extensions.
;
; Multidisk
; ~~~~~~~~~~~~~~~~
;     For multidisk games, module will load first two disks into Drive A and B.  However, disk swapping after
;     initial loading will need to be performed manually, via the Hatari Disk Manager function.
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

;Global settings
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
StatusBar := IniReadCheck(settingsFile, "Settings", "StatusBar","false",,1)		; show floppy status bar at bottom of emu window
Borders := IniReadCheck(settingsFile, "Settings", "Borders","false",,1)			; ST/STE only - show screen borders (for low/med resolution overscan demos), false will help stretch the game to fullscreen
Zoom := IniReadCheck(settingsFile, "Settings", "Zoom","false",,1)				; zoom low resolution
DesktopST := IniReadCheck(settingsFile, "Settings", "DesktopST","false",,1)		; Whether fullscreen mode uses desktop resolution to avoid: messing multi-screen setups, several seconds delay needed by LCD monitors resolution switching and the resulting sound break. As Hatari ST/E display code doesn't support zooming (except low-rez doubling), it doesn't get scaled (by Hatari or monitor) when this is enabled. Therefore this is mainly useful only if you suffer from the described effects, but still want to grab mouse and remove other distractions from the screen just by toggling fullscreen mode.
WarpKey := IniReadCheck(settingsFile, "Settings", "WarpKey","PgUp",,1)						; toggle warp speed
ConfigFile := IniReadCheck(settingsFile, "Settings", "ConfigFile","",,1)						; custom cfg file

;Rom settings
FastFloppy := IniReadCheck(settingsFile, "Settings" . "|" . romName, "FastFloppy","false",,1)

MachineType := IniReadCheck(settingsFile, romName, "MachineType","ST",,1)
MemorySize := IniReadCheck(settingsFile, romName, "MemorySize","0",,1)
TOSImage := IniReadCheck(settingsFile, romName, "TOSImage","Tos206.img",,1)
MouseMode := IniReadCheck(settingsFile, romName, "MouseMode","true",,1)
UseSingleDrive := IniReadCheck(settingsFile, romName, "UseSingleDrive","false",,1)
CPU := IniReadCheck(settingsFile, romName, "CPU","0",,1)
CPUClock := IniReadCheck(settingsFile, romName, "CPUClock","8",,1)
Monitor := IniReadCheck(settingsFile, romName, "Monitor","vga",,1)			; choices are mono, rgb, vga and tv
WriteProtectFloppy := IniReadCheck(settingsFile, romName, "WriteProtectFloppy","off",,1)
AssociatedCartName := IniReadCheck(settingsFile, romName, "AssociatedCartName","",,1)

WarpKey := xHotKeyVarEdit(WarpKey,"WarpKey","~","Add")
xHotKeywrapper(WarpKey,"Warp")

;need to save the original rom name for zipped hard drive images, because after unzipping, there may not be a file with the actual rom name.
origRomName := romName

hideEmuObj := Object("Hatari ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

cliOptions :=  " --confirm-quit false --grab"

TOSImage := emuPath . "\" . TOSImage
CheckFile(TOSImage)

BezelStart("FixResMode")

fs := If (Fullscreen = "true") ? " -f " : " -w "
monitor := " --monitor " . Monitor
sb := If StatusBar  = "true" ? " --statusbar true" : " --statusbar false"
borders := If (Borders = "true") ? " --borders true" : " --borders false"
desktopST := If (desktop-st = "true") ? " --desktop-st true" : " --desktop-st false"
zoom := If (Zoom = "true") ? " -z 2" : ""
machine := " --machine " . MachineType
memory := " --memsize " . MemorySize
tos := " --tos """ . TOSImage . """"
cpulevel := " --cpulevel " . CPU
cpuclock := " --cpuclock " . CPUClock
FastFloppy := If (FastFloppy = "true") ? " --fastfdc" : ""
singledrive := If (UseSingleDrive = "true") ? " --drive-b false" : ""
writeprotect := " --protect-floppy " . WriteProtectFloppy
cart := If (strlen(AssociatedCartName) > 0) ? " --cartridge """ . AssociatedCartName . """" : ""

cliOptions .= fs . monitor . sb . borders . desktopST . zoom . machine . memory . tos . mouse . cpulevel . cpuclock . FastFloppy . singledrive . writeprotect . cart

If FileExist(romPath . "\DESKTOP.INF")	; HDD Installed Game
{
	harddrive := " --harddrive """ . romPath . """" . " --drive-a false --drive-b false"	
	cliOptions .= harddrive
	rom1 := ""
	rom2 := ""
} Else {
	rom1 := " --disk-a """ . romPath . "\" . romName . romExtension . """"
	rom2 := ""
}

If (ConfigFile)
{
	ConfigFile := AbsoluteFromRelative(EmuPath, ConfigFile)
	CheckFile(ConfigFile)
	RLLog.Debug("Module - Loading custom config file from " . ConfigFile)
	cliOptions := cliOptions . " -c """ . ConfigFile . """"
}

;MultiDisk loading, this will load the first 2 disks into drives A and B since some games can read from both drives and therefore the user won't need to change disks through the MG menu.
If (InStr(romName, "(Disk "))
{
	If (UseSingleDrive="false") 
	{
		multipartTable := CreateRomTable(multipartTable)
		If multipartTable.MaxIndex() 
		{	;Make the searches case insensitive
			original_case_sense := A_StringCaseSense
			StringCaseSense, Off

			;Has multi part
			for index, element in multipartTable 
			{	current_rom := multipartTable[A_Index,1]
				If (InStr(current_rom, "(Disk 1)")) 
					rom1 := " --disk-a """ . current_rom . """"
				Else If (InStr(current_rom, "(Disk 2)"))  
					rom2 := " --disk-b """ . current_rom . """"			
			}
			;Restore original StringCaseSense
			StringCaseSense, %original_case_sense%
		}
	}
}

cliOptions .= rom1 . rom2

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable . cliOptions, emuPath) 

WinWait("Hatari ahk_class SDL_app")
WinWaitActive("Hatari ahk_class SDL_app")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


Warp:
	Send >!x
Return

HaltEmu:
	If WarpKey
		XHotKeywrapper(WarpKey,"Warp","OFF")
Return

RestoreEmu:
	If WarpKey
		XHotKeywrapper(WarpKey,"Warp","ON")
Return

CloseProcess:
	FadeOutStart()
	WinClose("Hatari ahk_class SDL_app")
Return
