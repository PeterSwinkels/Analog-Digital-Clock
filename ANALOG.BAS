DEFINT A-Z

DECLARE FUNCTION CurrentTime# (Advance, NewHour, NewMinute, NewSecond)
DECLARE FUNCTION GetHours (Seconds AS DOUBLE)
DECLARE FUNCTION GetMinutes (Seconds AS DOUBLE)
DECLARE FUNCTION GetSeconds (Seconds AS DOUBLE)
DECLARE SUB DrawClock (DisplayedTime AS DOUBLE)
DECLARE SUB Initialize ()
DECLARE SUB Main ()
DECLARE SUB Quit ()

CONST FALSE = 0
CONST NONE = -1
CONST TRUE = -1

CONST BACKGROUND = 0
CONST CLOCKSIZE = 190
CONST HANDNUTSIZE = 3
CONST HOURSTODEGREES = 30
CONST LARGEMARKINTERVAL = 3
CONST MINUTESTODEGREES = 6
CONST MINUTESTOFRACTION# = 1 / 60
CONST PI# = 3.14159265358979#
CONST SECONDSPERHOUR = 3600
CONST SECONDSPERMINUTE = 60
CONST SECONDSTODEGREES = 6
CONST TWELVEHOURANGLE = -90

CONST CLOCKX = CLOCKSIZE * 1.5
CONST CLOCKY = CLOCKSIZE * 1.1
CONST DEGREESPERRADIAN# = 180 / PI#
CONST HOURHANDLENGTH = CLOCKSIZE / 1.6
CONST LARGEMARKLENGTH = HOURHANDLENGTH / 2.5
CONST MINUTEHANDLENGTH = HOURHANDLENGTH * 1.5
CONST SECONDHANDLENGTH = HOURHANDLENGTH * 1.5
CONST SMALLMARKLENGTH = LARGEMARKLENGTH / 2

ON TIMER(1) GOSUB ClockTick
Initialize
CALL Main
Quit
END

ClockTick:
DrawClock CurrentTime(TRUE, NONE, NONE, NONE)
RETURN

FUNCTION CurrentTime# (Advance, NewHour, NewMinute, NewSecond)
STATIC Seconds AS DOUBLE

   IF Advance THEN
      IF GetSeconds(Seconds) = 59 THEN
         Seconds = (GetHours(Seconds) * CLNG(SECONDSPERHOUR)) + (GetMinutes(Seconds) * SECONDSPERMINUTE)
         IF GetMinutes(Seconds) = 59 THEN
            Seconds = GetHours(Seconds) * SECONDSPERHOUR
            IF GetHours(Seconds) = 11 THEN
               Seconds = 0
            ELSE
               Seconds = Seconds + SECONDSPERHOUR
            END IF
         ELSE
            Seconds = Seconds + SECONDSPERMINUTE
         END IF
      ELSE
         Seconds = Seconds + 1
      END IF
   ELSE
      IF NOT NewHour = NONE THEN
         Seconds = GetSeconds(Seconds) + (GetMinutes(Seconds) * SECONDSPERMINUTE) + (NewHour * CLNG(SECONDSPERHOUR))
      END IF
      IF NOT NewMinute = NONE THEN
         Seconds = GetSeconds(Seconds) + (NewMinute * SECONDSPERMINUTE) + (GetHours(Seconds) * CLNG(SECONDSPERHOUR))
      END IF
      IF NOT NewSecond = NONE THEN
         Seconds = NewSecond + (GetMinutes(Seconds) * SECONDSPERMINUTE) + (GetHours(Seconds) * CLNG(SECONDSPERHOUR))
      END IF
   END IF

   CurrentTime# = Seconds
END FUNCTION

SUB DrawClock (DisplayedTime AS DOUBLE)
DIM HourAsRadians AS DOUBLE
DIM HourOnFace
DIM MarkLength
DIM MinuteAsRadians AS DOUBLE
DIM SecondAsRadians AS DOUBLE

