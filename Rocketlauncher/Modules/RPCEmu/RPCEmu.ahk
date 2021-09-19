MEmu := "RPCEmu"
MEmuV := "v0.8.14"
MURL := ["http://www.marutan.net/rpcemu/"]
MAuthor := ["brolly","manson976"]
MVersion := "1.0.2"
MCRC := "1D46B4DB"
iCRC := "D6A61E4"
MID := "635599773137091110"
MSystem := ["Acorn Archimedes"]
;----------------------------------------------------------------------------
; Notes:
; You will need to have the RiscOS roms in the Roms folder
; WaitTime in the module settings file should be adjusted to your machine as RiscOS load might be slower or faster
; You can download a blank pre-formatted hdf file to use as HDD disk 4 and/or disk 5 here:
; http://b-em.bbcmicro.com/arculator/download.html
;
; hdf games are supported, but they will always be mounted in drive 5 so make sure you go to RiscOS desktop-Apps-!Configure-Discs and set the number of IDE hard discs to 2.
; You can have multiple games inside the same hdf file, to be able to launch the games make sure you set the HdfFileName in the module ini file
;
; Some games will start minimized and you'll need to click their icon on the system tray at the bottom right corner of the RiscOS desktop. Due to the games being launched 
; through command line in some cases the icon won't show up and apparently the game failed to boot, before assuming that click with the mouse on that area because it's likely that the 
; game is running, but the icon simply isn't visible.
;
; You can use HostFS as main bootable drive within RISC OS just search/download uniboot.zip place the file in hostfs, extract the file inside the os itself by using !sparrkplug  - you' find this on many Risc sites. 
; Enter the following commands/f12 key:
; *configure filesystem hostfs
; *configure boot
; Reset the Emulator
; Set the Resolution using the !Boot application
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)				; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("RPCEmu","WindowsApp"))	; instantiate primary emulator window object
emuOpenRomWindow := new Window(new WindowTitle("Open","#32770"))

;General Settings
Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
WaitTime := moduleIni.Read("Settings", "WaitTime","5000",,1)
UseDxWnd := moduleIni.Read("Settings", "UseDxWnd","false",,1)

;Rom Settings
Model := moduleIni.Read(romName, "Model","RPC710",,1)
CpuType := moduleIni.Read(romName, "CpuType","ARM710",,1)
RAMSize := moduleIni.Read(romName, "RAMSize","32",,1)
VRAMSize := moduleIni.Read(romName, "VRAMSize","2",,1)

WaitTime := moduleIni.Read(romName, "WaitTime",WaitTime,,1)
ExecuteCmd := moduleIni.Read(romName, "ExecuteCmd",A_Space,,1)
WorkingDir := moduleIni.Read(romName, "WorkingDir",A_Space,,1)
OpenFiler := moduleIni.Read(romName, "OpenFiler","false",,1)
CloseWimp := moduleIni.Read(romName, "CloseWimp","false",,1)
WimpMode := moduleIni.Read(romName, "WimpMode","",,1)
HdfFileName := moduleIni.Read(romName, "HdfFileName",A_Space,,1)

If (UseDxWnd = "true")
	BezelStart()
Else
	BezelStart("fixResMode")

If ((BezelEnabled() || Fullscreen = "false") && UseDxWnd = "true")
	Fullscreen := "true"
Else
	UseDxWnd := "false"

If (!HdfFileName && romExtension = ".hdf")
	HdfFileName := romName . romExtension

