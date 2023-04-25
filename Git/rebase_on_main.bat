@echo off
setlocal enabledelayedexpansion
set gitpath=%1
if "%gitpath%"=="" set gitpath=git

set main=
for /f "tokens=* USEBACKQ" %%a in (`%gitpath% remote show upstream ^| FindStr /L "HEAD branch:"`) do (
  set mainline=%%a
  set mainbit=!mainline:~13!
  REM echo "!mainline!"--"!mainbit!"
  REM 'Remote branch' also matches. Just keeping the first line seems to do the trick.
  if "!main!"=="" set main=!mainbit!
)

echo Main branch: %main%

:ok
%gitpath% fetch upstream %main%:%main%
%gitpath% push origin %main%
%gitpath% rebase %main% --autostash
