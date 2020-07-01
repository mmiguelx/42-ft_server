FROM debian:buster

RUN apt update -y \
	&& apt upgrade -y \
	&& apt-get install sudo nginx mariadb-server php-fpm php-mysql php-json php-mbstring -y \
	&& mkdir /var/www/server

ADD /srcs/phpMyAdmin /var/www/server/phpMyAdmin
ADD /srcs/wordpress /var/www/server/wordpress

COPY /srcs/server.conf /etc/nginx/sites-available/server.conf
COPY /srcs/server.crt /etc/ssl/certs/server.crt
COPY /srcs/server.key /etc/ssl/private/server.key
COPY /srcs/phpMyAdmin.conf /etc/nginx/conf.d/phpMyAdmin.conf

RUN ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf \
	&& rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default \
	&& service nginx start \
	&& service mysql start \
	&& mariadb -u root --password= < /var/www/server/phpMyAdmin/tmp/init.sql \
	&& mariadb wordpress -u root --password= < /var/www/server/phpMyAdmin/tmp/localhost.sql \
	&& sudo chmod 777 /var/www/server \
	&& chown -R www-data:www-data /var/www/server \
	&& service nginx reload

CMD service nginx start \
	&& service mysql start \
	&& service php7.3-fpm start \
	&& bash
