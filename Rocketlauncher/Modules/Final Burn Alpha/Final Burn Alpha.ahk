MEmu := "Final Burn Alpha"
MEmuV := "v0.2.97.38"
MURL := ["http://www.barryharris.me.uk/"]
MAuthor := ["djvj"]
MVersion := "2.0.4"
MCRC := "36363030"
iCRC := ""
MID := "635038268890292583"
MSystem := ["Final Burn Alpha","NEC TurboGrafx-16","NEC PC Engine","NEC SuperGrafx","Sega Mega Drive","SNK Neo Geo"]
;----------------------------------------------------------------------------
; Notes:
; You must have your roms renamed using clrmame and the dat generated by FBA. Run FBA manually and goto Misc->Generate dat file->Generate dat...
; Open FBA manually and select MISC->Configure ROM paths... and define at least one path to your roms.
; Fullscreen is now automatic when running FBA via command line
; FBA supports 7z, so no need for RocketLauncher 7z functions
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"FB Alpha"))	; instantiate primary emulator window object
emuLoadingWindow := new Window(new WindowTitle(,"#32770"))

If StringUtils.Contains(systemname,"NEC TurboGrafx-16|NEC PC Engine|NEC SuperGrafx|Sega Mega Drive")
{	; The object controls how the module reacts to different systems. FBA can play a lot of systems, but the romName changes slightly so this module has to adapt 
	mType := Object("NEC TurboGrafx-16","tg_","NEC PC Engine","pce_","NEC SuperGrafx","sgx_","Sega Mega Drive","md_")
	ident := mType[systemName]	; search 1st array for the systemName identifier mednafen uses
	If !ident
		ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this FBA module: " . moduleName)
}

fbaRomName := (If ident ? ident : "") . romName	; FBA requires an identifier prefix attached to the romName which tells FBA what system to run

hideEmuObj := Object(emuLoadingWindow,0,emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" """ . fbaRomName . """")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

; This loops detects the rom loading window and breaks when it's done. Only here to avoid using too many WinWait commands from all the odd flashing the emu does.
Loop {
	If emuLoadingWindow.Active()
		Break
	TimerUtils.Sleep(50,0)
}

; This loop detects when the emu window is done flashing back and forth between your FE and the emu window and is actually in the game.
Loop {
	If (x = 10)
		Break
	If emuPrimaryWindow.Active()
		x++
	emuPrimaryWindow.Activate()
	TimerUtils.Sleep(50,0)
}

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

emuPrimaryWindow.Activate()

primaryExe.Process("WaitClose")
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
