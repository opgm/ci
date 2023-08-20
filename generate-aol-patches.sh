#!/bin/bash -e
source ci/utils.sh

rm -rf panda_master panda_pfeifer 0001-Always-On-Lateral.patch 0002-panda.patch || :
wget https://raw.githubusercontent.com/pfeiferj/openpilot/pfeifer-openpilot-patches/always-on-lateral/0001-Always-On-Lateral.patch

git fetch pfeiferj pfeifer-always-on-lateral
git checkout -f pfeiferj/pfeifer-always-on-lateral
git reset --hard pfeiferj/pfeifer-always-on-lateral

rm -rf $submodules
git submodule init
git submodule update

unsubmodule

mv panda panda_pfeifer

git fetch origin master
git checkout -f origin/master
git reset --hard origin/master

rm -rf $submodules
git submodule init
git submodule update

unsubmodule

mv panda panda_master

git diff --no-index panda_master panda_pfeifer > 0002-panda.patch || :

rm -rf panda_pfeifer panda_master
