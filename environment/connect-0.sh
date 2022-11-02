#!/usr/bin/env bash

source include.sh

${KAFKA_DIR}/bin/connect-distributed.sh ${CONNECT_CONFIG_DIR}/worker-0.properties > /tmp/connect-0.log 2>&1 &
