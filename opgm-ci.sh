#!/bin/bash -e

pushd ci && git pull && popd
./ci/update-dev.sh
git fetch opgm dev
git checkout -f opgm/dev
build_branch="build-$(date -u +%Y%m%d)"
export build_branch
git branch -D $build_branch || :
git switch -c $build_branch
./ci/make-docs.sh
source ci/checks.sh
#cp -r ._github .github
#git add .github
#git commit -am "Reinstantiate tests" --author="OPGM CI Automated"
git push -f -u opgm $build_branch --no-verify
./ci/precompile.sh
git fetch opgm $build_branch
git push -f opgm opgm/${build_branch}:staging --no-verify
git checkout -f dev
# assuming everything works
#ci/push-release-alert.sh
