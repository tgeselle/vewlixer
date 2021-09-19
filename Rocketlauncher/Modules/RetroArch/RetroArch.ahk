MEmu := "RetroArch"
MEmuV := "v1.3.6"
MURL := ["http://themaister.net/retroarch.html"]
MAuthor := ["djvj","zerojay","SweatyPickle"]
MVersion := "2.4.3"
MCRC := "699AB8F7"
iCRC := "FB2DB971"
MID := "635038268922229162"
MSystem := ["Acorn BBC Micro","AAE","Amstrad CPC","Amstrad GX4000","APF Imagination Machine","Applied Technology MicroBee","Apple IIGS","Arcade Classics","Atari 2600","Atari 5200","Atari 7800","Atari 8-Bit","Atari Classics","Atari Jaguar","Atari Lynx","Atari ST","Atari XEGS","Bally Astrocade","Bandai Gundam RX-78","Bandai Super Vision 8000","Bandai Wonderswan","Bandai Wonderswan Color","Canon X07","Capcom Classics","Capcom Play System","Capcom Play System II","Capcom Play System III","Casio PV-1000","Casio PV-2000","Cave","Coleco ADAM","ColecoVision","Commodore MAX Machine","Commodore Amiga","Creatronic Mega Duck","Data East Classics","Dragon Data Dragon","Emerson Arcadia 2001","Entex Adventure Vision","Elektronika BK","Epoch Game Pocket Computer","Epoch Super Cassette Vision","Exidy Sorcerer","Fairchild Channel F","Final Burn Alpha","Funtech Super Acan","GamePark 32","GCE Vectrex","Hartung Game Master","Interton VC 4000","Irem Classics","JungleTac Sport Vii","Konami Classics","MAME","Magnavox Odyssey 2","Microsoft MSX","Microsoft MSX2","Matra & Hachette Alice","Mattel Aquarius","Mattel Intellivision","Midway Classics","Namco Classics","Namco System 22","NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC TurboGrafx-16","NEC SuperGrafx","NEC TurboGrafx-CD","Nintendo 64","Nintendo 64DD","Nintendo Arcade Systems","Nintendo Classics","Nintendo DS","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Japan","Nintendo Game Boy Advance","Nintendo Game & Watch","Nintendo Super Game Boy","Nintendo Pokemon Mini","Nintendo Virtual Boy","Nintendo Super Famicom","Nintendo Satellaview","Nintendo SuFami Turbo","Panasonic 3DO","Elektronska Industrija Pecom 64","Philips CD-i","Philips Videopac","RCA Studio II","ScummVM","Sega 32X","Sega Classics","Sega Mega Drive 32X","Sega Mark III","Sega SC-3000","Sega SG-1000","Sega CD","Sega Dreamcast","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Meganet","Sega Nomad","Sega Pico","Sega Saturn","Sega Saturn Japan","Sega VMU","Sega ST-V","Sharp X1","Sharp X68000","Sinclair ZX Spectrum","Sinclair ZX81","Sony PlayStation","Sony PlayStation Minis","Sony PocketStation","Sony PSP","Sony PSP Minis","Sord M5","SNK Classics","SNK Neo Geo","SNK Neo Geo AES","SNK Neo Geo MVS","SNK Neo Geo Pocket","SNK Neo Geo CD","SNK Neo Geo Pocket Color","Spectravideo","Super Nintendo Entertainment System","Taito Classics","Tandy TRS-80 Color Computer","Technos","Texas Instruments TI 99-4A","Thomson MO5","Thomson TO7","Tiger Game.com","Tiki-100","Tomy Tutor","VTech CreatiVision","Watara Supervision","Williams Classics"]
;----------------------------------------------------------------------------
; Notes:
; If the emu doesn't load and you get no error, usually this means the LibRetro DLL is not working!
; Devs stated they will never add support for mounted images (like via DT)
; Fullscreen is controlled via the module setting in RocketLauncherUI
; This module uses the CLI version of RetroArch (retroarch.exe), not the GUI (retroarch-phoenix.exe).
; The emu may make a mouse cursor appear momentarily during launch, MouseMove and hide_cursor seem to have no effect
; Enable 7z support for archived roms
; Available CLI options: https://github.com/PyroFilmsFX/iOS/blob/master/docs/retroarch.1
;
; LibRetro DLLs:
; LibRetro DLLs come with the emu, but here is another source for them: http://forum.themaister.net/
; Whatever cores you decide to use, make sure they are extracted anywhere in your Emu_Path\cores folder. The module will find and load the default core unless you choose a custom one for each system.
; You can find supported cores that Retroarch supports simply by downloading them from the "retroarch-phoenix.exe" or by visiting here: https://github.com/libretro/libretro.github.com/wiki/Supported-cores
; Some good discussion on cores and filters: http://forum.themaister.net/viewtopic.php?id=270
;
; SRM files:
; The srm files location is determined by the configuration file used (savefile_directory = ":\whatever") The default RetroArch srm directory is ":\saves" You can select to sort into core folders (ie: :/saves/Mednafen PSX) by changing sort_savefiles_enable = "true" in the configuration file.
;
; Save states:
; The save state files location is determined by the configuration file used (savestate_directory = ":\whatever") The default RetroArch savestate directory is ":\states" You can select to sort into core folders (ie: :/states/Mednafen PSX) by changing sort_savestates_enable = "true" in the configuration file.
;
; Config files:
; By default, the module looks for config files in a folder called config in the RetroArch folder. Example: C:\emus\RetroArch\config. You can change this folder to anything you like by changing the module's ConfigFolder setting in RocketLauncherUI.  This will be the config folder for the module and will NOT change the location of RetroArch's own /config directory.
; RetroArch's global config file is called "retroarch.cfg". RetroArch will use a system cfg file named to match your System Name (example: Nintendo Entertainment System.cfg).
; RetroArch will also load core config files named after the core name. Example: nestopia_libretro.cfg
; This allows different settings globally, for each system, and for each core. If you want all systems to use the same retroarch.cfg, do not have any system or core cfg files, only have the retroarch.cfg.
; If a core config exists, it takes precedence over the global config. And if a system config exists, it takes precedence over the core config.
;
; Core Options:
; By default, RetroArch creates a retroarch-core-options.cfg in it's root directory.  Example: C:\emus\RetroArch\retroarch-core-options.cfg.  This will always be used if the default RetroArch.cfg is loaded.  If a configuration file from any other location is used, RetroArch will create a retroarch-core-options.cfg file in the root of that directory.  The module has an option to have RetroArch use only the default retroarch-core-options.cfg file no matter the path of the config directory or location of the configuiration file being used.  To enable this option set Single_Core_Options to true.

