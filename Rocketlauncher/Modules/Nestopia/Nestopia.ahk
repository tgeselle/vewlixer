MEmu := "Nestopia"
MEmuV := "v1.42"
MURL := ["http://www.emucr.com/2011/09/nestopia-unofficial-v1420.html"]
MAuthor := ["djvj"]
MVersion := "2.0.5"
MCRC := "82C6968B"
iCRC := "CD8D8CF2"
MID := "635038268908287546"
MSystem := ["Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System"]
;----------------------------------------------------------------------------
; Notes:
; If using this for Nintendo Famicom Disk System, make sure you place an FDS bios in your bios subfolder for your emu. You will have to select it on first launch of any FDS game.
; Set your fullscreen key to Alt+Enter if it is not already for Pause support
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)	; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Nestopia","Nestopia"))	; instantiate primary emulator window object

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
ExitKey := moduleIni.Read("Settings", "ExitKey","Esc",,1)
ToggleMenuKey := moduleIni.Read("Settings", "ToggleMenuKey","Alt+M",,1)
bezelTopOffset := moduleIni.Read("Settings", "bezelTopOffset",16,,1)
bezelBottomOffset := moduleIni.Read("Settings", "bezelBottomOffset",26,,1)
bezelLeftOffset := moduleIni.Read("Settings", "bezelLeftOffset",7,,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset",7,,1)

forceControls := moduleIni.Read(dbName . "|Settings", "ForceControls","False",,1)
port1 := moduleIni.Read(dbName . "|Settings", "Port1","Unconnected",,1)
port2 := moduleIni.Read(dbName . "|Settings", "Port2","Unconnected",,1)
port3 := moduleIni.Read(dbName . "|Settings", "Port3","Unconnected",,1)
port4 := moduleIni.Read(dbName . "|Settings", "Port4","Unconnected",,1)
port5 := moduleIni.Read(dbName . "|Settings", "Port5","Unconnected",,1)

BezelStart()

emuSettingsFile := new File(emuPath . "\nestopia.xml")
emuSettingsFile.Read()

If StringUtils.InStr(emuSettingsFile.Text,"<confirm-exit>yes</confirm-exit>")	; find if this setting is not the desired value
	emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,"<confirm-exit>yes</confirm-exit>", "<confirm-exit>no</confirm-exit>")	; turning off confirmation on exit
If !StringUtils.InStr(emuSettingsFile.Text,"<exit>" . ExitKey . "</exit>")	; find if this setting is not the desired value
{	currentExitKey := StrX(emuSettingsFile.Text,"<exit>" ,0,0,"</exit>",0,0)	; trim confirm-exit to what it's current setting is
	emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,currentExitKey,"<exit>" . ExitKey . "</exit>")	; replacing the current exit key to the desired one from above
}
If !StringUtils.InStr(emuSettingsFile.Text,"<toggle-menu>" . ToggleMenuKey . "</toggle-menu>")	; find if this setting is not the desired value
{	currentMenuKey := StrX(emuSettingsFile.Text,"<toggle-menu>" ,0,0,"</toggle-menu>",0,0)	; trim toggle-menu to what it's current setting is
	emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,currentMenuKey,"<toggle-menu>" . ToggleMenuKey . "</toggle-menu>")	; replacing the current toggle-menu key to the desired one from above
}

If (forceControls = "true")
{	
	If StringUtils.InStr(emuSettingsFile.Text,"<auto-select-controllers>yes</auto-select-controllers>")	; find if this setting is not the desired value
		emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,"<auto-select-controllers>yes</auto-select-controllers>","<auto-select-controllers>no</auto-select-controllers>")	; replacing the current toggle-menu key to the desired one from above
		
	Loop, 5
	{
		currentTemp := StrX(emuSettingsFile.Text,"<port-" . A_Index . ">" ,0,0,"</port-" . A_Index . ">",0,0)
		port := port%A_Index%
		
		If (port = "pad")
			port := "pad" . A_Index
		
		;MsgBox,,,% port . " - " . currentTemp
		
		emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,currentTemp,"<port-" . A_Index . ">" . port . "</port-" . A_Index . ">")
	}	
} Else {
	If StringUtils.InStr(emuSettingsFile.Text,"<auto-select-controllers>no</auto-select-controllers>")	; find if this setting is not the desired value
		emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,"<auto-select-controllers>no</auto-select-controllers>","<auto-select-controllers>yes</auto-select-controllers>")
}

; Enable Fullscreen
currentFS := StrX(emuSettingsFile.Text,"<start-fullscreen>" ,0,0,"</start-fullscreen>",0,0)	; trim start-fullscreen to what it's current setting is
emuSettingsFile.Text := StringUtils.Replace(emuSettingsFile.Text,currentFS,"<start-fullscreen>" . ((If Fullscreen = "true")?"yes":"no") . "</start-fullscreen>")	; setting start-fullscreen to the desired setting from above

; Update and save emuSettingsFile
emuSettingsFile.Delete()
emuSettingsFile.Append(emuSettingsFile.Text,"UTF-8")

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

HideAppStart(hideEmuObj,hideEmu)
primaryExe.Run(" """ . romPath . "\" . romName . romExtension . """")

emuPrimaryWindow.Wait()

;Close Gamepad change popup
PopupWindow := new Window(new WindowTitle("Nestopia","#32770"))	; Instantiate Gamepad change popup window object
PopupWindow.Wait(1,,,1)	; silence error if window never shows
If(PopupWindow.Exist())
{
	PopupWindow.CreateControl("Button2")		; instantiate new control for Button2
	PopupWindow.GetControl("Button2").Send("{Enter}")	; Send Enter to Button2
}

emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	; KeyUtils.Send("!{Enter}")
	TimerUtils.Sleep(200)
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	; KeyUtils.Send("!{Enter}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
