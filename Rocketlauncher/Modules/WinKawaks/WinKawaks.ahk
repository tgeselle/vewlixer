MEmu := "WinKawaks"
MEmuV := "v1.62"
MURL := ["http://www.kawaks.net/"]
MAuthor := ["djvj"]
MVersion := "2.0.3"
MCRC := "A2089802"
iCRC := "84C72842"
MID := "635038268935109871"
MSystem := ["Capcom Play System","Capcom Play System 2","Capcom Play System II","SNK Neo Geo","SNK Neo Geo AES","SNK Neo Geo MVS"]
;----------------------------------------------------------------------------
; Notes:
; Rom path is set automatically by the module, no need to set that path in the emu
; All your roms should be zipped. Bios zips should be placed in the same dir as the games they are for. (ex.  neogeo.zip should be with the neogeo roms)
; Load a game and set your controls at Game->Redefine keys->Player1 and 2. Then click Game->save key settings as default. Now they will be mapped for every game.
; Set your Region to USA by going to Game->NeoGeo settings->USA. If you don't want to use coins, select Game->NeoGeo settings->Console
; Set Sound->Sound frequency->44 KHz (or 48 KHz)

; The larger games take a long time to load, be patient.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
freeplay := IniReadCheck(settingsFile, "Settings", "Freeplay","0",,1)						; 0=off, 1=on
country := IniReadCheck(settingsFile, "Settings", "Country","1",,1)						; 0 = Japan,  1 = USA,  2 = Europe
hardware := IniReadCheck(settingsFile, "Settings", "Hardware","1",,1)						; 0 = Console, 1 = Arcade
hotkeys := IniReadCheck(settingsFile, "Settings", "Hotkeys","1",,1)						; Set to 0 to disable menu shortcuts (handy for Hotrod players)

7z(romPath, romName, romExtension, sevenZExtractPath)

wkINI := CheckFile(emuPath . "\WinKawaks.ini")

; Compare existing settings and if different than desired, write them to the emulator's ini
IniWrite(freeplay, wkINI, "NeoGeo", "NeoGeoFreeplay", 1)
IniWrite(country, wkINI, "NeoGeo", "NeoGeoCountry", 1)
IniWrite(hardware, wkINI, "NeoGeo", "NeoGeoSystem", 1)
IniWrite(hotkeys, wkINI, "Misc", "EnableHotKeys", 1)
IniWrite(romPath, wkINI, "Path", "RomPath1")

; fullscreen := If fullscreen = "true" ? " -fullscreen" : ""

Run(executable . " " . romName, emuPath)

WinWait("Kawaks")
WinWaitActive("Kawaks")

Loop { ; looping until WinKawaks is done loading game
	Sleep, 200
	WinGetTitle, winTitle, Kawaks 1.62 ahk_class Afx:400000:0 ; excluding the title of the GUI window so we can read the title of the game window instead
	StringSplit, T, winTitle, %A_Space%
	If (T4 != "Initializing" && T4 != "Lost" && T4 != "") {
		Sleep, 500 ; need a bit longer so we don't see the winkawaks window
		Break
	}
}

; Sometimes the border and titlebar appear and flash rapidly, this gets rid of them
If (fullscreen = "true") {
	; WinSet, Style, -0xC00000, Kawaks 1.62 ahk_class Afx:400000:0 ; Removes the TitleBar
	; WinSet, Style, -0x40000, Kawaks 1.62 ahk_class Afx:400000:0 ; Removes the border of the game window
	MaximizeWindow("Kawaks 1.62 ahk_class Afx:400000:0")
}

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	; SetKeyDelay(50)
	PostMessage, 0x111, 32775,,, Kawaks ahk_class Afx:400000:0	; Pause emu
	Sleep, 1000 ; increase this if winkawaks is not closing and only going into windowed mode
	PostMessage, 0x111, 32808,,, Kawaks ahk_class Afx:400000:0	; Reset emu
	; PostMessage, 0x111, 32847,,, Kawaks ahk_class Afx:400000:0	; Toggle Fullscreen
	; Send, {ENTER} ; pause emu
	Sleep, 1000 ; increase this if winkawaks is not closing and only going into windowed mode
	; WinClose("Kawaks 1.62 ahk_class Afx:400000:0")
	PostMessage, 0x111, 57665,,, Kawaks ahk_class Afx:400000:0	; Exit
	; Sleep, 500
	; If WinExist("Kawaks 1.62 ahk_class Afx:400000:0")
	; {	WinActivate ; use the window found above
		; Send, {Alt}FX
	; }	
	; alternate closing method
	; errorLvl := Process("Exist", executable)
	; If errorLvl
		; Process("Close", executable)	; sometimes the process doesn't close when using the GUI, this makes sure it closes (eeprom still saves with previous line)
Return
