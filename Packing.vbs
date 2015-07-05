



' --> execute with cscript.exe


'on error resume next

Set Shell  = CreateObject("wscript.Shell")
Set FSO    = CreateObject("Scripting.FileSystemObject")
Set RevO   = CreateObject("SubWCRev.object")
Set StdOut = FSO.GetStandardStream(1)

quote = Chr(34)
Exe7z = "C:\Program Files\7-Zip\7z.exe"


' get SVN revision about this path 
WorkingDir = FSO.GetAbsolutePathName (".")
RevO.GetWCInfo WorkingDir, 0, 0
PackageSpec = WorkingDir + "\Package\FbEditMod_Rev" + cstr (RevO.Revision) + ".7z"


' delete package if existing - dont append 
If FSO.FileExists (PackageSpec) = true Then
    StdOut.WriteLine "deleting existing package: " + PackageSpec
	FSO.DeleteFile PackageSpec
Else
    StdOut.WriteLine "old package not found"        
End If 


StdOut.WriteLine "packing: " + PackageSpec
Set OExec = Shell.Exec (quote + Exe7z + quote + " a " + quote + PackageSpec + quote + " .\Build\* -mx")

Do
   wscript.Sleep 100
   StdOut.Write OExec.StdOut.ReadAll()
   StdOut.Write OExec.StdErr.ReadAll()
Loop Until OExec.Status

StdOut.WriteLine "READY"

Set Shell = Nothing
Set FSO   = Nothing
Set RevO  = Nothing

