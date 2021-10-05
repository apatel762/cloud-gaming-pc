#!/bin/bash

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
# install apache guacamole natively
# https://guacamole.apache.org/doc/gug/installing-guacamole.html

# set up Apache Tomcat server
apt-get -y install openjdk-11-jdk
useradd -m -U -d /opt/tomcat -s /bin/false tomcat

mkdir -p ~/tmp-tomcat

TOMCAT="apache-tomcat-9.0.54"
wget -P ~/tmp-tomcat -- "https://downloads.apache.org/tomcat/tomcat-9/v9.0.54/bin/$TOMCAT.tar.gz"
mkdir -p /opt/tomcat
tar -xzf "$HOME/tmp-tomcat/$TOMCAT.tar.gz" -C /opt/tomcat/
mv "/opt/tomcat/$TOMCAT" /opt/tomcat/tomcatapp
chown -R tomcat: /opt/tomcat
chmod u+x /opt/tomcat/tomcatapp/bin/*.sh

cat <<'EOF' > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"

Environment="CATALINA_BASE=/opt/tomcat/tomcatapp"
Environment="CATALINA_HOME=/opt/tomcat/tomcatapp"
Environment="CATALINA_PID=/opt/tomcat/tomcatapp/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/tomcatapp/bin/startup.sh
ExecStop=/opt/tomcat/tomcatapp/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# set up Guac
apt-get -y install         \
    make                   \
    libcairo2-dev          \
    libjpeg-turbo8-dev     \
    libpng-dev             \
    libtool-bin            \
    libossp-uuid-dev       \
    libavcodec-dev         \
    libavformat-dev        \
    libavutil-dev          \
    libswscale-dev         \
    freerdp2-dev           \
    libpango1.0-dev        \
    libssh2-1-dev          \
    libvncserver-dev       \
    libwebsockets-dev      \
    libpulse-dev           \
    libssl-dev             \
    libvorbis-dev          \
    libwebp-dev

mkdir -p ~/tmp-guac
cd ~/tmp-guac

GUAC_SERVER="guacamole-server-1.3.0"
wget "https://dlcdn.apache.org/guacamole/1.3.0/source/$GUAC_SERVER.tar.gz"
wget "https://downloads.apache.org/guacamole/1.3.0/source/$GUAC_SERVER.tar.gz.sha256"
sha256sum --check "$GUAC_SERVER.tar.gz.sha256" > "check-for-$GUAC_SERVER"
tar -xzf "$GUAC_SERVER.tar.gz"
cd "$GUAC_SERVER"

./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

cd ..

GUAC_CLIENT="guacamole-1.3.0"
wget "https://dlcdn.apache.org/guacamole/1.3.0/binary/$GUAC_CLIENT.war"
wget "https://downloads.apache.org/guacamole/1.3.0/binary/$GUAC_CLIENT.war.sha256"
sha256sum --check "$GUAC_CLIENT.war.sha256" > "check-for-$GUAC_CLIENT"
mv "$GUAC_CLIENT.war" guacamole.war
cp guacamole.war -t /opt/tomcat/tomcatapp/webapps

systemctl restart tomcat
