MEmu := "Demul"
MEmuV := "v0.5.8.2"
MURL := ["http://demul.emulation64.com/"]
MAuthor := ["djvj"]
MVersion := "2.1.7"
MCRC := "CE5A6607"
iCRC := "8615E590"
MID := "635211874656892855"
MSystem := ["Gaelco","Gaelco 3D","Sammy Atomiswave","Sega Dreamcast","Sega Hikaru","Sega Naomi","Sega Naomi 2"]
;----------------------------------------------------------------------------
; Notes:
; Required - control and nvram files setup for each game/control type
; Required - moduleName ini example can be found on GIT in the Demul module folder
; moduleName ini must be placed in same folder as this module if you use the provided example, just be sure to rename it to just Demul.ini first so it matches the module's name
; GDI images must match mame zip names and be extracted and have a .dat extension
; Rom_Extension should include 7z|zip|gdi|cue|cdi|chd|mds|ccd|nrg
; Module will automatically set your rom path for you on first launch
;
; Make sure the awbios, dc, hikaru, naomi, naomi2, saturn.zip bios archives are in any of your rom paths as they are needed to play all the games.
; Set your Video Plugin to gpuDX11 and set your desired resolution there
; In case your control codes do not match mine, set your desired control type in demul, then open the demul.ini and find section PORTB and look for the device key. Use this number instead of the one I provided
; gpuDX10 and gpuDX11 are the only supported plugins. You can define what plugin you want to use for each game in the module settings in RocketLauncherUI
; Read the tooltip for the Fullscreen module setting in RocketLauncherUI on how to control windowed fullscreen, true fullscreen, or windowed mode
; Windowed fullscreen will take effect the 2nd time you run the emu. It has to calculate your resolution on first run.
;
; Controls:
; Start a game of each control type (look in the RocketLauncherUI's module settings for these types, they all have their own tabs) and configure your controls to play the game. After configuring your controls manually in Demul, open padDemul.ini and Copy/paste the JAMMA0_0 and JAMMA0_1 (for naomi) or the ATOMISWAVE0_0 and ATOMISWAVE0_1 (for atomiswave) into RocketLauncherUI's module settings for each controls tab (standard, sfstyle, etc).
; Each pair of control tabs designates another real arcade control schema for a grouping of games. Demul does not handle this like MAME, so the module does instead.
;
; Gaelco:
; There is no known way to launch the desired Gaelco rom from CLI. You will always be presented with the rom selection window on launch.
;
; Sega Hikaru:
; Windowed Fullscreen doesn't seem to work as demul does not allow stretching of its window
;
; Troubleshooting:
; For some reason demul's ini files can get corrupted and ahk can't read/write to them correctly.
; If your ini keys are not being read or not writing to their existing keys in the demul inis, create a new file and copy/paste everything from the old ini into the new one and save.
; If you use Fade_Out, the module will disable it. Demul crashes when Fade tries to draw on top of it in windowed and fullscreen modes.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
ExtraFixedResBezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"window"))	; instantiate primary emulator window object
emuLCD0Window := new Window(new WindowTitle("LCD 0","LCD 0"))

; This object controls how the module reacts to different systems. Demul can play a few systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Gaelco","gaelco","Gaelco 3D","gaelco","Sammy Atomiswave","atomiswave","Sega Dreamcast","dc","Sega Hikaru","hikaru","Sega Naomi","naomi","Sega Naomi 2","naomi2")
ident := mType[systemName]	; search object for the systemName identifier Demul uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Demul module: " . moduleName)

DemuleIni := new IniFile(emuPath . "\Demul.ini")
PadIni := new IniFile(emuPath . "\padDemul.ini")
DemuleIni.CheckFile("Could not find Demul's ini. Please run Demul manually first and each of it's settings sections so the appropriate inis are created for you: " . DemuleIni.FileFullPath)
PadIni.CheckFile("Could not find Demul's control ini. Please run Demul manually first and set up your controls so this file is created for you: " . PadIni.FileFullPath)

