
#Include Once "windows.bi"

#Include Once "Inc\RAGrid.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\Environment.bi"


#Define IDC_GRD_USERSTRING      1601
#Define IDC_GRD_READONLY        1602
#Define IDC_GRD_USERPATH        1603
#Define IDC_GRD_PATH            1604

#Define IDC_BTN_OK              1605
#Define IDC_BTN_CANCEL          1606

#Define IDC_STC_PATH            1607
#Define IDC_STC_USERPATH        1608
#Define IDC_STC_READONLY        1609
#Define IDC_STC_USERSTRING      1610

#Define IDC_BTN_ADD_USERPATH    1611
#Define IDC_BTN_DEL_USERPATH    1612
#Define IDC_BTN_DEL_USERSTRING  1613
#Define IDC_BTN_ADD_USERSTRING  1614


#Define DLG_ENVIRON_FIRST_CTL   IDC_GRD_USERSTRING
#Define DLG_ENVIRON_LAST_CTL    IDC_BTN_ADD_USERSTRING



Type EnvironVarName     As ZString * 64
Type EnvironPathValue   As ZString * MAX_PATH
Type EnvironStringValue As ZString * 1024
Type EnvironItem        As ZString * SizeOf (EnvironVarName) + SizeOf (EnvironStringValue) + 1

Type CONTROLGEOM    ' initial geometry of controls in dialogbox (dialog coords)
    L As Long       ' left
    T As Long       ' top
    W As Long       ' width
    H As Long       ' height
End Type


Const EnvDlgGrdCount As Integer = 4

Dim Shared EnvDlgGrdItems(1 To EnvDlgGrdCount) As Integer => { IDC_GRD_READONLY,   _
                                                               IDC_GRD_PATH,       _
                                                               IDC_GRD_USERPATH,   _
                                                               IDC_GRD_USERSTRING  _
                                                             }


Dim Shared EnvPaths(1 To ...) As EnvironVarName => { "HELP_PATH",     _
                                                     "FBC_PATH",      _
                                                     "FBCINC_PATH",   _
                                                     "FBCLIB_PATH",   _
                                                     "PROJECTS_PATH"  _
                                                   }



