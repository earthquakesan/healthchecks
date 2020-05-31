#!/usr/bin/env bash
IFS=$'\n\t'

MANAGE_PY=/opt/healthchecks/manage.py
IS_INIT=/data/healthchecks_initialized
STATIC_DIR=/opt/healthchecks/static-collected

if [ ! -z ${DB_HOST+x} ]; 
then 
    NUMBER_OF_RETRIES=10
    for RETRY in {1..NUMBER_OF_RETRIES}
    do
        echo "Trying to connect to the database..."
        nc -z -v ${DB_HOST} ${DB_PORT}
        if [ "$?" -eq 0 ]; then
            break
        fi
        echo "Waiting 5 seconds to reconnect"
        sleep 5
    done
else 
    echo "DB_HOST is unset, will not wait for database availability."
fi

if [ "$(ls -A ${STATIC_DIR})" ]; then
     echo "${STATIC_DIR} is not empty, will not run manage.py collectstatic"
else
    ${MANAGE_PY} collectstatic
fi

if [ ! -f "${IS_INIT}" ]; then
    ${MANAGE_PY} migrate
    touch ${IS_INIT}
fi

# start sendalerts in the background

${MANAGE_PY} sendalerts &

# start healthchecks using gunicorn
gunicorn --bind 0.0.0.0:${PORT} --workers ${GUNICORN_WORKERS} --threads ${GUNICORN_THREADS} --log-level ${LOG_LEVEL} hc.wsgi