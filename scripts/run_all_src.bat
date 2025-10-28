@echo off
REM Run all python modules in the project's src/ directory.
REM Usage:
REM   set PYTHON=python
REM   scripts\run_all_src.bat

setlocal enabledelayedexpansion

REM Set default Python command if not already set
if not defined PYTHON set PYTHON=python

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
REM Remove trailing backslash
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Calculate repository root (parent of scripts directory)
for %%I in ("%SCRIPT_DIR%\..") do set REPO_ROOT=%%~fI
set SRC_DIR=%REPO_ROOT%\src

REM Check if src directory exists
if not exist "%SRC_DIR%" (
    echo src directory not found at: %SRC_DIR% >&2
    exit /b 2
)

echo Using Python: %PYTHON%
echo Running Python files under: %SRC_DIR%
%PYTHON% --version
if errorlevel 1 (
    echo Failed to run Python. Is it installed and in PATH? >&2
    exit /b 1
)

REM Initialize failure flag
set failed=0

REM Process each .py file in src directory (non-recursive)
for %%f in ("%SRC_DIR%\*.py") do (
    set filename=%%~nxf
    
    REM Skip __init__.py (not typically runnable)
    if /i not "!filename!"=="__init__.py" (
        echo.
        echo ===== Running: !filename! =====
        
        %PYTHON% "%%f"
        if errorlevel 1 (
            echo --- FAILED (!errorlevel!): !filename! >&2
            set failed=1
        ) else (
            echo --- OK: !filename!
        )
    )
)

REM Check if any files were processed
set file_count=0
for %%f in ("%SRC_DIR%\*.py") do set /a file_count+=1

if %file_count%==0 (
    echo No Python files found in %SRC_DIR%
    exit /b 0
)

echo.
if !failed! neq 0 (
    echo One or more scripts failed. >&2
    exit /b 1
)

echo All scripts ran (some may have produced their own output).
exit /b 0
