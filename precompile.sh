#!/bin/bash -e
# Copy all files over to comma to build
branch=$(git rev-parse --abbrev-ref HEAD)
scp ci/id_rsa_github comma:/data || exit 1
ssh comma << EOF
rm -rf /data/openpilot /data/openpilot_build
GIT_SSH_COMMAND="ssh -i /data/id_rsa_github" git clone --single-branch --branch ${branch} --depth=1 git@github.com:opgm/openpilot.git /data/openpilot_build
cd /data/openpilot_build
RELEASE_BRANCH=${branch} /usr/bin/bash -e -l release/build_release.sh
EOF
echo "Build successful"

ssh comma -t "sudo reboot" || :

## Copy all files back over
#rm -rf build
#(rsync -zarv comma:/data/openpilot/ build) 1> /dev/null
#pushd build
#[[ ! -f "body/board/obj/.placeholder" ]] && exit 1
#[[ ! -f "panda/board/obj/.placeholder" ]] && exit 1
#[[ ! -f "selfdrive/modeld/models/supercombo.thneed" ]] && exit 1
## TODO: update readme
#git push -f -u origin $branch --no-verify
#popd
#rm -rf build
