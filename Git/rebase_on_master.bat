@echo off
setlocal
set gitpath=%1
if "%gitpath%"=="" set gitpath=git


%gitpath% fetch upstream master:master
%gitpath% push origin master

for /f %%i in ('call %gitpath% status --porcelain') do set stash=%%i
if not "%stash%" == "" (
  %gitpath% stash push
)

%gitpath% rebase master

if not "%stash%" == "" (
  %gitpath% stash pop
)
