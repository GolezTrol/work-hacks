@echo off
setlocal
set gitpath=%1
if "%gitpath%"=="" set gitpath=git

%gitpath% commit --amend --no-edit
%gitpath% push --force