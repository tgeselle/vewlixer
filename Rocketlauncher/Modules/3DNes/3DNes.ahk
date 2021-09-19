MEmu := "3DNes"
MEmuV := "v1.2.1"
MURL := ["https://geod.itch.io/3dnes"]
MAuthor := ["djvj"]
MVersion := "1.0.0"
MCRC := "9B7C6847"
iCRC := "F9CEDBD1"
mId := "636197382944389091"
MSystem := ["Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; Roms should accompany a *.3dn file for proper 3D support, which can be found here: https://itch.io/board/28136/3dn-showcase-and-sharing
; 3dn files must accompany the rom in the same folder. If you turn on 7z support in RLUI, this will break the emu from finding the 3dn file.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)		; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("3DNes","UnityWndClass"))	; instantiate primary emulator window object

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

params := If (fullscreen = "true") ? "-screen-fullscreen" : "-popupwindow"

BezelStart()

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" --r=""" . romPath . "\" . romName . romExtension . """ " . params)
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
Return
