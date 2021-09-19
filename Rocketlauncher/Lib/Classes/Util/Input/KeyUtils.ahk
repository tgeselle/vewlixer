MCRC := "AE1F0C28"
MVersion := "1.0.2"

; Not instantiated, access functions directly
class KeyUtils
{
	Send(key,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Sending " . key)
		Send % key
		Return ErrorLevel
	}

	SendEvent(key,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Sending " . key)
		SendEvent % key
		Return ErrorLevel
	}

	SendInput(key,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Sending " . key)
		SendInput % key
		Return ErrorLevel
	}

	SendPlay(key,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Sending " . key)
		SendPlay % key
		Return ErrorLevel
	}

	SendRaw(key,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Sending " . key)
		SendRaw % key
		Return ErrorLevel
	}

	SetKeyDelay(delay:="",pressDur:="",play:="")
	{
		Global pressDuration
		If (delay = "")	; -1 is the default delay for play mode and 10 for event mode when none is supplied
			delay := (If play = "" ? 10 : -1)
		If (pressDur = "")	; -1 is the default pressDur when none is supplied
			pressDur := -1

		RLLog.Trace(A_ThisFunc . " - Current delay is " . A_KeyDelay  . ". Current press duration is " . pressDuration . ". Delay will now be set to """ . delay . """ms for a press duration of """ . pressDur . """")
		SetKeyDelay, %delay%, %pressDur%, %play%
		pressDuration := pressDur	; this is so the current pressDuration can be monitored outside the function
		Return
	}

	;Sends a command to the active window using AHK key names. It will always send down/up keypresses for better compatibility
	;A special command {Wait} can be used to force a sleep of the time defined by WaitTime
	;WaitCommandOffset will affect all Wait events passed in the Command string by this amount
	SendCommand(Command, SendCommandDelay:=2000, WaitTime:=500, WaitBetweenSends:=0, Delay:=50, PressDuration:=-1, WaitCommandOffset:=0) {
		RLLog.Info(A_ThisFunc . " - Started")
		RLLog.Debug(A_ThisFunc . " - Command: " . Command . "`r`n`t`t`t`t`tSendCommandDelay: " . SendCommandDelay . "`r`n`t`t`t`t`tWaitTime: " . WaitTime . "`r`n`t`t`t`t`tWaitBetweenSends: " . WaitBetweenSends . "`r`n`t`t`t`t`tDelay: " . Delay . "`r`n`t`t`t`t`tPressDuration: " . PressDuration . "`r`n`t`t`t`t`tWaitCommandOffset: " . WaitCommandOffset)
		ArrayCount := 0 ;Keeps track of how many items are in the array.
		InsideBrackets := 0 ;If 1 it means the current array item starts with {
		SavedKeyDelay := A_KeyDelay ;Saving previous key delay and setting the new one
		SetKeyDelay, %Delay%, %PressDuration%
		Sleep, %SendCommandDelay% ;Wait before starting to send any command

		If (WaitCommandOffset = "")
			WaitCommandOffset := 0 ;Just to make sure this is always set otherwise wait commands won't work

		;Create an array with each command as an array element
		Loop, % StrLen(Command)
		{	StrValue := SubStr(Command,A_Index,1)
		; {	StringMid, StrValue, Command, A_Index, 1
			If (StrValue != A_Space || InsideBrackets = 1)	; Spaces must be allowed when inside brackets so we can issue {Shift Down} for instance
			{	If (InsideBrackets = 0)
					ArrayCount += 1  
				If (StrValue = "{")
				{	If (InsideBrackets = 1)
						ScriptError("Non-Matching brackets detected in the SendCommand parameter, please correct it")
					Else
						InsideBrackets := 1
				} Else If (StrValue = "}")
				{	If (InsideBrackets = 0)
						ScriptError("Non-Matching brackets detected in the SendCommand parameter, please correct it")
					Else
						InsideBrackets := 0
				}
				Array%ArrayCount% := Array%ArrayCount% . StrValue ;Update the array data
			}
		}

		;Loop through the array and send the commands
		Loop %ArrayCount%
		{	element := Array%A_Index%

			If (WaitBetweenSends = 1)
				Sleep, %WaitTime%

			;Particular cases check if the commands already come with down or up suffixes on them and if so send the commands directly without appending Up/Down
			If RegExMatch(element,"i)Down}")
			{	If (element != "{Down}")
				{	Send, %element%
					continue
				}
			}
			Else If RegExMatch(element,"i)Up}")
			{	If (element != "{Up}")
				{	Send, %element%
					Continue
				}
			}
			Else If (element = "{Wait}") ;Special non-ahk tag to issue a sleep
			{	NewWaitTime := WaitTime + WaitCommandOffset
				Sleep, %NewWaitTime%
				Continue
			}
			Else If RegExMatch(element,"i)\{Wait:")
			{	;Wait for a specified amount of time {Wait:xxx}
				;StringMid, NewWaitTime, element, 7, StrLen(element) - 7
				NewWaitTime := SubStr(element,7,StrLen(element) - 7)
				NewWaitTime := NewWaitTime + WaitCommandOffset
				Sleep, %NewWaitTime%
				Continue
			}

			;the rest of the commands, send a keypress with down and up suffixes
			If RegExMatch(element,"}")
			{	StrElement := SubStr(element,1,StrLen(element) - 1)
			; {	StringLeft, StrElement, element, StrLen(element) - 1
				Send, %StrElement% down}%StrElement% up}
			} Else
				Send, {%element% down}{%element% up}
		}
		;Restore key delay values
		KeyUtils.SetKeyDelay(SavedKeyDelay, -1)
		RLLog.Info(A_ThisFunc . " - Ended")
	}

	SendMode(mode)
	{
		If !RegExMatch(mode,"i)Input|Play|Event|InputThenPlay")
			ScriptError(mode . " is not a valid mode for " . A_ThisFunc)
		SetKeyDelay, %delay%, %pressDur%, %play%
		RLLog.Trace(A_ThisFunc . " - Current SendMode is " . A_SendMode  . ". SendMode will now be set to """ . mode . ".")
		Return
	}
}
