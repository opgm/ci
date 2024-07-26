#!/bin/bash -e

docker build -t panda-test -f Dockerfile.openpilot .
docker run --rm panda-test panda/tests/safety/test.sh
