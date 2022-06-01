@echo off
setlocal
set gitpath=%1
if "%gitpath%"=="" set gitpath=git

%gitpath% fetch upstream main:main
%gitpath% push origin main


for /f %%i in ('call %gitpath% status --porcelain') do set stash=%%i
if not "%stash%" == "" (
  %gitpath% stash push
)

%gitpath% rebase main

if not "%stash%" == "" (
  %gitpath% stash pop
)
