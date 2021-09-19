MEmu := "ePSXe"
MEmuV := "v2.0.5"
MURL := ["http://www.epsxe.com/"]
MAuthor := ["djvj","Shateredsoul","brolly","robbforce","slizzap"]
MVersion := "2.1.6"
MCRC := "7B44C67"
iCRC := "F343B0EE"
MID := "635038268888210842"
MSystem := ["Sony PlayStation"]
;----------------------------------------------------------------------------
; Notes:
; epsxe can't deal with bin/cue dumps with more than one audio track if you load the cue file directly.
; For these to work you must mount the cue on Virtual Drive and let epsxe boot the game from there.
; You need to make sure you have a SCSI virtual drive on Daemon Tools, NOT a DT one.
; On first time use, 2 default memory card files will be created called _default_001.mcr and _default_002.mcr in emuPath\memcards
;
; Extract all your BIOS files to the bios subfolder. Then goto Config->Bios and select the bios you wish to use.
;
; Go to Config->Video then choose a plugin. Pete's OpenGL line is preferred
; Click Configure (under video plugin) and choose fullscreen and set your desired resolution. Video options/results will vary based on the plugin you choose.
;
; If you are using images with multiple tracks, set your extension to cue (make sure all your cues are correctly pointing to their tracks).
; Go to Config->Cdrom->Configure button and select the drive letter associated with your Virtual Drive virtual drive.
;
; ePSXe will ONLY close via Escape, it will bug out with all other forms of closing a normal program. Do not edit CloseProcess!
;
; ePSXe stores its settings in the registry @ HKEY_CURRENT_USER\Software\epsxe\config
; Video plugins store their settings in the registry @ HKEY_CURRENT_USER\Software\epsxe\config\ogl2
;
; neGcon Controller help: http://www.rlauncher.com/forum/showthread.php?3132-ePSXe-v2-0-Updates-and-Modifications-Module-Submission&p=25607&viewfull=1#post25607
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; dialogOpen := i18n("dialog.open")	; Looking up local translation
dialogOpen := "Open"	; apparently ePSXe doesnt support multiple languages, forcing this until it does

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("ePSXe","EPSX"))	; instantiate primary emulator window object
emuOpenRomWindow := new Window(new WindowTitle(dialogOpen . " PSX ISO","#32770"))
emuGUIWindow := new Window(new WindowTitle("","EPSXGUI"))
emuChangeDiscWindow := new Window(new WindowTitle("Change Disc Option","#32770"))

emuPrimaryWindow.CreateControl("TopMost")		; instantiate new control for the topmost control element
emuChangeDiscWindow.CreateControl("Button1")	; instantiate new control for Button1

; Settings (Global)
slowBoot := moduleIni.Read("Settings", "Slow_Boot","false",,1)			; If true, force emulator to show bios screen at boot
hideEpsxeGUIs := moduleIni.Read("Settings", "Hide_ePSXe_GUIs","true",,1)
perGameMemCards := moduleIni.Read("Settings", "Per_Game_Memory_Cards","true",,1)
memCardPath := moduleIni.Read("Settings", "Memory_Card_Path", emuPath . "\memcards",,1)
memCardPath := AbsoluteFromRelative(emuPath, memCardPath)

; Settings (Overridable per ROM)
GfxPlugin := moduleIni.Read(romName . "|Settings", "Video_Plugin","GPUCOREGL2",,1)	; Use the gfx plugin name
Widescreen := moduleIni.Read(romName . "|Settings", "Widescreen","false",,1)	; Widescreen hack.
GamepadTypePlayer1 := moduleIni.Read(romName . "|Settings", "GamepadType_Player1","4",,1)	; Set Gamepad type for Player 1. Allows for setting of different analog or digital controllers since not all games support analog controllers. Default is "4" (DualShock).
GamepadTypePlayer2 := moduleIni.Read(romName . "|Settings", "GamepadType_Player2","4",,1)	; Set Gamepad type for Player 2. Allows for setting of different analog or digital controllers since not all games support analog controllers. Default is "4" (DualShock).
GamepadTypePlayer3 := moduleIni.Read(romName . "|Settings", "GamepadType_Player3","4",,1)	; Set Gamepad type for Player 3. Allows for setting of different analog or digital controllers since not all games support analog controllers. Default is "4" (DualShock).
GamepadTypePlayer4 := moduleIni.Read(romName . "|Settings", "GamepadType_Player4","4",,1)	; Set Gamepad type for Player 4. Allows for setting of different analog or digital controllers since not all games support analog controllers. Default is "4" (DualShock).
MultitapPort1 := moduleIni.Read(romName . "|Settings", "Multitap_Port1","false",,1)   ; Enable Multitap for Port 1
enableFlightStick := moduleIni.Read(romName . "|Settings", "EnableFlightStick","false",,1)	; If true, GamepadType_Player1 and GamepadType_Player2 are forced to DualAnalog and enables Flight Stick mode at game start (Presses F5 twice).
enableAnalogDelay := moduleIni.Read(romName . "|Settings", "EnableAnalog_Delay","3",,1)	; Delay in seconds before Analog mode is enabled. This is set to 3 seconds by default, which works for the majority of games. Some games re-initialize at the loading screen and need to have a custom delay to enable analog afterwards (Colin McRae Rally =  30s, for example)
disableMemoryCard1 := moduleIni.Read(romName, "DisableMemoryCard1","false",,1)	; If true, disables memory card 1 for this game. Some games may not boot if both memory cards are inserted.
disableMemoryCard2 := moduleIni.Read(romName, "DisableMemoryCard2","false",,1)	; If true, disables memory card 2 for this game. Some games may not boot if both memory cards are inserted.

