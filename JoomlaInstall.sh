#!/bin/bash
#Install MySQL 5.7 service
yum install mysql57-server mysql57 -y

#Install PHP and HTTPD service
yum install php71-pdo php71-mcrypt php71-mbstring php71-mysqlnd php71-curl php71-intl php71-cli php71 httpd24-devel httpd24-tools httpd24 -y

#Make HTTPD and MySQL service to start on boot.
chkconfig httpd on
chkconfig mysqld on

#Start HTTPD and MySQL service
/etc/init.d/httpd start
/etc/init.d/mysqld start

#Set up MySQL root password.
password=`/opt/aws/bin/ec2-metadata -i | awk '{print $2}'`
/usr/libexec/mysql57/mysqladmin -u root password $password
echo $password

#Setup new database and logins for Joomla site.
DBNAME=`/opt/aws/bin/ec2-metadata -i | awk '{print $2}' | tail -c 3`
DBUSER=`/opt/aws/bin/ec2-metadata -i | awk '{print $2}' | head -c 3`
PASS=`openssl rand -base64 12`
NEWDBNAME=joomla$DBNAME
echo $NEWDBNAME
NEWDBUSER=joomla$DBUSER

mysql -u root -p$password -e "CREATE DATABASE ${NEWDBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -u root -p$password -e "CREATE USER '${NEWDBUSER}'@'localhost' IDENTIFIED BY '${PASS}';"
mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON ${NEWDBNAME}.* TO '${NEWDBUSER}'@'localhost';"
mysql -u root -p$password -e "FLUSH PRIVILEGES;"
sudo -u ec2-user touch ~/dblogin.txt
echo dbname=$NEWDBNAME > /home/ec2-user/dblogin.txt
echo dbusername=$NEWDBUSER >> /home/ec2-user/dblogin.txt
echo dbpassword=$PASS >> /home/ec2-user/dblogin.txt
echo $PASS
echo [client] > /root/.my.cnf
echo user=root >> /root/.my.cnf
echo password="\"$password"\" >> /root/.my.cnf


#Install zip and unzip commands
yum install zip unzip -y
cd /var/www/html
wget https://downloads.joomla.org/cms/joomla3/3-8-6/Joomla_3-8-6-Stable-Full_Package.zip
unzip Joomla_3-8-6-Stable-Full_Package.zip
chgrp apache /var/www/html -R
chmod 2775 /var/www/html -R
rm -f Joomla_3-8-6-Stable-Full_Package.zip
