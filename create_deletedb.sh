#!/bin/bash

cd ~
# The parameters to notice with default value
port_number=9090
synchronous_standby="*"
db_name="default"
user_name='default_user'
user_pass='user_pass'
location="/home/lakshimi-pt7619/server/dbusers/"
num_sch=1
admin_user="lakshimi-pt7619"
del='no'

help() {
    echo "-h  help"
    echo "-nsch no of schema required"
    echo "-db_name for database name"
    echo "-user user name"
    echo "-pass user password"
    echo "-port port number"
    echo "-delete 'yes' for delete 'no' for not delete"
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
        -nsch ) shift
            num_sch=$1
            ;;
        -db_name ) shift
            db_name="$1"
            ;;
        -user) shift
            user_name=$1
            ;;
        -port) shift
            port_number=$1
            ;;
        -pass) shift
            user_pass=$1
            ;;
        -delete) shift
            del=$1
            ;;
        * ) echo "invalid option"
            help
            exit 1
            ;;
    esac
    shift
done

cd "$location"

delete_db() {
    echo "Deleting... DB"
    psql -h localhost -U "$admin_user" -d postgres -p "$port_number" <<SQL
DROP DATABASE IF EXISTS $db_name WITH (FORCE);
SQL
}

create_db() {
    echo "hostssl ${db_name} ${user_name} 0.0.0.0/0 scram-sha-256 clientcert=verify-full" >> "${location}/data/pg_hba.conf"
    certif_authority="/home/lakshimi-pt7619/server/myca"
    # creating client certif
	openssl ecparam -name prime256v1 -genkey -noout -out data/client.key
	openssl req -new -sha256 -key data/client.key -out data/client.csr -subj "/CN=$user_name"
	openssl x509 -req -in data/client.csr -CA "${certif_authority}/ca.crt" -CAkey "${certif_authority}/ca.key" -CAcreateserial -out data/client.crt -days 3650 -sha256
	chmod 0600 data/client.key
	chmod 0600 data/client.crt
	
	#since client and server are in the same machine we are storing in the same loc as the client stores
	user_certif_dir="/home/lakshimi-pt7619/.postgresql/$user_name"
	user_certif="${user_certif_dir}/client.crt"
	user_key="${user_certif_dir}/client.key"
	
	if [ ! -d "$user_certif_dir" ]; then
	    mkdir -p "$user_certif_dir"
	fi
	mv "data/client.crt" "$user_certif"
	mv "data/client.key" "$user_key"
	
	
    #psql config
    psql -h localhost -U "$admin_user" -d postgres -p "$port_number" <<SQL
CREATE ROLE $user_name LOGIN PASSWORD '$user_pass';
CREATE DATABASE $db_name OWNER $user_name;
GRANT CREATE ON DATABASE $db_name TO $user_name;

\c $db_name

CREATE TABLE schema_utilize(username text, schema_remaining int);
INSERT INTO schema_utilize (username, schema_remaining) VALUES ('$user_name', $num_sch);
GRANT SELECT ON TABLE schema_utilize TO $user_name;

CREATE OR REPLACE FUNCTION create_schema_limiter()
RETURNS event_trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS \$function\$
DECLARE
    curr_user TEXT='$user_name';
    curr_rem INT;
    limit INT=$num_sch;
BEGIN
    RAISE NOTICE 'user: %', curr_user;
    SELECT schema_remaining INTO curr_rem FROM schema_utilize WHERE username = curr_user;

    IF tg_tag = 'CREATE SCHEMA' THEN
        IF curr_rem <= 0 THEN
            RAISE EXCEPTION 'user % has reached the schema creation limit', curr_user;
        ELSE
            UPDATE schema_utilize SET schema_remaining = curr_rem - 1 WHERE username = curr_user;
            RAISE NOTICE 'remaining schemas: %', curr_rem - 1;
        END IF;
    ELSIF tg_tag = 'DROP SCHEMA' THEN
        UPDATE schema_utilize SET schema_remaining = curr_rem + 1 WHERE username = curr_user;
        RAISE NOTICE 'remaining schemas: %', curr_rem + 1;
    END IF;
END;
\$function\$;

CREATE EVENT TRIGGER tg_create_schema_limiter
ON ddl_command_end
WHEN TAG IN ('CREATE SCHEMA', 'DROP SCHEMA')
EXECUTE PROCEDURE create_schema_limiter();

-- Test purpose
CREATE TABLE ddl_log (
    log_id SERIAL PRIMARY KEY,
    command_tag_or_dropped_obj TEXT,
    object_id OID,
    object_type TEXT,
    schema_name TEXT,
    ddl_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT SELECT ON TABLE ddl_log TO $user_name;

CREATE OR REPLACE FUNCTION log_ddl_command() RETURNS event_trigger AS \$\$
DECLARE
    rec RECORD;
BEGIN
    IF TG_EVENT = 'ddl_command_end' THEN
        FOR rec IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
            INSERT INTO ddl_log (command_tag_or_dropped_obj, object_id, object_type, schema_name)
            VALUES (rec.command_tag, rec.objid, rec.object_type, rec.schema_name);
        END LOOP;
    ELSIF TG_EVENT = 'sql_drop' THEN
        FOR rec IN SELECT * FROM pg_event_trigger_dropped_objects() LOOP
            INSERT INTO ddl_log (command_tag_or_dropped_obj, object_id, object_type, schema_name)
            VALUES (rec.object_name, rec.objid, rec.object_type, rec.schema_name);
        END LOOP;
    END IF;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE EVENT TRIGGER ddl_log_trigger_end
ON ddl_command_end
EXECUTE FUNCTION log_ddl_command();

CREATE EVENT TRIGGER ddl_log_trigger_drop
ON sql_drop
EXECUTE FUNCTION log_ddl_command();
SQL

app/bin/pg_ctl -D data reload
}

if [ "$del" == "yes" ]; then
    delete_db
else
    create_db
fi
