#!/usr/bin/env bash

# https://askubuntu.com/questions/1114525/reconfigure-the-display-manager-non-interactively

set_dm() {
    DISPLAY_MANAGER="gdm3"
    DISPLAY_MANAGER_SERVICE="/etc/systemd/system/display-manager.service"
    DEFAULT_DISPLAY_MANAGER_FILE="/etc/X11/default-display-manager"

    if [ -n "${1}" ]
    then
        DISPLAY_MANAGER="$1"
    fi

    DISPLAY_MANAGER_BIN="/usr/sbin/${DISPLAY_MANAGER}"
    if [ ! -e "${DISPLAY_MANAGER_BIN}" ]
    then
        echo "${DISPLAY_MANAGER} seems not to be a valid display manager or is not installed."
        exit 1
    fi

    echo "${DISPLAY_MANAGER_BIN}" > "${DEFAULT_DISPLAY_MANAGER_FILE}"
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure "${DISPLAY_MANAGER}"
    echo set shared/default-x-display-manager "${DISPLAY_MANAGER}" | debconf-communicate &> /dev/null 

    echo -n "systemd service is set to: "
    readlink "${DISPLAY_MANAGER_SERVICE}" 

    echo -n "${DEFAULT_DISPLAY_MANAGER_FILE} is set to: "
    cat "${DEFAULT_DISPLAY_MANAGER_FILE}"

    echo -n "debconf is set to: "
    echo get shared/default-x-display-manager | debconf-communicate 
}

set_dm $1