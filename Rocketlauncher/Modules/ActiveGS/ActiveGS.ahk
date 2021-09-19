MEmu := "ActiveGS"
MEmuV := "v3.7.1019"
MURL := ["http://activegs.freetoolsassociation.com/"]
MAuthor := ["wahoobrian","brolly"]
MVersion := "2.1.3"
MCRC := "1E119D14"
iCRC := "ED17ED6"
MID := "635412285478387119"
MSystem := ["Apple II","Apple IIGS"]
;------------------------------------------------------------------------------------------------------------------
; Notes:
; CLI is very limited for this Emulator.  
; To get around this, the module deletes and recreates the startup configuration xml file - default.activegsxml
;
; You will need to supply a default hard drive image that contains the ProDOS operating system.
; This is a good one ---> http://www.whatisthe2gs.apple2.org.za/files/harddrive_image.zip 
;
; If you want to keep your default default.activegsxml file after exiting then make a copy of it in the 
; emulator folder and name it original.activegsxml. This file will then be copied over on exit.
;------------------------------------------------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("ActiveGS","AfxFrameOrView90s"))	; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle(dialogOpen,"#32770"))
emuAltWindow := new Window(new WindowTitle("ActiveGS","#32770"))

emuPrimaryWindow.CreateControl("FocusWindow")	; Instantiate new control for FocusWindow. This is not an actual control, just the reference for this control instance
emuAltWindow.CreateControl("ComboBox1")	; Instantiate new control for ComboBox1
emuAltWindow.CreateControl("Button7")	; Instantiate new control for Button7

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
KeepAspectRatio := moduleIni.Read("Settings", "KeepAspectRatio","true",,1)
externalOS := moduleIni.Read(romName, "External_OS","false",,1)
SingleDrive := moduleIni.Read(romName, "SingleDrive","false",,1)
DiskSwapDrive := moduleIni.Read(romName, "DiskSwapDrive","1",,1)
HardDiskImage := moduleIni.Read(romName, "HardDiskImage","false",,1)
Command := moduleIni.Read(romName, "Command",,,1)
SendCommandDelay := moduleIni.Read(romName . "|Settings", "SendCommandDelay", "2000",,1)
WaitBetweenSends := moduleIni.Read(romName . "|Settings", "WaitBetweenSends", "false",,1)
DefaultVideoType := moduleIni.Read("Settings", "VideoType", "lcd",,1)
VideoType := moduleIni.Read(romName, "VideoType", DefaultVideoType,,1)
ColorMode := moduleIni.Read(romName, "ColorMode", "auto",,1)
BootableHardDiskImage := moduleIni.Read("Settings", "BootableHardDiskImage","System 6.hdv",,1)

configFile := new PropertiesFile(A_MyDocuments . "\ActiveGSLocalData\activegs.conf",":")
If configFile.Exist() {
	configFile.LoadProperties()	; load the config into memory
	;Set the properties in the preferences.cfg file
	configFile.ReadProperty("videoFX")
	configFile.ReadProperty("colorMode")
	configFile.WriteProperty("videoFX",VideoType)
	configFile.WriteProperty("colorMode",ColorMode)
	configFile.SaveProperties()	; save changes to Preferences.cfg
} Else
	RLLog.Info("Module - activegs.conf was not found at " . configFile.FileFullPath . ". Emulator was probably never ran before.")

If (SystemName = "Apple II") {
	if (romExtension = ".dsk") {
		bootslot := "6"
		SlotNumber := "6"
	} Else {
		bootslot := "5" 
		SlotNumber := "5"
	}	
} Else {
	bootslot := "5" 
	SlotNumber := "5"
}	

disk1 := " "
disk2 := " "
slot7disk1 := " "

If (HardDiskImage = "true") {
	slot7disk1 := romPath . "\" . romName . romExtension
	bootslot := 7
} Else {
	TimerUtils.Sleep(100)	; Without this romtable comes empty (thread related?)
	RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
	If (romTable.MaxIndex() > 1) {
		If (SingleDrive = "true") { ;some games require all disks to be mounted in only one drive
			disk1 := romTable[1,1]
		} Else {
			disk1 := romTable[1,1]
			disk2 := romTable[2,1]
		}
	} Else
		disk1 := romPath . "\" . romName . romExtension
}	