demuleIniEncoding := RLObject.getFileEncoding(DemuleIni.FileFullPath)
If demuleIniEncoding {
	If (demuleIniEncoding = "ERROR")
		RLLog.Warning("Module - Demul.ini set to Read-only and BOM cannot be changed. Check the DLL log for further details: " . DemuleIni.FileFullPath)
	Else {
		RLLog.Warning("Module - Recreating " . DemuleIni.FileFullPath . " as ANSI because UTF-8 format cannot be read")
		If RLObject.removeBOM(DemuleIni.FileFullPath)
			RLLog.Info("Module - Successfully converted " . DemuleIni.FileFullPath . " to ANSI")
		Else
			RLLog.Error("Module - Failed to convert " . DemuleIni.FileFullPath . " to ANSI")
	}
}

maxHideTaskbar := moduleIni.Read("Settings", "MaxHideTaskbar", "true",,1)
controllerCode := moduleIni.Read("Settings", "ControllerCode", "16777216",,1)
mouseCode := moduleIni.Read("Settings", "MouseCode", "131072",,1)
keyboardCode := moduleIni.Read("Settings", "KeyboardCode", "1073741824",,1)
lightgunCode := moduleIni.Read("Settings", "LightgunCode", "-2147483648",,1)
hideDemulGUI := moduleIni.Read("Settings", "HideDemulGUI", "true",,1)
PerGameMemoryCards := moduleIni.Read("Settings", "PerGameMemoryCards", "true",,1)
memCardPath := moduleIni.Read("Settings", "MemCardPath", emuPath . "\memsaves",,1)
memCardPath := AbsoluteFromRelative(emuPath, memCardPath)

fullscreen := moduleIni.Read(romName . "|Settings", "Fullscreen", "windowedfullscreen",,1)
plugin := moduleIni.Read(romName . "|Settings", "Plugin", "gpuDX11",,1)
shaderUsePass1 := moduleIni.Read(romName . "|Settings", "ShaderUsePass1", "false",,1)
shaderUsePass2 := moduleIni.Read(romName . "|Settings", "ShaderUsePass2", "false",,1)
shaderNamePass1 := moduleIni.Read(romName . "|Settings", "ShaderNamePass1",,,1)
shaderNamePass2 := moduleIni.Read(romName . "|Settings", "ShaderNamePass2",,,1)
listSorting := moduleIni.Read(romName . "|Settings", "ListSorting", "true",,1)
OpaqueMod := moduleIni.Read(romName . "|Settings", "OModifier", "true",,1)
TransMod := moduleIni.Read(romName . "|Settings", "TModifier", "true",,1)
internalResolutionScale := moduleIni.Read(romName . "|Settings", "InternalResolutionScale", "1",,1)
videomode := moduleIni.Read(romName . "|Settings", "VideoMode", "0",,1)
demulShooterEnabled := moduleIni.Read(romName . "|Settings", "DemulShooterEnabled", "false",,1)

displayVMU := moduleIni.Read("Settings", "DisplayVMU", "true",,1)
VMUPos := moduleIni.Read("Settings", "VMUPos", "topRight",,1) ; topRight, topCenter, topLeft, leftCenter, bottomLeft, bottomCenter, bottomRight, rightCenter 
VMUHideKey := moduleIni.Read("Settings", "VMUHideKey","F10",,1)

Bios := moduleIni.Read(romName, "Bios",,,1)
LoadDecrypted := moduleIni.Read(romName, "LoadDecrypted",,,1)	; not currently supported

