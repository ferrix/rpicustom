#!/bin/bash -eu

./getdeps.sh
docker run --privileged=true -it -v $(pwd):/root imagebuilder /root/mangle.sh
