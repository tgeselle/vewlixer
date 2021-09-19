MEmu := "Kat5200"
MEmuV := "v0.6.2"
MURL := ["http://kat5200.jillybunch.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.4"
MCRC := "4D36E25F"
MID := "635038268901251702"
MSystem := ["Atari 5200"]
;----------------------------------------------------------------------------
; Notes:
; In you emu dir, create a subdir named bios and place the 5200.rom there extracted.
; When you first start kat5200, you will be presented with a Wizard. Set the bios folder you created as your "Atari 8-Bit Image Directory" and leave Scan for BIOS? checked.
; While in the wizard, check the Fullscreen box to enable it and set Video Zoom to 2x.
; CLI is supported but doesn't seem to work. So for now, set your video options from the GUI.
; Settings are stored in the kat5200.db3 file.
; Roms must be extracted, zip is not supported
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("kat5200","SDL_app"))	; instantiate primary emulator window object
emuConsoleWindow := new Window(new WindowTitle(,"ConsoleWindowClass"))

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

If StringUtils.Contains(romExtension,sevenZFormatsRegEx)
	ScriptError("Kat5200 only supports extracted roms. Please extract your roms or turn on 7z for this system as the emu is being sent this extension: """ . romExtension . """")

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
