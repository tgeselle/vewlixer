MEmu := "Demul"
MEmuV := "v0.5.6"
MURL := ["http://demul.emulation64.com/"]
MAuthor := ["djvj"]
MVersion := "2.0.7"
MCRC := "C35346FC"
iCRC := "5C9B9311"
MID := "635038268881325110"
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
;
; Controls:
; Start a game of each control type (look in the moduleName ini for these types) and configure your controls to play the game. Copy paste the JAMMA0_0 and JAMMA0_1 (for naomi) or the ATOMISWAVE0_0 and ATOMISWAVE0_1 (for atomiswave) sections into the moduleName ini under the matching controls section.
;
; Sega Dreamcast:
; This script supports the following DC images: GDI, CDI, CHD, MDS, CCD, NRG, CUE
; Place your dc.zip bios in the roms subdir of your emu
; Run demul manually and goto Config->Plugins->GD-ROM Plugin and set it to gdrImage
; Set your Video Plugin to gpuOglv3
; On first run of a game, demul will ask you to setup all your plugin choices if you haven't already.
; If you want to convert your roms from gdi to chd, see here: http://www.emutalk.net/showthread.php?t=51502
; FileDelete(s) are in the script because sometimes demul will corrupt the ini and make it crash. The script recreates a clean ini for you.
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

controls := moduleIni.Read(romname, "controls","standard",,1)

fullscreen := moduleIni.Read("Settings", "Fullscreen", "true",,1)
controllerCode := moduleIni.Read("Settings", "ControllerCode", "16777216",,1)
mouseCode := moduleIni.Read("Settings", "MouseCode", "131072",,1)
keyboardCode := moduleIni.Read("Settings", "KeyboardCode", "1073741824",,1)
lightgunCode := moduleIni.Read("Settings", "LightgunCode", "-2147483648",,1)
globalShaderEffects := moduleIni.Read("Settings", "GlobalShaderEffects", "false",,1)
globalShaderName := moduleIni.Read("Settings", "GlobalShaderName",,,1)
globalShaderMode := moduleIni.Read("Settings", "GlobalShaderMode",,,1)

loadDecrypted := moduleIni.Read(romName, "LoadDecrypted",,,1)
bios := moduleIni.Read(romName, "Bios",,,1)
shaderEffects := moduleIni.Read(romName, "ShaderEffects",,,1)
shaderName := moduleIni.Read(romName, "ShaderName",,,1)
shaderMode := moduleIni.Read(romName, "ShaderMode",,,1)

n_push1_0 := moduleIni.Read(controls . "_JAMMA0_0", "push1",,,1)
n_push2_0 := moduleIni.Read(controls . "_JAMMA0_0", "push2",,,1)
n_push3_0 := moduleIni.Read(controls . "_JAMMA0_0", "push3",,,1)
n_push4_0 := moduleIni.Read(controls . "_JAMMA0_0", "push4",,,1)
n_push5_0 := moduleIni.Read(controls . "_JAMMA0_0", "push5",,,1)
n_push6_0 := moduleIni.Read(controls . "_JAMMA0_0", "push6",,,1)
n_push7_0 := moduleIni.Read(controls . "_JAMMA0_0", "push7",,,1)
n_push8_0 := moduleIni.Read(controls . "_JAMMA0_0", "push8",,,1)
n_service_0 := moduleIni.Read(controls . "_JAMMA0_0", "SERVICE",,,1)
n_start_0 := moduleIni.Read(controls . "_JAMMA0_0", "START",,,1)
n_coin_0 := moduleIni.Read(controls . "_JAMMA0_0", "COIN",,,1)
n_digitalup_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALUP",,,1)
n_digitaldown_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALDOWN",,,1)
n_digitalleft_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALLEFT",,,1)
n_digitalright_0 := moduleIni.Read(controls . "_JAMMA0_0", "DIGITALRIGHT",,,1)
n_analogup_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGUP",,,1)
n_analogdown_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGDOWN",,,1)
n_analogleft_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGLEFT",,,1)
n_analogright_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGRIGHT",,,1)
n_analogup2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGUP2",,,1)
n_analogdown2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGDOWN2",,,1)
n_analogleft2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGLEFT2",,,1)
n_analogright2_0 := moduleIni.Read(controls . "_JAMMA0_0", "ANALOGRIGHT2",,,1)

