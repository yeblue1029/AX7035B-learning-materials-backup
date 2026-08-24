@echo off
REM AI_REPO_INDEX Generator - CMD wrapper
REM Runs the PowerShell script to regenerate the repository index

powershell -ExecutionPolicy Bypass -File "%~dp0GENERATE_REPO_INDEX.ps1"
pause
