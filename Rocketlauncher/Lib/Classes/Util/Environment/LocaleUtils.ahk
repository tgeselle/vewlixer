MCRC := "5F0870A4"
MVersion := "1.0.0"

; Not instantiated, access functions directly
class LocaleUtils
{
	i18n(key, defaultLocale := "English_United_States", p0 := "-0", p1 := "-0", p2 := "-0", p3 := "-0", p4 := "-0", p5 := "-0", p6 := "-0", p7 := "-0", p8 := "-0", p9 := "-0")
	{
		Global sysLang,langFile
		RLLog.Info(A_ThisFunc . " - Started")
		IniRead, phrase, %langFile%, %sysLang%, %key%
		If (phrase = "ERROR" || phrase = "")
		{
			; Nothing found, test with generic language
			StringSplit, keyArray, sysLang, _
			RLLog.Debug(A_ThisFunc . " - Section """ . sysLang . """ & key """ . key . """ not found, trying section """ . keyArray1 . """")
			IniRead, phrase, %langFile% , %keyArray1%, %key%
			If (phrase = "ERROR" || phrase = "")
			{
				RLLog.Debug(A_ThisFunc . " - Section """ . keyArray1 . """ & key """ . key . """ not found, trying section """ . defaultLocale . """")
				; Nothing found, test with default locale if one is provided
				If (defaultLocale != "")
				{
					IniRead, phrase, %langFile% , %defaultLocale%, %key%
					If (phrase = "ERROR" || phrase = "")
					{
						; Nothing found, test with generic language for default locale as well
						StringSplit, keyArray, defaultLocale, _
						RLLog.Debug(A_ThisFunc . " - Section """ . defaultLocale . """ & key """ . key . """ not found, trying section """ . keyArray1 . """")
						IniRead, phrase, %langFile% , %keyArray1%, %key%
					}
				}
				; Nothing found return original value
				If (defaultLocale = "" || phrase = "ERROR" || phrase = "") {
					RLLog.Warning(A_ThisFunc . " - Ended, no phrase found for """ . key . """ in language """ . sysLang . """. Using default """ . key . """")
					Return % key
				}
			}
		}

		StringReplace, phrase, phrase, `\n, `r`n, ALL
		StringReplace, phrase, phrase, `\t, % A_Tab, ALL
		Loop 10
		{
			idx := A_Index - 1
			IfNotEqual, p%idx%, -0
				phrase := RegExReplace(phrase, "\{" . idx . "\}", p%idx%)
		}
		RLLog.Info(A_ThisFunc . " - Ended, using """ . phrase . """ for """ . key . """")
		Return % phrase
	}
}
