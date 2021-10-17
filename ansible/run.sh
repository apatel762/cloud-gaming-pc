#!/bin/bash

# echo an error message and exit the script
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

# args: $1 = a binary you want to require e.g. tar, gpg, mail
#       $2 = a message briefly describing what you need the binary for
require() {
    command -v "$1" > /dev/null 2>&1 \
        || oops "you do not have '$1' installed or its not in your PATH; needed for: $2"
}

require ansible
require ansible-playbook

# store the directory of this script
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# use `set -x` to log all commands from here onwards
set -x
HOSTS="$ROOTDIR/hosts.ini"
PLAYBOOK="$ROOTDIR/playbook.yml"
USER=amigo
PRIVATE_KEY_FILE="$ROOTDIR/../workstation.pem"

# runs Ansible playbook using our user.
ansible-playbook \
    --inventory "$HOSTS" "$PLAYBOOK" \
    --private-key "$PRIVATE_KEY_FILE" \
    --user "$USER"

exit 0
