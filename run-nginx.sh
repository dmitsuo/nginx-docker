#!/bin/bash

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

set -ex
### Variables - BEGIN
#### change variables below accordingly to your environment

WORK_DIR=${SCRIPT_PATH}
#WORK_DIR=.

NGINX_VERSION=1.17.6
NGINX_HTTP_PORT=80
NGINX_HTML_DIR=${WORK_DIR}/pages
NGINX_LOGS_DIR=${WORK_DIR}/logs
NGINX_CONF_FILE=${WORK_DIR}/conf/nginx.conf
NGINX_CONFD_DIR=${WORK_DIR}/conf/conf.d
NGINX_CONTAINER_NAME=mynginx
NGINX_ADDITIONAL_GROUP_ID=996
NGINX_DOCKERFILE=${WORK_DIR}/Dockerfile
### Variables - END

cat > ${NGINX_DOCKERFILE} <<- EOM
FROM nginx:${NGINX_VERSION}
RUN set -ex \
&& addgroup --gid ${NGINX_ADDITIONAL_GROUP_ID} tempgroup || true \
&& usermod -a -G ${NGINX_ADDITIONAL_GROUP_ID} nginx
EOM

docker rm -f $NGINX_CONTAINER_NAME || true \
&& docker rmi -f $NGINX_CONTAINER_NAME || true \
&& docker build -t $NGINX_CONTAINER_NAME $WORK_DIR \
&& docker run --name $NGINX_CONTAINER_NAME \
           --restart always                         \
           -v $NGINX_HTML_DIR:/usr/share/nginx/html \
           -v $NGINX_CONF_FILE:/etc/nginx/nginx.conf \
           -v $NGINX_CONFD_DIR:/etc/nginx/conf.d \
           -v $NGINX_LOGS_DIR:/var/log/nginx \
           -p $NGINX_HTTP_PORT:80 \
           -d $NGINX_CONTAINER_NAME \
&& tail -n 10 -f $NGINX_LOGS_DIR/*
