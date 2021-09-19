MEmu := "Yabause"
MEmuV := "0.9.14"
MURL := ["http://yabause.org/"]
MAuthor := ["djvj","brolly"]
MVersion := "2.0.3"
MCRC := "D9DC6A06"
iCRC := "955B1840"
MID := "635038268937782092"
MSystem := ["Sega Saturn"]
;----------------------------------------------------------------------------
; Notes:
; SSF is still far superior, I suggest using that emu instead
; If yabause.ini does not exist, change a setting in the emu's options and exit, it will be created.
; Only tested working with DTLite, not DTPro. Not tested on any other virtual drive apps.
; Make sure your Virtual_Drive_Path in RocketLauncherUI is correct
; Rom_Extension should include cue and iso
; Make a bios subfolder with your emulator and place your bios files there, then set the bios you want to use in the emu at File->Settings->General->Bios ROM File
; You can also set the bios in RocketLauncherUI Yabause module settings
; Ini files are stored at %LOCALAPPDATA%\yabause (on Win7/8 and XP) or alternatively in %USERPROFILE%\Local Settings\Application Data\yabause (on WinXP only)
;
; Devmiyax SSF:
; If you are using this fork of the emu by Devmiyax, please keep the Devmiyax in the file name or folder name so the module knows it's not the vanilla SSF and will detect it properly.
;
; Handling errors from Yabause:
; "Can't initialize Yabause" - comes from the fact you didn't setup a bios in the emu. But it's not a problem as emu will still work without one.
; Restore menus - Open C:\Users\NAME\AppData\Local\yabause\yabause.ini and change View\Menubar=0 and View\Toolbar=0. You can also change the module setting HideBars to false in RLUI.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
IniFolderSearchType := IniReadCheck(settingsFile, "Settings", "IniFolderSearchType","1",,1)
HideBars := IniReadCheck(settingsFile, "Settings", "HideBars","true",,1)					; If true, will hide both the menubar and toolbar in the emu
customBios := IniReadCheck(settingsFile, "Settings", "CustomBios","",,1)
customBios := GetFullName(customBios)

If IniFolderSearchType = 1
	IniPath := GetCommonPath("LOCAL_APPDATA")
Else {
	EnvGet, IniPath, USERPROFILE
	IniPath := IniPath . "\Local Settings\Application Data"
}

yabauseINI := CheckFile(IniPath . "\yabause\yabause.ini")

If !customBios {
	IniRead, satBios, %yabauseINI%, 0.9.11, General\Bios
	If (satBios = "" || satBios = "ERROR")
		ScriptError("Please make sure to set the BIOS you want to use in " . MEmu . " or set a CustomBios in " . MEmu . " module settings in RocketLauncherUI first.")
} Else
	CheckFile(customBios, "Could not locate the CustomBios you have set for " . MEmu . ": " . customBios)

If (vdEnabled = "true")
{	VirtualDrive("get")	; populates the vdDriveLetter variable with the drive letter to your scsi or dt virtual drive
	usedVD := 1
}

If (bezelEnabled = "true")
	hideBars := "true"	; must hide bars for bezels to look nice

yabauseAHKClass := If InStr(emuFullPath,"Devmiyax") ? "Qt5QWindowIcon" : "QWidget"
hideEmuObj := Object("Yabause ahk_class " . yabauseAHKClass,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)
BezelStart()

gameImage := If usedVD ? " -c " . vdDriveLetter . ":/" : " -i """ . romPath . "\" . romName . romExtension . """"
hideMenubar := If (hideBars = "true" ) ? 2 : 0
hideToolbar := If (hideBars = "true" ) ? 2 : 0
customBios := If customBios ? " -b """ . customBios . """" : ""

IniWrite, true, %yabauseINI%, 0.9.11, autostart
IniWrite, %hideMenubar%, %yabauseINI%, 0.9.11, View\Menubar
IniWrite, %hideToolbar%, %yabauseINI%, 0.9.11, View\Toolbar
IniWrite, %Fullscreen%, %yabauseINI%, 0.9.11, Video\Fullscreen

If usedVD
	VirtualDrive("mount",romPath . "\" . romName . romExtension)

HideEmuStart()
Run(executable . customBios . gameImage,emuPath)

WinWait("Yabause ahk_class " . yabauseAHKClass)
WinWaitActive("Yabause ahk_class " . yabauseAHKClass)

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

If usedVD
	VirtualDrive("unmount")

BezelExit()
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Yabause ahk_class " . yabauseAHKClass)
	;WinKill, Yabause ahk_class QWidget,,3 ; sometimes the emu didn't close, this assures it does
Return
