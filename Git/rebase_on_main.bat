@echo off
setlocal
set gitpath=%1
if "%gitpath%"=="" set gitpath=git

%gitpath% fetch upstream main:main
%gitpath% push origin main
%gitpath% stash push
%gitpath% rebase main
%gitpath% stash pop
