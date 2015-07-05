

' module compile with: -gen gcc -O2

#Include Once "windows.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\ZStringHandling.bi"


Function InZStr (ByRef i As Integer, ByRef Source As ZString, ByRef Find As ZString) As Integer

    Dim n As Integer = Any

    If i < 0 OrElse i > lstrlen (Source) Then Return -1

    n = 0
	Do
		Select Case Source[i]
		Case Find[n]
			n += 1	
			If Find[n] Then
				i += 1
			Else
				Return i - n + 1	
			EndIf
		Case 0
			Return -1	
		Case Else
		    If n Then
		    	i = i - n + 1
		    	n = 0
		    Else
		    	i += 1
		    EndIf 	
		End Select
	Loop	

End Function

Sub RemoveWhiteSpace (ByRef Work As ZString)

    Dim i As Integer = 0
    Dim k As Integer = 0

    Do
        Select Case Work[i]
        Case Asc(!"\t"), Asc(" ")
            i += 1

        Case 0
            Work[k] = 0
            Exit Do

        Case Else
            Work[k] = Work[i]
            i += 1
            k += 1
        End Select
    Loop

End Sub

Sub TrimWhiteSpace (ByRef Work As ZString)

    Dim i As Integer = 0
    Dim k As Integer = 0
    Dim e As Integer = 0

    Do
        Select Case Work[i]
        Case Asc(!"\t"), Asc(" ")
            If k = 0 Then
                i += 1
            Else
                Work[k] = Work[i]
                i += 1
                k += 1
            EndIf

        Case 0
            Work[e] = 0
            Exit Do

        Case Else
            Work[k] = Work[i]
            i += 1
            k += 1
            e = k         ' end of string, if WS following
        End Select
    Loop

End Sub

Sub GetEnclosedStrRev (ByRef i As Integer, ByRef Source As ZString, ByRef Dest As ZString, ByVal StartDelimiter As UByte, ByVal EndDelimiter As UByte)

    ' [in]  i = start of search (zerobased)
    ' [out] i = -1 : nothing found
    '       i = 0  : something found, subsequent search not necessary
    '       i > 0  : something found, subsequent searches possible

    Dim n As Integer = 0
    Dim k As Integer = Any

    Do                            ' search EndDelimiter
        If i < 0 Then
            Dest[0] = 0
            Exit Sub
        EndIf

        Select Case Source[i]
        Case EndDelimiter
            i -= 1
            Exit Do
        Case Else
            i -= 1
        End Select
    Loop

    Do                            ' search StartDelimiter
        If i < 0 Then
            Dest[0] = 0
            Exit Sub
        EndIf

        Select Case Source[i]
        Case StartDelimiter
            k = i + 1
            If i > 0 Then i -= 1
            Exit Do
        Case Else
            i -= 1
        End Select
    Loop

    Do                            ' make copy
        Select Case Source[k]
        Case EndDelimiter
            Dest[n] = 0
            Exit Do
        Case Else
            Dest[n] = Source[k]
            k += 1
            n += 1
        End Select
    Loop

End Sub

Sub GetEnclosedStr OverLoad (ByRef i As Integer, ByRef Source As ZString, ByRef Dest As ZString, ByVal DestSize As Integer, Byref StartDelimiter As ZString, Byref EndDelimiter As ZString)

    ' various delimiters
    ' [in]  i = start of search (zerobased)
    ' [out] i = 0  : nothing found   (hardlimit reached)
    '       i > 0  : something found (delimiter reached)
    '                subsequent searches possible, starting at i
    ' Dest is truncated to DestSize
    ' Source / Dest can share same address

    Dim StartDelimTab(0 To 255) As UByte
    Dim EndDelimTab(0 To 255)   As UByte
    Dim n                       As Integer = Any
    Dim nmax                    As Integer = DestSize - 1

    n = 0
    Do           ' set chartab 1
        Select Case StartDelimiter[n]
        Case 0
            Exit Do
        Case Else
            StartDelimTab(StartDelimiter[n]) = TRUE
        End Select
        n += 1
    Loop

    n = 0
    Do           ' set chartab 2
        Select Case EndDelimiter[n]
        Case 0
            Exit Do
        Case Else
            EndDelimTab(EndDelimiter[n]) = TRUE
        End Select
        n += 1
    Loop

    Do           ' search start
        If Source[i] Then
            If StartDelimTab(Source[i]) Then
                i += 1
                Exit Do
            Else
                i += 1
            EndIf
        Else
            Dest[0] = 0
            i = 0
            Exit Sub
        EndIf
    Loop

    n = 0
    Do             ' copy enclosed string
        If Source[i] Then
            If EndDelimTab(Source[i]) Then
                Dest[n] = 0
                i += 1
                Exit Sub
            Else
                If n < nmax Then
                	Dest[n] = Source[i]
                	i += 1
                	n += 1
        		Else
                	Dest[nmax] = 0
                	i += 1
                EndIf
            EndIf
        Else
            Dest[0] = 0
            i = 0
            Exit Sub
        EndIf
    Loop