; Video plugin settings (global)
Fullscreen := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Fullscreen","true",,1)
DesktopResolutionX := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Desktop_Resolution_X",,,1)
DesktopResolutionY := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Desktop_Resolution_Y",,,1)
WindowSizeX := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Window_Size_X",,,1)
WindowSizeY := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Window_Size_Y",,,1)
ColorDepth := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Color_Depth","32",,1)
WindowSizeInFullscreen := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Window_Size_In_Fullscreen","false",,1)
Scanlines := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Scanlines","false",,1)
ScanlineBrightness := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "Scanline_Brightness",,,1)
MDECFilter := moduleIni.Read("Pete's OpenGL2 GPU Plugin", "MDEC_Filter","false",,1)

; Video plugin settings (Overridable per ROM)
HiresX := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Internal_X_Resolution",1,,1)
HiresY := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Internal_Y_Resolution",1,,1)
KeepRatio := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Stretching_Mode",0,,1)
NoRenderTexture := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Render_Mode",0,,1)
FilterType := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Texture_Filtering",0,,1)
HiResTextures := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Hi_Res_Textures",0,,1)
VRamSize := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Gfx_Card_Vram",0,,1)
TWinShader := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Pixel_Shader","false",,1)
OffscreenDrawing := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Offscreen_Drawing",1,,1)
FrameTexType := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Framebuffer_Effects",0,,1)
FrameUpload := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Framebuffer_Upload",1,,1)
FullscreenBlur := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Screen_Filtering",0,,1)
FullscreenShader := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Shader_Effects",0,,1)
ShaderDir := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Shader_Directory",,,1)
FSShaderLevel := moduleIni.Read(romName . "|Pete's OpenGL2 GPU Plugin", "Shader_Level",1,,1)

; neGcon controller settings (Overridable per ROM)
neGcon_P1_Twist := moduleIni.Read(romName . "|neGcon Controller", "Player1_Twist","0",,1)
neGcon_P1_LeftShoulder := moduleIni.Read(romName . "|neGcon Controller", "Player1_LeftShoulder","1",,1)
neGcon_P1_ButtonI := moduleIni.Read(romName . "|neGcon Controller", "Player1_ButtonI","4",,1)
neGcon_P1_ButtonII := moduleIni.Read(romName . "|neGcon Controller", "Player1_ButtonII","3",,1)
neGcon_P2_Twist := moduleIni.Read(romName . "|neGcon Controller", "Player2_Twist","8",,1)
neGcon_P2_LeftShoulder := moduleIni.Read(romName . "|neGcon Controller", "Player2_LeftShoulder","9",,1)
neGcon_P2_ButtonI := moduleIni.Read(romName . "|neGcon Controller", "Player2_ButtonI","12",,1)
neGcon_P2_ButtonII := moduleIni.Read(romName . "|neGcon Controller", "Player2_ButtonII","11",,1)

BezelStart()

; Set the GPU plugin and it's settings.
Registry.Write("REG_SZ","HKCU","Software\epsxe\config","VideoPlugin",GfxPlugin)

; Set general video options
Widescreen := If Widescreen = "true" ? 3 : 4	
Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GTEWidescreen",Widescreen)

