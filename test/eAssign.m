MODULE eAssign;

TYPE t1 = RECORD END; p1 = POINTER TO t1;

VAR x: INTEGER; y: REAL; b: BOOLEAN; f: POINTER TO ARRAY OF CHAR;

PROCEDURE foo(): p1; BEGIN RETURN NIL END foo;

PROCEDURE Max(a: ARRAY OF INTEGER): INTEGER; BEGIN RETURN 0 END Max;

BEGIN
  x := qqq^;
  x := x^;
  x := t1;
  x := x[y];
  x := x.x;
  x := x - FALSE;
  x := x - {};
  x := x / FALSE;
  x := +FALSE;
  x := ~x;
  x := x DIV y;
  x := x < y;
  b := 'a' = 3;
  b := TRUE & 3;
  x := 9999999999;
  x := Max(f^)
END eAssign.

(*<<
"eAssign.m", line 12: 'qqq' has not been declared
>   x := qqq^;
>        ^^^

"eAssign.m", line 13: a pointer is needed here
>   x := x^;
>        ^
> This expression has type INTEGER

"eAssign.m", line 14: 't1' is not a variable
>   x := t1;
>        ^^

"eAssign.m", line 15: an array is needed here
>   x := x[y];
>        ^
> This expression has type INTEGER

"eAssign.m", line 15: a subscript must be an integer
>   x := x[y];
>          ^
> This expression has type REAL

"eAssign.m", line 16: a record or record pointer is needed here
>   x := x.x;
>        ^
> This expression has type INTEGER

"eAssign.m", line 17: the operands of - must be both numeric or both sets
>   x := x - FALSE;
>        ^^^^^^^^^
> The left operand has type INTEGER
> The right operand has type BOOLEAN

"eAssign.m", line 18: the operands of - must be both numeric or both sets
>   x := x - {};
>        ^^^^^^
> The left operand has type INTEGER
> The right operand has type SET

"eAssign.m", line 19: the operands of / must be both real or both sets
>   x := x / FALSE;
>        ^^^^^^^^^
> The left operand has type INTEGER
> The right operand has type BOOLEAN

"eAssign.m", line 20: the operand of unary + must be numeric
>   x := +FALSE;
>         ^^^^^
> This expression has type BOOLEAN

"eAssign.m", line 21: the operand of ~ must have type BOOLEAN
>   x := ~x;
>         ^
> This expression has type INTEGER

"eAssign.m", line 21: type INTEGER is needed on the RHS of this assignment
>   x := ~x;
>        ^^
> This expression has type BOOLEAN

"eAssign.m", line 22: the operands of DIV must be integers
>   x := x DIV y;
>        ^^^^^^^
> The left operand has type INTEGER
> The right operand has type REAL

"eAssign.m", line 23: type INTEGER is needed on the RHS of this assignment
>   x := x < y;
>        ^^^^^
> This expression has type BOOLEAN

"eAssign.m", line 24: the operands of = have incompatible types
>   b := 'a' = 3;
>        ^^^^^^^
> The left operand has type CHAR
> The right operand has type integer

"eAssign.m", line 25: the operands of & must have type BOOLEAN
>   b := TRUE & 3;
>        ^^^^^^^^
> The left operand has type BOOLEAN
> The right operand has type integer

"eAssign.m", line 26: warning -- the integer value 9999999999 does not fit in
type INTEGER
>   x := 9999999999;
>        ^^^^^^^^^^

"eAssign.m", line 27: open array parameter 'a' should have type ARRAY OF
INTEGER
>   x := Max(f^)
>            ^^
> This expression has type ARRAY OF CHAR
>>*)
