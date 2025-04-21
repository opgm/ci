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

# Retry precompile up to 3 times (300s timeout per attempt)
for attempt in {1..3}; do
  echo "Running precompile attempt $attempt..."
  if RELEASE_BRANCH=nightly timeout 300 ./ci/precompile.sh; then
    echo "Precompile succeeded on attempt $attempt."
    break
  fi

  if [ "$attempt" -lt 3 ]; then
    echo "Precompile failed (attempt $attempt). Retrying..."
  else
    echo "Precompile failed after 3 attempts."
    exit 1
  fi
done
