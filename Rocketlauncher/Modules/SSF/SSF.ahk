MEmu := "SSF"
MEmuV := "v0.12 beta R4"
MURL := ["http://www.geocities.jp/mj3kj8o5/ssf/index.html"]
MAuthor := ["djvj","brolly"]
MVersion := "2.1.7"
MCRC := "B055DE07"
iCRC := "918A4E4C"
MID := "635038268924991452"
MSystem := ["Sega Saturn","Sega ST-V"]
;----------------------------------------------------------------------------
; Notes:
; Sega Saturn:
; This only works with DTLite, not DTPro
; Make sure your Virtual Drive Path in RocketLauncherUI is correct
; romExtension should be ccd|mds|cue|iso|cdi|nrg
; You MUST set the path to the 3 different region BIOS files in RocketLauncherUI module's settings.
; If you prefer a region-free bios, extract this bios and set all 3 bios paths to this one file: http://theisozone.com/downloads/other-consoles/sega-saturn/sega-saturn-region-free-bios/
; Make sure you have your CDDrive set to whatever number you use for your games. 0 may be your hardware drive, while 1 may be your virtual drive (depending on how many you have). If you get a black screen, try different numbers starting from 0.
; If you keep getting the CD Player BIOS screen, you have the CDDrive variable set wrong below
; If you keep getting the CD Player screen with the message "Game disc unsuitable for this system", you have the incorrect bios set for the region game you are playing and or region is set wrong in the emu options. Or you can just turn off the BIOS below :)
; If your game's region is (USA), you must use a USA bios and set SSF Area Code to "America, Canada Brazil". For (Japan) games, bios must be a Japan one and SSF Area Code set to Japan. Use the same logic for European games. You will only see a black screen if wrong.
; SSF will use your desktop res as the emu's res if Stretch and EnforceAspectRatioFullscreen are both true when in fullscreen mode. If you turn Stretch off, it forces 1024x768 in fullscreen mode if your GPU supports pixel shader 3.0, otherwise it forces 640x480 if it does not.
; If you are getting clipping, set the vSync variable to true below
; For faster MultiGame switching, keep the BIOS off, otherwise you have to "play" the disc each time you switch discs
; Module will attempt to auto-detect the region for your game by using the region tags in parenthesis on your rom file and set SSF to use the appropriate region settings that match.
;
; Shining Force III - Scenario 2 & 3 (Japan) (Translated En) games crash at chapter 4 and when you use Marki Proserpina spell or using the Abyss Wand. Fix may be to use a different bios if this occurs, but this is untested. Read more about it here: http://forums.shiningforcecentral.com/viewtopic.php?f=34&t=14858&start=80
; 
; Custom Config Files:
; You can use custom per game ini files. Just put them in a Configurations folder inside the emulator folder and name them after the rom name. Make sure you also put a file named Default.ini file in there with your default 
; settings so the module can revert back to use those.
;
; Data Cartridges:
; These 2 games used a hardware cart in order to play the games, so the module will mount them if found within the same folder as the cd image and named the same as the xml game name with a "rom" extension.
; Ultraman - Hikari no Kyojin Densetsu (Japan) and King of Fighters '95, The (Europe)
; So something like this must exist: "King of Fighters '95, The (Europe).rom"

