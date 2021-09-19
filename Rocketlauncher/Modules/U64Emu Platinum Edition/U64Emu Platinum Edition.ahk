MEmu := "U64Emu Platinum Edition"
MEmuV := "v3.11"
MURL := ["http://www.zophar.net/marcade/ultra64-platinum-edition.html"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "45640382"
iCRC := "866CCAA2"
MID := "635038268928674521"
MSystem := ["Ultra64"]
;----------------------------------------------------------------------------
; Notes:
; This emulator only plays Killer Instinct 1 and Killer Instinct 2
; Settings are stored in your registry at HKEY_CURRENT_USER\Software\U64Emu\u64emu
; Roms should be unzipped and match the dirs set in the emuator Rom Settings.
; Mame CHDs don't work, you need the IMG versions, or use the patcher tool to convert your CHD to IMG
; Controls can be remapped by creating an ahk remap profile.
; If you use an older mame set and your roms are "ki" and "ki2", do a find/replace and change all kinst to ki and kinst2 to ki2
;
; Default Keys:
; System Controls
; ::F11		; Service Menu
; ::-			; Volume Up
; ::+			; Volume Down

; Player 1 Controls
; ::Home	; Up
; ::End		; Down
; ::Delete	; Left
; ::PgDn	; Right
; ::w			; Quick Punch
; ::e			; Medium Punch
; ::r			; Fierce Punch
; ::s			; Quick Kick
; ::d			; Medium Kick
; ::f			; Fierce Kick
; ::q			; Start
; ::F7		; Coin

; Player 2 Controls
; ::Up		; Up
; ::Down	; Down
; ::Left		; Left
; ::Right	; Right
; ::u			; Quick Punch
; ::i			; Medium Punch
; ::p			; Fierce Punch
; ::j			; Quick Kick
; ::k			; Medium Kick
; ::l			; Fierce Kick
; ::y			; Start
; ::F8		; Coin
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("U64Emu Platinum Edition","#32770"))	; instantiate primary emulator window object

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
Resolution := moduleIni.Read("Settings", "Resolution","3",,1)		; 0=320x240, 1=640x480, 2=800x600, 3=1024x768, 4=1280x1024, 5=1600x1200
WinX := moduleIni.Read("Settings", "WinX","0",,1)				; For windowed mode only
WinY := moduleIni.Read("Settings", "WinY","0",,1)

; Set Resolution
If (Resolution = 0) {
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\Options","ScreenRes",0)
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","ScreenRes",0)
} Else If (Resolution = 1) {
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\Options","ScreenRes",1)
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","ScreenRes",1)
} Else If (Resolution = 2) {
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\Options","ScreenRes",2)
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","ScreenRes",2)
} Else If (Resolution = 3) {
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\Options","ScreenRes",3)
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","ScreenRes",3)
} Else If (Resolution = 4) {
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\Options","ScreenRes",4)
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","ScreenRes",4)
} Else If (Resolution = 5) {
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\Options","ScreenRes",5)
	Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","ScreenRes",5)
}

Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","FullScreen",(If fullscreen = "true" ? 1 : 0))	; Set Fullscreen
Registry.Write("REG_DWORD","HKCU","Software\U64Emu\u64emu\KI2_Options","RomSet",(If romName = "kinst" ? 1 : 2))	; Setting the game we want to play

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run()

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

emuPrimaryWindow.MenuSelectItem("Emulation","Start")
TimerUtils.Sleep(1000)

; In windowed mode on smaller resolutions, the game screen is might not be fully on screen and the emu doesn't save its last position. It doesn't take effect if you run fullscreen.
If (fullscreen != "true")
	emuPrimaryWindow.Move(WinX,WinY)

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
FadeOutExit()
ExitModule()


HaltEmu:
	disableActivateBlackScreen := "true"
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
