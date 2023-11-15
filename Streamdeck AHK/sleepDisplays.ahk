;// https://superuser.com/questions/321342/turn-off-display-in-windows-on-command/1542141#1542141
cmdd := '$obj = Add-Type -MemberDefinition `'[DllImport(""""user32.dll"""")] public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);`' -Name fn -Namespace ns -PassThru; $obj::SendMessage(0xffff, 0x0112, 0xF170, 2)'
Run("powershell -Command " cmdd, "c:\")