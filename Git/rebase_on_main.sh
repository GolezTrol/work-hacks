#!/bin/bash
main=$(git remote show upstream | sed -n '/HEAD branch/s/.*: //p')

if [ "$main" != 'main' ] && [ "$main" != 'master' ]
then
  echo Unexpected main branch: $main;
  exit 1
else
  echo Rebasing on $main
  git fetch upstream $main:$main || exit 1
  git push origin $main || exit 1
  git rebase $main --autostash
fi
