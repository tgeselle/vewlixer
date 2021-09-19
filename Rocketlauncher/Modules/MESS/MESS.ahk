MEmu := "MESS"
MEmuV := "v0.161"
MURL := ["http://www.mess.org/"]
MAuthor := ["djvj","faahrev","brolly","Tomkun"]
MVersion := "2.3.7"
MCRC := "C9AE582F"
iCRC := "8E78A0D8"
MID := "635038268905515239"
MSystem := ["Aamber Pegasus","Acorn Electron","Amstrad GX4000","APF Imagination Machine","Apple IIGS","Atari 8-bit","Atari 2600","Atari 5200","Atari 7800","Atari Jaguar","Atari Lynx","Bally Astrocade","Bandai WonderSwan","Bandai WonderSwan Color","Casio PV-1000","Casio PV-2000","Coleco ADAM","ColecoVision","Creatronic Mega Duck","Emerson Arcadia 2001","Entex Adventure Vision","Epoch Game Pocket Computer","Epoch Super Cassette Vision","Exidy Sorcerer","Fairchild Channel F","Funtech Super Acan","GCE Vectrex","Hartung Game Master","Interton VC 4000","JungleTac Sport Vii","Magnavox Odyssey 2","Matra & Hachette Alice","Mattel Aquarius","Mattel Intellivision","Applied Technology MicroBee","NEC PC Engine","NEC PC Engine-CD","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD","Nintendo 64","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Advance","Nintendo Game Boy Color","Nintendo Super Famicom","Nintendo Super Game Boy","Nintendo Virtual Boy","Philips CD-i","RCA Studio II","Sega 32X","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega SG-1000","Sinclair ZX81","SNK Neo Geo AES","SNK Neo Geo CD","SNK Neo Geo Pocket","SNK Neo Geo Pocket Color","Sony PlayStation","Sony PocketStation","Sord M5","Super Nintendo Entertainment System","Tandy TRS-80 Color Computer","Texas Instruments TI 99-4A","Tiger Game.com","Tomy Tutor","VTech CreatiVision","Watara Supervision"]
;----------------------------------------------------------------------------
; Notes:
; Exit fade will only work correctly if you don't have Esc, the default MESS exit key,  as your exit key. If you use Esc, turn off the ExitScreen
; This module will set your rom paths on the fly via CLI, but you must make sure the RLUI module setting for this module "MESS_BIOS_Path" is correctly set. It defaults to your roms subfolder where mess.exe is found.
; This module assumes you have bios zip in your MESS "roms" directory, which might be different than your actual roms directory, for each system you need this module for. All tested systems listed below
; If MESS has a problem reading the bios zips, try archving them with "no compression"
; This site can help a ton with details for the various systems supported: http://www.progettoemma.net/mess/index.html
; You may get a black screen or MESS may close w/o notice if you do not have a bios rom for your system when one is needed.
; If you use bezel, it is recommended to set the module bezel mode to normal, and go to your mess.ini file, on your emulator folder, and choose these options: artwork_crop 1, use_backdrops 1, use_overlays 1, use_bezels 0 
;
; Following systems require a BIOS zip with their roms inside, placed in the "Mess\Roms\" directory:
; Amstrad GX4000 - N/A
; APF Imagination Machine - apfimag (tape games), apfm1000 (cart games)
; Apple IIGS - apple2gs
; Atari 800 - a800
; Atari 5200 - a5200
; Atari 7800 - a7800
; Atari Jaguar - jaguar
; Atari Lynx - lynx
; Bally Astrocade - astrocde
; Bandai WonderSwan - N/A
; Bandai WonderSwan Color - N/A
; Casio PV-2000 - pv2000
; Coleco ADAM - adam, adam_ddp, adam_fdc, adam_kb, adam_prn, adam_spi
; ColecoVision - coleco
; Creatronic Mega Duck - N/A
; Emerson Arcadia 2001 - N/A
; Entex Adventure Vision - advision
; Epoch Game Pocket Computer - gamepock
; Epoch Super Cassette Vision - scv
; Exidy Sorcerer - sorcerer
; Fairchild Channel F - channelf
; Funtech Super ACan - supracan
; GCE Vectrex - vextrex
; Hartung Game Master - gmaster
; Interton VC 4000 - vc4000
; JungleTac Sport Vii - vii
; Magnavox Odyssey 2 - odyssey2
; Matra & Hachette Alice - alice32
; Mattel Aquarius - aquarius
; Mattel Intellivision - intv ("exec.bin" [8,192 bytes] & "grom.bin" [2,048 bytes])
; MGT Sam Coupe - samcoupe
; NEC PC Engine - N/A
; NEC PC Engine-CD - N/A
; NEC SuperGrafx - N/A
; NEC TurboGrafx-16 - N/A
; NEC TurboGrafx-CD - "Super CD-ROM2 System V3.01 (U).pce" [262,144 bytes] (placed in the roms subfolder in the emuPath)
; Nintendo 64 - n64
; Nintendo Entertainment System - N/A
; Nintendo Famicom - famicom
; Nintendo Famicom Disk System - fds
; Nintendo Game Boy - gameboy
; Nintendo Game Boy Advance - gba
; Nintendo Game Boy Color - gbcolor
; Nintendo Super Famicom - supergb
; Nintendo Super Game Boy - supergb
; Nintendo Virtual Boy - N/A
; Philips CD-i - the cdimono1
; RCA Studio II - studio2
; Sega 32X - 32x
; Sega CD - segacd, megacd, megacd2j (megacd2j seems to be more compatible over megacdj)
; Sega Game Gear - gamegear
; Sega Genesis - N/A
; Sega Master System - sms
; Sega Mega Drive - N/A
; Sinclair ZX81 - zx81
; SNK Neo Geo AES - aes
; SNK Neo Geo CD - neocd
; SNK Neo Geo Pocket - ngp
; SNK Neo Geo Pocket Color - ngpc
; Sony PlayStation - psa, pse, psj, psu
; Sony PocketStation - pockstat
; Sord M5 - m5
; Super Nintendo Entertainment System - snes
; Tandy TRS-80 Color Computer - coco3
; Texas Instruments TI 99-4A - ti99_4a
; Tiger Game.com - gamecom
; Tomy Tutor - tutor
; VTech CreatiVision - crvision
; Watara Supervision - N/A
;
; Custom Configuration Files:
; If you want to use custom configuration files (.cfg files) for some games you will need to store them inside your MESS cfg folder using the following structure:
; cfg\mess_system_name\database_rom_name\mess_system_name.cfg
; An example of a game that requires specific settings is ICBM Attack for the Bally Astrocade, in this case special cfg file should be:
; cfg\astrocde\I.C.B.M. Attack (USA) (Unl)\astrocde.cfg
;
; Bally Astrocade:
; ICBM requires a soft reset (even on the real hardware) to launch. You can read about it here: http://www.ballyalley.com/ballyalley/articles/Playing_ICBM_Attack_Using_MESS.pdf
; A custom build of MESS is needed to play this game if you don't want to press F3 manually each time you play ICBM. The custom build enables DirectInput so it is possible to script a soft reset in.
; I compiled a mess with this turned on and it can be found in my user dir @ /Upload Here/djvj/Bally Astrocade/
; Also ICBM uses different controls then the rest of the games. Make sure you follow the procedure explained above under "Custom Configuration Files" to create such file.
; Rom extensions should be zip,bin,txt
; Create a txt file in your rom dir called "Gunfight+Checkmate+Calculator+Scribbling (USA).txt" This game is built into the system and no rom is required to play it.
;
; GCE Vectrex:
; Requires a vectrex.lay and a png overlay for each game. These all need to be placed in the mess\artwork\vectrex folder.
; You can download all these pngs and the lay file in my ftp folder. You need to use the HyperList XML to match the pngs.
;
; Magnavox Odyssey 2:
; Euro games should use the videopac bios instead of the odyssey2 one or you'll get some timing issues.
; Use the systemName ini file in the folder with this module for this, example:
; [Moto-Crash (France)]
; Bios=videopac
;
; Texas Instruments TI 99/4A:
; This system requires full keyboard emulation to work properly
; Split cart dumps are not supported since MESS .145 so you'll have to convert them to RPK format or use an earlier version of MESS (and a different module)
; You can check how to convert split cart dumps to RPK here:
; http://www.ninerpedia.org/index.php/MESS_multicart_system
; For floppy games make sure you have a RPK dump of an extended basic rom on your roms folder. It should be named "extended_basic.rpk"

