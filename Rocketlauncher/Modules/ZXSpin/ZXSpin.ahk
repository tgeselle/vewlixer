MEmu := "ZXSpin"
MEmuV := "v0.7"
MURL := ["http://www.zophar.net/sinclair/zx-spin.html"]
MAuthor := ["brolly"]
MVersion := "1.0.0"
MCRC := "B63A0A76"
iCRC := "5CF9BDE5"
MID := "636191089257618149"
MSystem := ["Sinclair ZX Spectrum"]
;----------------------------------------------------------------------------
; Notes:
; The emulator settings are stored by default on a file called Default.spincfg.
; It's recommended that you set the rendering method to Direct3D under Tools-Options-Display Engine
; Also go to the Emulation menu and make sure Enable Keystick is checked
; Games are run on 48K model by default, if you want to use a different model for a specific game you can set it on RLUI.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)		; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("ZXSpin","TSPINMainWindow"))	; instantiate primary emulator window object

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
DefaultModel := moduleIni.Read("Settings", "Model","1|1",,1) ;48K is the default model

If StringUtils.Contains(romName,"(16K)")
	DefaultModel := "0|0"
Else If StringUtils.Contains(romName,"(128K)")
	DefaultModel := "2|0"
Else If StringUtils.Contains(romName,"(+3)")
	DefaultModel := "5|0"

Model := moduleIni.Read(romName, "Model",DefaultModel,,1)

ZxSpinIni := new IniFile(emuPath . "\Default.spincfg")
ZxSpinIni.CheckFile()

ZxSpinIni.Write(Fullscreen = "true" ? "1" : "0","Video","StartFullScreen")

; Set Model
ModelArray := StringUtils.Split(Model,"|")
ZxSpinIni.Write(ModelArray[1], "Hardware", "Model")
ZxSpinIni.Write(ModelArray[2], "Hardware", "Issue2Emulation")

BezelStart()

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")
emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()

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
	errClose := primaryExe.ProcessWaitClose(1)
	If errClose	; if ZXSpin did not close, force close it. This sometimes happens on exit.
		primaryExe.ProcessClose()
Return
