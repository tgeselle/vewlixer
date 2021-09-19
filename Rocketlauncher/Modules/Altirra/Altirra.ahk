MEmu := "Altirra"
MEmuV := "v2.60 Test 12"
MURL := ["http://www.virtualdub.org/altirra.html"]
MAuthor := ["wahoobrian","brolly"]
MVersion := "1.3.2"
MCRC := "C65269B"
iCRC := "A55EF67B"
MID := "635532590282232367"
MSystem := ["Atari 8-Bit","Atari XEGS","Atari 5200"]
;-----------------------------------------------------------------------------------------------------------
; Notes:
;
; From command prompt, "altirra /?" will display help for command-line switches.
; Select your Bios files via System | Firmware | Rom Images...
;
; Lightgun/pen emulation via mouse is tricky, doesn't seem to work very well.  Not supported by module.
;
; The module will force Altirra to run in portable mode so all settings will be saved to a file named Altirra.ini 
; instead of the registry.
;
; Some compatibility tips from the Altirra authors:
;  Disable BASIC (unless you're actually running a BASIC program).
;  For older games, use 800 hardware and 48K RAM, and the OS-B kernel.
;  For newer games, use XL hardware and 128K RAM (XE), and use the XL kernel.
;  For demos and games written in Europe, use XL hardware/kernel, 320K RAM, and PAL.
;  If you don't have kernel ROM images, use the HLE kernel instead.
;  Use Input > Joystick to toggle the joystick, which uses the arrow keys and the left control key.
;-----------------------------------------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)		; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Altirra","AltirraMainWindow"))	; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle("Load disk, cassette, cartridge, or program image","#32770"))

mType := Object("Atari XEGS","xegs","Atari 8-Bit","800xl","Atari 5200","5200")
ident := mType[systemName]	; search object for the systemName identifier Atari800 uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Atari800 module: " . moduleName)

; Cursor cannot be at 0,0 or it will make Altirra's invisible menu become visible 
If StringUtils.RegExMatch(hideCursor,"i)true|do_not_restore")
	MouseMove, 0, 200, 0

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Mouse := moduleIni.Read(romName, "Mouse","off",,1)
CartType := moduleIni.Read(romName, "CartType",0,,1)	; 1-59 Info found in DOC\cart.txt

BezelStart()

cliOptions := If (Fullscreen = "true") ? " /f" : " "
cliOptions := cliOptions . " /portable"

If (SystemName = "Atari 5200") {
	cliOptions := cliOptions . " /hardware:5200 /kernel:5200 "

	CartType := moduleIni.Read(romName, "CartType",0,,1)
	if (!CartType) {
		a5200cartMaps := Object(4,58,8,19,16,6,32,4,40,7)
		RomFile := new File(romPath . "\" . romName . romExtension)
		fsize := RomFile.GetSize("K")
		CartType := a5200cartMaps[fsize]
	}
	If (!CartType)
		ScriptError("Unknown cart type, make sure you define a CartType for this game on Atari 5200.ini")

	cliOptions := cliOptions . " /cartmapper " . CartType . " /cart "
}
Else If (SystemName = "Atari XEGS") {
	cliOptions := cliOptions . " /hardware:xegs /kernel:xegs /memsize:64k /cart "
}
Else {
	Basic := moduleIni.Read(romName, "Basic",If (romExtension=".bas") ? "true" : "false",,1)
	OSType := moduleIni.Read(romName, "OSType","default",,1)
	VideoMode := moduleIni.Read(romName, "VideoMode","PAL",,1)
	MachineType := moduleIni.Read(romName, "MachineType",ident,,1)
	CartType := moduleIni.Read(romName, "CartType",0,,1)	
	CassetteLoadingMethod := moduleIni.Read(romName, "CassetteLoadingMethod",Auto,,1)
	Command := moduleIni.Read(romName, "Command",,,1)
	SendCommandDelay := moduleIni.Read(romName, "SendCommandDelay", "2000",,1)
	MouseMode := moduleIni.Read(romName, "MouseMode",A_Space,,1)
	DisableSIOPatch := moduleIni.Read(romName, "DisableSIOPatch","false",,1)
	LoadBasicAsCart := moduleIni.Read(romName, "LoadBasicAsCart",,,1)

	DefaultMemSize := "128K"
	If (MachineType = "800")
		DefaultMemSize := "48K"

	MemorySize := moduleIni.Read(romName, "MemorySize",DefaultMemSize,,1)

	;set sio patch (fast i/o access)
	If (DisableSIOPatch = "true")
		cliOptions := cliOptions . " /nosiopatch "
	Else
		cliOptions := cliOptions . " /siopatch "

	basic := If (Basic="true") ? " /basic" : " /nobasic"
	videomode := If (VideoMode="PAL") ? " /pal" : " /ntsc"
	machine := " /hardware:" . MachineType
	os := " /kernel:" . OSType
	memsize := " /memsize:" . MemorySize

	cliOptions := cliOptions . emuFullscreen . videomode . machine . basic . os . memsize
	
	If (LoadBasicAsCart)
	{
		PathToBasicCart := AbsoluteFromRelative(EmuPath, LoadBasicAsCart)
		CheckFile(PathToBasicCart)
		cliOptions := cliOptions . " /cart """ . PathToBasicCart . """ /cartmapper 1"
	}

	If StringUtils.Contains(romExtension,"\.a52|\.car|\.cart|\.rom")	; Carts
	{
		If (CartType > 0) 
			cliOptions := cliOptions . " /cartmapper" . CartType
		cliOptions := cliOptions . " /cart"
	}
	Else If StringUtils.Contains(romExtension,"\.cas") ; Tapes
	{
		If (CassetteLoadingMethod = "Auto")
			cliOptions := cliOptions . " /casautoboot /tape"
		Else 
			cliOptions := cliOptions . " /nocasautoboot /tape"
	}
	Else If StringUtils.Contains(romExtension,"\.atr|\.xfd|\.atx|\.bas")	; Disks
	{
		cliOptions := cliOptions . " /bootrw"
	}
	Else If StringUtils.Contains(romExtension,"\.xex|\.com")	; Binary Programs
	{
		cliOptions := cliOptions . " /run"
	}
	Else
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`a52,car,cart,rom,cas,atr,xfd,atx,xex,com,bas")
}

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(cliOptions . " """ . romPath . "\" . romName . romExtension)
emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()

If (CassetteLoadingMethod = "CLOAD+RUN") {
	TimerUtils.Sleep(5000)	; allow time for tape to mount, emulator to boot
	SendCommand("CLOAD{Enter}", 100)
	SendCommand("{Enter}", 100)
	TimerUtils.Sleep(3000)
	SendCommand("RUN{Enter}", 100)
}

If (Command) {
	TimerUtils.Sleep(5000)	; allow time for emulator to boot
	SendCommand(Command, 1000)
}

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


MultiGame:
	RLLog.Info("Module - MultiGame Label was ran!")
	If StringUtils.Contains(romExtension,"\.atr|\.cas")
		KeyUtils.Send("!o")
	Else
		ScriptError(romExtension . " is an invalid multi-game extension")
	
	emuOpenWindow.Wait()
	emuOpenWindow.WaitActive()
	emuOpenWindow.OpenROM(selectedRom)
	emuPrimaryWindow.WaitActive(5)
	emuPrimaryWindow.Activate()
Return

RestoreEmu:
	If (Fullscreen = "true")
		emuPrimaryWindow.MenuSelectItem("View","Full Screen")
Return

CloseProcess:
	FadeOutStart()
	BezelExit()
	emuPrimaryWindow.Close()
Return