; Bezels:
; Module settings control whether RocketLauncher or MESS bezels are shown
; In the bezel normal mode only RocketLauncher Bezels will be show and the MESS use_bezels option will be forced disbaled
; In the bezel layout mode, RocketLauncher Bezels will be drawn only when you do not have a layout file on your MESS folders for the current game
;
; Per game controller types:
; MESS allows you to change the controller type for each game by using slot devices. Slot devices are highly customizable and vary greatly from system to 
; system so to avoid adding a huge complexity to the module this must be done through the Parameters settings.
; Slot devices are stored in the MESS ini file you are using, so the best way to find the command line you need to use is to start your game set the slot devices 
; through the MESS UI (Press tab while in MESS) exit and then open the MESS ini file and search for a section named SLOT DEVICES.
; This is an example for Atari 2600 for a game using wheel controllers on both joy ports:
; #
; # SLOT DEVICES
; #
; joyport1     wheel
; joyport2     wheel
; The suggested method is to set the desired controllers you want to use by default in the Module Global Settings, in this case under the Atari 2600 tab you would 
; set Parameters=-joyport1 joy -joyport2 joy
; And then for specific games do the same under Module Specific Settings for that system, if a game requires the wheel controller you'd set 
; Parameters=-joyport1 wheel -joyport2 wheel
;
; Another option is to set the default values in the MESS ini file and make sure you also set writeconfig to 0.
; Swapping slot devices wipes out SYSTEM custom configs on the unplugged controllers, so to avoid any customised controls getting erased everytime you change slot devices, 
; ensure you set your controls in the main MESS config file (MESS.ini), not the system one (ex. Atari 2600.ini).
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; This object controls how the module reacts to different systems. MESS can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mTypeVar=
	( LTrim
	Aamber Pegasus|pegasus
	Acorn Electron|electron
	Amstrad GX4000|gx4000
	APF Imagination Machine|apfimag
	Apple IIGS|apple2gs
	Atari 8-bit|a800
	Atari 2600|a2600
	Atari 5200|a5200
	Atari 7800|a7800
	Atari Jaguar|jaguar
	Atari Lynx|lynx
	Bally Astrocade|astrocde
	Bandai WonderSwan|wswan
	Bandai WonderSwan Color|wscolor
	Casio PV-1000|pv1000
	Casio PV-2000|pv2000
	Coleco ADAM|adam
	ColecoVision|coleco
	Creatronic Mega Duck|megaduck
	Emerson Arcadia 2001|arcadia
	Entex Adventure Vision|advision
	Epoch Game Pocket Computer|gamepock
	Epoch Super Cassette Vision|scv
	Exidy Sorcerer|sorcerer
	Fairchild Channel F|channelf
	Funtech Super Acan|supracan
	GCE Vectrex|vectrex
	Hartung Game Master|gmaster
	Interton VC 4000|vc4000
	JungleTac Sport Vii|vii
	Magnavox Odyssey 2|odyssey2
	Matra & Hachette Alice|alice32
	Mattel Aquarius|aquarius
	Mattel Intellivision|intv
	Applied Technology MicroBee|mbeeic
	NEC PC Engine|pce
	NEC PC Engine-CD|pce
	NEC SuperGrafx|sgx
	NEC TurboGrafx-16|tg16
	NEC TurboGrafx-CD|tg16
	Nintendo 64|n64
	Nintendo Entertainment System|nes
	Nintendo Famicom|famicom
	Nintendo Famicom Disk System|fds
	Nintendo Game Boy|gameboy
	Nintendo Game Boy Advance|gba
	Nintendo Game Boy Color|gbcolor
	Nintendo Super Famicom|snes
	Nintendo Super Game Boy|supergb
	Nintendo Virtual Boy|vboy
	Philips CD-i|cdimono1
	RCA Studio II|studio2
	Sega 32X|32x
	Sega CD|segacd
	Sega Game Gear|gamegear
	Sega Genesis|genesis
	Sega Master System|sms
	Sega Mega Drive|megadriv
	Sega SG-1000|sg1000
	Sinclair ZX81|zx81
	SNK Neo Geo AES|aes
	SNK Neo Geo CD|neocdz
	SNK Neo Geo Pocket|ngp
	SNK Neo Geo Pocket Color|ngpc
	Sony PlayStation|psx
	Sony PocketStation|pockstat
	Sord M5|m5
	Super Nintendo Entertainment System|snes
	Tandy TRS-80 Color Computer|coco3
	Texas Instruments TI 99-4A|ti99_4a
	Tiger Game.com|gamecom
	Tomy Tutor|tutor
	VTech CreatiVision|crvision
	Watara Supervision|svision
	)
