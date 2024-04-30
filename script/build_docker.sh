#!/bin/bash
HERE=$(dirname $(realpath $0))
source ${HERE}/.env


DOCKER_IMAGE="
roboetech/${IMAGE}-user:${VER}
"
DOCKER_ARGS="
--build-arg IMAGE=${IMAGE} \
--build-arg TAG=${VER} \
--build-arg USERNAME=${USER}
"
echo docker build -t ${DOCKER_IMAGE}  ${DOCKER_ARGS}

docker build -t ${DOCKER_IMAGE}  ${DOCKER_ARGS} .