STATIC HourHandX
STATIC HourHandY
STATIC MinuteHandX
STATIC MinuteHandY
STATIC SecondHandX
STATIC SecondHandY

   LINE (CLOCKX, CLOCKY)-(HourHandX, HourHandY), BACKGROUND
   LINE (CLOCKX, CLOCKY)-(MinuteHandX, MinuteHandY), BACKGROUND
   LINE (CLOCKX, CLOCKY)-(SecondHandX, SecondHandY), BACKGROUND

   FOR HourOnFace = 0 TO 11
      HourAsRadians = ((HourOnFace * HOURSTODEGREES) + TWELVEHOURANGLE) / DEGREESPERRADIAN#
      IF HourOnFace MOD LARGEMARKINTERVAL = 0 THEN MarkLength = LARGEMARKLENGTH ELSE MarkLength = SMALLMARKLENGTH
      LINE ((COS(HourAsRadians) * CLOCKSIZE) + CLOCKX, (SIN(HourAsRadians) * CLOCKSIZE) + CLOCKY)-((COS(HourAsRadians) * (CLOCKSIZE - MarkLength)) + CLOCKX, (SIN(HourAsRadians) * (CLOCKSIZE - MarkLength)) + CLOCKY), 14
   NEXT HourOnFace
   CIRCLE (CLOCKX, CLOCKY), CLOCKSIZE, 1

   HourAsRadians = (((GetHours(DisplayedTime) + GetMinutes(DisplayedTime) * MINUTESTOFRACTION#) * HOURSTODEGREES) + TWELVEHOURANGLE) / DEGREESPERRADIAN#
   SecondAsRadians = ((GetSeconds(DisplayedTime) * SECONDSTODEGREES) + TWELVEHOURANGLE) / DEGREESPERRADIAN#
   MinuteAsRadians = ((GetMinutes(DisplayedTime) * MINUTESTODEGREES) + TWELVEHOURANGLE) / DEGREESPERRADIAN#

   HourHandX = (COS(HourAsRadians) * HOURHANDLENGTH) + CLOCKX
   HourHandY = (SIN(HourAsRadians) * HOURHANDLENGTH) + CLOCKY
   MinuteHandX = (COS(MinuteAsRadians) * MINUTEHANDLENGTH) + CLOCKX
   MinuteHandY = (SIN(MinuteAsRadians) * MINUTEHANDLENGTH) + CLOCKY
   SecondHandX = (COS(SecondAsRadians) * SECONDHANDLENGTH) + CLOCKX
   SecondHandY = (SIN(SecondAsRadians) * SECONDHANDLENGTH) + CLOCKY

   LINE (CLOCKX, CLOCKY)-(HourHandX, HourHandY), 2
   LINE (CLOCKX, CLOCKY)-(MinuteHandX, MinuteHandY), 2
   LINE (CLOCKX, CLOCKY)-(SecondHandX, SecondHandY), 4
   CIRCLE (CLOCKX, CLOCKY), HANDNUTSIZE, 15
END SUB

FUNCTION GetHours (Seconds AS DOUBLE)
   GetHours = INT(Seconds / SECONDSPERHOUR)
END FUNCTION

FUNCTION GetMinutes (Seconds AS DOUBLE)
   GetMinutes = INT((Seconds - (GetHours(Seconds) * CDBL(SECONDSPERHOUR))) / SECONDSPERMINUTE)
END FUNCTION

FUNCTION GetSeconds (Seconds AS DOUBLE)
   GetSeconds = INT(Seconds - (GetHours(Seconds) * CDBL(SECONDSPERHOUR)) - (GetMinutes(Seconds) * CDBL(SECONDSPERMINUTE)))
END FUNCTION

SUB Initialize
   SCREEN 12
   WIDTH 80, 30
   CLS
   COLOR 3
   TIMER ON
END SUB

SUB Main
DIM KeyCode AS STRING
DIM Seconds AS DOUBLE

   Seconds = CurrentTime(FALSE, GetHours(TIMER), GetMinutes(TIMER), GetSeconds(TIMER))
   DrawClock CurrentTime(FALSE, NONE, NONE, NONE)

   LOCATE (CLOCKSIZE / 8) + 3, 1
   PRINT "   QBClock v1.02 - by: Peter Swinkels, ***2019***"
   PRINT "   Press the a or A keys to quickly advance the time. Escape = quit"

   DO
      DO
         KeyCode = INKEY$
      LOOP WHILE KeyCode = ""
      SELECT CASE KeyCode
         CASE "a", "A"
            Seconds = CurrentTime(FALSE, NONE, NONE, NONE)
            IF KeyCode$ = "A" THEN
               IF GetHours(Seconds) = 11 THEN Seconds = 0 ELSE Seconds = Seconds + SECONDSPERHOUR
            ELSE
               IF GetMinutes(Seconds) = 59 THEN
                  Seconds = GetHours(Seconds) * CLNG(SECONDSPERHOUR)
                  IF GetHours(Seconds) = 11 THEN Seconds = 0 ELSE Seconds = Seconds + SECONDSPERHOUR
               ELSE
                  Seconds = Seconds + SECONDSPERMINUTE
               END IF
            END IF
            DrawClock CurrentTime#(FALSE, GetHours(Seconds), GetMinutes(Seconds), NONE)
         CASE CHR$(27)
            EXIT DO
      END SELECT
   LOOP
END SUB

SUB Quit
   TIMER OFF
   SCREEN 0
   WIDTH 80, 25
   COLOR 7, 0
   CLS
   SYSTEM
END SUB

