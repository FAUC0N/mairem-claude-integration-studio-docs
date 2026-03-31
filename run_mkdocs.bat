@echo off
rem =============================================================================
rem run_mkdocs.bat — mAIrem Claude Integration Studio
rem Launches MkDocs development server and opens the browser.
rem =============================================================================
setlocal

cd /d D:\Claude-Workspace\AIAutomation\mAIrem\projects\mairem_claude_integration_studio

start "MkDocs" cmd /k mkdocs serve

timeout /t 3 /nobreak >nul

start "" http://127.0.0.1:8000

endlocal
