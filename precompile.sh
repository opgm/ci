#!/bin/bash -e
# Copy all files over to comma to build
scp ci/id_rsa_github comma:/data || exit 1
ssh comma << EOF
set -e
rm -rf /data/openpilot /data/openpilot_build
GIT_SSH_COMMAND="ssh -i /data/id_rsa_github -o StrictHostKeyChecking=no" git clone --branch master --recurse-submodules --filter=blob:none git@github.com:opgm/openpilot.git /data/openpilot_build
cd /data/openpilot_build
RELEASE_BRANCH=${RELEASE_BRANCH} PANDA_DEBUG_BUILD=1 GIT_SSH_COMMAND="ssh -i /data/id_rsa_github" /usr/bin/bash -e -l release/build_release.sh
EOF
echo "Build successful"

ssh comma -t "sudo reboot" || :
