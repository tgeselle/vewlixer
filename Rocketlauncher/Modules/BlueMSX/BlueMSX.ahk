MEmu := "BlueMSX"
MEmuV := "v2.8.2"
MURL := ["http://www.bluemsx.com/"]
MAuthor := ["djvj","brolly"]
MVersion := "2.1.5"
MCRC := "8C926ADE"
iCRC := "AF158E9A"
MID := "635038268875990669"
MSystem := ["ColecoVision","Microsoft MSX","Microsoft MSX2","Microsoft MSX2+","Microsoft MSX Turbo-R","Sega SG-1000","Spectravideo"]
;----------------------------------------------------------------------------
; Notes:
; Set your fullscreen res manually in the emu by clicking Options->Performance->Fullscreen Resolution
;
; Make sure you enable the following settings:
; File->Cassette->Rewind after insert
; File->Cassette->Use Cassette Image Read Only
; File->Cartridge Slot 1->Reset After Insert/Remove
; Options->Settings->Eject all media when blueMSX exits
;
; And make sure you disable the following settings:
; File->Disk Drive A->Reset After Insert
;
; Configure the keymapping for the joysticks in Tools->Input Editor
;
; Valid Spectravideo Machines are only the SVI-318 and SVI-328 ones all the others are MSX based machines
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("blueMSX","blueMSX"))	; instantiate primary emulator window object
emuTapeWindow := new Window(new WindowTitle("blueMSX - Tape Position","#32770"))
emuOpenCasWindow := new Window(new WindowTitle("Insert cassette tape","#32770"))

mType := Object("ColecoVision","COL - ColecoVision","Microsoft MSX","MSX","Microsoft MSX2","MSX2","Microsoft MSX2+","MSX2+","Microsoft MSX Turbo-R","MSXturboR","Sega SG-1000","SEGA - SG-1000","Spectravideo","SVI - Spectravideo SVI-328 80 Column")
ident := mType[systemName]	; search machine type for the systemName identifier BlueMSX uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this BlueMSX module: " . moduleName)

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
UseDxWnd := moduleIni.Read("Settings", "UseDxWnd","false",,1)
Stretch := moduleIni.Read("Settings", "Stretch","false",,1)
GlobalJoystick1 := moduleIni.Read("Settings", "Joystick1","joystick",,1)
GlobalJoystick2 := moduleIni.Read("Settings", "Joystick2","joystick",,1)
Joystick1 := moduleIni.Read(romName, "Joystick1",GlobalJoystick1,,1)
Joystick2 := moduleIni.Read(romName, "Joystick2",GlobalJoystick2,,1)

If (UseDxWnd = "true")
	BezelStart()
Else
	BezelStart("fixResMode")

If ((BezelEnabled() || Fullscreen = "false") && UseDxWnd = "true")
	Fullscreen := "true"
Else
	UseDxWnd = "false"

Machine := ident
If StringUtils.Contains(ident,"MSX")
{
	TapeLoadTime := moduleIni.Read("Settings", "TapeLoadTime","8000",,1)
	Machine := moduleIni.Read(romName, "Machine",ident,,1)
	TapeLoadingMethod := moduleIni.Read(romName, "TapeLoadingMethod","RUN""CAS:""",,1)
	CLoadWaitTime := moduleIni.Read(romName, "CLoadWaitTime","50",,1)
	PositionTape := moduleIni.Read(romName, "PositionTape","false",,1)
	CartSlot1 := moduleIni.Read(romName, "CartSlot1",,,1)
	CartSlot2 := moduleIni.Read(romName, "CartSlot2",,,1)
	HoldKeyOnBoot := moduleIni.Read("Settings"  . "|" .  romName, "HoldKeyOnBoot",,,1)
	DualDiskLoad := moduleIni.Read(romName, "DualDiskLoad","false",,1)
	DiskSwapDrive := moduleIni.Read(romName, "DiskSwapDrive","A",,1)
	
	; MultiGame setup
	If (DiskSwapDrive = "A") {
		MessageToSend := "41300"
		emuOpenDskWindow := new Window(new WindowTitle("Insert disk image into drive A","#32770"))
	} Else {
		MessageToSend := "41400"
		emuOpenDskWindow := new Window(new WindowTitle("Insert disk image into drive B","#32770"))
	}
}
Else If StringUtils.Contains(ident,"SVI")
{
	TapeLoadTime := moduleIni.Read("Settings", "TapeLoadTime","8000",,1)
	Machine := moduleIni.Read(romName, "Machine",ident,,1)
	TapeLoadingMethod := moduleIni.Read(romName, "TapeLoadingMethod","CLOAD+RUN",,1)
	CLoadWaitTime := moduleIni.Read(romName, "CLoadWaitTime","50",,1)
	PositionTape := moduleIni.Read(romName, "PositionTape","false",,1)
}