; Read all the control values
controls := moduleIni.Read(romname, "Controls", "standard",,1)	; have to read this first so the below ini reads work
push1_0 := moduleIni.Read(controls . "_JAMMA0_0", "push1",,,1)
push2_0 := moduleIni.Read(controls . "_JAMMA0_0", "push2",,,1)
push3_0 := moduleIni.Read(controls . "_JAMMA0_0", "push3",,,1)
push4_0 := moduleIni.Read(controls . "_JAMMA0_0", "push4",,,1)
push5_0 := moduleIni.Read(controls . "_JAMMA0_0", "push5",,,1)
push6_0 := moduleIni.Read(controls . "_JAMMA0_0", "push6",,,1)
push7_0 := moduleIni.Read(controls . "_JAMMA0_0", "push7",,,1)
push8_0 := moduleIni.Read(controls . "_JAMMA0_0", "push8",,,1)
service_0 := moduleIni.Read(controls . "_JAMMA0_0", "SERVICE",,,1)
start_0 := moduleIni.Read(controls . "_JAMMA0_0", "START",,,1)
coin_0 := moduleIni.Read(controls . "_JAMMA0_0", "COIN",,,1)
digitalup_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALUP",,,1)
digitaldown_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALDOWN",,,1)
digitalleft_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALLEFT",,,1)
digitalright_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALRIGHT",,,1)
analogup_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGUP",,,1)
analogdown_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGDOWN",,,1)
analogleft_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGLEFT",,,1)
analogright_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGRIGHT",,,1)
analogup2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGUP2",,,1)
analogdown2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGDOWN2",,,1)
analogleft2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGLEFT2",,,1)
analogright2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGRIGHT2",,,1)
push1_1 := moduleIni.Read(controls . "_JAMMA0_1", "push1",,,1)
push2_1 := moduleIni.Read(controls . "_JAMMA0_1", "push2",,,1)
push3_1 := moduleIni.Read(controls . "_JAMMA0_1", "push3",,,1)
push4_1 := moduleIni.Read(controls . "_JAMMA0_1", "push4",,,1)
push5_1 := moduleIni.Read(controls . "_JAMMA0_1", "push5",,,1)
push6_1 := moduleIni.Read(controls . "_JAMMA0_1", "push6",,,1)
push7_1 := moduleIni.Read(controls . "_JAMMA0_1", "push7",,,1)
push8_1 := moduleIni.Read(controls . "_JAMMA0_1", "push8",,,1)
service_1 := moduleIni.Read(controls . "_JAMMA0_1", "SERVICE",,,1)
start_1 := moduleIni.Read(controls . "_JAMMA0_1", "START",,,1)
coin_1 := moduleIni.Read(controls . "_JAMMA0_1", "COIN",,,1)
digitalup_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALUP",,,1)
digitaldown_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALDOWN",,,1)
digitalleft_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALLEFT",,,1)
digitalright_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALRIGHT",,,1)
analogup_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGUP",,,1)
analogdown_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGDOWN",,,1)
analogleft_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGLEFT",,,1)
analogright_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGRIGHT",,,1)
analogup2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGUP2",,,1)
analogdown2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGDOWN2",,,1)
analogleft2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGLEFT2",,,1)
analogright2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGRIGHT2",,,1)

If (InStr(systemName, "Hikaru") && plugin != "gpuDX11")
	plugin := "gpuDX11"		; Hikaru does not work with gpuDX10 gpu plugin, setting it dumps an error

; Verify user set desired gpu plugin name correctly
If (plugin != "gpuDX11" && plugin != "gpuDX10" && plugin != "")
	ScriptError(plugin . " is not a supported gpu plugin.`nLeave the plugin blank to use the default ""gpuDX11"".`nValid options are gpuDX11 or gpuDX10.")

; Read and write videomode value for cable type
rvideomode := DemuleIni.Read("main", "videomode")
RLLog.Info("Module - Demul is reading the config with videomode = " . rvideomode)
DemuleIni.Write(videomode, "main", "videomode")
RLLog.Info("Module - Demul is updating the config with videomode = " . videomode)
;ExitApp

