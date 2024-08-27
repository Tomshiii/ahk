;// this script will alter the registry values required for the user to run unsigned extensions
;// within premiere pro - this is required for PremiereRemote to function
;// this script can also be run to fix newer versions of premiere as they update CEP

;// prem v??-v24
if !RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.11", "PlayerDebugMode", 0)
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.11", "PlayerDebugMode")
;// prem v25-v??
if !RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", 0)
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")