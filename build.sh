#!/bin/bash

DATADIR="/var/lib/postgresql/9.5/main/"
CONF="/etc/postgresql/9.5/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/9.5/bin/postgres"

if [ ! -d "/etc/postgresql/9.5/main/" ]; then

    pg_createcluster 9.5 main

    pass=postgres
    authMethod=trust

    { echo; echo "host  all all 0.0.0.0/0 trust"; } > "/etc/postgresql/9.5/main/pg_hba.conf"
    { echo; echo "local all all trust"; } >> "/etc/postgresql/9.5/main/pg_hba.conf"
    { echo; echo "host  all all 127.0.0.1/32 trust"; } >> "/etc/postgresql/9.5/main/pg_hba.conf"
    { echo; echo "host  all all ::1/128 trust"; } >> "/etc/postgresql/9.5/main/pg_hba.conf"

    sed -i "/^#listen_addresses/i listen_addresses='*'" /etc/postgresql/9.5/main/postgresql.conf
    sed -i "/^max_connections = 100/i max_connections = 200" /etc/postgresql/9.5/main/postgresql.conf
    sed -i '66s/max_connections = 100/ /g' /etc/postgresql/9.5/main/postgresql.conf

    mkdir -p /var/run/postgresql/9.5-main.pg_stat_tmp/
    touch /var/run/postgresql/9.5-main.pg_stat_tmp/global.tmp
    chown postgres:postgres /var/run/postgresql/ -R

    su postgres --command "$POSTGRES -D $DATADIR -c config_file=$CONF " 2>&1 &
fi

: ${POSTGRES_USER:=postgres}
: ${POSTGRES_DB:=$POSTGRES_USER}
export POSTGRES_USER POSTGRES_DB

if [ "$POSTGRES_DB" != 'postgres' ]; then
    psql --username postgres -c "CREATE DATABASE $POSTGRES_DB;"
    echo
fi

if [ "$POSTGRES_USER" = 'postgres' ]; then
    op='ALTER'
else
    op='CREATE'
fi

psql --username postgres -c "$op USER "$POSTGRES_USER" WITH SUPERUSER PASSWORD '$pass' ;"
echo

psql --username postgres --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker' ;"
echo

psql --username postgres -c "CREATE DATABASE docker TEMPLATE template0 ENCODING = 'UTF8' ;"
echo

psql --username postgres -d docker -f /home/postgres/*.sql
echo

wait $!