; Handle Demul's rom paths so the user doesn't have to
romPathCount := DemuleIni.Read("files", "romsPathsCount")
RLLog.Info("Module - Demul is configured with " . romPathCount . " rom path(s). Scanning these for a romPath to this rom.")
Loop, %romPathCount%
{	demulRomPath := A_Index - 1	; rompaths in demul start with 0
	path%A_Index% := DemuleIni.Read("files", "roms" . demulRomPath)
	RLLog.Info("Module - Path" . demulRomPath . ": " . path%A_Index%)
	; msgbox % path%A_Index%
	If (path%A_Index% = romPath . "\")	; demul tacks on the backslash at the end
	{	romPathFound := 1	; flag that demul has this romPath in its config and no need to add it
		RLLog.Info("Module - Stopping search because Demul is already configured with the correct romPath to this rom: " . path%A_Index%)
		Break	; stop looking for a correct romPath
	}
}
If !romPathFound	; if demul doesn't have the romPath in its ini, add it
{	RLLog.Warning("Module - Demul does not have this romPath in Demul.ini, adding it for you.")
	nextPath := romPathCount + 1	; add 1 to the romPathCount and write that to the ini
	DemuleIni.Write(nextPath, "files", "romsPathsCount")
	DemuleIni.Write(romPath , "\", "files", "roms" . romPathCount)	; write the rompath to the ini
}

BezelStart("FixResMode")

; Force Fade_Out to disabled as it causes demul to not close properly
fadeOut := "false"
RLLog.Warning("Module - Turning off Fade_Out because it doesn't let Demul exit properly.")

; check for the specified gpu plugin
GpuIni := new IniFile(emuPath . "\" . plugin . ".ini")
GpuIni.CheckFile("Please run Demul manually first and select the " . plugin . " gpu plugin so it creates this file for you: " . GpuIni.FileFullPath)

demulFileEncoding := RLObject.getFileEncoding(GpuIni.FileFullPath)
If demulFileEncoding {
	If (demulFileEncoding = "ERROR")
		RLLog.Warning("Module - GPU ini set to Read-only and BOM cannot be changed. Check the DLL log for further details: " . GpuIni.FileFullPath)
	Else {
		RLLog.Info("Module - Recreating " . GpuIni.FileFullPath . " as ANSI because UTF-8 format cannot be read")
		If RLObject.removeBOM(GpuIni.FileFullPath)
			RLLog.Info("Module - Successfully converted " . GpuIni.FileFullPath . " to ANSI")
		Else
			RLLog.Error("Module - Failed to convert " . GpuIni.FileFullPath . " to ANSI")
	}
}

; This updates the DX11gpu ini file to turn List Sorting on or off. Depending on the games, turning this on for some games may remedy missing graphics, having it off on other games may fix corrupted graphics. Untill they improve the DX11gpu, this is the best it's gonna get.
If (ListSorting = "true")
	GpuIni.Write(0, "main", "AutoSort")
Else
	GpuIni.Write(1, "main", "AutoSort")
	
; This will set the Opaque or Trans modifier for each game
If (OpaqueMod = "true")
	GpuIni.Write(0, "main", "OModifier")
Else
	GpuIni.Write(1, "main", "OModifier")

If (TransMod = "true")
	GpuIni.Write(0, "main", "TModifier")
Else
	GpuIni.Write(1, "main", "TModifier")

; This updates the DX10gpu or DX11gpu ini file to the scale you want to use for this game
GpuIni.Write(InternalResolutionScale, "main", "scaling")

; This updates the demul.ini with your gpu plugin choice for the selected rom
DemuleIni.Write(plugin . ".dll", "plugins", "gpu")

; This updates the demul.ini with your VMU display choice
VMUscreendisable := If (displayVMU="true") ? "false" : "true"
DemuleIni.Write(VMUscreendisable, "main", "VMUscreendisable")
 
 ; Shader Effects
Loop, 2 {
	shaderUsePass%A_Index% := If (ShaderUsePass%A_Index% != "" and ShaderUsePass%A_Index% != "ERROR" ? (ShaderUsePass%A_Index%) : (GlobalShaderUsePass%A_Index%))	; determine what shaderUsePass to use
	currentusePass%A_Index% := GpuIni.Read("shaders", "usePass" . A_Index)
	If (shaderUsePass%A_Index% = "true")
	{
		shaderNamePass%A_Index% := If (ShaderNamePass%A_Index% != "" and ShaderNamePass%A_Index% != "ERROR" ? (ShaderNamePass%A_Index%) : (GlobalShaderNamePass%A_Index%))	; determine what shaderNamePass to use
		If !StringUtils.Contains(shaderNamePass%A_Index%,"FXAA|HDR-TV|SCANLINES|CARTOON|RGB DOT\(MICRO\)|RGB DOT\(TINY\)|BLUR")
			ScriptError(shaderNamePass%A_Index% . " is not a valid choice for a shader. Your options are FXAA, HDR-TV, SCANLINES, CARTOON, RGB DOT(MICRO), RGB DOT(TINY), or BLUR.")
		If (currentusePass%A_Index% = 0)
			GpuIni.Write(1, "shaders", "usePass" . A_Index)	; turn shader on in gpuDX11 ini
		GpuIni.Write(shaderNamePass%A_Index%, "shaders", "shaderPass" . A_Index)	; update gpuDX11 ini with the shader name to use
	}Else If (shaderUsePass%A_Index% != "true" and currentusePass%A_Index% = 1)
		GpuIni.Write(0, "shaders", "usePass" . A_Index)	; turn shader off in gpuDX11 ini
}

If (ident = "dc")
{
	7z(romPath, romName, romExtension, sevenZExtractPath)
	If (romExtension = ".cdi" || romExtension = ".mds" || romExtension = ".ccd" || romExtension = ".nrg" || romExtension = ".gdi" || romExtension = ".cue") {
		GdrImageIni := new IniFile(emuPath . "\gdrImage.ini")
		If !GdrImageIni.Exist() {
			GdrImageIni.Append(defaultIni)		; Create a default gdrImage.ini in your emu folder if one does not exist already.
			; GdrImageIni.Delete(gdrImageFile)	; don't know why this was in the old module, no point in deleting the file I just made
		}
		TimerUtils.Sleep(500)
		DemuleIni.Write("gdrImage.dll", "plugins", "gdr")
		GdrImageIni.Write("false", "Main", "openDialog")
		GdrImageIni.Write(romPath . "\" . romName . romExtension, "Main", "imagefilename")
	} Else If (romExtension = ".chd")
	{
		GdrCHDIni := new IniFile(emuPath . "\gdrCHD.ini")
		If !GdrCHDIni.Exist() {
			GdrCHDIni.Append(defaultIni)		; Create a default gdrCHD.ini in your emu folder if one does not exist already.
			; GdrCHDIni.Delete(gdrCHDFile)	; don't know why this was in the old module, no point in deleting the file I just made
		}
		TimerUtils.Sleep(500)
		GdrCHDIni.Write("false", "Main", "openDialog")
		DemuleIni.Write("gdrCHD.dll", "plugins", "gdr")
		GdrCHDIni.Write(romPath . "\" . romName . romExtension, "Main", "imagefilename")
	} Else
		ScriptError(romExtension . " is not a supported file type for this " . moduleName . " module.")

	DemuleIni.Write(1, "main", "region")	; Set BIOS to Auto Region
} Else {	; all other systems, Naomi and Atomiswave
	; This updates the demul.ini with your Bios choice for the selected rom
	If (Bios != "" && Bios != "ERROR") {
		Bios := StringUtils.RegExReplace(Bios,"\s.*")	; Cleans off the added text from the key's value so only the number is left
		DemuleIni.Write("false", "main", "naomiBiosAuto")	; turning auto bios off so we can use a specific one instead
		DemuleIni.Write(Bios, "main", "naomiBios")	; setting specific bios user has set from the moduleName ini
	} Else
		DemuleIni.Write("true", "main", "naomiBiosAuto")	; turning auto bios on if user did not specify a specific one
}

; This section writes your custom keys to the padDemul.ini. Naomi games had many control panel layouts. The only way we can accomodate these differing controls, is to keep track of them all and write them to the ini at the launch of each game.
; First we check if the last controls used are the same as the game we want to play, so we don't waste time updating the ini if it is not necessary. For example playing 2 sfstyle type games in a row, we wouldn't need to write to the ini.

; This section tells demul what arcade control type should be connected to the game. Options are standard (aka controller), mouse, lightgun, or keyboard
If (controls = "lightgun" || controls = "mouse") {
	RLLog.Info("Module - This game uses a Mouse or Lightgun control type.")
	DemuleIni.Write(MouseCode, "PORTB", "device")
} Else If (controls = "keyboard") {
	RLLog.Info("Module - This game uses a Keyboard control type.")
	DemuleIni.Write(KeyboardCode, "PORTB", "device")
} Else { ; accounts for all other control types
	RLLog.Info("Module - This game uses a standard (controller) control type.")
	DemuleIni.Write(ControllerCode, "PORTB", "device")
}

WriteControls(0,push1_0,push2_0,push3_0,push4_0,push5_0,push6_0,push7_0,push8_0,SERVICE_0,START_0,COIN_0,DIGITALUP_0,DIGITALDOWN_0,DIGITALLEFT_0,DIGITALRIGHT_0,ANALOGUP_0,ANALOGDOWN_0,ANALOGLEFT_0,ANALOGRIGHT_0,ANALOGUP2_0,ANALOGDOWN2_0,ANALOGLEFT2_0,ANALOGRIGHT2_0)

WriteControls(1,push1_1,push2_1,push3_1,push4_1,push5_1,push6_1,push7_1,push8_1,SERVICE_1,START_1,COIN_1,DIGITALUP_1,DIGITALDOWN_1,DIGITALLEFT_1,DIGITALRIGHT_1,ANALOGUP_1,ANALOGDOWN_1,ANALOGLEFT_1,ANALOGRIGHT_1,ANALOGUP2_1,ANALOGDOWN2_1,ANALOGLEFT2_1,ANALOGRIGHT2_1)

RLLog.Info("Module - Wrote " . controls . " controls to padDemul.ini.")

; This will check the save game files and create per game ones if enabled.
If (PerGameMemoryCards = "true")
{
	MemCardFolder := new Folder(memCardPath)
	DefaultMemCard := new File(memCardPath . "\default_vms.bin")	; defining default blank VMU file
	If !DefaultMemCard.Exist("Folder")
		DefaultMemCard.CreateDir()	; create memcard folder if it doesn't exist
	If defaultMemCard.Exist()
	{
		RLLog.Info("VMU - Default VMU file location - " . defaultMemCard.FileFullPath)
		Loop, 4
		{
			outerLoop := A_Index
			If (A_Index = 1)
				contrPort := "A"
			Else If (A_Index = 2)
				contrPort := "B"
			Else If (A_Index = 3)
				contrPort := "C"
			Else If (A_Index = 4)
				contrPort := "D"
			controllerPort%contrPort% := DemuleIni.Read("PORT" . contrPort, "device")
			RLLog.Info("VMU - Config for controller PORT" . contrPort . " = " . controllerPort%contrPort%)
			If (controllerPort%contrPort% = -1)
				Continue
			Loop, 2
			{
				SubCount := A_Index - 1
				VMUPort%SubCount% := DemuleIni.Read("PORT" . contrPort, "port" . SubCount)
				RLLog.Info("VMU - Config Plugin VMUPort" . contrPort . SubCount . " for controller PORT" . contrPort . " = " . VMUPort%SubCount%)
				If (VMUPort%SubCount% <> -1)
				{
					VMUPortFile%SubCount% := DemuleIni.Read("VMS", "VMS" . contrPort . SubCount)
					RLLog.Info("VMU - VMUPortFile" . contrPort . SubCount . " controllerVMU" . contrPort .	SubCount . " " . "VMS" . contrPort . SubCount . " = " . VMUPortFile%SubCount%)
					memCardName := If romTable[1,5] ? romTable[1,4] : romName	; defining rom name for multi disc rom
					PerGameVMUBin%A_Index% := new File(memCardPath . "\" . memCardName . "_vms_" . contrPort . SubCount . ".bin")
					RLLog.Info("VMU - PerGameVMUBin = " . PerGameVMUBin%A_Index%.FileFullPath)
					If PerGameVMUBin%A_Index%.Exist()
					{
						RLLog.Info("VMU - PerGameVMU file exists at " . PerGameVMUBin%A_Index%.FileFullPath)
					} Else {
						RLLog.Info("VMU - PerGameVMU file does not exist. So we will create one at " . PerGameVMUBin%A_Index%.FileFullPath)
						DefaultMemCard.Copy(PerGameVMUBin%A_Index%.FileFullPath)
					}
					DemuleIni.Write(PerGameVMUBin%A_Index%.FileFullPath, "VMS", "VMS" . contrPort . SubCount)
					RLLog.Info("VMU - PerGameVMU file written to " . DemuleIni.FileFullPath . " at section VMS to variable VMS" . contrPort . SubCount . " as " . PerGameVMUBin%A_Index%.FileFullPath)
				} Else {
					RLLog.Info("VMU - No VMU Plugged In.")
				}
			}
		}
	} Else {
		RLLog.Info("VMU - No default VMU file at " . DefaultMemCard.FileFullPath)
	}
}

; Setting demul to use true fullscreen if defined in settings.ini, otherwise sets demul to run windowed. This is for gpuDX11 plugin only
If (plugin = "gpuDX11")
	If (fullscreen = "truefullscreen")
		GpuIni.Write(1, "main", "UseFullscreen")
	Else
		GpuIni.Write(0, "main", "UseFullscreen")

If (fullscreen = "windowedfullscreen")
{
	If (maxHideTaskbar = "true") {
		RLLog.Info("Module - Hiding Taskbar and Start Button.")
		MiscUtils.TaskBar("off")
	}
	; Create black background to give the emu the fullscreen look
	RLLog.Info("Module - Creating black background to simulate a fullscreen look.")
	Gui demulGUI: -Caption +ToolWindow
	Gui demulGUI: Color, Black
	Gui demulGUI: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
}

If (ident != "dc" && demulShooterEnabled = "true") {	; If demulshooter is enabled for this game, launch it with relevant options
	DemulShooterExe := New DemulShooter()
	DemulShooterExe.Launch("demul058",romName,"-noresize")
}

TimerUtils.Sleep(250)

;  Construct the CLI for demul and send romName if naomi or atomiswave. Dreamcast needs a full path and romName.
If (LoadDecrypted = "true")		; decrypted naomi rom
	romCLI := "-customrom=" . """" . romPath . "\" . romName . ".bin"""
Else If (ident = "dc")	; dreamcast game
	romCLI := " -image=" . """" . romPath . "\" . romName . romExtension . """"
Else	; standard naomi rom
	romCLI := "-rom=" . romName

hideEmuObj := Object(emuLCD0Window,0,emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run(" -run=" . ident . " " . romCLI, (If hideDemulGUI = "true" ? "min" : ""))	; launching minimized, then restoring later hides the launch completely

TimerUtils.Sleep(1000) ; Need a second for demul to launch, increase if yours takes longer and the emu is NOT appearing and staying minimized. This is required otherwise bezel backgrounds do not appear

DetectHiddenWindows, On
If (hideDemulGUI = "true")
{
	emuPrimaryWindow.Restore()
	emuPrimaryWindow.Activate()
}

RLLog.Info("Module - Waiting for Demul to finish loading game.")
Loop {	; looping until demul is done loading rom and gpu starts showing frames
	TimerUtils.Sleep(200)
	winTitle := emuPrimaryWindow.GetTitle(0)
	winTextSplit := StringUtils.Split(winTitle, A_Space)
	If (winTextSplit[5] = "gpu:" And winTextSplit[6] != "0" And winTextSplit[6] != "1")
		Break
}
RLLog.Info("Module - Demul finished loading game.")

If (StringUtils.Contains(systemName, "Gaelco|Hikaru") && fullscreen = "truefullscreen")
	KeyUtils.Send("!{Enter}")	; Automatic fullscreen seems to be broken in the Gaelco driver, must alt+Enter to get fullscreen

; This is where we calculate and maximize demul's window using our pseudo fullscreen code
If (fullscreen = "windowedfullscreen")
{
	;KeyUtils.Send("{F3}") ; Removes the MenuBar
	emuPrimaryWindow.Maximize() ; this will take effect after you run demul once because we cannot stretch demul's screen while it is running.
	If (plugin = "gpuDX11") {
		GpuIni.Write(appWidthNew, "resolution", "Width")
		GpuIni.Write(appHeightNew, "resolution", "Height")
	} Else {
		GpuIni.Write(appWidthNew, "resolution", "wWidth")
		GpuIni.Write(appHeightNew, "resolution", "wHeight")
	}
}

BezelDraw()

If (displayVMU = "true"){
	VMUWindowID := emuLCD0Window.Get("ID")
	ExtraFixedResBezelDraw(VMUWindowID, "VMU", VMUPos, 144, 96, 8, 8, 28, 8)
	VMUHideKey := xHotKeyVarEdit(VMUHideKey,"VMUHideKey","~","Add")
	xHotKeywrapper(VMUHideKey,"VMUHide")
}

HideEmuEnd()
FadeInExit()
primaryExe.Process("WaitClose")

If (fullscreen = "windowedfullscreen")
{	Gui demulGUI: Destroy
	RLLog.Info("Module - Destroyed black gui background.")
}

If (ident = "dc")
	7zCleanUp()

BezelExit()
ExtraFixedResBezelExit()
FadeOutExit()

If (fullscreen = "windowedfullscreen" && maxHideTaskbar = "true") {
	RLLog.Info("Module - Showing Taskbar and Start Button.")
	MiscUtils.TaskBar("on")
}

ExitModule()


 ; Write new controls to padDemul.ini
WriteControls(player,push1,push2,push3,push4,push5,push6,push7,push8,service,start,coin,digitalup,digitaldown,digitalleft,digitalright,analogup,analogdown,analogleft,analogright,analogup2,analogdown2,analogleft2,analogright2) {
	Global PadIni
	PadIni.Write(push1, "JAMMA0_" . player, "PUSH1")
	PadIni.Write(push2, "JAMMA0_" . player, "PUSH2")
	PadIni.Write(push3, "JAMMA0_" . player, "PUSH3")
	PadIni.Write(push4, "JAMMA0_" . player, "PUSH4")
	PadIni.Write(push5, "JAMMA0_" . player, "PUSH5")
	PadIni.Write(push6, "JAMMA0_" . player, "PUSH6")
	PadIni.Write(push7, "JAMMA0_" . player, "PUSH7")
	PadIni.Write(push8, "JAMMA0_" . player, "PUSH8")
	PadIni.Write(service, "JAMMA0_" . player, "SERVICE")
	PadIni.Write(start, "JAMMA0_" . player, "START")
	PadIni.Write(coin, "JAMMA0_" . player, "COIN")
	PadIni.Write(digitalup, "JAMMA0_" . player, "DIGITALUP")
	PadIni.Write(digitaldown, "JAMMA0_" . player, "DIGITALDOWN")
	PadIni.Write(digitalleft, "JAMMA0_" . player, "DIGITALLEFT")
	PadIni.Write(digitalright, "JAMMA0_" . player, "DIGITALRIGHT")
	PadIni.Write(analogup, "JAMMA0_" . player, "ANALOGUP")
	PadIni.Write(analogdown, "JAMMA0_" . player, "ANALOGDOWN")
	PadIni.Write(analogleft, "JAMMA0_" . player, "ANALOGLEFT")
	PadIni.Write(analogright, "JAMMA0_" . player, "ANALOGRIGHT")
	PadIni.Write(analogup2, "JAMMA0_" . player, "ANALOGUP2")
	PadIni.Write(analogdown2, "JAMMA0_" . player, "ANALOGDOWN2")
	PadIni.Write(analogleft2, "JAMMA0_" . player, "ANALOGLEFT2")
	PadIni.Write(analogright2, "JAMMA0_" . player, "ANALOGRIGHT2")
}

HaltEmu:
	If (fullscreen = "truefullscreen")
		KeyUtils.Send("!{Enter}")
	If VMUHideKey
		XHotKeywrapper(VMUHideKey,"VMUHide","OFF")
Return
RestoreEmu:
	If (fullscreen = "truefullscreen")
		KeyUtils.Send("!{Enter}")
	If (displayVMU = "true")
	{
		If !IsObject(VMUWindow)
			VMUWindow := new Window("ahk_ID " . VMUWindowID)
		If !IsObject(ExtraFixedResBezel)
			ExtraFixedResBezel := new Window("ahk_ID " . extraFixedRes_Bezel_hwnd)
		VMUWindow.Set("Transparent", 0)
		VMUWindow.Set("AlwaysOnTop", "On")
		VMUWindow.Show()
		VMUWindow.Set("AlwaysOnTop", "On")
		ExtraFixedResBezel.Set("AlwaysOnTop", "On")
		ExtraFixedResBezel.Show()
		If !(VMUHidden)
			VMUWindow.Set("Transparent", "off")
	}
	If VMUHideKey
		XHotKeywrapper(VMUHideKey,"VMUHide","ON")
Return

HideGUIWindow:
	emuPrimaryWindow.Set("Transparent", "On")
	emuPrimaryWindow.Activate()		; once activated, demul starts loading the rom
Return

VMUHide:
	If VMUHidden {
		Loop, 4
			VMUWindow.Set("Transparent", "off")
		UpdateLayeredWindow(extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_hdc,0,0, A_ScreenWidth, A_ScreenHeight,255)
		VMUHidden := false
	} Else {
		Loop, 4
			VMUWindow.Set("Transparent", 0)
		UpdateLayeredWindow(extraFixedRes_Bezel_hwnd, extraFixedRes_Bezel_hdc,0,0, A_ScreenWidth, A_ScreenHeight,0)
		VMUHidden := true
	}
Return

CloseProcess:
	FadeOutStart()
	If (demulShooterEnabled = "true") {
		DemulShooterExe.Close()
	}
	emuPrimaryWindow.PostMessage("0x111", "40085")	; Stop emulation first for a clean exit
	TimerUtils.Sleep(5)	; just like to give a little time before closing
	emuPrimaryWindow.PostMessage("0x111", "40080")	; Exit
Return
