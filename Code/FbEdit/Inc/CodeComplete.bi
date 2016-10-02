

Declare Sub GetItems (ByVal ntype As Integer)
Declare Function FindExact (ByVal lpTypes As ZString Ptr,ByVal lpFind As ZString Ptr,ByVal fMatchCase As WINBOOLEAN) As ZString Ptr
Declare Sub MoveList ()
Declare Sub HideCCLists ()

Declare Function UpdateEnumList (ByVal lpszEnum As ZString Ptr) As WINBOOLEAN
Declare Function UpdateConstList (ByVal lpszApi As ZString Ptr,ByVal npos As Integer) As Integer
Declare Sub UpdateTypeList ()
Declare Sub UpdateStructList (ByVal lpProc As ZString Ptr)
Declare Sub UpdateIncludeList ()
Declare Sub UpdateInclibList ()
Declare Sub UpdateList (ByVal lpProc As ZString Ptr)
Declare Sub IsStructList ()
Declare Sub SetupProperty ()


Extern ftypelist     As WINBOOLEAN
Extern fconstlist    As WINBOOLEAN
Extern fstructlist   As WINBOOLEAN
Extern fmessagelist  As WINBOOLEAN
Extern flocallist    As WINBOOLEAN
Extern fincludelist  As WINBOOLEAN
Extern fincliblist   As WINBOOLEAN
Extern fenumlist     As WINBOOLEAN
Extern sEditFileName As ZString * MAX_PATH
Extern ccpos         As ZString Ptr
Extern ccstring      As ZString * 65536

