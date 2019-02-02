#!/bin/bash -eu

mkdir -p vendor dist

if [ -f vendor/latest_image  ] && [ ! -f vendor/`cat vendor/latest_image` ] || [ ! -f vendor/latest_image ]; then
    pushd vendor
    curl https://downloads.raspberrypi.org/raspbian_lite_latest -LOJR -w "%{filename_effective}" > latest_image
    echo "Downloaded $(cat latest_image)"
    popd
else
    echo "Using $(cat vendor/latest_image)"
fi
