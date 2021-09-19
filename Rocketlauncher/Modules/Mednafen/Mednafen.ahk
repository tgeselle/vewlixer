MEmu := "Mednafen"
MEmuV := "v0.9.39.2"
MURL := ["http://mednafen.sourceforge.net/"]
MAuthor := ["djvj"]
MVersion := "2.1.8"
MCRC := "488A4354"
iCRC := "C757F6D3"
MID := "635038268903923913"
MSystem := ["Atari Lynx","Bandai Wonderswan","Bandai Wonderswan Color","NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD","Nintendo BS-X Satellaview","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Advance","Nintendo Game Boy Color","Nintendo Sufami Turbo","Nintendo Super Famicom","Nintendo Virtual Boy","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Saturn","ss","SNK Neo Geo Pocket","SNK Neo Geo Pocket Color","Sony PlayStation","Super Nintendo Entertainment System"]
;----------------------------------------------------------------------------
; Notes:
; Below are some basic params you can change, there are many other params
; located in the mednafen documentation that you can add If needed. You can check the docs here:
; https://mednafen.github.io/documentation/
;
; Some people experience screen flickering and mednafen will not stay in 
; fullscreen, you can changed vDriver below to -vdriver sdl and it will
; possibly fix the issue.
;
; There is no error checking If mednafen fails, so If you try to launch
; your game and nothing happens, then check the stdout.txt in your mednafen
; installation directory to see what went wrong.
;
; To remap your keys, start a game then press alt + shift + 1 to enter
; the key configuration for player 1. Similarly press alt + shift + 2 for player 2.
; To reconfigure hotkeys such as the exit key press F2 and then the hotkey whose mapping you wish to change.
; You can also edit the mednafen.cfg to change these keys directly there.
;
; Windows Aero:
; Since v0.9.33, the emu disables aero when launching mednafen in an effort to improve performance. This can also cause flashing among other issues namely bezel support not working.
; http://forum.fobby.net/index.php?t=msg&goto=3411&
; You can disable Desktop Composition by editing mednafen.cfg and adding this line to it:
; video.disable_composition 0

; Atari Lynx:
; Create a folder called "firmware" in your mednafen folder and place lynxboot.img in there
; If games are not rotating and the CLI command is being sent to the emu, your roms have bad headers
;
; Nintendo Virtual Boy:
; For Virtual Boy you might not be able to get in game and get stuck
; on the intro screen, so open your cfg file and change these settings
; to allow you to play. There are some extra options here to.
; vb.anaglyph.lcolor 0xFF0000
; vb.anaglyph.preset disabled
; vb.anaglyph.rcolor 0x000000
; vb.default_color 0xFFFFFF
; vb.disable_parallax 0
; vb.input.builtin.gamepad.a keyboard 109
; vb.input.builtin.gamepad.b keyboard 110
; vb.input.builtin.gamepad.down-l keyboard 100
; vb.input.builtin.gamepad.down-r keyboard 107
; vb.input.builtin.gamepad.left-l keyboard 115
; vb.input.builtin.gamepad.left-r keyboard 106
; vb.input.builtin.gamepad.lt keyboard 103
; vb.input.builtin.gamepad.rapid_a keyboard 46
; vb.input.builtin.gamepad.rapid_b keyboard 44
; vb.input.builtin.gamepad.right-l keyboard 102
; vb.input.builtin.gamepad.right-r keyboard 108
; vb.input.builtin.gamepad.rt keyboard 104
; vb.input.builtin.gamepad.select keyboard 118
; vb.input.builtin.gamepad.start keyboard 13
; vb.input.builtin.gamepad.up-l keyboard 101
; vb.input.builtin.gamepad.up-r keyboard 105

