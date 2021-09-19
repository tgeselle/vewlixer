MEmu := "Radikal Bikers Emu"
MEmuV := "v0.9.0.1"
MURL := ["http://aarongiles.com/radikal.html"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "ABA431B9"
iCRC := "1E716C97"
MID := "635038268921178278"
MSystem := ["Radikal Bikers"]
;----------------------------------------------------------------------------
; Notes:
; radikalb.zip rom must reside in the emulator directory and be zipped. Copy it from your mame set.
; Run the emu manuallly initially and set your resolution and control you want to use. It gets saved in the radikalb.dat
;
; Defaults emu keys:
; System Controls
; 9				; Service Coin
; F2				; Test Mode
; F9				; Display FPS (windowed mode only)
; F10			; Toggle Throttling
; p				; Pause
; Escape	; Quit

; Player 1 Controls
; Down		; Handlebars up
; Left			; Steer Left
; Right		; Steer Right
; LControl	; Accelerate
; LAlt 			; Brake
; Space		; Change View
; 1				; Start
; 5				; Coin
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Radikal Bikers","Radikal Bikers"))	; instantiate primary emulator window object
emuSetupWindow := new Window(new WindowTitle("Radikal Bikers Setup","#32770"))

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)

hideEmuObj := Object(emuSetupWindow,0,emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)
PrimaryExe.Run(,(If Fullscreen = "true" ? "Hide" : ""))

emuSetupWindow.Wait()
emuSetupWindow.Activate()

emuSetupWindow.CreateControl("Button1")		; instantiate new control for msctls_statusbar321
emuSetupWindow.GetControl("Button1").Control(If (Fullscreen = "true") ? "UnCheck" : "Check")	; get position of control msctls_statusbar321

KeyUtils.Send("{Enter}")	; starting game

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
FadeOutExit()
ExitModule()


HaltEmu:
	disableLoadScreen := "true"
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
