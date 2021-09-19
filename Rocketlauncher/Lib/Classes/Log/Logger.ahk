MCRC := "48E798C8"
MVersion := "1.1.1"

; Instantiated by creating the Logger instance first:
; log := new Logger(LogName,LogFileObject,ThreadID,EndOfLineCharacters)
class Logger
{
	;vars
	; EndOfLine	; characters used to end each line in the log
	; Errors	; records # of errors
	; LogFile	; file object of the log file
	; LogText	; full log
	; Name		; name of log
	; ThreadID	; id of thread log is assigned to
	; Warnings	; records # of warnings


	__New(n,fileObj,tID,eol)
	{
		this.Errors := 0
		this.EndOfLine := eol
		this.LogFile := fileObj
		this.Name := n
		this.ThreadID := tID
		this.Warnings := 0
		; this.Log(A_ThisFunc . " - Created new Logger object: """ . this.Name . """")
	}

	__Delete()
	{
		this.LogFile := ""
		this.EndOfLine := ""
		this.Errors := ""
		this.Name := ""
		this.ThreadID := ""
		this.Warnings := ""
	}

	Open(firstLine)
	{
		this.Log(firstLine,"",1,1)
	}

	Close(lastLine)
	{
		this.Log(lastLine,"",1,1)
	}

	; useful to dump log to file while keeping it open
	; before starting a new thread, it might be useful to dump log to file in case thread crashes before any logging is done
	Dump(txt)
	{
		this.Log(txt,1,"",1)
	}

	Info(txt,noDiff:="")
	{
		this.Log(txt,1,"","",noDiff)
	}

	Warning(txt,noDiff:="")
	{
		this.Warnings++
		this.Log(txt,2,"","",noDiff)
	}

	Error(txt,noDiff:="")
	{
		this.Errors++
		this.Log(txt,3,"","",noDiff)
	}

	Debug(txt,noDiff:="")
	{
		this.Log(txt,4,"","",noDiff)
	}

	Trace(txt,noDiff:="")
	{
		this.Log(txt,5,"","",noDiff)
	}

	TraceDLL(txt,noDiff:="")
	{
		this.Log(txt,6,"","",noDiff)
	}

	; txt = text I want to log
	; lvl = the lvl to log the text at
	; noTime = only used for 1st and last lines of the log so a time is not inserted when I inset the BBCode [code] tags.
	; dump = tells the function to write the log file at the end. Do not use this param directly.
	; noDiff = tells the function to not insert a time when the first or last log line is made, instead puts an N/A.
	; Log() in the module thread requires `r`n at the end of each line, where it's not needed in the RocketLauncher thread
	Log(txt,lvl:=1,noTime:="",dump:="",noDiff:="")
	{
		Static lastTimeStamp
		Static logLabel := ["     INFO","  WARNING","    ERROR","    DEBUG","    TRACE","TRACE_DLL"]
		Global logFile,logLevel,logShowDebugConsole
		If (logLevel > 0)
		{
			If (lvl <= logLevel || lvl = 3) {	; ensures errors are always logged
				logDiff := A_TickCount - lastTimeStamp
				lastTimeStamp := A_TickCount
				this.LogEntry := (If noTime?"" : A_Hour . ":" . A_Min ":" . A_Sec ":" . A_MSec . " | " . this.ThreadID . " | " . logLabel[lvl] . A_Space . " | +" . this.AlignColumn(If noDiff ? "N/A" : logDiff) . "" . " | ") . txt . this.EndOfLine
				this.LogText .= this.LogEntry	; update full log with this entry
			}
			If (logShowDebugConsole = "true")
				DebugMessage(this.LogEntry)
			If (logLevel >= 10)
				this.LogFile.Append(this.LogEntry,"",0)
			Else If dump {
				this.LogFile.Append(this.LogText,"",0)
				this.LogText := ""
			}
		}
	}

	; Inserts extra characters/spaces into sections of the Log file to keep it aligned.
	; Usage: inserts char x number of times on the end of txt until pad is reached.
	AlignColumn(txt,pad:=9,char:=" "){
		x := If char=" "?2:1	; if char is a space, let's only insert half as many so it looks slightly more even in notepad++
		Loop {
			n := StrLen(txt)
			If (n*x >= pad)
				Break
			txt := txt . char
		}
		Return txt
	}
}
