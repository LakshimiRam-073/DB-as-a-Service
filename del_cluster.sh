#!/bin/bash

#one arg which is location of the cluster 
#used to stop the server and delete the cluster
# and second arg is for the replicataion count
location=$1
repcount=$2
cd $location

./app/bin/pg_ctl -D primary stop
rm -r primary


#-----------for backup purpose------
#---------////------------------
for (( i=1;i<=repcount; i++ )); do
	folder="standby_$i"
	standby_loc="${location}/${folder}"
	./app/bin/pg_ctl -D $standby_loc stop
	rm -r $standby_loc
done
	
cd 
rm -r $location