mType := Object()
Loop, Parse, mTypeVar, `n, `r
{
	obj := {}
	Loop, Parse, A_LoopField, |
		If A_Index = 1
			obj.System := A_LoopField
		Else	; 2
			obj.MessID := A_LoopField
	mType.Insert(obj["System"], obj)
}
Log("Module - Finished building the " . MEmu . " object",4)
; For easier use throughout the module
messSystem := mType[systemName].System
messID := mType[systemName].MessID

If !messSystem
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module.")

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)		; Set fullscreen mode
messBiosPath := IniReadCheck(settingsFile, "Settings", "MESS_BIOS_Path", emuPath . "\roms",,1)
Videomode := IniReadCheck(settingsFile, "Settings", "Videomode","d3d",,1)	; Choices are gdi,ddraw,d3d. If left blank, mess uses d3d by default
hlsl := IniReadCheck(settingsFile, "Settings|" . messSystem . "|" . romName, "HLSL","false",,1)
glsl := IniReadCheck(settingsFile, "Settings|" . messSystem . "|" . romName, "GLSL","false",,1)
bezelMode := IniReadCheck(settingsFile, "Settings", "BezelMode","layout",,1)	; "layout" or "normal"
UseSoftwareList := IniReadCheck(settingsFile, messSystem, "UseSoftwareList","false",,1)
sysStaticParams := IniReadCheck(settingsFile, messSystem, "StaticParameters", A_Space,,1)
sysParams := IniReadCheck(settingsFile, messSystem, "Parameters", A_Space,,1)
romParams := IniReadCheck(settingsFile, romName, "Parameters", sysParams,,1)
Artwork_Crop := IniReadCheck(settingsFile, messSystem . "|" . romName, "Artwork_Crop", "true",,1)
Use_Bezels := IniReadCheck(settingsFile, messSystem . "|" . romName, "Use_Bezels", "false",,1)
Use_Overlays := IniReadCheck(settingsFile, messSystem . "|" . romName, "Use_Overlays", "true",,1)
Use_Backdrops := IniReadCheck(settingsFile, messSystem . "|" . romName, "Use_Backdrops", "true",,1)
messBiosPath := GetFullName(messBiosPath)

