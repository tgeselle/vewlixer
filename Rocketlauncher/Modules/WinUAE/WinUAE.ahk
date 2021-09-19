MEmu := "WinUAE"
MEmuV := "v3.0.0"
MURL := ["http://www.winuae.net/"]
MAuthor := ["brolly","Turranius"]
MVersion := "2.2.10"
MCRC := "A554B31D"
iCRC := "449BD1FF"
MID := "635138307631183750"
MSystem := ["Commodore Amiga","Commodore Amiga CD32","Commodore CDTV","Commodore Amiga CD","Commodore Amiga Demos","Arcadia Multi Select System"]
;----------------------------------------------------------------------------
; Notes:
; You can have specific configuration files inside a Configurations folder on WinUAE main dir.
; Just name them the same as the game name on the XML file.
; Make sure you create a host config files with these names:
; CD32 : cd32host.uae and cd32mousehost.uae;
; CDTV : cdtvhost.uae and cdtvmousehost.uae;
; Amiga : amigahost.uae;
; Amiga CD : amigacdhost.uae;
; cd32mouse and cdtvmouse are for mouse controlled games on these systems, you should configure 
; Windows Mouse on Port1 and a CD32 pad on Port2. For Amiga and Amiga CD make sure you set both 
; a joystick and a mouse on Port1 and only a joystick on Port2.
; Set all your other preferences like video display settings. And make sure you are saving a HOST 
; configuration file and not a general configuration file.
;
; If you want to configure an exit key through WinUAE:
; Host-Input-Configuration #1-RAW Keyboard and then remap the desired key to Quit Emulator.
; If you want to configure a key to toggle fullscreen/windowed mode:
; Host-Input-Configuration #1-RAW Keyboard and then remap the desired key to Toggle windowed/fullscreen.
;
; CD32 and CDTV:
; A settings file called System_Name.ini should be placed on your module dir. on that file you can define if a 
; game uses mouse or if it needs the special delay hack loading method amongst other things. Example of such a file:
;
; [Lemmings (Europe)]
; UseMouse=true
;
; [Project-X & F17 Challenge (Europe)]
; DelayHack=true
;
; Amiga:
; For MultiGame support make sure you don't change the default WinUAE diskswapper keys which are:
; END+1-0 (not numeric keypad) = insert image from swapper slot 1-10
; END+SHIFT+1-0 = insert image from swapper slot 11-20
; END+CTRL+1-4 = select drive
;
; To do that follow the same procedure as above for the exit 
; key, but on F11 set it to Toggle windowed/fullscreen. Make sure you save your configuration afterwards.
; Note : If you want to use Send commands to WinUAE for any keys that you configured through Input-Configuration panel make sure you 
; set those keys for Null Keyboard! This is a virtual keyboard that collects all input events that don't come from physical 
; keyboards. This applies to the exit or windowed/fullscreen keys mentioned above.
;
; If you are using WHDLoad games, but want to keep your default user-startup file after exiting then make a copy of it in the 
; WHDFolder\S (Set in PathToWHDFolder) and name it default-user-startup. This file will then be copied over S\user-startup on exit.
;
; Amiga CD:
; Several Amiga CD games require Hard drive installation, but will also require the game CD to be inserted in the CD drive.
; The module will take care of this automatically as long as you have the CD image alongside with HDD installed files (.hdf or .vhd).
; Amiga CD games will require a Workbench disk by default, for games that auto boot, make sure you go to the module settings and set 
; RequiresWB to false.
;
; To use the shader options you must first download and put in place the shader pack from the WinUAE website found here:
; http://www.winuae.net/ 
; Download the Direct3D Pixel Shader Filters and extract the zip file into your emulator directory
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object

; This object controls how the module reacts to different systems. WinUAE can play several systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Commodore Amiga","a500","Commodore Amiga CD32","cd32","Commodore CDTV","cdtv","Commodore Amiga CD","amigacd","Commodore Amiga Demos","a500","Arcadia Multi Select System","a500")
ident := mType[systemName]	; search object for the systemName identifier MESS uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this WinUAE module: " . moduleName)

