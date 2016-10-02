

#Define IDD_DLG_ENVIRON         1600


Declare Function ExpandStrByEnviron (ByRef Source As ZString, ByVal SourceSize As Integer, ByVal MaxAttempt As Integer = 5) As BOOL
Declare Sub UpdateEnvironment ()

Declare Function EnvironProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

