#!/bin/bash

#first arg is version
#second arg is location
cd ~
#check if theres is 2 args

if [ "$#" != "2" ];then
	echo "No of arguments is two 1-> version ,2-> location"
	exit 1
fi

version=$1
loc=$2
cluster_loc="/home/lakshimi-pt7619/server/clustusers/$loc"
cd  $cluster_loc || mkdir -p $cluster_loc


#first check if the version is already installed in the location
filename="http://localhost/install_instances/app_${version}.tar.gz"
if ! wget --spider "$filename" 2>/dev/null; then
	echo "File app_${version}.tar.gz not  exists..."
	/home/lakshimi-pt7619/server/clustusers/invoke_server.sh $version
else
	echo "File exists"
	
fi


wget $filename
tar -xvf app_$version.tar.gz
mv app_$version app
rm app_$version.tar.gz

