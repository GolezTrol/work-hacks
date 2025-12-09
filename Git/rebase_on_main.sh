#!/bin/bash
main=$(git remote show upstream | sed -n '/HEAD branch/s/.*: //p')

if [ "$main" != 'main' ] && [ "$main" != 'master' ]
then
  echo Unexpected main branch: $main;
else
  echo Rebasing on $main
  git fetch upstream $main:$main
  git push origin $main
  git rebase $main --autostash
fi
