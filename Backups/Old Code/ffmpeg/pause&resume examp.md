<!-- Pause -->
```ps1
Add-Type -Namespace Win32 -Name Proc -MemberDefinition @'
[DllImport("ntdll.dll")] public static extern int NtSuspendProcess(IntPtr h);
[DllImport("ntdll.dll")] public static extern int NtResumeProcess(IntPtr h);
'@ -ErrorAction SilentlyContinue

$p = Get-Process ffmpeg | Where-Object { $_.Path -like '*\lib\ffmpeg\*' } | Select-Object -First 1
if ($p) { [void][Win32.Proc]::NtSuspendProcess($p.Handle); "Paused PID $($p.Id)" }
else    { "No ffmpeg process found" }
```

<!-- resume -->
```ps1
Add-Type -Namespace Win32 -Name Proc -MemberDefinition @'
[DllImport("ntdll.dll")] public static extern int NtSuspendProcess(IntPtr h);
[DllImport("ntdll.dll")] public static extern int NtResumeProcess(IntPtr h);
'@ -ErrorAction SilentlyContinue

$p = Get-Process ffmpeg | Where-Object { $_.Path -like '*\lib\ffmpeg\*' } | Select-Object -First 1
if ($p) { [void][Win32.Proc]::NtResumeProcess($p.Handle); "Resumed PID $($p.Id)" }
else    { "No ffmpeg process found" }
```

<!-- resum if there are stacked suspends -->
```ps1
Add-Type -Namespace Win32 -Name Proc -MemberDefinition @'
[DllImport("ntdll.dll")] public static extern int NtSuspendProcess(IntPtr h);
[DllImport("ntdll.dll")] public static extern int NtResumeProcess(IntPtr h);
'@ -ErrorAction SilentlyContinue

$p = Get-Process ffmpeg | Where-Object { $_.Path -like '*\lib\ffmpeg\*' } | Select-Object -First 1
if ($p) {
    1..10 | ForEach-Object { [void][Win32.Proc]::NtResumeProcess($p.Handle) }
    "Resumed PID $($p.Id) (cleared any stacked suspends)"
} else {
    "No ffmpeg process found"
}
```
(this is essentially just a 10 loop though so not overly sophisticated. shouldn't be necessary)