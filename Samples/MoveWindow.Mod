MODULE MoveWindow;

(* Simple moving window application by Alexander Iljin, June 08, 2006. *)
(* Adapted Component Pascal to ETH Oberon by Oleg N. Cher, 2011. *)
(* See: http://oberoncore.ru/wiki/blackbox/make_exe for details. *)

  IMPORT SYSTEM, Kernel32 (* WinApi *);

  TYPE
    WinApiHDC* = Kernel32.HANDLE;
    WinApiRECT* = RECORD [NOTAG]
      left*: LONGINT;
      top*: LONGINT;
      right*: LONGINT;
      bottom*: LONGINT;
    END;
    WinApiPAINTSTRUCT* = RECORD [NOTAG]
      hdc*: WinApiHDC;
      fErase*: Kernel32.BOOL;
      rcPaint*: WinApiRECT;
      fRestore*: Kernel32.BOOL;
      fIncUpdate*: Kernel32.BOOL;
      rgbReserved*: ARRAY [NOTAG] 32 OF CHAR (* SHORTCHAR *);
    END;
    User32WParam* = LONGINT;
    User32LParam* = LONGINT;
    User32LResult* = LONGINT;
    User32HGDIObj* = Kernel32.HANDLE;
    User32HFont* = User32HGDIObj;
    User32HBrush* = User32HGDIObj;
    User32HCursor* = Kernel32.HANDLE;
    User32HIcon* = Kernel32.HANDLE;
    User32HMenu* = Kernel32.HANDLE;
    User32HWND* = LONGINT;
    User32WndProc* = PROCEDURE [WINAPI] (hwnd: User32HWND; uMsg: LONGINT;
      wParam: User32WParam; lParam: User32LParam): User32LResult;
    User32Point* = RECORD
      x*, y*: LONGINT
    END;
    User32Msg* = RECORD [NOTAG]
      hwnd*: User32HWND;
      message*: LONGINT;
      wParam*, lParam*: LONGINT;
      time*: LONGINT;
      point*: User32Point;
    END;
    WinApiWNDCLASSA* = RECORD [NOTAG]
      style*: SET;
      lpfnWndProc*: User32WndProc;
      cbClsExtra*: LONGINT;
      cbWndExtra*: LONGINT;
      hInstance*: Kernel32.HINSTANCE;
      hIcon*: User32HIcon;
      hCursor*: User32HCursor;
      hbrBackground*: User32HBrush;
      lpszMenuName*: Kernel32.LPSTR;
      lpszClassName*: Kernel32.LPSTR;
    END;
    WinApiWNDCLASS* = WinApiWNDCLASSA;
    WinApiATOM* = INTEGER (* SHORTINT *);
    HGDIOBJ* = Kernel32.HANDLE;
    COLORREF* = LONGINT;

  CONST
     defFontName = "Verdana";
     HWNDTOPMOST = -1; (* this constant is not present in WinApi module *)
     WinApiSWPSHOWWINDOW* = {6};
     WinApiWMPAINT* = 15 (* {0..3} *);
     WinApiWMCHAR* = 258 (* {1, 8} *);
     WinApiWMDESTROY* = 02H;
     WinApiWMLBUTTONDOWN* = 513 (* {0, 9} *);
     WinApiDTWORDBREAK* = {4};
     WinApiDTCENTER* = {0};
     WinApiVKESCAPE* = 27 (* {0, 1, 3, 4} *);
     WinApiCOLORBTNFACE* = 15 (* {0..3} *);
     WinApiFWREGULAR* = 400 (* {4, 7, 8} *);
     WinApiDEFAULTCHARSET* = 1 (* {0} *);
     WinApiOUTDEFAULTPRECIS* = 0 (* {} *);
     WinApiCLIPDEFAULTPRECIS* = 0 (* {} *);
     WinApiDEFAULTQUALITY* = 0 (* {} *);
     WinApiDEFAULTPITCH* = 0 (* {} *);
     WinApiIDCARROW* = 32512 (* {8..14} *);
     WinApiCSVREDRAW* = {0};
     WinApiCSHREDRAW* = {1};
     WinApiWSEXTOPMOST* = {3};
     WinApiWSOVERLAPPEDWINDOW* = {16..19, 22, 23};
     WinApiSWSHOWDEFAULT* = 10 (* {1, 3} *);
     WinApiTRANSPARENT* = 1 (* {0} *);

  VAR
     defMessage: ARRAY 1024 OF CHAR;
     instance: Kernel32.HINSTANCE;
     mainWnd: User32HWND;
     defaultBrush: User32HBrush;
     defaultFont: User32HFont;
     iconId: ARRAY 2 OF CHAR;
      
     User32GetWindowRect-: PROCEDURE [C] (hWnd: User32HWND; VAR lpRect: WinApiRECT): Kernel32.BOOL;
     (*END GetWindowRect;*)
     User32SetWindowPos-: PROCEDURE [C] (hWnd: User32HWND; hWndInsertAfter: User32HWND;
         X: LONGINT; Y: LONGINT; cx: LONGINT; cy: LONGINT; uFlags: SET): Kernel32.BOOL;
     (*END SetWindowPos;*)
     User32LoadCursor-: PROCEDURE [C] (hInstance: Kernel32.HINSTANCE; lpCursorName: Kernel32.LPSTR): User32HCursor;
     (*END LoadCursor;*)
     User32BeginPaint-: PROCEDURE [C] (hWnd: User32HWND; VAR lpPaint: WinApiPAINTSTRUCT): WinApiHDC;
     (*END BeginPaint;*)
     User32EndPaint-: PROCEDURE [C] (hWnd: User32HWND; VAR lpPaint: WinApiPAINTSTRUCT): Kernel32.BOOL;
     (*END EndPaint;*)
     User32RegisterClass-: PROCEDURE [C] (VAR lpWndClass: WinApiWNDCLASSA): WinApiATOM;
     (*END RegisterClass;*)
     Gdi32CreateFont-: PROCEDURE [C] (p0: LONGINT; p1: LONGINT; p2: LONGINT; p3: LONGINT;
         p4: LONGINT; p5: LONGINT; p6: LONGINT; p7: LONGINT; p8: LONGINT; p9: LONGINT;
         p10: LONGINT; p11: LONGINT; p12: LONGINT; p13: Kernel32.LPSTR): User32HFont;
     (*END CreateFont;*)
     Gdi32DeleteObject-: PROCEDURE [C] (p0: HGDIOBJ): Kernel32.BOOL;
     (*END DeleteObject;*)
     Gdi32SetBkMode-: PROCEDURE [C] (p0: WinApiHDC; p1: LONGINT): LONGINT;
     (*END SetBkMode;*)
     Gdi32SelectObject-: PROCEDURE [C] (p0: WinApiHDC; p1: HGDIOBJ): HGDIOBJ;
     (*END SelectObject;*)
     User32GetClientRect-: PROCEDURE [C] (hWnd: User32HWND; VAR lpRect: WinApiRECT): Kernel32.BOOL;
     (*END GetClientRect;*)
     User32DrawText-: PROCEDURE [C] (hDC: WinApiHDC; lpString: Kernel32.LPSTR; nCount: LONGINT;
         VAR lpRect: WinApiRECT; uFormat: SET): LONGINT;
     (*END DrawText;*)
     Gdi32CreateSolidBrush-: PROCEDURE [C] (p0: COLORREF): User32HBrush;
     (*END CreateSolidBrush;*)
     User32GetSysColor-: PROCEDURE [C] (nIndex: LONGINT): LONGINT;
     (*END GetSysColor;*)
     User32PostQuitMessage-: PROCEDURE [WINAPI] (nExitCode: LONGINT);
     (*END PostQuitMessage;*)
     User32DefWindowProc-: User32WndProc;
     (*END DefWindowProc;*)
     User32LoadIcon-: PROCEDURE [WINAPI] (hInstance: Kernel32.HINSTANCE;
         VAR lpIconName: ARRAY [NOTAG] OF CHAR): User32HIcon;
     (*END LoadIcon;*)
     User32CreateWindowEx-: PROCEDURE [WINAPI] (dwExStyle: LONGINT;
         VAR lpClassName, lpWindowName: ARRAY [NOTAG] OF CHAR;
         dwStyle: SET; x, y, nWidth, nHeight: LONGINT; hWndParent: User32HWND;
         hMenu: User32HMenu; hInstance: Kernel32.HINSTANCE; lpParam: LONGINT): User32HWND;
     (*END CreateWindowEx;*)
     User32ShowWindow-: PROCEDURE [WINAPI] (hWnd: User32HWND; nCmdShow: LONGINT): Kernel32.BOOL;
     (*END ShowWindow;*)
     User32UpdateWindow-: PROCEDURE [WINAPI] (hWnd: User32HWND): Kernel32.BOOL;
     (*END UpdateWindow;*)
     User32GetMessage-: PROCEDURE [WINAPI] (VAR lpMsg: User32Msg; hWnd: User32HWND;
         wMsgFilterMin, wMsgFilterMax: LONGINT): LONGINT;
     (*END GetMessage;*)
     User32TranslateMessage-: PROCEDURE [WINAPI] (VAR lpMsg: User32Msg): Kernel32.BOOL;
     (*END TranslateMessage;*)
     User32DispatchMessage-: PROCEDURE [WINAPI] (VAR lpMsg: User32Msg): LONGINT;
     (*END DispatchMessage;*)
     
  PROCEDURE Append* (VAR to: ARRAY OF CHAR; this: ARRAY OF CHAR);
    VAR i, j, l: LONGINT;
  BEGIN
    i := 0; WHILE to[i] # 0X DO INC(i) END;
    l := LEN(to)-1; j := 0;
    WHILE (i < l) & (this[j] # 0X) DO
      to[i] := this[j]; INC(i); INC(j)
    END;
    to[i] := 0X
  END Append;

  PROCEDURE MoveMainWindow;
     CONST numSteps = 50;
     VAR
        i, res: LONGINT; rect: WinApiRECT;
        left, top, width, height: LONGINT; (* original window parameters *)
  BEGIN
     (* remember original window position *)
     res := User32GetWindowRect(mainWnd, rect);
     IF res = 0 THEN RETURN END;

     left := rect.left;
     top := rect.top;
     width := rect.right - left;
     height := rect.bottom - top;
     (* move window *)
     i := 0;
     res := 1;
     WHILE (i < numSteps) & (res # 0) DO
        INC(rect.top, 10);
        INC(rect.left, 10);
        res := User32SetWindowPos(
           mainWnd, HWNDTOPMOST, rect.left, rect.top, width, height, WinApiSWPSHOWWINDOW
        );
        INC(i);
     END;
     (* restore original window position *)
     res := User32SetWindowPos(
        mainWnd, HWNDTOPMOST, left, top, width, height, WinApiSWPSHOWWINDOW
     );
  END MoveMainWindow;


  PROCEDURE [WINAPI] WndHandler (wnd: User32HWND; msg: LONGINT;
        wParam: User32WParam; lParam: User32LParam): User32LResult;
     VAR
        res: LONGINT; ps: WinApiPAINTSTRUCT; dc: WinApiHDC; rect: WinApiRECT;
  BEGIN
     CASE msg OF
     | WinApiWMDESTROY (* WinApi.WM_DESTROY *):
        res := Gdi32DeleteObject(defaultBrush);
        res := Gdi32DeleteObject(defaultFont);
        User32PostQuitMessage(0);
     | WinApiWMPAINT:
        dc := User32BeginPaint(wnd, ps);
        res := Gdi32SetBkMode(dc, WinApiTRANSPARENT);
        res := Gdi32SelectObject(dc, defaultFont);
        res := User32GetClientRect(wnd, rect);
        defMessage := "Click me";
        Append(defMessage, 0DX); Append(defMessage, 0AX);
        Append(defMessage, "Esc - exit");
        res := User32DrawText(
           dc, SYSTEM.ADR(defMessage), -1, rect, WinApiDTWORDBREAK + WinApiDTCENTER
        );
        res := User32EndPaint(wnd, ps);
     | WinApiWMCHAR:
        IF wParam = WinApiVKESCAPE THEN
           User32PostQuitMessage(0);
        ELSE
           MoveMainWindow;
        END
     | WinApiWMLBUTTONDOWN:
        MoveMainWindow;
     ELSE
        RETURN User32DefWindowProc(wnd, msg, wParam, lParam);
     END;
     RETURN 0
  END WndHandler;


  PROCEDURE OpenWindow;
     VAR
        class: WinApiWNDCLASS; res: LONGINT;
        str: ARRAY 256 (* LEN(defFontName)+1 *) OF CHAR (* SHORTCHAR *);
        moveWinStr: ARRAY 32 OF CHAR;
  BEGIN
     defaultBrush := Gdi32CreateSolidBrush(User32GetSysColor(WinApiCOLORBTNFACE));
     str := defFontName;
     defaultFont := Gdi32CreateFont(
        -20, 0, 0, WinApiFWREGULAR, 0, 0, 0, 0, WinApiDEFAULTCHARSET,
        WinApiOUTDEFAULTPRECIS, WinApiCLIPDEFAULTPRECIS, WinApiDEFAULTQUALITY,
        WinApiDEFAULTPITCH, SYSTEM.VAL(Kernel32.LPSTR, SYSTEM.ADR(str))
     );
     class.hCursor := User32LoadCursor(0, SYSTEM.VAL(Kernel32.LPSTR, WinApiIDCARROW));
     iconId := 1X;
     class.hIcon := User32LoadIcon(instance, iconId);
     class.lpszMenuName := Kernel32.NULL;
     moveWinStr := "MoveWindow";
     class.lpszClassName := SYSTEM.ADR(moveWinStr);
     class.hbrBackground := defaultBrush;
     class.style := WinApiCSVREDRAW + WinApiCSHREDRAW;
     class.hInstance := instance;
     class.lpfnWndProc := WndHandler;
     class.cbClsExtra := 0;
     class.cbWndExtra := 0;
     res := User32RegisterClass(class);
     mainWnd := User32CreateWindowEx(
        SYSTEM.VAL(LONGINT, WinApiWSEXTOPMOST),
        moveWinStr, moveWinStr, WinApiWSOVERLAPPEDWINDOW,
        100, 100, 100, 100, 0, 0, instance, 0
     );
     res := User32ShowWindow(mainWnd, WinApiSWSHOWDEFAULT);
     res := User32UpdateWindow(mainWnd);
  END OpenWindow;


  PROCEDURE MainLoop;
     VAR
        msg: User32Msg; res: LONGINT;
  BEGIN
     WHILE User32GetMessage(msg, 0, 0, 0) # 0 DO
        res := User32TranslateMessage(msg);
        res := User32DispatchMessage(msg);
     END;
     Kernel32.Shutdown(0);
     Kernel32.ExitProcess(msg.wParam)
  END MainLoop;


BEGIN
  instance := Kernel32.GetModuleHandle(NIL);
  OpenWindow;
  MainLoop
END MoveWindow.

(*
  DevCompiler.Compile
  DevLinker.LinkExe MoveWin.exe := PrivMoveWindow ~
*)