; MultiGame:
; MultiGame support is currently only available for the Mednafen PSX core. Retroarch uses the same method as Mednafen to load multi-disc games. This method involves m3u playlists which are commonly used for music. The m3u files needed to load multi-disc games are generated for you by the module when you launch a multi-disc game and are saved to your corresponding rom directory. Due to m3u limitations, your multi-disc roms/images cannot be archived -- they must be unzipped. All single disc games can remain archived and you can still enable 7z under system settings. If you do not wish to use MultiGame support you can archive your roms/images and m3u generation will be skipped on launch. 
; The m3u files generated by the module contain a list of paths to all roms/images in the multi-disc set. Retroarch automatically loads the first path in the m3u so the first path will always be the disc you are loading. For example, Final Fantasy VII has 3 discs and if you load Disc 2 first, the order of the paths in the m3u will be disc 2, disc 3, disc 1. If you load Disc 3 first, the order will be disc 3, disc 1, disc 2. The module anticipates this and will load the correct disk, selected from the Pause/MultiDisk menus. However if you choose to manually use Retroarch's UI or disk swap keys to change discs, you will need to keep this in mind.
; In order for RocketLauncher's MultiGame UI to swap discs, you must define Eject_Toggle_Key, Next_Disk_Key, and Previous_Disk_Key under global settings for the emulator in RocketLauncher. Because AHK and Retroarch use different naming conventions for some keyboard keys, it is best to use a letter, a number, or F1-F12.
;
; MAME:
; MAME BIOS roms should be placed in Rom Path's directory. Some systems require the BIOS roms be placed in the MAME internal name directory. (Example: :\Rom Folder\a5200). The MAME BIOS_Roms_Folder option will have no effect unless you are using an older version of the mess core. 
;
; System Specific Notes:
; Microsoft MSX/MSX2: Launch an MSX game and in the core options, set the console to be an MSX2 and it will play both just fine.
; Nintendo Famicom Disk System - Requires disksys.rom be placed in the folder you define as system_directory in the RetroArch's cfg.
; Sega CD - Requires "bios_CD_E.bin", "bios_CD_J.bin", "bios_CD_U.bin" all be placed in the folder you define as system_directory in the RetroArch's cfg.
; Super Nintendo Entertainment System - requires split all 10 dsp# & st### roms all be placed in the folder you define as system_directory in the RetroArch's cfg. Many games, like Super Mario Kart require these.
; NEC TurboGrafx-CD (using pce fast core) - Requires "syscard3.pce" be placed in the folder you define as system_directory in the RetroArch's cfg.
; NEC TurboGrafx-CD (using MAME core)
;   - You'll need to update a couple mame specific options in the Retroarch core options file to get it to boot from the cli. These should probably be updated automagically by the module. Turning softlists off, but might not need to.
;       mame_boot_from_cli = "enabled"
;       mame_softlists_enable = "disabled"
;       mame_softlists_auto_media = "disabled"
;	- Requires hash folder from MAME/MESS/UME, either from the source or release package. Save this in the system_directory you've defined for RetroArch. Something like \RetroArch\system\mame\hash\
;	- Requires the CD bios file(s) saved in the mame bios folder you've defined. Usually \RetroArch\system\mame\bios\
;		For PC Engine-CD you'll need the file "[cd] cd-rom system (japan) (v2.1).pce" zipped as cdsys.zip and saved in a pce subfolder in your bios path, so \RetroArch\system\mame\bios\pce\cdsys.zip
;		For PC Engine SuperGrafx-CD you'll need the file "[cd] super cd-rom system (japan) (v3.0).pce" zipped as scdsys.zip and saved in a pce subfolder in your bios path, so \RetroArch\system\mame\bios\pce\scdsys.zip
;		For TurboGrafx-CD you'll need the file "[cd] turbografx cd system card (usa) (v2.0).pce" zipped as cdsys.zip and saved in a tg16 subfolder in your bios path, so \RetroArch\system\mame\bios\tg16\cdsys.zip
;		For TurboDuo you'll need the file "[cd] turbografx cd super system card (usa) (v3.0).pce" zipped as scdsys.zip and saved in a tg16 subfolder in your bios path, so \RetroArch\system\mame\bios\tg16\scdsys.zip
; Nintendo Super Game Boy - Set the Module setting in RocketLauncherUI SuperGameBoy to true to enable a system or only a rom to use SGB mode. This is not needed if your systemName is set to the official name of "Nintendo Super Game Boy". Requires "sgb.boot.rom" and "Super Game Boy (World).sfc" to be placed in the folder you define as system_directory in the RetroArch's cfg. This is needed if you want to use Super game boy mode and color palettes. Also requires using the latest bsnes core. Not all games support SGB mode.
; Sony PSP/PlayStation Minis: To avoid the dialog box complaining about ppge_atlas.zim, download it from https://github.com/libretro/libretro-ppsspp/blob/master/assets/ppge_atlas.zim and place it in your Retroarch/system/PPSSPP/ directory.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)	; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("RetroArch","RetroArch"))	; instantiate primary emulator window object
emuConsoleWindow := new Window(new WindowTitle("","ConsoleWindowClass"))	; instantiate emulator console window object

