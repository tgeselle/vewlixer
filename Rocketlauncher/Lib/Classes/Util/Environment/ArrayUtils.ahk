MCRC := "7A8DF696"
MVersion := "1.0.0"

; Not instantiated, access functions directly
class ArrayUtils
{

	ArrayContains(haystack, needle) {
		If (!isObject(haystack) || haystack.Length()==0)
			Return false
		For k,v in haystack
			If (v = needle)
				Return true
		Return false
	}

}
