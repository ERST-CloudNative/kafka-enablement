#!/usr/bin/env bash

source include.sh

export KAFKA_OPTS="-Djava.security.auth.login.config=${BROKER_CONFIG_DIR}/jaas.config"; \
    ${KAFKA_DIR}/bin/kafka-server-start.sh ${BROKER_CONFIG_DIR}/server-4.properties > /tmp/kafka-4.log 2>&1 &
