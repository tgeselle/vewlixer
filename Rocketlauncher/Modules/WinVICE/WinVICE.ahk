MEmu := "WinVICE"
MEmuV := "v2.4"
MURL := ["http://vice-emu.sourceforge.net/"]
MAuthor := ["djvj","wahoobrian","brolly"]
MVersion := "2.1.5"
MCRC := "9A8F13BF"
iCRC := "15E345B2"
MID := "635038268966170754"
MSystem := ["Commodore 64","Commodore 16 & Plus4","Commodore VIC-20","Commodore 128","Commodore MAX Machine","Commodore 64 Games System", "Commodore PET"]
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped.
; You can turn off the exit confirmation box by unchecking Settings->Confirm on exit
; Turn on saving settings by checking Settings->Save settings on exit, this will create the vice.ini file this module needs.
;
; Default Joyport setting for C64 requires that you configure "Keyset A" as the default for JoyPort 1 and "Keyset B" as the 
; default for JoyPort 2.  This allows the module to use the ini settings and set the default joystick to Player 1 at startup
; This can be disabled by setting the disableAutoControllerSwapping to true.  That is helpful for users who do not wish to use 
; "KeySet A" and "KeySet B" as the controller configurations.
;
; If you want to use the StartTape and StopTape hotkeys make sure you edit the files C64\win_shortcuts.vsc or VIC20\win_shortcuts.vsc 
; (paths relative to the emulator install folder) and assign Alt+F7 as the StartTape shortcut and Alt+F8 as the StopTape shortcut, like this:
; ALT				0x76		IDM_DATASETTE_CONTROL_START		  F7
; ALT				0x77		IDM_DATASETTE_CONTROL_STOP		  F8
;
; WinVICE SDL:
; This module will also work with the SDL version of WinVICE even though it's not recommended to use it with it. If you do bare in mind that 
; some of the features might not work. For hotkeys to work you need to manually set them all in SDL VICE and make sure you save the settings. 
; To map the hotkeys navigate to any menu item (F12 shows the menu) press 'm' and then the key or key combo you want to use for the hotkey for that item.
; Don't forget to save your hotkeys before exiting the emulator before you exi or they will be lost. This is done in Settings management->Save hotkeys.
; You can find more info on the Readme-SDL.txt file that comes with this version of the emulator.
; The module will detect that you are using the SDL version by checking if the sdl-vice.ini file exists in your emulator folder, so make sure you 
; run the emulator once in order to create this file.
;
; WinVICE uses different executables for each machine so make sure you setup your emulators properly:
; x64.exe - Commodore 64
; xplus4.exe - Commodore 16 & Plus/4
; xvic.exe - Commodore VIC-20
; x128.exe - Commodore 128
; xpet.exe - Commodore PET
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object

mType := Object("Commodore 64","C64","Commodore 16 & Plus4","PLUS4","Commodore VIC-20","VIC20","Commodore 128","C128","Commodore MAX Machine","C64","Commodore 64 Games System","C64", "Commodore PET", "PET") ;ident should be the section names used in VICE.ini
ident := mType[systemName]	; search object for the systemName identifier

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)				; If true, the module governs If the emulator launches fullscreen or not. Set to false when troubleshooting a module for launching problems.
WarpKey := moduleIni.Read("Settings", "WarpKey","F9",,1)						; toggle warp speed
JoySwapKey := moduleIni.Read("Settings", "JoySwapKey","F10",,1)					; swap joystick port
StartTapeKey := moduleIni.Read("Settings", "StartTapeKey","F7",,1)					; starts tape
StopTapeKey := moduleIni.Read("Settings", "StopTapeKey","F8",,1)					; stops tape

