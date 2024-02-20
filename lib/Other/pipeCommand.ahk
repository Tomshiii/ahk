;// This function was provided to me by `DepthTrawler` in the ahk discord
;// https://discord.com/channels/115993023636176902/1209347616513720342/1209485394270224406

/**
 * Executes a command and returns information about the process, including exit code, standard error, and standard output.
 * @param {String} Target - The command to be executed.
 * @param {String} [WorkingDir=A_WorkingDir] - The working directory for the command.
 * @param {Boolean} [returnObj=false] - Determines whether the function returns an object or a single string
 * @param {String} [Encoding=CP0] - The encoding used for reading standard error and standard output.
 * @returns {Object} - An `Object` or a `String` depending on the `returnObj` variable.
 * @property {Number} Object.ExitCode - The exit code of the command.
 * @property {String} Object.StdErr - The standard error output of the command.
 * @property {String} Object.StdOut - The standard output of the command.
 * @author DepthTrawler, g33k
 * @link [original post](https://discord.com/channels/115993023636176902/1209347616513720342/1209485394270224406)
 */
pipeCommand(Target, WorkingDir := "", returnObj := false, Encoding := "CP0", PipeBufferKB := 64) {
	static NULLCHAR := 1
	ReadStdErr := Object()
	ReadStdErr.Ptr := 0
	ReadStdErr.__Delete := (this) => DllCall("kernel32.dll\CloseHandle", "Ptr", this)
	WriteStdErr := Object()
	WriteStdErr.Base := ReadStdErr
	ReadStdOut := Object()
	ReadStdOut.Ptr := 0
	ReadStdOut.__Delete := (this) => DllCall("kernel32.dll\CloseHandle", "Ptr", this)
	WriteStdOut := Object()
	WriteStdOut.Base := ReadStdOut
	CreatePipe := DllCall("kernel32.dll\CreatePipe",
		"Ptr*", ReadStdErr, ; hReadPipe
		"Ptr*", WriteStdErr, ; hWritePipe
		"Ptr", 0, ; lpPipeAttributes
		"UInt", 1024 * PipeBufferKB ; nSize
	)
	if !CreatePipe {
		throw OSError(A_LastError)
	}
	SetHandleInfo := DllCall("kernel32.dll\SetHandleInformation",
		"Ptr", WriteStdErr, ; hObject
		"UInt", 0x00000001, ;dwMask -> HANDLE_FLAG_INHERIT = 0x00000001
		"UInt", 0x00000001 ; dwFlags -> HANDLE_FLAG_INHERIT = 0x00000001
	)
	if !SetHandleInfo {
		throw OSError(A_LastError)
	}
	CreatePipe := DllCall("kernel32.dll\CreatePipe",
		"Ptr*", ReadStdOut, ; hReadPipe
		"Ptr*", WriteStdOut, ; hWritePipe
		"Ptr", 0, ; lpPipeAttributes
		"UInt", 1024 * PipeBufferKB ; nSize
	)
	if !CreatePipe {
		throw OSError(A_LastError)
	}
	SetHandleInfo := DllCall("kernel32.dll\SetHandleInformation",
		"Ptr", WriteStdOut, ; hObject
		"UInt", 0x00000001, ;dwMask -> HANDLE_FLAG_INHERIT = 0x00000001
		"UInt", 0x00000001 ; dwFlags -> HANDLE_FLAG_INHERIT = 0x00000001
	)
	if !SetHandleInfo {
		throw OSError(A_LastError)
	}
	PROCESS_INFORMATION := Buffer(A_PtrSize = 4 ? 16 : 24, 0) ; PROCESS_INFORMATION structure.
	STARTUPINFO := Buffer(A_PtrSize = 4 ? 68 : 104, 0) ; STARTUPINFO structure.
	NumPut("UInt", STARTUPINFO.Size, STARTUPINFO, 0) ; cbSize
	NumPut("UInt", STARTF_USESTDHANDLES := 0x00000100, STARTUPINFO, A_PtrSize = 4 ? 44 : 60) ; dwFlags
	NumPut("Ptr", WriteStdOut.Ptr, STARTUPINFO, A_PtrSize = 4 ? 60 : 88) ; hStdInput
	NumPut("Ptr", WriteStdErr.Ptr, STARTUPINFO, A_PtrSize = 4 ? 64 : 96) ; hStdError
	CreateProcess := DllCall("kernel32.dll\CreateProcess",
		"Ptr", 0, ; lpApplicationName
		"Str", Target, ; lpCommandLine
		"Ptr", 0, ; lpProcessAttributes
		"Ptr", 0, ; lpThreadAttributes
		"Int", true, ; bInheritHandles
		"UInt", 0x08000000, ; dwCreationFlags -> CREATE_NO_WINDOW = 0x08000000
		"Ptr", 0, ; lpEnvironment
		"Ptr", WorkingDir ? StrPtr(WorkingDir) : 0, ; lpCurrentDirectory
		"Ptr", STARTUPINFO, ; lpStartupInfo
		"Ptr", PROCESS_INFORMATION ; lpProcessInformation
	)
	if !CreateProcess {
		throw OSError(A_LastError)
	}
	; The write pipes must be closed before reading the output so release the object.
	WriteStdErr := ""
	WriteStdOut := ""
	while PeekNamedPipe(ReadStdErr, &BytesAvail := 0) {
		if !BytesAvail {
			continue
		}
		BufferObj := Buffer(BytesAvail + NULLCHAR)
		DllCall("kernel32.dll\ReadFile",
			"Ptr", ReadStdErr, ; hFile
			"Ptr", BufferObj, ; lpBuffer
			"UInt", BytesAvail, ; nNumberOfBytesToRead
			"Ptr*", &BytesRead := 0, ; lpNumberOfBytesRead
			"Ptr" , 0 ; lpOverlapped
		)
		StdErr .= StrGet(BufferObj, BytesRead, Encoding)
	}
	StdErr := RegExReplace(StdErr ?? "", "\r?\n$")
	while PeekNamedPipe(ReadStdOut, &BytesAvail := 0) {
		if !BytesAvail {
			continue
		}
		BufferObj := Buffer(BytesAvail + NULLCHAR)
		DllCall("kernel32.dll\ReadFile",
			"Ptr", ReadStdOut, ; hFile
			"Ptr", BufferObj, ; lpBuffer
			"UInt", BytesAvail, ; nNumberOfBytesToRead
			"Ptr*", &BytesRead := 0, ; lpNumberOfBytesRead
			"Ptr" , 0 ; lpOverlapped
		)
		StdOut .= StrGet(BufferObj, BytesRead, Encoding)
	}
	StdOut := RegExReplace(StdOut ?? "", "\r?\n$")
	DllCall("kernel32.dll\GetExitCodeProcess",
		"Ptr", NumGet(PROCESS_INFORMATION, 0, "Ptr"), ; hProcess
		"UInt*", &ExitCode := 0 ; lpExitCode
	)
	Handle := NumGet(PROCESS_INFORMATION, 0, "Ptr")
	DllCall("kernel32.dll\CloseHandle", "Ptr", Handle)
	Handle := NumGet(PROCESS_INFORMATION, A_PtrSize, "Ptr")
	DllCall("kernel32.dll\CloseHandle", "Ptr", Handle)

    if returnObj = true
	    return {StdErr: StdErr ?? "", StdOut: StdOut ?? "", ExitCode: ExitCode}
    else
        return ((StdOut != "") ? StdOut : StdErr)

	PeekNamedPipe(Handle, &BytesAvail) {
		return DllCall("kernel32.dll\PeekNamedPipe",
			"Ptr", Handle, ; hNamedPipe
			"Ptr", 0, ; lpBuffer
			"UInt", 0, ; nBufferSize
			"Ptr", 0, ; lpBytesRead
			"UInt*", &BytesAvail := 0, ; lpTotalBytesAvail
			"Ptr", 0 ; lpBytesLeftThisMessage
		)
	}
}