; Sega ST-V:
; romExtension should be zip
; Extract the stv110.bin bios into the BIOS folder. Run SSF.exe and goto Option->Option and point ST-V BIOS to this file.
; Set fullscreen mode via the variable below
; If you are getting clipping, set the vSync variable to true below
;
; If it seems like it's taking a long time to load, it probably is. You are going to stare at the black screen while SSF is decoding the roms.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("SSF"))	; instantiate primary emulator window object
emuOpenROMWindow := new Window(new WindowTitle("Select ROM file","#32770"))
emuDecodingWindow := new Window(new WindowTitle("Decoding ROM file","#32770"))

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
UseBIOS := moduleIni.Read("Settings", "UseBIOS","false",,1)
BilinearFiltering := moduleIni.Read("Settings", "BilinearFiltering","true",,1)
WideScreen := moduleIni.Read("Settings", "WideScreen","false",,1)
Stretch := moduleIni.Read("Settings", "Stretch","true",,1)	; default true because SSF will use your desktop res in fullscreen mode as long as EnforceAspectRatioFullscreen is also true
AutoFieldSkip := moduleIni.Read("Settings", "AutoFieldSkip","true",,1)
EnforceAspectRatioWindow := moduleIni.Read("Settings", "EnforceAspectRatioWindow","true",,1)	; enforces aspect even when stretch is true
EnforceAspectRatioFullscreen := moduleIni.Read("Settings", "EnforceAspectRatioFullscreen","true",,1)	; enforces aspect even when stretch is true
FixedWindowResolution := moduleIni.Read("Settings", "FixedWindowResolution","true",,1)
FixedFullscreenResolution := moduleIni.Read("Settings", "FixedFullscreenResolution","false",,1)
VSynchWaitWindow := moduleIni.Read("Settings", "VSynchWaitWindow","true",,1)
VSynchWaitFullscreen := moduleIni.Read("Settings", "VSynchWaitFullscreen","true",,1)
CDDrive := moduleIni.Read("Settings", "CDDrive","1",,1)
defaultRegion := moduleIni.Read("Settings", "DefaultRegion","1",,1)
WindowSize := moduleIni.Read("Settings", "WindowSize","2",,1)
Scanlines := moduleIni.Read(romName . "|Settings", "Scanlines","false",,1)
ScanlineRatio := moduleIni.Read(romName . "|Settings", "ScanlineRatio","70",,1)
usBios := moduleIni.Read("Settings", "USBios",,,1)
euBios := moduleIni.Read("Settings", "EUBios",,,1)
jpBios := moduleIni.Read("Settings", "JPBios",,,1)
worldBios := moduleIni.Read("Settings", "WorldBios",,,1)
SH2enabled := moduleIni.Read(romName, "SH2enabled","false",,1)
deleteCachedSettings := moduleIni.Read(romName . "|Settings", "DeleteCachedSettings","false",,1)
legacyMode := moduleIni.Read(romName . "|Settings", "LegacyMode","false",,1)
bezelTopOffset := moduleIni.Read(romName . "|Settings", "bezelTopOffset","0",,1)
bezelBottomOffset := moduleIni.Read(romName . "|Settings", "bezelBottomOffset","24",,1)
bezelLeftOffset := moduleIni.Read(romName . "|Settings", "bezelLeftOffset","0",,1)
bezelRightOffset := moduleIni.Read(romName . "|Settings", "bezelRightOffset","0",,1)
forceRegion := moduleIni.Read(romName, "ForceRegion",,,1)
busWait := moduleIni.Read(romName, "BusWait","false",,1)
usBios := GetFullName(usBios)	; convert relative to absolute path
euBios := GetFullName(euBios)
jpBios := GetFullName(jpBios)
worldBios := GetFullName(worldBios)

