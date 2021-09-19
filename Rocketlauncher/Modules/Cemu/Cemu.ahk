MEmu := "Cemu"
MEmuV := "v1.7.0"
MURL := ["http://cemu.info/"]
MAuthor := ["djvj"]
MVersion := "1.0.5"
MCRC := "6773400D"
iCRC := "317C6C8"
MID := "635803743205902402"
MSystem := ["Nintendo Wii U"]
;----------------------------------------------------------------------------
; Notes:
; Make sure the keys.txt in the emu root folder contains a Wii U common key.
; Do not ask where to get this, it's your job to figure this out.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Cemu","wxWindowNR"))	; instantiate primary emulator window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart("FixResMode")
HideAppStart(hideEmuObj,hideEmu)

If (Fullscreen = "true")
	Params := " -f"

primaryExe.Run(Params . " -g """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

;If (fullscreen = "true")
;	emuPrimaryWindow.MenuSelectItem("Options","Fullscreen")

; Load image
; emuPrimaryWindow.WinMenuSelectItem("File","Load")
; OpenROM("Open file to launch", romPath . "\" . romName . romExtension)
; emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
