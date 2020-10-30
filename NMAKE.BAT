@echo off
REM Assembly 'make' batch by Charlie Chiang

FOR /F "tokens=*" %%g IN ('DIR *.ASM /B') do (SET FILE=%%g)

IF "%1"=="clean" GOTO CLEAN
IF "%1"=="run" GOTO RUN
IF "%1"=="" GOTO COMPILE
GOTO DONE

:COMPILE
MASM %FILE:~0,-4%.ASM;
LINK %FILE:~0,-4%.OBJ;
GOTO DONE

:RUN
IF NOT EXIST %FILE:~0,-4%.EXE (
    MASM %FILE:~0,-4%.ASM;
    LINK %FILE:~0,-4%.OBJ;
)
%FILE:~0,-4%.EXE
GOTO DONE

:CLEAN
DEL %FILE:~0,-4%.OBJ 2>nul
DEL %FILE:~0,-4%.EXE 2>nul
DEL %FILE:~0,-4%.LST 2>nul
GOTO DONE

:DONE