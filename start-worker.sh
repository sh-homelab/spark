#!/usr/bin/env bash

export SPARK_HOME=${SPARK_HOME:-/opt/spark}

. $SPARK_HOME/sbin/spark-config.sh
. $SPARK_HOME/bin/load-spark-env.sh

export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}

export SPARK_MASTER=${SPARK_MASTER:?Fatal error: Undefined SPARK_MASTER variable}

set -xe
$SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker --webui-port $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER
