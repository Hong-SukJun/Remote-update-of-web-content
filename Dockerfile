#BEGIN arm32v7
FROM arm32v7/ubuntu:20.04 as build
#END

#BEGIN arm64v8
FROM arm64v8/ubuntu:20.04 as build
#END

WORKDIR /app

RUN \
        DEBIAN_FRONTEND=noninteractive apt-get update -y && \
        DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 php php-sqlite3 sqlite3 && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y vim && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y curl && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y zip unzip && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y dos2unix && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y wget && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y jq

RUN \ 
	rm -rf /etc/apache2/ports.conf && \
	rm -rf /etc/apache2/sites-enabled/000-default.conf && \
	rm -rf /etc/apache2/sites-available && \
	rm -rf /var/www/html && \
	mkdir /update

COPY /src/apache2/ports.conf /etc/apache2/
COPY /src/apache2/sites-enabled /etc/apache2/sites-available
COPY /src/veea.crt.pem /etc/apache2/
COPY /src/veea.key.pem /etc/apache2/
COPY /src/html /var/www/html
COPY /src/loop.sh /app
COPY /src/update /update


RUN \
	cd /etc/apache2/sites-enabled && \
	ln -s ../sites-available/000-default.conf ./000-default.conf && \
	a2enmod ssl && \
	a2ensite 000-default.conf && \
	chmod -R 777 /var/log/apache2 && \
	chmod -R 777 /var/run/apache2 && \
	chmod -R 777 /update/contents_ver && \
	chmod -R 777 /update/project && \
	chmod -R 777 /update/ssl_ver && \
	chmod -R 777 /update/meshinfo.php && \
	chmod -R 777 /update/tmp && \
	chmod -R 777 /update/ftp && \
	chmod -R 777 /update/apache_ver && \
	chmod -R 777 /var/www/ && \
	chmod -R 777 /etc/apache2 && \
	chmod -R 777 /app/loop.sh && \
	echo "ServerName veea_local.sc-lab.kr" >> /etc/apache2/apache2.conf
 	#dos2unix /update/test.sh && \

EXPOSE 9600

CMD ["/app/loop.sh"]