; Sony PlayStation Info:
; Create a folder called "firmware" in your mednafen folder and place all your bios files (ex. scph5501.bin) in there. Set the options in RLUI so mednafen can find them if needed
; This module only supports Virtual Drive when mounting with a cue extension for psx.
; Set your rom extension to cue
; Multi-Disc games REQUIRES Virtual Drive, do not attempt to swap discs any other way as it is not supported by this module.
;
; Sega Saturn Info:
; Create a folder called "firmware" in your mednafen folder and place all your bios files (ex. scph5501.bin) in there. Set the options in RLUI so mednafen can find them if needed
; King Of Fighters '95 and Ultraman - Hikari no Kyojin Densetsu are supported, in order to run them you'll need to place the cart dumps alongside with the CD images of the games and name them after the romName with the extension .rom. If you leave the roms in the default mednafen locations they should work as well, refer to the mednafen docs to know how to name them.
;
; Virtual Drive Support:
; Virtual Drive (aka Physical CD) support was removed in version 0.9.38 so if you are using a Mednafen version more recent than that make sure you disable Virtual Drive for the systems that use it otherwise they won't work.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()
 
primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"SDL_app"))		; instantiate primary emulator window object

; The next 2 objects control how the module reacts to different systems. Mednafen can play a lot of systems, but changes itself slightly so this module has to adapt 
mType1 := Object("Atari Lynx","lynx","Bandai Wonderswan","wswan","Bandai Wonderswan Color","wswan","NEC PC Engine","pce","NEC PC-FX","pcfx","NEC SuperGrafx","pce","NEC TurboGrafx-16","pce","Nintendo BS-X Satellaview","bsx","Nintendo Entertainment System","nes","Nintendo Famicom","nes","Nintendo Famicom Disk System","nes","Nintendo Game Boy","gb","Nintendo Game Boy Advance","gba","Nintendo Game Boy Color","gb","Nintendo Sufami Turbo","nst","Nintendo Super Famicom","snes","Nintendo Virtual Boy","vb","Samsung Gam Boy","sms","Sega Game Gear","gg","Sega Genesis","md","Sega Mega Drive","md","Sega Master System","sms","SNK Neo Geo Pocket","ngp","SNK Neo Geo Pocket Color","ngp","Super Nintendo Entertainment System","snes")
mType2 := Object("NEC PC Engine-CD","pce","NEC TurboGrafx-CD","pce","Sega Saturn","ss","Sony PlayStation","psx")	; these systems change Mednafen's window name, so it needs to be separate from the rest

ident1 := mType1[systemName]	; search 1st array for the systemName identifier mednafen uses
ident2 := mType2[systemName]	; search 2nd array for the systemName identifier mednafen uses
ident := If (!ident1 && !ident2) ? ("") : (ident1 . ident2)
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Mednafen module: " . moduleName)

; Settings used for all systems
Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Stretch := moduleIni.Read("Settings", "Stretch","aspect",,1)			; 0, aspect, or full
vDriver := moduleIni.Read("Settings", "vDriver","opengl",,1)				; opengl or sdl
xRes := moduleIni.Read("Settings", "xRes",0,,1)
yRes := moduleIni.Read("Settings", "yRes",0,,1)
Params := moduleIni.Read(romName . "|Settings", "Params",,,1)

stretch := " -" . ident . ".stretch " . Stretch
vDriver := If vDriver ? (" -vdriver " . vDriver) : ""
xRes := If xRes ? (" -" . ident . ".xres " . xRes) : ""
yRes := If yRes ? (" -" . ident . ".yres " yRes) : ""
Params := If Params ? (" " . Params) : ""

