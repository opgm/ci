#!/bin/bash -e
source ci/utils.sh

#### Unsubmodule master ####
git fetch origin master
git checkout -f origin/master
git reset --hard origin/master

rm -rf $submodules
git submodule init
git submodule update

git branch -D dev-new || :
git switch -c dev-new

unsubmodule

#source ci/checks.sh

git commit -am "I h8 submodules" --author="OPGM CI Automated"

#### Cherry-pick dev commits onto dev-new ####
diverged_commits=$(git log --pretty=format:"%H" --reverse origin/master..opgm/dev | tail -n +2)
# fail if none detected
if [ -z "$diverged_commits" ]; then
  echo "Error: no commits to cherry-pick"
  exit 1
fi
git checkout -f dev-new

##### Uncomment to do a manual cherry-pick. Useful when there are conflicts. #####
#exit 0

skip_commits=[]
for commit in $diverged_commits; do
  if [[ $skip_commits =~ $commit ]]; then
    echo "Skipping $commit"
    continue
  fi
  echo "Cherry-picking $commit"
  git cherry-pick $commit || exit 1
done

source ci/checks.sh

#### Push dev to backup branch ####
backup_branch_name="dev-bkp-$(date +%Y-%m-%d-%H-%M-%S)"
git checkout -f dev
git switch -c $backup_branch_name

#### Push dev-new to dev ####
git checkout -f dev-new
git branch -D dev
git switch -c dev
git push -f opgm dev --no-verify
