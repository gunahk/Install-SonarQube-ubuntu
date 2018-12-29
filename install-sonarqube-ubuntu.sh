#!/bin/bash

#######################################
# Bash script to install a SonarQube in ubuntu
# Author: Subhash (serverkaka.com)

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check port 9000 is Free or Not
netstat -ln | grep ":9000 " 2>&1 > /dev/null
if [ $? -eq 1 ]; then
     echo go ahead
else
     echo Port 9000 is allready used
     exit 1
fi

# Prerequisite
apt-get install unzip -y

# Install Java if not allready Installed
if java -version | grep -q "java version" ; then
  echo "Java Installed"
else
  sudo add-apt-repository ppa:webupd8team/java -y  && sudo apt-get update -y  && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && sudo apt-get install oracle-java8-installer -y && echo JAVA_HOME=/usr/lib/jvm/java-8-oracle >> /etc/environment && echo JRE_HOME=/usr/lib/jvm/java-8-oracle/jre >> /etc/environment && source /etc/environment
fi

# Install Postgresql
apt update -y
apt install postgresql postgresql-contrib -y
sed -i -e '1ilocal    postgres     postgres     peer\' /etc/postgresql/10/main/pg_hba.conf

# Set Postgres user Password
echo "postgres:postgres" | chpasswd
echo "postgres" | passwd --stdin postgres
service postgresql restart
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
sudo systemctl enable postgresql

# Create and Configure Database
su - postgres -c "createuser sonar"
sudo -u postgres psql -c "ALTER USER sqube WITH ENCRYPTED password '654321Ab';"
sudo -u postgres psql -c "CREATE DATABASE sqube OWNER sqube;"

# Install SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.2.1.zip
unzip sonarqube-7.2.1.zip -d /opt
sudo mv /opt/sonarqube-7.2.1 /opt/sonarqube

# clean Downloaded file
rm sonarqube-7.2.1.zip

# Configure SonarQube
cd /opt/sonarqube/conf
rm sonar.properties
wget https://s3.amazonaws.com/serverkaka-pubic-file/sonarqube/sonar.properties

# Configure Systemd service
cd /etc/systemd/system/
wget https://s3.amazonaws.com/serverkaka-pubic-file/sonarqube/sonar.service
systemctl start sonar

# Enable the SonarQube service to automatically start at boot time.
systemctl enable sonar

#To check if the service is running, run:
systemctl status sonar

echo "Sonarqube is successfully installed at /opt/sonarqube" For Aceess sonarqube Go to http://localhost:9000/
echo "you can start and stop sonarqube using command : sudo service sonar stop|start|status|restart"
