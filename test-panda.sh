#!/bin/bash -e

ci/deploy.sh
ssh comma << 'ENDSSH'
  cd /data/openpilot/panda
  scons -j$(nproc) || exit 1

  cd /data/openpilot
  python3 panda/board/flash.py
  python3 -m pytest panda/tests/safety/test_gm.py

ENDSSH
