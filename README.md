# Tomcat installation script
This script is used to install Tomcat on your Linux machine. Initialization scripts were taken from **Mitchell Anicas** [articles](#links).
### What does **not** this script do:
* Installing Java Runtime Environment(JRE).
* Setting your installed JRE and right values for RAM usage in **_init/tomcat.service(conf)_** initialization script.
* Choosing the right script for your initialization system, e.g **systemd** or **Upstart**.

### What does this script **do**:
* Installing or Updating Tomcat if URL and proper argument are provided.
* Deleting all Tomcat data that was installed by this script.

## Usage
### Installation:
To install Tomcat type the following: `sudo ./tomcatSystemd.sh -i URL`   
_**NOTE**_: Don't use _-i_ argument to update previous instance.
### Update:
To update Tomcat type the following: `sudo ./tomcatSystemd.sh -u URL`  
_**NOTE**_: Previous Tomcat instance will be moved to _/opt/tomcat.backup_. If `/opt/tomcat.backup` directory already exists then it will be removed.
#### Restore previous instance after update:
To restore previous instance after update type the following: `sudo ./tomcatSystemd.sh -r`  
_**NOTE**_: New instance will be moved to `/opt/tomcat.broken` directory.
### Deletion:
To delete Tomcat type the following: `sudo ./tomcatSystemd.sh -d`  
_**NOTE**_: Script will delete **all** the Tomcat data that was installed **by this script**, e.g tomcat dir, backup dir if exists, init script and user:group.

## Links
Many thanks to [**Mitchell Anicas**](https://www.digitalocean.com/community/users/manicas) and his articles:  
* [How To Install Apache Tomcat 8 on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-14-04)  
* [How To Install Apache Tomcat 8 on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-centos-7)
