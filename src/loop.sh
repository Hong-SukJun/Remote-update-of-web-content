#!/bin/sh
#
sys_meshinfo=$(cat /update/meshinfo.php)
sys_project=$(cat /update/project)
sys_ftp=$(cat /update/ftp)
if [ "$sys_project" = "none" ] 
   then
      echo "set sys_project"
      sys_project=$(cat /usr/local/config/defaults/user-config.json | jq -r '.project_name')
      echo $sys_project > /update/project
      sys_ftp=$(cat /usr/local/config/defaults/user-config.json | jq -r '.ftp_link')
      echo $sys_ftp> /update/ftp
      sys_meshinfo=$(cat /usr/local/config/defaults/user-config.json | jq -r '.meshname')
      echo "<?php header(\"Access-Control-Allow-Origin: *\"); echo($sys_meshinfo)  ?>" > /update/meshinfo.php
fi

cd /update
first_start=0

while true
do
   net_contents_ver=$(curl $sys_ftp/$sys_project/content/ver.php)
   net_ssl_ver=$(curl $sys_ftp/$sys_project/ssl/ver.php)
   net_apache_ver=$(curl $sys_ftp/$sys_project/apache/ver.php)
   sys_contents_ver=$(cat /update/contents_ver)
   sys_ssl_ver=$(cat /update/ssl_ver)
   sys_apache_ver=$(cat /update/apache_ver)
   if [ "$first_start" = "0" ] 
   then
      echo "-------- first start -----------"
      sys_project=$(cat /usr/local/config/defaults/user-config.json | jq -r '.project_name')
      sys_ftp=$(cat /usr/local/config/defaults/user-config.json | jq -r '.ftp_link')
      sys_meshinfo=$(cat /usr/local/config/defaults/user-config.json | jq -r '.meshname')
      service apache2 start
      first_start=1
   fi
   echo "-------- contents update check -----------"
   echo "net_ver : " $net_contents_ver
   echo "sys_ver : " $sys_contents_ver
   if [ "$net_contents_ver" = "$sys_contents_ver" ] 
   then
      echo "newest version"
   else
      echo "update need"
      echo "-------- update start -----------"
      wget -P /update/tmp $sys_ftp/$sys_project/content/$sys_meshinfo.zip
      unzip /update/tmp/$sys_meshinfo.zip -d /update/tmp
      rm -rf /var/www/html/*
      \cp -Rf /update/tmp/html /var/www
      rm -rf /update/tmp/*
      rm -rf /var/www/html/meshinfo.php
      ln -s /update/meshinfo.php /var/www/html/meshinfo.php
######################################################################################
      rm -rf /var/www/html/ver.php
      wget -P /var/www/html/ $sys_ftp/$sys_project/content/ver.php
######################################################################################   
      echo $net_contents_ver > /update/contents_ver
 
      echo "-------- update done -----------"  
   fi
   #
   echo "-------- ssl update check -----------"
   echo "net_ver : " $net_ssl_ver
   echo "sys_ver : " $sys_ssl_ver
   if [ "$net_ssl_ver" = "$sys_ssl_ver" ] 
   then
      echo "newest version"
   else
      echo "update need"
      echo "-------- update start -----------"
      wget -P /update/tmp $sys_ftp/$sys_project/ssl/ssl.zip
      unzip /update/tmp/ssl.zip -d /update/tmp
      \cp -Rf /update/tmp/veea.crt.pem /etc/apache2/
      \cp -Rf /update/tmp/veea.key.pem /etc/apache2/
      rm -rf /update/tmp/*
      apachectl -k stop
      sleep 1
      service apache2 start
      echo $net_ssl_ver > /update/ssl_ver
   fi
   echo "-------- ssl update done --------"
   #
   echo "-------- apache setting update check -----------"
   echo "net_ver : " $net_apache_ver
   echo "sys_ver : " $sys_apache_ver
   if [ "$net_apache_ver" = "$sys_apache_ver" ] 
   then
      echo "newest version"
   else
      echo "update need"
      echo "-------- update start -----------"
      wget -P /update/tmp $sys_ftp/$sys_project/apache/apache.zip
      unzip /update/tmp/apache.zip -d /update/tmp
      rm -rf /etc/apache2/sites-available/000-default.conf
      \cp -Rf /update/tmp/000-default.conf /etc/apache2/sites-available
      rm -rf /etc/apache2/ports.conf
      \cp -Rf /update/tmp/ports.conf /etc/apache2
      rm -rf /etc/apache2/apache2.conf
      \cp -Rf /update/tmp/apache2.conf /etc/apache2
      rm -rf /update/tmp/*
      apachectl -k stop
      sleep 1
      service apache2 start
      echo $net_apache_ver > /update/apache_ver
   fi
   echo "-------- apache setting update done --------"
   sleep 60
done