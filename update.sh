#!/bin/bash
set -e

git submodule update

pushd opendbc_repo
git fetch origin master
git checkout master
git rebase origin/master
git push --force-with-lease -u opgm master
popd

git fetch origin master
git checkout master
git rebase --onto origin/master $(git merge-base HEAD origin/master) HEAD~1
git checkout -B master

# Check if system/hardware/tici/agnos.json was modified by the rebased commits
if git diff --quiet origin/master HEAD -- system/hardware/tici/agnos.json; then
  echo "system/hardware/tici/agnos.json not modified."
  BUMP_AGNOS=0
else
  echo "system/hardware/tici/agnos.json was modified."
  BUMP_AGNOS=1
fi

git add opendbc_repo
git commit -m "Bump opendbc"
git push --force-with-lease --no-verify -u opgm master:master

if [ "$BUMP_AGNOS" -eq 1 ]; then
  echo "Unable to precompile pending AGNOS update; please run the script again after the AGNOS update is merged."
  exit 1
fi

RELEASE_BRANCH=${RELEASE_BRANCH:-nightly} RETRIES=3 ci/precompile.sh