; TODO: The other video plugins might use the same settings and even if they don't, it probably won't hurt
; to have these values in the registry for the selected plugin.
; Only apply these settings if the user selected the OpenGL2 plugin.
If (GfxPlugin = "GPUCOREGL2") {
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","ColDepth",ColorDepth)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","HiresX",HiresX)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","HiresY",HiresY)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","KeepRatio",KeepRatio)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","NoRenderTexture",NoRenderTexture)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FilterType",FilterType)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","HiResTextures",HiResTextures)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","VRamSize",VRamSize)
	TWinShader := If TWinShader = "true" ? 1 : 0	; Convert texture shader bool into an int before writing to the registry
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","TWinShader",TWinShader)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","OffscreenDrawing",OffscreenDrawing)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FrameTexType",FrameTexType)
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FrameUpload",FrameUpload)
	FullscreenBlur := If FullscreenBlur = "true" ? 1 : 0
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FullscreenBlur",FullscreenBlur)
	Scanlines := If Scanlines = "true" ? 1 : 0
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","UseScanlines",UseScanlines)
	If (Scanlines = "1") {
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","ScanBlend",ScanlineBrightness)
	}
	MDECFilter := If MDECFilter = "true" ? 1 : 0
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","UseMdecFilter",MDECFilter)
	
	; If Shader_Effects is set to 3 or 5 and Shader_Directory is not set, disable Shader_Effects.
	If (FullscreenShader = 3 or FullscreenShader = 5) {
		If (ShaderDir = "") {
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FullscreenShader",0)
		} Else {
			Registry.Write("REG_SZ","HKCU","Software\epsxe\config\ogl2","ShaderDir",ShaderDir)
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FullscreenShader",FullscreenShader)
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FSShaderLevel",FSShaderLevel)

			; Turn these settings off because they'll blur/alter the image before it gets to the shader.
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FilterType",0)
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","HiResTextures",0)
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FullscreenBlur",0)
		}
	} Else {
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FullscreenShader",FullscreenShader)
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","FSShaderLevel",FSShaderLevel)
	}
}

; Enable Fullscreen mode for the video plugin.
If (Fullscreen = "true") {
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","WindowMode",0)

	If (WindowSizeInFullscreen = "true") {		; If true enable Window Size in Fullscreen mode.
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","CenterFullScreen",1)
		If (WindowSizeX != "" or WindowSizeY != "") {		; If resolution configured, convert Window Resolution X and Y from decimal to hex, concatenate, then import into the registry as a single value.
			SetFormat, integer, hex
			WindowSizeX += 0
			WindowSizeY += 0
			SetFormat, integer, decimal
			WindowSizeX_Hex := StringUtils.TrimLeft(WindowSizeX,2)
			WindowSizeY_Hex := StringUtils.TrimLeft(WindowSizeY,2)
			WindowSize := "0x0" . WindowSizeY_Hex . "0" . WindowSizeX_Hex
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","WinSize",WindowSize)
		}
	} Else {
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","CenterFullScreen",0)
		
		If (DesktopResolutionX != "" or DesktopResolutionY != "") {
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","ResX",DesktopResolutionX)
			Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","ResY",DesktopResolutionY)
		}
	}
} Else {
	Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","WindowMode",1)

	If (WindowSizeX != "" or WindowSizeY != "") {
		SetFormat, integer, hex
		WindowSizeX += 0
		WindowSizeY += 0
		SetFormat, integer, decimal
		WindowSizeX_Hex := StringUtils.TrimLeft(WindowSizeX,2)
		WindowSizeY_Hex := StringUtils.TrimLeft(WindowSizeY,2)
		WindowSize := "0x0" . WindowSizeY_Hex . "0" . WindowSizeX_Hex
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","WinSize",WindowSize)
	}
	If (bezelEnabled = "true") {
		winSize := bezelScreenHeight * 65536 + bezelScreenWidth	; convert desired windowed resolution to Decimal
		Registry.Write("REG_DWORD","HKCU","Software\epsxe\config\ogl2","WinSize",winSize)
	}
}

; Set Gamepad Type. If enableFlightStick is set to "true", GamepadType is forced to DualAnalog for Player 1 and Player 2.
If (enableFlightStick = "true") {
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Multitap1","0")	; Disable Multitap if enableFlightStick is true
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadType","5,1,1,1,5,1,1,1")
} Else {
	If (MultitapPort1 = "true") {
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Multitap1","1")
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadType",GamepadTypePlayer1 . "," . GamepadTypePlayer2 . "," . GamepadTypePlayer3 . "," . GamepadTypePlayer4 . ",4,4,4,4")
	} Else {
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Multitap1","0")
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadType",GamepadTypePlayer1 . ",4,4,4," . GamepadTypePlayer2 . ",4,4,4")
	}
}

