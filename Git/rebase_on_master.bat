@echo off
setlocal
set gitpath=%1
if "%gitpath%"=="" set gitpath=git

%gitpath% fetch upstream master:master
%gitpath% push origin master
%gitpath% stash push
%gitpath% rebase master
%gitpath% stash pop
