/**
 * This function sends commands to the commandline and returns the result
 * func found here: https://lexikos.github.io/v2/docs/commands/Run.htm#Examples
 * @param command is the command you wish to send to the commandline
 */
getcmd(command) {
    shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_ComSpec " /C " command)
    return exec.StdOut.ReadAll()
}