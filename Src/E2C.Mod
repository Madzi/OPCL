MODULE E2C;

    (*symbols:
        |  0          1          2          3          4
     ---|--------------------------------------------------------
      0 |  null       *          /          DIV        MOD
      5 |  &          +          -          OR         =
     10 |  #          <          <=         >          >=
     15 |  IN         IS         ^          .          ,
     20 |  :          ..         )          ]          }
     25 |  OF         THEN       DO         TO         BY
     30 |  (          [          {          ~          :=
     35 |  number     NIL        TRUE       FALSE      string
     40 |  ident      ;          |          END        ELSE
     45 |  ELSIF      UNTIL      IF         CASE       WHILE
     50 |  REPEAT     FOR        LOOP       WITH       EXIT
     55 |  RETURN     ARRAY      OBJECT     RECORD     POINTER
     60 |  BEGIN      CONST      TYPE       VAR        PROCEDURE
     65 |  IMPORT     MODULE     CODE       eof        **
     *)

CONST
    (*symbol values*)
    null*      =  0;  times*     =  1;  slash*     =  2;  div*    =  3;  mod*     =  4;
    and*       =  5;  plus*      =  6;  minus*     =  7;  or*     =  8;  eql*     =  9;
    neq*       = 10;  lss*       = 11;  leq*       = 12;  gtr*    = 13;  geq*     = 14;
    in*        = 15;  is*        = 16;  arrow*     = 17;  period* = 18;  comma*   = 19;
    colon*     = 20;  upto*      = 21;  rparen*    = 22;  rbrak*  = 23;  rbrace*  = 24;
    of*        = 25;  then*      = 26;  do*        = 27;  to*     = 28;  by*      = 29;
    lparen*    = 30;  lbrak*     = 31;  lbrace*    = 32;  not*    = 33;  becomes* = 34;
    number*    = 35;  nil*       = 36;  true*      = 37;  false*  = 38;  string*  = 39;
    ident*     = 40;  semicolon* = 41;  bar*       = 42;  end*    = 43;  else*    = 44;
    elsif*     = 45;  until*     = 46;  if*        = 47;  case*   = 48;  while*   = 49;
    repeat*    = 50;  for*       = 51;  loop*      = 52;  with*   = 53;  exit*    = 54;
    return*    = 55;  array*     = 56;  object*    = 57;  record* = 58;  pointer* = 59;
    begin*     = 60;  code*      = 61;  const*     = 62;  type*   = 63;  var*     = 64;
    procedure* = 65;  import*    = 66;  module*    = 67;  eof*    = 68;

    (* numtyp values *)
    char* = 1;
    integer* = 2;
    real* = 3;
    longreal* = 4;

END E2C.