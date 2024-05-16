#!/bin/bash -e
source ci/utils.sh

git fetch opgm dev
#### Unsubmodule master ####
git fetch origin master
git checkout -f origin/master
git reset --hard origin/master

rm -rf $submodules
git submodule init
git submodule update

git branch -D unsubmoduled || :
git switch -c unsubmoduled

unsubmodule
git commit -am "I h8 submodules" --author="OPGM CI Automated"

git fetch origin master-ci
git checkout -f origin/master-ci
git reset --hard origin/master-ci

git branch -D dev-new || :
git switch -c dev-new

git checkout unsubmoduled panda/tests/
git commit -am "Re-add panda tests" --author="OPGM CI Automated" --no-verify

git fetch origin master
git checkout origin/master tools
git commit -am "Re-add tools" --author="OPGM CI Automated" --no-verify

source ci/checks.sh

#### Cherry-pick dev commits onto dev-new ####
diverged_commits=$(git log --pretty=format:"%H" --reverse origin/master-ci..opgm/dev | tail -n +3)
# fail if none detected
if [ -z "$diverged_commits" ]; then
  echo "Error: no commits to cherry-pick"
  exit 1
fi
git checkout -f dev-new

##### Uncomment to do a manual cherry-pick. Useful when there are conflicts. #####
if [ "$1" == "--manual" ]; then
  echo "Manual cherry-pick"
  exit 0
fi

skip_commits=[]
for commit in $diverged_commits; do
  if [[ $skip_commits =~ $commit ]]; then
    echo "Skipping $commit"
    continue
  fi
  echo "Cherry-picking $commit"
  git cherry-pick $commit || exit 1
done

#### Push dev to backup branch ####
source ci/checks.sh
backup_branch_name="dev-bkp-$(date -u +%Y-%m-%d-%H-%M-%S)"
git checkout -f dev
git switch -c $backup_branch_name

#### Push dev-new to dev ####
git checkout -f dev-new
git branch -D dev
git switch -c dev
git push -f opgm dev --no-verify
