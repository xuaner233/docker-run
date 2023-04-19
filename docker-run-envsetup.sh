#!/usr/bin/env bash
#
set -e

echo -e "Setup env for user: $DUSER\n"

# Align timezone with host
if [[ -n "$TIMEZONE" ]]; then
    echo "$TIMEZONE" > /etc/timezone
    ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata
fi

if [ -n "$DGROUP" ]; then
    # Change current primary group id to host group id
    groupdel "$DGROUP" &>/dev/null || true
    groupadd -og "$DGID" "$DGROUP"
fi

# Check if 'sudo' command is installed
if [ ! command -v sudo &> /dev/null ]; then
    echo "'sudo' could not be found, install now..."
    apt update && apt install -y sudo
fi

if [ -n "$DUSER" ]; then
    # Add user
    useradd -M -u "$DUID" -g "$DGID" -d "/home/$DUSER" -s /bin/bash "$DUSER"

    # sudo without password
    echo "${DUSER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Before here, users are root, now change to actual user
if [[ "$@" ]]; then
    echo $@
    sudo -u $DUSER /bin/bash --rcfile /home/$DUSER/.bashrc -c "$@"
else
    sudo -u $DUSER /bin/bash
fi

# exit when user exit from command
echo -e "Exit from docker\n"
exit $?
