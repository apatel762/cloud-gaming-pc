#!/usr/bin/env bash

apt-get update

# create the user
adduser --disabled-password --gecos "" ${user}

%{ if give_sudo }
# give passwordless sudo access to the user
usermod -a -G sudo ${user}
echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/00-cloud-workstation
%{ endif }

# set up the authorised SSH key to include the one Terraform generates
mkdir /home/${user}/.ssh
touch /home/${user}/.ssh/authorized_keys
echo "${authorised_key}" >> /home/${user}/.ssh/authorized_keys

# restrict file and folder ownership
chown -R ${user}:${user} /home/${user}/.ssh
chmod -R go-rx /home/${user}/.ssh

# ---------------------------------------------------------------------
# stuff that's needed for rootless docker

apt-get install -y uidmap