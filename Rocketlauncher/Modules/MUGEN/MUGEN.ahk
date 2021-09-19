MEmu := "MUGEN"
MEmuV := "N/A"
MURL := ["http://www.elecbyte.com/"]
MAuthor := ["brolly","djvj","knewlife"]
MVersion := "2.0.6"
MCRC := "7579D2F9"
iCRC := "965C2F5A"
MID := "635038268906726252"
MSystem := ["MUGEN"]
;----------------------------------------------------------------------------
; Notes:
; To use this module, set SkipChecks to "Rom and Emu". This sytem does not use any roms and uses a different executable for each game.
; Emulator Path needs to point to a dummy exe, like Dummy.exe, if you don't set Skip Checks to Rom and Emu
; Default location to launch the games will be in your romPath with a subfolder for each game (named after the rom in the xml).
; Each game's folder, should contain a MUGEN.exe

; If you don't want to use the above path/exe, create an ini in the folder of this module with the same name as this module.
; Place each game in it using the example below. gamePath should start from your romPath and end with the exe to the game.
; moduleName ini contains an entry for each game, pointing to the MUGEN.exe
; It can also contain an exitHack setting which can be 1 or 0, typically you only add these to mugen 1.0+ games and set it to 0
; This will override the whole exit hack code needed for older mugen versions
; example:
;
; [Bastard]
; gamePath = Bastard\WinBastard.exe
; [Street Fighter Legends]
; gamePath = Street Fighter Legends\mugen.exe
; exitHack = 0
;
; Escape will only close the game from the main menu, it is needed for in-game menu usage otherwise.
; Fullscreen and controls are done via in-game options for each game. To speed up configuring of games, configure one game then save its settings to a default.cfg and paste it into each game's Saves folder.
; Controls are done via in-game options for each game.
; Larger games are inherently slower to load, this is MUGEN, nothing you can do about it but get a faster HD.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

remapWinKeys := moduleIni.Read("Settings","remapWinKeys","true","",1)
gamePathIni := moduleIni.Read(romName,"gamePath", "","",1)
exitHack := moduleIni.Read(romName,"exitHack","1","",1)

7z(romPath, romName, romExtension, 7zExtractPath)
gamePath := GetMugenExeLocation()

; This remaps windows Start keys to Return to prevent accidental leaving of game
If (remapWinKeys = "true") {
	Hotkey, RWin, WinRemap
	Hotkey, LWin, WinRemap
}

MugenExe := New Emulator(gamePath.FileFullPath)
MugenExe.Run("","UseErrorLevel")

MugenWin := New Window(New WindowTitle("","",MugenExe.FileName,"",MugenExe.PID))
MugenWin.Wait()
MugenWin.WaitActive()

WinGetActiveTitle, gameTitle
RLLog.Info("Module - Active window is currently: " . gameTitle)

FadeInExit()

If (exitHack = 1)	; Sometimes mugen crashes during exit and doesn't close, so we need to do a workaround to detect it, this doesn't seem to happen on MUGEN 1.0
{
	MugenErrorWin := New Window(New WindowTitle(MugenExe.FileName,"#32770"))
	gameWin := New Window(New WindowTitle(gameTitle))
	If (gameTitle != frontendWinTitle) ; If the user exited mugen in under 1500ms then we don't need to do this otherwise the script would hang
	{
		If (gameWin.Exist())
		{
			Loop {
				Sleep, 1000
				gameWin.Get("MinMax")
				If ( gameWin.MinMax != 1 )	; Mugen window minimized or closed
					Break
				
			}
		}
	}
	Sleep 2000
	If (gameTitle != frontendWinTitle)
	{
		If (gameWin.Exist())
		{
			FadeOutExit()	; this needs to be on its own line so it does not error
			If(MugenErrorWin.Exist()) ;If Error window exists close it
			{
				Sleep, 100 ; have to add a little delay before close the window or it will fail sometimes
				MugenErrorWin.Close()
			}
			MugenExe.Process("WaitClose","","PID") 
		}
	}
	MugenExe.Process("Close","","PID")
} Else
	MugenExe.Process("WaitClose","","PID") 

7zCleanUp()
FadeOutExit()
ExitModule()

GetMugenExeLocation() {
	Global gamePathIni, romPath, romName, RLLog

	;RomName included in RomPath? (You have the Dummy rom file inside a folder with the same romName)
	StringUtils.SplitPath(romPath,romPathFolder,romPathPath)
	RomNameInRomPath := (romPathFolder = romName)

	if(RomNameInRomPath)
		RLLog.Info("Module - gamePath: RomPath variable contains the rom name as the final folder of the path.")
	else
		RLLog.Info("Module - gamePath: RomPath variable don't include the romName as part of the path.")

	;Check all posible game.exe location
	If (!gamePathIni or gamePathIni = "ERROR")								
	{
		RLLog.Info("Module - gamePath: using default game folder and exe location.")
		if(RomNameInRomPath)
			gamePath := New File(romPath . "\MUGEN.exe")						;gamePath is [romPath]\MUGEN.exe
		Else
			gamePath := New File(romPath . "\" . romName . "\MUGEN.exe")		;gamePath is [romPath]\[romName]\MUGEN.exe
	}
	else
	{
		if( StringUtils.Contains(gamePathIni,"\\") ) 							;Have to escape the backslash as the function uses regex internally
		{
			RLLog.Info("Module - gamePath: using gamePath setting to find game folder and exe file.")
			if(RomNameInRomPath)
				gamePath := New File(romPathPath . "\" . gamePathIni)			;gamePath is [romPathPath]\[INI:gamefolder\game.exe]
			else
				gamePath := New File(romPath     . "\" . gamePathIni)			;gamePath is [romPath]\[INI:gamefolder\game.exe]
		}
		else					
		{
			RLLog.Info("Module - gamePath: using RomName to find game folder and gamePath setting to find game exe file.")
			if(RomNameInRomPath)
				gamePath := New File(romPath 	. "\" . gamePathIni)			;gamePath is [romPath]\[INI:game.exe]
			else
				gamePath := New File(romPath . "\" . romName . "\" gamePathIni)	;gamePath is [romPath]\[romName]\[INI:game.exe]
		}
	}
	gamePath.CheckFile("Could not find " . gamePath.FileFullPath . "`nPlease place your game in it's own folder in your Rom_Path or define a custom gamePath in " . modulePath . "\" . moduleName . ".ini")
	RLLog.Info("Module - gamePath: game exe file found: " . gamePath.FileFullPath)

	Return gamePath
}

WinRemap:
Return

CloseProcess:
	FadeOutStart()
	MugenWin.Close()
Return