End Sub

Sub GetEnclosedStr OverLoad (ByRef i As Integer, ByRef Source As ZString, ByRef Dest As ZString, ByVal DestSize As Integer, ByVal StartDelimiter As UByte, ByVal EndDelimiter As UByte)

    ' single delimiter
    ' [in]  i = start of search (zerobased)
    ' [out] i = 0  : nothing found   (hardlimit reached)
    '       i > 0  : something found (delimiter reached)
    '                subsequent searches possible, starting at i
    ' Dest is truncated to DestSize
    ' Source / Dest can share same address

    Dim n    As Integer = 0
    Dim nmax As Integer = DestSize - 1

    Do
        Select Case Source[i]
        Case StartDelimiter
            i += 1
            Exit Do
        Case 0             ' hard limit
            Dest[0] = 0
            i = 0
            Exit Sub
        Case Else
            i += 1
        End Select
    Loop

    Do
        Select Case Source[i]
        Case EndDelimiter
            Dest[n] = 0
            i += 1
            Exit Do
        Case 0             ' hard limit
            Dest[0] = 0
            i = 0
            Exit Sub
        Case Else
            If n < nmax Then
            	Dest[n] = Source[i]
            	i += 1
            	n += 1
    		Else
            	Dest[nmax] = 0
            	i += 1
            EndIf
        End Select
    Loop

End Sub

Sub GetSubStr OverLoad (ByRef i As Integer, ByRef Source As ZString, ByRef Dest As ZString, ByVal DestSize As Integer, ByRef Delimiter As ZString)

    ' for set of delimiters
    ' [in]  i = start of search (zerobased)
    ' [out] i = 0  : subsequent search not necessary               (hardlimit was found)
    '       i > 0  : subsequent searches possible, starting at i   (delimiter was found)
    ' Dest is truncated to DestSize
    ' Source / Dest can share same address

    Dim n    As Integer = 0
    Dim nmax As Integer = DestSize - 1
    Dim k    As Integer = Any

    Do
        k = 0
        Do While Delimiter[k]

            Select Case Source[i]
            Case 0
                Dest[n] = 0
                i = 0
                Exit Sub

            Case Delimiter[k]
                Dest[n] = 0
                i += 1
                Exit Sub
            End Select
            k += 1
        Loop

        If n < nmax Then
        	Dest[n] = Source[i]
        	i += 1
        	n += 1
		Else
        	Dest[nmax] = 0
        	i += 1
        EndIf
    Loop

End Sub

Sub GetSubStr OverLoad (ByRef i As Integer, ByRef Source As ZString, ByRef Dest As ZString, ByVal DestSize As Integer, ByVal Delimiter As UByte)

    ' for single delimiter <> NULL
    ' [in]  i = start of search (zerobased)
    ' [out] i = 0  : subsequent search not necessary               (hardlimit was found)
    '       i > 0  : subsequent searches possible, starting at i   (delimiter was found)
    ' Dest is truncated to DestSize
    ' Source / Dest can share same address

    Dim n    As Integer = 0
    Dim nmax As Integer = DestSize - 1

    Do
        Select Case Source[i]
        Case 0             ' hard limit
            Dest[n] = 0
            i = 0
            Exit Do
        Case Delimiter     ' soft limit
            Dest[n] = 0
            i += 1
            Exit Do
        Case Else
            If n < nmax Then
            	Dest[n] = Source[i]
            	i += 1
            	n += 1
            Else
            	Dest[nmax]=0
                i += 1
            EndIf     	
        End Select
    Loop
