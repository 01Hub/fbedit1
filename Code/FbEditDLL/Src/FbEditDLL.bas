
#Include Once "windows.bi"

Extern "Windows" Lib "..\CustomControl\RACodeComplete\Build\RACodeComplete"
    Declare Sub InstallRACodeComplete   (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub UnInstallRACodeComplete ()
End Extern    
    
Extern "Windows" Lib "..\CustomControl\RAFile\Build\RAFile"    
    Declare Sub InstallFileBrowser      (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub UnInstallFileBrowser    ()
End Extern    

Extern "Windows" Lib "..\CustomControl\RAProperty\Build\RAProperty"    
    Declare Sub InstallRAProperty       (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub UnInstallRAProperty     ()
End Extern

Extern "Windows" Lib "..\CustomControl\RAGrid\Build\RAGrid"    
    Declare Sub GridInstall             (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub GridUnInstall           ()
End Extern

Extern "Windows" Lib "..\CustomControl\RAHexEd\Build\RAHexEd"    
    Declare Sub RAHexEdInstall Cdecl    (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub RAHexEdUnInstall        ()
End Extern    
    
Extern "Windows" Lib "..\CustomControl\RAEdit\Build\RAEdit"    
    Declare Sub InstallRAEdit           (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub UnInstallRAEdit         ()
    Declare Function GetCharTabPtr      () As Any Ptr
End Extern

Extern "Windows" Lib "..\CustomControl\RAResEd\Build\RAResEd"    
    Declare Sub ResEdInstall            (ByVal hInst As HINSTANCE, ByVal fGlobal As DWORD)
    Declare Sub ResEdUninstall          ()
End Extern


#Inclib "user32"
#inclib "kernel32"
#Inclib "gdi32"
#Inclib "comctl32"
#Inclib "shell32"
#Inclib "comdlg32"
#Inclib "shlwapi"
#Inclib "ole32"

#LibPath "..\VKDebug\Build" 
#Inclib "VKDebug"
#Inclib "masm32"


Function DllMain (ByVal hInstDLL As HINSTANCE, ByVal fdwReason as DWORD, ByVal lpReserved As LPVOID) As BOOL 

    Select Case fdwReason 
    Case DLL_PROCESS_ATTACH
		InstallRACodeComplete hInstDLL, TRUE
		InstallFileBrowser    hInstDLL, TRUE
		InstallRAProperty     hInstDLL, TRUE
		GridInstall           hInstDLL, TRUE
		RAHexEdInstall        hInstDLL, TRUE
		InstallRAEdit         hInstDLL, TRUE
		ResEdInstall          hInstDLL, TRUE

    Case DLL_PROCESS_DETACH
        UnInstallRACodeComplete
        UnInstallFileBrowser   
        UnInstallRAProperty    
        GridUnInstall          
        RAHexEdUnInstall       
        UnInstallRAEdit        
        ResEdUninstall         
    End Select

    Return TRUE 

End Function


Function RAEdit_GetCharTabPtr () As Any Ptr Export
    Return GetCharTabPtr ()
End Function
