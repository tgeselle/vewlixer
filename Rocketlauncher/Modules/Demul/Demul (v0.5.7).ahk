MEmu := "Demul"
MEmuV := "v0.5.7"
MURL := ["http://demul.emulation64.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.9"
MCRC := "D933AAFF"
iCRC := "D4B6118E"
MID := "635038268881865553"
MSystem := ["Sammy Atomiswave","Sega Dreamcast","Sega Naomi"]
;----------------------------------------------------------------------------
; Notes:
; Required - control and nvram files setup for each game/control type
; Required - moduleName ini: can be found in my user dir on the FTP at /Upload Here/djvj/Sega Naomi\Modules\Sega Naomi
; moduleName ini must be placed in same folder as this module
; GDI images must match mame zip names and be extracted and have a .dat extension
; Rom_Extension should be zip
;
; Place the naomi.zip bios archive in the demul\roms subdir
; Set your Video Plugin to gpuOglv3 and set your desired resolution there
; In case your control codes do not match mine, set your desired control type in demul, then open the demul.ini and find section PORTB and look for the device key. Use this number instead of the one I provided
; gpuDX11, gpuDXv3, and gpuDXLegacy are all supported. Define what plugin you want to use for each game in the moduleName ini.
; Read the notes at the top of the moduleName ini on how to control windowed fullscreen, true fullscreen, or windowed mode
; Windowed fullscreen will take effect the 2nd time you run the emu. It has to calculate your resolution on first run.
;
; Controls:
; Start a game of each control type (look in the moduleName ini for these types) and configure your controls to play the game. Copy paste the JAMMA0_0 and JAMMA0_1 (for naomi) or the ATOMISWAVE0_0 and ATOMISWAVE0_1 (for atomiswave) sections into the moduleName ini under the matching controls section.
;
; Troubleshooting:
; For some reason demul's ini files can get corrupted and ahk can't read/write to them correctly.
; If your ini keys are not being read or not writing to their existing keys in the demul inis, create a new file and copy/paste everything from the old ini into the new one and save.
; If you use Fade_Out, the module will force close demul because you cannot send ALT+F4 to demul if another GUI is covering it. Otherwise demul should close cleanly when Fade_Out is disabled. I suggest keeping Fade_Out disabled if you use this emu.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"window"))	; instantiate primary emulator window object

; This object controls how the module reacts to different systems. Demul can play a few systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Sammy Atomiswave","atomiswave","Sega Dreamcast","dc","Sega Naomi","naomi")
ident := mType[systemName]	; search object for the systemName identifier Demul uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Demul module: " . moduleName)

DemuleIni := new IniFile(emuPath . "\Demul.ini")
PadIni := new IniFile(emuPath . "\padDemul.ini")
DemuleIni.CheckFile("Could not find Demul's ini. Please run Demul manually first and each of it's settings sections so the appropriate inis are created for you: " . DemuleIni.FileFullPath)
PadIni.CheckFile("Could not find Demul's control ini. Please run Demul manually first and set up your controls so this file is created for you: " . PadIni.FileFullPath)

controls := moduleIni.Read(romname, "controls","standard",,1)	; have to read this first so the below loop works

globalMax := moduleIni.Read("Settings", "GlobalMax", "false",,1)
maxHideTaskbar := moduleIni.Read("Settings", "MaxHideTaskbar",,,1)

controllerCode := moduleIni.Read("Settings", "ControllerCode", "16777216",,1)
mouseCode := moduleIni.Read("Settings", "MouseCode", "131072",,1)
keyboardCode := moduleIni.Read("Settings", "KeyboardCode", "1073741824",,1)
lightgunCode := moduleIni.Read("Settings", "LightgunCode", "-2147483648",,1)
globalPlugin := moduleIni.Read("Settings", "GlobalPlugin", "gpuDX11",,1)
globalShaderUsePass1 := moduleIni.Read("Settings", "GlobalShaderUsePass1", "false",,1)
globalShaderUsePass2 := moduleIni.Read("Settings", "GlobalShaderUsePass2", "false",,1)
globalShaderNamePass1 := moduleIni.Read("Settings", "GlobalShaderNamePass1",,,1)
globalShaderNamePass2 := moduleIni.Read("Settings", "GlobalShaderNamePass2",,,1)
demulShooterEnabled := moduleIni.Read(romName . "|Settings", "DemulShooterEnabled", "false",,1)

max := moduleIni.Read(romName, "Max",,,1)
loadDecrypted := moduleIni.Read(romName, "LoadDecrypted",,,1)
bios := moduleIni.Read(romName, "Bios",,,1)
shaderUsePass1 := moduleIni.Read(romName, "ShaderUsePass1",,,1)
shaderUsePass2 := moduleIni.Read(romName, "ShaderUsePass2",,,1)
shaderNamePass1 := moduleIni.Read(romName, "ShaderNamePass1",,,1)
shaderNamePass2 := moduleIni.Read(romName, "ShaderNamePass2",,,1)
plugin := moduleIni.Read(romName, "Plugin",,,1)
listSorting := moduleIni.Read(romName, "ListSorting",,,1)

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