End Sub

Sub DePackStr OverLoad (ByRef i As Integer, ByRef Source As ZString, ByRef Dest As ZString, ByVal DestSize As Integer)

    ' depacking packed array (COPYING):        string1<NULL>string2<NULL>string3<NULL><NULL>

    ' [in]  i = start of search (zerobased)
    ' [out] i = 0  : subsequent search not necessary               (NULL, NULL was found)
    '       i > 0  : subsequent searches possible, starting at i   (NULL was found)
    ' Dest is truncated to DestSize
    ' Source / Dest can share same address

    Dim n    As Integer = 0
    Dim nmax As Integer = DestSize - 1

    Do
        Select Case Source[i]
        Case 0             ' hard limit
            Dest[n] = 0
            If Source[i + 1] = 0 Then
                i = 0
            Else
                i += 1
            EndIf
            Exit Do
        Case Else
            If n < nmax Then
            	Dest[n] = Source[i]
            	i += 1
            	n += 1
            Else
            	Dest[nmax]=0
                i += 1
            EndIf     	
        End Select
    Loop

End Sub

Sub DePackStr OverLoad (ByRef i As Integer, Byval pSource As ZString Ptr, ByRef pDest As ZString Ptr)

    ' depacking packed array (NO COPY):        string1<NULL>string2<NULL>string3<NULL><NULL>

    ' [in]  i = start of search (zerobased)
    ' [out] i = 0  : subsequent search not necessary               (NULL, NULL was found)
    '       i > 0  : subsequent searches possible, starting at i   (NULL was found)

    pDest = pSource + i
    i += lstrlen (pDest) + 1
    If pSource[i] = 0 Then i = 0

End Sub

Sub GetLineFromChar (ByRef Source As ZString, ByVal CharPos As Integer, ByRef Dest As ZString, ByVal DestSize As Integer, ByRef LineCount As Integer)

    ' [in]   CharPos      : any char in line of interest
    ' [out]  LineCount > 0: line number (based 1) belonging to CharPos
    '                  = 0: invalid CharPos

    Dim StrStart As Integer = 0
    Dim i        As Integer = Any

    LineCount = 1

    For i = 0 To CharPos
        Select Case Source[i]
        Case 13        ' CR
            Select Case Source[i + 1]
            Case 10    ' LF
                LineCount += 1
                StrStart = i + 2
            End Select

        Case NULL
            LineCount = 0
            Dest[0] = 0
            Exit Sub
        End Select
    Next

    GetSubStr StrStart, Source, Dest, DestSize, CUByte (13)

End Sub

Sub ReplaceChar1stHit (Byref Source As ZString, ByVal SearchChar As UByte, ByVal ReplaceChar As UByte)

    ' caution: terminating 0 maybe be replaced if SearchChar = 0

    Dim n As Integer = 0

    Do
        Select Case Source[n]
        Case SearchChar
            Source[n] = ReplaceChar
            Exit Sub
        Case 0
            Exit Sub
        End Select

        n += 1
    Loop

End Sub

Sub SplitStr (ByRef Source As ZString, ByVal Delimiter As UByte, ByRef pPartB As ZString Ptr)

    ' [in]  Source   : ZString to be splitted
    ' [out] Source   : left part after split
    ' [out] pPartB   : ptr to right part after split
    ' [in]  Delimiter: single char (removed after split)

    Dim n As Integer = 0

    Do
        Select Case Source[n]
        Case Delimiter
            Source[n] = 0
            pPartB = @Source[n + 1]
            Exit Sub
        Case 0
            pPartB = 0
            Exit Sub
        End Select

        n += 1
    Loop

End Sub

