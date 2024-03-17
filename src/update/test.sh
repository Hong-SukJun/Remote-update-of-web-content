#!/bin/sh
#
cd /update
first_start=0
net_contents_ver=$(curl https://cloud.sc-lab.kr/nowon_nevi/contents/ver.php)
net_ssl_ver=$(curl https://cloud.sc-lab.kr/nowon_nevi/ssl/ver.php)
sys_contents_ver=$(cat /update/contents_ver)
sys_ssl_ver=$(cat /update/ssl_ver)
while true
do
   if [ "$first_start" = "0" ] 
   then
      echo "-------- first start -----------"
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
      wget -P /update/tmp https://cloud.sc-lab.kr/nowon_nevi/contents/1.zip
      unzip /update/tmp/1.zip -d /update/tmp
      cp -R /update/tmp/html /var/www
      rm -rf /update/tmp/*
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
      wget -P /update/tmp https://cloud.sc-lab.kr/nowon_nevi/ssl/ssl.zip
      unzip /update/tmp/ssl.zip -d /update/tmp
      cp -R /update/tmp/veea.crt.pem /etc/apache2/
      cp -R /update/tmp/veea.key.pem /etc/apache2/
      rm -rf /update/tmp/*
      service apache2 stop
      # service apache2 start
      echo $net_ssl_ver > /update/ssl_ver
   fi
   echo "-------- ssl update done --------"
   sleep 5
done