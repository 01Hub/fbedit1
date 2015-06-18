
on error resume next

Set Shell  = CreateObject("wscript.Shell")
Set FSO    = CreateObject("Scripting.FileSystemObject")
Set RevO   = CreateObject("SubWCRev.object")
Set StdOut = FSO.GetStandardStream(1)

quote = Chr(34)


Exe7z = "C:\Program Files\7-Zip\7z.exe"

RevO.GetWCInfo FSO.GetAbsolutePathName ("."), 0, 0
Revision = RevO.Revision

StdOut.WriteLine "packing revision: " + cstr (Revision)

FSO.DeleteFile "Package\*.7z"

Shell.Run quote + Exe7z + quote + " a Package\FbEditMod_Rev" + cstr (Revision) + "  .\Build\* -mx",1 , true


Set Shell = Nothing
Set FSO   = Nothing
Set RevO  = Nothing

