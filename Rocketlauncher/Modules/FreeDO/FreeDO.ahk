MEmu := "FreeDO"
MEmuV := "v2.1.1 alpha"
MURL := ["http://www.freedo.org/"]
MAuthor := ["djvj"]
MVersion := "2.0.4"
MCRC := "CE1A4839"
iCRC := "7E0E6CF7"
MID := "635038268892864713"
MSystem := ["Panasonic 3DO"]
;----------------------------------------------------------------------------
; Notes:
; The emu does not support CLI or a way of launching fullscreen by default. This is all done manually in the script.
; Supported images are iso, cdi, nrg, bin, img. Cues are not supported. Set your extensions appropriately.
; If your bios file is called fz10_rom.bin, rename it to fz10.rom, it should be placed in the same dir as the emu exe.
; On first launch, FreeDO will ask you to point it to the fz10.rom. After you do that, exit the emu and select a game in your Front End and it should work.
; If the Menu bar at top is present on launch, Hit F9 and exit to save.
; If you do not have an English windows, set the language you use for the MLanguage setting in RocketLauncherUI. Currently only Spanish/Portuguese is supported.
;
; Create a restore.xml or follow the next line.
; In the emu dir, rename config.xml to restore.xml then open it in notepad. Remove the entire section including <cdrom> and </cdrom> (this fixes not being able to play the game twice in a row)
; If you change inputs or make any other changes, make sure to copy the changes from the config.xml into your restore.xml
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ToolbarWait := IniReadCheck(settingsFile, "Settings", "ToolbarWait","300",,1) ; increase this if toolbar is staying visible

freeDOFile := CheckFile(emuPath . "\config.xml","Cannot find " . emuPath . "\config.xml`nPlease run FreeDO manually first so it is created for you.")

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"FreeDO ahk_class TForm1",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar,.zip,.cue
	ScriptError("Pheonix does not support archived or cue files. Only ""iso, cdi, nrg, bin & img"" files can be loaded. Either enable 7z support, or extract your games first.")

; restoring a proper config.xml
FileDelete, %emuPath%\config.xml
FileCopy, %emuPath%\restore.xml, %emuPath%\config.xml

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath)
DetectHiddenWindows, on
; Sleep, 500
WinWait("FreeDO ahk_class TForm1")
IfWinNotActive, FreeDO ahk_class TForm1
	WinActivate, FreeDO ahk_class TForm1
WinWaitActive("FreeDO ahk_class TForm1")
PostMessage, 0x111, 2,,,FreeDO ahk_class TForm1
WinWait(dialogOpen)
IfWinNotActive, %dialogOpen% ahk_class #32770, , WinActivate, %dialogOpen% ahk_class #32770

OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

WinWait("FreeDO ahk_class TForm1")
WinWaitActive("FreeDO ahk_class TForm1")

If Fullscreen = true
	Send, {F11}

Sleep, %ToolbarWait%	; increase this if toolbar is staying visible
Send, {F9}	; disable toolbar

WinWait("FreeDO ahk_class TForm1")
WinWaitActive("FreeDO ahk_class TForm1")

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

 
CloseProcess:
	FadeOutStart()
	WinClose("FreeDO ahk_class TForm1")
Return
 
