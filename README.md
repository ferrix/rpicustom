# Customize Raspbian Lite images

These scripts download the latest Raspbian Lite image and prepare
it for use with Docker. To keep the machine clean and in order to
work around using Windows or OS X desktops, the whole operation is
executed within an Ubuntu container.

## Configuration

Add your authorized keys and default password into config directory

    mkdir -p config
    cat ~/.ssh/id_rsa.pub >> config/authorized_keys
    echo "mydefaultpassword" > config/defaultpass
