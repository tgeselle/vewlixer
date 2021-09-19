MEmu := "Project64"
MEmuV := "v2.2.x"
MURL := ["http://www.pj64-emu.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.6"
MCRC := "BAF353D9"
iCRC := "28E52E46"
MID := "635038268918025653"
MSystem := ["Nintendo 64","Nintendo 64DD"]
;----------------------------------------------------------------------------
; Notes:
; Run the emu manually and hit Ctrl+T to enter Settings. On Options, check "On loading a ROM go to full screen"
; If roms don't start automatically, enabled advanced settings, and go to the Advanced and check "Start Emulation when rom is opened?"
; I like to turn off the Rom Browser by going to Settings->Rom Selection and uncheck "Use Rom Browser" (advanced settings needs to be on to see this tab)
; If you use Esc as your exit key, it could crash the emu because it also takes the emu out of fullscreen
; You can remove Esc as a key to change fullscreen mode in the Settings->Keyboard Shortcuts, change CPU State to Game Playing (fullscreen) then Options->Full Screen and remove Esc from Current Keys
; Suggested to use Glide64 Final plugin as your graphics plugin (it does not crash on exit): https://code.google.com/p/glidehqplusglitch64/downloads/detail?name=Glide64_Final.zip&can=2&q=

; 64DD support requires Project 64 2.2.0.3 or above. Only 64DD disk to cart conversions work. 
; Original 64DD disk images are not currently supported. 

; Project64 Plugins store their settings in the Project64.cfg as of 2.2.0.1

; Known Plugin issues:
; Video - Rice: crashes with annoying msgbox on exiting from fullscreen
;
; Nintendo 64DD support:
; To play N64DD games it's recommended that you use Project64U instead, this version of the emulator can be used with this module. Download it here:
; https://project64u.wordpress.com/
;
; Disk dumps aren't supported by the emulator so make sure you use the cart conversions.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; Get emulator version from executable, this is needed since ahk_class uses it
exeAtrib := FileGetVersionInfo_AW(EmuPath . "\" . executable, "FileVersion|ProductVersion", "|")
Loop, Parse, exeAtrib, |%A_Tab%, %A_Space%
 A_Index & 1 ? ( _ := A_LoopField ) : ( %_% := A_LoopField )
If (ProductVersion)
	StringRight, FileEmuVersion, ProductVersion, StrLen(ProductVersion)
Log("Module - Detected Project64 Product Version from '" . EmuPath . "\" . executable . "' is " . FileEmuVersion)
If (!FileEmuVersion)
	FileEmuVersion := "2.2.0.3"

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				; Controls if emu launches fullscreen or windowed
EmuVersion := IniReadCheck(settingsFile, "Settings", "EmuVersion",FileEmuVersion,,1)
bezelDelay := IniReadCheck(settingsFile, "Settings", "BezelDelay","",,1)					; amount in milliseconds to give Project64 time to draw its window before bezel takes over

hideEmuObj := Object("ahk_class Project64 " . EmuVersion,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart("FixResMode")

emuCfg := CheckFile(emuPath . "\Config\Project64.cfg")	; check for emu's settings file
currentFullScreen := IniReadCheck(emuCfg,"default","Auto Full Screen")
If (Fullscreen != "true" And currentFullScreen != "0")
	IniWrite(0,emuCfg,"default","Auto Full Screen")
Else If (Fullscreen = "true" And currentFullScreen != "1")
	IniWrite(1,emuCfg,"default","Auto Full Screen")

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class Project64 " . EmuVersion)
WinWaitActive("ahk_class Project64 " . EmuVersion)

If (bezelEnabled = "true")
	Control, Hide,, msctls_statusbar321, ahk_class Project64 %EmuVersion% ; Removes the StatusBar

Sleep % bezelDelay

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	PostMessage, 0x111, 4152,,, ahk_class Project64 %EmuVersion%	; Pause/Resume emulation
	If (fullscreen  = "true") {
		PostMessage, 0x111, 4172,,, ahk_class Project64 %EmuVersion%	; fullscreen part1
		PostMessage, 0x111, 4173,,, ahk_class Project64 %EmuVersion%	; fullscreen part2
	}
Return
RestoreEmu:
	Winrestore, ahk_class Project64 %EmuVersion%
	If (fullscreen  = "true") {
		Sleep, 1000	; couple required sleeps otherwise the emu doesn't always return to Fullscreen state
		PostMessage, 0x111, 4172,,, ahk_class Project64 %EmuVersion%	; fullscreen part1
		Sleep, 500
		PostMessage, 0x111, 4173,,, ahk_class Project64 %EmuVersion%	; fullscreen part2
	}
	PostMessage, 0x111, 4152,,, ahk_class Project64 %EmuVersion%	; Pause/Resume emulation
Return

CloseProcess:
	FadeOutStart()
	PostMessage, 0x111, 4003,,, ahk_class Project64 %EmuVersion%	; End emulation
	Sleep, 500
	; WinClose("ahk_class Project64 2.0")	; Often leaves the process running
	PostMessage, 0x111, 4006,,, ahk_class Project64 %EmuVersion%	; Exit Emu
Return
