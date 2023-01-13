; { \\ #Includes
#Include <Classes\tool>
; }

checkKey(key) {
	if GetKeyState(key) && !GetKeyState(key, "P")
		{
			tool.Cust(key " was stuck")
			SendInput("{" key " Up}")
		}
}