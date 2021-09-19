MEmu := "DCAlice"
MEmuV := "v2014.01.23"
MURL := ["http://alice32.free.fr/"]
MAuthor := ["brolly"]
MVersion := "2.0.2"
MCRC := "A6E6FDB8"
iCRC := "96B57889"
MID := "635535810894136267"
MSystem := ["Matra & Hachette Alice"]
;----------------------------------------------------------------------------
; Notes:
; The emu will be in french until you click Options -> Parametres -> Langue -> Anglais, then hit OK.
; Roms must be unzipped
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"DCAlice"))	; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle(dialogOpen,"#32770"))

Fullscreen := moduleIni.Read("settings", "Fullscreen","true",,1)
RestoreTaskbar := moduleIni.Read("settings", "RestoreTaskbar","true",,1)
Model := moduleIni.Read(romName . "|Settings", "Model", "alice32",,1)
Command := moduleIni.Read(romName, "Command", "CLOAD+RUN",,1)

DefaultAliceModelIni := emuPath . "\dcalice.ini"
AliceModelIni := new File(emuPath . "\dcalice_" . Model . ".ini")

If AliceModelIni.Exist()
	AliceModelIni.Copy(DefaultAliceModelIni,1)
Else
	RLLog.Info("Module - Couldn't find file : " . AliceModelIni . " using dcalice.ini instead")

BezelStart()

hideEmuObj := Object(emuOpenWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run()

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
TimerUtils.Sleep(100)

emuPrimaryWindow.PostMessage("0x111","9001")	; Opens Load Tape window
emuOpenWindow.OpenROM(romPath . "\" . romName . romExtension)

emuPrimaryWindow.WaitActive()
TimerUtils.Sleep(500)	; increase If CLOAD is not appearing in the emu window or some just some letters

If (Model = "mc10")
	StartCommand := If Command = "CLOAD+RUN" ? "cload{Enter}{Wait:1500}run{Enter}" : "cloadm{Enter}{Wait:1500}exec{Enter}"
Else
	StartCommand := If Command = "CLOAD+RUN" ? "cloqd{Enter}{Wait:1500}run{Enter}" : "cloqd{vkC0sc027}{Enter}{Wait:1500}exec{Enter}"

KeyUtils.SetKeyDelay(50)
KeyUtils.SendCommand(StartCommand)	; This will type CLOAD in the screen (french systems are AZERTY so q=a)

If (Fullscreen = "true")
	KeyUtils.Send("{PGUP}")

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()

If (RestoreTaskbar = "true")
	MiscUtils.TaskBar("on")

ExitModule()


HaltEmu:
	KeyUtils.Send("{Alt down}{Alt up}")
Return

RestoreEmu:
	emuPrimaryWindow.Restore()
	emuPrimaryWindow.Activate()
	If (Fullscreen = "true")
		KeyUtils.Send("{PGUP}")		; PgDown gets back to windowed mode
Return

CloseProcess:
	FadeOutStart()
	KeyUtils.Send("{Alt down}{Alt up}")
	emuPrimaryWindow.Close()
Return