;Defining screen orientation
resolutionsIni := new IniFile(A_ScriptDir . "\Settings\" systemName . "\resolutions.ini")
gameRes := resolutionsIni.ReadCheck(dbname,"Resolution",,,1)  
res := StringUtils.Split(gameRes,x)		; res[1]=Width, res[2]=Height 

If (ident = "lynx" or ident = "wswan")
	rotateScreen := If ((moduleIni.Read(romName, "RotateScreen",,,1) = "true") or (res[2]>res[1])) ? " -" . ident . ".rotateinput 1" : ""

If (ident = "lynx") {	; this needs to be before BezelStart so we can tell it if we need to rotate the screen or not
	lynxbootImgFile := new File(emuPath . "\firmware\lynxboot.img")
	lynxbootImgFile.CheckFile("Cannot find the Atari Lynx bios file required to use this system:`n" . lynxbootImgFile.FileFullPath)
}

BezelStart(,,(If rotateScreen ? 1:""))

emuFullscreen := If Fullscreen = "true" ? " -fs 1" : " -fs 0"	; This needs to stay after BezelStart

If (ident1 = "pce")
	sgfxMode := If (systemName = "NEC SuperGrafx" && romExtension != sgx) ? " -pce.forcesgx 1"  : ""

If (ident2 = "pce")
{	PCE_CD_Bios := moduleIni.Read("Bios", "PCE_CD_Bios","syscard3.pce",,1)		; Bios, placed in the firmware subfolder of the emu, required for these systems: NEC PC Engine-CD & NEC TurboGrafx-CD
	pceCDBiosFile := new File(emuPath . "\firmware\" . PCE_CD_Bios)
	pceCDBiosFile.CheckFile("Cannot find the PCE_CD_Bios  file you have defined in the module:`n" . pceCDBiosFile.FileFullPath)
	pceCDBios := If PCE_CD_Bios ? (" -pce.cdbios ""firmware\"  . PCE_CD_Bios  . """") : ""
}
If (ident = "pcfx")
{	PCFX_Bios := moduleIni.Read("Bios", "PCFX_Bios","pcfxbios.bin",,1)			; Bios, placed in the firmware subfolder of the emu, required for NEC PC-FX
	pcfxBiosFile := new File(emuPath . "\firmware\" . PCFX_Bios)
	pcfxBiosFile.CheckFile("Cannot find the PCFX_Bios  file you have defined in the module:`n" . pcfxBiosFile.FileFullPath)
	pcfxBios := If PCFX_Bios ? (" -pcfx.bios ""firmware\"  . PCFX_Bios  . """") : ""
}

If (ident = "psx")	; only need these for Sony PlayStation, must check If these files exist, otherwise mednafan doesn't launch and RocketLauncher gets stuck
{	NA_Bios := moduleIni.Read("Bios", "NA_Bios","PSX - SCPH1001.bin",,1)		; Sony PlayStation only - this is the bios you want to use for North American games - place this in a "firmware" subfolder where Mednafen is
	EU_Bios := moduleIni.Read("Bios", "EU_Bios","PSX - SCPH5502.bin",,1)		; Sony PlayStation only - this is the bios you want to use for European games - place this in a "firmware" subfolder where Mednafen is
	JP_Bios := moduleIni.Read("Bios", "JP_Bios","PSX - SCPH5500.bin",,1)		; Sony PlayStation only - this is the bios you want to use for Japanese games - place this in a "firmware" subfolder where Mednafen is
	naBiosFile := new File(emuPath . "\firmware\" . NA_Bios)
	euBiosFile := new File(emuPath . "\firmware\" . EU_Bios)
	jpBiosFile := new File(emuPath . "\firmware\" . JP_Bios)
	naBiosFile.CheckFile("Cannot find the PSX NA_Bios file you have defined in the module:`n" . naBiosFile.FileFullPath)
	euBiosFile.CheckFile("Cannot find the PSX EU_Bios file you have defined in the module:`n" . euBiosFile.FileFullPath)
	jpBiosFile.CheckFile("Cannot find the PSX JP_Bios file you have defined in the module:`n" . jpBiosFile.FileFullPath)
	naBios := If NA_Bios ? " -psx.bios_na ""firmware\" . NA_Bios . """" : ""
	euBios := If EU_Bios ? " -psx.bios_eu ""firmware\" .  EU_Bios . """" : ""
	jpBios := If JP_Bios ? " -psx.bios_jp ""firmware\"  . JP_Bios . """" : ""
}

If (ident = "ss")	; only need these for Sega Saturn, must check If these files exist, otherwise mednafan doesn't launch and RocketLauncher gets stuck
{	NA_Bios := moduleIni.Read("Bios", "Saturn_NA_Bios","mpr-17933.bin",,1)	; Sega Saturn only - this is the bios you want to use for North American games - place this in a "firmware" subfolder where Mednafen is
	EU_Bios := moduleIni.Read("Bios", "Saturn_EU_Bios","sega_101.bin",,1)	; Sega Saturn only - this is the bios you want to use for European games - place this in a "firmware" subfolder where Mednafen is
	JP_Bios := moduleIni.Read("Bios", "Saturn_JP_Bios","sega_101.bin",,1)	; Sega Saturn only - this is the bios you want to use for Japanese games - place this in a "firmware" subfolder where Mednafen is
	naBiosFile := new File(emuPath . "\firmware\" . NA_Bios)
	; euBiosFile := new File(emuPath . "\firmware\" . EU_Bios)
	jpBiosFile := new File(emuPath . "\firmware\" . JP_Bios)
	naBiosFile.CheckFile("Cannot find the Saturn NA_Bios file you have defined in the module:`n" . naBiosFile.FileFullPath)
	; euBiosFile.CheckFile("Cannot find the Saturn EU_Bios file you have defined in the module:`n" . euBiosFile.FileFullPath)
	jpBiosFile.CheckFile("Cannot find the Saturn JP_Bios file you have defined in the module:`n" . jpBiosFile.FileFullPath)
	naBios := If NA_Bios ? " -ss.bios_na_eu ""firmware\" . NA_Bios . """" : ""
	; euBios := If EU_Bios ? " -ss.bios_eu ""firmware\" . EU_Bios . """" : ""		; mednafen doesn't support PAL yet so this setting will use the NA bios CLI until it does
	euBios := ""
	jpBios := If JP_Bios ? " -ss.bios_jp ""firmware\" . JP_Bios . """" : ""
	
	AutoDetectRegion := moduleIni.Read("Settings", "AutoDetectRegion","true",,1)
	ExpansionCart := moduleIni.Read(romName, "ExpansionCart","auto",,1)
	Region := moduleIni.Read(romName, "Region","",,1)

	If (!Region)
		Region := If (AutoDetectRegion = "true") ? "auto" : "none"

	; Setup Expansion Carts
	DataCartridgeFile := new File(romPath . "\" . romName . ".rom")
	If DataCartridgeFile.Exist() {		; Only 2 known games need this, Ultraman - Hikari no Kyojin Densetsu (Japan) and King of Fighters '95, The (Europe).
		RLLog.Info("Module - This game requires a data cart in order to play. Trying to mount the cart: """ . DataCartridgeFile.FileFullPath . """")
		If !DataCartridgeFile.Exist()
			ScriptError("Could not locate the Data Cart for this game. Please make sure one exists inside the archive of this game or in the folder this game resides and it is called: """ . romName . ".rom""")
		If (StringUtils.Contains(romName, "King of Fighters"))
			SysParams := "-ss.cart.kof95_path """ .  DataCartridgeFile.FileFullPath . """"
		Else If (StringUtils.Contains(romName, "Ultraman"))
			SysParams := "-ss.cart.ultraman_path """ .  DataCartridgeFile.FileFullPath . """"
	} Else If (ExpansionCart) {
		SysParams := "-ss.cart " . ExpansionCart
	}

	; Configuring Region
	If (Region = "auto")
		SysParams := SysParams . " -ss.region_autodetect 1"
	Else If (Region = "none")
		SysParams := SysParams . " -ss.region_autodetect 0"
	Else
		SysParams := SysParams . " -ss.region_default " . Region

	SysParams := If SysParams ? (" " . SysParams) : ""
}

If bezelPath ; defining xscale and yscale relative to the bezel windowed mode
{
	If res[1] {
		baseWidth := res[1]
		baseHeight := res[2]
	} Else {
			baseWidthArray := [] 
			baseWidthArray["lynx", "width"] := 160 , baseWidthArray["lynx", "height"] := 102
			baseWidthArray["wswan", "width"] := 224 , baseWidthArray["wswan", "height"] := 144
			baseWidthArray["pce", "width"] := 288 , baseWidthArray["pce", "height"] := 231
			baseWidthArray["pcfx", "width"] := 341 , baseWidthArray["pcfx", "height"] := 480
			baseWidthArray["nes", "width"] := 298 , baseWidthArray["nes", "height"] := 240
			baseWidthArray["gb", "width"] := 160 , baseWidthArray["gb", "height"] := 144
			baseWidthArray["gba", "width"] := 240 , baseWidthArray["gba", "height"] := 160
			baseWidthArray["snes", "width"] := 256 , baseWidthArray["snes", "height"] := 224
			baseWidthArray["vb", "width"] := 384 , baseWidthArray["vb", "height"] := 224
			baseWidthArray["gg", "width"] := 160 , baseWidthArray["gg", "height"] := 144
			baseWidthArray["md", "width"] := 320 , baseWidthArray["md", "height"] := 480
			baseWidthArray["sms", "width"] := 256 , baseWidthArray["sms", "height"] := 240
			baseWidthArray["ngp", "width"] := 160 , baseWidthArray["ngp", "height"] := 152
			baseWidthArray["psx", "width"] := 320 , baseWidthArray["psx", "height"] := 240
			baseWidthArray["ss", "width"] := 301 , baseWidthArray["ss", "height"] := 240
			baseWidth := (If rotateScreen ? baseWidthArray[ident,"height"]:baseWidthArray[ident,"width"])
			baseHeight := (If rotateScreen ? baseWidthArray[ident,"width"]:baseWidthArray[ident,"height"])
		}
	bezelXres := moduleIni.Read(romName . "|Settings", "Bezel_X_Res",baseWidth,,1)	; Controls width of the emu's window, relative to the bezel's window
	bezelYres := moduleIni.Read(romName . "|Settings", "Bezel_Y_Res",baseHeight,,1)	; Controls height of the emu's window, relative to the bezel's window
	xscale := round(bezelScreenWidth / bezelXres,2)
	yscale := round(bezelScreenHeight / bezelYres,2)
	xscale := " -" . ident . ".xscale " . xscale
	yscale := " -" . ident . ".yscale " . yscale
}

;----------------------------------------------------------------------------

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

; Mount the CD using Virtual Drive
If ((romExtension = ".cue" || romExtension = ".ccd" || romExtension = ".iso") && vdEnabled = "true" && (ident = "psx" || ident = "pce")) {	; only Sony PlayStation tested
	RLLog.Info("Module - Mounting rom in Virtual Drive")
	VirtualDrive("get")
	VirtualDrive("mount",romPath . "\" . romName . romExtension)
	usedVD := 1
}

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" " . emuFullscreen . stretch . vDriver . (If Fullscreen = "true" ? xRes . " " . yRes : xscale . " " . yscale) . sgfxMode . naBios . euBios . jpBios . pceCDBios . pcfxBios . rotateScreen . SysParams . Params . (If usedVD ? " -physcd " . vdDriveLetter . ":" : " """ . romPath . "\" . romName . romExtension . """"))

; WinWait, % (If ident2 ? ("Mednafen") : (romName)) . " ahk_class SDL_app"
; WinWaitActive, % (If ident2 ? ("Mednafen") : (romName)) . " ahk_class SDL_app"
emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()
BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

errorLvl := primaryExe.Process("Exist")
If errorLvl != 0
	primaryExe.Process("WaitClose")

If usedVD
	VirtualDrive("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

MultiGame:
	If usedVD {
		KeyUtils.SetKeyDelay(50)
		KeyUtils.Send("{F8 down}{F8 up}")	; eject disc in mednafen - MIGHT WANT TO TRY DOING A CONTROLSEND
		VirtualDrive("unmount")
		TimerUtils.Sleep(500)	; Required to prevent your Virtual Drive from bugging
		VirtualDrive("mount",selectedRom)
		emuPrimaryWindow.Activate()
		KeyUtils.Send("{F8 down}{F8 up}")	; eject disc in mednafen
	}
Return
RestoreEmu:
	If (fullscreen = "true")
		emuPrimaryWindow.Maximize()	; mednafen will not restore unless this command is used
	emuPrimaryWindow.Activate()
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
	; WinClose, % (If ident2 ? ("Mednafen") : (romName)) . " ahk_class SDL_app"
Return
