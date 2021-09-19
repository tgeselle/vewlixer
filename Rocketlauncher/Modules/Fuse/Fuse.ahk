MEmu := "Fuse"
MEmuV := "v1.1.1"
MURL := ["http://fuse-emulator.sourceforge.net/"]
MAuthor := ["brolly"]
MVersion := "1.0.1"
MCRC := "57F822F3"
iCRC := "8381FFD1"
MID := "635965569783899151"
MSystem := ["Sinclair ZX Spectrum","Timex Sinclair 2068"]
;----------------------------------------------------------------------------
; Notes:
; To see the emulator supported command line parameters type:
; fuse.exe --help
;
; Or check the file named fuse.html in the emulator's folder
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Fuse","Fuse"))	; instantiate primary emulator window object

mType := Object("Timex Sinclair 2068","ts2068","Sinclair ZX Spectrum","48")
ident := mType[systemName]	; search object for the systemName identifier

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Filter := moduleIni.Read("Settings", "Filter",,,1)
Model := moduleIni.Read(romName . "|Settings", "Model", ident,,1)

BezelStart("fixResMode")
hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, SevenZExtractPath)

cliOptions := " --no-confirm-actions --no-statusbar"
If (Fullscreen = "true")
	cliOptions .= " --full-screen"
If Filter
	cliOptions .= " --graphics-filter " . Filter
If Model
	cliOptions .= " --machine " . Model

If StringUtils.Contains(romExtension,"\.dck")
	cliOptions .= " --dock"
Else If StringUtils.Contains(romExtension,"\.tap|\.tzx")
	cliOptions .= " --tape"
Else If StringUtils.Contains(romExtension,"\.z80")
	cliOptions .= " --snapshot"
Else
	ScriptError("Selected File Extension isn't compatible with this module : " . romExtension)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(cliOptions . " """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
