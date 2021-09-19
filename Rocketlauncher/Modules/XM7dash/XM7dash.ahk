MEmu := "XM7dash"
MEmuV := "v3.4 L77 R26 (2016/01/09)"
MURL := ["http://tomatoma.s54.xrea.com/xm7/"]
MAuthor := ["wahoobrian","brolly"]
MVersion := "1.0.0"
MCRC := "4F4A4EE0"
iCRC := "6DB63BB1"
MID := "636084662192134726"
MSystem := ["Fujitsu FM-7"]
;----------------------------------------------------------------------------
; Notes:
; Extensions should at least include 7z|zip|d77|t77|xm7
; Set your resolution by going to Tools->Configure->Screen->Full-screen view
; (Assuming you are using the translated version, otherwise it's the 6th menu from the left and then the 1st menu item and the last tab)
;
; Module will use a FM77AV system by default, if a game requires a specific mode make sure you configure it through RLUI
; Be sure to use the correct format for naming the discs and set MultiGame to "True"
;
; This module only works with the XM7dash version, make sure you are using that one and not the regular version.
;
; the FM77-AV had three space keys and some games use all of them, so you'll need to map the other two to something in the emulator (keys #57 and #58 on the XM7 keyboard map). Go to Tools->Configure->Keyboard then in the keyboard map table find the row No. 57 and 58 double click on them set the mapped keys and right click mouse to confirm each type.
; You will also need to map the Esc key in the same dialog since some games need it.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("XM7","XM7"))	; instantiate primary emulator window object
openRomWindow := new Window(new WindowTitle(,"#32770"))		; instantiate open rom window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
AspectRatioAdjustment := moduleIni.Read("Settings", "AspectRatioAdjustment","true",,1)
ShowStatusBar := moduleIni.Read("Settings", "ShowStatusBar","false",,1)

DiskBasicLocation := moduleIni.Read("Settings", "DiskBasicLocation", romPathOrig . "\System\F-BASIC v3.0 L10.d77",,1)
DiskBasicLocation := GetFullName(DiskBasicLocation)
UraDOSLocation := moduleIni.Read("Settings", "UraDOSLocation", romPathOrig . "\System\Ura DOS (Japan).d77",,1)
UraDOSLocation := GetFullName(UraDOSLocation)

Model := moduleIni.Read(romName, "Model","2|3|1",,1)
DualDiskLoad := moduleIni.Read(romName, "DualDiskLoad",,,1)
MultipleDiskSlot := IniReadCheck(romName, "MultipleDiskSlot",,,1)
Command := moduleIni.Read(romName, "Command",,,1)
BootMode := moduleIni.Read(romName, "BootMode", "1",,1)
RequiresBootFromBasicDisk := moduleIni.Read(romName, "RequiresBootFromBasicDisk", "false",,1)
RequiresBootFromUraDOS := moduleIni.Read(romName, "RequiresBootFromUraDOS", "false",,1)
UseMouse := moduleIni.Read(romName, "UseMouse", "false",,1)

; Making all letters lower case or the emulator will end up with the shift key held down forever! Upper case letters should be typed by using {Shift Down}/{Shift Up} in the Command setting as needed.
StringLower, Command, Command