Function EnvironProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

    Dim    i              As Integer             = Any
    Dim    n              As Integer             = Any
    Dim    dW             As Integer             = Any
    Dim    dH             As Integer             = Any
    Dim    dH025          As Integer             = Any
    Dim    dH050          As Integer             = Any
    Dim    dH075          As Integer             = Any
    Dim    hGrd           As HWND                = Any
    Dim    hGrdPath       As HWND                = Any
    Dim    hGrdUserPath   As HWND                = Any
    Dim	   hGrdReadOnly   As HWND                = Any
    Dim    hGrdUserString As HWND                = Any
    Dim    hDlgItem       As HWND                = Any
    Dim    clmn           As COLUMN
    Dim    row(1)         As ZString Ptr         = Any
    Dim    CurrRow        As Integer             = Any
    Dim    RowCol         As DWORD               = Any

    Dim    EPathValue     As EnvironPathValue
    Dim    EStringValue   As EnvironStringValue
    Dim    EName          As EnvironVarName
    Dim    EditorMode     As Long                = Any
    Dim    pPIDL          As LPITEMIDLIST        = Any
    Dim    bri            As BROWSEINFO
    Dim    SectionBuffer  As ZString * 64 * 1024
    Dim    FileSpec       As ZString * MAX_PATH
    Dim    DlgRect        As RECT                = Any
    Dim    ItemRect       As RECT                = Any

    Static InitGeoCtl(IDD_DLG_ENVIRON To DLG_ENVIRON_LAST_CTL) As CONTROLGEOM  ' DLG coords

    Select Case uMsg
    Case WM_INITDIALOG

        TranslateDialog hWin, IDD_DLG_ENVIRON
        GetClientRect hWin, Cast(RECT ptr, @InitGeoCtl(IDD_DLG_ENVIRON))       ' save initial geometry

        For i = DLG_ENVIRON_FIRST_CTL to DLG_ENVIRON_LAST_CTL
            hDlgItem = GetDlgItem (hWin, i)
            GetWindowRect hDlgItem, @ItemRect                                  ' screen coord
            InitGeoCtl(i).L = ItemRect.left
            InitGeoCtl(i).T = ItemRect.top
            InitGeoCtl(i).W = ItemRect.right - ItemRect.left
            InitGeoCtl(i).H = ItemRect.bottom - ItemRect.top

            MapWindowPoints NULL, hWin, Cast (Point Ptr, @InitGeoCtl(i)), 1
        Next

        GetWindowRect hWin, @DlgRect                                           ' startup position for non existing ini file entry
        LoadFromIni "Win", "EnvironDlgPos", "4444", @DlgRect, FALSE
        SetWindowPos hWin, 0, DlgRect.Left, DlgRect.Top, DlgRect.Right - DlgRect.Left, DlgRect.Bottom - DlgRect.Top, SWP_NOZORDER

        ' build all grids
        For i = 1 To UBound (EnvDlgGrdItems)

            hGrd = GetDlgItem (hWin, EnvDlgGrdItems(i))
            SendMessage hGrd, WM_SETFONT, SendMessage (hWin, WM_GETFONT, 0, 0), FALSE
            SendMessage hGrd, GM_SETHDRHEIGHT, 0, 22

            SendMessage hGrd, GM_SETROWHEIGHT, 0, 20

            clmn.colwt       = 160
            clmn.lpszhdrtext = @"Name"
            clmn.ctype       = TYPE_EDITTEXT
            clmn.ctextmax    = SizeOf (EnvironVarName)
            SendMessage hGrd, GM_ADDCOL, 0, Cast (LPARAM, @clmn)

            Select Case EnvDlgGrdItems(i)
            Case IDC_GRD_USERSTRING
                clmn.ctype    = TYPE_EDITTEXT
                clmn.ctextmax = SizeOf (EnvironStringValue)
            Case IDC_GRD_READONLY
                clmn.ctype    = TYPE_EDITTEXT
                clmn.ctextmax = SizeOf (EnvironStringValue)
            Case IDC_GRD_USERPATH
                clmn.ctype    = TYPE_BUTTON
                clmn.ctextmax = SizeOf (EnvironPathValue)
            Case IDC_GRD_PATH
                clmn.ctype    = TYPE_BUTTON
                clmn.ctextmax = SizeOf (EnvironPathValue)
            End Select

            clmn.colwt       = 320
            clmn.lpszhdrtext = @"Value"
            SendMessage hGrd, GM_ADDCOL, 0, Cast (LPARAM, @clmn)
        Next

        ' fill grid: ReadOnly
        row(0) = @"WORKING_PATH"
        row(1) = @FileSpec
        GetCurrentDirectory SizeOf (FileSpec), @FileSpec
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"FBE_PATH"
        row(1) = @ad.AppPath
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"CURRTAB_BNAME"
        row(1) = @ad.filename
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"MAIN_BNAME"
        row(1) = GetProjectFileName (nMain, PT_RELATIVE)
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"MAIN_RES_BNAME"
        row(1) = StrPtr(Type<String>(GetProjectMainResource ()))
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"COMPILIN_BNAME"
        row(1) = NULL                 ' updated by MakeBuild on every call
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"BUILD_TYPE"
        row(1) = NULL                 ' updated by MakeBuild on every call
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"CARET_WORD"
        row(1) = NULL
        If ah.hred then
            EditorMode = GetWindowLong (ah.hred, GWL_ID)
            If EditorMode = IDC_CODEED _
                OrElse EditorMode = IDC_TEXTED Then
                SendMessage ah.hred, REM_GETWORD, SizeOf (EnvironStringValue), Cast (LPARAM, @buff)
                row(1) = @buff
            EndIf
        EndIf
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        ' fill grid: Path
        For i = 1 To UBound (EnvPaths)
            GetPrivateProfileString @"EnvironPath", EnvPaths(i), NULL, @EPathValue, SizeOf (EPathValue), @ad.IniFile
            'If EPathValue[0] Then
            row(0) = @EnvPaths(i)
            row(1) = @EPathValue
            SendDlgItemMessage hWin, IDC_GRD_PATH, GM_ADDROW, 0, Cast (LPARAM, @row(0))
            'EndIf
        Next

        ' fill grid: UserPath
        GetPrivateProfileSection "EnvironUserPath", @SectionBuffer, SizeOf (SectionBuffer), ad.IniFile
        i = 0
        Do
            DePackStr i, @SectionBuffer, row(0)
            SplitStr *row(0), Asc ("="), row(1)
            SendDlgItemMessage hWin, IDC_GRD_USERPATH, GM_ADDROW, 0, Cast (LPARAM, @row(0))
        Loop While i

        ' fill grid: UserString
        GetPrivateProfileSection "EnvironUserString", @SectionBuffer, SizeOf (SectionBuffer), ad.IniFile
        i = 0
        Do
            DePackStr i, @SectionBuffer, row(0)
            SplitStr *row(0), Asc ("="), row(1)
            SendDlgItemMessage hWin, IDC_GRD_USERSTRING, GM_ADDROW, 0, Cast (LPARAM, @row(0))
        Loop While i

    Case WM_CLOSE
        GetWindowRect hWin, @DlgRect
        SaveToIni @"Win", @"EnvironDlgPos", "4444", @DlgRect, FALSE
        EndDialog hWin, 0

    Case WM_COMMAND
        Select Case LoWord (wParam)
        Case IDC_BTN_OK
            hGrdPath = GetDlgItem (hWin, IDC_GRD_PATH)
            RowCol = SendMessage (hGrdPath, GM_GETCURSEL, 0, 0)
            SendMessage hGrdPath, GM_ENDEDIT, RowCol, FALSE
            n = SendMessage (hGrdPath, GM_GETROWCOUNT, 0, 0)
            For i = 0 To n - 1
                SendMessage hGrdPath, GM_GETCELLDATA, MAKEWPARAM (0, i), Cast (LPARAM, @EName)
                SendMessage hGrdPath, GM_GETCELLDATA, MAKEWPARAM (1, i), Cast (LPARAM, @EPathValue)
                WritePrivateProfileString "EnvironPath", @EName, @EPathValue, ad.IniFile

                Select Case EName
                Case "HELP_PATH"      :  ad.HelpPath       = EPathValue
                Case "FBC_PATH"       :  ad.fbcPath        = EPathValue
                Case "FBCINC_PATH"    :  ad.FbcIncPath     = EPathValue
                Case "FBCLIB_PATH"    :  ad.FbcLibPath     = EPathValue
                Case "PROJECTS_PATH"  :  ad.DefProjectPath = EPathValue
                End Select
            Next

            hGrdUserPath = GetDlgItem (hWin, IDC_GRD_USERPATH)
            RowCol = SendMessage (hGrdUserPath, GM_GETCURSEL, 0, 0)
            SendMessage hGrdUserPath, GM_ENDEDIT, RowCol, FALSE
            WritePrivateProfileSection "EnvironUserPath", !"\0", ad.IniFile        'remove all keys
            n = SendMessage (hGrdUserPath, GM_GETROWCOUNT, 0, 0)
            For i = 0 To n - 1
                SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (0, i), Cast (LPARAM, @EName)
                If IsZStrNotEmpty (EName) Then
                    SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (1, i), Cast (LPARAM, @EPathValue)
                    WritePrivateProfileString "EnvironUserPath", @EName, @EPathValue, ad.IniFile
                EndIf
            Next

            hGrdUserString = GetDlgItem (hWin, IDC_GRD_USERSTRING)
            RowCol = SendMessage (hGrdUserString, GM_GETCURSEL, 0, 0)
            SendMessage hGrdUserString, GM_ENDEDIT, RowCol, FALSE
            WritePrivateProfileSection "EnvironUserString", !"\0", ad.IniFile      'remove all keys
            n = SendMessage (hGrdUserString, GM_GETROWCOUNT, 0, 0)
            For i = 0 To n - 1
                SendMessage hGrdUserString, GM_GETCELLDATA, MAKEWPARAM (0, i), Cast (LPARAM, @EName)
                If IsZStrNotEmpty (EName) Then
                    SendMessage hGrdUserString, GM_GETCELLDATA, MAKEWPARAM (1, i), Cast (LPARAM, @EStringValue)
                    WritePrivateProfileString "EnvironUserString", @EName, @EStringValue, ad.IniFile
                EndIf
            Next
            SendMessage hWin, WM_CLOSE, 0, 0

        Case IDC_BTN_CANCEL
            hGrdUserPath = GetDlgItem (hWin, IDC_GRD_USERPATH)
            SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (1, 0), Cast (LPARAM, @buff)
            SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (1, 1), Cast (LPARAM, @buff)
            SendMessage hWin, WM_CLOSE, 0, 0

        Case IDC_BTN_ADD_USERPATH
            row(0) = NULL
            row(1) = NULL
            SendDlgItemMessage hWin, IDC_GRD_USERPATH, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        Case IDC_BTN_DEL_USERPATH
            CurrRow = SendDlgItemMessage (hWin, IDC_GRD_USERPATH, GM_GETCURROW, 0, 0)
            SendDlgItemMessage hWin, IDC_GRD_USERPATH, GM_DELROW, CurrRow, 0

        Case IDC_BTN_ADD_USERSTRING
            row(0) = NULL
            row(1) = NULL
            SendDlgItemMessage hWin, IDC_GRD_USERSTRING, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        Case IDC_BTN_DEL_USERSTRING
            CurrRow = SendDlgItemMessage (hWin, IDC_GRD_USERSTRING, GM_GETCURROW, 0, 0)
            SendDlgItemMessage hWin, IDC_GRD_USERSTRING, GM_DELROW, CurrRow, 0
        End Select

    Case WM_NOTIFY
        #Define pGRIDNOTIFY     Cast (GRIDNOTIFY Ptr, lParam)
        hGrdPath       = GetDlgItem (hWin, IDC_GRD_PATH)
        hGrdUserPath   = GetDlgItem (hWin, IDC_GRD_USERPATH)
        hGrdReadOnly   = GetDlgItem (hWin, IDC_GRD_READONLY)
        hGrdUserString = GetDlgItem (hWin, IDC_GRD_USERSTRING)

        Select Case pGRIDNOTIFY->nmhdr.hwndFrom
        Case hGrdPath
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdPath, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_BUTTONCLICK
                bri.hwndOwner = hWin
                bri.ulFlags   = BIF_RETURNONLYFSDIRS Or BIF_BROWSEINCLUDEFILES Or BIF_NEWDIALOGSTYLE         ' Or BIF_EDITBOX
                bri.lpfn      = @BrowseForFolderCallBack
                bri.lParam    = Cast (LPARAM, pGRIDNOTIFY->lpdata)  'browsing starts here
                pPIDL = SHBrowseForFolder (@bri)
                If pPIDL Then
                    SHGetPathFromIDList(pPIDL, Cast (ZString Ptr, pGRIDNOTIFY->lpdata))
                    CoTaskMemFree Cast (PVOID, pPIDL)
                EndIf
            Case GN_BEFOREEDIT
                Select Case pGRIDNOTIFY->col
                Case 0
                    pGRIDNOTIFY->fcancel = TRUE                     ' read only
                End Select
            End Select

        Case hGrdUserPath
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdUserPath, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_BUTTONCLICK
                bri.hwndOwner = hWin
                bri.ulFlags   = BIF_RETURNONLYFSDIRS Or BIF_BROWSEINCLUDEFILES Or BIF_NEWDIALOGSTYLE         ' Or BIF_EDITBOX
                bri.lpfn      = @BrowseForFolderCallBack
                bri.lParam    = Cast (LPARAM, pGRIDNOTIFY->lpdata)  'browsing starts here
                pPIDL = SHBrowseForFolder (@bri)
                If pPIDL Then
                    SHGetPathFromIDList(pPIDL, Cast (ZString Ptr, pGRIDNOTIFY->lpdata))
                    CoTaskMemFree Cast (PVOID, pPIDL)
                EndIf
            Case GN_AFTEREDIT
                Select Case pGRIDNOTIFY->col
                Case 0
                    TrimWhiteSpace *Cast (ZString Ptr, pGRIDNOTIFY->lpdata)
                    ZStrReplaceChar pGRIDNOTIFY->lpdata, Asc ("="), Asc ("*")
                End Select
            End Select

        Case hGrdReadOnly
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdReadOnly, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_BEFOREEDIT
                pGRIDNOTIFY->fcancel = TRUE                         ' read only
            End Select

        Case hGrdUserString
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdUserString, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_AFTEREDIT
                Select Case pGRIDNOTIFY->col
                Case 0
                    TrimWhiteSpace *Cast (ZString Ptr, pGRIDNOTIFY->lpdata)
                    ZStrReplaceChar pGRIDNOTIFY->lpdata, Asc ("="), Asc ("*")
                End Select
            End Select
        End Select
        #Undef  pGRIDNOTIFY

    Case WM_WINDOWPOSCHANGING
        If Cast (WINDOWPOS Ptr, lParam)->CY < InitGeoCtl(IDD_DLG_ENVIRON).H Then
            Cast (WINDOWPOS Ptr, lParam)->CY = InitGeoCtl(IDD_DLG_ENVIRON).H
        EndIf

        If Cast (WINDOWPOS Ptr, lParam)->CX < InitGeoCtl(IDD_DLG_ENVIRON).W Then
            Cast (WINDOWPOS Ptr, lParam)->CX = InitGeoCtl(IDD_DLG_ENVIRON).W
        EndIf

        Return FALSE

    Case WM_SIZE
        GetClientRect hWin, @DlgRect
        dW    = DlgRect.Right  - InitGeoCtl(IDD_DLG_ENVIRON).W
        dH    = DlgRect.Bottom - InitGeoCtl(IDD_DLG_ENVIRON).H
        dH025 = dH \ 4
        dH050 = dH \ 2
        dH075 = dH * 3 \ 4

        ' ok / cancel
        hDlgItem = GetDlgItem (hWin, IDC_BTN_OK)
        With InitGeoCtl(IDC_BTN_OK)
            SetWindowPos hDlgItem, 0, .L + dW, .T + dH, 0, 0, SWP_NOSIZE Or SWP_NOZORDER   ' DLG coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_BTN_CANCEL)
        With InitGeoCtl(IDC_BTN_CANCEL)
            SetWindowPos hDlgItem, 0, .L + dW, .T + dH, 0, 0, SWP_NOSIZE Or SWP_NOZORDER   ' DLG coords
        End With


        ' grids
        hDlgItem = GetDlgItem (hWin, IDC_GRD_READONLY)
        With InitGeoCtl(IDC_GRD_READONLY)
            SetWindowPos hDlgItem, 0, .L, .T, .W + dW, .H + dH025, SWP_NOZORDER            ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_GRD_PATH)
        With InitGeoCtl(IDC_GRD_PATH)
            SetWindowPos hDlgItem, 0, .L, .T + dH025, .W + dW, .H + dH025, SWP_NOZORDER    ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_GRD_USERPATH)
        With InitGeoCtl(IDC_GRD_USERPATH)
            SetWindowPos hDlgItem, 0, .L, .T + dH050, .W + dW, .H + dH025, SWP_NOZORDER    ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_GRD_USERSTRING)
        With InitGeoCtl(IDC_GRD_USERSTRING)
            SetWindowPos hDlgItem, 0, .L, .T + dH075, .W + dW, .H + dH025, SWP_NOZORDER    ' DLG Coords
        End With


        ' statics
        hDlgItem = GetDlgItem (hWin, IDC_STC_READONLY)
        With InitGeoCtl(IDC_STC_READONLY)
            SetWindowPos hDlgItem, 0, .L, .T, 0, 0, SWP_NOSIZE Or SWP_NOZORDER             ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_STC_PATH)
        With InitGeoCtl(IDC_STC_PATH)
            SetWindowPos hDlgItem, 0, .L, .T + dH025, 0, 0, SWP_NOSIZE Or SWP_NOZORDER     ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_STC_USERPATH)
        With InitGeoCtl(IDC_STC_USERPATH)
            SetWindowPos hDlgItem, 0, .L, .T + dH050, 0, 0, SWP_NOSIZE Or SWP_NOZORDER     ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_STC_USERSTRING)
        With InitGeoCtl(IDC_STC_USERSTRING)
            SetWindowPos hDlgItem, 0, .L, .T + dH075, 0, 0, SWP_NOSIZE Or SWP_NOZORDER     ' DLG Coords
        End With


        ' adds / dels
        hDlgItem = GetDlgItem (hWin, IDC_BTN_DEL_USERPATH)
        With InitGeoCtl(IDC_BTN_DEL_USERPATH)
            SetWindowPos hDlgItem, 0, .L + dW, .T + dH050, 0, 0, SWP_NOSIZE Or SWP_NOZORDER ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_BTN_DEL_USERSTRING)
        With InitGeoCtl(IDC_BTN_DEL_USERSTRING)
            SetWindowPos hDlgItem, 0, .L + dW, .T + dH075, 0, 0, SWP_NOSIZE Or SWP_NOZORDER ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_BTN_ADD_USERPATH)
        With InitGeoCtl(IDC_BTN_ADD_USERPATH)
            SetWindowPos hDlgItem, 0, .L + dW, .T + dH050, 0, 0, SWP_NOSIZE Or SWP_NOZORDER ' DLG Coords
        End With

        hDlgItem = GetDlgItem (hWin, IDC_BTN_ADD_USERSTRING)
        With InitGeoCtl(IDC_BTN_ADD_USERSTRING)
            SetWindowPos hDlgItem, 0, .L + dW, .T + dH075, 0, 0, SWP_NOSIZE Or SWP_NOZORDER ' DLG Coords
        End With
        Return FALSE

    Case Else
        Return FALSE

    End Select

    Return TRUE
