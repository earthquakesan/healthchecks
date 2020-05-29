#!/usr/bin/env bash
IFS=$'\n\t'

MANAGE_PY=/opt/healthchecks/manage.py
IS_INIT=/data/healthchecks_initialized

if [ ! -z ${DB_HOST+x} ]; 
then 
    NUMBER_OF_RETRIES=10
    for RETRY in {1..NUMBER_OF_RETRIES}
    do
        echo "Trying to connect to the database..."
        nc -z -v ${DB_HOST} ${DB_PORT}
        if [ "${is_connected}" -eq 0 ]; then
            break
        fi
        echo "Waiting 5 seconds to reconnect"
        sleep 5
    done
else 
    echo "DB_HOST is unset, will not wait for database availability."
fi


if [ ! -f "${IS_INIT}" ]; then
    ${MANAGE_PY} migrate
    ${MANAGE_PY} collectstatic
    touch ${IS_INIT}
fi

httpd -DFOREGROUND -X