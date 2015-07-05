

#Include Once "windows.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"

#include Once "Inc\NonProjRunOpt.bi"

#Define IDC_EDT_NONPROJCMDLINEPARAM         6602
#Define IDC_CHK_NONPROJKEEPSHELL            6603

Dim Shared NonProjCmdLineParam As ZString * 512
Dim Shared NonProjKeepShell    As UINT 

Const QUOTE      As String = Chr (34)


Sub NonProjRunOptInit ()

	GetPrivateProfileString @"Make", @"NonProjCmdLineParam", NULL, @NonProjCmdLineParam, SizeOf (NonProjCmdLineParam), @ad.IniFile
	NonProjKeepShell = GetPrivateProfileInt (@"Make", @"NonProjKeepShell", 0, @ad.IniFile)

End Sub


Function NonProjRunOptDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	Dim hCtrl               As HWND           = Any
    Dim Buffer              As ZString * 1024 = Any 
    
	Select Case uMsg
	Case WM_INITDIALOG
		TranslateDialog hWin, IDD_DLG_NONPROJRUNOPTION
		CenterOwner hWin
		
		hCtrl = GetDlgItem (hWin, IDC_EDT_NONPROJCMDLINEPARAM)
		SendMessage hCtrl, EM_LIMITTEXT, SizeOf (NonProjCmdLineParam), 0
		
		GetPrivateProfileString @"Make", @"NonProjCmdLineParam", NULL, @NonProjCmdLineParam, SizeOf (NonProjCmdLineParam), @ad.IniFile
		SetDlgItemText hWin, IDC_EDT_NONPROJCMDLINEPARAM, @NonProjCmdLineParam
		
		NonProjKeepShell = GetPrivateProfileInt (@"Make", @"NonProjKeepShell", 0, @ad.IniFile)
		CheckDlgButton hWin, IDC_CHK_NONPROJKEEPSHELL, NonProjKeepShell

    Case WM_CLOSE
		EndDialog hWin, 0

	Case WM_COMMAND
		Select Case LoWord (wParam)
		Case IDOK
			GetDlgItemText hWin, IDC_EDT_NONPROJCMDLINEPARAM, @NonProjCmdLineParam, SizeOf (NonProjCmdLineParam)
			Buffer = QUOTE + NonProjCmdLineParam + QUOTE                         ' preserve quotes if existing, subsequential profile reading will remove first level of quotes
			WritePrivateProfileString @"Make", @"NonProjCmdLineParam", @Buffer, @ad.IniFile

			NonProjKeepShell = IsDlgButtonChecked (hWin, IDC_CHK_NONPROJKEEPSHELL)
			WritePrivateProfileString @"Make", @"NonProjKeepShell", Str (NonProjKeepShell), @ad.IniFile

			EndDialog hWin, 0

		Case IDCANCEL
			EndDialog hWin, 0

		End Select

	Case Else
		Return FALSE

	End Select
	Return TRUE

End Function