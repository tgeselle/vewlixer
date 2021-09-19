MEmu := "NullDC"
MEmuV := "r141"
MURL := ["https://code.google.com/p/nulldc/"]
MAuthor := ["djvj","bleasby"]
MVersion := "2.0.7"
MCRC := "9A3E2657"
iCRC := "D1BEBB86"
MID := "635038268910409317"
MSystem := ["Sega Dreamcast"]
;----------------------------------------------------------------------------
; NullDC works with these disc images:
; - CDI: Padus DiscJuggler image
; - MDS: Alcohol 120% Media Descriptor image (must be accompanied by a MDF file)
; - NRG: Nero Burning ROM image
; - GDI: Raw GDI dump
; - CHD: MAME's Compressed Hunk of Data
;
; Helpful guide for getting the basics setup for NullDC: http://www.dgemu.com/forums/index.php/topic/474318-guide-configuring-nulldc-104-r136/
; If you want to use specific configs per game, create a folder called Cfg inside nullDC folder and copy your nullDC.cfg 
; config files into it naming them to match the database names. Make sure you keep a copy of nullDC.cfg on the Cfg folder as well.
;
; If you want to convert your roms from gdi to chd, see here: http://www.emutalk.net/showthread.php?t=51502
; FileDelete(s) are in the script because sometimes demul will corrupt the ini and make it crash. The script recreates a clean ini for you.
;
; Setup the user settings in the moduleName ini to your liking
; Games can have a custom Cable Type (per game). Not all games work on VGA, so use the below option in the ini
; Cable can be 0 (VGA(0)(RGB)), 1 (VGA(1)(RGB)), 2 (TV(RGB)) or 3 (TV(VBS/Y+S/C)), default is 0.
;
; Not all builds work with swapping discs, it's mostly broken and is a nulldc problem, not RocketLauncher's. See here: http://code.google.com/p/nulldc/issues/detail?id=264
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
ExtraFixedResBezelGUI()

If !RegExMatch(systemName,"i)dreamcast|dc")
	ScriptError(systemName . " is not a supported system for this module. Only " . MSystem . " is supported.")

FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
nullDCcfg := checkFile(emuPath . "\nullDC.cfg")

fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
dualMonitors := IniReadCheck(settingsFile, "NullDC", "DualMonitors","false",,1)
autoStart := IniReadCheck(settingsFile, "NullDC", "autoStart","1",,1)
noConsole := IniReadCheck(settingsFile, "NullDC", "noConsole","1",,1)
autoHideMenu := IniReadCheck(settingsFile, "NullDC", "autoHideMenu","0",,1)
alwaysOnTop := IniReadCheck(settingsFile, "NullDC", "alwaysOnTop","1",,1)
showVMU := IniReadCheck(settingsFile, "NullDC", "showVMU","0",,1)
VMU1Pos := IniReadCheck(settingsFile, "NullDC", "VMU1Pos","topLeft",,1) ; topRight, topCenter, topLeft, leftCenter, bottomLeft, bottomCenter, bottomRight, rightCenter 
VMU2Pos := IniReadCheck(settingsFile, "NullDC", "VMU2Pos","topRight",,1) ; topRight, topCenter, topLeft, leftCenter, bottomLeft, bottomCenter, bottomRight, rightCenter 
VMU3Pos := IniReadCheck(settingsFile, "NullDC", "VMU3Pos","bottomLeft",,1) ; topRight, topCenter, topLeft, leftCenter, bottomLeft, bottomCenter, bottomRight, rightCenter 
VMU4Pos := IniReadCheck(settingsFile, "NullDC", "VMU4Pos","bottomRight",,1) ; topRight, topCenter, topLeft, leftCenter, bottomLeft, bottomCenter, bottomRight, rightCenter 
VMUHideKey := IniReadCheck(settingsFile, "Settings", "VMUHideKey","F10",,1)
loadDefaultImage := IniReadCheck(settingsFile, "NullDC", "loadDefaultImage","1",,1)
patchRegion := IniReadCheck(settingsFile, "NullDC", "patchRegion","1",,1)
cable := IniReadCheck(settingsFile, romName, "Cable","0",,1)
PerGameMemoryCards := IniReadCheck(settingsFile, "NullDC", "PerGameMemoryCards","true",,1)
memCardPath := IniReadCheck(settingsFile, "Settings", "MemCardPath", emuPath . "\Game VMU",,1)
memCardPath := AbsoluteFromRelative(emuPath, memCardPath)

hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"nullDC ahk_class ndc_main_window",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

specialCfg := emuPath . "\cfg\" . romName . ".cfg"
defaultCfg := emuPath . "\cfg\nullDC.cfg"
If (FileExist(specialCfg) && FileExist(defaultCfg))
	FileCopy, %specialCfg%, %emuPath%\nullDC.cfg, 1
Else If FileExist(defaultCfg)
	FileCopy, %defaultCfg%, %emuPath%\nullDC.cfg, 1

;Detect game region based on rom name
If InStr(romName,"(Europe)")
	region := 2
Else If InStr(romName,"(Japan)")
	region := 0
Else If InStr(romName,"(World)")
	region := 2
Else
	region := 1

If RegExMatch(romExtension,"i)" . sevenZFormatsRegEx)
	ScriptError(MEmu . " does not support compressed formats. Please extract your images first or enable 7z.")

BezelStart()

;Write Settings
IniWrite, % (If (Fullscreen = "true" )?("1"):("0")), %nullDCcfg%, nullDC_GUI, Fullscreen
IniWrite, %autoStart%, %nullDCcfg%, nullDC, Emulator.AutoStart
IniWrite, %noConsole%, %nullDCcfg%, nullDC, Emulator.NoConsole
IniWrite, %autoHideMenu%, %nullDCcfg%, nullDC_GUI, AutoHideMenu
IniWrite, %alwaysOnTop%, %nullDCcfg%, nullDC_GUI, AlwaysOnTop
IniWrite, %showVMU%, %nullDCcfg%, drkMaple, VMU.Show
IniWrite, %loadDefaultImage%, %nullDCcfg%, ImageReader, LoadDefaultImage
IniWrite, %patchRegion%, %nullDCcfg%, ImageReader, PatchRegion
IniWrite, %region%, %nullDCcfg%, nullDC, Dreamcast.Region
IniWrite, %cable%, %nullDCcfg%, nullDC, Dreamcast.Cable
Log("Module - Telling ImageReader plugin to load this game: """ . romPath . "\" . romname . RomExtension)
IniWrite, %romPath%\%romname%%RomExtension%, %nullDCcfg%, ImageReader, DefaultImage

;Fixes hanging previous nullDC on bad exits or loads
Process("Exist", executable)
If !(ErrorLevel := 0)
	Process("Close", executable)

; This hides nullDC's menu when running dual screens
If (dualMonitors := "true")
{	MouseGetPos X, Y 
	SetDefaultMouseSpeed, 0
	MouseMove %A_ScreenWidth%,%A_ScreenHeight%
}

If (PerGameMemoryCards := "true")
{
	defaultMemCard := emuPath . "\Data\vmu_default.bin"	; defining default blank VMU file
	If FileExist(defaultMemCard)
	{
		Log("VMU - Default VMU file location - " . defaultMemCard,4)
		Log("VMU - Per game memory card path - " . memCardPath,4)
		If !FileExist(memCardPath)
			FileCreateDir, %memCardPath%
		Loop, 4
		{
			VMUCount := A_Index - 1
			controllerVMU%VMUCount% := IniReadCheck(nullDCcfg, "nullDC_plugins", "Current_maple" . VMUCount . "_" . "5",,,1)
			Log("VMU - Config Plugin controllerVMU" . VMUCount . " - " . controllerVMU%VMUCount%,4)
			If controllerVMU%VMUCount% = NULL
				Continue
			Loop, 2
			{
				SubCount := A_Index - 1
				controllerVMU%VMUCount%SubDev%SubCount% := IniReadCheck(nullDCcfg, "nullDC_plugins", "Current_maple" . VMUCount . "_" . SubCount,,,1)
				Log("VMU - Config Plugin controllerVMU" . VMUCount . " Sub " . SubCount . " - " . controllerVMU%VMUCount%SubDev%SubCount%,4)
				If (controllerVMU%VMUCount%SubDev%SubCount% = "drkMapleDevices_Win32.dll:2") or (controllerVMU%VMUCount%SubDev%SubCount% = "G15_drkMapleDevices_Win32.dll:2")
				{
					If (VMUCount = 0)
						VMUPort := "0"
					Else If (VMUCount = 1)
						VMUPort := "4"
					Else If (VMUCount = 2)
						VMUPort := "8"
					Else If (VMUCount = 3)
						VMUPort := "C"
					VMUGameName := If romTable[1,5] ? romTable[1,4] : romName	; defining rom name for multi disc rom
					PerGameVMUIn := memCardPath . "\" . VMUGameName . "_port" . VMUPort . A_Index . ".bin"
					PerGameVMUOut := emuPath . "\vmu_data_port" . VMUPort . A_Index . ".bin"
					If (FileExist(PerGameVMUIn))
					{
						Log("VMU - Per game VMU in file """ . PerGameVMUIn . """ exists. Copying to emu folder as """ . PerGameVMUOut . """")
						FileCopy, %PerGameVMUIn%, %PerGameVMUOut%, 1
					} Else {
						FileCopy, %defaultMemCard%, %PerGameVMUOut%, 1
						Log("VMU - Per game VMU out file """ . PerGameVMUIn . """ does not exist, so """ . PerGameVMUOut . """ is created.")
					}
				}
			}
		}
	} Else
		Log("VMU - No default VMU file at " . defaultMemCard,4)
}

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath)

; TESTING TO HIDE THE CONSOLE WINDOW POPUP, NOTHING WORKS
; WinWait("nullDC ahk_class ndc_main_window")
; WinSet, Transparent, On, nullDC ahk_class ndc_main_window
; WinSet, Transparent, On, ahk_class ConsoleWindowClass	; makes the console window transparent so you don't see it on exit
; Sleep, 2000 ; Enough to hide the startup logo
; WinHide, ahk_class ConsoleWindowClass

WinWait("nullDC ahk_class ndc_main_window")
WinWaitActive("nullDC ahk_class ndc_main_window")

ndcID:=WinExist("A")	; storing the window's PID so we can toggle it later
ToggleMenu(ndcID) ; Removes the MenuBar
; DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar

;Let's completely hide the menu by slighly moving the window off screen
;nullDC will self adjust once the menu autohides
If (fullScreen = "true")
{	yOffset := -20
	winHeight := A_ScreenHeight - yOffset
	WinMove, nullDC,, 0, %yOffset%, %A_ScreenWidth%, %winHeight%
}

; WinShow, nullDC ahk_class ndc_main_window ; without these, nullDC may stay hidden behind HS
; WinActivate, nullDC ahk_class ndc_main_window
HideEmuEnd()
BezelDraw()

If !(showVMU="0")
	SetTimer, CheckforVMU, 10000

FadeInExit()
WinSet, Transparent, Off, nullDC ahk_class ndc_main_window
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
ExtraFixedResBezelExit()

If (PerGameMemoryCards = "true")
{
	Loop, 4
	{
		VMUCount := A_Index - 1
		Log("VMU - Config Plugin controllerVMU" . VMUCount . " - " . controllerVMU%VMUCount%,4)
		If controllerVMU%VMUCount% = NULL
			Continue
		Loop, 2
		{
			SubCount := A_Index - 1
			If (controllerVMU%VMUCount%SubDev%SubCount% = "drkMapleDevices_Win32.dll:2") or (controllerVMU%VMUCount%SubDev%SubCount% = "G15_drkMapleDevices_Win32.dll:2")
			{
				If (VMUCount = 0)
					VMUPort := "0"
				Else If (VMUCount = 1)
					VMUPort := "4"
				Else If (VMUCount = 2)
					VMUPort := "8"
				Else If (VMUCount = 3)
					VMUPort := "C"
				PerGameVMUIn := memCardPath . "\" . VMUGameName . "_port" . VMUPort . A_Index . ".bin"
				PerGameVMUOut := emuPath . "\vmu_data_port" . VMUPort . A_Index . ".bin"
				If FileExist(PerGameVMUOut)
				{
					FileCopy, %PerGameVMUOut%, %PerGameVMUIn%, 1
					Log("VMU - VMUFile " . PerGameVMUOut . " exists. Backing up to " . PerGameVMUIn)
				}
			}
		}
	}
}

FadeOutExit()
ExitModule()


 ; Toggle the MenuBar
!a::
	ToggleMenu(ndcID)
Return

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	ToggleMenu(ndcID) ; Restore the MenuBar
	Loop {
		WinMenuSelectItem,nullDC ahk_class ndc_main_window,,Options,GDRom,Select Default Image
		WinWait("Select Image File ahk_class #32770")
		WinWaitActive("Select Image File ahk_class #32770")
		If WinActive("Select Image File ahk_class #32770")
			Break
	}
	OpenROM("Select Image File ahk_class #32770", mgRomPath . "\" . mgRomName . "." . mgRomExt)	; unsure if Select Image File needs to be translated via i18n
	WinWaitActive("nullDC ahk_class ndc_main_window")
	Sleep, 300 ; giving time for emu to mount the new image
	WinMenuSelectItem,nullDC ahk_class ndc_main_window,,Options,GDRom,Swap Disc	; DC does not support swapping discs on-the-fly like psx because the console reset when the drive was opened. This basically tells the emu to reset.
	ToggleMenu(ndcID) ; Removes the MenuBar
Return

BezelLabel:
	disableHideToggleMenu := true
Return

HaltEmu:
	If VMUHideKey
		XHotKeywrapper(VMUHideKey,"VMUHide","OFF")
Return

RestoreEmu:
	If VMULoaded
	{	Loop, 4
		{	WinSet, Transparent, 0, % "ahk_ID " . VMUScreenID%A_Index%
			WinSet, AlwaysOnTop, On, % "ahk_ID " . VMUScreenID%A_Index%
			WinShow, % "ahk_ID " . VMUScreenID%A_Index%
		}
		WinSet, AlwaysOnTop, On, ahk_ID %extraFixedRes_Bezel_hwnd%
		WinShow, ahk_ID %extraFixedRes_Bezel_hwnd%
		If !(VMUHidden)
			Loop, 4
				WinSet, Transparent, off, % "ahk_ID " . VMUScreenID%A_Index%
	}
	If VMUHideKey
		XHotKeywrapper(VMUHideKey,"VMUHide","ON")
Return

CheckforVMU:
	Loop, 4
	{ 	Transform, letter, Chr, % A_Index + asc("A") - 1  ; transform number to letter
		If ((!(VMU%A_Index%Draw)) and (VMUScreenID%A_Index%:=WinExist("nullDC VMU " . letter . "0 ahk_class #32770")))
		{	WinSet, Transparent, 0, % "ahk_ID " . VMUScreenID%A_Index%
			WinSet, AlwaysOnTop, On, % "ahk_ID " . VMUScreenID%A_Index%
			ExtraFixedResBezelDraw(VMUScreenID%A_Index%, "VMU",VMU%A_Index%Pos, 144, 96, 8, 8, 28, 8)
			WinShow, % "ahk_ID " . VMUScreenID%A_Index%
			WinSet, AlwaysOnTop, On, ahk_ID %extraFixedRes_Bezel_hwnd%
			WinShow, ahk_ID %extraFixedRes_Bezel_hwnd%
			WinSet, Transparent, off, % "ahk_ID " . VMUScreenID%A_Index%
			VMU%A_Index%Draw := true
			If !(VMULoaded){
				VMUHideKey := xHotKeyVarEdit(VMUHideKey,"VMUHideKey","~","Add")
				xHotKeywrapper(VMUHideKey,"VMUHide")
				VMULoaded := true
			}
		}
	}
	If ((VMU1Draw) and (VMU2Draw) and (VMU3Draw) and (VMU4Draw))
		SetTimer, CheckforVMU, off
Return	

VMUHide:
	If (VMUHidden)
	{	Loop, 4
			WinSet, Transparent, off, % "ahk_ID " . VMUScreenID%A_Index%
		UpdateLayeredWindow(extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_hdc,0,0, A_ScreenWidth, A_ScreenHeight,255)
		VMUHidden := false
	} Else {
		Loop, 4
			WinSet, Transparent, 0, % "ahk_ID " . VMUScreenID%A_Index%
		UpdateLayeredWindow(extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_hdc,0,0, A_ScreenWidth, A_ScreenHeight,0)
		VMUHidden := true           
	}
Return

CloseProcess:
	If VMULoaded
		SetTimer, checkforVMU, off
	FadeOutStart()
	; WinClose("ahk_class ConsoleWindowClass")
	WinClose("nullDC ahk_class ndc_main_window")
Return
