MEmu := "SpudACE"
MEmuV := "v0.323"
MURL := ["http://www.jupiter-ace.co.uk/emulators_win.html#spudace"]
MAuthor := ["wahoobrian"]
MVersion := "1.0.3"
MCRC := "EBFBCB41"
iCRC := "57203A32"
MID := "635947558728471805"
MSystem := ["Jupiter ACE"]
;---------------------------------------------------------------------------------------------------
; Notes:
; Go to Tools|Options|Emulation and uncheck 'Ask before leaving SpudACE' and uncheck 'Autoload tapes' 
; (you don't always want the first program on the tape to start)
;
; As of 02/2016, SpudACE is the best emulator for Jupiter Ace, however does suffer from ugly crashes
; now and then.  If it crashes, you may not be able to launch it again since it leaves part of itself
; running and can also corrupt its configuration file.
; To correct:
;   The remnants of the running process do NOT always show in the Windows Task Manager.
;   Open a command prompt and issue TASKLIST, if you see SpudACE still running, enter the following:
;      TASKKILL /F IM SpudACE.exe /T
;   Then, again using a command prompt, run SpudAce from the command line to rebuild the corrupt 
;   configuration file:
;       SpudAce.exe -i
;
; Using RLUI, you can set the emulator to run at 100%, 200, or 300% size.  Also, fullscreen.
;
; Most games are controlled using 5,6,7,8 as left, up, down, right, respectively.
; Detailed info on each game, including controls, can be found at:
; http://www.jupiter-ace.co.uk/software_index.html
;
; The emulator has some issues detecting simulated keypresses so if you see some letters missing on your 
; loading commands you should tweak the KeyDelay and KeyPressDuration module settings. It also seems that 
; when run in DirectDraw module the emulator is less prone to these issues, so it's suggested that you 
; use this rendering mode, you can set it in Tool|Options|Display
;---------------------------------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("SpudACE","Jupiter Ace Emulator"))	; instantiate primary emulator window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
KeyDelay := moduleIni.Read("Settings", "KeyDelay", "100",,1)
KeyPressDuration := moduleIni.Read("Settings", "KeyPressDuration", "1",,1)
ModelType := moduleIni.Read(romName, "ModelType", "0",,1)
Command := moduleIni.Read(romName, "Command",,,1)
If (Fullscreen = "false")
	WindowSize := moduleIni.Read("Settings", "WindowSize","3",,1)
Else
	WindowSize := 4

spudAceINI := new IniFile(emuPath . "\spudace.ini")
spudAceINI.CheckFile()

currentScreenSize := spudAceINI.Read("Display", "opt_DrawSize")
currentModelType  := spudAceINI.Read("Hardware", "opt_model_type")

; Setting WindowSize setting in ini If it doesn't match what user wants above
If (WindowSize != currentScreenSize)
	spudAceINI.Write(WindowSize, "Display", "opt_DrawSize")

; Setting ModelType setting in ini If it doesn't match what user wants above
If (ModelType != currentModelType)
	spudAceINI.Write(ModelType, "Hardware", "opt_model_type")

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)	
	
BezelStart("FixResMode")

cliOptions := " -i"

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(cliOptions . " """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()

KeyUtils.SendCommand(Command, 3000, 500, 0, KeyDelay, KeyPressDuration)

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	BezelExit()
	emuPrimaryWindow.Close()
Return
