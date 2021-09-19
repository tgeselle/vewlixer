MCRC := "9FDB406E"
MVersion := "1.0.2"

; Not instantiated, access functions directly
class Registry
{
	Delete(RootKey,SubKey,ValueName:="",RegistryVersion:=32,log:=1)
	{
		If log
			RLLog.Debug(A_ThisFunc . " - Deleting Registry Entry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",RegistryVersion=" . RegistryVersion)
		If (RegistryVersion = "64")
			this.SetRegView(64)
		RegDelete, %RootKey%, %SubKey%, %ValueName%
		this.SetRegView()	; default reg mode
		If log
			RLLog.Trace(A_ThisFunc . " - Registry Delete finished")
	}

	Read(RootKey,SubKey,ValueName:="",RegistryVersion:=32,log:=1)
	{
		Global winVer
		If log
			RLLog.Debug(A_ThisFunc . " - Reading from Registry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",RegistryVersion=" . RegistryVersion)
		If (RegistryVersion = "Auto") ;Try finding the correct registry reading based on the windows version
		{
			If (winVer = "64")
				If !OutputVar := this.Read(RootKey, SubKey, ValueName, "64",0)
				OutputVar := this.Read(RootKey, SubKey, ValueName, "32",0)
			Else
				OutputVar := this.Read(RootKey, SubKey, ValueName,"",0)
		} Else If (RegistryVersion = "32")
			RegRead, OutputVar, %RootKey%, %SubKey%, %ValueName%
		Else
			OutputVar := RegRead64(RootKey, SubKey, ValueName)
		If log
			RLLog.Debug(A_ThisFunc . " - Registry Read finished, returning " . OutputVar)
		Return OutputVar
	}

	SetRegView(RegView:="Default")
	{
		SetRegView % RegView
	}

	Write(ValueType,RootKey,SubKey,ValueName:="",Value:="",RegistryVersion:=32,log:=1)
	{
		If log
			RLLog.Debug(A_ThisFunc . " - Writing to Registry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",Value=" . Value . ",ValueType=" . ValueType . ",RegistryVersion=" . RegistryVersion)
		If (RegistryVersion = "32")
			RegWrite, %ValueType%, %RootKey%, %SubKey%, %ValueName%, %Value%
		Else
			RegWrite64(ValueType, RootKey, SubKey, ValueName, Value)
		If log
			RLLog.Trace(A_ThisFunc . " - Registry Write finished")
	}
}
