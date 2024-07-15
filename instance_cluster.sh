#!/bin/bash 

cd "/home/lakshimi-pt7619/server/clustusers"
# the parameters to notice with default value
port_number=54321
synchronous_standby="*"
clustername="default"
repcount=1
user_name='default_user'
user_pass='user_pass'
admin_user="lakshimi-pt7619"


help()
{
    echo "-h  help"
    echo "-port port number"
    echo "-clust_name for clustername"
    echo "-rep replication count"
    echo "-user user name"
    echo "-pass password for user"

}

if [ "$1" = "" ]; then
    help
    exit 0
fi

while [ "$1" != "" ]; do
    case $1 in 
        -h ) help
            exit 0
            ;;
        -port ) shift
            port_number=$1
            ;;
        -clust_name ) shift
            clustername="$1"
            ;;
        -rep ) shift
            repcount=$1
            ;;
        -user) shift
            user_name=$1
            ;;
        -pass) shift
            user_pass=$1
            ;;
        * ) echo "invalid option"
            help
            exit 1
    esac
    shift
done

location="/home/lakshimi-pt7619/server/clustusers/${clustername}"
cd $location || exit

init_db()
{
    local data=$1
    ./app/bin/initdb -D "$data"
}

start_server()
{
    local data=$1
    ./app/bin/pg_ctl -D "$data" -l "$data/logfile" start
}

restart_server()
{
    local data=$1
    ./app/bin/pg_ctl -D "$data" restart
}

inserting_replication_table()
{
    local from=$1
    local to=$2

    psql -h localhost -p 5432 -U postgres -d postgres <<-SQL
    INSERT INTO replication_heirarchy (from_port, to_port) VALUES ($from, $to);
SQL
}

init_db "${location}/primary"

assign_port=$port_number
certif_authority="/home/lakshimi-pt7619/server/myca"
# creating server certif
openssl ecparam -name prime256v1 -genkey -noout -out "${location}/primary/server.key"
chmod og-rwx "${location}/primary/server.key"
openssl req -new -sha256 -key "${location}/primary/server.key" -out "${location}/primary/server.csr" -subj "/CN=$clustername"
chmod og-rwx "${location}/primary/server.csr"
openssl x509 -req -in "${location}/primary/server.csr" -CA "${certif_authority}/ca.crt" -CAkey "${certif_authority}/ca.key" -CAcreateserial -out "${location}/primary/server.crt" -days 3650 -sha256
chmod og-rwx "${location}/primary/server.crt"
ls -l "${location}/primary/"

# creating client certif
openssl ecparam -name prime256v1 -genkey -noout -out "${location}/primary/client.key"
openssl req -new -sha256 -key "${location}/primary/client.key" -out "${location}/primary/client.csr" -subj "/CN=$user_name"
openssl x509 -req -in "${location}/primary/client.csr" -CA "${certif_authority}/ca.crt" -CAkey "${certif_authority}/ca.key" -CAcreateserial -out "${location}/primary/client.crt" -days 3650 -sha256
chmod 0600 "${location}/primary/client.key"
chmod 0600 "${location}/primary/client.crt"

# since client and server are in the same machine we are storing in the same loc as the client stores
user_certif_dir="/home/lakshimi-pt7619/.postgresql/$user_name"
user_certif="${user_certif_dir}/client.crt"
user_key="${user_certif_dir}/client.key"

if [ ! -d "$user_certif_dir" ]; then
    mkdir -p "$user_certif_dir"
fi
mv "${location}/primary/client.crt" "$user_certif"
mv "${location}/primary/client.key" "$user_key"

#config of server
#--hba conf
echo "host replication repuser 127.0.0.1/32 scram-sha-256" >> "${location}/primary/pg_hba.conf"
echo "hostssl all ${user_name} 0.0.0.0/0 md5 clientcert=verify-full" >> "${location}/primary/pg_hba.conf"
#--postgres conf
echo "cluster_name = $clustername" >> "${location}/primary/postgresql.conf"
echo "port = $assign_port" >> "${location}/primary/postgresql.conf"
echo "listen_addresses='*'">> "${location}/primary/postgresql.conf"
echo "ssl = on" >> "${location}/primary/postgresql.conf"
echo "ssl_cert_file = 'server.crt'" >> "${location}/primary/postgresql.conf"
echo "ssl_key_file = 'server.key'" >>  "${location}/primary/postgresql.conf"
echo "ssl_ca_file = '/home/${admin_user}/server/myca/ca.crt'" >> "${location}/primary/postgresql.conf"

#starting server
start_server "${location}/primary"

echo "primary_server with $assign_port with username:$user_name and password:$user_pass" >> server_ports.txt

replication_user="repuser"
replication_password="rep_password"

./app/bin/psql -p "$assign_port" -h localhost -d postgres -U "$admin_user" <<-SQL
CREATE ROLE "$replication_user" WITH replication LOGIN PASSWORD '$replication_password';
CREATE ROLE $user_name WITH CREATEDB CREATEROLE LOGIN PASSWORD '$user_pass';


SQL
#REVOKE CREATE ON SCHEMA public FROM $user_name;
#REVOKE USAGE ON SCHEMA public FROM $user_name;

for ((i=1; i<=repcount; i++)); do
    mkdir "standby_${i}"
    chmod 700 "standby_${i}"
    ./app/bin/pg_basebackup -h localhost -U "$replication_user" -R -X stream -c fast -C -S "slot_${i}" -p $assign_port -D "standby_${i}"
    new_port=$("/home/lakshimi-pt7619/server/clustusers/port_giver.sh")
    sed -i "s/port = $assign_port/port = $new_port/" "${location}/standby_${i}/postgresql.conf"
    start_server "${location}/standby_${i}"
    echo "standby_${i} with $new_port" >> server_ports.txt
    inserting_replication_table $assign_port $new_port
    assign_port=$new_port
done

# sed -i 's/^#\(port = \).*/\1 45434/' postgresql_primary.conf
# sed -i "s/port = 45434/port = 4500/" postgresql_primary.conf
