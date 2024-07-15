#!/bin/bash

#invoking apache for the required file

version=$1
cd /var/www/html/install_instances/

wget https://ftp.postgresql.org/pub/source/v$version/postgresql-$version.tar.gz
tar -xvf postgresql-$version.tar.gz
temp_loc="postgresql-$version"
cd $temp_loc 

./configure --prefix=/var/www/html/install_instances/app_$version --with-openssl
make 
make install
#taking one step back
cd ..
tar -zcf app_$version.tar.gz app_$version

#remove the unwanted tar and the and the postgresfile
rm  postgresql-$version.tar.gz
rm -r postgresql-$version
rm -r app_$version