MCRC := "1A151944"
MVersion := "1.0.1"

; Instantiated by creating an instance first:
; shooterInstance := new DemulShooter()
class DemulShooter extends Process
{
	;vars
	; inherits all vars from Process class

	__New()
	{
		Global demulShooterPath
		base.__New(demulShooterPath)	; extends to use super class constructor so all Process methods can be used directly, (ex Run, Process, etc)
		RLLog.Trace(A_ThisFunc . " - Created new DemulShooter object of: """ . this.FileFullPath . """")
	}

	Launch(target,rom,params:="")
	{
		RLLog.Debug(A_ThisFunc . " - Launching DemulShooter from " . this.FileFullPath . " with target=" . target . ", rom=" . rom . ", params=" . params)
		base.Run("-target=" . target . " -rom=" . rom . (params ? " " . params : ""))
	}
}
