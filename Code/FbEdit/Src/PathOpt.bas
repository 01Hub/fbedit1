'
''PathOpt.dlg
'#Define IDD_DLGPATHOPTION					5400
'#Define IDC_EDTOPTCOMPILERPATH			    1003
'#Define IDC_EDTOPTPROJECTPATH				1005
'#Define IDC_EDTOPTHELPPATH					5402
'#Define IDC_BTNOPTPROJECTPATH				1007
'#Define IDC_BTNOPTCOMPILERPATH			    1008
'#Define IDC_BTNOPTHELPPATH					5401
'#Define IDC_EDTOPTAPPPATH                   5404     ' MOD 24.1.2012 ADD
'
'
'Function PathOptDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
'
'	Select Case uMsg
'		Case WM_INITDIALOG
'			TranslateDialog(hWin,IDD_DLGPATHOPTION)
'			CenterOwner(hWin)
'			GetPrivateProfileString(StrPtr("Project"),StrPtr("Path"),NULL,@buff,260,@ad.IniFile)
'			SetDlgItemText(hWin,IDC_EDTOPTPROJECTPATH,@buff)
'			GetPrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),NULL,@buff,260,@ad.IniFile)
'			SetDlgItemText(hWin,IDC_EDTOPTCOMPILERPATH,@buff)
'			GetPrivateProfileString(StrPtr("Help"),StrPtr("Path"),NULL,@buff,260,@ad.IniFile)
'			SetDlgItemText(hWin,IDC_EDTOPTHELPPATH,@buff)
'			SetDlgItemText(hWin,IDC_EDTOPTAPPPATH,@ad.AppPath)
'			'
'		Case WM_CLOSE
'			EndDialog(hWin, 0)
'			'
'		Case WM_COMMAND
'			Select Case LoWord(wParam)
'				Case IDOK
'					GetDlgItemText(hWin,IDC_EDTOPTPROJECTPATH,@ad.DefProjectPath,260)
'					WritePrivateProfileString(StrPtr("Project"),StrPtr("Path"),@ad.DefProjectPath,@ad.IniFile)
'					If ad.DefProjectPath[0] = Asc("\") Then
'						ad.DefProjectPath=Left(ad.AppPath,2) & ad.DefProjectPath
'					EndIf
'					FixPath(ad.DefProjectPath)
'					GetDlgItemText(hWin,IDC_EDTOPTCOMPILERPATH,@ad.fbcPath,260)
'					WritePrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),@ad.fbcPath,@ad.IniFile)
'					If ad.fbcPath[0] = Asc("\") Then
'						ad.fbcPath=Left(ad.AppPath,2) & ad.fbcPath
'					EndIf
'					FixPath(ad.fbcPath)
'					GetDlgItemText(hWin,IDC_EDTOPTHELPPATH,@ad.HelpPath,260)
'					WritePrivateProfileString(StrPtr("Help"),StrPtr("Path"),@ad.HelpPath,@ad.IniFile)
'					If ad.HelpPath[0] = Asc("\") Then
'						ad.HelpPath=Left(ad.AppPath,2) & ad.HelpPath
'					EndIf
'					FixPath(ad.HelpPath)
'					GetMakeOption
'					EndDialog(hWin, 0)
'					'
'				Case IDCANCEL
'					EndDialog(hWin, 0)
'					'
'				Case IDC_BTNOPTPROJECTPATH
'					BrowseForFolder(hWin,IDC_EDTOPTPROJECTPATH)
'					'
'				Case IDC_BTNOPTCOMPILERPATH
'					BrowseForFolder(hWin,IDC_EDTOPTCOMPILERPATH)
'					'
'				Case IDC_BTNOPTHELPPATH
'					BrowseForFolder(hWin,IDC_EDTOPTHELPPATH)
'					'
'			End Select
'		Case Else
'			Return FALSE
'			'
'	End Select
'	Return TRUE
'
'End Function