; neGcon Controller
RegVarGamepadFullAxis_bak := Registry.Read("HKCU","Software\epsxe\config","GamepadFullAxis.bak")	; Check to see if backup registry key exists. If so, RocketLauncher may not have exited properly and original key should be restored to ensure expected DualShock functionality.
If !RegVarGamepadFullAxis_bak {
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadFullAxis",RegVarGamepadFullAxis_bak)
	Registry.Delete("HKCU","Software\epsxe\config","GamepadFullAxis.bak")
}
If (GamepadTypePlayer1 = "7") {
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Multitap1",0)	; Ensure Multitap is disabled
	RegVarGamepadFullAxis_bak := Registry.Read("HKCU","Software\epsxe\config","GamepadFullAxis.bak")	; Check to see if backup registry key exists. If so, RocketLauncher may not have exited properly and original key should be restored to ensure expected DualShock functionality.
	If !RegVarGamepadFullAxis_bak {
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadFullAxis",RegVarGamepadFullAxis_bak)
		Registry.Delete("HKCU","Software\epsxe\config","GamepadFullAxis.bak")
	}
	RegVarGamepadFullAxis := Registry.Read("HKCU","Software\epsxe\config","GamepadFullAxis")
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadFullAxis.bak",RegVarGamepadFullAxis)
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadFullAxis",neGcon_P1_Twist . "," . neGcon_P1_LeftShoulder . "," . neGcon_P1_ButtonII . "," . neGcon_P1_ButtonI . ",192,192,192,192,192,192,192,192,192,192,192,192," . neGcon_P2_Twist . "," . neGcon_P2_LeftShoulder . "," . neGcon_P2_ButtonII . "," . neGcon_P2_ButtonI . ",192,192,192,192,192,192,192,192,192,192,192,192")
	; Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadFullAxis","0,67,130,66,192,192,192,192,192,192,192,192,192,192,192,192,8,75,138,74,192,192,192,192,192,192,192,192,192,192,192,192")
}

; Memory Cards

defaultMemCard1 := memCardPath . "\_default_001.mcr"	; defining default blank memory card for slot 1
defaultMemCard2 := memCardPath . "\_default_002.mcr"	; defining default blank memory card for slot 2
memCardName := If romTable[1,5] ? romTable[1,4] : romName	; defining rom name for multi disc rom
romMemCard1 := memCardPath . "\" . memCardName . "_001.mcr"		; defining name for rom's memory card for slot 1
romMemCard2 := memCardPath . "\" . memCardName . "_002.mcr"		; defining name for rom's memory card for slot 2
memcardType := If perGameMemCards = "true" ? "rom" : "default"	; define the type of memory card we will create in the below loop

memcardFolder := new Folder(memCardPath)
If !memcardFolder.Exist()
	memcardFolder.CreateDir()	; create memcard folder if it doesn't exist
Loop 2
{
	memcard%A_Index%File := new File(%memcardType%MemCard%A_Index%)
	If !memcard%A_Index%File.Exist()
	{	memcard%A_Index%File.Append()		; create a new blank memory card if one does not exist
		RLLog.Info("Module - Created a new blank memory card in Slot " . A_Index . ":" . memcard%A_Index%File.FileFullPath)
	}
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Memcard" . A_Index,memcard%A_Index%File.FileFullPath)

	; Now disable a memory card if required for the game to boot properly
	memcard%A_Index%Enable := Registry.Read("HKCU","Software\epsxe\config","Memcard" . A_Index . "Enable")
	If (disableMemoryCard%A_Index% = "true")
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Memcard" . A_Index . "Enable",0)
	Else
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","Memcard" . A_Index . "Enable",1)
}

