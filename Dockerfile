# The FROM instruction specifies the Parent Image from which you are building. FROM instruction initializes a new build stage and sets the Base Image for subsequent instructions. Le digo el sistema operativo q quiero
FROM debian:buster
# apt = "advanced package tool" APT, is a free-software user interface that works with core libraries to handle the installation and removal of software on Debian
# apt is for the terminal and gives beautiful output while apt-get and apt-cache are for scripts and give stable, parseable output. To update the list of packages known by your system:
RUN apt-get update
# -y es para q cuando instalas algo y te pregunta cosas digas yes automáticamente, porque tu ordenador muerto no puede responder en el momento de ejecutar el dockerfile
# to install the package and all its dependencies:
RUN apt-get install -y nginx
RUN apt-get install -y vim
# In Debian 10, MariaDB, a community fork of the MySQL project, is packaged as the default MySQL variant
RUN apt-get install -y mariadb-server mariadb-client
RUN apt-get install -y php php-fpm php-common php-mysql php-gd php-cli \
	php-mbstring php-gd php-zip php-curl php-intl php-soap php-xml php-xmlrpc
RUN apt-get install -y wget
RUN wget https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN wp core download --path=var/www/wordpress --allow-root
COPY /srcs/create-mysql.bash /
COPY /srcs/nginx-wp-conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/nginx-wp-conf /etc/nginx/sites-enabled/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-all-languages.tar.gz
RUN tar xvf phpMyAdmin-4.9.5-all-languages.tar.gz
RUN mv phpMyAdmin-4.9.5-all-languages var/www/phpmyadmin
RUN chown -R www-data:www-data /var/www
COPY /srcs/self-signed.conf /etc/nginx/snippets/
#COPY /srcs/ssl-params.conf /etc/nginx/snippets/
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=ES/ST=Madrid/L=Madrid/O=Org/CN=localhost"
COPY /srcs/index.html /var/www/
COPY /srcs/background.jpg /var/www/

# bash para ejecutar comandos dentro del contenedor
CMD service nginx start && \
	service mysql start && \
	service php7.3-fpm start && \
	bash create-mysql.bash && \
	wp config create --dbname=wptest --dbuser=ana --dbpass=password \
		--path=var/www/wordpress/ --allow-root && \
	wp core install --url=localhost/wordpress --title="que tal" --admin_user=ana \
		--admin_password=password --admin_email=mi@email.com --path=var/www/wordpress/ --allow-root && \
	bash

EXPOSE 80