Sub SplitStrQuoted (ByRef Source As ZString, ByVal Delimiter As UByte, ByRef pPartB As ZString Ptr)

    ' [in]  Source   : ZString to be splitted
    ' [out] Source   : left part after split
    ' [out] pPartB   : ptr to right part after split
    ' [in]  Delimiter: single char (removed after split)

    ' quoted substrings are ignored
    ' if there is only one quote, remaining part is completly ignored

    Dim n As Integer = 0

    Do
        Select Case Source[n]
        Case Delimiter
            Source[n] = 0
            pPartB = @Source[n + 1]
            Exit Sub
        Case Asc (!"\"")
            Do                                ' skip quoted part
                n += 1
                Select Case Source[n]
                Case Asc (!"\"")
                    Exit Do
                Case 0
                    pPartB = 0
                    Exit Sub
                End Select
            Loop
        Case 0
            pPartB = 0
            Exit Sub
        End Select

        n += 1
    Loop

End Sub

Sub ZStrReplaceChar (ByVal lpszStr As UByte Ptr, ByVal nByte As UByte, Byval nReplace As UByte)

	Dim i As Integer = Any

    If lpszStr Then
        i = 0
        Do
    	    Select Case lpszStr[i]
    	    Case nByte
    	        lpszStr[i] = nReplace
    	    Case NULL
    	        Exit Sub
    	    End Select	

    	    i += 1
    	Loop
    EndIf

    ' MOD 23.1.2012
    'Sub ZStrReplace(ByVal lpszStr As ZString Ptr,ByVal nByte As Integer,ByVal nReplace As Integer)
    '	Dim i As Integer
    '
    '	For i=0 To Len(*lpszStr)-1
    '		If Asc(lpszStr[i])=nByte Then
    '			lpszStr[i]=nReplace
    '		EndIf
    '	Next
    '
    'End Sub
End Sub

Sub FormatFunctionName (ByRef FuncDescIn As ZString, ByRef FuncDescOut As ZString)

    Dim    n      As Integer        = Any
    Dim    i      As Integer        = Any

    n = 0
    i = 0	
	
	Do                                            ' name of function
	    Select Case FuncDescIn[i]
	    Case 0
	        Exit Do
	    Case Else
	        FuncDescOut[n] = FuncDescIn[i]
	        n += 1
	        i += 1
	    End Select
	Loop
	
	*Cast (UShort Ptr, @FuncDescOut + n) = *Cast (UShort Ptr, @" (")
	n += 2
	i += 1
	
	Do                                            ' param list
	    Select Case FuncDescIn[i]
	    Case 0
	        Exit Do
	    Case Asc (",")
        	*Cast (UShort Ptr, @FuncDescOut + n) = *Cast (UShort Ptr, @", ")
        	n += 2
        	i += 1
	    Case Else
	        FuncDescOut[n] = FuncDescIn[i]
	        n += 1
	        i += 1
	    End Select
	Loop

	*Cast (UShort Ptr, @FuncDescOut + n) = *Cast (UShort Ptr, @") ")
	n += 2
	i += 1
	
	Do                                            ' return value
	    Select Case FuncDescIn[i]
	    Case 0
	        Exit Do
	    Case Else
	        FuncDescOut[n] = FuncDescIn[i]
	        n += 1
	        i += 1
	    End Select
	Loop

    FuncDescOut[n] = 0                            ' terminate zstring

End Sub

Sub ZStrCat Cdecl (ByVal pTarget As ZString Ptr, ByVal TargetSize As Integer, ByVal ArgCount As Integer, ByVal pFirst As ZString Ptr, ...)

    Dim n        As Integer     = Any
    Dim i        As Integer     = Any
    Dim k        As Integer     = Any
    Dim pZString As ZString Ptr = Any

    n = lstrlen (pTarget)
    For k = 0 To ArgCount - 1
        pZString = (@pFirst)[k]

        If pZString Then                              ' skip null pointers
            i = 0
            Do
               If n = TargetSize Then
                    (*pTarget)[n] = 0                 ' prevent buffer overrun
                    Exit Sub
                EndIf

                Select Case (*pZString)[i]
                Case 0
                    (*pTarget)[n] = 0
                    Exit Do
                Case Else
                    (*pTarget)[n] = (*pZString)[i]
                    n += 1
                    i += 1
                End Select
            Loop
        EndIf
    Next

