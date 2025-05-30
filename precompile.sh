#!/usr/bin/env bash
if [ -z "$RELEASE_BRANCH" ]; then
  echo "Warning: RELEASE_BRANCH is not set. Defaulting to nightly"
  RELEASE_BRANCH="nightly"
fi

retry() {
  local -r retries="${RETRIES:-3}"
  local -r delay="${RETRY_DELAY:-5}"
  local exit_code=0

  for ((i=1; i<=retries; i++)); do
    echo "Attempt $i of $retries..."
    "$@" && return 0

    exit_code=$?
    if (( i < retries )); then
      echo "Failed (exit $exit_code). Retrying in ${delay}s..."
      sleep "$delay"
    fi
  done

  echo "Command failed after $retries attempts (last exit $exit_code)."
  exit $exit_code
}

retry scp ci/id_rsa_github comma:/data || exit 1

clone_remote() {
  ssh comma << "EOF"
set -e
export GIT_SSH_COMMAND="ssh -i /data/id_rsa_github -o StrictHostKeyChecking=no"

rm -rf /data/openpilot_build
git clone --branch master --recurse-submodules --filter=blob:none git@github.com:opgm/openpilot.git /data/openpilot_build || { echo "Failed to clone openpilot"; exit 1; }
EOF
}

build_remote() {
  ssh comma << EOF
set -e
export GIT_SSH_COMMAND="ssh -i /data/id_rsa_github -o StrictHostKeyChecking=no"
export PANDA_DEBUG_BUILD=1
export RELEASE_BRANCH=${RELEASE_BRANCH}

cd /data/openpilot_build
rm -rf /data/openpilot
/usr/bin/bash -e -l /data/openpilot_build/release/build_release.sh
EOF
}

push_remote() {
  ssh comma << EOF
set -e
export GIT_SSH_COMMAND="ssh -i /data/id_rsa_github -o StrictHostKeyChecking=no"
export RELEASE_BRANCH=${RELEASE_BRANCH}

cd /data/openpilot
git push -f origin ${RELEASE_BRANCH}:${RELEASE_BRANCH}
EOF
}

if ! retry clone_remote; then
  echo "Failed to clone"
  exit 1
fi

if ! retry build_remote; then
  echo "Failed to build"
  exit 1
fi

if ! retry push_remote; then
  echo "Failed to push"
  exit 1
fi

echo "Build successful"
ssh comma -t "sudo reboot" || :
