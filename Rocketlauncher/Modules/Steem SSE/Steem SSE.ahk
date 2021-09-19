MEmu := "Steem SSE"
MEmuV := "v3.7.0"
MURL := ["http://sourceforge.net/projects/steemsse/"]
MAuthor := ["ghutch92","wahoobrian","zerojay"]
MVersion := "2.0.7"
MCRC := "41845F96"
iCRC := "CD500DC1"
MID := "635038268925531896"
MSystem := ["Atari ST"]
;----------------------------------------------------------------------------
; Notes
; -----
; This is for the updated SSE edition, not the original Steem which ended at v3.2
; If a game does not work properly check to see if there is a patch available.
; Be sure to read the controller options very carefully since sometimes your controls 
; might only work if Scroll Lock is on or Num Lock is off. This needs to be set from 
; within the emulator.
;
; Games have unique requirements in order to run properly.  TOS Images, memory size, machine type (ST vs STE),
; and some other not-so-common settings all must be configured properly.  These per rom settings are available
; in the ini/isd used by this module.  
;
; TOS Images
; ~~~~~~~~~~~~~~~~
; Different TOS Images (The Operating System) are required for different games.  You will need 
; to find these and store in your emulator path inside the TOS folder.  Common ones required are:
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
; Suggestions
; ~~~~~~~~~~~~~~~~
; 1.  Options (wrench icon) | General - Uncheck 'Show pop-up hints' 
; 2.  Shortcuts (lightning icon) - Assign a Shortcut Key to 'Fast Forward (Toggle)', then map that 
;     key to you input device.  Comes in VERY handy while waiting for the Atari ST to perform a memory 
;     check when booting.
;
; Harddrive images  
; ~~~~~~~~~~~~~~~~
;     Images can be a folder in your rom path with all the hard disk files within, or can be zipped up.  
;     Steem must have a generic BOOT.ST loaded into drive A in order for the game to start automatically,
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
;     initial loading will need to be performed manually, via the Steem Disk Manager function.
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

;Global settings
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
LockAspectRatio := IniReadCheck(settingsFile, "Settings", "LockAspectRatio","false",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset",20,,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset",0,,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset",0,,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset",10,,1)
runSpeed := IniReadCheck(settingsFile, "Settings|" . romName, "RunSpeed","",,1)

;Rom settings
MachineType := IniReadCheck(settingsFile, romName, "MachineType","1",,1)  ; 0 = STE, 1 = ST
MemorySize := IniReadCheck(settingsFile, romName, "MemorySize","0",,1)
TOSImage := IniReadCheck(settingsFile, romName, "TOSImage","Tos206.img",,1)
UseSingleDrive := IniReadCheck(settingsFile, romName, "UseSingleDrive","false",,1)
FastFloppy := IniReadCheck(settingsFile, romName, "FastFloppy","true",,1)
Monitor := IniReadCheck(settingsFile, romName, "Monitor","1",,1)			; choices are 0=mono/high res, 1=color
AssociatedCartName := IniReadCheck(settingsFile, romName, "AssociatedCartName","",,1)

steemINI := CheckFile(emuPath . "\steem.ini")

;need to save the original rom name for zipped hard drive images, because after unzipping, there may not be a file with the actual rom name.
origRomName := romName