bezelTopOffset := moduleIni.Read("Settings", "bezelTopOffset",16,,1)
bezelBottomOffset := moduleIni.Read("Settings", "bezelBottomOffset",46,,1)
bezelLeftOffset := moduleIni.Read("Settings", "bezelLeftOffset",7,,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset",7,,1)
disableAutoControllerSwapping := moduleIni.Read("Settings", "DisableAutoControllerSwapping","false",,1)

UsePaddles := moduleIni.Read(romName, "UsePaddles", "false",,1)
AutostartPrgMode := moduleIni.Read(romName, "AutostartPrgMode", "2",,1)
RequiresReset := moduleIni.Read(romName, "RequiresReset", "false",,1)
RequiresHardReset := moduleIni.Read(romName, "RequiresHardReset", "false",,1)
TrueDriveEmulation := moduleIni.Read(romName . "|Settings", "TrueDriveEmulation", "false",,1)
LoadFile := moduleIni.Read(romName, "LoadFile",,,1)
DefaultJoyPort := moduleIni.Read(romName, "DefaultJoyPort", "1",,1)
ColumnMode := moduleIni.Read(romName, "ColumnMode", "80",,1)

; DiskSwapKey := "F11"		; swaps disk or tape - Do not need this key anymore with multigame support

7z(romPath, romName, romExtension, SevenZExtractPath)

;Detect if SDL VICE is being used
SdlViceINI := new IniFile(emuPath . "\sdl-vice.ini")
If SdlViceINI.Exist()
	SdlVice := "true"
Else
	SdlVice := "false"

RLLog.Info("Module - SDL mode is set to " . SdlVice)

If (SdlVice = "true") {
	emuPrimaryWindow := new Window(new WindowTitle("VICE","SDL_app"))	; instantiate primary emulator window object
	viceINI := SdlViceINI
} Else {
	emuPrimaryWindow := new Window(new WindowTitle(,"VICE"))	; instantiate primary emulator window object
	viceINI := new IniFile(emuPath . "\vice.ini")
}
viceINI.CheckFile()

emuOpenROMWindow := new Window(new WindowTitle("Select cartridge file","#32770"))
hideEmuObj := Object(emuOpenROMWindow,0,emuPrimaryWindow,1)

viceINIFullscreenKey := "FullscreenEnabled"
If (SdlVice = "true")
{
	If (ident = "C64")
		viceINIFullscreenKey := "VICIIFullscreen"
	If (ident = "PLUS4")
		viceINIFullscreenKey := "TEDFullscreen"
	If (ident = "VIC20")
		viceINIFullscreenKey := "VICFullscreen"
	If (ident = "C128")
		viceINIFullscreenKey := "VICIIFullscreen"
}

currentFullScreen := viceINI.Read(ident, viceINIFullscreenKey)
currentAutostartPrgMode := viceINI.Read(ident, AutostartPrgMode)
currentDriveTrueEmulation := viceINI.Read(ident, DriveTrueEmulation)
currentJoyDevice1 := viceINI.Read(ident, JoyDevice1)
currentJoyDevice2 := viceINI.Read(ident, JoyDevice2)

BezelStart()

; Setting Fullscreen setting in ini If it doesn't match what user wants above
If (ident = "C128") ;Always start in windowed mode otherwise we won't be able to set the proper window
	viceINI.Write(0, ident, viceINIFullscreenKey)
Else {
	If (Fullscreen != "true" And currentFullScreen != 0)
		viceINI.Write(0, ident, viceINIFullscreenKey)
	Else If (Fullscreen = "true" And currentFullScreen != 1)
		viceINI.Write(1, ident, viceINIFullscreenKey)
}

If (currentAutostartPrgMode != AutostartPrgMode)
	viceINI.Write(AutostartPrgMode, ident, "AutostartPrgMode")

WarpKey := xHotKeyVarEdit(WarpKey,"WarpKey","~","Add")
JoySwapKey := xHotKeyVarEdit(JoySwapKey,"JoySwapKey","~","Add")
StartTapeKey := xHotKeyVarEdit(StartTapeKey,"StartTapeKey","~","Add")
StopTapeKey := xHotKeyVarEdit(StopTapeKey,"StopTapeKey","~","Add")
xHotKeywrapper(WarpKey,"Warp")
xHotKeywrapper(JoySwapKey,"JoySwap")
xHotKeywrapper(StartTapeKey,"StartTape")
xHotKeywrapper(StopTapeKey,"StopTape")

If StringUtils.Contains(romName,"\(USA\)|\(Canada\)")
	DefaultVideoMode := "NTSC"
Else
	DefaultVideoMode := "PAL"

VideoMode := moduleIni.Read(romName, "VideoMode", DefaultVideoMode,,1)

params := (If SdlVice = "true" ? " " : " +confirmexit")

; Setting video mode depending on rom, default NTSC
If (VideoMode = "NTSC") {
	params .= " -ntsc"
	;viceINI.Write(-2, ident, "MachineVideoStandard")  ;NTSC
} Else {
	params .= " -pal"
	;viceINI.Write(-1, ident, "MachineVideoStandard")  ;PAL
}

;Enable/Disable paddles as needed, leave these checks in-place because mouse CLI and Ini options aren't supported in VICE 1.22 and this way it will also work with it.
currentUsePaddles := viceINI.Read(ident, "Mouse")
If (UsePaddles = "true" And currentUsePaddles != 1)
	params .= " -mouse -mousetype 3"
If (UsePaddles = "false" And currentUsePaddles = 1)
	params .= " +mouse"

If (ident = "C64") {
	If !StringUtils.Contains(romExtension,"\.d64|\.d71|\.d80|\.d81|\.d82|\.g64|\.g41|\.x64|\.t64|\.tap|\.crt|\.prg|\.vsf")
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nd64,d71,d80,d81,d82,g64,g41,x64,t64,tap,crt")

	If (romExtension = ".crt") {
		viceINI.Write(romPath . "\" . romName . romExtension, "C64", "CartridgeFile")
		viceINI.Write(0, "C64", "CartridgeType")
	} Else {
		viceINI.Write("", "C64", "CartridgeFile")
		viceINI.Write(-1, "C64", "CartridgeType")
	}
	; Setting TrueDriveEmulation setting in ini If it doesn't match what user wants above
	If (TrueDriveEmulation != "true" And currentDriveTrueEmulation != 0) {
		viceINI.Write(0, ident, "DriveTrueEmulation")
		viceINI.Write(0, ident, "Drive8Type")
	}
	Else If (TrueDriveEmulation = "true" And currentDriveTrueEmulation != 1) {
		viceINI.Write(1, ident, "DriveTrueEmulation")
		viceINI.Write(1541, ident, "Drive8Type")
	}

	If (disableAutoControllerSwapping = "false") {
		; Setting Default JoyPort to Player 1 If needed
		If (DefaultJoyPort = "1" And currentJoyDevice1 != 2) {
			viceINI.Write(2, ident, "JoyDevice1")
			viceINI.Write(3, ident, "JoyDevice2")
		}
		Else If (DefaultJoyPort = "2" And currentJoyDevice1 != 3) {
			viceINI.Write(3, ident, "JoyDevice1")
			viceINI.Write(2, ident, "JoyDevice2")
		}
	}

	SendCommandDelay := moduleIni.Read("Settings", "SendCommandDelay", "1500",,1)
	Command := moduleIni.Read(romName, "Command",,,1)
	Command := StringUtils.Lower(Command)	; Command MUST be in lower case so let's force it

	HideAppStart(hideEmuObj,hideEmu)
	
	If StringUtils.Contains(romExtension,"\.d64|\.d71|\.d80|\.d81|\.d82|\.g64|\.g41|\.x64|\.prg|\.vsf")
		primaryExe.Run(params . " -autostart """ . romPath . "\" . romName . romExtension . ":" . LoadFile . """")
	Else If StringUtils.Contains(romExtension,"\.t64|\.tap")
		primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")
	Else If (romExtension = ".crt")
		primaryExe.Run(params . " -cartcrt """ . romPath . "\" . romName . romExtension . """")

	If (RequiresReset = "true")
	{
		emuPrimaryWindow.WaitActive()
		TimerUtils.Sleep(1000) ; increase if command is not appearing in the emu window or some just some letters
		KeyUtils.Send("!r")
	}

	If Command {
		TimerUtils.Sleep(1000)
		emuPrimaryWindow.WaitActive()
		KeyUtils.SetKeyDelay(50)
		SendCommand(Command . "{Enter}", SendCommandDelay)
	}
}
Else If (ident = "PLUS4") {
	If !StringUtils.Contains(romExtension,"\.prg|\.d64|\.t64|\.tap|\.crt|\.g64")
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,t64,tap,crt,g64")

	SendCommandDelay := moduleIni.Read("Settings", "SendCommandDelay", "1500",,1)
	Model := moduleIni.Read(romName, "Model", "Commodore Plus/4",,1)

	; Setting model
	If (Model = "Commodore Plus/4") { ;Commodore Plus/4
		viceINI.Write("3plus1lo", ident, "FunctionLowName")
		viceINI.Write("3plus1hi", ident, "FunctionHighName")
		viceINI.Write(64, ident, "RamSize")
		viceINI.Write(1, ident, "Acia1Enable")
	} Else {	; Commodore 16
		viceINI.Write("", ident, "FunctionLowName")
		viceINI.Write("", ident, "FunctionHighName")
		viceINI.Write(16, ident, "RamSize")
		viceINI.Write(0, ident, "Acia1Enable")
	}

	; TrueDriveEmulation must be set to false
	If (currentDriveTrueEmulation != 0) {
		viceINI.Write(0, ident, "DriveTrueEmulation")
	}

	Command := moduleIni.Read(romName, "Command",,,1)
	Command := StringUtils.Lower(Command)	; Command MUST be in lower case so let's force it

	HideAppStart(hideEmuObj,hideEmu)
	
	If StringUtils.Contains(romExtension,"\.d64|\.g64|\.prg")
		primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")
	Else If romExtension in .t64,.tap
		primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")
	Else If (romExtension = .crt)
	{
		If (SdlVice = "true")
		{
			primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")
		}
		Else
		{
			;CLI does not seem to work for carts for Plus4, use GUI instead
			; primaryExe.Run(params . " -cartcrt """ . romPath . "\" . romName . romExtension . """")
			primaryExe.Run()
			emuPrimaryWindow.Wait()
			emuPrimaryWindow.WaitActive()

			;Following keystrokes open up dialog for smart-attach cartridge image
			TimerUtils.Sleep(500)
			emuPrimaryWindow.MenuSelectItem("File", "Attach cartridge image", "1&")

			OpenROM(emuOpenROMWindow.WinTitle.GetWindowTitle(),romPath . "\" . romName . romExtension)
		}
	}

	If (RequiresReset = "true")
	{
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		TimerUtils.Sleep(1000) ; increase If command is not appearing in the emu window or some just some letters
		KeyUtils.Send("!r")
	}

	If (RequiresHardReset = "true")
	{
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		TimerUtils.Sleep(1000) ; increase If command is not appearing in the emu window or some just some letters
		KeyUtils.Send("^!r")
	}

	If Command
	{
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		;TimerUtils.Sleep(SendCommandDelay) ; increase If command is not appearing in the emu window or some just some letters

		If StringUtils.Contains(romExtension,"\.t64|\.tap")
		{
			;Tape loading time will vary greatly so we can't type this automatically, user must do it using a hotkey
			RunTapeKey := moduleIni.Read(romname, "RunTapeKey","Ctrl&F12",,1)						; run tape key
			RunTapeKey := xHotKeyVarEdit(RunTapeKey,"RunTapeKey","~","Add")
			xHotKeywrapper(RunTapeKey,"RunTape")
		} Else
			SendCommand(Command . "{Enter}", SendCommandDelay)
	}
}
Else If (ident = "VIC20") {
	If !StringUtils.Contains(romExtension, "\.prg|\.d64|\.t64|\.tap|\.crt|\.vsf")
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported: prg,d64,t64,tap,crt")

	SendCommandDelay := moduleIni.Read("Settings", "SendCommandDelay", "1500",,1)

	CartAddress := moduleIni.Read(romName, "CartLoadingAddress", "X000",,1)
	MemoryExpansion := moduleIni.Read(romName, "MemoryExpansion", "none",,1)
	Command := moduleIni.Read(romName, "Command",,,1)
	RequiresReset := moduleIni.Read(romName, "RequiresReset", "false",,1)

	Command := StringUtils.Lower(Command)	; Command MUST be in lower case so let's force it

	If (romExtension = ".crt") {
		;TimerUtils.Sleep(100) ;Without this romtable comes empty (thread related?)
		RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly

		;MultiPart carts can only be run If the MultiGame feature is enabled
		If StringUtils.Contains(romName, "\(Part ")
		{
			If (mgEnabled = "false")
				ScriptError("You cannot run multipart games with MultiGame disabled")
		}

		romCount := romtable.MaxIndex()

		If (romCount > 1) {
			;multipart carts - need to build custom CLI parameters to invoke multipart cartridges.  Multipart cartridges are loaded in more than one 
			;                  memory address, so we interrogate each part, and determine its loading address, and build the CLI parameters.
			;				   Once all the cartridge parts have been processed, the emulator with the custom CLI parameters are invoked.
			;				
			;                  Using Lunaar Leeper as an example, it has two parts, one loaded in $2000, and one in $A000
			;	               "xvic.exe -cart2 "D:\Games\Commodore VIC-20\Lunar Leeper (USA) (Part 1).crt" -cartA "D:\Games\Commodore VIC-20\Lunar Leeper (USA) (Part 2).crt"			

			multipartCLI := params

			for index, element in romtable {
				currentCart := romtable[A_Index,1]
				StringUtils.SplitPath(currentCart,,,,OutFileName)
				currentCartAddress := moduleIni.Read(OutFileName, "CartLoadingAddress", "X000",,1)
				
				If (currentCartAddress = "A000")
					cartSlot := " -cartA"
				Else If (currentCartAddress = "B000")
					cartSlot := " -cartB"
				Else If (currentCartAddress = "2000")
					cartSlot := " -cart2"
				Else If (currentCartAddress = "4000")
					cartSlot := " -cart4"
				Else If (currentCartAddress = "6000")
					cartSlot := " -cart6"
				Else
					ScriptError("Invalid Cart Address Specified: " . CartAddress)

				multipartCLI := multipartCLI . " " . cartSlot . " """ . currentCart . """"
			}
			primaryExe.Run(multipartCLI)
		}
		Else {
			;singlepart carts - unlike multipart carts, we can directly run the emulator with a single CLI parameter

			If (CartAddress = "A000")
				cartSlot := " -cartA"
			Else If (CartAddress = "B000")
				cartSlot := " -cartB"
			Else If (CartAddress = "2000")
				cartSlot := " -cart2"
			Else If (CartAddress = "4000")
				cartSlot := " -cart4"
			Else If (CartAddress = "6000")
				cartSlot := " -cart6"
			Else
				ScriptError("Invalid Cart Address Specified: " . CartAddress)

			HideAppStart(hideEmuObj,hideEmu)
			primaryExe.Run(params . cartSlot . " """ . romPath . "\" . romName . romExtension . """")
		}
	} Else {
		;for non cartridges, update the vice.ini with the proper memory expansion values (If needed) prior to calling the emulator.
		varBlock0 := 0
		varBlock1 := 0
		varBlock2 := 0
		varBlock3 := 0
		varBlock5 := 0
		
		If (MemoryExpansion = "3k") { 
			varBlock0 := 1
		} Else If (MemoryExpansion = "8k") { 
			varBlock1 := 1
		} Else If (MemoryExpansion = "16k") { 
			varBlock1 := 1
			varBlock2 := 1
		} Else If (MemoryExpansion = "24k") { 
			varBlock1 := 1
			varBlock2 := 1
			varBlock3 := 1
		} Else If (MemoryExpansion = "all") { 
			varBlock0 := 1
			varBlock1 := 1
			varBlock2 := 1
			varBlock3 := 1
			varBlock5 := 1
		} Else If (MemoryExpansion = "3,5") { 
			varBlock3 := 1
			varBlock5 := 1
		} Else If (MemoryExpansion = "5") { 
			varBlock5 := 1
		} Else If (MemoryExpansion = "1,5") { 
			varBlock1 := 1
			varBlock5 := 1
		} Else If (MemoryExpansion = "1,2,5") { 
			varBlock1 := 1
			varBlock2 := 1
			varBlock5 := 1
		}
		viceINI.Write(varBlock0, "VIC20", "RAMBlock0")
		viceINI.Write(varBlock1, "VIC20", "RAMBlock1")
		viceINI.Write(varBlock2, "VIC20", "RAMBlock2")
		viceINI.Write(varBlock3, "VIC20", "RAMBlock3")
		viceINI.Write(varBlock5, "VIC20", "RAMBlock5")

		HideAppStart(hideEmuObj,hideEmu)
		primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")
	}

	If (RequiresReset = "true")
	{
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		TimerUtils.Sleep(1000) ; increase If command is not appearing in the emu window or some just some letters
		KeyUtils.Send("!r")
	}

	If Command
	{
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		KeyUtils.SetKeyDelay(50)
		SendCommand(Command . "{Enter}", SendCommandDelay)
	}
}
Else If (ident = "C128") {
	If !StringUtils.Contains(romExtension,"\.prg|\.d64|\.d81")
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,d81")

	SendCommandDelay := moduleIni.Read("Settings", "SendCommandDelay", "1500",,1)

	; Setting TrueDriveEmulation setting in ini If it doesn't match what user wants above
	If (TrueDriveEmulation != "true" And currentDriveTrueEmulation != 0) {
		viceINI.Write(0, ident, "DriveTrueEmulation")
		viceINI.Write(0, ident, "Drive8Type")
	}
	Else If (TrueDriveEmulation = "true" And currentDriveTrueEmulation != 1) {
		viceINI.Write(1, ident, "DriveTrueEmulation")
		viceINI.Write(1570, ident, "Drive8Type")
	}

	Command := moduleIni.Read(romName, "Command",,,1)
	Commodore64Mode := moduleIni.Read(romName, "Commodore64Mode", "false",,1)
	Command := StringUtils.Lower(Command)	; Command MUST be in lower case so let's force it

	;set 80/40 col param
	If (ColumnMode = 40) {
		params .= " -40col"
	}
	Else {
		params .= " -80col"
	}

	; Force either C64 mode (-go64) or C128 mode (+go64)
	If (Commodore64Mode = "true") {
		params .= " -go64"
	}
	Else {
		params .= " +go64"
	}

	params .= " +reu +autostart-warp"

	HideAppStart(hideEmuObj,hideEmu)
	primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")
	emuPrimaryWindow.Wait()
	TimerUtils.Sleep(1000)	; wait just a little more for 2 instances of the emu to open
	
	emuPrimaryWindow.Get("List")	; Retrieves the unique ID numbers of all existing windows
	MaxWidth := 0
	MinWidth := 10000
	Loop % emuPrimaryWindow.List[0] {
		emuWindow%A_Index% := new Window(new WindowTitle(,,,emuPrimaryWindow.List[A_Index]))	; instantiate each emulator window object with the ahk_id
		emuWindow%A_Index%.Activate()
		emuWindow%A_Index%.GetClass()	; store the class of this window in the object
		emuWindow%A_Index%.GetTitle()	; store the title of this window in the object
		emuWindow%A_Index%.GetPos(emuX, emuY, emuWidth, emuHeight)
		If (emuWidth > MaxWidth) {
			emu80ColWindow := emuWindow%A_Index%
			MaxWidth := emuWidth
		}
		If (emuWidth < MinWidth) {
			emu40ColWindow := emuWindow%A_Index%
			MinWidth := emuWidth
		}
	}

	If (ColumnMode = 40) {
		emu80ColWindow.Hide()
		visibleWindow := emu40ColWindow
	} Else {
		emu40ColWindow.Hide()
		visibleWindow := emu80ColWindow
	}

	;Activate the desired window since you might have hidden the active one above
	visibleWindow.Activate()
	visibleWindow.WaitActive()
	WinSet, Redraw, , A ;Without this line bezel will always draw below the emulator window!

	If (Fullscreen = "true") ;We always force windowed mode on the ini for the 40/80col mode detection to work
		KeyUtils.Send("!{Enter}")

	If Command {
		visibleWindow.Wait()
		visibleWindow.WaitActive()
		KeyUtils.SetKeyDelay(50)
		SendCommand(Command . "{Enter}", SendCommandDelay)
	}
}
Else If (ident = "PET") {
	If !StringUtils.Contains(romExtension,"\.prg|\.d64|\.d81|\.tap")
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,d81,tap")

	SendCommandDelay := moduleIni.Read("Settings", "SendCommandDelay", "1500",,1)

	Command := moduleIni.Read(romName, "Command",,,1)
	PETModel := moduleIni.Read(romName, "PETModel", "PET4032",,1)
	Command := StringUtils.Lower(Command)	; Command MUST be in lower case so let's force it

	If (PETModel = "PET3032")
	{
		viceINI.Write("kernal2", ident, "KernalName")
		viceINI.Write("edit2g", ident, "EditorName")
		viceINI.Write("basic2", ident, "BasicName")
		viceINI.Write(0, ident, "Crtc")
		viceINI.Write(40, ident, "VideoSize")
		viceINI.Write(2, ident, "KeymapIndex")
	}
	Else If (PETModel = "PET8032")
	{
		viceINI.Write("kernal4", ident, "KernalName")
		viceINI.Write("edit4b80", ident, "EditorName")
		viceINI.Write("basic4", ident, "BasicName")
		viceINI.Write(1, ident, "Crtc")
		viceINI.Write(80, ident, "VideoSize")
		viceINI.Write(0, ident, "KeymapIndex")
	}
	Else
	{
		;Assume Model 4032
		viceINI.Write("kernal4", ident, "KernalName")
		viceINI.Write("edit4g40", ident, "EditorName")
		viceINI.Write("basic4", ident, "BasicName")
		viceINI.Write(1, ident, "Crtc")
		viceINI.Write(40, ident, "VideoSize")
		viceINI.Write(2, ident, "KeymapIndex")
	}	
		
	HideAppStart(hideEmuObj,hideEmu)
	primaryExe.Run(params . " """ . romPath . "\" . romName . romExtension . """")

	If Command {
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		KeyUtils.SetKeyDelay(50)
		SendCommand(Command, SendCommandDelay)
	}
}

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


JoySwap:
	KeyUtils.Send("!j")
Return

Warp:
	KeyUtils.Send("!w")
Return

StartTape:
	KeyUtils.Send("!{F7}")
Return

StopTape:
	KeyUtils.Send("!{F8}")
Return

RunTape:
	KeyUtils.SetKeyDelay(50)
	Loop, parse, Command
		KeyUtils.Send("{" . A_LoopField . " down}{" . A_LoopField . " up}")
	KeyUtils.Send("{Enter down}{Enter up}")
Return

HaltEmu:
	If WarpKey
		XHotKeywrapper(WarpKey,"Warp","OFF")
	If JoySwapKey
		XHotKeywrapper(JoySwapKey,"JoySwap","OFF")
	If StartTapeKey
		XHotKeywrapper(StartTapeKey,"StartTape","OFF")
	If StopTapeKey
		XHotKeywrapper(StopTapeKey,"StopTape","OFF")
	If (Fullscreen = "true")
		KeyUtils.Send("!{Enter}")
Return

MultiGame:
	RLLog.Info("MultiGame label triggered")
	If romExtension in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.prg
	{	KeyUtils.Send("!8") ; swaps a Disk
		wvTitle := "Attach disk image ahk_class #32770"
	} Else If romExtension in .t64,.tap
	{	KeyUtils.Send("!t") ; swaps a Tape
		wvTitle := "Attach tape image ahk_class #32770"
	} Else
		ScriptError(romExtension . " is an invalid multi-game extension")
	OpenROM(wvTitle, selectedRom)
	emuPrimaryWindow.WaitActive(5)
	emuPrimaryWindow.Activate()
Return

RestoreEmu:
	If (Fullscreen = "true")
		KeyUtils.Send("!{Enter}")
	If WarpKey
		XHotKeywrapper(WarpKey,"Warp","ON")
	If JoySwapKey
		XHotKeywrapper(JoySwapKey,"JoySwap","ON")
	If StartTapeKey
		XHotKeywrapper(StartTapeKey,"StartTape","ON")
	If StopTapeKey
		XHotKeywrapper(StopTapeKey,"StopTape","ON")
Return

CloseProcess:
	FadeOutStart()
	BezelExit()
	emuPrimaryWindow.Close()
Return
