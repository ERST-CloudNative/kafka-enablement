#!/usr/bin/env bash

source include.sh

${KAFKA_DIR}/bin/connect-distributed.sh ${CONNECT_CONFIG_DIR}/worker-2.properties > /tmp/connect-2.log 2>&1 &