hideEmuObj := Object("ahk_class Steem Window",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

cliOptions :=  " -nonotifyinit"

TOSImage := emuPath . "\TOS\" . TOSImage
CheckFile(TOSImage)
IniWrite, %TOSImage%, %steemINI%, Machine, ROM_File

IniWrite, %MachineType%, %steemINI%, Machine, STType
IniWrite, %Monitor%, %steemINI%, Machine, Colour_Monitor
IniWrite, 0, %steemINI%, Options, BlockResize ;Enable window resize

If (LockAspectRatio="true")
	IniWrite, 1, %steemINI%, Options, LockAspectRatio
Else
	IniWrite, 0, %steemINI%, Options, LockAspectRatio

BezelStart()

If (fullscreen="true")
	IniWrite, 1, %steemINI%, Options, StartFullscreen
Else
	IniWrite, 0, %steemINI%, Options, StartFullscreen

If (FastFloppy="false") {
	IniWrite, 0, %steemINI%, Disks, QuickDiskAccess
	IniWrite, 0, %steemINI%, Options, DiskAccessFF
} Else {
	IniWrite, 1, %steemINI%, Disks, QuickDiskAccess
	IniWrite, 1, %steemINI%, Options, DiskAccessFF
}

; Set the emulated CPU speed.
If runSpeed
	IniWrite, %runSpeed%, %steemINI%, Options, CPUBoost

If (MemorySize="0") 
{  ;512K
	IniWrite, 1, %steemINI%, Machine, Mem_Bank_1
	IniWrite, 3, %steemINI%, Machine, Mem_Bank_2
} Else If (MemorySize="1") 
{  ;1M
	IniWrite, 1, %steemINI%, Machine, Mem_Bank_1
	IniWrite, 1, %steemINI%, Machine, Mem_Bank_2
} Else If (MemorySize="2") 
{  ;2M
	IniWrite, 2, %steemINI%, Machine, Mem_Bank_1
	IniWrite, 3, %steemINI%, Machine, Mem_Bank_2
} Else If (MemorySize="4") 
{  ;4M
	IniWrite, 2, %steemINI%, Machine, Mem_Bank_1
	IniWrite, 2, %steemINI%, Machine, Mem_Bank_2
}

If InStr(romExtension, "stx")
	IniWrite, 1, %steemINI%, Disks, PastiActive
Else
	IniWrite, 0, %steemINI%, Disks, PastiActive

If (strlen(AssociatedCartName) > 0)
	IniWrite, %AssociatedCartName%, %steemINI%, Machine, Cart_File
Else
	IniWrite, A_Space, %steemINI%, Machine, Cart_File

IfExist, %romPath%\DESKTOP.INF ;HDD Installed Game
{
	;clear out floppy drives
	IniWrite, %romPath%\BOOT.ST, %steemINI%, Disks, Disk_A_Path   ;must have BOOT.ST in drive A
	IniWrite, BOOT.ST, %steemINI%, Disks, Disk_A_Name
	
	IniWrite, A_Space, %steemINI%, Disks, Disk_B_Path
	IniWrite, A_Space, %steemINI%, Disks, Disk_B_Name
	
	;setup hard drive
	IniWrite, 0, %steemINI%, HardDrives, DisableHardDrives
	IniWrite, 2, %steemINI%, HardDrives, BootDrive
	IniWrite, C, %steemINI%, HardDrives, Drive_0_Letter
	IniWrite, %romPath%, %steemINI%, HardDrives, Drive_0_Path
	boot := "\BOOT.ST"
	
	cliOptions .= " """ romPath . boot . """"
	
} Else {
	IniWrite, 1, %steemINI%, HardDrives, DisableHardDrives
	IniWrite, %romPath%\%romName%%romExtension%, %steemINI%, Disks, Disk_A_Path
	IniWrite, %romName%, %steemINI%, Disks, Disk_A_Name
	
	;MultiDisk loading, this will load the first 2 disks into drives A and B since some games can read from both drives and therefore the user won't need to change disks through the MG menu.
	If InStr(romName, "(Disk ")
	{
		If (UseSingleDrive="false") 
		{
			IniWrite, 2, %steemINI%, Disks, NumFloppyDrives
			multipartTable := CreateRomTable(multipartTable)
			If multipartTable.MaxIndex() 
			{	;Make the searches case insensitive
				original_case_sense := A_StringCaseSense
				StringCaseSense, Off

				;Has multi part
				for index, element in multipartTable 
				{	current_rom := multipartTable[A_Index,1]
					LastDotPos := InStr(current_rom,".",0,0)  ; get position of last occurrence of "."
					LastSlashPos := InStr(current_rom,"\",0,0)  ; get position of last occurrence of "\"
					fileNameNoExt := SubStr(current_rom,LastSlashPos+1, ((LastDotPos - LastSlashPos) - 1))  ; get file name only - from last slash to last dot

					If InStr(current_rom, "(Disk 1)")
					{
						IniWrite, %current_rom%, %steemINI%, Disks, Disk_A_Path
						IniWrite, %fileNameNoExt%, %steemINI%, Disks, Disk_A_Name
						cliOptions .= " """ romPath . "\" . current_rom . """"
					} Else If (InStr(current_rom, "(Disk 2)")) {
						IniWrite, %current_rom%, %steemINI%, Disks, Disk_B_Path
						IniWrite, %fileNameNoExt%, %steemINI%, Disks, Disk_B_Name
					}	
				}
				;Restore original StringCaseSense
				StringCaseSense, %original_case_sense%
			}
		} Else
			IniWrite, 1, %steemINI%, Disks, NumFloppyDrives

	} Else {
		cliOptions .= " """ romPath . "\" . romName . romExtension . """"
		IniWrite, 1, %steemINI%, Disks, NumFloppyDrives
	}
}	

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable . cliOptions, emupath) 

WinWait("ahk_class Steem Window")
WinWaitActive("ahk_class Steem Window")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


RestoreEmu: 
	Send, {Pause} 
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Steem Window")
Return
