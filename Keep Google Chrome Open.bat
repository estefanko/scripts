@ECHO OFF

SET EXEName=chrome.exe
SET EXEFullPath=C:\Program Files\Google\Chrome\Application\chrome.exe

:FindGoogleChromeProcess
TASKLIST | FINDSTR /I "%EXEName%"
IF NOT ERRORLEVEL 1 GOTO :FindGoogleChromeProcess ELSE GOTO :StartGoogleChrome

:StartGoogleChrome
START "" "%EXEFullPath%"
GOTO :FindGoogleChromeProcess