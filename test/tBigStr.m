MODULE tBigStr;

(*<<
301
1350
>>*)

IMPORT Out, Strings;

CONST s =
"012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789";

VAR i, sum: INTEGER;

BEGIN
  Out.Int(LEN(s), 0); Out.Ln;

  sum := 0;
  FOR i := 0 TO Strings.Length(s)-1 DO
    sum := sum + ORD(s[i]) - ORD('0')
  END;
  Out.Int(sum, 0); Out.Ln
END tBigStr.

(*[[
!! SYMFILE #tBigStr STAMP #tBigStr.%main 1
!! END STAMP
!! 
MODULE tBigStr STAMP 0
IMPORT Out STAMP
IMPORT Strings STAMP
ENDHDR

PROC tBigStr.%main 4 4 0
!   Out.Int(LEN(s), 0); Out.Ln;
CONST 0
CONST 301
GLOBAL Out.Int
CALL 2
GLOBAL Out.Ln
CALL 0
!   sum := 0;
CONST 0
STGW tBigStr.sum
!   FOR i := 0 TO Strings.Length(s)-1 DO
CONST 301
GLOBAL tBigStr.%1
GLOBAL Strings.Length
CALLW 2
DEC
STLW -4
CONST 0
STGW tBigStr.i
JUMP 3
LABEL 2
!     sum := sum + ORD(s[i]) - ORD('0')
LDGW tBigStr.sum
GLOBAL tBigStr.%1
LDGW tBigStr.i
CONST 301
BOUND 20
LDIC
PLUS
CONST 48
MINUS
STGW tBigStr.sum
!   FOR i := 0 TO Strings.Length(s)-1 DO
LDGW tBigStr.i
INC
STGW tBigStr.i
LABEL 3
LDGW tBigStr.i
LDLW -4
JLEQ 2
!   Out.Int(sum, 0); Out.Ln
CONST 0
LDGW tBigStr.sum
GLOBAL Out.Int
CALL 2
GLOBAL Out.Ln
CALL 0
RETURN
END

! Global variables
GLOVAR tBigStr.i 4
GLOVAR tBigStr.sum 4

! String "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
DEFINE tBigStr.%1
STRING 3031323334353637383930313233343536373839303132333435363738393031
STRING 3233343536373839303132333435363738393031323334353637383930313233
STRING 3435363738393031323334353637383930313233343536373839303132333435
STRING 3637383930313233343536373839303132333435363738393031323334353637
STRING 3839303132333435363738393031323334353637383930313233343536373839
STRING 3031323334353637383930313233343536373839303132333435363738393031
STRING 3233343536373839303132333435363738393031323334353637383930313233
STRING 3435363738393031323334353637383930313233343536373839303132333435
STRING 3637383930313233343536373839303132333435363738393031323334353637
STRING 38393031323334353637383900

! End of file
]]*)
