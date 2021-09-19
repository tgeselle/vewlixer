MEmu := "Magic Engine"
MEmuV := "v1.1.3"
MURL := ["http://www.magicengine.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.4"
MCRC := "9470303E"
iCRC := "A62EB847"
MID := "635038268901782138"
MSystem := ["NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD"]
;----------------------------------------------------------------------------
; Notes:
; Nomousy makes the cursor transparent, so clicks will still register
; This is used to prevent the mouse cursor from appearing in the middle of your screen when you run Magic Engine
; xPadder/joy2key don't work, the emu reads raw inputs. If you use gamepads, make sure you set your keys in Config->Gamepad
; Set your desired Video settings in RocketLauncherUI module settings.
;
; NEC PC-FX:
; Tested with emulator Magic Engine FX v1.0.1
; This is not the same emu as Magic Engine. It only emulates a PC-FX, but module script is almost the same.
;
; CD systems:
; Make sure your Virtual Drive_Tools_Path in RocketLauncherUI is correct
; Make sure you have the syscard3.pce rom in your emu dir. You can find the file here: http://www.fantasyanime.com/emuhelp/syscards.zip
;
; Bezels:
; Play with the Zoom setting in RocketLauncherUI settings for this module to make the bezel smaller or larger. The larger your resolution, the more zoom you will need.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Windowed := IniReadCheck(settingsFile, "Settings", "Windowed","y",,1)					; y=Simulated Fullscreen mode, n=Normal Fullscreen mode - Simulated Fullscreen mode is preferred, it still looks fullscreen
WideScreenMode := IniReadCheck(settingsFile, "Settings", "WideScreenMode","n",,1)		; y=enable, n=disable
DesktopMode := IniReadCheck(settingsFile, "Settings", "DesktopMode","y",,1)			; y=enable, n=disable - This is basically what sets fullscreen mode. Set to n to show emu in a small window
FullscreenStretch := IniReadCheck(settingsFile, "Settings", "FullscreenStretch","y",,1)		; y=enable, n=disable - This stretches the game screen while keeping the aspect ratio
HighResMode := IniReadCheck(settingsFile, "Settings", "HighResMode","y",,1)		; y=enable, n=disable
Filter := IniReadCheck(settingsFile, "Settings", "Filter","1",,1)							; 1=bilinear filtering , 0=disable
TripleBuffer := IniReadCheck(settingsFile, "Settings", "TripleBuffer","y",,1)					; y=enable, n=disable (DirectX only)
Zoom := IniReadCheck(settingsFile, "Settings", "Zoom","2",,1)							; 4=zoom max , 0=no zoom, use any value between 0 and 4
scanlines := IniReadCheck(settingsFile, "Settings", "scanlines","0",,1)					; 0=none, 40=black, use any value in between 0 and 40
vSync := IniReadCheck(settingsFile, "Settings", "vSync","1",,1)							; 0=disable, 1=enable, 2=vsync + timer (special vsync for windowed mode)
vDriver := IniReadCheck(settingsFile, "Settings", "vDriver","1",,1)							; 0=DirectX, 1=OpenGL
xRes := IniReadCheck(settingsFile, "Settings", "xRes","1280",,1)
yRes := IniReadCheck(settingsFile, "Settings", "yRes","1024",,1)
bitDepth := IniReadCheck(settingsFile, "Settings", "bitDepth","32",,1)
DisplayRes := IniReadCheck(settingsFile, "Settings", "DisplayRes","n",,1)				; Display screen resolution for troubleshooting
UseNoMousy := IniReadCheck(settingsFile, "Settings", "UseNoMousy","true",,1)		; Use NoMousy tool to hide the mouse. If false, will move mouse off the screen instead
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","15",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","24",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","0",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","15",,1)

If (bezelEnabled = "true")
{	; these settings must be specific otherwise bezels do not work
	DesktopMode := "n"
	FullscreenStretch := "n"
}
BezelStart("FixResMode")

If RegExMatch(systemName,"i)pcfx|pc-fx")
	meini := "pcfx.ini"
Else
	meini := "pce.ini"

MEINI := CheckFile(emuPath . "\" . meini,"Could not find " . emuPath . "\" . meini . "`nPlease run Magic Engine manually first so it is created for you.")
If (UseNoMousy = "true")
	noMousyFile := CheckFile(moduleExtensionsPath . "\nomousy.exe","You have UseNoMousy enabled in the module, but could not find " . moduleExtensionsPath . "\nomousy.exe")
If RegExMatch(systemName,"i)CD|pcfx|pc-fx")
{
	CheckFile(emuPath . "\SYSCARD3.PCE","Cannot find " . emuPath . "\SYSCARD3.PCE`nThis file is required for CD systems  when using Magic Engine.")
	If (vdEnabled = "true")
		VirtualDrive("get")	; populates the vdDriveLetter variable with the drive letter to your scsi or dt virtual drive
	Else
		ScriptError("You are running a CD-based system with Magic Engine but do not have Virtual Drive enabled. Please enable Virtual Drive support`, it is required to run CD systems with this module.")
}
If InStr(systemName,"CD")?"":" -cd"

; Compare existing settings and if different than desired, write them to the emulator's ini
IniWrite(Windowed, MEINI, "video", "windowed", 1)
IniWrite(DesktopMode, MEINI, "video", "wide", 1)
IniWrite(FullscreenStretch, MEINI, "video", "fullscreen", 1)
IniWrite(HighResMode, MEINI, "video", "high_res", 1)
IniWrite(Filter, MEINI, "video", "filter", 1)
IniWrite(TripleBuffer, MEINI, "video", "triple_buffer", 1)
IniWrite(Zoom, MEINI, "video", "zoom", 1)
IniWrite(scanlines, MEINI, "video", "scanlines", 1)
IniWrite(vSync, MEINI, "video", "vsync", 1)
IniWrite(vDriver, MEINI, "video", "driver", 1)
IniWrite(xRes, MEINI, "video", "screen_width", 1)
IniWrite(yRes, MEINI, "video", "screen_height", 1)
IniWrite(bitDepth, MEINI, "video", "screen_depth", 1)
IniWrite(vdDriveLetter, MEINI, "cdrom", "drive_letter", 1)
IniWrite(DisplayRes, MEINI, "misc", "screen_resolution", 1)

hideEmuObj := Object("MagicEngine ahk_class MagicEngineWindowClass",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

If RegExMatch(romExtension,"i)\.7z|\.rar")
	ScriptError("Magic Engine does not support loading this extension directly, please enable 7z support first: " . romExtension)

HideEmuStart()

If RegExMatch(systemName,"i)CD|pcfx|pc-fx")	; your system name must have "CD" in it's name
{
	VirtualDrive("mount",romPath . "\" . romName . romExtension)
	Run(executable . " syscard3.pce" . (If InStr(systemName,"CD")?"":" -cd"), emuPath)
}Else
	Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("MagicEngine ahk_class MagicEngineWindowClass")
WinWaitActive("MagicEngine ahk_class MagicEngineWindowClass")

If (UseNoMousy = "true")
	Run(noMousyFile . " /hide")	; hide cursor
Else
	MouseMove %A_ScreenWidth%,%A_ScreenHeight%

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

If RegExMatch(systemName,"i)CD|pcfx|pc-fx")
	VirtualDrive("unmount")
If (UseNoMousy = "true")
	Run(noMousyFile)	; unhide cursor

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("MagicEngine ahk_class MagicEngineWindowClass")
Return

Esc::Return ; this prevents the quick flash of your Front End when exiting with fade on. You can still exit with Esc.
