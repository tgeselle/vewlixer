MEmu := "Snes9X (-sx2)"
MEmuV := "v1.53 (v0.2)"
MURL := ["http://www.snes9x.com/","http://bsxproj.superfamicom.org/"]
MAuthor := ["djvj","brolly"]
MVersion := "2.0.6"
MCRC := "FF29AA41"
iCRC := "D76D030E"
MID := "635038268923820476"
MSystem := ["Bandai Sufami Turbo","Nintendo Satellaview","Nintendo Super Famicom","Super Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; snes9x adjusts the windowed resolutions in the ini automatically based on the settings you choose in RocketLauncherUI.
; Bezels work, but if you notice a black bar along the bottom, change this option to false in snes9x.conf: ExtendHeight
;
; Bandai Sufami Turbo:
; Make sure you have the stbios.bin file inside the BIOS folder.
; If you are using hacked dumps that also include the bios in the game's rom make sure you enable hackedROM in the module 
; settings. You won't be able to combine roms by using the 2 cart slots though so using proper dumps is advisable.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
If InStr(systemName,"Satellaview") {
	emuPrimaryWindow := new Window(new WindowTitle("Snes9X-sx2","Snes9X: WndClass"))	; when booting Satellaview, the window's title changes slightly
	BSXBiosFile := new File(emuPath . "\BIOS\BS-X.bin")
	BSXBiosFile.CheckFile("Could not locate " . BSXBiosFile.FileName . " that is required to launch Satellaview games. Place it in here: " . BSXBiosFile.FileFullPath)
} Else
	emuPrimaryWindow := new Window(new WindowTitle("Snes9X","Snes9X: WndClass"))
emuMultiCartWindow := new Window(new WindowTitle("Open MultiCart",""))

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
EmulateFullscreen := moduleIni.Read("Settings", "EmulateFullscreen","true",,1)		; This helps fading look better and work better on exit. You cannot use this with a normal fullscreen so one has to be false
WindowMaximized := moduleIni.Read("Settings", "WindowMaximized","true",,1)
Stretch := moduleIni.Read("Settings", "Stretch","true",,1)
MaintainAspectRatio := moduleIni.Read("Settings", "MaintainAspectRatio","true",,1)
HideMenu := moduleIni.Read("Settings", "HideMenu","true",,1)
FullScreenWidth := moduleIni.Read("Settings", "FullScreenWidth","1024",,1)
FullScreenHeight := moduleIni.Read("Settings", "FullScreenHeight","768",,1)
ControlType := moduleIni.Read(romName . "|Settings", "ControlType",0,,1)
StereoSound := moduleIni.Read(romName . "|Settings", "StereoSound","true",,1)
HackedROM := moduleIni.Read(romName . "|Settings", "HackedROM","false",,1)
CartBrom := moduleIni.Read(romName, "CartBrom","",,1)

If (HideMenu = "false")
	disableHideToggleMenu := "true"	; disables Bezel's builtin menu hiding

; cType := Object(0,"Use SNES Joypad(s)",1,"Use SNES Mouse",2,"Use Super Scope",3,"Use Super Multitap (5-Player)",4,"Use Konami Justifier",5,"Use Mouse in alternate port",6,"Use Multitaps (8-Player)",7,"Use Dual Justifiers")
cType := Object(0,40137,1,40105,2,40106,3,40104,4,40109,5,40133,6,40135,7,40134)
snes9xControl := cType[ControlType]	; search object for the ControlType snes9x uses in its input menu
If !snes9xControl
	ScriptError("Your ControlType is set to: " . ControlType . "`nIt is not one of the supported control types. Please set a proper control type in RocketLauncherUI for this system or game.")

; Multicart Setup for Sufami Turbo
MultiCartA := ""
MultiCartB := ""
UseCliBoot := "true"

If StringUtils.Contains(systemName,"Sufami") {
	stBiosFile := new File(emuPath . "\BIOS\stbios.bin")
	stBiosFile.CheckFile()

	If (HackedROM = "false") {
		UseCliBoot := "false"
		MultiCartA := romPath . "\" . romName . romExtension
		If (CartBrom) {
			CartBromFile := new File(romPath . "\" . CartBrom)
			CartBromFile.CheckFile()
			MultiCartB := romPath . "\" . CartBrom
		}
		Else {
			MultiCartB := stBiosFile.FileFullPath
		}
	}
}

BezelStart()

; Compare existing settings and if different than desired, write them to the emulator's ini
snes9xConf := new IniFile(emuPath . "\snes9x.conf")
snes9xConf.CheckFile()
snes9xConf.Write(Fullscreen, "Display\Win", "Fullscreen:Enabled", 1)
snes9xConf.Write(EmulateFullscreen, "Display\Win", "Fullscreen:EmulateFullscreen", 1)
snes9xConf.Write(WindowMaximized, "Display\Win", "Window:Maximized", 1)
snes9xConf.Write(Stretch, "Display\Win", "Stretch:Enabled", 1)
snes9xConf.Write(MaintainAspectRatio, "Display\Win", "Stretch:MaintainAspectRatio", 1)
snes9xConf.Write(FullScreenWidth, "Display\Win", "Fullscreen:Width", 1)
snes9xConf.Write(FullScreenHeight, "Display\Win", "Fullscreen:Height", 1)
snes9xConf.Write(HideMenu, "HideMenu", "HideMenu", 1)
snes9xConf.Write(If StereoSound = "true" ? "ON" : "OFF", "Sound", "Stereo", 1)
snes9xConf.Write(MultiCartA, "Settings\Win\Files", "Rom:MultiCartA", 1)
snes9xConf.Write(MultiCartB, "Settings\Win\Files", "Rom:MultiCartB", 1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
If (UseCliBoot = "true")
	PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")
Else
	PrimaryExe.Run()

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

;Open MultiCart dialog and press OK, this workaround is needed otherwise Sufami games won't work. (Only applies to proper dumps not hacked ones)
If (UseCliBoot = "false") {
	emuPrimaryWindow.PostMessage(0x111,40153)
	emuMultiCartWindow.Wait()
	; emuMultiCartWindow.WaitActive()
	emuMultiCartWindow.PostMessage(0x111,1)
}

; Change the control type to what's required for this game
; WinMenuSelectItem, %emuWinClass%,, Input, %snes9xControl%
; msgbox 40%snes9xControl%`n%emuWinClass%
emuPrimaryWindow.PostMessage(0x111,snes9xControl)

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
BezelExit()
7zCleanUp()
FadeOutExit()
ExitModule()


RestoreEmu:
	If (bezelEnabled = "true") ; checking if emulator window is on bezel defined coordinates and if not try to move the window (timeout = 3 seconds).
		If (bezelPath) { 
			X:="" , Y:="" , W:="" , H:=""
			timeout := A_TickCount
			Loop {
				WinGetPos, X, Y, W, H, ahk_id %emulatorID%
				If (X = bezelScreenX) and (Y = bezelScreenY) and (W = bezelScreenWidth) and (H = bezelScreenHeight)
					Break
				If (timeout < A_TickCount - 3000)
					Break
				TimerUtils.Sleep(50)
				WinMove, ahk_id %emulatorID%,, %bezelScreenX%, %bezelScreenY%, %bezelScreenWidth%, %bezelScreenHeight%
				TimerUtils.Sleep(50)
			}
		}
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
