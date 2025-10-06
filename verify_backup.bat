@ECHO OFF
REM ============================================================================
REM PostgreSQL Automated Backup and Verification Script (verify_backup.bat)
REM Adjust configuration values below before running.
REM ============================================================================

REM -- Configuration --
SET PG_BIN="C:\Program Files\PostgreSQL\16\bin"
SET BACKUP_DIR="C:\edb"
SET DB_NAME=analyticsscdb
SET DB_USER=postgres
SET DB_HOST=localhost

REM -- Dynamic filenames for log and dump --
SET TIMESTAMP=%DATE:/=-%_%TIME::=-%
SET TIMESTAMP=%TIMESTAMP: =0%
SET DUMP_FILE=%BACKUP_DIR%\%DB_NAME%_%TIMESTAMP%.dump
SET LOG_FILE=%BACKUP_DIR%\backup_log.txt

REM -- Start Logging --
ECHO. >> %LOG_FILE%
ECHO ================================================= >> %LOG_FILE%
ECHO Starting Backup and Verification at %DATE% %TIME% >> %LOG_FILE%
ECHO ================================================= >> %LOG_FILE%

REM --- 1. CREATE THE DATABASE DUMP ---
ECHO [1/3] Creating database dump for '%DB_NAME%'... >> %LOG_FILE%
%PG_BIN%\pg_dump.exe -h %DB_HOST% -U %DB_USER% -F c -b -v -f "%DUMP_FILE%" %DB_NAME%

IF %ERRORLEVEL% NEQ 0 (
    ECHO    [FAIL] pg_dump failed with error code %ERRORLEVEL%. Aborting. >> %LOG_FILE%
    GOTO :END
)
ECHO    [SUCCESS] Dump file created: %DUMP_FILE% >> %LOG_FILE%

REM --- 2. VERIFY THE DUMP (Quantitative Check) ---
ECHO [2/3] Verifying dump file... >> %LOG_FILE%

REM Get table count from the LIVE database
FOR /F "tokens=*" %%A IN ('%PG_BIN%\psql.exe -h %DB_HOST% -U %DB_USER% -d %DB_NAME% -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';"') DO (
    SET LIVE_TABLE_COUNT=%%A
)
SET LIVE_TABLE_COUNT=%LIVE_TABLE_COUNT: =%

REM Get table count from the DUMP file
FOR /F "tokens=*" %%A IN ('%PG_BIN%\pg_restore.exe -l "%DUMP_FILE%" ^| findstr "TABLE " ^| find /V /C ""') DO (
    SET DUMP_TABLE_COUNT=%%A
)
SET DUMP_TABLE_COUNT=%DUMP_TABLE_COUNT: =%

ECHO    Live DB table count: %LIVE_TABLE_COUNT% >> %LOG_FILE%
ECHO    Dump file table count: %DUMP_TABLE_COUNT% >> %LOG_FILE%

REM --- 3. COMPARE AND REPORT ---
ECHO [3/3] Comparing counts and reporting status... >> %LOG_FILE%
IF "%LIVE_TABLE_COUNT%"=="%DUMP_TABLE_COUNT%" (
    ECHO    [SUCCESS] Verification successful. Table counts match. >> %LOG_FILE%
) ELSE (
    ECHO    [FAIL] Verification FAILED. Table counts DO NOT match. >> %LOG_FILE%
)

:END
ECHO Finished at %DATE% %TIME%. >> %LOG_FILE%
ECHO ================================================= >> %LOG_FILE%
ECHO Script finished. Check %LOG_FILE% for details.