BezelStart("FixResMode")
hideEmuObj := Object(emuDecodingWindow,0,emuOpenROMWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

If StringUtils.InStr(systemName, "Saturn")
	If !StringUtils.Contains(romExtension,"\.ccd|\.mds|\.cue|\.iso|\.cdi|\.nrg")
		ScriptError("For Sega Saturn, SSF only supports extensions ""mds|cue|iso|cdi|nrg"" and you are trying to use """ . romExtension . """")

SSFSpecialINI := new File(emuPath . "\Configurations\" . romName . ".ini")
SSFDefaultINI := new File(emuPath . "\Configurations\Default.ini")
If SSFSpecialINI.Exist()
	SSFSpecialINI.Copy(emuPath . "\SSF.ini", 1)
Else If SSFDefaultINI.Exist()
	SSFDefaultINI.Copy(emuPath . "\SSF.ini", 1)

SSFINI := new IniFile(emuPath . "\SSF.ini")
SSFINI.CheckFile()
mySW := A_ScreenWidth
mySH := A_ScreenHeight

; Now let's update all our keys if they differ in the ini
cliFullscreen := If Fullscreen = "true" ? "1" : "0"
UseBIOS := If UseBIOS = "true" ? "0" : "1"
BilinearFiltering := If BilinearFiltering = "true" ? "1" : "0"
WideScreen := If WideScreen = "true" ? "1" : "0"
Stretch := If Stretch = "true" ? "0" : "1"	; this setting uses 0 for stretch and 1 for not
AutoFieldSkip := If AutoFieldSkip = "true" ? "1" : "0"
EnforceAspectRatioWindow := If EnforceAspectRatioWindow = "true" ? "1" : "0"
EnforceAspectRatioFullscreen := If EnforceAspectRatioFullscreen = "true" ? "1" : "0"
FixedWindowResolution := If FixedWindowResolution = "true" ? "1" : "0"
FixedFullscreenResolution := If FixedFullscreenResolution = "true" ? "1" : "0"
VSynchWaitWindow := If VSynchWaitWindow = "true" ? "1" : "0"
VSynchWaitFullscreen := If VSynchWaitFullscreen = "true" ? "1" : "0"
Scanlines := If Scanlines = "true" ? "1" : "0"
SH2enabled := If SH2enabled = "true" ? "1" : "0"
busWait := If busWait = "true" ? "1" : "0"

If StringUtils.InStr(systemName, "Saturn")
{
	regionName := romName
	If (forceRegion)
		regionName := If forceRegion = "1" ? "(USA)" : (If forceRegion = "2" ? "(Japan)" : (If forceRegion = "3" ? "(Europe)" : "(World)"))	; translating for easier use later

	If StringUtils.Contains(regionName, "\(U\)|\(USA\)|\(Braz")
	{	RLLog.Info("Module - This is an American rom. Setting SSF's settings to this region.")
		Areacode := "4"	; 1 = Japan, 2 = Taiwan/Korea/Philippines. 4 = America/Canada/Brazil, c = Europe/Australia/South Africa
		SaturnBIOS := CheckSaturnBIOS(usBios,"USA")
	} Else If StringUtils.Contains(regionName, "JP|\(J\)|\(Jap")
	{	RLLog.Info("Module - This is a Japanese rom. Setting SSF's settings to this region.")
		Areacode := "1"
		SaturnBIOS := CheckSaturnBIOS(jpBios,"Japanese")
	} Else If StringUtils.Contains(regionName, "\(Eu\)|\(Eur|\(German")
	{	RLLog.Info("Module - This is a European rom. Setting SSF's settings to this region.")
		Areacode := "c"
		SaturnBIOS := CheckSaturnBIOS(euBios,"Europe")
	} Else If StringUtils.Contains(regionName, "\(Kore")
	{	RLLog.Info("Module - This is a Korean rom. Setting SSF's settings to this region.")
		Areacode := "2"
		SaturnBIOS := CheckSaturnBIOS(jpBios,"Japanese")	; don't see a bios for this region, assuming it uses japanese one
	} Else If StringUtils.Contains(regionName, "\(World")
	{	RLLog.Info("Module - This is a rom without region. Setting SSF's settings to this region.")
		Areacode := "4"
		SaturnBIOS := CheckSaturnBIOS(worldBios,"World")
	} Else
	{	RLLog.Warning("Module - This rom has an UNKNOWN region. Reverting to use your default region. If you get a black screen, please rename your rom to add a proper (Region) tag.")
		Areacode := If defaultRegion = "1" ? "4" : If defaultRegion = "2" ? "1" : "c"
		SaturnBIOS := If defaultRegion = "1" ? usBios : If defaultRegion = "2" ? jpBios : euBios
	}
	; CheckFile(SaturnBIOS)

	DataCartridgeFile := new File(romPath . "\" . romName . ".rom")
	If DataCartridgeFile.Exist() {		; Only 2 known games need this, Ultraman - Hikari no Kyojin Densetsu (Japan) and King of Fighters '95, The (Europe).
		RLLog.Info("Module - This game requires a data cart in order to play. Trying to mount the cart: """ . DataCartridgeFile.FileFullPath . """")
		If !DataCartridgeFile.Exist()
			ScriptError("Could not locate the Data Cart for this game. Please make sure one exists inside the archive of this game or in the folder this game resides and it is called: """ . romName . ".rom""")
		CartridgeID := "21"
		DataCartridgeEnable := "1"
	} Else {	; all other games
		RLLog.Info("Module - This game does not require a data cart in order to play.")
		CartridgeID := "5c"
		DataCartridgeEnable := "0"
		DataCartridge := ""
	}
}