If (HdfFileName) {
	HdfFile := new File(romPath . "\" . HdfFileName)
	HdfFile.CheckFile()
}

cfgFile := new PropertiesFile(emuPath . "\rpc.cfg")
cfgFile.CheckFile()
cfgFile.LoadProperties()

hideEmuObj := Object(emuOpenRomWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, 7zExtractPath)

; Read current settings from rpc.cfg
CurrentModel := cfgFile.ReadProperty("model")
CurrentCpuType := cfgFile.ReadProperty("cpu_type")
CurrentRAMSize := cfgFile.ReadProperty("mem_size")
CurrentVRAMSize := cfgFile.ReadProperty("vram_size")

If (Model != CurrentModel)
	cfgFile.WriteProperty("model",Model,1)
If (CpuType != CurrentCpuType)
	cfgFile.WriteProperty("cpu_type",CpuType,1)
If (RAMSize != CurrentRAMSize)
	cfgFile.WriteProperty("mem_size",RAMSize,1)
If (VRAMSize != CurrentVRAMSize)
	cfgFile.WriteProperty("vram_size",VRAMSize,1)

ExecuteCmd := FixCommand(ExecuteCmd)

cfgFile.SaveProperties()	; save changes to Preferences.cfg

If (HdfFile) ;Copy game to drive 5
	HdfFile.Copy(emuPath . "\hd5.hdf", 1)

HideAppStart(hideEmuObj,hideEmu)

If (UseDxWnd = "true")
	DxwndRun()

primaryExe.Run()

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

KeyUtils.SetKeyDelay(50,50)

If StringUtils.Contains(romExtension,"\.adf|\.apd") {
	;Disk loading
	emuPrimaryWindow.MenuSelectItem("Disc", "Load Disc :0")
	emuOpenRomWindow.OpenROM(romPath . "\" . romName . romExtension)
	emuOpenRomWindow.WaitActive()
}

If (ExecuteCmd OR WorkingDir) {
	TimerUtils.Sleep(WaitTime) ;Wait until RiscOS has finished booting
	KeyUtils.SetKeyDelay(50,50)

	driveNr := A_Space
	If StringUtils.Contains(romExtension,"\.adf|\.apd")
		driveNr := "0"
	Else If HdfFile
		driveNr := "5"

	If (OpenFiler = "true") {
		openFilerCommand := FixCommand("Filer_OpenDir{Space}adfs::" . driveNr)
		KeyUtils.Send("{F12}")
		KeyUtils.Send(openFilerCommand)
		If (WorkingDir)
			KeyUtils.Send("." . WorkingDir)
		KeyUtils.Send("{Enter}{Enter}") ;Double enter to close the console
		TimerUtils.Sleep(3000) ;Wait for the filer to appear
	}
	KeyUtils.Send("{F12}")

	;Ensure we are on adfs because if !Boot is in hostfs folder then it will be on hostfs mode at startup and commands like drive won't work
	KeyUtils.Send("adfs{Enter}")

	If (driveNr != A_Space)
		KeyUtils.Send("drive{Space}" . driveNr . "{Enter}")

	If (WimpMode)
		KeyUtils.Send("wimpMode{Space}" . WimpMode . "{Enter}")

	If (WorkingDir)
		KeyUtils.Send("dir{Space}" . WorkingDir . "{Enter}")

	If (ExecuteCmd) {
		If (CloseWimp = "true") {
			closeWimpCommand := FixCommand("Basic{Enter}SYS{Space}""Wimp_CloseDown""{Enter}")
			KeyUtils.Send(closeWimpCommand)
		}
		KeyUtils.Send(ExecuteCmd . "{Enter}")
	}
}

; Set fullscreen If needed
If (Fullscreen = "true")
	emuPrimaryWindow.MenuSelectItem("Settings", "Fullscreen mode")

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

primaryExe.Process("WaitClose")

If (UseDxWnd = "true")
	DxwndClose()

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

FixCommand(OScommand) {
	OScommand := StringUtils.Replace(OScommand, "*", "{NumpadMult}", "All")
	OScommand := StringUtils.Replace(OScommand, """", "{Shift Down}2{Shift Up}", "All")
	OScommand := StringUtils.Replace(OScommand, "_", "{Shift Down}{vkDBsc00C}{Shift Up}", "All")
	OScommand := StringUtils.Replace(OScommand, "-", "{NumpadSub}", "All")
	OScommand := StringUtils.Replace(OScommand, ":", "{Shift Down}{vkC0sc027}{Shift Up}", "All")
	OScommand := StringUtils.Replace(OScommand, "?", "{Shift Down}{vkC0sc035}{Shift Up}", "All")
	OScommand := StringUtils.Replace(OScommand, "+", "{NumpadAdd}", "All")
	Return OScommand
}

HaltEmu:
Return

MultiGame:
	emuPrimaryWindow.MenuSelectItem("Disc", "Load Disc :0")
	emuOpenRomWindow.OpenROM(selectedRom)
	If (Fullscreen = "true")
		emuPrimaryWindow.MenuSelectItem("Settings", "Fullscreen mode")
	emuPrimaryWindow.Activate()
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
