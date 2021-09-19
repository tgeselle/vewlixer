MEmu := "Raine"
MEmuV := "v0.64.9"
MURL := ["http://rainemu.swishparty.co.uk/"]
MAuthor := ["brolly"]
MVersion := "2.0.3"
MCRC := "60318E5E"
iCRC := "4BF75BC8"
MID := "635038268907767111"
MSystem := ["SNK Neo Geo CD","SNK Neo Geo","SNK Neo Geo MVS","SNK Neo Geo AES"]
;----------------------------------------------------------------------------
; Notes:
; First time you run the emu, it will ask you to find the Neocd.bin bios, so place it in the folder with the emulator or a "bios" subfolder.
; If you get an error "Could not open IPL.TXT", then you have one of the below problems:
; Not using a real Neo-Geo CD game (which are cd images) that contain an IPL.TXT. Do not use MAME roms otherwise you will get this error.
;
; To play MVS/AES games requires a proper rom path. The module will set the first rom path (rom_dir_0) for you automatically.
; If you want to use multiple rom paths you can do it by editing the config\raine32_sdl.cfg file and adding the paths under the Directories section
; For example to use 2 different rom paths:
; rom_dir_0 = E:\Games\SNK Neo Geo\	(DO NOT SET THIS PATH AS IT'S CONTROLLED BY THE MODULE)
; rom_dir_1 = E:\Emulators\Raine\roms\
;
; If you don't add all your roms (both bios and games) to the cfg file then Raine will fail to load the games as it won't be able to find the rom files.
;
; The config file raine32_sdl.cfg should be in the config folder. If this file doesn't exist, start Raine change any setting and exit so it will create this file on exit
;
; Useful command line switches:
; raine32.exe -gamelist
; raine32.exe -listdsw
; raine32.exe -h
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"SDL_app"))	; instantiate primary emulator window object

If StringUtils.Contains(systemName,"AES")
	DefaultBiosVersion := "22"

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
ScreenWidth := moduleIni.Read("Settings", "ScreenWidth",,,1)
ScreenHeight := moduleIni.Read("Settings", "ScreenHeight",,,1)
BiosVersion := moduleIni.Read(romName . "|Settings", "BiosVersion", DefaultBiosVersion,,1)	; AES should be 22 and 23

; Setting Region
If StringUtils.Contains(romName,"\(Japan\)")
	DefaultRegion := "0"
Else If StringUtils.Contains(romName,"\(Europe\)")
	DefaultRegion := "2"
Else If StringUtils.Contains(romName,"\(Brazil\)")
	DefaultRegion := "3"
Else
	DefaultRegion := "1"	; USA

Region := moduleIni.Read(romName . "|Settings", "Region", DefaultRegion,,1)

RaineIni := new File(emuPath . "\config\raine32_sdl.cfg")
RaineIni.CheckFile("Cannot find raine32_sdl.cfg. Please run Raine manually and enter options menu, then exit so it is created for you: " . RaineIni.FileFullPath)

BezelStart()
hideEmuObj := Object(emuPrimaryWindow,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

If StringUtils.Contains(romExtension,"\.7z|\.rar")
	ScriptError("Raine only supports zip archives. Either enable 7z support, or extract your games first.")

cliOptions := " -nogui"
If (Fullscreen = "true")
	cliOptions .= " -fs 1"
Else
	cliOptions .= " -fs 0"

If (ScreenWidth)
	cliOptions .= " -screenx " . ScreenWidth
If (ScreenHeight)
	cliOptions .= " -screeny " . ScreenHeight

If StringUtils.Contains(systemName,"AES")
	cliOptions .= " -cont"	; Enable continuous play

If (systemName = "SNK Neo Geo CD")
{
	cliOptions .= " -region " . Region
	cliOptions .= " """ . romPath . "\" . romName . romExtension . """"
} Else {
	cliOptions .= " -g " . romName
	RaineIni.Write(romPath . "\", "Directories", "rom_dir_0")	; Set rom path
}

If (!StringUtils.Contains(systemName,"CD") && BiosVersion)
	RaineIni.Write(BiosVersion, "neogeo", "bios")

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(cliOptions)

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