If (legacyMode = "false")
{
	; Compare existing settings and if different then desired, write them to the SSF.ini
	; Note: On older emulator versions NoBIOS is under Program3 instead of Program4 so we set it on both
	SSFINI.Write("""" . cliFullscreen . """", "Screen", "FullSize", 1)
	SSFINI.Write("""" . BilinearFiltering . """", "Screen", "BilinearFiltering", 1)
	SSFINI.Write("""" . WideScreen . """", "Screen", "WideScreen", 1)
	SSFINI.Write("""" . Stretch . """", "Screen", "StretchScreen", 1)
	SSFINI.Write("""" . AutoFieldSkip . """", "Screen", "AutoFieldSkip", 1)
	SSFINI.Write("""" . EnforceAspectRatioWindow . """", "Screen", "EnforceAspectRatioWindow", 1)
	SSFINI.Write("""" . EnforceAspectRatioFullscreen . """", "Screen", "EnforceAspectRatioFullscreen", 1)
	SSFINI.Write("""" . FixedWindowResolution . """", "Screen", "FixedWindowResolution", 1)
	SSFINI.Write("""" . FixedFullscreenResolution . """", "Screen", "FixedFullscreenResolution", 1)
	SSFINI.Write("""" . VSynchWaitWindow . """", "Screen", "VSynchWaitWindow", 1)
	SSFINI.Write("""" . VSynchWaitFullscreen . """", "Screen", "VSynchWaitFullscreen", 1)
	SSFINI.Write("""" . Scanlines . """", "Screen", "Scanline", 1)
	SSFINI.Write("""" . ScanlineRatio . """", "Screen", "ScanlineRatio", 1)
	SSFINI.Write("""" . SaturnBIOS . """", "Peripheral", "SaturnBIOS", 1)
	SSFINI.Write("""" . CDDrive . """", "Peripheral", "CDDrive", 1)
	SSFINI.Write("""" . Areacode . """", "Peripheral", "Areacode", 1)
	SSFINI.Write("""" . CartridgeID . """", "Peripheral", "CartridgeID", 1)
	SSFINI.Write("""" . DataCartridgeEnable . """", "Peripheral", "DataCartridgeEnable", 1)
	SSFINI.Write("""" . DataCartridge . """", "Peripheral", "DataCartridge", 1)
	SSFINI.Write("""" . SH2enabled . """", "Program3", "SH2Cache", 1)
	SSFINI.Write("""" . 0 . """", "Program3", "EnableInstructionCache", 1)
	SSFINI.Write("""" . busWait . """", "Program3", "SCUDMADelayInterrupt", 1)
	SSFINI.Write("""" . busWait . """", "Program3", "BusWait", 1)
	SSFINI.Write("""" . UseBIOS . """", "Program3", "NoBIOS", 1)
	SSFINI.Write("""" . UseBIOS . """", "Program4", "NoBIOS", 1)
	SSFINI.Write("""" . cliFullscreen . """", "Other", "ScreenMode", 1)
	SSFINI.Write("""" . WindowSize . """", "Other", "WindowSize", 1)
}

If StringUtils.InStr(systemName, "Saturn") {
	;Delete cached settings if needed
	If (deleteCachedSettings = "true")
	{
		If (romExtension = ".iso" || romExtension = ".bin")
		{
			imagetoCheck := romPath . "\" . romName . romExtension
		}
		Else If (romExtension = ".mds")
		{
			imagetoCheck := romPath . "\" . romName . ".mdf"
		}
		Else If (romExtension = ".ccd")
		{
			imagetoCheck := romPath . "\" . romName . ".img"
		}
		Else If (romExtension = ".cue") {
			datatrack := RLObject.listCUEFiles(romPath . "\" . romName . romExtension,1)
			imagetoCheck := romPath . "\" . datatrack
		}
		If (imagetoCheck) {
			gameID := RLObject.readFileData(imagetoCheck,48,10,"UTF8")
			gameCode := RLObject.readFileData(imagetoCheck,112,16,"UTF8")
			gameID := gameID ;To trim leading spaces
			gameCode := gameCode
			CachedSettingsFile := new File(emuPath . "\Setting\Saturn\" . gameID . "_" . gameCode . ".ini")
			RLLog.Info("Deleting cached settings file at '" . CachedSettingsFile.FileFullPath . "'")
			If CachedSettingsFile.Exist()
				CachedSettingsFile.Delete()
		}
	}

	;Setup Virtual Drive
	If (vdEnabled = "false")
		ScriptError("Virtual Drive must be enabled to use this SSF module")
	usedVD := 1
	VirtualDrive("mount",romPath . "\" . romName . romExtension)
}

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run()
; primaryExe.Run((If Fullscreen = "true" ? ("Hide" ): ("")))	; Worked in R3, not in R4

If (systemName = "Sega ST-V")
{	KeyUtils.Send("{SHIFTDOWN}") ; this tells SSF we want to boot in ST-V mode
	errLvl := emuOpenROMWindow.Wait(8) ; times out after 8 Seconds
	If errLvl
	{	KeyUtils.Send("{SHIFTUP}")
		emuPrimaryWindow.Close()
		ScriptError("Module timed out waiting for Select ROM file window. This probably means you did not set your ST-V bios or have an invalid ST-V bios file.")
	}
	If !emuOpenROMWindow.Active()
		emuOpenROMWindow.Activate()	; WinActivate, Select ROM file
	emuOpenROMWindow.WaitActive()
	KeyUtils.Send("{SHIFTUP}")
	OpenROM(emuOpenROMWindow.WinTitle.GetWindowTitle(), romPath . "\" . romName . romExtension)
	emuDecodingWindow.Wait()
}

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
emuPrimaryWindow.PID := primaryExe.PID	; Set the emu's Primary Window PID to that returned from the running process
emuPrimaryWindow.Get("ID")	; store the hwnd ID in the object

If (bezelEnabled = "true")
{	timeout := A_TickCount
	Loop
	{
		TimerUtils.Sleep(100,0)
		emuPrimaryWindow.GetPos(,,,SSFHeight)
		If (SSFHeight > 400) {
			RLLog.Info("Module - SSF loaded")
			Break
		}
		If (timeout < A_TickCount - 5000) {
			RLLog.Warning("Module - Timed out waiting for SSF Height")
			Break
		}
	}
	BezelDraw()
} Else
	TimerUtils.Sleep(1000) ; SSF flashes in real fast before going fullscreen if this is not here

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

; WinMove,SSF,,0,0 ; uncomment me if you turned off fullscreen mode and cannot see the emu, but hear it in the background

primaryExe.Process("WaitClose")

If usedVD
	VirtualDrive("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	disableActivateBlackScreen := "true"
	If (Fullscreen = "true") ; only have to take the emu out of fullscreen we are using it
	{		; SSF cannot swap discs in fullscreen mode, so we have to go windowed first, swap, and restore fullscreen
		RLLog.Error("test")
		emuPrimaryWindow.GetPos(,,ssfW,ssfH)
		KeyUtils.SetKeyDelay(,10)	; change only pressDuration
		KeyUtils.Send("!{Enter}")
		emuPrimaryWindow.Set("Transparent", 0)
		If (mySW != ssfW || mySH != ssfH) { ; if our screen is not the same size as SSF uses for it's fullscreen, detect when it changes
			While % ssfH = ssfHn
			{	emuPrimaryWindow.GetPos(,,,ssfHn)
				TimerUtils.Sleep(100)
			}
		} Else ; if our screen is the same size as SSF uses for it's fullscreen, use a sleep instead
			TimerUtils.Sleep(3000) ; increase me if MG GUI is showing tiny instead of the full screen size
		tempgui()
	}
Return

MultiGame:
	emuPrimaryWindow.MenuSelectItem("Hardware","CD Open")
	VirtualDrive("unmount")
	TimerUtils.Sleep(200)	; just in case script moves too fast for DT
	VirtualDrive("mount",selectedRom)
	emuPrimaryWindow.MenuSelectItem("Hardware","CD Close")
	If (Fullscreen = "true")
	{
		Loop { ; looping until SSF is done loading the new disc
			TimerUtils.Sleep(200)
			winTitle := emuPrimaryWindow.GetTitle(0)	; do not store title in object
			winTextSplit := StringUtils.Split(winTitle, A_Space . ":")
			; ToolTip, %A_Index%`nT10=%T10%,0,0
			If !oldT10	; get the current T10 as soon as it exists and store it
				oldT10 := winTextSplit[10]
			If (winTextSplit[10] > oldT10)	; If T10 starts incrementing, we know SSF has a game loaded and can continue the script
				Break
		}
		emuPrimaryWindow.Activate()
		KeyUtils.SetKeyDelay(,10)	; change only pressDuration
		KeyUtils.Send("!{Enter}")
		TimerUtils.Sleep(500)
		Gui, 69: Destroy
		emuPrimaryWindow.Set("Transparent", 255)
		emuPrimaryWindow.Set("Transparent", "Off")
	}
Return

RestoreEmu:
	emuPrimaryWindow.Activate()
	If (Fullscreen = "true")
	{
		TimerUtils.Sleep(500)
		KeyUtils.SetKeyDelay(,100)	; change only pressDuration
		KeyUtils.Send("!{Enter}")
	}
Return

BezelLabel:
	disableHideToggleMenuScreen := "true"
Return

CheckSaturnBIOS(biosFile,region){
	bFile := new File(biosFile)
	If !bFile.Exist()
		ScriptError("This game requires a path to the " . region . " bios in the module settings in RocketLauncherUI. Make sure you set the bios paths for all the games regions you have in your collection.")
	Else
		Return biosFile
}

tempgui(){
	Gui, 69:Color, 000000 
	Gui, 69:-Caption +ToolWindow 
	Gui, 69:Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, BlackScreen
}

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