;Read settings from system name ini file
sysSettingsFile := modulePath . "\" . messSystem . ".ini"
IfExist, %sysSettingsFile% 
{
	romParams := IniReadCheck(sysSettingsFile, romName, "Parameters", romParams,,1)
	hlsl := IniReadCheck(sysSettingsFile, romName, "HLSL",hlsl,,1)
	glsl := IniReadCheck(sysSettingsFile, romName, "GLSL",glsl,,1)
	Artwork_Crop := IniReadCheck(sysSettingsFile, romName, "Artwork_Crop", Artwork_Crop,,1)
	Use_Bezels := IniReadCheck(sysSettingsFile, romName, "Use_Bezels", Use_Bezels,,1)
	Use_Overlays := IniReadCheck(sysSettingsFile, romName, "Use_Overlays", Use_Overlays,,1)
	Use_Backdrops := IniReadCheck(sysSettingsFile, romName, "Use_Backdrops", Use_Backdrops,,1)
}

artworkCrop := If (Artwork_Crop = "true") ? " -artwork_crop" : " -noartwork_crop"
useBezels := If (Use_Bezels = "true") ? " -use_bezels" : " -nouse_bezels"
useOverlays := If (Use_Overlays = "true") ? " -use_overlays" : " -nouse_overlays"
useBackdrops := If (Use_Backdrops = "true") ? " -use_backdrops" : " -nouse_backdrops"