SpecialCFGFile := new File(emuPath . "\Configurations\" . romName . ".uae")

If StringUtils.Contains(romExtension,"\.hdf|\.vhd")
	DefaultRequireWB := "true"
Else
	DefaultRequireWB := "false"

If StringUtils.Contains(romExtension,"\.zip|\.lha|\.rar|\.7z")
{
	SlaveFile := RLObject.findByExtension(romPath . "\" . romName . romExtension, "slave")	; find rom in archive if it's extension is .slave
	If SlaveFile {
		If StringUtils.Contains(romName,"\(AGA\)")
		{
			defaultCycleExact := "false"
			defaultCpuSpeed := "max"
		} Else {
			defaultCycleExact := "true"
			defaultCpuSpeed := "real"
		}
		defaultImmediateBlittler := "false"
		defaultCpuCompatible := "false"
		defaultCacheSize := "0" ;8192
	}
}

If (ident = "amigacd") {
	DefaultRequireWB := "true" ;Most Amiga CD games require installation so better to default this to true
	defaultz3Ram := "128"
	isAmigaCd := "true"
}

; Settings
fullscreen := moduleIni.Read(romName . "|Settings", "ScreenMode","true",,1)
quickstartmode := moduleIni.Read(romName . "|Settings", "QuickStartMode",A_Space,,1)
kickstart_rom_file := moduleIni.Read(romName . "|Settings", "KickstartFile",,,1)
options := moduleIni.Read(romName . "|Settings", "Options",,,1)
bezelTopOffset := moduleIni.Read(romName . "|Settings", "Bezel_Top_Offset","0",,1)
bezelBottomOffset := moduleIni.Read(romName . "|Settings", "Bezel_Bottom_Offset","0",,1)
bezelRightOffset := moduleIni.Read(romName . "|Settings", "Bezel_Right_Offset","0",,1)
bezelLeftOffset := moduleIni.Read(romName . "|Settings", "Bezel_Left_Offset","0",,1)
use_gui := moduleIni.Read(romName . "|Settings", "UseGui","false",,1)
floppyspeed := moduleIni.Read(romName . "|Settings", "FloppySpeed","turbo",,1)
PathToWorkBenchBase := moduleIni.Read(romName . "|Settings", "PathToWorkBenchBase", EmuPath . "\HDD\Workbench31_Lite.vhd",,1)
PathToWorkBenchBase := AbsoluteFromRelative(EmuPath, PathToWorkBenchBase)
PathToExtraDrive := moduleIni.Read(romName . "|Settings", "PathToExtraDrive",,,1)
If (PathToExtraDrive)
	PathToExtraDrive := AbsoluteFromRelative(EmuPath, PathToExtraDrive)

usemouse := moduleIni.Read(romName, "UseMouse","false",,1) ;Only needed for CDTV and CD32
delayhack := moduleIni.Read(romName, "DelayHack","false",,1) ;Only needed for CDTV and CD32
requireswb := moduleIni.Read(romName, "RequiresWB",DefaultRequireWB,,1)

; Display 
videomode := moduleIni.Read(romName . "|Display", "VideoMode","PAL",,1)
gfx_width := moduleIni.Read(romName . "|Display", "XResolution","native",,1)
gfx_height := moduleIni.Read(romName . "|Display", "YResolution","native",,1)
gfx_blacker_than_black := moduleIni.Read(romName . "|Display", "BlackerThanBlack","false",,1)
gfx_flickerfixer := moduleIni.Read(romName . "|Display", "RemoveInterlaceArtifacts","false",,1)
gfx_linemode := moduleIni.Read(romName . "|Display", "LineMode",,,1)
gfx_filter_autoscale := moduleIni.Read(romName . "|Display", "AutoScale",,,1)
gfx_filter_mask := moduleIni.Read(romName . "|Display", "ShaderMask",,,1)
gfx_filter := moduleIni.Read(romName . "|Display", "FilterShader",,,1)
gfx_filter_mode := moduleIni.Read(romName . "|Display", "FilterShaderScale",,,1)
gfx_lores_mode := moduleIni.Read(romName . "|Display", "FilteredLowResolution",,,1)
gfx_resolution := moduleIni.Read(romName . "|Display", "ResolutionMode","hires",,1)

; CPU 
cpu := moduleIni.Read(romName . "|CPU", "CPU",,,1)
cpuspeed := moduleIni.Read(romName . "|CPU", "CpuSpeed",defaultCpuSpeed,,1)
cpucycleexact := moduleIni.Read(romName . "|CPU", "CpuCycleExact",,,1)
cpucompatible := moduleIni.Read(romName . "|CPU", "CpuCompatible",defaultCpuCompatible,,1)
mmu_model := moduleIni.Read(romName . "|CPU", "MMU","false",,1)
cpu_no_unimplemented := moduleIni.Read(romName . "|CPU", "DisableUnimplementedCPU","true",,1)
fpu := moduleIni.Read(romName . "|CPU", "FPU",,,1)
fpu_strict := moduleIni.Read(romName . "|CPU", "MoreCompatibleFPU","false",,1)
fpu_no_unimplemented := moduleIni.Read(romName . "|CPU", "DisableUnimplementedFPU","true",,1)
cachesize := moduleIni.Read(romName . "|CPU", "CacheSize",defaultCacheSize,,1)
24bitaddressing := moduleIni.Read(romName . "|CPU", "24-BitAddressing","true",,1)

; Chipset
cycleexact := moduleIni.Read(romName . "|Chipset", "CycleExact",defaultCycleExact,,1)
immediateblitter := moduleIni.Read(romName . "|Chipset", "ImmediateBlitter",defaultImmediateBlittler,,1)
blittercycleexact := moduleIni.Read(romName . "|Chipset", "BlitterCycleExact",,,1)
collisionlevel := moduleIni.Read(romName . "|Chipset", "CollisionLevel",,,1)

; RAM
chipmemory := moduleIni.Read(romName . "|RAM", "ChipMemory",,,1)
fastmemory := moduleIni.Read(romName . "|RAM", "FastMemory",,,1)
autoconfigfastmemory := moduleIni.Read(romName . "|RAM", "AutoConfigFastMemory",,,1)
slowmemory := moduleIni.Read(romName . "|RAM", "SlowMemory",,,1)
z3fastmemory := moduleIni.Read(romName . "|RAM", "Z3FastMemory",defaultz3Ram,,1)
megachipmemory := moduleIni.Read(romName . "|RAM", "MegaChipMemory",,,1)
processorslotfastmemory := moduleIni.Read(romName . "|RAM", "ProcessorSlotFast",,,1)

; Expansions
rtgcardtype := moduleIni.Read(romName . "|Expansions", "RTGCardType",,,1)
rtgvramsize := moduleIni.Read(romName . "|Expansions", "RTGVRAMSize",,,1)
rtghardwaresprite := moduleIni.Read(romName . "|Expansions", "RTGHardwareSprite",,,1)

; WHDLoad
PathToWHDFolder := moduleIni.Read(romName . "|WHDLoad", "PathToWHDFolder", EmuPath . "\HDD\WHD",,1)
PathToWHDFolder := AbsoluteFromRelative(EmuPath, PathToWHDFolder)
whdloadoptions := moduleIni.Read(romName . "|WHDLoad", "WHDLoadOptions","PRELOAD",,1)
neverextract := moduleIni.Read(romName . "|WHDLoad", "NeverExtract","false",,1)

; CD-Rom
CDRomImage := moduleIni.Read(romName, "CDRomImage",,,1)

If PathToExtraDrive
	ExtraDriveFolder := new Folder(PathToExtraDrive)

BezelStart()

; Force Full Screen Windowed and Autoscale if Bezels are enabled. This must be done here since window class name changes from windowed to fullscreen modes
If bezelPath {
	fullscreen := "fullwindow"
	gfx_filter_autoscale := "scale"
}

winUAEWindowClass := "PCsuxRox"		; Class name is different depending on if the game is being run windowed or fullscreen
If (fullscreen = "true" or fullscreen = "fullwindow")
	winUAEWindowClass := "AmigaPowah"

emuPrimaryWindow := new Window(new WindowTitle(,winUAEWindowClass))	; instantiate primary emulator window object

If (cpucycleexact and blittercycleexact)
	cycleexact := "" ;No need to set cycle exact if both cpu and blitter are set as it could lead to inconsistent states

if (cpu != "68060" and cpu_no_unimplemented)
	cpu_no_unimplemented := "" ; cpu_no_unimplemented requires a 68060 CPU. Disable it if its true without a 68060 CPU.}

if (fpu = "internal") {
	if (cpu = "68040" || cpu = "68060") ; Internal FPU is only valid for 040 and 060 cpus
		fpu := cpu
	else
		fpu := ""
}

; Make sure 24bitaddressing is false if using Z3 memory.
If z3fastmemory 
	24bitaddressing := "false"
	
;Fill both z3 slots when amount of RAM requires it
If (z3fastmemory = 384) {
	z3fastmemory := 256
	z3fastmemoryb := 128
} Else If (z3fastmemory = 768) {
	z3fastmemory := 512
	z3fastmemoryb := 256
} Else If (z3fastmemory = 1536) {
	z3fastmemory := 1024
	z3fastmemoryb := 512
}	

videomode := If videomode = "NTSC" ? "-s ntsc=true" : ""

If (requireswb = "true") {
	ident := "a1200"
	If !PathToWorkBenchBase
		ScriptError("You must set the WinUAE module setting for PathToWorkBenchBase before using WorkBench")
	Else {
		WorkBenchBaseFile := new File(PathToWorkBenchBase)
		WorkBenchBaseFile.CheckFile()
		wbDrive := "-s hardfile=rw,32,1,2,512," . """" . WorkBenchBaseFile.FileFullPath . """"
	}
}

If StringUtils.Contains(romExtension,"\.hdf|\.vhd")
{
	ident := "a1200"
	gameDrive := "-s hardfile=rw,32,1,2,512," . """" . romPath . "\" . romName . romExtension . """"
}

If ExtraDriveFolder.FileFullPath
{
	ExtraDriveFolder.CheckFile(,,,,,1)	; allow folders
	If StringUtils.InStr(ExtraDriveFolder.Exist(), "D")	; it's a folder
		extraDrive := " -s filesystem=rw,Extra:" . """" . ExtraDriveFolder.FileFullPath . """"
	Else	; it's a file
	{
		StringUtils.SplitPath(pathtoextradrive,,,extradriveExtension)
		If StringUtils.Contains(ExtraDriveFolder.FileExt,"hdf|vhd")
			extraDrive := " -s hardfile=rw,32,1,2,512," . """" . ExtraDriveFolder.FileFullPath . """"
		Else
			extraDrive := " -s filesystem=ro,Extra:" . """" . ExtraDriveFolder.FileFullPath . """"
	}
}

options := options . " " . videomode

If (ident = "a500" or ident = "a1200") {
	If StringUtils.Contains(romName,"\(AGA\)|\(LW\)")
		ident := "a1200"

	If SlaveFile {
		If !PathToWHDFolder
			ScriptError("You must set the WinUAE module setting for PathToWHDFolder before using WHD")
		
		PathToWHDFolder := new Folder(PathToWHDFolder)
		PathToWHDFolder.CheckFolder()

		ident := "a1200"

		;Create the user-startup file to launch the game
		WHDUserStartupFile := new File(PathToWHDFolder.FilePath . "\S\user-startup")
		StringUtils.SplitPath(SlaveFile, SlaveName, SlaveFolder)

		WHDUserStartupFile.Delete()
		WHDUserStartupFile.Append("echo """";`n")
		WHDUserStartupFile.Append("echo Running: " . SlaveName . ";`n")
		WHDUserStartupFile.Append("echo """";`n")
		WHDUserStartupFile.Append("cd dh1:" . SlaveFolder . ";`n")
		WHDUserStartupFile.Append("whdload " . SlaveName . " " . whdloadoptions . ";`n")
	}
}

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

;--- Detecting what Configuration File to use (Or Quick Start Mode) ---

If SpecialCFGFile.Exist() {
	;Game specific configuration file exists
	configFile := romName . ".uae"
} Else {
	;Game specific configuration file doesn't exist
	If (ident = "cd32" or ident = "cdtv") {
		configFile := If (usemouse = "true") ? ("host\" . ident . "mousehost.uae") : ("host\" . ident . "host.uae")
		quickcfg := If (ident = "cd32") ? ("-s quickstart=" . ident . "`,0 -s chipmem_size=8") : ("-s quickstart=" . ident . "`,0")
	} Else {
		;Amiga or Amiga CD game

		configFile := If systemName = "Commodore Amiga CD" ? "host\amigacdhost.uae" : "host\amigahost.uae"
		If quickstartmode
			quickcfg := "-s quickstart=" . quickstartmode
		Else
			quickcfg := If (ident = "a500") ? "-s quickstart=a500`,1" : (If (isAmigaCd = "true") ? "-s quickstart=a4000`,1" : "-s quickstart=a1200`,1")
	}
}

;--- Setting up command line arguments to use ---

; Global command line arguments.
If use_gui
	options := options . " -s use_gui=" . use_gui

If (fullscreen = "true") {
	options := options . " -s gfx_width_fullscreen=" . gfx_width
	options := options . " -s gfx_height_fullscreen=" . gfx_height
} Else If (fullscreen = "false") {
	If (gfx_width != "native" and gfx_height != "native") {
		options := options . " -s gfx_width_windowed=" . gfx_width
		options := options . " -s gfx_height_windowed=" . gfx_height
	}
}

If gfx_linemode
	options := options . " -s gfx_linemode=" . gfx_linemode
If gfx_filter_autoscale
	options := options . " -s gfx_filter_autoscale=" . gfx_filter_autoscale
If gfx_blacker_than_black
	options := options . " -s gfx_blacker_than_black=" . gfx_blacker_than_black
If gfx_flickerfixer
	options := options . " -s gfx_flickerfixer=" . gfx_flickerfixer
If gfx_filter_mode
	options := options . " -s gfx_filter_mode=" . gfx_filter_mode

If (gfx_lores_mode = "true")
	options := options . " -s gfx_lores_mode=filtered"
Else If (gfx_lores_mode = "false")
	options := options . " -s gfx_lores_mode=normal"

If gfx_resolution {
	options := options . " -s gfx_resolution=" . gfx_resolution
	If (gfx_resolution = "lores") {
		options := options . " -s gfx_autoresolution_vga=false"
		options := options . " -s gfx_lores=true"
	}
	Else {
		options := options . " -s gfx_lores=false"
	}
}

If gfx_filter_mask {
	GfxFilterMaskFile := new File(emuPath . "\Plugins\masks\" . gfx_filter_mask)
	RLLog.Debug("Module - Filter - gfx_filter_mask_path = " . GfxFilterMaskFile.FileFullPath)
	If GfxFilterMaskFile.Exist()
		options := options . " -s gfx_filter_mask=" . gfx_filter_mask
}

If gfx_filter {
	If (StringUtils.SubStr(gfx_filter, 1, 4) = "D3D:") {
		FilterFileName := StringUtils.TrimLeft(gfx_filter, 4)
		FilterFile := new File(emuPath . "\Plugins\filtershaders\direct3d\" . FilterFileName)
		If FilterFile.Exist()
			options := options . " -s gfx_filter=" . gfx_filter
	} Else {
		options := options . " -s gfx_filter=" . gfx_filter
	}
}

If (ident = "cd32" or ident = "cdtv") {
	If (delayhack = "true")
		options := options . " -s cdimage0=" . """" . romPath . "\" . romName . romExtension . """" . "`,delay"
	Else
		options := options . " -cdimage=" . """" . romPath . "\" . romName . romExtension . """"
	
	If fastmemory
		options := options . " -s fastmem_size=" . fastmemory
} Else {
	If floppyspeed
		options := options . " -s floppy_speed=" . floppyspeed
	If kickstart_rom_file
		options := options . " -s kickstart_rom_file=" . """" . kickstart_rom_file . """"
	If (cachesize || cachesize = "0")
		options := options . " -s cachesize=" . cachesize
	If immediateblitter
		options := options . " -s immediate_blits=" . immediateblitter
	If cycleexact
		options := options . " -s cycle_exact=" . cycleexact
	If cpucycleexact
		options := options . " -s cpu_cycle_exact=" . cpucycleexact
	If blittercycleexact
		options := options . " -s blitter_cycle_exact=" . blittercycleexact
	If cpucompatible
		options := options . " -s cpu_compatible=" . cpucompatible
	If cpuspeed
		options := options . " -s cpu_speed=" . cpuspeed
	If cpu
		options := options . " -s cpu_model=" . cpu
	If cpu_no_unimplemented
		options := options . " -s cpu_no_unimplemented=" . cpu_no_unimplemented		
	If (mmu_model = "true")	
		options := options . " -s mmu_model=" . cpu ; not a typo. Actually needs the same value as CPU.
	If 24bitaddressing
		options := options . " -s cpu_24bit_addressing=" . 24bitaddressing	
	If fpu
		options := options . " -s fpu_model=" . fpu
	If fpu_strict
		options := options . " -s fpu_strict=" . fpu_strict	
	If fpu_no_unimplemented
		options := options . " -s fpu_no_unimplemented=" . fpu_no_unimplemented
	If collisionlevel
		options := options . " -s collision_level=" . collisionlevel
	If chipmemory
		options := options . " -s chipmem_size=" . chipmemory
	If fastmemory
		options := options . " -s fastmem_size=" . fastmemory
	If autoconfigfastmemory
		options := options . " -s fastmem_autoconfig=" . autoconfigfastmemory
	If slowmemory
		options := options . " -s bogomem_size=" . slowmemory
	If z3fastmemory
		options := options . " -s z3mem_size=" . z3fastmemory
	If z3fastmemoryb
		options := options . " -s z3mem2_size=" . z3fastmemoryb
	If megachipmemory
		options := options . " -s megachipmem_size=" . megachipmemory
	If processorslotfastmemory
		options := options . " -s mbresmem_size=" . processorslotfastmemory
	If rtgcardtype
		options := options . " -s gfxcard_type=" . rtgcardtype
	If rtgvramsize
		options := options . " -s gfxcard_size=" . rtgvramsize
	If rtghardwaresprite
		options := options . " -s gfxcard_hardware_sprite=" . rtghardwaresprite

	If SlaveFile {
		;WHDLoad Game
		options := options . " -s filesystem=rw,WHD:" . """" . PathToWHDFolder.FilePath . """" . " -s filesystem=ro,Games:" . """" . romPath . "\" . romName . romExtension . """"
	}
	Else If gameDrive {
		;HDD Game
		options := options . " " . wbDrive . " " . gameDrive

		;Check if there's also a CD to load
		CDRomImageFile := new File(romPath . "\" . CDRomImage)
		If (CDRomImage) {
			If CDRomImageFile.Exist()
				cdDrive := CDRomImageFile.FileFullPath
		}
		Else {
			CDRomImageCUEFile := new File(romPath . "\" . romName . ".cue")
			CDRomImageISOFile := new File(romPath . "\" . romName . ".iso")
			CDRomImageMDSFile := new File(romPath . "\" . romName . ".mds")
			If CDRomImageCUEFile.Exist()
				cdDrive := CDRomImageCUEFile.FileFullPath
			If CDRomImageISOFile.Exist()
				cdDrive := CDRomImageISOFile.FileFullPath
			If CDRomImageMDSFile.Exist()
				cdDrive := CDRomImageMDSFile.FileFullPath
		}

		If extraDrive
			options := options . extraDrive
		If cdDrive
			options := options . " -cdimage=" . """" . cdDrive . """" . " -s win32.map_cd_drives=true -s scsi=true"
	} Else If StringUtils.Contains(romExtension,"\.cue|\.iso|\.mds")
	{
		;Amiga CD game

		;Check if game has a HDD installation
		RomHDFFile := new File(romPath . "\" . romName . ".hdf")
		RomVHDFile := new File(romPath . "\" . romName . ".vhd")
		If RomHDFFile.Exist()
			installedHdd := " -s hardfile=rw,32,1,2,512," . """" . RomHDFFile.FileFullPath . """"
		If RomVHDFile.Exist()
			installedHdd := " -s hardfile=rw,32,1,2,512," . """" . RomVHDFile.FileFullPath . """"

		options := options . " " . wbDrive . installedHdd
		
		If extraDrive
			options := options . extraDrive

		options := options . " -cdimage=" . """" . romPath . "\" . romName . romExtension . """" . " -s win32.map_cd_drives=true -s scsi=true"
	} Else {
		;Floppy Game

		;MultiDisk loading, this will load the first 2 disks into drives 0 and 1 since some games can read from both drives and therefore 
		;the user won't need to change disks through the MG menu. We can have up to 4 drives, but most of the games will only support 2 drives 
		;so disks are only loaded into the first 2 for better compatibility. Remaining drives will be loaded into quick disk slots.
		
		romCount := romTable.MaxIndex()
		If StringUtils.Contains(romName,"\(Disk 1\)")
		{
			;If the user boots any disk rather than the first one, multi disk support must be done through RocketLauncher MG menu
			If romCount > 1
			{
				options := options . " -s nr_floppies=2"
				mgoptions := " -s floppy1=" . """" . romTable[2,1] . """"
			}
		}
		options := options . " " . floppyspeed . " -s floppy0=" . """" . romPath . "\" . romName . romExtension . """" . mgoptions
		
		If romCount > 1
		{
			;DiskSwapper
			;diskswapper := " -diskswapper "
			Loop % romTable.MaxIndex() ; loop each item in our array
			{
				;diskswapper := diskswapper . """" . romTable[A_Index,1] . ""","
				diskswapper := diskswapper . " -s diskimage" . (A_Index-1) . "=" . """" . romTable[A_Index,1] . """"
			}
			options := options . diskswapper
		}
	}
}

configFile := new File(emuPath . "\Configurations\" . configFile)

;param1 := "-f " . """" . configFileFullPath . """" . " " . quickcfg
If configFile.Exist()
	param1 := " -f " . """" . configFile.FileFullPath . """"
param1 := param1 . " " . quickcfg

param2 := " -s gfx_fullscreen_amiga=" . fullscreen
param3 := options

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(param1 . param2 . A_Space . param3 . " -portable")

If (use_gui = "true") {
	emuPropertiesWindow := new Window(new WindowTitle("WinUAE Properties"))
	emuPropertiesWindow.Wait(60)
	FadeInExit()
	emuPropertiesWindow.WaitClose()
	TimerUtils.Sleep(100)
	errLvl := primaryExe.Process("WaitClose")
	If (errLvl = 0) {
		7zCleanUp()
		ExitModule()
	}
}

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


MultiGame:
	If (currentButton = 10)
		diskslot := 0
	Else If (currentButton > 10)
		diskslot := currentButton - 10
	Else
		diskslot := currentButton

	If (currentButton > 10)
		KeyUtils.Send("{End Down}{Shift Down}" . diskslot . "{Shift Up}{End Up}")
	Else
		KeyUtils.Send("{End Down}" . diskslot . "{End Up}")
Return

CloseProcess:
	If (ident = "a500" or ident = "a1200") {
		If SlaveFile {
			PathToWHDFolder.CheckFolder()
			;Copy default-user-startup to user-startup if file exists
			WHDDefaultFile := new File(PathToWHDFolder . "\S\default-user-startup")
			If WHDDefaultFile.Exist()
				WHDDefaultFile.Copy(PathToWHDFolder . "\S\user-startup",1)
		}
	}
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
