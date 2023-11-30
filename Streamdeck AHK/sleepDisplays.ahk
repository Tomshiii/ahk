;//! BE WARNED
;//! I have noticed that if you use this command to sleep the displays and then immediately try to wake the PC, it can get stuck in a loop of sleeping/waking and it can be quite tough to break out of it.

;// https://superuser.com/questions/321342/turn-off-display-in-windows-on-command/1542141#1542141
cmdd := '$obj = Add-Type -MemberDefinition `'[DllImport(""""user32.dll"""")] public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);`' -Name fn -Namespace ns -PassThru; $obj::SendMessage(0xffff, 0x0112, 0xF170, 2)'
Run("powershell -Command " cmdd, "c:\")