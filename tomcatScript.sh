#!/bin/bash

# Variables for passed arguments
# arg is for action, i.e -i to install, -u to update, -d to delete
# url is for URL to download Tomcat
arg="$1"
url="$2"

# This function is used to stop tomcat service before update or deletion
function serviceStop {
    if [[ $(ps -u tomcat | grep java) != 0 ]]; then
        initctl stop tomcat
        echo "Service stoped. Continue..."
    else
        echo "Service not running. Continue..."
    fi
}

# This function is used to set proper permissions for tomcat:tomcat(user:group)
# in Tomcat directory
function permissions {
    echo "Setting permissions..."
    cd /opt/tomcat
    chown -R tomcat:tomcat conf/ work/ temp/ logs/ webapps/
    chmod 640 conf/*
    cd - > /dev/null
}

# This function is used to download and unpack Tomcat
# also this function removes basic Tomcat webapps, e.g ROOT, manager
function download {
    if [ -d /opt/tomcat ]; then
        if [ -d /opt/tomcat.backup ]; then
            rm -r /opt/tomcat.backup
            mv /opt/tomcat /opt/tomcat.backup
        else
            mv /opt/tomcat /opt/tomcat.backup
        fi
    fi
    if ! [ $url ]; then
        echo "Please provide download URL for Tomcat with *.tar.gz"
        exit 0
    fi
    echo "Downloading..."
    wget -O /tmp/tomcat.tar.gz $url
    mkdir /opt/tomcat
    echo "Unpacking Tomcat..."
    tar -zxvf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1 > /dev/null
    rm /tmp/tomcat.tar.gz
    rm -r /opt/tomcat/webapps/*
}

# This function is used for Tomcat installation
function install {
    echo "Installing Tomcat..."
    if [ -d /opt/tomcat ]; then
        echo "/opt/tomcat is used. Backup current installation or use -u to update"
        exit 0
    fi
    download
    echo "Adding user tomcat..."
    groupadd tomcat
    useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
    permissions
    cp init/tomcat.conf /etc/init/
    echo "Initializing Tomcat..."
    initctl reload-configuration
    initctl start tomcat
    echo "Finished"
    exit 0
}

# This function is used for Tomcat updates
function update {
    serviceStop
    echo "Updating Tomcat..."
    download
    rm -r /opt/tomcat/conf/*
    cp -r /opt/tomcat.backup/webapps /opt/tomcat/
    cp -r /opt/tomcat.backup/conf/* /opt/tomcat/conf/
    permissions
    echo "Starting Tomcat..."
    initctl start tomcat
    echo "Finished"
    exit 0
}

# This function is used for complete removal of Tomcat from the system
function delete {
	read -p "Are you sure you want to completely remove Tomcat (also backup)? y(Y) or n(N) : " INPUT
	case $INPUT in
		[Yy]* )
            serviceStop
            initctl reload-configuration
            echo "Deleting user tomcat..."
            userdel tomcat
            echo "Deleting tomcat dirs..."
            if [[ -d /opt/tomcat && -d /opt/tomcat.backup ]]; then
                rm -r /opt/tomcat
                rm -r /opt/tomcat.backup
            elif [ -d /opt/tomcat ]; then
                rm -r /opt/tomcat
            fi
            echo "Deleteing tomcat init script..."
            rm /etc/init/tomcat.conf
            echo "Finished"
            exit 0
        ;;
		[Nn]* )
            echo "Abort"
            exit 0
        ;;
	    * )
	       echo "Please enter y(Y) or n(N)"
           delete
	    ;;
	esac
}

# This function is used to restore previous installation
function restore {
    serviceStop
    if [ -d /opt/tomcat.backup ]; then
        if [ -d /opt/tomcat ]; then
            mv /opt/tomcat /opt/tomcat.broken
            cp -r /opt/tomcat.backup /opt/tomcat
            permissions
            initctl start tomcat
            echo "Previous Tomcat installation restored"
            exit 0
        else
            cp -r /opt/tomcat.backup /opt/tomcat
            permissions
            initctl start tomcat
            echo "Previous Tomcat installation restored"
            exit 0
        fi
    else
        echo "Backup directory is missing! Abort..."
        exit 0
    fi
}

# case construction that decides what action will be used, e.g
# installation, update or deletion
if [[ $(id -u) = "0" ]]; then
    case $arg in
        -i)
            install
        ;;
        -u)
            update
        ;;
        -d)
            delete
        ;;
        -r)
            restore
        ;;
        *)
            echo "Use -i URL to install, -u URL to update, -d to delete"
            exit 0
    esac
else
    echo "Please run script as root. Exiting..."
    exit 0
fi