; Get MESS version from executable, this is needed since some CLI switches are not available in older MESS versions
exeAtrib := FileGetVersionInfo_AW( EmuPath . "\" . executable, "FileVersion|ProductVersion", "|"  )
Loop, Parse, exeAtrib, |%A_Tab%, %A_Space%
 A_Index & 1 ? ( _ := A_LoopField ) : ( %_% := A_LoopField )
If (ProductVersion)
	StringRight, MESSVersion, ProductVersion, StrLen(ProductVersion) - 2
Log("Detected MESS Product Version from '" . EmuPath . "\" . executable . "' is " . MESSVersion)

hideEmuObj := Object(dialogOpen . " ahk_class ConsoleWindowClass",0,"ahk_class MAME",1)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

If bezelEnabled = true
{	
	ListXMLtable := []
	ListXMLtable := ListXMLInfo(romName)
	If (bezelMode = "layout"){
		BezelStart("layout",ListXMLtable[1],ListXMLtable[2],romName)
	} else { ;bezel mode = normal
		useBezels := " -nouse_bezels"   ; force disabling MESS built-in bezels
		BezelStart(,,ListXMLtable[2])
	}
}

7z(romPath, romName, romExtension, 7zExtractPath)

winstate := If (Fullscreen = "true") ? "Hide UseErrorLevel" : "UseErrorLevel"
fullscreen := If (Fullscreen = "true") ? " -nowindow" : " -window"
If (Videomode = "opengl")
{
	hlsl := " -nohlsl_enable"
	If (MESSVersion > 159)
		glsl := If glsl = "true" ? " -gl_glsl" : (If glsl = "ini" ? "" : " -nogl_glsl")
	Else
		glsl := ""
}
Else
{
	hlsl := If hlsl = "true" ? " -hlsl_enable" : (If hlsl = "ini" ? "" : " -nohlsl_enable")
	If (MESSVersion > 159)
		glsl := If Videomode = "ini" ? "" : " -nogl_glsl"
	Else
		glsl := ""
		
	If (Videomode = "ini")
		Videomode := ""
}
videomode := If (Videomode != "" )? " -video " . videomode : ""
param1 := " -cart """ . romPath . "\" . romName . romExtension . """"	; default param1 used for launching most systems.

If romExtension = .txt	; This can be applied to all systems
	param1:=

If messID = apfimag	; APF Imagination Machine
	If romExtension != .tap
		messID = apfm1000	; cart games for APF Imagination Machine require a different bios to be loaded

If UseSoftwareList != true
{	; Now that we know the system we are loading, determine if we use an ini assocated with that system for custom game configs a user might need. Then load the configs associated to that game.
	If messID in ti99_4a,aes,apple2gs,electron,mbeeic,odyssey2	; these systems will use an ini to store game specific settings
	{	messSysINI := CheckFileMESS(modulePath . "\" . messSystem . ".ini")	; create the ini if it does not exist
		If messID = ti99_4a	; Texas Instruments TI 99-4A
		{	mainCart := IniReadCheck(messSysINI, romName, "Main_Cart",A_Space,,1)
			basicCart := IniReadCheck(messSysINI, romName, "Basic_Cart","extended_basic.rpk",,1)	; user can specify a rom specific cart instead of the default basic one
			expansionLocation := IniReadCheck(messSysINI, romName, "Expansion_Location","extended_basic.rpk",,1)
			; Now set the parameters to send to mess
			If romExtension = .dsk	; Expansion Disk
				; If using the mainCart , send expansionLocation to MESS. This will require DirectInput to be enabled on the MESS build! Else we are loading a Disk game
				param1 := " -gromport multi -cart1", param2:=" """ . romPath . "\" . (If mainCart ? (mainCart):(basicCart)) . """", param3:=" -peb:slot2 32kmem -peb:slot3 speech -peb:slot6 tirs232 -peb:slot8 hfdc", param4:=" -flop1", param5:=" """ . romPath . "\" . romName . romExtension . """"
			Else If romExtension = .rpk	; Cart Game (RPK Format)
				param1 := " -gromport single -cart1", param2:=" """ . romPath . "\" . romName . romExtension . """", param3:=" -peb:slot3 speech" ;-cart will also work here
			param6 := " -ui_active" ;Enable partial keyboard mode at startup
		} Else If messID = aes	; SNK Neo Geo AES
		{	biosRegion := IniReadCheck(messSysINI, romName, "BIOS_Region","asia",,1)
			param1 := " -bios " . biosRegion	; can also be japan, but the asian one has english menus for most games
			param2 := " -cart " . romName
		}Else if messID = apple2gs	; Apple IIGS
		{	externalOS := IniReadCheck(messSysINI, romName, "External_OS","false",,1)
			2gsSystemFile := "System6.2mg"	;For games without OS included, always force this name and error out if not found
			multipartTable := CreateRomTable(multipartTable)

			If externalOS = true
			{	CheckFile(romPath . "\" . 2gsSystemFile)
				param1 := " -flop3", param2:=" """ . romPath . "\" . 2gsSystemFile . """", param3:=" -flop4", param4:=" """ . romPath . "\" . romName . romExtension . """"
			}Else{
				param1 := " -flop3", param2:=" """ . romPath . "\" . romName . romExtension . """"
				If (multipartTable.MaxIndex() > 1)
					param3:=" -flop4", param4 := " """ . multipartTable[2,1] . """"
			}
			param5 := " -ui_active" ;Enable partial keyboard mode at startup
		}Else If messID = electron ; Acorn Electron
			{ AutoBootDelay := IniReadCheck(messSysINI, "Settings", "AutoBootDelay","2",,1)	; Read delay from config.
			AutoBootDelay := " -autoboot_delay " . AutoBootDelay
			If romExtension = .bin
				mediaDeviceType := "cart"
			Else	; any other format
				mediaDeviceType := "cass"
				param1 := " -" . mediaDeviceType . " """ . romPath . "\" . romName . romExtension . """ -autoboot_command ""chain""""""""""""\n""" . AutoBootDelay . ""
		}Else If messID = mbeeic ; Applied Technology MicroBee
		{	microbeeModel := IniReadCheck(messSysINI, romName, "MicroBee_Model","mbeeic",,1)
			If microbeeModel not in mbee,mbeeic,mbeepc,mbeepc85,mbee56
				ScriptError("This is not a known MicroBee model value: " . microbeeModel)
			Else If (microbeeModel != "mbeeic")
				messID := microbeeModel
			If romExtension in .mwb,.com,.bee
				mediaDeviceType := "quik1"
			Else If romExtension in .wav,.tap
				mediaDeviceType := "cass"
			Else If romExtension in .rom
				mediaDeviceType := "cart"
			Else If romExtension in .dsk
				mediaDeviceType := "flop1"
			Else	; .bin format
				mediaDeviceType := "quik2"
			param1 := " -" . mediaDeviceType . " """ . romPath . "\" . romName . romExtension . """"
		}Else if messID = odyssey2	; Magnavox Odyssey 2
			param2 := " -ui_active" ;Enable partial keyboard mode at startup
		;Use a different bios if needed (This must be done after the above if conditions since the messID will change)
		iniBios := IniReadCheck(messSysINI, romName, "Bios",messID,,1) ; for all games, we use the default bios. Some games might require different bios like Odyssey2's Jopac games use the videopac bios instead, which should be defined in the ini
		If (iniBios != "")
			messID := iniBios	; need to change the bios name for some games
	}

	; These systems don't use an ini, but do require parameters to be changed from the default method of launching Mess
	If (messID = "neocdz" || messID = "cdimono1" || messID = "segacd" || messID = "psx" || (messID = "tg16" && messSystem = "NEC TurboGrafx-CD") || (messID = "pce" && messSystem = "NEC PC Engine-CD"))	; SNK Neo Geo CD, Philips CD-i, Sega CD, Sony PlayStation, NEC PC Engine-CD or NEC TurboGrafx-CD
	{	If romExtension not in .chd,.cue
			ScriptError("MESS only supports " . messSystem . " games in chd and cue format. It does not support:`n" . romExtension)
		If (messSystem = "NEC TurboGrafx-CD") {		; NEC TurboGrafx-CD needs an additional bios mounted as a cart to run
			; tgcdBios := CheckFile(emuPath . "\roms\CD-ROM System V2.01 (U).pce")	; older bios that doesn't seem to work with many games
			tgcdBios := CheckFile(emuPath . "\roms\Super CD-ROM2 System V3.01 (U).pce")
			param2 := " -cart " . """" . tgcdBios . """"
		} Else If (messSystem = "NEC PC Engine-CD") {		; NEC PC Engine-CD needs an additional bios mounted as a cart to run
			pcecdBios := CheckFile(emuPath . "\roms\Super CD-ROM2 System V3.0 (J).pce")
			param2 := " -cart " . """" . pcecdBios . """"
		} Else If (messID = "psx") {		; Sony PlayStation
			messID = psu	; changing messID sent to Mess to use the USA bios
			; SelectMemCard()	; future function to swap around memcards
			; Usage: mc1 "J:\MESS\software\psu\card1.mc" 
		} If (messSystem = "Sega CD") {	; 
			If InStr(romName,"(Jap")	; Mega CD Japanese v2
				messID = megacd2j
			Else If InStr(romName,"(Euro")	; Mega CD European (PAL)
				messID = megacd
		}
		param1 := " -cdrm """ . romPath . "\" . romName . romExtension . """"
	}Else If messID = gamecom	; Tiger Game.com
	{	If romExtension != .txt
			param1 := " -cart1 """ . romPath . "\" . romName . romExtension . """"
	}Else If messID = genesis	; Sega Genesis
	{	If (InStr(romName, "(Europe") || InStr(romName, "(PAL"))	; if rom is from europe, tell MESS to boot a Mega Drive instead
			messID = megadriv
	}Else If messID = megadriv	; Sega Mega Drive
	{	If (InStr(romName, "(USA") || InStr(romName, "(NTSC"))	; if rom is from America, tell MESS to boot a Genesis instead
			messID = genesis
	}Else If messID = vii ; JungleTac Sport Vii
	{   If romName = Built-In Games (China)	;  Has some built-in games, gotta launch just BIOS for it.
			param1:=
	}Else If messID = alice32 ; Matra & Hachette Alice
	{   If romExtension != .txt
			param1 := " -cass1 """ . romPath . "\" . romName . romExtension . """"
	}Else If messID = pockstat	; Sony PocketStation
	{	If romExtension != .gme
			param1 := " -cart1 """ . romPath . "\" . romName . romExtension . """"	
	}Else If messID = coco3 ; Tandy TRS-80 Color Computer
	{   If romExtension != .txt
			param1 := " -cart """ . romPath . "\" . romName . romExtension . """"
	}Else If messID = zx81 ; Sinclair ZX81
	{   If romExtension != .txt
			param1 := " -cass1 """ . romPath . "\" . romName . romExtension . """"
	}Else If messID = sorcerer	; Exidy Sorcerer
	{	If romExtension = .snp   ; Snapshot file
			param1 := " -dump """ . romPath . "\" . romName . romExtension . """"
		Else If romExtension = .bin
			param1 := " -quik """ . romPath . "\" . romName . romExtension . """"
	}Else If (messID = "a800" || messID = "fds" || messID = "samcoupe")	; Atari 8-bit, Nintendo Famicom Disk System, and MGT Sam Coupe
	{	If romExtension != .txt
			param1 := " -flop1 """ . romPath . "\" . romName . romExtension . """"
	}Else If messID = vectrex	; GCE Vectrex
	{	If romName = Mine Storm (World)	; Mess dumps an error if you try to launch Mine Storm using a rom instead of just booting vectrex w/o a game in it (Mine Storm is built into vectrex)
			param1:=
	}Else If messID = apfm1000	; APF Imagination Machine/APF M1000
	{	If romName = Rocket Patrol (USA)	; Rocket Patrol is built into the APF M1000 ROM.
			param1:=
	}Else If messID = adam		; Coleco ADAM
		param1 := (If romExtension = ".ddp" ? " -cass1" : " -floppydisk") . " """ . romPath . "\" . romName . romExtension . """"	;  Decide if disk or ddp game
	Else If messID = pegasus	; Aamber Pegasus
	{   If romExtension != .txt
			param1 := " -cart1 """ . romPath . "\" . romName . romExtension . """"
	}
}Else{	; Use Software List
	hashname := messID
	param1 := " " . romName ; param1 used for launching from software lists

	If messID = aes	; SNK Neo Geo AES
	{	hashname := "neogeo"
		param2 := " -bios asia"	; can also be japan, but the asian one has english menus for most games
	}
	CheckFile(emuPath . "\hash\" . hashname . ".xml","Could not find a software list for the system " . messID) ;Check if software list for selected system exists
}

If messID = vectrex	; GCE Vectrex
	param2 := " -view "  . (If (FileExist(emuPath . "\artwork\Vectrex\" . romName . ".png"))?("""" . romName . """"):"standard")	; need overlays extracted in the artwork\vectres folder. PNGs must match romName

sysStaticParams := If sysStaticParams != ""  ? A_Space . sysStaticParams : "" ; tacking on a space in case user forgot to add one
romParams := If romParams != ""  ? A_Space . romParams : "" ; tacking on a space in case user forgot to add one

StringReplace,messRomPaths,romPathFromIni,|,`"`;`",1	; replace all instances of | to ; in the Rom_Path from RL's Emulators.ini so mess knows where to find your roms
messRomPaths := " -rompath """ .  messRomPaths . (If messBiosPath ? ";" . messBiosPath : "") . """"	; if a bios path was supplied, add it into the rom paths sent to mess

If InStr(romParams,"-rompath")
	ScriptError("""-rompath"" is defined as a parameter for " . romName . ". The MESS module fills this automatically so please remove this from Params in the module's settings.")
If InStr(sysStaticParams,"-rompath")
	ScriptError("""-rompath"" is defined as a parameter for " . messSystem . ". The MESS module fills this automatically so please remove this from Params in the module's settings.")

; use a custom cfg file if it exists and append it to param1
IfExist, % emuPath . "\cfg\" . messID . "\" . dbName
	param1 := " -cfg_directory " . """" . emuPath . "\cfg\" . messID . "\" . dbName . """" . param1

HideEmuStart()

errLvl := Run(executable . A_Space . messID . param1 . param2 . param3 . param4 . param5 . param6 . messRomPaths . sysStaticParams . romParams . fullscreen . hlsl . glsl . videomode . artworkCrop . useBezels . useOverlays . useBackdrops . " -skip_gameinfo", emuPath, winstate)

If errLvl {
	If (errLvl = 1)
		Error = Failed Validity
	Else If(errLvl = 2)
		Error = Missing Files
	Else If(errLvl = 3)
		Error = Fatal Error
	Else If(errLvl = 4)
		Error = Device Error
	Else If(errLvl = 5)
		Error = Game Does Not Exist
	Else If(errLvl = 6)
		Error = Invalid Config
	Else If errLvl in 7,8,9
		Error = Identification Error
	Else
		Error = MESS Error
	Log("MESS Error - " . Error,3)
}

WinWait("ahk_class MAME")
WinWaitActive("ahk_class MAME")

BezelDraw()

If romName = ICBMromName	; for Bally Astrocade only
{	Sleep, 2000 ; increase if you don't see the title screen
	SetKeyDelay(50)
	Send, {F3 down}{F3 up}	; sends a reset to MESS, needed for ICBM to boot
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


; This will simply create a new blank ini if one does not exist
CheckFileMESS(file){
	IfNotExist, %file%
		FileAppend,, %file%
	Return file
}

ListXMLInfo(rom){ ; returns MAME/MESS info about parent rom, orientation angle, resolution
	Global emuFullPath, emuPath
	ListXMLtable := []
	Log("Module - RunWait`, " .  comspec . " /c " . """" . emuFullPath . """" . " -listxml " . rom . " > tempBezel.txt`, " . emuPath . "`, Hide")
	RunWait, % comspec . " /c " . """" . emuFullPath . """" . " -listxml " . rom . " > tempBezel.txt", %emuPath%, Hide
	Fileread, ListxmlContents, %emuPath%\tempBezel.txt
	RegExMatch(ListxmlContents, "s)<game.*name=" . """" . rom . """" . ".*" . "cloneof=" . """" . "[^""""]*", parent)
	RegExMatch(parent,"cloneof=" . """" . ".*", parent)
	RegExMatch(parent,"""" . ".*", parent)
	StringTrimLeft, parent, parent, 1
	RegExMatch(ListxmlContents, "s)<display.*rotate=" . """" . "[0-9]+" . """", angle)
	RegExMatch(angle,"[0-9]+", angle, "-6")
	RegExMatch(ListxmlContents, "s)<display.*width=" . """" . "[0-9]+" . """", width)
	RegExMatch(width,"[0-9]+", width, "-6")
	RegExMatch(ListxmlContents, "s)<display.*height=" . """" . "[0-9]+" . """", Height)
	RegExMatch(Height,"[0-9]+", Height, "-6")
	ListXMLtable[1] := parent
	ListXMLtable[2] := angle
	ListXMLtable[3] := height
	ListXMLtable[4] := width
	If (ListXMLtable[3] > ListXMLtable[4])
		ListXMLtable[2] := true
	FileDelete, %emuPath%\tempBezel.txt
	Return ListXMLtable	
}

BezelLabel:
	WinSet, Transparent, 0, ahk_class ConsoleWindowClass
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class MAME")
Return
