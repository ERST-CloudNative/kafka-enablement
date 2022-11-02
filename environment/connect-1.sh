#!/usr/bin/env bash

source include.sh

${KAFKA_DIR}/bin/connect-distributed.sh ${CONNECT_CONFIG_DIR}/worker-1.properties > /tmp/connect-1.log 2>&1 &
