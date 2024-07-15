#!/bin/bash

cd 
cd /home/lakshimi-pt7619/server/clustusers
clust_name=$1
if [ -d $clust_name ];then
	echo "Username $clust_name already have a cluster"
	exit 1
fi
mkdir -p "${clust_name}"
