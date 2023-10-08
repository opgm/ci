#!/bin/bash -e

REMOTE=$1
BRANCH=$2

source ci/utils.sh

for submodule in $submodules; do
  rm -rf _$submodule || :
done

git fetch $REMOTE $BRANCH
git checkout -f $REMOTE/$BRANCH
git reset --hard $REMOTE/$BRANCH

rm -rf $submodules
git submodule init
git submodule update

unsubmodule

git branch -D tmp || :
git checkout -b tmp

for submodule in $submodules; do
  mv $submodule _$submodule
done

git fetch origin master
git checkout -f origin/master
git reset --hard origin/master

rm -rf $submodules
git submodule init
git submodule update

unsubmodule

git branch -D tmp2 || :
git checkout -b tmp2

idx=1
for submodule in $submodules; do
  DIFF=$(git diff --no-index --patch ${submodule} _${submodule} || :)
  if [ -n "$DIFF" ]; then
    echo "Found diff for $submodule"
    echo "$DIFF" > "000$idx-$submodule.patch"
    idx=$((idx+1))
  fi
done
git diff --patch tmp2..tmp $(for submodule in $submodules; do echo -n " :!$submodule"; done) > 000$idx-openpilot.patch

for submodule in $submodules; do
  rm -rf _$submodule
done