;Different keyboard layouts will use different keys
ColonKey := moduleIni.Read("Settings", "ColonKey",":",,1)
DoubleQuoteKey := moduleIni.Read("Settings", "DoubleQuoteKey","""",,1)

BlueMSXIni := new IniFile(emuPath . "\bluemsx.ini")
BlueMSXIni.CheckFile()

currentFullscreen := BlueMSXIni.Read("config", "video.windowSize")
currentStretch := BlueMSXIni.Read("config", "video.horizontalStretch")

currentJoystick1 := BlueMSXIni.Read("config", "joy1.type")
currentJoystick2 := BlueMSXIni.Read("config", "joy2.type")

; Setting Fullscreen setting in ini If it doesn't match what user wants above
; Do not use the /fullscreen CLI because If it's not specified it will use the setting from the ini file
If (Fullscreen != "true" && currentFullScreen = "fullscreen")
	BlueMSXIni.Write("normal","config","video.windowSize")
Else If (Fullscreen = "true" && currentFullScreen = "normal")
	BlueMSXIni.Write("fullscreen","config","video.windowSize")

; Setting Stretch setting in ini If it doesn't match what user wants above
If (Stretch != "true" && currentStretch = "yes")
	BlueMSXIni.Write("no","config","video.horizontalStretch")
Else If (Stretch = "true" && currentStretch = "no")
	BlueMSXIni.Write("yes","config","video.horizontalStretch")

; Setting Joystick settings If they don't match
If (Joystick1 != currentJoystick1)
	BlueMSXIni.Write(Joystick1,"config","joy1.type")
If (Joystick2 != currentJoystick2)
	BlueMSXIni.Write(Joystick2,"config","joy2.type")

params := " /theme """ . (If bezelPath ? "Classic" : "DIGIblue_SuiteX2") . """"

hideEmuObj := Object(emuTapeWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, SevenZExtractPath)

If (romExtension = ".dsk")	; Disk games
{
	params .= " /diskA """ . romPath . "\" . romName . romExtension . """"
	If (DualDiskLoad = "true")
	{
		If StringUtils.Contains(romName,"\(Disk 1")
		{
			RomTableCheck()	; Make sure romTable is created already so the next line can calculate correctly
			If (romtable.MaxIndex() > 1)
			{
				romName2 := romtable[2,1]	; This should be disk 2
				params .= " /diskB """ . romName2 . """"
			}
		}
	}
}
Else If (romExtension = ".cas")	; Cassette games
	params .= " /cas """ . romPath . "\" . romName . romExtension . """"
Else	; Cart games
	params .= " /rom1 """ . romPath . "\" . romName . romExtension . """"
If CartSlot1
	If (CartSlot1 != "64KBexRAM")
		params .= " /romtype1 """ . CartSlot1 . """"
If CartSlot2
	If (CartSlot2 != "64KBexRAM")
		params .= " /romtype2 """ . CartSlot2 . """"

params .= " /machine """ . Machine . """"	; CLI order matters for some machines like ColecoVision, rom must be set before the machine

HideAppStart(hideEmuObj,hideEmu)

If (UseDxWnd = "true")
	DxwndRun()

primaryExe.Run(params)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If bezelPath {
	emuPrimaryWindow.CreateControl("blueMSXmenuWindow1")		; instantiate new control for blueMSXmenuWindow1
	emuPrimaryWindow.GetControl("blueMSXmenuWindow1").Control("Hide")	; Hide control blueMSXmenuWindow1
	; Control, Hide, , ahk_class blueMSXmenuWindow1, ahk_class blueMSX
}

If CartSlot1
	If (CartSlot1 = "64KBexRAM")
		emuPrimaryWindow.PostMessage("0x111", 41113)
If CartSlot2
	If (CartSlot2 = "64KBexRAM")
		emuPrimaryWindow.PostMessage("0x111", 41263)

If HoldKeyOnBoot
{
	TimerUtils.Sleep(2000)	; To make sure the boot process has started otherwise the key will be pressed too early

	If (HoldKeyOnBoot = "Ctrl")
		KeyUtils.Send("{LCtrl Down}")
	Else If (HoldKeyOnBoot = "Shift")
		KeyUtils.Send("{SHIFTDOWN}")

	If (romExtension != ".cas")
	{
		TimerUtils.Sleep(3000)	; Wait for boot
		If (HoldKeyOnBoot = "Ctrl")
			KeyUtils.Send("{LCtrl Up}")
		Else If (HoldKeyOnBoot = "Shift")
			KeyUtils.Send("{SHIFTUP}")
	}
}

TimerUtils.Sleep(2000)	; Need this otherwise Your Front End can flash back in during fade

If (romExtension = ".cas")
{
	; Tape loading procedures
	TimerUtils.Sleep(TapeLoadTime)

	delay := 50
	pressDuration := 50
	If StringUtils.Contains(ident,"SVI")
	{
		; Spectravideo needs longer durations otherwise keys won't be captured properly
		delay := 100
		pressDuration := 100
	}

	If StringUtils.Contains(ident,"MSX")
	{
		KeyUtils.SetKeyDelay(delay, pressDuration)
		KeyUtils.Send("{Enter}{Enter}")		; For the date screen
		TimerUtils.Sleep(1000)	; Wait for the BASIC prompt to appear
	}

	; Release the boot keys If needed
	If (HoldKeyOnBoot = "Ctrl")
		KeyUtils.Send("{LCtrl Up}")
	Else If (HoldKeyOnBoot = "Shift")
		KeyUtils.Send("{SHIFTUP}")

	If TapeLoadingMethod
	{
		If (PositionTape = "true")
		{
			; Wait until user selects the game
			BezelDraw()
			HideAppEnd(hideEmuObj,hideEmu)
			FadeInExit()
			KeyUtils.Send("^!{F11}")
			emuTapeWindow.Wait()
			emuTapeWindow.WaitActive()
			emuTapeWindow.WaitClose()
		}

		If (TapeLoadingMethod = "CLOAD+RUN")
		{
			KeyUtils.SendCommand("cload{Enter}{Wait:" . CLoadWaitTime . "}run{Enter}", 0, 500, 0, delay, pressDuration)
		} Else {
			TapeLoadingMethod := StringUtils.Replace(TapeLoadingMethod, """", DoubleQuoteKey, "All")
			TapeLoadingMethod := StringUtils.Replace(TapeLoadingMethod, ":", ColonKey, "All")
			KeyUtils.SendCommand(TapeLoadingMethod . "{Enter}", 0, 500, 0, delay, pressDuration)
		}

		If (PositionTape != "true")
		{
			BezelDraw()
			HideAppEnd(hideEmuObj,hideEmu)
			FadeInExit()
		}
	}
} Else {
	BezelDraw()
	HideAppEnd(hideEmuObj,hideEmu)
	FadeInExit()
}

primaryExe.Process("WaitClose")

If (UseDxWnd = "true")
	DxwndClose()

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	If (romExtension = ".cas") {
		emuPrimaryWindow.PostMessage("0x111", 41500)	; Insert Cassette
		emuOpenCasWindow.OpenROM(selectedRom)
	} Else If (romExtension = ".dsk") {
		emuPrimaryWindow.PostMessage("0x111", MessageToSend)	; Insert Disk A
		emuOpenDskWindow.OpenROM(selectedRom)
	}
Return

HaltEmu:
	disableSuspendEmu := true
	emuPrimaryWindow.PostMessage("0x111", 40025)	; Pause
Return

RestoreEmu:
	emuPrimaryWindow.PostMessage("0x111", 40025)	; Pause
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
