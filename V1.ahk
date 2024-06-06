; #region:GetStdStreams_WithInput (685341990)

; #region:Metadata:
; Snippet: GetStdStreams_WithInput;  (v.1.1.3)
;  09 Oktober 2023
; --------------------------------------------------------------
; Author: u/anonymous1184
; License: none
; --------------------------------------------------------------
; Library: Personal Library
; Section: 25 - Command CommandLine
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Executes a command line input in Directory 'WorkDir', returns the command line output via the byRef variable 'InOut'
; #endregion:Description

; #region:Example
; if GetStdStreams_WithInput(A_ComSpec " /C ping 127.0.0.1 -n 9",, io) {
; msgbox, % io "`n" e
; } else {
; msgbox, % "command failed"
; }
; 
; #endregion:Example


; #region:Code
GetStdStreams_WithInput(CommandLine, WorkDir := "", ByRef InOut := "") {
    static HANDLE_FLAG_INHERIT := 0x00000001, PIPE_NOWAIT := 0x00000001, STARTF_USESTDHANDLES := 0x0100, CREATE_NO_WINDOW := 0x08000000, HIGH_PRIORITY_CLASS := 0x00000080
    DllCall("CreatePipe", "Ptr*", hInputR := 0, "Ptr*", hInputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("CreatePipe", "Ptr*", hOutputR := 0, "Ptr*", hOutputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hInputR, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetHandleInformation", "Ptr", hOutputW, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetNamedPipeHandleState", "Ptr", hOutputR, "Ptr", &PIPE_NOWAIT, "Ptr", 0, "Ptr", 0)
    VarSetCapacity(processInformation, A_PtrSize = 4 ? 16 : 24, 0) ; PROCESS_INFORMATION
    cb := VarSetCapacity(startupInfo, A_PtrSize = 4 ? 68 : 104, 0) ; STARTUPINFO
    NumPut(cb, startupInfo, 0, "UInt")
    NumPut(STARTF_USESTDHANDLES, startupInfo, A_PtrSize = 4 ? 44 : 60, "UInt")
    NumPut(hInputR, startupInfo, A_PtrSize = 4 ? 56 : 80, "Ptr")
    NumPut(hOutputW, startupInfo, A_PtrSize = 4 ? 60 : 88, "Ptr")
    NumPut(hOutputW, startupInfo, A_PtrSize = 4 ? 64 : 96, "Ptr")
    pWorkDir := IsSet(WorkDir) && WorkDir ? &WorkDir : 0
    created := DllCall("CreateProcess", "Ptr", 0, "Ptr", &CommandLine, "Ptr", 0, "Ptr", 0, "Int", true, "UInt", CREATE_NO_WINDOW | HIGH_PRIORITY_CLASS, "Ptr", 0, "Ptr", pWorkDir, "Ptr", &startupInfo, "Ptr", &processInformation)
    lastError := A_LastError
    DllCall("CloseHandle", "Ptr", hInputR)
    DllCall("CloseHandle", "Ptr", hOutputW)
    if (!created) {
        DllCall("CloseHandle", "Ptr", hInputW)
        DllCall("CloseHandle", "Ptr", hOutputR)
        throw Exception("Couldn't create process.", -1, Format("{:04x}", lastError))
    }
    if (IsSet(InOut) && InOut != "") {
        if (SubStr(InOut, 0) != "`n") {
            InOut .= "`n"
        }
        FileOpen(hInputW, "h", "UTF-8").Write(InOut)

    }
    DllCall("CloseHandle", "Ptr", hInputW)
    cbAvail := 0, InOut := ""
    pipe := FileOpen(hOutputR, "h`n", "UTF-8")
    while (DllCall("PeekNamedPipe", "Ptr", hOutputR, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", cbAvail, "Ptr", 0)) {
        if (cbAvail) {
            InOut .= pipe.Read()
        }
        else {
            Sleep 10
        }
    }
    DllCall("CloseHandle", "Ptr", hOutputR)
    hProcess := NumGet(processInformation, 0)
    DllCall("GetExitCodeProcess", "Ptr", hProcess, "UInt*", exitCode := 0)
    DllCall("CloseHandle", "Ptr", hProcess)
    hThread := NumGet(processInformation, A_PtrSize)
    DllCall("CloseHandle", "Ptr", hThread)
    return exitCode
}

; #endregion:Code



; #endregion:GetStdStreams_WithInput (685341990)
