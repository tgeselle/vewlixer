MEmu := "1964"
MEmuV := "v1.1"
MURL := ["http://www.emulator-zone.com/doc.php/n64/1964.html"]
MAuthor := ["djvj"]
MVersion := "2.0.2"
MCRC := "7FEC0C43"
iCRC := "2A538F1F"
MID := "635038268873418528"
MSystem := ["Nintendo 64"]
;----------------------------------------------------------------------------
; Notes:
; On first run the emu requires you to set your rom folder, so do so.
; The Rom Browser is disabled for you.
;
; Emu stores its config in the registry @ HKEY_CURRENT_USER\Software\1964emu_099\GUI
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Process(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("1964","WinGui"))	; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle(dialogOpen . " ROM","#32770"))	; instantiate primary emulator window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
FullscreenMethod := moduleIni.Read("Settings", "FullscreenMethod","reg",,1)

exitEmulatorKey := xHotKeyVarEdit("Esc","exitEmulatorKey","~","Remove")	; sending Esc to the emu when in fullscreen causes it to crash on exit , this prevents Esc from reaching the emu

; Disabling ROM Browser if it is active
currentBrowser := Registry.Read("HKCU","Software\1964emu_099\GUI","DisplayRomList")
If (currentBrowser = 1)
	Registry.Write("REG_DWORD","HKCU","Software\1964emu_099\GUI","DisplayRomList", 0)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
If (FullscreenMethod = "reg")
{
	currentFullScreen := Registry.Read("HKCU","Software\1964emu_099\GUI","AutoFullScreen")
	If (Fullscreen != "true" && (currentFullScreen != 0 || currentFullScreen = ""))
		Registry.Write("REG_DWORD","HKCU","Software\1964emu_099\GUI","AutoFullScreen",0)
	Else If (Fullscreen = "true" && currentFullScreen != 1)
		Registry.Write("REG_DWORD","HKCU","Software\1964emu_099\GUI","AutoFullScreen",1)
}

hideEmuObj := Object(emuOpenWindow,1,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

BezelStart()
HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """","Hide")

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

KeyUtils.SetKeyDelay(50)
KeyUtils.Send("^o")	; Open Rom

emuOpenWindow.OpenROM(romPath . "\" . romName . romExtension)
emuPrimaryWindow.WaitActive()

emuPrimaryWindow.CreateControl("msctls_statusbar321")		; instantiate new control for msctls_statusbar321
emuPrimaryWindow.GetControl("msctls_statusbar321").GetPos(x,y,w,h)	; get position of control msctls_statusbar321
Loop {
	TimerUtils.Sleep(200)
	If (Fullscreen = "true") ; looping until 1964 is done loading rom and it goes fullscreen. The x position will change then, which is when this loop will break.
		emuPrimaryWindow.GetControl("msctls_statusbar321").GetPos(x2,y2,w2,h2)
	Else {	; looping until 1964 is done loading rom and it starts showing frames if in windowed mode, then this loop will break.
		cText := emuPrimaryWindow.GetControl("msctls_statusbar321").GetText()	; get text of statusbar which shows emulation stats
		cTextAr := StringUtils.Split(cText, ": %")	; split text to find the video % which will update constantly as emulation is active
		; StringSplit, cTextAr, cText, : `%	; old method
		; Tooltip % cText . "`n" . cTextAr[5] . ": " . cTextAr[5]
		If (cTextAr[5] > 0)	; Break out when video % is greater then 0
			Break
	}
	; ToolTip, Waiting for "1964 ahk_class WinGui" to go fullscreen or to start showing frames if using windowed mode after loading rom`nWhen x does not equal x2 (in windowed mode)`, script will continue:`nx=%x%`nx2=%x2%`ny=%y%`ny2=%y2%`nw=%w%`nw2=%w2%`nh=%h%`nh2=%h2%`nStatus Bar Text: %cText%`nLoop #: %A_Index%`nVideo `%: %cTextAr5%
	If (x != x2 or A_Index >= 30) { ; x changes when emu goes fullscreen, so we will break here and destroy the GUI. Break out if loop goes on too long, something is wrong then.
		If A_Index >= 30
			RLLog.Info("Module - " . MEmu . " had a problem detecting when it was done loading the rom. Please try different options inside the module to find what is compatible with your system.")
		Break
	}
}

If (Fullscreen = "true" && FullscreenMethod = "hotkey")
	KeyUtils.Send("!{Enter}")

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	disableSuspendEmu := "true"
	KeyUtils.Send("!{Enter}")
	KeyUtils.Send("F3")
	TimerUtils.Sleep(200)
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	KeyUtils.Send("!{Enter}")
Return

CloseProcess:
	FadeOutStart()
	KeyUtils.SetKeyDelay(50)
	emuPrimaryWindow.PostMessage("0x12")	; 0x12 = WM_QUIT, this is the only method that works for me with the new fade and doesn't cause a crash
	; ControlSend,, {alt down}{F4 down}{F4 up}{alt up}, 1964 ahk_class WinGui	; v1.1 this works, WinClose crashes it
	; KeyUtils.Send("{alt down}{F4 down}{F4 up}{alt up}")	; v1.1 this works, WinClose crashes it
	; KeyUtils.Send("!F4")		; v1.1 this works, WinClose crashes it
	; emuPrimaryWindow.Close()
Return
