MEmu := "O2Em"
MEmuV := "v1.18"
MURL := ["http://o2em.sourceforge.net/"]
MAuthor := ["brolly"]
MVersion := "1.0"
MCRC := "C458F7C5"
iCRC := "F38BF62E"
MID := "635871548205404365"
MSystem := ["Magnavox Odyssey 2","Philips Videopac Plus G7400"]
;----------------------------------------------------------------------------
; Notes:
; Make sure you put your bios files inside the bios folder on your emulator folder.
; Bios filenames should be:
; Magnavox Odyssey 2: o2rom.bin
; Philips Videopac Plus G7400: g7400.bin
;
; Check the O2EM.TXT file inside the docs folder for details on setting up any extra 
; settings namely the use of the o2emcfg.cfg file.
;
; For voice emulation to work make sure you have all the voice WAV samples inside the 
; voice folder.
;
; There's a newer unofficial version of the emulator (v1.20b5) available here:
; http://videopac.nl/forum/index.php?topic=1771.0
;
; This version seems to be very buggy with a lot of crashes, also has several other issues 
; like windowed mode only working at x1 and x2 so it's suggested to stick with the official version.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("Magnavox Odyssey 2","ody2","Philips Videopac Plus G7400","g7400")
ident := mType[systemName]	; search object for the systemName identifier
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this O2Em module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Scanlines := IniReadCheck(settingsFile, "Settings", "Scanlines","true",,1)
WindowSize := IniReadCheck(settingsFile, "Settings", "WindowSize","4",,1)
Params := IniReadCheck(settingsFile, "Settings|" . romName, "Params","",,1)
NoVoice := IniReadCheck(settingsFile, romName, "NoVoice","false",,1)

BezelStart("fixResMode")

hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"O2EM ahk_class AllegroWindow",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

options := If Fullscreen = "true" ? " -fullscreen" : ""
options .= If Scanlines = "true" ? " -scanlines" : ""
options .= If NoVoice = "true" ? " -novoice" : ""

If (Fullscreen = "false")
	options .= " -wsize=" . WindowSize

If (ident = "ody2")
	options .= " -o2rom"
Else
	options .= " -g7400"

If RegExMatch(romName,"i)\(USA")
	options := options ;. " -ntsc" -ntsc is only an option for the 1.20b5 unofficial version
Else
	options .= " -euro"

options .= If Params ? " " . Params : ""

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """" . options, emuPath)

WinWait("O2EM ahk_class AllegroWindow")
WinWaitActive("O2EM ahk_class AllegroWindow")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("O2EM ahk_class AllegroWindow")
Return
