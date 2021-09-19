MEmu := "XM6 type G"
MEmuV := "v3.10 20131123"
MURL := ["http://www.geocities.jp/kugimoto0715/"]
MAuthor := ["djvj","faahrev"]
MVersion := "2.0.4"
MCRC := "69FE75C0"
iCRC := "AA7E7184"
MID := "635242714072518055"
MSystem := ["Sharp X68000"]
;----------------------------------------------------------------------------
; Notes:
; Make sure the cgrom.dat & iplrom.dat roms exist in the emu dir or else you will get an error "Initializing the Virtual Machine is failed"
; Extensions should at least include 7z|dim|hdf|xdf|hdm
; Set your resolution by going to Tools->Options->Misc->Full screen resolution
; Set the multiplication by going to View->Stretch
;
; Be sure to use the correct format for naming the discs
; and set MultiGame to "True"
;
; Settings in RocketLauncherUI:
; - Fullscreen
; - Stretch factor (normal and bezel)
; per ROM:
; - Option to load the second disc in floppy station 1 at boot (first disc in station 0 is default)
; - Option to configure in which floppy station discs should be changed (0 or 1)
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
StretchBezel := IniReadCheck(settingsFile, "Settings", "StretchBezel","0",,1)
StretchFullscreen := IniReadCheck(settingsFile, "Settings", "StretchFullscreen","2",,1)
StretchWindow := IniReadCheck(settingsFile, "Settings", "StretchWindow","0",,1)
DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad",,,1)
MultipleDiskSlot := IniReadCheck(settingsFile, romName, "MultipleDiskSlot",,,1)
xm6gINI := CheckFile(emuPath . "\XM6g.ini")

; x1.0 = 834x652
; x0.5 = 422x382
; x1.5 = 1246x942
; x1.8 = 1493x1116
; x2.0 = 1658x1232

; BezelStart("FixResMode")
; msgbox % bezelScreenWidth . "`n" . bezelScreenHeight
 ; exitapp

fullscreen := If fullscreen = "true" ? "1" : "0"

; Setting Fast Floppy mode because it speeds up loading floppy games a bit.
; Setting Resume Window mode, it is needed to so we can launch fullscreen
; Turning off status bar because it is on by default
; Adding a SASI drive if it is turned off for hdf games
; Compare existing settings and if different than desired, write them to the emulator's ini
IniWrite(fullscreen, xm6gINI, "Window", "Full", 1)
IniWrite(StretchWindow, xm6gINI, "Display", "Stretch", 1)
IniWrite(1, xm6gINI, "Misc", "FloppySpeed", 1)
IniWrite(1, xm6gINI, "Resume", "Screen", 1)
IniWrite(0, xm6gINI, "Window", "StatusBar", 1)
IniWrite(1, xm6gINI, "SASI", "Drives", 1)

; If chosen for bezel, set stretch
If (bezelEnabled = "true")
	Iniwrite, %StretchBezel%, %xm6gINI%, Display, Stretch
Else If (fullscreen = 1)
	Iniwrite, %StretchFullscreen%, %xm6gINI%, Display, Stretch

hideEmuObj := Object("ahk_class #32770",0,"XM6 TypeG ahk_class AfxFrameOrView110",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

; If the rom is a SASI HD Image, this updates the emu ini to the path of the image
If (romExtension = ".hdf")
	IniWrite, %romPath%\%romName%%romExtension%, %xm6gINI%, SASI, File0

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)
WinWait("XM6 TypeG ahk_class AfxFrameOrView110")

; Opening second disc if needed
If (DualDiskLoad = "true") {
	RomTableCheck()	; make sure romTable is created already so the next line works
	romName2 := romTable[2,2]
	PostMessage, 0x111, 40050,,, XM6 TypeG ahk_class AfxFrameOrView110	; Open floppy1
	OpenROM("ahk_class #32770", romPath . "\" . romName2)
}

WinWait("XM6 TypeG ahk_class AfxFrameOrView110")
WinWaitActive("XM6 TypeG ahk_class AfxFrameOrView110")

; BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
Return

MultiGame:
Return

RestoreEmu:
	Control := If MultipleDiskSlot = "1" ? "40050" : "40020"
	PostMessage, 0x111, %Control%,,, XM6 TypeG ahk_class AfxFrameOrView110	; Open correct floppy
	OpenROM("ahk_class #32770", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("XM6 TypeG ahk_class AfxFrameOrView110")
Return
