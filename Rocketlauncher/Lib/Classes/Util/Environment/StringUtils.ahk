MCRC := "1D3F1544"
MVersion := "1.5.5"

; Not instantiated, access functions directly
class StringUtils
{
	BackslashCheck(file,id) {
		x := this.Right(file,1,0)
		If (x = "\")
			ScriptError("Please make sure " . (id ? "your " . id : "this path") . " does not contain a backslash on the end:`n" . file)
	}

	Contains(Haystack,Needle,log:=1)
	{
		FoundPos := RegExMatch(Haystack,"i)" . Needle)
		If log
			If FoundPos
				RLLog.Trace(A_ThisFunc . " - """ . Haystack . """ contains """ . Needle . """ at position " . FoundPos)
			Else
				RLLog.Trace(A_ThisFunc . " - """ . Haystack . """ does not contain """ . Needle . """")
		Return FoundPos
	}

	InStr(Haystack,Needle,CaseSensitive:=false,StartingPos:=1,Occurrence:=1,log:=1)
	{
		FoundPos := InStr(Haystack,Needle,CaseSensitive,StartingPos,Occurrence)
		If log
			If FoundPos
				RLLog.Trace(A_ThisFunc . " - Found """ . Needle . """ in """ . Haystack . """ starting at position " . StartingPos . " at position " . FoundPos)
			Else
				RLLog.Trace(A_ThisFunc . " - Could not find """ . Needle . """ in """ . Haystack . """ starting at position " . StartingPos)
		Return FoundPos
	}

	IsBoolean(v,tag) {
		If !v
			Return
		Else
			If (v != "true" || v != "false")
				ScriptError("""" . v . """ is not a boolean (true|false) value for """ . tag . """")
	}

	IsRelative(String,log:=1)
	{
		x := this.Left(String,1,0)
		If (x = ".") {
			If log
				RLLog.Trace(A_ThisFunc . " - This path is relative: """ . String . """")
			Return true
		} Else {
			If log
				RLLog.Trace(A_ThisFunc . " - This path is not relative: """ . String . """")
			Return
		}
	}

	Left(String,Length,log:=1)
	{
		If Length <= 0
			NewStr := ""
		Else If (Length > StrLen(String))
			NewStr := String
		Else
			NewStr := SubStr(String,1,Length)
		If log
			RLLog.Trace(A_ThisFunc . " - Trimming """ . String . """ to """ . NewStr . """")
		Return NewStr
	}

	Lower(String,TitleCase:="",log:=1)
	{
		StringLower, OutputVar, String, % TitleCase
		If log
			RLLog.Trace(A_ThisFunc . " - Converting """ . String . """ to """ . OutputVar . """")
		Return OutputVar
	}

	ObjToStr(obj)
	{
		Loop % obj.MaxIndex()
			str .= obj[A_Index] . "|"
		Return StringUtils.TrimRight(str,1,0)	; trim off last |
	}

	; Returns object of parsed title from a string
	ParsePCTitle(title) {
		obj:={}
		If StringUtils.Contains(title,"ahk_class") {
			newTitle := StringUtils.RegExReplace(title,"i)ahk_class","�")	; replace ahk_class with �
			Loop, Parse, newTitle, �
			{
				x := Trim(A_LoopField)
				If A_Index = 1
					obj.Title := x
				Else
					obj.Class := x
			}
		} Else {	; ahk_class not defined
			obj.Title := title
		}
		Return obj
	}

	RegExMatch(Haystack,NeedleRegEx,ByRef OutVar:="",StartingPosition:=1,log:=1)
	{
		FoundPos := RegExMatch(Haystack,NeedleRegEx,OutVar,StartingPosition)
		If log
			RLLog.Trace(A_ThisFunc . " - Matched """ . OutVar . """ from Haystack")
		Return FoundPos
	}

	RegExReplace(Haystack,NeedleRegEx,Replacement:="",ByRef OutputVarCount:="",Limit:=-1,StartingPosition:=1,log:=1)
	{
		NewStr := RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCount,Limit,StartingPosition)
		If log
			RLLog.Trace(A_ThisFunc . " - Replaced """ . Haystack . """ with """ . NewStr . """")
		Return NewStr
	}

	; Bleasby's custom version, not tested!!
	RegExReplaceX(Haystack,NeedleRegEx,Replacement:="",ByRef OutputVarCount:="",Limit:=-1,StartingPosition:=1,log:=1)
	{
		StringReplace, Haystack, Haystack, \, \\, All
		replace :=   {".":"\.","*":"\*","?":"\?","+":"\+","[":"\[","{":"\{","|":"\|","(":"\(",")":"\)","^":"\^","$":"\$"}	; replace all characters that have special functions on regexmatch
		For what, with in replace
			StringReplace, Haystack, Haystack, %what%, %with%, All
		NewStr := RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCount,Limit,StartingPosition)
		If log
			RLLog.Trace(A_ThisFunc . " - Replacing """ . Haystack . """ with """ . Replacement . """ via RegEx """ . NeedleRegEx . """")
		Return NewStr
	}

	Replace(InputVar,SearchText,ReplaceText:="",ReplaceAll:="",ByRef OutputVarCount:="",log:=1)
	{
		StringReplace,OutputVar,InputVar, %SearchText%, %ReplaceText%, %ReplaceAll%
		OutputVarCount := ErrorLevel	; the number of replacements that occured
		If log
			RLLog.Trace(A_ThisFunc . " - Replacing """ . SearchText . """ with """ . ReplaceText . """")
		Return OutputVar
	}

	; Use this instead when AHK is updated to latest
	; Replace(Haystack,SearchText,ReplaceText:="",OutputVarCount:=0,Limit:=-1,log:=1)
	; {
		; OutputVar := StrReplace(Haystack,SearchText,ReplaceText,OutputVarCount,Limit)
		; OutputVarCount := ErrorLevel	; the number of replacements that occured
		; If log
			; RLLog.Trace(A_ThisFunc . " - Replacing """ . Haystack . """ with """ . ReplaceText . """")
		; Return OutputVar
	; }

	Right(String,Length,log:=1)
	{
		strLength := StrLen(String)
		If Length <= 0
			NewStr := ""
		Else If (Length > strLength)
			NewStr := String
		Else
			NewStr := SubStr(String,strLength-Length+1)
		If log
			RLLog.Trace(A_ThisFunc . " - Trimming """ . String . """ to """ . NewStr . """")
		Return NewStr
	}

	; Returns an object of the split string provided:
	; var := StringUtils.Split(string, delimiter)
	; Access with var[1], var[2], etc
	Split(InputVar,Delimiters:="",OmitChars:="",log:=1)
	{
		StringSplit,Array,InputVar, % Delimiters, % OmitChars
		If log
			RLLog.Trace(A_ThisFunc . " - Splitting this string " . Array0 . " ways: """ . InputVar . """" . (If Delimiters ? " by """ . Delimiters . """" : ""))
		; Must convert to an object because AHK can't return the array as is from the StringSplit command
		obj := Object()
		Loop % Array0
			obj[A_Index] := Array%A_Index%
		Return obj
	}

	; SplitPath function with support for roms that contain multiple periods in their name. AHK SplitPath does not support this.
	SplitPath(fullPath,Byref outFileName:="",Byref outPath:="",Byref outExt:="",Byref outNameNoExt:="",Byref outDrive:="") {
		vectorResult := RLObject.splitPath(fullPath)
		outFileName := vectorResult[0]
		outPath := vectorResult[1]
		outExt := vectorResult[2]
		outNameNoExt := vectorResult[3]
		outDrive := vectorResult[4]
		Return
	}

	StringLength(String,log:=1)
	{
		Length := StrLen(String)
		If log
			RLLog.Trace(A_ThisFunc . " - This string is """ . Length . """ long")
		Return Length
	}

	; Converts a string to hex
	StringToHex(S,log:=1) {
		S="" ? "":Chr((*&S>>4)+48) Chr((x:=*&S&15)+48+(x>9)*7) StrToHex(SubStr(S,2))
		If log
			RLLog.Trace(A_ThisFunc . " - Converted string to """ . S . """")
		Return S
	}

	SubStr(String,StartingPos,Length:="",log:=1)
	{
		NewStr := SubStr(String,StartingPos,Length)
		If log
			RLLog.Trace(A_ThisFunc . " - Retrieved """ . NewStr . """ from """ . String . """")
		Return NewStr
	}

	TrimLeft(String,Length,log:=1)
	{
		strLength := StrLen(String)
		If (Length > strLength)
			NewStr := ""
		Else
			NewStr := SubStr(String,Length+1,strLength)
		If log
			RLLog.Trace(A_ThisFunc . " - Trimming """ . String . """ to """ . NewStr . """")
		Return NewStr
	}

	TrimRight(String,Length,log:=1)
	{
		strLength := StrLen(String)
		If (Length > strLength)
			NewStr := ""
		Else
			NewStr := SubStr(String,1,strLength-Length)
		If log
			RLLog.Trace(A_ThisFunc . " - Trimming """ . String . """ to """ . NewStr . """")
		Return NewStr
	}

	Upper(String,TitleCase:="",log:=1)
	{
		StringUpper, OutputVar, String, % TitleCase
		If log
			RLLog.Trace(A_ThisFunc . " - Converting """ . String . """ to """ . OutputVar . """")
		Return OutputVar
	}
}