; Here we define all supported systems for this module. This object controls how the module reacts to different systems. RetroArch can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
; 1 - Official System Name in RocketLauncher
; 2 - Short name used only for easy referencing within module
; 3 - Default core
; 4 - The system ID MAME core recognizes
RLLog.Debug("Module - Started building the " . MEmu . " object")
mTypeVar:="
	( LTrim
	AAE|LibRetro_AAE|mame_libretro
	Acorn BBC Micro|LibRetro_BBCB|mame_libretro|bbcb
	Amstrad CPC|LibRetro_CPC|mame_libretro|cpc464
	Amstrad GX4000|LibRetro_GX4K|mame_libretro|gx4000
	APF Imagination Machine|LibRetro_APF|mame_libretro|apfimag
	Apple IIGS|LibRetro_AIIGS|mame_libretro|apple2gs
	Applied Technology MicroBee|LibRetro_MBEE|mame_libretro|mbeeic
	Arcade Classics|LibRetro_ARCADE|mame_libretro
	Atari 2600|LibRetro_2600|stella_libretro|a2600
	Atari 5200|LibRetro_5200|mame_libretro|a5200
	Atari 7800|LibRetro_7800|prosystem_libretro|a7800
	Atari 8-Bit|LibRetro_ATARI8|mame_libretro|a800
	Atari Classics|LibRetro_ACLS|mame_libretro
	Atari Jaguar|LibRetro_JAG|virtualjaguar_libretro|jaguar
	Atari Lynx|LibRetro_LYNX|handy_libretro|lynx
	Atari ST|LibRetro_ST|hatari_libretro
	Atari XEGS|LibRetro_XEGS|mame_libretro|xegs
	Bally Astrocade|LibRetro_BAST|mame_libretro|astrocde
	Bandai Gundam RX-78|LibRetro_BGRX|mame_libretro|rx78
	Bandai Super Vision 8000|LibRetro_SV8K|mame_libretro|sv8000
	Bandai Wonderswan|LibRetro_WSAN|mednafen_wswan_libretro|wswan
	Bandai Wonderswan Color|LibRetro_WSANC|mednafen_wswan_libretro|wscolor
	Canon X07|LibRetro_CX07|mame_libretro|x07
	Capcom Classics|LibRetro_CAPC|mame_libretro
	Capcom Play System|LibRetro_CPS1|fbalpha_libretro
	Capcom Play System II|LibRetro_CPS2|fbalpha_libretro
	Capcom Play System III|LibRetro_CPS3|mame_libretro
	Casio PV-1000|LibRetro_CAS1K|mame_libretro|pv1000
	Casio PV-2000|LibRetro_CAS2K|mame_libretro|pv2000
	Cave|LibRetro_CAVE|mame_libretro
	Coleco ADAM|LibRetro_ADAM|mame_libretro|adam
	ColecoVision|LibRetro_COLEC|mame_libretro|coleco
	Commodore Amiga|LibRetro_PUAE|puae_libretro
	Commodore Max Machine|LibRetro_CMAX|mame_libretro|vic10
	Creatronic Mega Duck|LibRetro_DUCK|mame_libretro|megaduck
	Data East Classics|LibRetro_DATA|mame_libretro
	Dragon Data Dragon|LibRetro_DRAG64|mame_libretro|dragon64
	Elektronika BK|LibRetro_EBK|mame_libretro|bk0010
	Elektronska Industrija Pecom 64|LibRetro_P64|mame_libretro|pecom64
	Emerson Arcadia 2001|LibRetro_A2001|mame_libretro|arcadia
	Entex Adventure Vision|LibRetro_AVISION|mame_libretro|advision
	Epoch Game Pocket Computer|LibRetro_GPCKET|mame_libretro|gamepock
	Epoch Super Cassette Vision|LibRetro_SCV|mame_libretro|scv
	Exidy Sorcerer|LibRetro_SORCR|mame_libretro|sorcerer
	Fairchild Channel F|LibRetro_CHANF|mame_libretro|channelf
	Final Burn Alpha|LibRetro_FBA|fbalpha_libretro
	Funtech Super Acan|LibRetro_SACAN|mame_libretro|supracan
	GamePark 32|LibRetro_GP32|mame_libretro|gp32
	GCE Vectrex|LibRetro_VECTX|mame_libretro|vectrex
	Hartung Game Master|LibRetro_GMASTR|mame_libretro|gmaster
	Interton VC 4000|LibRetro_VC4K|mame_libretro|vc4000
	Irem Classics|LibRetro_IREM|mame_libretro
	JungleTac Sport Vii|LibRetro_SPORTV|mame_libretro|vii
	Konami Classics|LibRetro_KONC|mame_libretro
	Magnavox Odyssey 2|LibRetro_ODYS2|mame_libretro|odyssey2
	MAME|LibRetro_MAME|mame_libretro|mame
	Matra & Hachette Alice|LibRetro_ALICE|mame_libretro|alice32
	Mattel Aquarius|LibRetro_AQUA|mame_libretro|aquarius
	Mattel Intellivision|LibRetro_INTV|mame_libretro|intv
	MGT Sam Coupe|LibRetro_SAMCP|mame_libretro|
	Microsoft MS-DOS|LibRetro_MSDOS|dosbox_libretro
	Microsoft MSX|LibRetro_MSX|bluemsx_libretro
	Microsoft MSX2|LibRetro_MSX2|bluemsx_libretro
	Microsoft Windows 3.x|LibRetro_WIN3X|dosbox_libretro
	Midway Classics|LibRetro_MIDC|mame_libretro
	Namco Classics|LibRetro_NAMC|mame_libretro
	Namco System 22|LibRetro_NAM2|mame_libretro
	NEC PC Engine|LibRetro_PCE|mednafen_pce_fast_libretro|pce,cart
	NEC PC Engine-CD|LibRetro_PCECD|mednafen_pce_fast_libretro|pce,cdrom
	NEC PC-FX|LibRetro_PCFX|mednafen_pcfx_libretro
	NEC SuperGrafx|LibRetro_SGFX|mednafen_supergrafx_libretro|sgx,cart
	NEC TurboGrafx-16|LibRetro_TG16|mednafen_pce_fast_libretro|tg16,cart
	NEC TurboGrafx-CD|LibRetro_TGCD|mednafen_pce_fast_libretro|tg16,cdrom
	Nintendo 64|LibRetro_N64|mupen64plus_libretro|n64
	Nintendo 64DD|LibRetro_N64|mupen64plus_libretro
	Nintendo Arcade Systems|LibRetro_NINARC|mame_libretro
	Nintendo Classics|LibRetro_NINC|mame_libretro
	Nintendo DS|LibRetro_DS|desmume_libretro
	Nintendo Entertainment System|LibRetro_NES|nestopia_libretro|nes
	Nintendo Famicom|LibRetro_NFAM|nestopia_libretro
	Nintendo Famicom Disk System|LibRetro_NFDS|nestopia_libretro|famicom
	Nintendo Game Boy|LibRetro_GB|gambatte_libretro|gameboy
	Nintendo Game Boy Advance|LibRetro_GBA|vba_next_libretro|gba
	Nintendo Game Boy Color|LibRetro_GBC|gambatte_libretro|gbcolor
	Nintendo Game Boy Japan|LibRetro_GBJ|gambatte_libretro|gameboy
	Nintendo Game & Watch|LibRetro_GW|gw_libretro
	Nintendo Pokemon Mini|LibRetro_POKE|mame_libretro|pokemini
	Nintendo Satellaview|LibRetro_NSFS|snes9x_libretro
	Nintendo SuFami Turbo|LibRetro_NSFST|snes9x_libretro
	Nintendo Super Famicom|LibRetro_NSF|bsnes_balanced_libretro
	Nintendo Super Game Boy|LibRetro_SGB|bsnes_balanced_libretro
	Nintendo Virtual Boy|LibRetro_NVB|mednafen_vb_libretro|vboy
	Othello Multivision|LibRetro_OTHO|genesis_plus_gx_libretro
	Panasonic 3DO|LibRetro_3DO|4do_libretro
	Philips CD-i|LibRetro_CDI|mame_libretro|cdimono1
	Philips Videopac|LibRetro_PVID|mame_libretro|videopac
	RCA Studio II|LibRetro_STUD2|mame_libretro|studio2
	SCUMMVM|LibRetro_SCUMM|scummvm_libretro
	Sega 32X|LibRetro_32X|picodrive_libretro|32x
	Sega CD|LibRetro_SCD|genesis_plus_gx_libretro|segacd
	Sega Classics|LibRetro_SEGC|mame_libretro
	Sega Dreamcast|LibRetro_DCAST|reicast_libretro
	Sega Game Gear|LibRetro_GG|genesis_plus_gx_libretro|gamegear
	Sega Genesis|LibRetro_GEN|genesis_plus_gx_libretro|genesis
	Sega Mark III|Libretro_SM3|genesis_plus_gx_libretro
	Sega Master System|LibRetro_SMS|genesis_plus_gx_libretro|sms
	Sega Mega Drive|LibRetro_GEN|genesis_plus_gx_libretro|megadriv
	Sega Mega Drive 32X|LibRetro_MD32X|picodrive_libretro
	Sega Meganet|LibRetro_GEN|genesis_plus_gx_libretro|genesis
	Sega Nomad|LibRetro_GEN|genesis_plus_gx_libretro|genesis
	Sega Pico|LibRetro_PICO|picodrive_libretro
	Sega Saturn|LibRetro_SAT|yabause_libretro|saturn
	Sega Saturn Japan|LibRetro_SAT|yabause_libretro|saturnjp
	Sega SC-3000|LibRetro_SC3K|mame_libretro|sc3000
	Sega SG-1000|LibRetro_SG1K|genesis_plus_gx_libretro
	Sega ST-V|LibRetro_STV|mame_libretro
	Sega VMU|LibRetro_SVMU|mame_libretro|svmu
	Sharp X1|LibRetro_SX1|mame_libretro|x1
	Sharp X68000|LibRetro_SX68000|mame_libretro|x68000
	Sinclair ZX Spectrum|LibRetro_SPECZX|mame_libretro|spectrum
	Sinclair ZX81|LibRetro_ZX81|81_libretro|zx81
	SNK Classics|LibRetro_SNKC|mame_libretro
	SNK Neo Geo|LibRetro_NEO|fbalpha_libretro
	SNK Neo Geo AES|LibRetro_NEOAES|mame_libretro|aes
	SNK Neo Geo CD|LibRetro_NEOCD|mame_libretro|neocdz
	SNK Neo Geo MVS|LibRetro_NEOMVS|mame_libretro
	SNK Neo Geo Pocket|LibRetro_NGP|mednafen_ngp_libretro|ngp
	SNK Neo Geo Pocket Color|LibRetro_NGPC|mednafen_ngp_libretro|ngpc
	Sony PlayStation|LibRetro_PSX|mednafen_psx_libretro|psu
	Sony PlayStation Minis|LibRetro_PSXMIN|ppsspp_libretro
	Sony PocketStation|LibRetro_POCKS|mame_libretro|pockstat
	Sony PSP|LibRetro_PSP|ppsspp_libretro
	Sony PSP Minis|LibRetro_PSP|ppsspp_libretro
	Sord M5|LibRetro_SORD|mame_libretro|m5
	Spectravideo|LibRetro_SV328|mame_libretro|svi328n
	Super Nintendo Entertainment System|LibRetro_SNES|bsnes_balanced_libretro|snes
	Taito Classics|LibRetro_TAIC|mame_libretro
	Tandy TRS-80 Color Computer|LibRetro_TRS80|mame_libretro|coco3
	Technos|LibRetro_TECHN|mame_libretro
	Texas Instruments TI 99-4A|LibRetro_TI99|mame_libretro|ti99_4a
	Thomson MO5|LibRetro_MO5|mame_libretro|mo5
	Thomson TO7|LibRetro_TO7|mame_libretro|to7
	Tiger Game.com|LibRetro_TCOM|mame_libretro|gamecom
	Tiki-100|LibRetro_TIKI|mame_libretro|kontiki
	Tomy Tutor|LibRetro_TOMY|mame_libretro|tutor
	VTech CreatiVision|LibRetro_VTECH|mame_libretro|crvision
	Watara Supervision|LibRetro_SUPRV|mame_libretro|svision
	Williams Classics|LibRetro_WILLS|mame_libretro
	)"
