MEmu := "PSXfin"
MEmuV := "v1.13"
MURL := ["http://psxemulator.gazaxian.com/"]
MAuthor := ["brolly","djvj"]
MVersion := "2.0.4"
MCRC := "B8E95642"
iCRC := "F5EC44D5"
MID := "635038268919606980"
MSystem := ["Sony PlayStation"]
;----------------------------------------------------------------------------
; Notes:
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
disableMemoryCard1 := IniReadCheck(settingsFile, romName, "DisableMemoryCard1","false",,1)	; If true, disables memory card 1 for this game. Some games may not boot if both memory cards are inserted.
disableMemoryCard2 := IniReadCheck(settingsFile, romName, "DisableMemoryCard2","false",,1)	; If true, disables memory card 2 for this game. Some games may not boot if both memory cards are inserted.
memCardPath := IniReadCheck(settingsFile, "Settings", "MemCardPath", emuPath . "\cards",,1)
memCardPath := AbsoluteFromRelative(emuPath, memCardPath)

PSXfincfg := checkFile(emuPath . "\psx.ini", "Could not find PSXfin ini. Please run PSXfin manually first and each of it's settings sections so the appropriate inis are created for you: " . emuPath . "\psx.ini")

If (vdEnabled = "true") {
	VirtualDrive("get")	; populates the vdDriveLetter variable with the drive letter to your scsi or dt virtual drive
	usedVD := 1
}

BezelStart()

; Memory Cards
defaultMemCard1 := memCardPath . "\_default_001.mcr"	; defining default blank memory card for slot 1
defaultMemCard2 := memCardPath . "\_default_002.mcr"	; defining default blank memory card for slot 2
memCardName := If romTable[1,5] ? romTable[1,4] : romName	; defining rom name for multi disc rom
romMemCard1 := memCardPath . "\" . memCardName . "_001.mcr"		; defining name for rom's memory card for slot 1
romMemCard2 := memCardPath . "\" . memCardName . "_002.mcr"		; defining name for rom's memory card for slot 2
memcardType := If perGameMemCards = "true" ? "rom" : "default"	; define the type of memory card we will create in the below loop
IfNotExist, %memCardPath%
	FileCreateDir, %memCardPath%	; create memcard folder if it doesn't exist

Loop 2
{	IfNotExist, % %memcardType%MemCard%A_Index%
	{	FileAppend,, % %memcardType%MemCard%A_Index%		; create a new blank memory card if one does not exist
		Log("Module - Created a new blank memory card in Slot " . A_Index . ":" . %memcardType%MemCard%A_Index%)
	}
	; Now disable a memory card if required for the game to boot properly
	If (disableMemoryCard%A_Index% = "true")
	{
		IniWrite, "", %PSXfincfg%, Cards, Card%A_Index%
	} ELSE {
		memcardOut := %memcardType%MemCard%A_Index%
		IniWrite, %memcardOut%, %PSXfincfg%, Cards, Card%A_Index%
	}
}

hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"pSX ahk_class pSX",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := If fullscreen = "true" ? " -f" : ""

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

; Mount the CD using Virtual Drive
If (romExtension = ".cue" && usedVD)
{	VirtualDrive("mount",romPath . "\" . romName . romExtension)
	Run(executable . fullscreen . " " . vdDriveLetter . ":", emuPath)
} Else {
	Log("Module RunWait - " . emuPath "\" . executable . " -f """ . romPath . "\" . romName . romExtension . """")
	Run(executable . fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath)
}

SetTitleMatchMode, slow
WinWait("pSX ahk_class pSX")
WinWaitActive("pSX ahk_class pSX")

If fullscreen = true
{	SetKeyDelay(50)
	Send, {Alt Down}{Enter Down}{Enter Up}{Alt Up}
}

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

If (romExtension = ".cue" && usedVD)
	VirtualDrive("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from Virtual Drive
	If (romExtension = ".cue" && vdEnabled = "true")
		VirtualDrive("unmount")
	Sleep, 500	; Required to prevent your Virtual Drive from bugging
	; Mount the CD using Virtual Drive
	If (romExtension = ".cue" && vdEnabled = "true")
		VirtualDrive("mount",selectedRom)
Return

RestoreEmu:
	SetWinDelay, 50
	If fullscreen = true
	{	SetKeyDelay(50)
		Send, {Alt Down}{Enter Down}{Enter Up}{Alt Up}
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("pSX ahk_class pSX")
Return
