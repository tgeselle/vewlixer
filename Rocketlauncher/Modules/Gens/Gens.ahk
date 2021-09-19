MEmu := "Gens"
MEmuV := "v2.14"
MURL := ["http://segaretro.org/Gens"]
MAuthor := ["djvj"]
MVersion := "2.0.2"
MCRC := "5E022267"
iCRC := "2805229D"
MID := "635038268896537774"
MSystem := ["Sega CD","Sega Genesis","Sega Mega Drive","Sega Mega-CD"]
;----------------------------------------------------------------------------
; Notes:
; For Sega CD, don't forget to setup your bios or you might just get a black screen.
; Fullscreen and stretch are controlled via module settings in RLUI
;
; Sega CD & Sega 32X
; Configure your Sega CD bios first by going to Option -> Bios/Misc Files
; Gens only supports bin files for Sega CD, not cue
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Gens","Gens"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Stretch := moduleIni.Read("Settings", "Stretch","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

gensINI := new IniFile(emuPath . "\Gens.cfg")
gensINI.CheckFile()

currentFullScreen := gensINI.Read("Graphics","Full Screen")
currentStretch := gensINI.Read("Graphics","Stretch")

If (romExtension = ".cue")
	ScriptError("Gens does not support cue files, please use another extension")

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If (Fullscreen != "true" And currentFullScreen = 1)
	gensINI.Write(0,"Graphics","Full Screen")
Else If (Fullscreen = "true" And currentFullScreen = 0)
	gensINI.Write(1,"Graphics","Full Screen")

; Setting Stretch setting in ini if it doesn't match what user wants above
If (Stretch != "true" And currentStretch = 1)
	gensINI.Write(0,"Graphics","Stretch")
Else If (Stretch = "true" And currentStretch = 0)
	gensINI.Write(1,"Graphics","Stretch")

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


RestoreEmu:
	KeyUtils.Send("!{Enter}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
