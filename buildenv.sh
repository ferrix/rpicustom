#!/bin/bash -eu

./getdeps.sh
docker run --privileged=true -it -v $(pwd):/root ubuntu /root/mangle.sh
