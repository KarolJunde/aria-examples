#!/bin/bash

set -x

function get_response_code() {

    port=$1

    set +e

    curl_cmd=$(which curl)
    wget_cmd=$(which wget)

    if [[ ! -z ${curl_cmd} ]]; then
        response_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${port})
    elif [[ ! -z ${wget_cmd} ]]; then
        response_code=$(wget --spider -S "http://localhost:${port}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -1)
    else
        ctx logger error "Failed to retrieve response code from http://localhost:${port}: Neither 'cURL' nor 'wget' were found on the system"
        exit 1;
    fi

    set -e

    echo ${response_code}

}

function wait_for_server() {

    port=$1
    server_name=$2

    started=false

    ctx logger info "Running ${server_name} liveness detection on port ${port}"

    for i in $(seq 1 120)
    do
        response_code=$(get_response_code ${port})
        ctx logger info "[GET] http://localhost:${port} ${response_code}"
        if [ ${response_code} -eq 200 ] ; then
            started=true
            break
        else
            ctx logger info "${server_name} has not started. waiting..."
            sleep 1
        fi
    done
    if [ ${started} = false ]; then
        ctx logger error "${server_name} failed to start. waited for a 120 seconds."
        exit 1
    fi
}

NODEJS_BINARIES_PATH=$(ctx instance runtime_properties nodejs_binaries_path)
APPLICATION_SOURCE_PATH=$(ctx instance runtime_properties application_source_path)
STARTUP_SCRIPT=$(ctx node properties startup_script)

COMMAND="${NODEJS_BINARIES_PATH}/bin/node ${APPLICATION_SOURCE_PATH}/${STARTUP_SCRIPT}"

export MONGO_HOST=$(ctx instance runtime_properties mongo_ip_address)
export MONGO_PORT=$(ctx instance runtime_properties mongo_port)

ctx logger info "MongoDB is located at ${MONGO_HOST}:${MONGO_PORT}"
ctx logger info "Starting Nodecellar"

ctx logger info "${COMMAND}"
nohup ${COMMAND} > /dev/null 2>&1 &
PID=$!

wait_for_server 3000 'Nodecellar'

# this runtime property is used by the stop-nodecellar-app.sh script.
ctx instance runtime_properties pid ${PID}

ctx logger info "Successfully started Nodecellar (${PID})"
