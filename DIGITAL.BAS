DEFINT A-Z
DECLARE FUNCTION GetHours (Seconds#)
DECLARE FUNCTION GetMinutes (Seconds#)
DECLARE FUNCTION GetTime$ ()
DECLARE FUNCTION IIF (Condition, Result1, Result2)
DECLARE FUNCTION TranslateDigit (Digit$)
DECLARE FUNCTION Trim$ (Text$)
DECLARE SUB DisplayTime (x, y, Size, ColorV, Angled)
DECLARE SUB DrawColon (x, y, Size, ColorV, Angled)
DECLARE SUB DrawSegment (x, y, Size, Angle, ColorV)
DECLARE SUB DrawSegments (x, y, Segments, Size, ColorV, Angled)

CONST FALSE = 0
CONST NONE = 0
CONST TRUE = -1

CONST H1 = &H1
CONST H2 = &H2
CONST H3 = &H4
CONST L1 = &H8
CONST L2 = &H10
CONST R1 = &H20
CONST R2 = &H40

CONST C0 = H1 OR H3 OR L1 OR L2 OR R1 OR R2
CONST C1 = R1 OR R2
CONST C2 = H1 OR H2 OR H3 OR L2 OR R1
CONST C3 = H1 OR H2 OR H3 OR R1 OR R2
CONST C4 = H2 OR L1 OR R1 OR R2
CONST C5 = H1 OR H2 OR H3 OR L1 OR R2
CONST C6 = H1 OR H2 OR H3 OR L1 OR L2 OR R2
CONST C7 = H1 OR R1 OR R2
CONST C8 = H1 OR H2 OR H3 OR L1 OR L2 OR R1 OR R2
CONST C9 = H1 OR H2 OR H3 OR L1 OR R1 OR R2

CONST SECONDSPERHOUR = 3600
CONST SECONDSPERMINUTE = 60

SCREEN 7: CLS
ON TIMER(1) GOSUB Tick
TIMER ON
DO UNTIL INKEY$ = CHR$(27)
LOOP
TIMER OFF
END

Tick:
CLS
SCREEN , , 1, 0
DisplayTime 50, 50, 15, 11, TRUE
PCOPY 1, 0
RETURN

SUB DisplayTime (x, y, Size, ColorV, Angled)
STATIC Blink

   DisplayedTime$ = GetTime$

   CurrentX = x
   FOR Index = 1 TO LEN(DisplayedTime$)
      Digit$ = MID$(DisplayedTime$, Index, 1)
      IF Digit$ = ":" THEN
         IF Blink THEN DrawColon CurrentX, y, Size, ColorV, Angled
         CurrentX = CurrentX + (Size * 2)
      ELSE
         DrawSegments CurrentX, y, TranslateDigit(Digit$), Size, ColorV, Angled
         CurrentX = CurrentX + (Size * 3)
      END IF
   NEXT Index

   Blink = NOT Blink
END SUB

SUB DrawColon (x, y, Size, ColorV, Angled)
   Angle = IIF(Angled, -5, 0)
   DRAW "C" + STR$(ColorV)
   DRAW "BM" + STR$(x) + "," + STR$(y + Size)
   DRAW "S" + STR$(Size) + "TA" + STR$(Angle)
   DRAW "BU1 F1 G1 H1 E1 BD1 P" + STR$(ColorV) + "," + STR$(ColorV)
   DRAW "BD" + STR$(CINT(Size / 2))
   DRAW "BU1 F1 G1 H1 E1 BD1 P" + STR$(ColorV) + "," + STR$(ColorV)
END SUB

SUB DrawSegment (x, y, Size, Angle, ColorV)
   DRAW "C" + STR$(ColorV)
   DRAW "BM" + STR$(x) + "," + STR$(y)
   DRAW "S" + STR$(Size) + "TA" + STR$(Angle)
   DRAW "BL1 BM-1,-1 R4 F1 G1 L4 H1 E1"
   PAINT (x, y), ColorV
END SUB

SUB DrawSegments (x, y, Segments, Size, ColorV, Angled)
   Angle = IIF(Angled, -5, 0)

   DrawSegment x, y, Size, 0, IIF((Segments AND H1) = H1, ColorV, 0)
   DrawSegment x, y + (Size * 2), Size, 0, IIF((Segments AND H2) = H2, ColorV, 0)
   DrawSegment x, y + (Size * 4), Size, 0, IIF((Segments AND H3) = H3, ColorV, 0)
   DrawSegment x - Size, y + Size, Size, Angle + 90, IIF((Segments AND L1) = L1, ColorV, 0)
   DrawSegment x - Size, y + (Size * 3), Size, Angle + 90, IIF((Segments AND L2) = L2, ColorV, 0)
   DrawSegment x + Size, y + Size, Size, Angle + 90, IIF((Segments AND R1) = R1, ColorV, 0)
   DrawSegment x + Size, y + (Size * 3), Size, Angle + 90, IIF((Segments AND R2) = R2, ColorV, 0)
END SUB

FUNCTION GetHours (Seconds#)
   GetHours = INT(Seconds# / SECONDSPERHOUR)
END FUNCTION

FUNCTION GetMinutes (Seconds#)
   GetMinutes = INT((Seconds# - (GetHours(Seconds#) * CDBL(SECONDSPERHOUR))) / SECONDSPERMINUTE)
END FUNCTION

FUNCTION GetTime$
   Hours$ = Trim$(STR$(GetHours(TIMER)))
   Minutes$ = Trim$(STR$(GetMinutes(TIMER)))
   IF LEN(Hours$) = 1 THEN Hours$ = " " + Hours$
   IF LEN(Minutes$) = 1 THEN Minutes$ = "0" + Minutes$

   GetTime$ = Hours$ + ":" + Minutes$
END FUNCTION

FUNCTION IIF (Condition, Result1, Result2)
   IIF = Result2
   IF Condition THEN IIF = Result1
END FUNCTION

FUNCTION TranslateDigit (Digit$)
   Translation = NONE

   SELECT CASE Digit$
      CASE "0": Translation = C0
      CASE "1": Translation = C1
      CASE "2": Translation = C2
      CASE "3": Translation = C3
      CASE "4": Translation = C4
      CASE "5": Translation = C5
      CASE "6": Translation = C6
      CASE "7": Translation = C7
      CASE "8": Translation = C8
      CASE "9": Translation = C9
   END SELECT

   TranslateDigit = Translation
END FUNCTION

FUNCTION Trim$ (Text$)
   Trim$ = LTRIM$(RTRIM$(Text$))
END FUNCTION

