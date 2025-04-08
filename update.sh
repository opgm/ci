#!/bin/bash
set -e

pushd opendbc_repo
git fetch origin master
git checkout master
git pull --ff-only origin master
git submodule update
git rebase origin/master
git push --force-with-lease -u opgm master
popd

git fetch origin master
git checkout master
git rebase --onto origin/master $(git merge-base HEAD origin/master) HEAD~1
git checkout -B master
git add opendbc_repo
git commit -m "Bump opendbc"
git push --force-with-lease -u opgm master:master