n_push1_1 := moduleIni.Read(controls . "_JAMMA0_1", "push1",,,1)
n_push2_1 := moduleIni.Read(controls . "_JAMMA0_1", "push2",,,1)
n_push3_1 := moduleIni.Read(controls . "_JAMMA0_1", "push3",,,1)
n_push4_1 := moduleIni.Read(controls . "_JAMMA0_1", "push4",,,1)
n_push5_1 := moduleIni.Read(controls . "_JAMMA0_1", "push5",,,1)
n_push6_1 := moduleIni.Read(controls . "_JAMMA0_1", "push6",,,1)
n_push7_1 := moduleIni.Read(controls . "_JAMMA0_1", "push7",,,1)
n_push8_1 := moduleIni.Read(controls . "_JAMMA0_1", "push8",,,1)
n_service_1 := moduleIni.Read(controls . "_JAMMA0_1", "SERVICE",,,1)
n_start_1 := moduleIni.Read(controls . "_JAMMA0_1", "START",,,1)
n_coin_1 := moduleIni.Read(controls . "_JAMMA0_1", "COIN",,,1)
n_digitalup_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALUP",,,1)
n_digitaldown_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALDOWN",,,1)
n_digitalleft_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALLEFT",,,1)
n_digitalright_1 := moduleIni.Read(controls . "_JAMMA0_1", "DIGITALRIGHT",,,1)
n_analogup_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGUP",,,1)
n_analogdown_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGDOWN",,,1)
n_analogleft_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGLEFT",,,1)
n_analogright_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGRIGHT",,,1)
n_analogup2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGUP2",,,1)
n_analogdown2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGDOWN2",,,1)
n_analogleft2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGLEFT2",,,1)
n_analogright2_1 := moduleIni.Read(controls . "_JAMMA0_1", "ANALOGRIGHT2",,,1)

a_up_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "UP",,,1)
a_down_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "DOWN",,,1)
a_left_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "LEFT",,,1)
a_right_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "RIGHT",,,1)
a_shot1_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "SHOT1",,,1)
a_shot2_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "SHOT2",,,1)
a_shot3_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "SHOT3",,,1)
a_shot4_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "SHOT4",,,1)
a_shot5_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "SHOT5",,,1)
a_start_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "START",,,1)
a_coin_0 := moduleIni.Read(controls . "_ATOMISWAVE0_0", "COIN",,,1)

a_up_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "UP",,,1)
a_down_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "DOWN",,,1)
a_left_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "LEFT",,,1)
a_right_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "RIGHT",,,1)
a_shot1_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "SHOT1",,,1)
a_shot2_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "SHOT2",,,1)
a_shot3_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "SHOT3",,,1)
a_shot4_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "SHOT4",,,1)
a_shot5_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "SHOT5",,,1)
a_start_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "START",,,1)
a_coin_1 := moduleIni.Read(controls . "_ATOMISWAVE0_1", "COIN",,,1)

; Now compare global & rom keys to get final value
shaderEffects := If (shaderEffects = "" or shaderEffects = "ERROR") ? globalShaderEffects : shaderEffects
shaderName := If (shaderName = "" or shaderName = "ERROR") ? globalShaderName : shaderName
shaderMode := If (shaderMode = "" or shaderMode = "ERROR") ? globalShaderMode : shaderMode

 ; Shader Effects
GpuOglv3Ini := new IniFile(emuPath . "\gpuOglv3.ini")
GpuOglv3Ini.CheckFile("Shaders are only supported using the gpuOglv3 plugin. Cannot find " . emuPath . "\gpuOglv3.ini")
currentShaderValue := GpuOglv3Ini.Read("shader", "effects")
If (shaderEffects = "true")
{
	shaderPath := emupath . "\shaders"	; define the path to the shaders
	DemulShader := new File(shaderPath . "\" . shaderName . ".slf")
	DemulShader.CheckFile()	; make sure the shader exists
	If (currentShaderValue = "false")
		GpuOglv3Ini.Write("true", "shader", "effects")
	GpuOglv3Ini.Write(shaderMode, "shader", "mode")
	GpuOglv3Ini.Write(shaderPath, "shader", "path")
	GpuOglv3Ini.Write(shaderName, "shader", "name")
}Else If (shaderEffects != "true" and currentShaderValue = "true")
	GpuOglv3Ini.Write("false", "shader", "effects")

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

	If (ident = "atomiswave") {
		WriteAtomiswaveControls(0,a_shot1_0,a_shot2_0,a_shot3_0,a_shot4_0,a_shot5_0,a_start_0,a_coin_0,a_up_0,a_down_0,a_left_0,a_right_0)
		WriteAtomiswaveControls(1,a_shot1_1,a_shot2_1,a_shot3_1,a_shot4_1,a_shot5_1,a_start_1,a_coin_1,a_up_1,a_down_1,a_left_1,a_right_1)
	} Else{
		WriteNaomiControls(0,n_push1_0,n_push2_0,n_push3_0,n_push4_0,n_push5_0,n_push6_0,n_push7_0,n_push8_0,n_service_0,n_start_0,n_coin_0,n_digitalup_0,n_digitaldown_0,n_digitalleft_0,n_digitalright_0,n_analogup_0,n_analogdown_0,n_analogleft_0,n_analogright_0,n_analogup2_0,n_analogdown2_0,n_analogleft2_0,n_analogright2_0)
		WriteNaomiControls(1,n_push1_1,n_push2_1,n_push3_1,n_push4_1,n_push5_1,n_push6_1,n_push7_1,n_push8_1,n_service_1,n_start_1,n_coin_1,n_digitalup_1,n_digitaldown_1,n_digitalleft_1,n_digitalright_1,n_analogup_1,n_analogdown_1,n_analogleft_1,n_analogright_1,n_analogup2_1,n_analogdown2_1,n_analogleft2_1,n_analogright2_1)
	}
}

