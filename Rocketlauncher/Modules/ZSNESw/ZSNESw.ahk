MEmu := "ZSNESw"
MEmuV := "v1.51"
MURL := ["http://www.zsnes.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.5"
MCRC := "2F6DE4D2"
iCRC := "FF33BDC8"
MID := "635038268938832977"
MSystem := ["Super Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; Make sure you set quickexit to your Exit_Emulator_Key key while in ZSNES.
; If you want to use Esc as your quick exit key, open zsnesw.cfg with a text editor and find the lines below.
; If using fullscreen mode, it is suggest you turn fadeout off as it can not allow zsnes to close properly due to the method required to close zsnes.
; Set KeyQuickExit to 1, as shown below. You can't set the quick exit key to escape while in the emulator, because that's the exit key to configuring keys. 
;
; Quit ZSNES / Load Menu / Reset Game / Panic Key
; KeyQuickExit=1
; KeyQuickLoad=0
; KeyQuickRst=0
; KeyResetAll=42
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("ZSNES","ZSNES"))	; instantiate primary emulator window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Stretch := moduleIni.Read("Settings", "Stretch","false",,1)
resX := moduleIni.Read("Settings", "resX","1024",,1)
resY := moduleIni.Read("Settings", "resY","768",,1)
DisplayRomInfo := moduleIni.Read("Settings", "DisplayRomInfo","false",,1)	; Display rom info on load along bottom of screen

zsnesFile := new File(emuPath . "\zsnesw.cfg")
zsnesFile.CheckFile()
zsnesIni := LoadProperties(zsnesFile.FileFullPath)	; load the config into memory
xLine := ReadProperty(zsnesIni,"CustomResX")	; read current X value
yLine := ReadProperty(zsnesIni,"CustomResY")	; read current Y value
currentDRI := ReadProperty(zsnesIni,"DisplayInfo")	; read current displayinfo value

WriteProperty(zsnesIni,"CustomResX", resX)	; update custom X res in zsnes cfg file
WriteProperty(zsnesIni,"CustomResY", resY)	; update custom Y res in zsnes cfg file

If (Fullscreen = "true" && Stretch = "true") ; sets fullscreen, stretch, and filter support
	vidMode := 39
Else If (Fullscreen = "true" && Stretch != "true") ; sets fullscreen, correct aspect ratio, and filter support
	vidMode := 42
Else ; sets windowed mode with filter support
	vidMode := 38

WriteProperty(zsnesIni,"cvidmode", vidMode)	; update custom Y res in zsnes cfg file

; Setting DisplayRomInfo setting in cfg if it doesn't match what user wants above
If (DisplayRomInfo != "true" And currentDRI = 1) {
	WriteProperty(zsnesIni,"DisplayInfo", 0)
} Else If (DisplayRomInfo = "true" And currentDRI = 0) {
	WriteProperty(zsnesIni,"DisplayInfo", 1)
}

SaveProperties(zsnesFile.FileFullPath,zsnesIni)	; save zsnesFile to disk

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

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


CloseProcess:
	FadeOutStart()
	KeyUtils.SetKeyDelay(50)	; slow down the keys below so the emu can register them
	MiscUtils.SetWinDelay(50)	; don't remember why I needed this
	KeyUtils.Send("{Alt Down}{F4 Down}{F4 Up}{Alt Up}")		; No other closing method seems to work, not even ControlSend
Return
