
#Define IDD_DLG_NONPROJRUNOPTION            6600

Declare Function NonProjRunOptDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
Declare Sub NonProjRunOptInit ()


Extern NonProjCmdLineParam As ZString * 512
Extern NonProjKeepShell    As UINT 