End Function

Function ExpandStrByEnviron (ByRef Source As ZString, ByVal SourceSize As Integer, ByVal MaxAttempt As Integer = 5) As BOOL

    ' Source     [in]
    ' SourceSize [in]

    ' expands substrings like %var% with values defined in environment
    ' substitution is done inplace
    ' MaxAttempt limits forwarding e.g. greeting=%var1%, %var2%
    '                                   var1=hello
    '                                   var2=%target%
    '                                   target=world

    Dim i    As Integer             = Any
    Dim Dest As ZString * 32 * 1024

    For i = 1 To MaxAttempt
        ExpandEnvironmentStrings @Source, @Dest, SizeOf (Dest)

        If Dest = Source Then
            Return TRUE
        Else
            If lstrcpyn (@Source, @Dest, SourceSize) = NULL Then                ' Source = Dest
                Return FALSE
            EndIf
        EndIf
    Next

    Return FALSE                 ' too much levels
End Function

Sub UpdateEnvironment

    Dim i              As Integer             = Any
    Dim EPathValue     As EnvironPathValue
    Dim EStringValue   As EnvironStringValue
    Dim EItem          As EnvironItem                      ' containing: "Var=Value"
    Dim pEnvironBlock  As LPTCH               = Any
    Dim EditorMode     As Long                = Any
    Dim SectionBuffer  As ZString * 64 * 1024
    Dim FileSpec       As ZString * MAX_PATH
    Dim pBuff          As ZString Ptr         = Any
    Dim pBuffB         As ZString Ptr         = Any
    Dim Success        As BOOL                = Any

    ' Path
    For i = 1 To UBound (EnvPaths)
        GetPrivateProfileString @"EnvironPath", EnvPaths(i), NULL, @EPathValue, SizeOf (EPathValue), @ad.IniFile
        If EPathValue[0] Then
            SetEnvironmentVariable @EnvPaths(i), @EPathValue
        EndIf
    Next

    ' ReadOnly
    SetEnvironmentVariable @"FBE_PATH", @ad.AppPath
    SetEnvironmentVariable @"CURRTAB_BNAME", @ad.filename
    SetEnvironmentVariable @"MAIN_BNAME", GetProjectFileName (nMain, PT_RELATIVE)
    SetEnvironmentVariable @"MAIN_RES_BNAME", StrPtr(Type<String>(GetProjectMainResource ()))
    SetEnvironmentVariable @"COMPILIN_BNAME", @""               ' updated by MakeBuild on every call
    SetEnvironmentVariable @"BUILD_TYPE", @""                   ' updated by MakeBuild on every call
    GetCurrentDirectory SizeOf (FileSpec), @FileSpec
    SetEnvironmentVariable @"WORKING_PATH", @FileSpec

    SetZStrEmpty (EStringValue)
    If ah.hred then
        EditorMode = GetWindowLong (ah.hred, GWL_ID)
        If EditorMode = IDC_CODEED _
            OrElse EditorMode = IDC_TEXTED Then
            SendMessage ah.hred, REM_GETWORD, SizeOf (EStringValue), Cast (LPARAM, @EStringValue)
        EndIf
    EndIf
    SetEnvironmentVariable @"CARET_WORD", @EStringValue

    ' UserPath
    GetPrivateProfileSection @"EnvironUserPath", @SectionBuffer, SizeOf (SectionBuffer), @ad.IniFile
    i = 0
    Do
        DePackStr i, @SectionBuffer, pBuff
        SplitStr *pBuff, Asc ("="), pBuffB
        SetEnvironmentVariable pBuff, pBuffB
    Loop While i

    ' UserString
    GetPrivateProfileSection @"EnvironUserString", @SectionBuffer, SizeOf (SectionBuffer), @ad.IniFile
    i = 0
    Do
        DePackStr i, @SectionBuffer, pBuff
        SplitStr *pBuff, Asc ("="), pBuffB
        SetEnvironmentVariable pBuff, pBuffB
    Loop While i

    ' resolve references / backreferences
    pEnvironBlock = GetEnvironmentStrings ()
    i = 0
    Do
        DePackStr i, *Cast (ZString Ptr, pEnvironBlock), EItem, SizeOf (EItem)   ' get copies, EnvironBlock is Const
        SplitStr EItem, Asc ("="), pBuffB
        Success = ExpandStrByEnviron (*pBuffB, SizeOf (EItem) + @EItem - pBuffB)         ' but we wanna expand
        If Success Then
            SetEnvironmentVariable EItem, pBuffB
        ' Else
            ' cant expand this, leave untouched
        EndIf
    Loop While i
    FreeEnvironmentStrings pEnvironBlock

End Sub
