MCRC := "752C2B49"
MVersion := "1.1.3"

; Instantiated by creating the RIniFile instance first:
; RIniFile := new RIniFile(ID,IndexName1>IndexName1|IndexName2>IndexName2|etc)
; iniVar := RIniFile.Read(section1|section2|etc,key,defaultValue)
class RIniFile
{
	;vars
	; ID		; ID of the type of inis being used, for example if used for Modules, use "Module". This is used to differentiate entries in logging
	; RIndex	; Contains index of all RInis used for this instance, order determines priority
	;   #		; The index for the ini. Denotes priority as 1 is checked first, followed by 2, etc.
	;     Name	: Name of the indexed Ini
	;     Path	: File object of path to this ini. Use file class vars to access

	__New(id,iniIndexes)
	{
		this.ID := id
		this.RIndex := {}
		Loop, Parse, iniIndexes, |	; create RIni index
		{
			Loop, Parse, A_LoopField, >
				If A_Index = 1
					a := A_LoopField	; index name
				Else
					b := A_LoopField	; path
			b := new file(b)
			If b.Exist()	; if this ini exists, store it in the final index
			{
				c++
				this.RIndex[c] := {}
				this.RIndex[c].Name := a
				this.RIndex[c].Path := b
				RIni_Read(a,b.FileFullPath)	; load into ini library
				RLLog.Debug(A_ThisFunc . " - """ . this.ID . """ at index " . c . ", adding """ . a . """ from: """ . b.FileFullPath . """")
			} Else
				b.__Delete()	; delete file instance
		}
	}

	; No real method to clear a loaded ini from Rini itself
	__Delete()
	{
		this.RIndex := ""
	}

	; Rini returns "ERROR_SECTION_NOT_FOUND" if section does not exist
	; Rini returns "ERROR_KEY_NOT_FOUND" if key does not exist
	; Rini returns "ERROR_INVALID_REFERENCE" if an invalid reference var for the ini file was used
	; Rini returns empty value if key exists with no value
	Read(section,key,defaultvalue:="",errorMsg:="",logType:="") {
		key := Trim(key)
		Loop % this.RIndex.MaxIndex()
		{
			iniIndex := A_Index
			Loop, Parse, section, |
			{
				;v := RIni_GetKeyValue(this.RIndex[iniIndex].Name,A_LoopField,key)
				v := RIni_GetRLKeyValue(this.RIndex[iniIndex].Name,A_LoopField,key)
				v := Trim(v)	; trims whitespace

				If (v != "ERROR_INVALID_REFERENCE" && v != "ERROR_SECTION_NOT_FOUND" && v != "ERROR_KEY_NOT_FOUND" && v != "")	; if a value exists and is not empty
				{
					RLLog.Info(A_ThisFunc . " - " . this.ID . " {" . this.RIndex[iniIndex].Name . "} - [" . A_LoopField . "] - " . key . ": " . v)
					Return v
				} Else
					RLLog.Trace(A_ThisFunc . " - " . this.ID . " {" . this.RIndex[iniIndex].Name . "} - [" . A_LoopField . "] - " . key . ": " . (v = -2 ? "Section does not exist" : v = -3 ? "Key does not exist" : "No value for this key"))
			}
		}
		If (defaultvalue = A_Space) {	; Do not allow A_Space as a default value
			RLLog.Warning(A_ThisFunc . " - " . this.ID . " - " . key . " removed space from default value")
			defaultvalue := ""
		}
		If errorMsg
			ScriptError(errorMsg)
		Else If (defaultvalue != "") {
			RLLog.Info(A_ThisFunc . " - " . this.ID . " - " . key . ": " . defaultvalue . " (DEFAULT)")
			Return defaultvalue
		} Else
			RLLog.Info(A_ThisFunc . " - " . this.ID . " - " . key . ": (NO VALUE)")
	}

	Write(value,ini,section,key)
	{
		Loop % this.RIndex.MaxIndex()
		{
			If (this.RIndex[A_Index].Name = ini) {	; check to see if the ini provided exists as an RIni first
				validIni := 1
				iniPath := this.RIndex[A_Index].Path.FileFullPath
			}
		}
		If !validIni
			ScriptError(A_ThisFunc . " - " . this.ID . " - """ . ini . """ is not a valid ini. Please make sure the ini is added to the index of this instance first.")
		RIni_SetKeyValue(ini,section,key,value)	; Set new value to ini in memory
		RIni_Write(ini,iniPath,"`r`n",1,1,1)	; Write the ini to disk to save the new value
		RLLog.Info(A_ThisFunc . " - " . this.ID . " {" . ini . "} - " . key . ": " . value)
	}
}
