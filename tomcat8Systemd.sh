#!/bin/bash

key="$1"
LINK="$2"

#function that stopping tomcat service
function serviceStop {
    systemctl stop tomcat.service
    echo Service stoped. Continue...
}

function permissions {
    cd /opt/tomcat
    chown -R tomcat:tomcat conf
    chmod 755 conf
    chmod 744 conf/*
    chown -R tomcat:tomcat work/ temp/ logs/ webapps/
    cd -
}

# function that download and unpack tomcat
function download {
    if [ -d /opt/tomcat ]; then
        mv /opt/tomcat /opt/tomcat.bak
    fi
    if ! [ $LINK ]; then
        echo "Please provide download link for Tomcat with *.tar.gz"
        exit 0
    fi
    wget -O /tmp/tomcat.tar.gz $LINK
    mkdir /opt/tomcat
    tar -zxvf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1
    rm /tmp/tomcat.tar.gz
}

# function that install tomcat
function install {
    serviceStop
    download
    groupadd tomcat
    useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
    permissions
    cp init/tomcat.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl start tomcat
    systemctl enable tomcat
    exit 0
}

# function that update tomcat
function update {
    serviceStop
    download
    cp -r /opt/tomcat.bak/webapps /opt/tomcat/
    permissions
    systemctl start tomcat
    exit 0
}

# function that delete tomcat
function delete {
    serviceStop
    groupdel tomcat
    userdel tomcat
    rm -r /opt/tomcat
    rm -r /opt/tomcat.bak
    systemctl disable tomcat
    rm /etc/systemd/system/tomcat.service
    exit 0
}

if [[ $(id -u) = "0" ]]; then
    case $key in
        -i|--install)
            install
        ;;
        -u|--update)
            update
        ;;
        -d|--delete)
            delete
        ;;
        *)
            echo "Use -i|--install to install, -u|--update to update, -d|--delete"
            exit 0
    esac
else
    echo Please run script as root. Exiting...
    exit 0
fi