Command := StringUtils.Replace(Command, """", "{Shift Down}2{Shift Up}", "All")
Command := StringUtils.Replace(Command, "/", "{NumpadDiv}", "All")
Command := StringUtils.Replace(Command, "-", "{NumpadSub}", "All")

; Update xm7Dash ini to ensure last used disks/tapes are cleared out.  If they remain, the last disk will autoboot - even if a tape is passed in via the module.
xm7DashINI := new IniFile(emuPath . "\xm7dash.ini")
xm7DashINI.CheckFile()
xm7DashINI.Write("", "Tape", "File0")
xm7DashINI.Write("", "MFD0", "File0")
xm7DashINI.Write("", "MFD1", "File0")

; Set Model
ModelArray := StringUtils.Split(Model,"|")
xm7DashINI.Write(ModelArray[1], "General", "Version")
xm7DashINI.Write(ModelArray[2], "General", "SubVersion")
xm7DashINI.Write(ModelArray[3], "General", "CycleSteal")

; SetMouse
If (UseMouse = "true") {
	xm7DashINI.Write("1", "Option", "MouseEmulation")
	xm7DashINI.Write("2", "Option", "MousePort")
	xm7DashINI.Write("1", "Option", "MidBtnMode")
} Else {
	xm7DashINI.Write("0", "Option", "MouseEmulation")
	xm7DashINI.Write("2", "Option", "MousePort")
	xm7DashINI.Write("1", "Option", "MidBtnMode")
} 

; Updating aspect ratio and status bar settings
xm7DashINI.Write(If AspectRatioAdjustment = "true" ? "1" : "0", "Screen", "AspectRatioAdj")
xm7DashINI.Write(If ShowStatusBar = "true" ? "1" : "0", "Window", "StatusBar")
xm7DashINI.Write(If ShowStatusBar = "true" ? "1" : "0", "Screen", "DD480Status")

; Set BootMode
If (romExtension = ".t77")
	xm7DashINI.Write(0, "Resume", "BootMode")
Else 
	xm7DashINI.Write(BootMode, "Resume", "BootMode")

BezelStart("FixResMode")

; Force windowed mode because fullscreen needs to be set through the menu after we have loaded the game
xm7DashINI.Write("0", "Window", "FullScreen")

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

RomTableCheck()	; make sure romTable is created already so the next line works
romName2 := romTable[2,2]

HideAppStart(hideEmuObj,hideEmu)

If (RequiresBootFromBasicDisk = "true") {
	primaryExe.Run(" """ . DiskBasicLocation . """")
	emuPrimaryWindow.Wait()
	KeyUtils.SendCommand("1{Enter}{wait}0{Enter}{wait}")
	emuPrimaryWindow.PostMessage(0x111, 50070)
	openRomWindow.OpenROM(romPath . "\" . romName . romExtension)
	If (Command)
		KeyUtils.SendCommand(Command)
} Else If (RequiresBootFromUraDOS = "true") {
	primaryExe.Run(" """ . UraDOSLocation . """")
	emuPrimaryWindow.Wait()
	Sleep, 3000
	emuPrimaryWindow.PostMessage(0x111, 50070)
	openRomWindow.OpenROM(romPath . "\" . romName . romExtension)
	If (Command)
		KeyUtils.SendCommand(Command)
} Else If (romExtension = ".d77" && romName2) {
	primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """ " . """" . romPath . "\" . romName2 . """")
} Else {	
	primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")
}

emuPrimaryWindow.Wait()
Sleep, 1500

If (romExtension = ".t77") {
	emuPrimaryWindow.PostMessage(0x111, 40052)
	openRomWindow.OpenROM(romPath . "\" . romName . romExtension)
	If (Command) {
		KeyUtils.SendCommand(Command)
	} Else {
		Command = run{Shift Down}22{Shift Up}{Enter}
		KeyUtils.SendCommand(Command)
	}
} Else If (Command && RequiresBootFromBasicDisk = "false" && RequiresBootFromUraDOS = "false") {
	KeyUtils.SendCommand(Command)
}

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

; Changing to fullscreen if needed
If (FullScreen = "true")
	emuPrimaryWindow.PostMessage(0x111, 40078)

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

HaltEmu:
	disableSuspendEmu := true
Return

MultiGame:
	RLLog.Info("MultiGame label triggered")
	If (romExtension = ".t77") {
		emuPrimaryWindow.PostMessage(0x111,40052)
		openRomWindow.OpenROM(selectedRom)
	}
	If (romExtension = ".d77") {
		emuPrimaryWindow.PostMessage(0x111, 50070)
		openRomWindow.OpenROM(selectedRom)
	}
	emuPrimaryWindow.WaitActive(5)
	emuPrimaryWindow.Activate()
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
