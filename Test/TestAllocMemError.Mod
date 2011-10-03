(*

This module crashes ETH Oberon Compiler 2.4 while generating .Obj file.
The error presents in procedure OPL.AllocCaseTab in lines:

				IF OPO.csize >= LEN(OPO.constant) THEN
					NEW(table, LEN(OPO.constant)*2);

It is here expected that 2*length of array OPO.constant will
always more, than OPO.csize value. But it is not always so.
And this module demonstates that possible legal event.

Problem lines are changed to have more info about this error:

				IF OPO.csize >= LEN(OPO.constant) THEN
					OPM.LogWStr(0DX); OPM.LogWStr(0AX);
					OPM.LogWStr("OPO.constant len1 ="); OPM.LogWNum(LEN(OPO.constant), 5);
					OPM.LogWStr(0DX); OPM.LogWStr(0AX);
					OPM.LogWStr("OPO.csize         ="); OPM.LogWNum(OPO.csize, 5);
					OPM.LogWStr(0DX); OPM.LogWStr(0AX);
					len := LEN(OPO.constant)*2;
					OPM.LogWStr("OPO.constant len2 ="); OPM.LogWNum(len, 5);
					OPM.LogWStr(0DX); OPM.LogWStr(0AX);
					WHILE OPO.csize >= len DO len := len*2 END;
					OPM.LogWStr("OPO.constant len3 ="); OPM.LogWNum(len, 5);
					OPM.LogWStr(0DX); OPM.LogWStr(0AX);
					NEW(table, len);
					
  And we have message:

> O2ETHCLC.EXE TestAllocMemError.Mod
file=TestAllocMemError.Mod
Oberon Portable Compiler / nw, rc, nm, tk, prk
Oberon Parser (Active & X Extensions) / prk
TestAllocMemError.Mod compiling TestAllocMemError
OPO.constant len1 = 1024
OPO.csize         = 2064
OPO.constant len2 = 2048
OPO.constant len3 = 4096
  code=77; data=76
  
With old code 2*OPO.constant len1 = 2048, and OPO.csize = 2064. And this line:

WHILE i < OPO.csize DO OPO.constant [i] := CHR (255); (* = -1 *) INC (i) END

produces memory protection crash. To fix this error I've changed the code to:

				IF OPO.csize >= LEN(OPO.constant) THEN
					len := LEN(OPO.constant)*2;
					WHILE OPO.csize >= len DO len := len*2 END;
					NEW(table, len);

WARNING!!!
Similar event of memory allocation there is in procedure OPL.AllocConst

03.10.2011
Oleg N. Cher

*)

MODULE TestAllocMemError;

   IMPORT SYSTEM, Kernel32, User32;

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
     WinApiWNDCLASSA* = RECORD [NOTAG]
       style*: SET;
       lpfnWndProc*: User32.WndProc;
       cbClsExtra*: LONGINT;
       cbWndExtra*: LONGINT;
       hInstance*: Kernel32.HINSTANCE;
       hIcon*: User32.HIcon;
       hCursor*: User32.HCursor;
       hbrBackground*: User32.HBrush;
       lpszMenuName*: Kernel32.LPSTR;
       lpszClassName*: Kernel32.LPSTR;
     END;
     WinApiWNDCLASS* = WinApiWNDCLASSA;
     WinApiATOM* = INTEGER (* SHORTINT *);
     HGDIOBJ* = Kernel32.HANDLE;
     COLORREF* = LONGINT;

   CONST
      defFontName = "Verdana";
      defMessage = "Click me + 0DX + 0AX + Esc - exit";
      HWNDTOPMOST = -1; (* this constant is not present in WinApi module *)
      WinApiSWPSHOWWINDOW* = {6};
      WinApiWMPAINT* = 15 (* {0..3} *);
      WinApiWMCHAR* = 258 (* {1, 8} *);
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
      instance: Kernel32.HINSTANCE;
      mainWnd: User32.HWND;
      defaultBrush: User32.HBrush;
      defaultFont: User32.HFont;
      iconId: ARRAY 2 OF CHAR;

      User32GetWindowRect-: PROCEDURE [C] (hWnd: User32.HWND; VAR lpRect: WinApiRECT): Kernel32.BOOL;
      (*END GetWindowRect;*)
      User32SetWindowPos-: PROCEDURE [C] (hWnd: User32.HWND; hWndInsertAfter: User32.HWND;
          X: LONGINT; Y: LONGINT; cx: LONGINT; cy: LONGINT; uFlags: SET): Kernel32.BOOL;
      (*END SetWindowPos;*)
      User32LoadCursor-: PROCEDURE [C] (hInstance: Kernel32.HINSTANCE; lpCursorName: Kernel32.LPSTR): User32.HCursor;
      (*END LoadCursor;*)
      User32BeginPaint-: PROCEDURE [C] (hWnd: User32.HWND; VAR lpPaint: WinApiPAINTSTRUCT): WinApiHDC;
      (*END BeginPaint;*)
      User32EndPaint-: PROCEDURE [C] (hWnd: User32.HWND; VAR lpPaint: WinApiPAINTSTRUCT): Kernel32.BOOL;
      (*END EndPaint;*)
      User32RegisterClass-: PROCEDURE [C] (VAR lpWndClass: WinApiWNDCLASSA): WinApiATOM;
      (*END RegisterClass;*)
      Gdi32CreateFont-: PROCEDURE [C] (p0: LONGINT; p1: LONGINT; p2: LONGINT; p3: LONGINT;
          p4: LONGINT; p5: LONGINT; p6: LONGINT; p7: LONGINT; p8: LONGINT; p9: LONGINT;
          p10: LONGINT; p11: LONGINT; p12: LONGINT; p13: Kernel32.LPSTR): User32.HFont;
      (*END CreateFont;*)
      Gdi32DeleteObject-: PROCEDURE [C] (p0: HGDIOBJ): Kernel32.BOOL;
      (*END DeleteObject;*)
      Gdi32SetBkMode-: PROCEDURE [C] (p0: WinApiHDC; p1: LONGINT): LONGINT;
      (*END SetBkMode;*)
      Gdi32SelectObject-: PROCEDURE [C] (p0: WinApiHDC; p1: HGDIOBJ): HGDIOBJ;
      (*END SelectObject;*)
      User32GetClientRect-: PROCEDURE [C] (hWnd: User32.HWND; VAR lpRect: WinApiRECT): Kernel32.BOOL;
      (*END GetClientRect;*)
      User32DrawText-: PROCEDURE [C] (hDC: WinApiHDC; lpString: Kernel32.LPSTR; nCount: LONGINT;
          VAR lpRect: WinApiRECT; uFormat: SET): LONGINT;
      (*END DrawText;*)
      Gdi32CreateSolidBrush-: PROCEDURE [C] (p0: COLORREF): User32.HBrush;
      (*END CreateSolidBrush;*)
      User32GetSysColor-: PROCEDURE [C] (nIndex: LONGINT): LONGINT;
      (*END GetSysColor;*)
    
   PROCEDURE [WINAPI] WndHandler (wnd: User32.HWND; msg: LONGINT;
         wParam: User32.WParam; lParam: User32.LParam): User32.LResult;
   BEGIN
      CASE msg OF
        02H:
      | WinApiWMPAINT:
      | WinApiWMCHAR:
      | WinApiWMLBUTTONDOWN:
      ELSE
      END;
      RETURN 0
   END WndHandler;

END TestAllocMemError.

