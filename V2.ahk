; #region:GetStdStreams_WithInput (685341990)

; #region:Metadata:
; Snippet: GetStdStreams_WithInput;  (v.1.1.3)
;  09 Oktober 2023
; --------------------------------------------------------------
; Author: u/anonymous1184, translated by Gewerd Strauss
; License: none
; --------------------------------------------------------------
; Library: Personal Library
; Section: 25 - Command CommandLine
; Dependencies: /
; AHK_Version: v2
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Executes a command line input in Directory 'WorkDir', returns the command line output via the byRef variable 'InOut'
; #endregion:Description

; #region:Example
if GetStdStreams_WithInput(A_ComSpec " /C ping 127.0.0.1 -n 9", , &io) {
    MsgBox(io)
} else {
    MsgBox("command failed")
}
;
; #endregion:Example


; #region:Code
GetStdStreams_WithInput(CommandLine, WorkDir := "", &InOut := "") {
    static HANDLE_FLAG_INHERIT := 0x00000001, PIPE_NOWAIT := 0x00000001, STARTF_USESTDHANDLES := 0x0100, CREATE_NO_WINDOW := 0x08000000, HIGH_PRIORITY_CLASS := 0x00000080
    DllCall("CreatePipe", "Ptr*", &hInputR := 0, "Ptr*", &hInputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("CreatePipe", "Ptr*", &hOutputR := 0, "Ptr*", &hOutputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hInputR, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetHandleInformation", "Ptr", hOutputW, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    ; v1->v2-conversion error: DllCall("SetNamedPipeHandleState", "Ptr", hOutputR, "Ptr", PIPE_NOWAIT, "Ptr", 0, "Ptr", 0)
    DllCall("SetNamedPipeHandleState", "Ptr", hOutputR, "uint*", &lpMode := 1, "Ptr", 0, "Ptr", 0)
    processInformation := Buffer(A_PtrSize = 4 ? 16 : 24, 0) ; PROCESS_INFORMATION ; V1toV2: if 'processInformation' is a UTF-16 string, use 'VarSetStrCapacity(&processInformation, A_PtrSize = 4 ? 16 : 24)'
    cb := startupInfo := Buffer(A_PtrSize = 4 ? 68 : 104, 0) ; STARTUPINFO ; V1toV2: if 'startupInfo' is a UTF-16 string, use 'VarSetStrCapacity(&startupInfo, A_PtrSize = 4 ? 68 : 104)'
    ; v1->v2-conversion error: NumPut("UInt", cb, startupInfo, 0)
    NumPut("UInt", cb.Size, startupInfo, 0)
    NumPut("UInt", STARTF_USESTDHANDLES, startupInfo, A_PtrSize = 4 ? 44 : 60)
    NumPut("Ptr", hInputR, startupInfo, A_PtrSize = 4 ? 56 : 80)
    NumPut("Ptr", hOutputW, startupInfo, A_PtrSize = 4 ? 60 : 88)
    NumPut("Ptr", hOutputW, startupInfo, A_PtrSize = 4 ? 64 : 96)
    pWorkDir := IsSet(WorkDir) && WorkDir ? &WorkDir : 0
    ; v1->v2-conversion error: created := DllCall("CreateProcess", "Ptr", 0, "Ptr", CommandLine, "Ptr", 0, "Ptr", 0, "Int", true, "UInt", CREATE_NO_WINDOW | HIGH_PRIORITY_CLASS, "Ptr", 0, "Ptr", pWorkDir, "Ptr", startupInfo, "Ptr", processInformation)
    created := DllCall("CreateProcess", "Ptr", 0, "WStr", CommandLine, "Ptr", 0, "Ptr", 0, "Int", true, "UInt", CREATE_NO_WINDOW | HIGH_PRIORITY_CLASS, "Ptr", 0, "Ptr", pWorkDir, "Ptr", startupInfo, "Ptr", processInformation)
    lastError := A_LastError
    DllCall("CloseHandle", "Ptr", hInputR)
    DllCall("CloseHandle", "Ptr", hOutputW)
    if (!created) {
        DllCall("CloseHandle", "Ptr", hInputW)
        DllCall("CloseHandle", "Ptr", hOutputR)
        throw Error("Couldn't create process.", -1, Format("{:04x}", lastError))
    }
    if (IsSet(InOut) && InOut != "") {
        if (SubStr(InOut, -1) != "`n") {
            InOut .= "`n"
        }
        FileOpen(hInputW, "h", "UTF-8").Write(InOut)

    }
    DllCall("CloseHandle", "Ptr", hInputW)
    cbAvail := 0, InOut := ""
    pipe := FileOpen(hOutputR, "h`n", "UTF-8")
    while (DllCall("PeekNamedPipe", "Ptr", hOutputR, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", &cbAvail, "Ptr", 0)) {
        if (cbAvail) {
            InOut .= pipe.Read()
        } else {
            Sleep(10)
        }
    }
    DllCall("CloseHandle", "Ptr", hOutputR)
    hProcess := NumGet(processInformation, 0x0, "Ptr")
    DllCall("GetExitCodeProcess", "Ptr", hProcess, "UInt*", &exitCode := 0)
    DllCall("CloseHandle", "Ptr", hProcess)
    hThread := NumGet(processInformation, A_PtrSize, "UPtr")
    DllCall("CloseHandle", "Ptr", hThread)
    return exitCode
}

; #endregion:Code


; #endregion:GetStdStreams_WithInput (685341990)