TimerUtils.Sleep(250)

;  Construct the CLI for demul and send romName if naomi or atomiswave. Dreamcast needs a full path and romName.
If (LoadDecrypted = "true")	; decrypted naomi rom
	romCLI := "-customrom=" . """" . romPath . "\" . romName . ".bin"""
Else If (ident = "dc")	; dreamcast game
	romCLI := " -rom=" . """" . romPath . "\" . romName . romExtension . """"
Else	; standard naomi rom
	romCLI := "-rom=" . romName

hideEmuObj := Object(emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)

primaryExe.Run(" -run=" . ident . " " . romCLI,, emuPID)
; Sleep, 1000 ; need a second for demul to launch, increase if yours takes longer and the emu is appearing too soon

Loop { ; looping until demul is done loading rom and gpu starts showing frames
	TimerUtils.Sleep(200)
	winTitle := emuPrimaryWindow.GetTitle(0)
	winTextSplit := StringUtils.Split(winTitle, A_Space)
	If (winTextSplit[5] = "gpu:" And winTextSplit[6] = "0")
		Break
}
emuPrimaryWindow.Activate()

If (fullscreen = "true")
	KeyUtils.Send("!{ENTER}") ; go fullscreen

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")

If StringUtils.Contains(systemName,"Dreamcast|DC")
	7zCleanUp()

FadeOutExit()
ExitModule()


 ; Write new naomi controls to padDemul.ini
WriteNaomiControls(player,push1,push2,push3,push4,push5,push6,push7,push8,service,start,coin,digitalup,digitaldown,digitalleft,digitalright,analogup,analogdown,analogleft,analogright,analogup2,analogdown2,analogleft2,analogright2) {
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

 ; Write new atomiswave controls to padDemul.ini
WriteAtomiswaveControls(player,shot1,shot2,shot3,shot4,shot5,start,coin,up,down,left,right) {
	Global PadIni
	PadIni.Write(shot1, "ATOMISWAVE0_" . player, "SHOT1")
	PadIni.Write(shot2, "ATOMISWAVE0_" . player, "SHOT2")
	PadIni.Write(shot3, "ATOMISWAVE0_" . player, "SHOT3")
	PadIni.Write(shot4, "ATOMISWAVE0_" . player, "SHOT4")
	PadIni.Write(shot5, "ATOMISWAVE0_" . player, "SHOT5")
	PadIni.Write(start, "ATOMISWAVE0_" . player, "START")
	PadIni.Write(coin, "ATOMISWAVE0_" . player, "COIN")
	PadIni.Write(up, "ATOMISWAVE0_" . player, "UP")
	PadIni.Write(down, "ATOMISWAVE0_" . player, "DOWN")
	PadIni.Write(left, "ATOMISWAVE0_" . player, "LEFT")
	PadIni.Write(right, "ATOMISWAVE0_" . player, "RIGHT")
}

CloseProcess:
	FadeOutStart()
	If (fadeOut = "true")	; cannot send ALT+F4 to a background window (controlsend doesn't work), so we have to force close instead.
		primaryExe.Process("Close", emuPID) ; we have to close this way otherwise demul crashes with WinClose
	Else
		KeyUtils.Send("!{F4}")
Return