; Now compare global & rom keys to get final value
max := If (max = "" or max = "ERROR") ? globalMax : max
plugin := If (plugin = "" or plugin = "ERROR") ? globalPlugin : plugin
shaderUsePass1 := If (shaderUsePass1 = "" or shaderUsePass1 = "ERROR") ? globalShaderUsePass1 : shaderUsePass1
shaderUsePass2 := If (shaderUsePass2 = "" or shaderUsePass2 = "ERROR") ? globalShaderUsePass2 : shaderUsePass2
shaderNamePass1 := If (shaderNamePass1 = "" or shaderNamePass1 = "ERROR") ? globalShaderNamePass1 : shaderNamePass1
shaderNamePass2 := If (shaderNamePass2 = "" or shaderNamePass2 = "ERROR") ? globalShaderNamePass2 : shaderNamePass2

; Verify user set desired gpu plugin name correctly
If (plugin != "gpuDX11" And plugin != "gpuDXv3" And plugin != "gpuDXLegacy") or (plugin = "" or plugin = "ERROR")
	ScriptError(plugin . " is not a supported gpu plugin.`nLeave the plugin blank to use the default ""gpuDX11"".`nValid options are gpuDX11, gpuDXv3, or gpuDXLegacy.")

; check for the specified gpu plugin
GpuIni := new IniFile(emuPath . "\" . plugin . ".ini")
GpuIni.CheckFile("Please run Demul manually first and select the " . plugin . " gpu plugin so it creates this file for you: " . GpuIni.FileFullPath)

; This updates the DX11gpu ini file to turn List Sorting on or off. Depending on the games, turning this on for some games may remedy missing graphics, having it off on other games may fix corrupted graphics. Untill they improve the DX11gpu, this is the best it's gonna get.
If (plugin = "gpuDX11")
	If (ListSorting = "true")
		GpuIni.Write(0, "main", "AutoSort")	; 0 enables Auto Sort in demul 0.5.7, opposite from 0.5.6
	Else
		GpuIni.Write(1, "main", "AutoSort")	; Disabling Auto Sort unless someone specifies it to be on or off in settings

; This updates the demul.ini with your gpu plugin choice for the selected rom
DemuleIni.Write(plugin . ".dll", "plugins", "gpu")

 ; Shader Effects
If (plugin = "gpuDX11") {	; Demul 0.5.7 only supports shaders using the gpuDX11 plugin
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

; Setting demul to use true fullscreen if defined in settings.ini, otherwise sets demul to run windowed. This is for gpuDX11 plugin only
If (plugin = "gpuDX11")
	If (Max = "fullscreen")
		GpuIni.Write(1, "main", "UseFullscreen")
	Else
		GpuIni.Write(0, "main", "UseFullscreen")

If (Max = "true")
{
	If (maxHideTaskbar = "true") {
		RLLog.Info("Module - Hiding Taskbar and Start Button.")
		MiscUtils.TaskBar("off")
	}
	; Create black background to give the emu the fullscreen look
	Gui 2: -Caption +ToolWindow
	Gui 2: Color, Black
	Gui 2: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
}

If (ident != "dc" && demulShooterEnabled = "true") {	; If demulshooter is enabled for this game, launch it with relevant options
	DemulShooterExe := New DemulShooter()
	DemulShooterExe.Launch("demul057",romName,"-noresize")
}

TimerUtils.Sleep(250)

;  Construct the CLI for demul and send romName if naomi or atomiswave. Dreamcast needs a full path and romName.
If (LoadDecrypted = "true")	; decrypted naomi rom
	romCLI := "-customrom=" . """" . romPath . "\" . romName . ".bin"""
Else If (ident = "dc")	; dreamcast game
	romCLI := " -image=" . """" . romPath . "\" . romName . romExtension . """"
Else	; standard naomi rom
	romCLI := "-rom=" . romName

hideEmuObj := Object(emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run(" -run=" . ident . " " . romCLI,, emuPID)
; TimerUtils.Sleep(1000) ; need a second for demul to launch, increase if yours takes longer and the emu is appearing too soon

Loop { ; looping until demul is done loading rom and gpu starts showing frames
	TimerUtils.Sleep(200)
	winTitle := emuPrimaryWindow.GetTitle(0)
	winTextSplit := StringUtils.Split(winTitle, A_Space)
	If (winTextSplit[5] = "gpu:" And winTextSplit[6] != "0" And winTextSplit[6] != "1")
		Break
}
emuPrimaryWindow.Activate()

If ((plugin = "gpuDXv3" Or plugin = "gpuDXLegacy") && Max = "fullscreen")
	KeyUtils.Send("!{ENTER}") ; go fullscreen for gpuDXv3 and gpuDXLegacy plugins only

; This is where we calculate and maximize demul's window using our pseudo fullscreen code
If (Max = "true")
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

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")

Gui 2: Destroy

If StringUtils.Contains(systemName,"Dreamcast|DC")
	7zCleanUp()

FadeOutExit()

If (Max = "true" and maxHideTaskbar = "true") {
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
	If (Max = "fullscreen")
		KeyUtils.Send("!{ENTER}")
Return
RestoreEmu:
	If (Max = "fullscreen")
		KeyUtils.Send("!{ENTER}")
Return

CloseProcess:
	FadeOutStart()
	If (demulShooterEnabled = "true") {
		DemulShooterExe.Close()
	}
	If (fadeOut != "true")	; cannot send ALT+F4 to a background window (controlsend doesn't work), so we have to force close instead.
	{
		; demul 0.5.7 crashes 50% of the time if you try to close it any other way
		KeyUtils.Send("{F3}{Alt}{Up}s{Enter}")
		TimerUtils.Sleep(50)
	}
	primaryExe.Process("Close", emuPID) ; we have to close this way otherwise demul crashes with WinClose
Return
