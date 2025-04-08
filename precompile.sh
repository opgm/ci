#!/bin/bash -e
if [ -z "$RELEASE_BRANCH" ]; then
  echo "RELEASE_BRANCH is not set"
  exit 1
fi
scp ci/id_rsa_github comma:/data || exit 1
ssh comma << EOF
set -e
export GIT_SSH_COMMAND="ssh -i /data/id_rsa_github -o StrictHostKeyChecking=no"
export PANDA_DEBUG_BUILD=1
export RELEASE_BRANCH=${RELEASE_BRANCH}

rm -rf /data/openpilot /data/openpilot_build
git clone --branch master --recurse-submodules --filter=blob:none git@github.com:opgm/openpilot.git /data/openpilot_build || { echo "Failed to clone openpilot"; exit 1; }
cd /data/openpilot_build
/usr/bin/bash -e -l /data/openpilot_build/release/build_release.sh
EOF
echo "Build successful"

ssh comma -t "sudo reboot" || :
