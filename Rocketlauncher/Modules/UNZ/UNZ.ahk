MEmu := "UNZ"
MEmuV := "v0.5L30"
MURL := ["http://townsemu.world.coocan.jp/"]
MAuthor := ["djvj"]
MVersion := "2.0.4"
MCRC := "AE6BA559"
iCRC := "1E716C97"
MID := "635038268929715384"
MSystem := ["Fujitsu FM Towns"]
;----------------------------------------------------------------------------
; Notes:
; Make sure your Virtual_Drive_Path in RocketLauncherUI General Settings is correct as it is required.
; Run UNZ manually and in Settings->Property->CD-ROM1->Emulation Type->Select drive, set your virtual drive letter
; There is no way of launching the game automatically from the FM-Towns OS window.
; To launch the game, double click the game's name once you are in the FM-Towns OS
; View->Fullscreen to enable fullscreen
; If a game requires a boot disk or user disk, just put it on the same folder as your game and name it
; with the rom name with an hdm extension.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)	; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("UNZ","Unz"))	; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle("Open diskimage","#32770"))
emuErrorWindow := new Window(new WindowTitle("Unz.exe","#32770"))

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuOpenWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart("fixResMode")

fullscreen := If (Fullscreen = "true")?" -fs":""

diskFile := new File(romPath "\" . romName . ".hdm")

VirtualDrive("mount",romPath . "\" . romName . romExtension)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(fullscreen)

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If diskFile.Exist()
{
	TimerUtils.Sleep(500)
	emuPrimaryWindow.PostMessage("0x111",40005)
	emuOpenWindow.OpenROM(diskFile)
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
VirtualDrive("unmount")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	KeyUtils.Send("{F11}")
	TimerUtils.Sleep(200)
Return

RestoreEmu:
	emuPrimaryWindow.Restore()
	If !emuPrimaryWindow.Active()
		Loop {
			TimerUtils.Sleep(50)
			emuPrimaryWindow.Activate()
			If emuPrimaryWindow.Active()
				Break
		} 
	KeyUtils.Send("{F11}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
	TimerUtils.Sleep(300)
	If emuErrorWindow.Exist()
		emuErrorWindow.Close()
Return
