#!/bin/bash

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE wptest;
CREATE USER 'ana'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wptest.* TO 'ana'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