mType := Object()
Loop, Parse, mTypeVar, `n, `r
{
	obj := {}
	Loop, Parse, A_LoopField, |
	{
		If (A_Index = 1)
			obj.System := A_LoopField
		Else If (A_Index = 2)
			obj.ID := A_LoopField
		Else If (A_Index = 3)
			obj.Core := A_LoopField
		Else {	; 4
			StringSplit, tmp, A_LoopField, `,
			obj.MAMEID := tmp1
			obj.MAMEMedia := tmp2
		}
	}
	mType.Insert(obj["System"], obj)
}
RLLog.Debug("Module - Finished building the " . MEmu . " object")
; For easier use throughout the module
retroSystem := mType[systemName].System
retroID := mType[systemName].ID
retroCore := mType[systemName].Core
retroMAMEID := mType[systemName].MAMEID
retroMAMEMedia := mType[systemName].MAMEMedia
RLLog.Info("Module - Using these system variables:")
RLLog.Info("Module - retroSystem: " . retroSystem)
RLLog.Info("Module - retroID: " . retroID)
RLLog.Info("Module - retroCore: " . retroCore)
RLLog.Info("Module - retroMAMEID: " . retroMAMEID)
RLLog.Info("Module - retroMAMEMedia: " . retroMAMEMedia)
If !retroSystem
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module: " . moduleName)
If !retroCore
	ScriptError("Your Core ID is: " . retroID . "`nCould not find a default core to use. Please update the module with a default core.")

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
configFolder := moduleIni.Read("Settings", "ConfigFolder",emuPath . "\config",,1)
singlecoreoptions := moduleIni.Read("Settings", "single_core_options","false",,1) = "true" ? ":\retroarch-core-options.cfg" : """"
mameRomPath := moduleIni.Read("MAME", "BIOS_Roms_Folder",,,1)
mameHideNag := If moduleIni.Read("MAME", "Hide_Nag_Screen","false",,1) = "true" ? "enabled" : "disabled"
mameHideInfo := If moduleIni.Read("MAME", "Hide_Info_Screen","false",,1) = "true" ? "enabled" : "disabled"
mameHideWarn := If moduleIni.Read("MAME", "Hide_Warning_Screen","false",,1) = "true" ? "enabled" : "disabled"
hideConsole := moduleIni.Read("Settings", "HideConsole","true",,1)
ejectToggleKey := moduleIni.Read("Settings", "Eject_Toggle_Key",,,1)
nextDiskKey := moduleIni.Read("Settings", "Next_Disk_Key",,,1)
prevDiskKey := moduleIni.Read("Settings", "Previous_Disk_Key",,,1)
core := moduleIni.Read(romName . "|" . systemName, "LibRetro_Core",retroCore,,1)
superGB := moduleIni.Read(romName . "|" . systemName, "SuperGameBoy","false",,1)
enableNetworkPlay := moduleIni.Read(romName . "|Network", "Enable_Network_Play","false",,1)
overlay := moduleIni.Read(romName . "|" . systemName, "Overlay",,,1)
videoShader := moduleIni.Read(romName . "|" . systemName, "VideoShader",,,1)
aspectRatioIndex := moduleIni.Read(romName . "|" . systemName, "AspectRatioIndex",,,1)
customViewportWidth := moduleIni.Read(romName . "|" . systemName, "CustomViewportWidth",,,1)
customViewportHeight := moduleIni.Read(romName . "|" . systemName, "CustomViewportHeight",,,1)
customViewportX := moduleIni.Read(romName . "|" . systemName, "CustomViewportX",,,1)
customViewportY := moduleIni.Read(romName . "|" . systemName, "CustomViewportY",,,1)
stretchToFillBezel := moduleIni.Read(romName . "|" . systemName, "StretchToFillBezel","false",,1)
rotation := moduleIni.Read(romName . "|" . systemName, "Rotation",0,,1)
cropOverscan := moduleIni.Read(romName . "|" . systemName, "CropOverscan",,,1)
threadedVideo := moduleIni.Read(romName . "|" . systemName, "ThreadedVideo",,,1)
vSync := moduleIni.Read(romName . "|" . systemName, "VSync",,,1)
integerScale := moduleIni.Read(romName . "|" . systemName, "IntegerScale",,,1)
configurationPerCore := moduleIni.Read(romName . "|" . systemName, "ConfigurationPerCore","false",,1)

If (StringUtils.Contains(core, "^(mame|mess|ume)") && !retroMAMEID) {
	retroMAMEID := "mame"	; set all systems that use a mame core to the default mame ID so any system name is supported
	RLLog.Warning("Module - Setting MAMEID to default ""mame"" for """ . retroSystem . """")
}

configFolder := RLObject.getFullPathFromRelative(rlPath,configFolder)
mameRomPath := If mameRomPath ? RLObject.getFullPathFromRelative(rlPath,mameRomPath) : romPath
overlay := RLObject.getFullPathFromRelative(rlPath,overlay)
videoShader := RLObject.getFullPathFromRelative(rlPath,videoShader)
rotateBezel := false

configFolder := new Folder(configFolder)

If (retroID = "LibRetro_SGB" || superGB = "true")	; if system or rom is set to use Super Game Boy
{	superGB := "true"	; setting this just in case it's false and the system is Nintendo Super Game Boy
	sgbRomPath := CheckFile(emuPath . "\system\Super Game Boy (World).sfc","Could not find the rom required for Super Game Boy support. Make sure the rom ""Super Game Boy (World).sfc"" is located in: " . emuPath . "\system")
	CheckFile(emuPath . "\system\sgb.boot.rom","Could not find the bios required for Super Game Boy support. Make sure the bios ""sgb.boot.rom"" is located in: " . emuPath . "\system")
	retroID := "LibRetro_SGB"	; switching to Super Game Boy mode
	retroSystem := "Nintendo Super Game Boy"
}

; Find the dll for this system
libDll := CheckFile(emuPath . "\cores\" . core . ".dll", "Your " . retroID . " dll is set to " . core . " but could not locate this file:`n" . emuPath . "\cores\" . core . ".dll")

; Find the cfg file to use
If !configFolder.Exist()
	ScriptError("You need to make sure ""ConfigFolder"" is pointing to your RetroArch config folder. By default it is looking here: """ . configFolder.FilePath . """")
globalRetroCfg := emuPath . "\retroarch.cfg"
systemRetroCfg := configFolder.FilePath . "\" . retroSystem . ".cfg"
coreRetroCfg := configFolder.FilePath . "\" . core . ".cfg"
RLLog.Info("Module - Global cfg should be: " . globalRetroCfg)
RLLog.Info("Module - System cfg should be: " . systemRetroCfg)
RLLog.Info("Module - Core cfg should be: " . coreRetroCfg)
foundCfg := ""

systemRetroCfg := new File(systemRetroCfg)
coreRetroCfg := new File(coreRetroCfg)
globalRetroCfg := new File(globalRetroCfg)

If systemRetroCfg.Exist() {	; check for system cfg first
	retroCFGFile := systemRetroCfg
	foundCfg := 1
	RLLog.Info("Module - Found a System cfg!")
} Else If coreRetroCfg.Exist() {	; 2nd option is a core config
	retroCFGFile := coreRetroCfg
	foundCfg := 1
	RLLog.Info("Module - Found a Core cfg!")
} Else If globalRetroCfg.Exist() {	; 3rd is global cfg
	retroCFGFile := globalRetroCfg
	foundCfg := 1
	RLLog.Info("Module - Found a Global cfg!")
}
If foundCfg {
	RLLog.Info("Module - " . MEmu . " is using " . retroCFGFile.FileFullPath . " as its config file.")
	retroCFG := LoadProperties(retroCFGFile.FileFullPath)
} Else
	RLLog.Warning("Module - Could not find a cfg file to update settings. RetroArch will make one for you.")

If StringUtils.Contains(rotation,"1|3") ; use vertical bezel if RA rotation is set to 90 or 270 degrees
	rotateBezel := true

If StringUtils.Contains(retroID, "LibRetro_NFDS|LibRetro_SCD|LibRetro_TGCD|LibRetro_PCECD|LibRetro_PCFX") {		; these systems require the retroarch settings to be read
	retroSysDir := ReadProperty(retroCFG,"system_directory")	; read value
	retroSysDir := ConvertRetroCFGKey(retroSysDir)	; remove dbl quotes
	retroSysDirLeft := StringUtils.Left(retroSysDir, 2)
	If (retroSysDirLeft = ":\") {	; if retroarch is set to use a default folder
		retroSysDir := StringUtils.TrimLeft(retroSysDir, 1)
		RLLog.Info("Module - RetroArch is using a relative system path: """ . retroSysDir . """")
		retroSysDir := emuPath . retroSysDir
	}
	If !retroSysDir
		ScriptError("RetroArch requires you to set your system_directory and place bios rom(s) in there for """ . retroSystem . """ to function. Please do this first by running ""retroarch-phoenix.exe"" manually.")
	checkForSlash := StringUtils.Right(retroSysDir, 1)
	If (checkForSlash = "\")	; check if a backslash is the last character. If it is, remove it, as this is non-standard method to define folders
		retroSysDir := StringUtils.TrimRight(retroSysDir, 1)
}

If (StringUtils.Contains(core, "^(mame|mess|ume)")) || (StringUtils.Contains(retroID, "LibRetro_N64|LibRetro_NES|LibRetro_LYNX|LibRetro_PSX")) || (StringUtils.Contains(retroID, "LibRetro_NES") && (StringUtils.Contains(core, "nestopia_libretro"))) {	; these systems will use an ini to store game specific settings
	RLLog.Info("Module - Reading / creating system ini for specific settings.")
	If !StringUtils.Contains(core, "^(mame|mess|ume)") {
		If !SystemModuleIni.Exist()
			SystemModuleIni.Append		; create a new blank ini file if one does not exist
	}

	coreOptionsCFG := LoadProperties(coreOptionsCFGFile.FileFullPath)
	
	If StringUtils.Contains(core, "^(mame|mess|ume)") {	; Set some MAME/MESS/UME core options.
		tmpCore := If StringUtils.Contains(core, "mame") ? "mame" : "mess"
		WriteProperty(coreOptionsCFG, tmpCore . "_read_config", """enabled""", 1)
		WriteProperty(coreOptionsCFG, tmpCore . "_boot_from_cli", """enabled""", 1)				; This needs to be enabled in order to run games with RLauncher
		WriteProperty(coreOptionsCFG, tmpCore . "_hide_nagscreen", "" . mameHideNag . "", 1)
		WriteProperty(coreOptionsCFG, tmpCore . "_hide_infoscreen", "" . mameHideInfo . "", 1)
		WriteProperty(coreOptionsCFG, tmpCore . "_hide_warnings", "" . mameHideWarn . "", 1)
	} Else If StringUtils.Contains(retroID, "LibRetro_N64") {	; Nintendo 64
		mupenGfx := moduleIni.Read(romName . "|" . systemName, "Mupen_Gfx_Plugin", "auto",,1)
		mupenRsp := moduleIni.Read(romName . "|" . systemName, "Mupen_RSP_Plugin", "auto",,1)
		mupenCpu := moduleIni.Read(romName . "|" . systemName, "Mupen_CPU_Core", "dynamic_recompiler",,1)
		mupenPak1 := moduleIni.Read(romName . "|" . systemName, "Mupen_Pak_1", "memory",,1)
		mupenPak2 := moduleIni.Read(romName . "|" . systemName, "Mupen_Pak_2", "memory",,1)
		mupenPak3 := moduleIni.Read(romName . "|" . systemName, "Mupen_Pak_3", "memory",,1)
		mupenPak4 := moduleIni.Read(romName . "|" . systemName, "Mupen_Pak_4", "memory",,1)
		mupenGfxAccur := moduleIni.Read(romName . "|" . systemName, "Mupen_Gfx_Accuracy", "high",,1)
		mupenExpMem := moduleIni.Read(romName . "|" . systemName, "Mupen_Disable_Exp_Memory", "no",,1)
		mupenTexturFilt := moduleIni.Read(romName . "|" . systemName, "Mupen_Texture_Filtering", "nearest",,1)
		mupenViRefresh := moduleIni.Read(romName . "|" . systemName, "Mupen_VI_Refresh", "2200",,1)
		mupenFramerate := moduleIni.Read(romName . "|" . systemName, "Mupen_Framerate", "fullspeed",,1)
		mupenResolution := moduleIni.Read(romName . "|" . systemName, "Mupen_Resolution", "640x480",,1)
		mupenPolyOffstFctr := moduleIni.Read(romName . "|" . systemName, "Mupen_Polygon_Offset_Factor", "-3.0",,1)
		mupenPolyOffstUnts := moduleIni.Read(romName . "|" . systemName, "Mupen_Polygon_Offset_Units", "-3.0",,1)
		mupenViOverlay := moduleIni.Read(romName . "|" . systemName, "Mupen_VI_Overlay", "disabled",,1)
		mupenAnalogDzone := moduleIni.Read(romName . "|" . systemName, "Mupen_Analog_Deadzone", "15",,1)

		WriteProperty(coreOptionsCFG, "mupen64-gfxplugin", mupenGfx, 1)
		WriteProperty(coreOptionsCFG, "mupen64-rspplugin", mupenRsp, 1)
		WriteProperty(coreOptionsCFG, "mupen64-cpucore", mupenCpu, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak1", mupenPak1, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak2", mupenPak2, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak3", mupenPak3, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak4", mupenPak4, 1)
		WriteProperty(coreOptionsCFG, "mupen64-gfxplugin-accuracy", mupenGfxAccur, 1)
		WriteProperty(coreOptionsCFG, "mupen64-disableexpmem", mupenExpMem, 1)
		WriteProperty(coreOptionsCFG, "mupen64-filtering", mupenTexturFilt, 1)
		WriteProperty(coreOptionsCFG, "mupen64-virefresh", mupenViRefresh, 1)
		WriteProperty(coreOptionsCFG, "mupen64-framerate", mupenFramerate, 1)
		WriteProperty(coreOptionsCFG, "mupen64-screensize", mupenResolution, 1)
		WriteProperty(coreOptionsCFG, "mupen64-polyoffset-factor", mupenPolyOffstFctr, 1)
		WriteProperty(coreOptionsCFG, "mupen64-polyoffset-units", mupenPolyOffstUnts, 1)
		WriteProperty(coreOptionsCFG, "mupen64-angrylion-vioverlay", mupenViOverlay, 1)
		WriteProperty(coreOptionsCFG, "mupen64-astick-deadzone", mupenAnalogDzone, 1)
	} Else If StringUtils.Contains(retroID, "LibRetro_NES") {		; these systems will use an ini to store game specific settings
		If StringUtils.Contains(core, "nestopia_libretro") {	; Nestopia
			nestopiaBlargg := moduleIni.Read(romName . "|Nestopia", "Nestopia_Blargg_NTSC_Filter", "disabled",,1)
			nestopiaPalette := moduleIni.Read(romName . "|Nestopia", "Nestopia_Palette", "canonical",,1)
			nestopiaNoSprteLimit := moduleIni.Read(romName . "|Nestopia", "Nestopia_Remove_Sprites_Limit", "disabled",,1)
			
			WriteProperty(coreOptionsCFG, "nestopia_blargg_ntsc_filter", nestopiaBlargg, 1)
			WriteProperty(coreOptionsCFG, "nestopia_palette", nestopiaPalette, 1)
			WriteProperty(coreOptionsCFG, "nestopia_nospritelimit", nestopiaNoSprteLimit, 1)
		}
	} Else If StringUtils.Contains(retroID, "LibRetro_LYNX") {	; Atari Lynx
		If StringUtils.Contains(core, "handy_libretro") {   ; Handy
			handyRotate := moduleIni.Read(romName . "|" . systemName, "Handy_Rotation", "None",,1)
			If StringUtils.Contains(handyRotate, "240") or StringUtils.Contains(handyRotate, "90")
				rotateBezel := true
			WriteProperty(coreOptionsCFG, "handy_rot", handyRotate, 1)
		}
	} Else If StringUtils.Contains(retroID, "LibRetro_PSX") {	; Sony PlayStation
		psxCdImageCache := moduleIni.Read(romName . "|" . systemName, "PSX_CD_Image_Cache", """enabled""",,1)
		psxMemcardHandling := moduleIni.Read(romName . "|" . systemName, "PSX_Memcard_Handling", """libretro""",,1)
		psxDualshockAnalogToggle := moduleIni.Read(romName . "|" . systemName, "PSX_Dualshock_Analog_Toggle", """enabled""",,1)
		
		WriteProperty(coreOptionsCFG, "beetle_psx_cdimagecache", psxCdImageCache, 1)
		WriteProperty(coreOptionsCFG, "beetle_psx_use_mednafen_memcard0_method", psxMemcardHandling, 1)
		WriteProperty(coreOptionsCFG, "beetle_psx_analog_toggle", psxDualshockAnalogToggle, 1)
	}
	SaveProperties(coreOptionsCFGFile.FileFullPath, coreOptionsCFG)
}

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

mgM3UFile := new File(romPath . "\" . romTable[1,4] . ".m3u")

mgRomExtensions := "cue|iso|ccd"
mgValidExtension := false

Loop, Parse, mgRomExtensions, |
	If (romExtension = "." . A_LoopField)
		mgValidExtension := true

If (StringUtils.Contains(retroID, "LibRetro_PSX") && romTable.MaxIndex() && mgValidExtension) { ; See if MultiGame table is populated	
	m3uRomIndex := Object()
	mgType := romTable[1,6] . " "
	mgMaxIndex := romTable.MaxIndex()
	mgRomIndex := 0

	If mgM3UFile.Exist()
		mgM3UFile.Delete()

	Loop % mgMaxIndex
	{
		If (romTable[A_Index, 3] = romName) {
			tempType := romTable[A_Index, 5]
			mgRomIndex := StringUtils.TrimLeft(tempType, StringUtils.StringLength(mgType))
			RLLog.Info("Found rom index in rom set in romTable: " . mgRomIndex)
			Break
		}
	}

	If (mgRomIndex > 0) {
		tempRomIndex := mgRomIndex
		Loop % mgMaxIndex
		{
			mgTypeIndex := mgType . tempRomIndex
			m3uRomIndex.Insert(tempRomIndex)

			Loop % mgMaxIndex
			{
				If (romTable[A_Index, 5] = mgTypeIndex) {
					tempRomPath := romTable[A_Index, 1]
					mgM3UFile.Append(tempRomPath . "`n")
					RLLog.Info("Module - Appending rom path to m3u: " . tempRomPath)
					Break
				}
			}

			If (tempRomIndex < mgMaxIndex)
				tempRomIndex++
			Else
				tempRomIndex := 1
		}
	}
}

; MAME/MESS/UME core options
MAMEParam1 := ""
MAMEParam2 := ""
MAMEParam3 := ""
If StringUtils.Contains(core, "^(mame|mess|ume)") {	; if a MAME/MESS/UME core is used
	If !retroMAMEID
		ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for the MAME/MESS/UME LibRetro core")
	Else
		RLLog.Info("Module - MAME/MESS/UME mode using a known ident: " . retroMAMEID)

	If !mameRomPath
		ScriptError("Please set the RetroArch module setting ""BIOS_Roms_Folder"" to the folder that contains your MAME/MESS/UME BIOS roms to use with RetroArch.")
	
	If (retroMAMEID = "mame") {		; want this for arcade mame only
		RLLog.Info("Module - Retroarch MAME/MESS/UME Arcade mode enabled")
		fullRomPath := " """ . romPath . "\" . romName . romExtension . """"
	} Else {
		RLLog.Info("Module - Retroarch MAME/MESS/UME Console/PC mode enabled")
		MAMEParam1 := ""
		MAMEParam2 := " -rompath \""" . mameRomPath . "\"""

		; If we already have a media type, then use it.
		If (StringUtils.Contains(retroMAMEID, "tg16|pce") && retroMAMEMedia = "cart") {
			;MAMEParam3 := " -cart \" . """" . romPath . "\" . romName . romExtension . "\" . """"
			MAMEParam3 := " -cart \""" . romPath . "\" . romName . romExtension . "\"""""
		; TODO: This needs a better way to handle the cdrom bios files, in my opinion. As it is, there's no clean way to pick between the v2.00 or v3.00 bios.
		;       Defaulting to the TurboDuo cdrom bios since it will play 2.00 or 3.00 games.
		} Else If (StringUtils.Contains(retroMAMEID, "tg16|pce") && retroMAMEMedia = "cdrom") {
			;MAMEParam3 := " -cart cdsys -cdrm \" . """" . romPath . "\" . romName . romExtension . "\" . """"
			MAMEParam3 := " -cart scdsys -cdrm \""" . romPath . "\" . romName . romExtension . "\"""""
		} Else {
			; Build a key/value object containing the different MAMEParam3 choices
			MAMEP3 := Object("alice32","cass1","gp32","memc","cpc464","cass","spectrum","cass","dragon64","cass","cdimono1","cdrom","bk0010","cass","neocd","cdrom","neocdz","cdrom","saturn","cdrm","saturnjp","cdrm","svi328n","cass","pecom64","cass","psu","cdrm","svmu","quik","gamecom","cart1","mbeeic","quik1")
			MAMEParam3 := MAMEP3[retroMAMEID]	; search object for the retroMAMEID pair
			MAMEParam3 := " -" . (If MAMEParam3 ? MAMEParam3 : "cart") . " \" . """" . romPath . "\" . romName . romExtension . "\" . """"
		}

		If (retroMAMEID = "mbeeic") ; Applied Technology MicroBee
		{	microbeeModel := IniReadCheck(MAMESysINI, romName, "MicroBee_Model","mbeeic",,1)
			If microbeeModel not in mbee,mbeeic,mbeepc,mbeepc85,mbee56
				ScriptError("This is not a known MicroBee model value: " . microbeeModel)
			Else If (microbeeModel != "mbeeic")
				retroMAMEID := microbeeModel
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
			MAMEParam3 := " -" . mediaDeviceType . " \" . """" . romPath . "\" . romName . romExtension . "\" . """"
		}
		
		If (retroMAMEID = "x68000") ; Sharp X68000
		{	
			If romExtension in .xdf,.hdm,.2hd,.dim,.d77,.d88,.1dd,.dfi,.imd,.ipf,.mfi,.mfm,.td0,.cqm,.cqi,.dsk
				mediaDeviceType := "flop1"
			Else	; .bin format
				mediaDeviceType := "sasi"
			MAMEParam3 := " -" . mediaDeviceType . " \" . """" . romPath . "\" . romName . romExtension . "\" . """"
		}
		
		fullRomPath := MAMEParam1 . MAMEParam2 . MAMEParam3
	}
} Else If (superGB = "true") {
	RLLog.Info("Module - Retroarch Super Game Boy mode enabled")
	fullRomPath := " """ . sgbRomPath . """ --subsystem sgb """ . romPath . "\" . romName . romExtension . """"
} Else {
	RLLog.Info("Module - Retroarch standard mode enabled")
	fullRomPath := " """ . romPath . "\" . romName . romExtension . """"
}

If (retroID = "LibRetro_NFDS")	; Nintendo Famicom Disk System
{	disksysRom := new File(retroSysDir . "\disksys.rom")
	If !disksysRom.Exist()
		ScriptError("RetroArch requires ""disksys.rom"" for " . retroSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If (retroID = "LibRetro_SCD")	; Sega CD
{	If !StringUtils.Contains(romExtension, "\.bin|\.cue|\.iso")
		ScriptError("RetroArch only supports Sega CD games in bin|cue|iso format. It does not support:`n" . romExtension)
	biosCDEBin := new File(retroSysDir . "\bios_CD_E.bin")
	biosCDUBin := new File(retroSysDir . "\bios_CD_U.bin")
	biosCDJBin := new File(retroSysDir . "\bios_CD_J.bin")
	If !biosCDEBin.Exist()
		ScriptError("RetroArch requires ""bios_CD_E.bin"" for " . retroSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
	If !biosCDUBin.Exist()
		ScriptError("RetroArch requires ""bios_CD_U.bin"" for " . retroSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
	If !biosCDJBin.Exist()
		ScriptError("RetroArch requires ""bios_CD_J.bin"" for " . retroSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If StringUtils.Contains(retroID,"LibRetro_PCECD|LibRetro_TGCD")	; NEC PC Engine-CD and NEC TurboGrafx-CD
{	If !StringUtils.Contains(romExtension,"\.ccd|\.cue")
		ScriptError("RetroArch only supports " . retroSystem . " games in ccd or cue format. It does not support:`n" . romExtension)
	sysCard3Pce := new File(retroSysDir . "\syscard3.pce")
	If !sysCard3Pce.Exist()
		ScriptError("RetroArch requires ""syscard3.pce"" for " . retroSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If (retroID = "LibRetro_PCFX")
{	If !StringUtils.Contains(romExtension,"\.ccd|\.cue")
		ScriptError("RetroArch only supports " . retroSystem . " games in ccd or cue format. It does not support:`n" . romExtension)
	pcfxBios := new File(retroSysDir . "\pcfx.bios")
	If !pcfxBios.Exist()
		ScriptError("RetroArch requires ""pcfx.bios"" for " . retroSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If (retroID = "LibRetro_SCUMM")
{
	scummFile := new File(romPath . "\" . romName . ".scummvm")
	If !scummFile.Exist()
		scummFile.Append("""" . romName . """")
}

networkSession := ""
If (enableNetworkPlay = "true") {
	RLLog.Info("Module - Network Multi-Player is an available option for " . dbName)

	netplayNickname := moduleIni.Read("Network", "NetPlay_Nickname","Player",,1)
	getWANIP := moduleIni.Read("Network", "Get_WAN_IP","false",,1)

	If (getWANIP = "true")
		myPublicIP := GetPublicIP()

	RLLog.Warning("Module - CAREFUL WHEN POSTING THIS LOG PUBLICLY AS IT CONTAINS YOUR IP ON THE NEXT LINE")
	defaultServerIP := moduleIni.Read("Network", "Default_Server_IP", myPublicIP,,1)
	defaultServerPort := moduleIni.Read("Network", "Default_Server_Port",,,1)
	lastIP := moduleIni.Read("Network", "Last_IP", defaultServerIP,,1)	; does not need to be on the ISD
	lastPort := moduleIni.Read("Network", "Last_Port", defaultServerPort,,1)	; does not need to be on the ISD

	mpMenuStatus := MultiPlayerMenu(lastIP,lastPort,networkType,,0)
	If (mpMenuStatus = -1) {	; if user exited menu early
		RLLog.Warning("Module - Cancelled MultiPlayer Menu. Exiting module.")
		ExitModule()
	}
	If networkSession {
		RLLog.Info("Module - Using a Network for " . dbName)
		moduleIni.Write(networkPort, "GlobalModuleIni", "Network", "Last_Port")
		; msgbox lastIP: %lastIP%`nlastPort: %lastPort%`nnetworkIP: %networkIP%`nnetworkPort: %networkPort%
		If (networkType = "client") {
			moduleIni.Write(networkIP, "GlobalModuleIni", "Network", "Last_IP")	; Save last used IP and Port for quicker launching next time
			netCommand := " -C " . networkIP . " --port " . networkPort . " --nick """ . netplayNickname . """"	; -C = connect as client
		} Else {	; server
			netCommand := " -H --port " . networkPort . " --nick """ . netplayNickname . """"	; -H = host as server
		}
		RLLog.Warning("Module - CAREFUL WHEN POSTING THIS LOG PUBLICLY AS IT CONTAINS YOUR IP ON THE NEXT LINE")
		RLLog.Info("Module - Starting a network session using the IP """ . networkIP . """ and PORT """ . networkPort . """")
	} Else
		RLLog.Info("Module - User chose Single Player mode for this session")
}

BezelStart(,,(If rotateBezel ? 1:""))

If foundCfg {
	If (stretchToFillBezel = "true" and bezelEnabled = "true" and bezelPath)
	{
		customViewportWidth := bezelScreenWidth
		customViewportHeight := bezelScreenHeight
		customViewportX := 0
		customViewportY := 0
		aspectRatioIndex := 22
		RLLog.Info("Stretching viewport to fit bezel")
	}

	raCfgHasChanges := ""
	WriteRetroProperty("core_options_path", singlecoreoptions)
	WriteRetroProperty("input_overlay", overlay)
	WriteRetroProperty("video_shader", videoShader)
	WriteRetroProperty("aspect_ratio_index", aspectRatioIndex)
	WriteRetroProperty("custom_viewport_width", customViewportWidth)
	WriteRetroProperty("custom_viewport_height", customViewportHeight)
	WriteRetroProperty("custom_viewport_x", customViewportX)
	WriteRetroProperty("custom_viewport_y", customViewportY)
	WriteRetroProperty("video_rotation", rotation)
	WriteRetroProperty("video_crop_overscan", cropOverscan)
	WriteRetroProperty("video_threaded", threadedVideo)
	WriteRetroProperty("video_vsync", vSync)
	WriteRetroProperty("video_scale_integer", integerScale)
	WriteRetroProperty("input_disk_eject_toggle", ejectToggleKey)
	WriteRetroProperty("input_disk_next", nextDiskKey)
	WriteRetroProperty("input_disk_prev", prevDiskKey)
	If StringUtils.Contains(retroID, "LibRetro_PSX") {
		Loop, 8	; Loop 8 times for 8 controllers
		{	p%A_Index%ControllerType := moduleIni.Read(romName . "|" . systemName, "P" . A_Index . "_Controller_Type", 517,,1)
			WriteRetroProperty("input_libretro_device_p" . A_Index, p%A_Index%ControllerType)
		}
	}

	If raCfgHasChanges {
		RLLog.Info("Module - Saving changed settings to: """ . retroCFGFile.FileFullPath . """")
		SaveProperties(retroCFGFile.FileFullPath, retroCFG)
	}
}

fullscreen := If fullscreen = "true" ? " -f" : ""
retroCFGFileCLI := If foundCfg ? " -c """ . retroCFGFile.FileFullPath . """" : ""



HideAppStart(hideEmuObj,hideEmu)

If (StringUtils.Contains(core, "^(mame|mess|ume)") && (retroMAMEID != "mame")) {    ; if a MAME/MESS/UME core is used
	primaryExe.Run(" """ . (retroMAMEID ? retroMAMEID : "") . fullRomPath . """ " . fullscreen . retroCFGFileCLI . " -L """ . libDll . netCommand, "Hide")
} Else If (retroID = "LibRetro_SCUMM") {
	primaryExe.Run(" """ . scummFile . """" . fullscreen . retroCFGFileCLI . " -L """ . libDll . "" . netCommand, "Hide")
} Else If (retroID = "LibRetro_SGB" || If superGB = "true") { ; For some reason, the order of our command line matters in this particular case.
	primaryExe.Run(fullscreen . retroCFGFileCLI . " -L """ . libDll . fullRomPath . netCommand, "Hide")
} Else If mgM3UFile.Exist() {
	primaryExe.Run(" """ . mgM3UFile.FileFullPath . """" . fullscreen . retroCFGFileCLI . " -L """ . libDll . netCommand, "Hide")
} Else {
	primaryExe.Run(" " . fullRomPath . fullscreen . retroCFGFileCLI . " -L """ . libDll . netCommand, "Hide")
}

mpMenuStatus := ""
If networkSession {
	canceledServerWait := false
	multiplayerMenuExit := false
	TimerUtils.SetTimer("NetworkConnectedCheck", 500)

	If (networkType = "server") {
		RLLog.Info("Module - Waiting for a client to connect to your server")
		mpMenuStatus := MultiPlayerMenu(,,,,,,,,"You are the server. Please wait for your client to connect.")
	} Else {	; client
		RLLog.Info("Module - Trying to contact the server to establish a connection.")
		mpMenuStatus := MultiPlayerMenu(,,,,,,,,"Attempting to connect to the server...")
	}

	If (mpMenuStatus = -1) {	; if user exited menu early before a client connected
		RLLog.Warning("Module - Cancelled waiting for the " . If (networkType = "server") ? "client to connect" : "server to respond" . ". Exiting module.")
		If primaryExe.Process("Exist")
			primaryExe.Process("Close")	; must close process as the exe is waiting for a client to connect and no window was drawn yet
		ExitModule()
	} Else {	; blank response from MultiPlayerMenu, exited properly
		RLLog.Info("Module - " . If (networkType = "server") ? "Client has connected" : "Connected to the server")
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
	}
	TimerUtils.SetTimer("NetworkConnectedCheck", "Off")
} Else {	; single player
	emuPrimaryWindow.Wait()
	emuPrimaryWindow.WaitActive()
}

If (hideConsole = "true")
	emuConsoleWindow.Set("Transparent", "On")	; makes the console window transparent so you don't see it on exit

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


; Writes new properties into the retroCFG if defined by user
WriteRetroProperty(key,value="") {
	If (value != "") {
		Global retroCFG,raCfgHasChanges
		WriteProperty(retroCFG, key, value,1,1)
		raCfgHasChanges := 1
	}
}

; Used to convert between RetroArch keys and usable data
ConvertRetroCFGKey(txt,direction="read"){
	Global emuPath,RLLog
	If (direction = "read")
	{	newtxt := StringUtils.TrimLeft(txt,1,0)	; removes the " from the left of the txt
		newtxt := StringUtils.TrimRight(newtxt,1,0)	; removes the " from the right of the txt
		relativeCheck := StringUtils.SubStr(newtxt,1,1,0)
		If StringUtils.Contains(relativeCheck,":",0) {	; if the path contains a ":" then it is a relative path
			RLLog.Debug("ConvertRetroCFGKey - " . newtxt . " is a relative path")
			newtxt := StringUtils.TrimLeft(newtxt,1,0)	; removes the : from the left of the txt
			newtxt := AbsoluteFromRelative(emuPath, "." . newtxt)	; convert relative to absolute
		}
		If StringUtils.Contains(newtxt,"/",0)
			newtxt := StringUtils.Replace(newtxt,"/","\",1,,0)	; replaces all forward slashes with backslashes
	} Else If (direction = "write")
	{	newtxt := """" . txt . """"	; wraps the txt with ""
		If StringUtils.Contains(newtxt,"\\",0)
			newtxt := StringUtils.Replace(newtxt,"\","/",1,,0)	; replaces all backslashes with forward slashes
	} Else
		ScriptError("Not a valid use of ConvertRetroCFGKey. Only ""read"" or ""write"" are supported.")
	RLLog.Debug("ConvertRetroCFGKey - Converted " . txt . " to " . newtxt)
	Return newtxt
}

MultiGame:
	KeyUtils.SetKeyDelay(100)
	emuPrimaryWindow.Activate()
	KeyUtils.Send("{" . ejectToggleKey . " down}{" . ejectToggleKey . " up}")	; eject disc in Retroarch
	If (!mgLastRomIndex) {
		mgLastRomIndex := mgRomIndex
	}
	selectedRomIndex := 0
	selectedRomIndex := StringUtils.TrimLeft(selectedRomNum, StringUtils.StringLength(mgType,0))
	
	Loop % mgMaxIndex
	{
		If (m3uRomIndex[A_index] = mgLastRomIndex) {
			tempLastRomIndex := A_index
			RLLog.Debug("Module - Last index: " . tempLastRomIndex)
		}
		If (m3uRomIndex[A_index] = selectedRomIndex) {
			tempSelectedRomIndex := A_index
			RLLog.Debug("Module - Selected index: " . tempSelectedRomIndex)
		}
	}
	
	mgNewIndex := tempLastRomIndex - tempSelectedRomIndex
	
	If (mgNewIndex < 0) {
		mgNewIndex := mgNewIndex * -1
		Loop % mgNewIndex
		{
			RLLog.Debug("Module - Sending the next disk key: " . nextDiskKey)
			KeyUtils.Send("{" . nextDiskKey . " down}{" . nextDiskKey . " up}")
		}
	} Else If (mgNewIndex > 0) {
		Loop % mgNewIndex
		{
			RLLog.Debug("Module - Sending the previous disk key: " . mgNewIndex)
			KeyUtils.Send("{" . prevDiskKey . " down}{" . prevDiskKey . " up}")
		}
	}
	
	KeyUtils.Send("{" . ejectToggleKey . " down}{" . ejectToggleKey . " up}")	; close disc in Retroarch
	mgLastRomIndex := selectedRomIndex
Return

NetworkConnectedCheck:
	If clientConnected
		multiplayerMenuExit := true
	Else If emuPrimaryWindow.Exist() {
		RLLog.Info("Module - RetroArch session started, closing the MultiPlayer menu")
		multiplayerMenuExit := true
	}
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
