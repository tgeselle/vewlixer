MCRC := "ABC8D8D3"
MVersion := "1.0.0"

; Usage - Read and Write to config files that are not valid inis with [sections], like RetroArch's cfg
; Instantiated by creating the folder instance first:
; propertiesFile := new PropertiesFile(pathToFile)

class PropertiesFile extends File
{
	;vars
	; inherits all vars from File class
	; PropertyArray
	; Separator

	; Separator = the separator to use, defaults to =
	__New(FileFullPath,Separator:="=")
	{
		base.__New(FileFullPath)
		this.Separator := Separator
		RLLog.Trace(A_ThisFunc . " - Created new property file object of """ . this.FileFullPath . """ with Separator """ . Separator . """")
	}

	; Loads Properties File into memory
	LoadProperties()
	{
		RLLog.Debug(A_ThisFunc . " - Loading properties file : " . this.FileFullPath)
		this.PropertyArray := Object()
		Loop, Read, % this.FileFullPath ; This loop retrieves each line from the file, one at a time.
			this.PropertyArray.Insert(A_LoopReadLine) ; Append this line to the array.
		RLLog.Debug(A_ThisFunc . " - Ended")
	}

	; Saves Properties File contents back to disk
	SaveProperties()
	{
		RLLog.Debug(A_ThisFunc . " - Saving properties file to : " . this.FileFullPath)
		this.Delete()
		Loop % this.PropertyArray.MaxIndex()
		{
			element := this.PropertyArray[A_Index]
			trimmedElement := LTrim(element)
			finalCfg .= trimmedElement . "`n"
		}
		this.Append(finalCfg)
		RLLog.Debug(A_ThisFunc . " - Ended")
	}

	; Reads the value of a certain property
	; keyName = key whose value you want to read
	ReadProperty(keyName)
	{
		RLLog.Debug(A_ThisFunc . " - Reading property for key name : " . keyName . " using " . this.Separator . " as the separator")
		Loop % this.PropertyArray.MaxIndex()
		{
			element := this.PropertyArray[A_Index]
			trimmedElement := Trim(element)
			StringGetPos, pos, trimmedElement, [
			If (pos = 0)
				Break	; Section was found, do not search anymore, global section has ended

			If StringUtils.Contains(trimmedElement,this.Separator)
			{
				keyValues := StringUtils.Split(trimmedElement,this.Separator)
				CfgValue := Trim(keyValues[1])
				If (CfgValue = keyName)
				{
					RetValue := Trim(keyValues[2])	; Found it & trim any whitespace
					RLLog.Debug(A_ThisFunc . " - Value for " . keyName . " = " . RetValue)
					Return RetValue
				}
			}
		}
		RLLog.Debug(A_ThisFunc . " - Value for " . keyName . " not found")
	}

	; Writes the value of a certain property (saves it in memory, use SaveProperties to write back to disk)
	; keyName = key whose value you want to write
	; Value = value that you want to write to the keyName
	; AddSpaces = If the seperator (=) has spaces on either side, set this parameter to 1 and it will wrap the seperator in spaces
	; AddQuotes = If the Value needs to be wrapped in double quotes (like in retroarch's config), set this parameter to 1
	WriteProperty(keyName,Value,AddSpaces:=0,AddQuotes:=0)
	{
		RLLog.Debug(A_ThisFunc . " - Started")

		added := 0
		Loop % this.PropertyArray.MaxIndex()
		{
			lastIndex := A_Index
			element := this.PropertyArray[A_Index]
			trimmedElement := Trim(element)

			StringGetPos, pos, trimmedElement, [
			If (pos = 0)
			{
				lastIndex := lastIndex - 1	; Section was found, do not search anymore
				Break
			}

			If StringUtils.Contains(element,this.Separator)
			{
				keyValues := StringUtils.Split(element,this.Separator)
				;StringSplit, keyValues, element, %Separator%
				CfgValue := Trim(keyValues[1])
				If (CfgValue = keyName)
				{
					this.PropertyArray[A_Index] := CfgValue . (If AddSpaces=1 ? (" " . this.Separator . " ") : this.Separator) . (If AddQuotes=1 ? ("""" . Value . """") : Value)	; Found it
					added := 1
					Break
				}
			}
		}
		If (added = 0)
		{
			this.PropertyArray.Insert(lastIndex+1, keyName . (If AddSpaces=1 ? (" " . this.Separator . " ") : this.Separator) . (If AddQuotes=1 ? ("""" . Value . """") : Value))	; Add the new entry to the file
			RLLog.Debug(A_ThisFunc . " - Writing (insert) - " . keyName . ": " . value)
		}
		Else
		{
			RLLog.Debug(A_ThisFunc . " - Writing (update) - " . keyName . ": " . value)
		}
	}
}
