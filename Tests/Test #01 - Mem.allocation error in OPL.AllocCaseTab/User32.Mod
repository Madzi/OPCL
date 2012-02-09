MODULE User32;

IMPORT
  SYSTEM, Kernel32;

CONST
  WMDestroy* = 02H;
  WMKeyDown* = 0100H;
  SWShow*    = 5;
  SWShowMaximized* = 3;

  WSMaximizeBox* = 16;
  WSMinimizeBox* = 17;
  WSThickFrame* = 18;
  WSSysMenu* = 19;
  WSBorder* = 23;
		WSMaximize* = 24;
		WSVisible* = 28;
		WSMinimize* = 29;
		WSChild* = 30;

  
TYPE
		HWND* = Kernel32.HANDLE;
		HDC* = Kernel32.HANDLE;
		HGDIObj* = Kernel32.HANDLE;
		HFont* = HGDIObj;
		HBrush* = HGDIObj;
		HRgn* = HGDIObj;
		HBitmap* = HGDIObj;
		HIcon* = Kernel32.HANDLE;
		HCursor* = Kernel32.HANDLE;
		HMenu* = Kernel32.HANDLE;
		HPalette* = Kernel32.HANDLE;
		HAccel* = Kernel32.HANDLE;
		HHook* = Kernel32.HANDLE;

  Point* = RECORD
			 x*, y*: LONGINT
		END;

  Msg* = RECORD [NOTAG]
    hwnd*: HWND;
    message*: LONGINT;
    wParam*, lParam*: LONGINT;
    time*: LONGINT;
    point*: Point;
		END;

		WParam* = LONGINT;
		LParam* = LONGINT;
		LResult* = LONGINT;

  WndProc* = PROCEDURE [WINAPI] (hwnd: HWND; uMsg: LONGINT; wParam: WParam; lParam: LParam): LResult;

		WndClassEx* = RECORD [NOTAG]
    cbSize*: LONGINT;
    style*: SET;
    lpfnWndProc*: WndProc;
    cbClsExtra*, cbWndExtra*: LONGINT;
    hInstance*: Kernel32.HINSTANCE;
    hIcon*: HIcon;
    hCursor*: HCursor;
    hbrBackground*: HBrush;
    lpszMenuName*, lpszClassName*: Kernel32.LPSTR;
    hIconSm*: HIcon;
		END;

VAR
  PostQuitMessage-: PROCEDURE [WINAPI] (nExitCode: LONGINT);  
  LoadIcon-: PROCEDURE [WINAPI] (hInstance: Kernel32.HINSTANCE; VAR lpIconName: ARRAY [NOTAG] OF CHAR):HIcon;
  CreateWindowEx-: PROCEDURE [WINAPI] (dwExStyle: LONGINT; VAR lpClassName, lpWindowName: ARRAY [NOTAG] OF CHAR; dwStyle: SET; x, y, nWidth, nHeight: LONGINT; hWndParent: HWND; hMenu: HMenu; hInstance: Kernel32.HINSTANCE; lpParam: LONGINT): HWND;
		ShowWindow-: PROCEDURE [WINAPI] (hWnd: HWND; nCmdShow: LONGINT): Kernel32.BOOL;
  UnregisterClass-: PROCEDURE [WINAPI] (VAR lpClassName: ARRAY [NOTAG] OF CHAR; hInstance: Kernel32.HINSTANCE): Kernel32.BOOL;
  RegisterClassEx-: PROCEDURE [WINAPI] (VAR lpwcx: WndClassEx): Kernel32.ATOM;
  GetMessage-: PROCEDURE [WINAPI] (VAR lpMsg: Msg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax: LONGINT): LONGINT;
  TranslateMessage-: PROCEDURE [WINAPI] (VAR lpMsg: Msg): Kernel32.BOOL;
  DispatchMessage-: PROCEDURE [WINAPI] (VAR lpMsg: Msg): LONGINT;
  DefWindowProc-: WndProc;
  UpdateWindow-: PROCEDURE [WINAPI] (hWnd: HWND): Kernel32.BOOL;
		


PROCEDURE Init;
VAR
  mod: Kernel32.HMODULE;
  str: ARRAY 32 OF CHAR;
BEGIN
  str := "USER32.DLL";
  mod := Kernel32.LoadLibrary(str);
  Kernel32.GetProcAddress(mod, "CreateWindowExA", SYSTEM.VAL(LONGINT,CreateWindowEx ));
  Kernel32.GetProcAddress(mod, "DefWindowProcA", SYSTEM.VAL(LONGINT,DefWindowProc ));
  Kernel32.GetProcAddress(mod, "DispatchMessageA", SYSTEM.VAL(LONGINT,DispatchMessage ));
  Kernel32.GetProcAddress(mod, "GetMessageA", SYSTEM.VAL(LONGINT,GetMessage ));
  Kernel32.GetProcAddress(mod, "LoadIconA", SYSTEM.VAL(LONGINT,LoadIcon ));
  Kernel32.GetProcAddress(mod, "PostQuitMessage", SYSTEM.VAL(LONGINT,PostQuitMessage ));
  Kernel32.GetProcAddress(mod, "RegisterClassExA", SYSTEM.VAL(LONGINT,RegisterClassEx ));
  Kernel32.GetProcAddress(mod, "ShowWindow", SYSTEM.VAL(LONGINT,ShowWindow ));
  Kernel32.GetProcAddress(mod, "TranslateMessage", SYSTEM.VAL(LONGINT,TranslateMessage ));
  Kernel32.GetProcAddress(mod, "UnregisterClassA", SYSTEM.VAL(LONGINT,UnregisterClass ));
  Kernel32.GetProcAddress(mod, "UpdateWindow", SYSTEM.VAL(LONGINT,UpdateWindow ));
END Init;

BEGIN
  Init;
END User32.