If (externalOS = "true") {
	BootableHardDiskImageFile := new File(emuPath . "\" . BootableHardDiskImage)
	BootableHardDiskImageFile.CheckFile("Using an external OS but could not find the BootableHardDiskImage: " . BootableHardDiskImageFile.FileFullPath)	; For games without OS included, make sure it exists and error If not found
	slot7disk1 := emuPath . "\" . BootableHardDiskImage
	bootslot := 7
}

; Limited CLI, so setup XML with proper disks and correct boot sequence
originalActiveGSXMLFile := new File(emuPath . "\original.activegsxml")
defaultActiveGSXMLFile := new File(emuPath . "\default.activegsxml")
defaultActiveGSXMLFile.Delete()  ; Build a new file on every execution
ActiveGSXML :=
(
"<?xml version=""1.0"" encoding=""iso-8859-1""?>
<config version=""2"">
	<format>2GS</format>
	<image slot=""" . SlotNumber . """ disk=""1"" icon="""">" . disk1 . "</image>
	<image slot=""" . SlotNumber . """ disk=""2"" icon="""">" . disk2 . "</image>
	<image slot=""7"" disk=""1"" icon="""">" . slot7disk1 . "</image>
	<speed>2</speed>
	<bootslot>" . bootslot . "</bootslot>
</config>"
)
defaultActiveGSXMLFile.Append(ActiveGSXML)

BezelStart()

hideEmuObj := Object(emuAltWindow,0,emuOpenWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run()

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

KeyUtils.Send("{F8}")	; Enable Mouse Lock

If (Fullscreen = "true") {
	; No true fullscreen is available for ActiveGS, so we fake it by maximizing the window
	emuPrimaryWindow.RemoveMenubar()
	; TimerUtils.Sleep(600)	; Need this otherwise the game window snaps back to size, increase If this occurs
	emuPrimaryWindow.Maximize(KeepAspectRatio)
} Else {
	; Resize window per user settings and center
	WindowWidth := moduleIni.Read("Settings", "WindowWidth","800",,1)
	WindowHeight := moduleIni.Read("Settings", "WindowHeight","600",,1)
	emuPrimaryWindow.Move((A_ScreenWidth-WindowWidth)/2, (A_ScreenHeight-WindowHeight)/2, WindowWidth, WindowHeight)
}

WaitBetweenSends := (If WaitBetweenSends = "true" ? "1" : "0")

emuPrimaryWindow.WaitActive()
KeyUtils.SendCommand(Command, SendCommandDelay, "500", WaitBetweenSends)

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
	emuPrimaryWindow.PostMessage(0x111, 40025)	; Pause
Return

RestoreEmu:
	emuPrimaryWindow.PostMessage(0x111, 40025)	; Pause
Return

MultiGame:
	If (systemName = "Apple II")
		DriveToChoose := If DiskSwapDrive = "1" ? "S6D1" : "S6D2"
	Else
		DriveToChoose := If DiskSwapDrive = "1" ? "S5D1" : "S5D2"

	emuPrimaryWindow.GetControl("FocusWindow").Click("x100 y100","Right",,"NAPos")	; Click on the window (this way it will work even If it's not on focus)

	emuAltWindow.Wait()
	emuAltWindow.WaitActive()
	
	emuAltWindow.GetControl("ComboBox1").Control("ChooseString",DriveToChoose)	; Select the correct drive in the ComboBox

	emuAltWindow.GetControl("Button7").Click(,,,"NA")	; Click Button7
	emuOpenWindow.OpenROM(selectedRom)

	emuAltWindow.Close()
Return

CloseProcess:
	FadeOutStart()
	If originalActiveGSXMLFile.Exist()
	{
		originalActiveGSXMLFile.Copy(defaultActiveGSXMLFile.FileFullPath,1)
	}
	emuPrimaryWindow.Close()
Return
