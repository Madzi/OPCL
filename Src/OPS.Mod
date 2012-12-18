(* ETH Oberon, Copyright 2000 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

(* Oberon Portable Scanner (front end) *)
(* NW, RC, ejz, rml, pjm, prk*)

MODULE OPS; (** non-portable *)

IMPORT
    E2C,
    OPM;

CONST
    MaxStrLen* = 256;
    MaxIdLen = 40;

TYPE
    Name* = ARRAY MaxIdLen OF CHAR;
    String* = ARRAY MaxStrLen OF CHAR;

    GetProc* = PROCEDURE (VAR sym: SHORTINT);

    Token = POINTER TO RECORD
        pos: OPM.TextPos;
        sym: SHORTINT;
        next: Token
    END;

    IntToken = POINTER TO RECORD (Token)
        intval: LONGINT;
        typ: INTEGER
    END;

    RealToken = POINTER TO RECORD (Token)
        realval: REAL
    END;

    LRealToken = POINTER TO RECORD (Token)
        lrlval: LONGREAL
    END;

    StrToken = POINTER TO RECORD (Token)
        str: String;
        len: LONGINT
    END;

    NameToken = POINTER TO RECORD (Token)
        name: Name
    END;

    TokenStream* = Token;

    (* name, str, numtyp, intval, realval, lrlval are implicit results of Get *)

VAR
    name*: Name;
    str*: String;
    numtyp*: INTEGER; (* 1 = char, 2 = integer, 3 = real, 4 = longreal *)
    intval*: LONGINT; (* integer value or string length *)
    realval*: REAL;
    lrlval*: LONGREAL;
    Get*: GetProc;
    ch*: CHAR;     (*current character*)
    stream, last: TokenStream;

CONST

PROCEDURE err(n: INTEGER);
BEGIN
    OPM.err(n)
END err;

PROCEDURE StreamGet (VAR sym: SHORTINT);
BEGIN
    IF (stream # NIL) & (stream.next # NIL) THEN
        stream := stream.next;
        sym := stream.sym; OPM.errpos := stream.pos;
        IF stream IS IntToken THEN
            intval := stream(IntToken).intval;
            numtyp := stream(IntToken).typ
        ELSIF stream IS RealToken THEN
            realval := stream(RealToken).realval;
            numtyp := E2C.real
        ELSIF stream IS LRealToken THEN
            lrlval := stream(LRealToken).lrlval;
            numtyp := E2C.longreal
        ELSIF stream IS StrToken THEN
            str := stream(StrToken).str;
            intval := stream(StrToken).len
        ELSIF stream IS NameToken THEN
            name := stream(NameToken).name
        ELSIF ((E2C.times <= sym) & (sym <= E2C.arrow)) OR (sym = E2C.not ) OR (sym = E2C.becomes) THEN
            name := stream(NameToken).name
        END
    ELSE
        sym := E2C.eof
    END
END StreamGet;

PROCEDURE RecToken (sym: SHORTINT);
VAR
    s: Token;
    r: RealToken;
    lr: LRealToken;
    i: IntToken;
    st: StrToken;
    nam: NameToken;
BEGIN
    IF sym = E2C.number THEN
        IF numtyp = E2C.real THEN
            NEW (r);
            r.realval := realval;
            s := r
        ELSIF numtyp = E2C.longreal THEN
            NEW (lr);
            lr.lrlval := lrlval;
            s := lr
        ELSE
            NEW (i);
            i.intval := intval;
            i.typ := numtyp;
            s := i
        END
    ELSIF sym = E2C.string THEN
        NEW (st);
        st.str := str;
        st.len := intval;
        s := st
    ELSIF sym = E2C.ident THEN
        NEW (nam);
        nam.name := name;
        s := nam
    ELSIF ((E2C.times <= sym) & (sym <= E2C.arrow)) OR (sym = E2C.not) OR (sym = E2C.becomes) THEN
        NEW (nam);
        nam.name := name;
        s := nam
    ELSE
        NEW (s)
    END;
    s.pos := OPM.errpos;
    s.sym := sym;
    s.next := last.next;
    last.next := s;
    last := s
END RecToken;

PROCEDURE StartRecording* (sym: SHORTINT);
BEGIN
    NEW (stream);
    last := stream;
    RecToken (sym)
END StartRecording;

PROCEDURE StopRecording* (VAR s: TokenStream);
BEGIN
    s := stream;
    stream := NIL;
    last := NIL
END StopRecording;

PROCEDURE StartPlaying* (s: TokenStream);
BEGIN
    stream := s;
    Get := StreamGet
END StartPlaying;

PROCEDURE Str(VAR sym: SHORTINT);
VAR
    i: INTEGER;
    och: CHAR;
BEGIN
    i := 0;
    och := ch;
    LOOP
        OPM.Get(ch);
        IF ch = och THEN
            EXIT
        END;
        IF ch < " " THEN err(3); EXIT END ;
        IF i = MaxStrLen-1 THEN err(241); EXIT END ;
        str[i] := ch; INC(i)
    END ;
    OPM.Get(ch); str[i] := 0X; intval := i + 1;
    IF intval = 2 THEN
        sym := E2C.number;
        numtyp := 1;
        intval := ORD(str[0])
    ELSE
        sym := E2C.string
    END
END Str;

PROCEDURE Identifier(VAR sym: SHORTINT);
VAR
    i: INTEGER;
BEGIN
    i := 0;
    REPEAT
        name[i] := ch;
        INC(i);
        OPM.Get(ch)
    UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch)) & (ch # "_") OR (i = MaxIdLen);
    IF i = MaxIdLen THEN
        err(240);
        DEC(i)
    END;
    name[i] := 0X;
    sym := E2C.ident
END Identifier;

PROCEDURE CheckCardinality*(VAR name: Name; nofp: SHORTINT): BOOLEAN;
BEGIN
    CASE name[0] OF
    | "+", "-":
        RETURN (nofp = 1) OR (nofp = 2)

    | "~":
        RETURN (name[1] = 0X) & (nofp = 1)
    ELSE
        RETURN
            nofp = 2
    END
END CheckCardinality;

PROCEDURE CheckOperator*(VAR id: SHORTINT);
VAR
    ch0, ch1, ch2: CHAR;
BEGIN
    COPY(str, name);
    ch0 := str[0];
    ch1 := str[1];
    ch2 := str[2];
    CASE ch0 OF
        | "=", "#", "&":
            IF ch1 = 0X THEN
                id := 126;
            END

    | "<", ">":
        IF (ch1 = 0X) OR ((ch1 = "=") & (ch2 = 0X)) THEN
            id := 126;
        END (* < , <=,  > , >= *)

    | "I":
        IF (ch1 = "N") & (ch2 = 0X) THEN
            id := 126;
        END (* IN *)

    | "D":
        IF str = "DIV" THEN
            id := 126;
        END (* DIV *)

    | "M":
        IF str = "MOD" THEN
            id := 126;
        END (* MOD *)

    | "O":
        IF str = "OR" THEN
            id := 126;
        END (* OR *)

    | "+", "-", "*", "/":
        IF (ch1 = 0X) OR ((ch2 = 0X) & (ch1 = "*")) THEN
            id := 126;
        END;

    | "~":
        IF (ch1 = 0X) THEN
            id := 126;
        END;

    | ":":
        IF str = ":=" THEN
            id := 126;
        END;
    ELSE
        id := 0;
    END;
END CheckOperator;

PROCEDURE Number*;
VAR
    i, m, n, d, e: INTEGER;
    dig: ARRAY 24 OF CHAR;
    f: LONGREAL;
    expCh: CHAR;
    neg: BOOLEAN;

    PROCEDURE Ten(e: INTEGER): LONGREAL;
			VAR x, p: LONGREAL;
		BEGIN x := 1; p := 10;
			WHILE e > 0 DO
				IF ODD(e) THEN x := x*p END;
				e := e DIV 2;
				IF e > 0 THEN p := p*p END (* prevent overflow *)
			END;
			RETURN x
		END Ten;

		PROCEDURE Ord(ch: CHAR; hex: BOOLEAN): INTEGER;
		BEGIN (* ("0" <= ch) & (ch <= "9") OR ("A" <= ch) & (ch <= "F") *)
			IF ch <= "9" THEN RETURN ORD(ch) - ORD("0")
			ELSIF hex THEN RETURN ORD(ch) - ORD("A") + 10
			ELSE err(2); RETURN 0
			END
		END Ord;

BEGIN (* ("0" <= ch) & (ch <= "9") *)
    i := 0;
    m := 0;
    n := 0;
    d := 0;
    LOOP (* read mantissa *)
        IF ("0" <= ch) & (ch <= "9") OR (d = 0) & ("A" <= ch) & (ch <= "F") THEN
            IF (m > 0) OR (ch # "0") THEN (* ignore leading zeros *)
                IF n < LEN(dig) THEN
                    dig[n] := ch;
                    INC(n)
                END;
                INC(m)
            END;
            OPM.Get(ch);
            INC(i)
            ELSIF ch = "." THEN 
                OPM.Get(ch);
            IF ch = "." THEN (* ellipsis *)
                ch := 7FX;
                EXIT
            ELSIF d = 0 THEN (* i > 0 *)
                d := i
            ELSE
                err(2)
            END
        ELSE
            EXIT
        END
    END; (* 0 <= n <= m <= i, 0 <= d <= i *)
    IF d = 0 THEN (* integer *)
        IF n = m THEN
            intval := 0;
            i := 0;
            IF ch = "X" THEN (* character *)
                OPM.Get(ch);
                numtyp := E2C.char;
                IF n <= 2 THEN
                    WHILE i < n DO
                        intval := intval * 10H + Ord(dig[i], TRUE);
                        INC(i)
                    END
                ELSE
                    err(203)
                END
            ELSIF ch = "H" THEN (* hexadecimal *)
                OPM.Get(ch);
                numtyp := E2C.integer;
                IF n <= OPM.MaxHDig THEN
                    IF (n = OPM.MaxHDig) & (dig[0] > "7") THEN (* prevent overflow *)
                        intval := -1
                    END;
                    WHILE i < n DO
                        intval := intval * 10H + Ord(dig[i], TRUE);
                        INC(i)
                    END
                ELSE
                    err(203)
                END
            ELSE (* decimal *)
                numtyp := E2C.integer;
                WHILE i < n DO
                    d := Ord(dig[i], FALSE);
                    INC(i);
                    IF intval <= (MAX(LONGINT) - d) DIV 10 THEN
                        intval := intval * 10 + d
                    ELSE
                        err(203)
                    END
                END
            END
        ELSE
            err(203)
        END
    ELSE (* fraction *)
        f := 0;
        e := 0;
        expCh := "E";
        WHILE n > 0 DO (* 0 <= f < 1 *)
            DEC(n);
            f := (Ord(dig[n], FALSE) + f) / 10
        END;
        IF (ch = "E") OR (ch = "D") THEN
            expCh := ch;
            OPM.Get(ch);
            neg := FALSE;
            IF ch = "-" THEN
                neg := TRUE;
                OPM.Get(ch)
            ELSIF ch = "+" THEN
                OPM.Get(ch)
            END;
            IF ("0" <= ch) & (ch <= "9") THEN
                REPEAT
                    n := Ord(ch, FALSE);
                    OPM.Get(ch);
                    IF e <= (MAX(INTEGER) - n) DIV 10 THEN
                        e := e * 10 + n
                    ELSE
                        err(203)
                    END
                UNTIL (ch < "0") OR ("9" < ch);
                IF neg THEN
                    e := -e
                END
            ELSE
                err(2)
            END
        END;
        DEC(e, i - d - m); (* decimal point shift *)
        IF expCh = "E" THEN
            numtyp := E2C.real;
            IF (1 - OPM.MaxRExp < e) & (e <= OPM.MaxRExp) THEN
                IF e < 0 THEN
                    realval := SHORT(f / Ten(-e))
                ELSE
                    realval := SHORT(f * Ten(e))
                END
            ELSE
                err(203)
            END
        ELSE
            numtyp := E2C.longreal;
            IF (1 - OPM.MaxLExp < e) & (e <= OPM.MaxLExp) THEN
                IF e < 0 THEN
                    lrlval := f / Ten(-e)
                ELSE
                    lrlval := f * Ten(e)
                END
            ELSE
                err(203)
            END
        END
    END
END Number;

PROCEDURE DefaultGet(VAR sym: SHORTINT);
VAR
    s: SHORTINT;

    PROCEDURE Comment; (* do not read after end of file *)
    VAR dump: BOOLEAN;
    BEGIN OPM.Get(ch);
        IF ch = "@" THEN dump := TRUE; OPM.LogWLn END;
        LOOP
            LOOP
                WHILE ch = "(" DO OPM.Get(ch);
                    IF ch = "*" THEN Comment ELSIF dump THEN OPM.LogW ("(") END
                END ;
                IF ch = "*" THEN OPM.Get(ch); EXIT END ;
                IF ch = OPM.Eot THEN EXIT END ;
                IF dump THEN OPM.LogW (ch) END;
                OPM.Get(ch)
            END ;
            IF ch = ")" THEN OPM.Get(ch); EXIT END ;
            IF dump THEN OPM.LogW ("*") END;
            IF ch = OPM.Eot THEN err(5); EXIT END
        END
    END Comment;

BEGIN
    WHILE ch <= " " DO (*ignore control characters*)
        IF ch = OPM.Eot THEN
            sym := E2C.eof;
            RETURN
        ELSE
            OPM.Get(ch)
        END
    END ;
    OPM.TextPosPrev(OPM.errpos, OPM.curpos);
    CASE ch OF   (* ch > " " *)
    | 22X, 27X :
        Str(s)

    | "#":
        s := E2C.neq;
        name := "#";
        OPM.Get(ch)

    | "&":
        s := E2C.and;
        name := "&";
        OPM.Get(ch)

    | "(":
        OPM.Get(ch);
        IF ch = "*" THEN
            Comment;
            Get(sym);
            RETURN (*dont' record twice!*)
        ELSE
            s := E2C.lparen
        END

    | ")":
        s := E2C.rparen;
        OPM.Get(ch)

    | "*":
        name := "*";
        s := E2C.times;
        OPM.Get(ch)

    | "+":
        name := "+";
        s := E2C.plus;
        OPM.Get(ch)

    | ",":
        s := E2C.comma;
        OPM.Get(ch)

    | "-":
        name := "-";
        s := E2C.minus;
        OPM.Get(ch)

    | ".":
        OPM.Get(ch);
        IF ch = "." THEN
            OPM.Get(ch);
            s := E2C.upto
        ELSE
            s := E2C.period
        END

    | "/":
        name:="/";
        OPM.Get(ch);
        s := E2C.slash

    | "0".."9":
        Number;
        s := E2C.number

    | ":":
        OPM.Get(ch);
        IF ch = "=" THEN
            OPM.Get(ch);
            s := E2C.becomes;
            name := ":="
        ELSE
            s := E2C.colon
        END

    | ";":
        s := E2C.semicolon;
        OPM.Get(ch)

    | "<":
        OPM.Get(ch);
        IF ch = "=" THEN
            OPM.Get(ch);
            s := E2C.leq;
            name := "<="
        ELSE
            s := E2C.lss;
            name := "<"
        END

    | "=":
        s := E2C.eql;
        name := "=";
        OPM.Get(ch)

    | ">":
        OPM.Get(ch);
        IF ch = "=" THEN
            OPM.Get(ch);
            s := E2C.geq;
            name := ">="
        ELSE
            s := E2C.gtr;
            name := ">"
        END

    | "A":
        Identifier(s);
        IF name = "ARRAY" THEN
            s := E2C.array
        END

    | "B":
        Identifier(s);
        IF name = "BEGIN" THEN
            s := E2C.begin
        ELSIF name = "BY" THEN
            s := E2C.by
        END

    | "C":
        Identifier(s);
        IF name = "CASE" THEN
            s := E2C.case
        ELSIF name = "CODE" THEN
            s := E2C.code
        ELSIF name = "CONST" THEN
            s := E2C.const
        END

    | "D":
        Identifier(s);
        IF name = "DO" THEN
            s := E2C.do
        ELSIF name = "DIV" THEN
            s := E2C.div
        END

    | "E":
        Identifier(s);
        IF name = "END" THEN
            s := E2C.end
        ELSIF name = "ELSE" THEN
            s := E2C.else
        ELSIF name = "ELSIF" THEN
            s := E2C.elsif
        ELSIF name = "EXIT" THEN
            s := E2C.exit
        END

    | "F":
        Identifier(s);
        IF name = "FALSE" THEN
            s := E2C.false
        ELSIF name = "FOR" THEN
            s := E2C.for
        END

    | "I":
        Identifier(s);
        IF name = "IF" THEN
            s := E2C.if
        ELSIF name = "IN" THEN
            s := E2C.in
        ELSIF name = "IS" THEN
            s := E2C.is
        ELSIF name = "IMPORT" THEN
            s := E2C.import
        END

    | "L":
        Identifier(s);
        IF name = "LOOP" THEN
            s := E2C.loop
        END

    | "M":
        Identifier(s);
        IF name = "MOD" THEN
            s := E2C.mod
        ELSIF name = "MODULE" THEN
            s := E2C.module
        END

    | "N":
        Identifier(s);
        IF name = "NIL" THEN
            s := E2C.nil
        END

    | "O":
        Identifier(s);
        IF name = "OR" THEN
            s := E2C.or
        ELSIF name = "OF" THEN
            s := E2C.of
        ELSIF name = "OBJECT" THEN
            s := E2C.object
        END

    | "P":
        Identifier(s);
        IF name = "PROCEDURE" THEN
            s := E2C.procedure
        ELSIF name = "POINTER" THEN
            s := E2C.pointer
        END

    | "R":
        Identifier(s);
        IF name = "RECORD" THEN
            s := E2C.record
        ELSIF name = "REPEAT" THEN
            s := E2C.repeat
        ELSIF name = "RETURN" THEN
            s := E2C.return
        END

    | "T":
        Identifier(s);
        IF name = "THEN" THEN
            s := E2C.then
        ELSIF name = "TO" THEN
            s := E2C.to
        ELSIF name = "TRUE" THEN
            s := E2C.true
        ELSIF name = "TYPE" THEN
            s := E2C.type
        END

    | "U":
        Identifier(s);
        IF name = "UNTIL" THEN
            s := E2C.until
        END

    | "V":
        Identifier(s);
        IF name = "VAR" THEN
            s := E2C.var
        END

    | "W":
        Identifier(s);
        IF name = "WHILE" THEN
            s := E2C.while
        ELSIF name = "WITH" THEN
            s := E2C.with
        END

    | "G".."H", "J", "K", "Q", "S", "X".."Z", "_":
        Identifier(s)

    | "[":
        s := E2C.lbrak;
        OPM.Get(ch)

    | "]":
        s := E2C.rbrak;
        OPM.Get(ch)

    | "^":
        s := E2C.arrow;
        OPM.Get(ch)

    | "a".."z":
        Identifier(s)

    | "{":
        s := E2C.lbrace;
        OPM.Get(ch)

    | "|":
        s := E2C.bar;
        OPM.Get(ch)

    | "}":
        s := E2C.rbrace;
        OPM.Get(ch)

    | "~":
        s := E2C.not;
        name := "~";
        OPM.Get(ch)

    | 7FX:
        s := E2C.upto;
        OPM.Get(ch)
    ELSE
        s := E2C.null;
        OPM.Get(ch)
    END ;
    IF stream # NIL THEN
        RecToken (s)
    END;
    sym := s
END DefaultGet;

PROCEDURE Init*;
BEGIN
    ch := " ";
    stream := NIL;
    last := NIL;
    Get := DefaultGet
END Init;

BEGIN
    Init
END OPS.

(*
    Generate Enumeration:
    ProgTools.Enum 0 *
        null
        times slash div mod and
        plus minus or eql neq  lss leq gtr geq in is
        arrow period comma
        colon upto rparen rbrak rbrace
        of then do to by
        lparen lbrak lbrace
        not
        becomes
        number nil true false string
        ident semicolon bar end else
        elsif until if case while
        repeat for loop with exit
        return array object record pointer begin code
        const type var procedure import
        module eof
        ~

    Generate Import List
    ProgTools.Enum OPS
        null
        times slash div mod and
        plus minus or eql neq  lss leq gtr geq in is
        arrow period comma
        colon upto rparen rbrak rbrace
        of then do to by
        lparen lbrak lbrace
        not
        becomes
        number nil true false string
        ident semicolon bar end else
        elsif until if case while
        repeat for loop with exit
        return array object record pointer begin code
        const type var procedure import
        module eof
        ~

*)
