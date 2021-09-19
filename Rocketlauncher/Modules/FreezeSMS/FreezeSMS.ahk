MEmu := "FreezeSMS"
MEmuV := "v4.6"
MURL := ["http://freezesms.emuunlim.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "179E6DD8"
iCRC := "1E716C97"
MID := "635115863426031003"
MSystem := ["ColecoVision","Nintendo Entertainment System","Sega Game Gear","Sega Game Gear","Sega Master System","Sega SG-1000"]
;----------------------------------------------------------------------------
; Notes:
; FreezeSMS stores its config in the registry @ HKEY_CURRENT_USER\Software\Freeze software\FreezeSMS
; Emu will probably not work in fullscreen mode (it cannot initialize directX on modern computers because it requires a very old directX).
; To use this emu, turn on bezel mode.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("FreezeSMS","FreezeSMS"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

BezelStart()

; Setting Fullscreen setting in registry if it doesn't match what user wants
currentFullScreen := Registry.Read("HKCU","Software\Freeze software\FreezeSMS\Video","FullScreen")
If (fullscreen != "true" And currentFullscreen = 1)
	Registry.Write("REG_DWORD","HKCU","Software\Freeze software\FreezeSMS\Video","Fullscreen",0)
Else If (fullscreen = "true" And currentFullscreen = 0)
	Registry.Write("REG_DWORD","HKCU","Software\Freeze software\FreezeSMS\Video","Fullscreen",1)

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

CoreExeFile := new File(emuPath . "\core.exe")
CoreDatFile := new File(emuPath . "\core.dat")
If !CoreExeFile.Exist()
{	
	RLLog.Warning("Module - core.exe not found, attempting to copy core.dat to core.exe")
	If CoreDatFile.Exist()
		errLvl := CoreDatFile.Copy(CoreExeFile)
		If errLvl
			ScriptError("There was a problem renaming ""core.dat"" to ""core.exe"" in the emuPath. There might be a permission issue. Please do this manually")
	Else
		ScriptError("Could not locate ""core.dat"" in your emuPath. Please make sure it exists and rename it to ""core.exe"" so RocketLauncher can launch " . MEmu)
}

If StringUtils.Contains(StringUtils.Left(romPath,2),"\\\\")
	ScriptError(MEmu . " does not support network paths. Please use 7z support to extract to a local temp folder or store your roms in a local folder.")
If !StringUtils.Contains(romExtension,"\.zip|\.col|\.gg|\.nes|\.sg|\.sms")
	ScriptError(MEmu . " only supports uncompressed or zip compressed roms. Please enable 7z support in RocketLauncherUI to use this module/emu.")
If (executable = "FreezeSMS.exe")
	ScriptError("FreezeSMS requires core.exe to be set as your executable, not FreezeSMS.exe. Rename core.dat to core.exe.")

HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(A_Space . romPath . "\" . romName . romExtension)	; rompath and name must not be in quotes otherwise emu errors with "system not supported"

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

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