hideEmuObj := Object(emuOpenRomWindow,0,emuGUIWindow,0,emuGameWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

epsxeExtension := StringUtils.Contains(".ccd|.cue|.mds|.img|.iso|.pbp",romExtension)	; the psx extensions supported by the emu

RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
noGUI := If romTable.MaxIndex() ? "" : " -nogui" ; multidisc games will not use nogui because we need to select an option in epsxe's gui to swap discs
slowBoot := If slowBoot = "true" ? " -slowboot" : ""

If (noGUI = "" && hideEpsxeGUIs = "true") {	; for multi disc games only
	RLLog.Info("Module - Starting the HideGUIWindow timer to prevent them from showing")
	SetTimer, HideGUIWindow, 10	; start watching for gui window so it can be completely hidden
}

; Mount the CD using Virtual Drive
If (epsxeExtension && vdEnabled = "true") {
	RLLog.Info("Module - Virtual Drive is enabled and " . romExtension . " is a supported Virtual Drive extension")

	VirtualDrive("get")	; populates the vdDriveLetter variable with the drive letter to your scsi or dt virtual drive
	currentCDRomAscii := Registry.Read("HKCU","Software\epsxe\config","CdromLetter")	; read the current setting for ePSXe's cdrom it is using
	currentCDRomLetter := Chr(currentCDRomAscii)	; converts the ascii code to a letter

	If (currentCDRomLetter = "")
		RLLog.Info("Module - " . MEmu . " is not configured with a CDRom Drive")
	Else If (currentCDRomAscii = 48)
		RLLog.Info("Module - " . MEmu . " is configured to read from the FirstCdrom Drive and will be updated to a proper letter instead")
	Else
		RLLog.Info("Module - " . MEmu . " is configured to read from Drive " . currentCDRomLetter . ":")
	
	If (currentCDRomLetter != vdDriveLetter) {
		newCDRomAscii := Asc(vdDriveLetter)	; converts the letter to an ascii code
		Registry.Write("REG_SZ","HKCU","Software\epsxe\config","CdromLetter",newCDRomAscii)
		RLLog.Warning("Module - Updated " . MEmu . " to use Drive " . vdDriveLetter . ": for all future launches.")
	} Else
		RLLog.Info("Module - " . MEmu . " is configured to use the correct drive already")

	VirtualDrive("mount",romPath . "\" . romName . romExtension)
	HideAppStart(hideEmuObj,hideEmu)
	errorLvl := primaryExe.Run(noGUI . slowBoot)
	usedVD := 1
} Else {
	If (romExtension = ".pbp") {
		RLLog.Info("Module - Sending rom to emu directly with the load binary directive.")
		HideAppStart(hideEmuObj,hideEmu)
		errorLvl := primaryExe.Run(noGUI . slowBoot . " -loadbin """ . romPath . "\" . romName . romExtension . """")
	} Else {
		RLLog.Info("Module - Sending rom to emu directly as Virtual Drive is not enabled or " . romExtension . " is not a supported Virtual Drive extension.")
		HideAppStart(hideEmuObj,hideEmu)
		errorLvl := primaryExe.Run(noGUI . slowBoot . " -loadiso """ . romPath . "\" . romName . romExtension . """")
	}
}
If errorLvl
	ScriptError("Error launching " . executable . "`, closing module.")

epsxeLaunchType := If usedVD ? "CDROM" : "ISO"	; determines which command gets sent to epsxe

If (noGUI = "") {	; for multi disc games only
	RLLog.Info("Module - " . romName . " is a multi-disc game, so launching " . MEmu . " with GUI enabled so swapping can occur.")
	emuGUIWindow.Wait()
	If (epsxeLaunchType = "CDROM") {
		RLLog.Info("Module - Telling ePSXe to run a CDROM")
		emuGUIWindow.PostMessage(0x111,40001)		; Run CDROM
	} Else {
		RLLog.Info("Module - Telling ePSXe to run an ISO")
		emuGUIWindow.PostMessage(0x111,40003)		; Run ISO
	}
} Else
	RLLog.Info("Module - " . romName . " is not a multi-disc game, so launching " . MEmu . " with GUI disabled.")

If (!usedVD && noGUI = "") {		; for some reason, epsxe still shows an open psx iso box even though it was provided on the run command when we don't also send -nogui. This handles loading the rom.
	RLLog.Info("Module - " . MEmu . " GUI and DT support are both disabled. Loading rom via the Open PSX ISO window.")
	emuOpenRomWindow.OpenROM(romPath . "\" . romName . romExtension)
}	

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If (noGUI = "" && hideEpsxeGUIs = "true") {	; for multi disc games only
	RLLog.Info("Module - Stopping the HideGUIWindow timer")
	SetTimer, HideGUIWindow, Off
}

BezelDraw()
HideEmuEnd()
FadeInExit()

; Enable Analog mode. During boot, presses F5 twice to enable Flight Stick mode if enableFlightStick is true. Presses F5 once for all other controllers except Digital.
If (enableFlightStick = "true") {
	MiscUtils.SetKeyDelay(50)
	TimerUtils.Sleep(enableAnalogDelay . "000")
	KeyUtils.Send("{F5 down}")
	TimerUtils.Sleep(250)
	KeyUtils.Send("{F5 up}")
	TimerUtils.Sleep(500)	; Half second delay until second F5 keypress
	KeyUtils.Send("{F5 down}")
	TimerUtils.Sleep(250)
	KeyUtils.Send("{F5 up}")
} Else If (GamepadType_Port1 = "2,1,1,1" or "5,1,1,1" or "4,1,1,1" or "7,1,1,1" or "3,1,1,1" or "8,1,1,1") {
	MiscUtils.SetKeyDelay(50)
	TimerUtils.Sleep(enableAnalogDelay . "000")
	KeyUtils.Send("{F5 down}")
	TimerUtils.Sleep(250)
	KeyUtils.Send("{F5 up}")
}

primaryExe.Process("WaitClose")

; If NeGcon controller selected, restores the original GamepadFullAxis registry key, then deletes the GamepadFullAxis.bak backup registry key.
If (GamepadTypePlayer1 = "7") {
	Registry.Write("REG_SZ","HKCU","Software\epsxe\config","GamepadFullAxis",RegVarGamepadFullAxis)
	Registry.Delete("HKCU","Software\epsxe\config","GamepadFullAxis.bak")
}	

If usedVD
	VirtualDrive("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	If (Fullscreen = "true") {
		emuGUIWindow.PostMessage(0x111,40001)	; Go fullscreen, same as alt+enter
		TimerUtils.Sleep(200)
	}
Return

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	MiscUtils.SetKeyDelay(50)
	If usedVD {
		VirtualDrive("unmount")	; Unmount the CD from Virtual Drive
		TimerUtils.Sleep(500)	; Required to prevent your Virtual Drive app from bugging
		VirtualDrive("mount",selectedRom)	; Mount the CD using Virtual Drive
	}
	emuPrimaryWindow.GetControl("TopMost").Send("{ESC down}{ESC Up}")	; this exits the game window and brings back ePSXe's gui menu window
	If (hideEpsxeGUIs = "true") {
		RLLog.Info("Module - Starting the HideGUIWindow timer to prevent them from showing")
		SetTimer, HideGUIWindow, 10
	}

	If (epsxeLaunchType = "CDROM") {
		RLLog.Info("Module - Telling ePSXe to swap to another CDROM")
		emuGUIWindow.PostMessage(0x111,40005)		; Change Disc CDROM
	} Else {
		RLLog.Info("Module - Telling ePSXe to swap to another ISO")
		emuGUIWindow.PostMessage(0x111,40006)		; Change Disc ISO
	}

	If usedVD {
		emuChangeDiscWindow.Wait()
		emuChangeDiscWindow.GetControl("Button1").Send("{Enter}")	; ControlSend Enter key
	} Else {
		emuOpenRomWindow.OpenROM(selectedRom)
	}	
	If (hideEpsxeGUIs = "true") {
		RLLog.Info("Module - Stopping the HideGUIWindow timer")
		SetTimer, HideGUIWindow, off
	}
	; If BezelEnabled
		; BezelDraw()
Return

RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	If (Fullscreen = "true")
		emuGUIWindow.PostMessage(0x111,40001)		; Go fullscreen, same as alt+enter
Return

HideGUIWindow:
	emuGUIWindow.Set("Transparent","On")
	emuOpenRomWindow.Set("Transparent","On")	; when not using DT
	emuChangeDiscWindow.Set("Transparent","On")	; when not using DT
Return

CloseProcess:
	FadeOutStart()
	MiscUtils.SetWinDelay(50)
	RLLog.Info("Module - Sending Escape to close emulator")
	If (noGUI = "") {	; for multi disc games only
		emuPrimaryWindow.PostMessage(0x111,40007)		; Exit ePSXe, only works when guis are used though, basically when multigame supported games are launched
		emuGUIWindow.Wait()
		emuGUIWindow.Close()
	} Else
		emuPrimaryWindow.GetControl("TopMost").Send("{ESC down}{ESC Up}") ; DO NOT CHANGE
		; ControlSend,, {Esc down}{Esc up}, ePSXe ahk_class EPSX ; DO NOT CHANGE
Return

; emuGUIWindow.PostMessage(0x111,40008)	; Continue
; emuGUIWindow.PostMessage(0x111,40009)	; Reset
