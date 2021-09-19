MCRC := "D1FF33E5"
MVersion := "1.0.0"

; Instantiated by creating the XmlFile instance first:
; file := new XmlFile(pathToFile)
class XmlFile
{
	;vars
	
	__New(fullFilePath,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Creating new XmlFile object of: """ . fullFilePath . """")
	}

	__Delete()
	{
	}
}
