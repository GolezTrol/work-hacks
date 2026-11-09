#!/bin/bash
git commit --amend --no-edit || exit 1
git push --force-with-lease