End Sub

Function FormatDEVStr (ByRef Source As ZString, ByVal SourceSize As Integer) As BOOL

    ' DEV Dot Enclosed Value

    Dim n       As Integer = Any
    Dim i       As Integer = Any
    Dim Success As BOOL    = Any


  	WeedOutSpec Source                        ' remove illegal chars from spec
  	CharLower @Source                         ' LCASE p.def.
    Success = EncloseString (Source, SourceSize, Asc("."))
    	
    Return Success

End Function

Sub RemoveChars (Byref Source As ZString, ByRef CharList As ZString)

    ' [in/out]  Source   : null terminated string, from which chars will be removed
    ' [in]      CharList : list of illegal chars, any char in this list will be removed from Source

    Dim IllegalCharTab(0 To 255) As UByte
    Dim n                        As Integer = Any
    Dim i                        As Integer = Any

    n = 0
    Do           ' set chartab
        Select Case CharList[n]
        Case 0
            Exit Do
        Case Else
            IllegalCharTab(CharList[n]) = TRUE
        End Select
        n += 1
    Loop

    i = 0
    n = 0
    Do           ' remove illegal chars
        If Source[i] Then
            If IllegalCharTab(Source[i]) Then
                i += 1
            Else
                Source[n] = Source[i]
                n += 1
                i += 1
            EndIf
        Else
            Source[n] = Source[i]        ' terminating null
            Exit Sub
        EndIf
    Loop

End Sub

Sub KeepChars (ByRef Source As ZString, ByRef CharList As ZString)

    ' [in/out]  Source   : null terminated string, from which chars will be removed
    ' [in]      CharList : list of legal chars, any char NOT in this list will be removed from Source

    Dim LegalCharTab(0 To 255) As UByte
    Dim n                      As Integer = Any
    Dim i                      As Integer = Any

    n = 0
    Do           ' set chartab
        Select Case CharList[n]
        Case 0
            Exit Do
        Case Else
            LegalCharTab(CharList[n]) = TRUE
        End Select
        n += 1
    Loop

    i = 0
    n = 0
    Do           ' remove illegal chars
        If Source[i] Then
            If LegalCharTab(Source[i]) Then
                Source[n] = Source[i]
                n += 1
                i += 1
            Else
                i += 1
            EndIf
        Else
            Source[n] = Source[i]        ' terminating null
            Exit Sub
        EndIf
    Loop

End Sub

Function EncloseString (ByRef Source As ZString, ByVal SourceSize As Integer, ByVal EncloseChar As UByte) As BOOL
    
    ' enclosing a string with a single char
    ' enclosing is done inplace
    ' if source string is enclosed already, nothing will be done
    ' i.e.   source          enclosechar          result
    '        xyz             *                    *xyz*
    '        *xyz            *                    *xyz*
    '        xyz*            *                    *xyz* 
    '
    
    Dim L As Integer = Any

    L = lstrlen (@Source)

    If Source[0] Then
        If Source[0] <> EncloseChar Then
            If L >= SourceSize - 1 Then
                Return FALSE                                  ' string not extensible
            EndIf
            MoveMemory (@Source + 1, @Source, L + 1)          ' shift string in mem, incl. terminating null
            Source[0] = EncloseChar                           ' prefix it
            L += 1
        EndIf
        If (Source[L - 1] <> EncloseChar) OrElse (L = 1) Then ' (L = 1) to preserve prefix
            If L >= SourceSize - 1 Then
                Return FALSE
            EndIf
            Source[L]     = EncloseChar                       ' postfix it
            Source[L + 1] = 0
        EndIf
    Else
        If SourceSize < 3 Then
            Return FALSE
        EndIf
        Source[0] = EncloseChar
        Source[1] = EncloseChar
        Source[2] = 0
    EndIf

    Return TRUE

End Function
