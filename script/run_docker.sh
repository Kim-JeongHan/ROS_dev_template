#!/bin/bash
HERE=$(dirname $(realpath $0))
source ${HERE}/.env

if [ ! -d  $REPO ]; then
    mkdir $REPO
fi

if [ ! -d  .catkin ]; then
    mkdir -p .catkin/build
    mkdir -p .catkin/devel
    mkdir -p .catkin/install
fi

if [ ! -d ${HOME}/.bin ]; then
    mkdir -p ${HOME}/.bin
    PATH="${HOME}/.bin:${PATH}"
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
    chmod a+x ~/.bin/repo
fi


DOCKER_VOLUMES="
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume="${XAUTHORITY:-$HOME/.Xauthority}:/root/.Xauthority" \
--volume="/dev:/dev" \
--volume="${HOME}/.ssh:/home/linux/.ssh:ro" \
--volume="${HOME}/.gitconfig:/home/linux/.gitconfig:ro" \
--volume="${HERE}/.catkin/build:/opt/${WORKDIR}/build" \
--volume="${HERE}/.catkin/devel:/opt/${WORKDIR}/devel" \
--volume="${HERE}/.catkin/install:/opt/${WORKDIR}/install" \
--volume="${HERE}/${REPO}:/opt/${WORKDIR}/src/${REPO}" \
--user=$(id -u):$(id -g) \
"
DOCKER_ENV_VARS="
--env="DISPLAY" \
--env="QT_X11_NO_MITSHM=1" \
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="TERM=xterm-256color" \
"
DOCKER_ARGS=${DOCKER_VOLUMES}" "${DOCKER_ENV_VARS}

# Check if the container exists
if docker ps -a --format '{{.Names}}' | grep -q ${CONTAINER}; then
    echo "Attaching to the existing container"
    docker start ${CONTAINER}
    docker attach ${CONTAINER}
else
    echo "Running the command"
    docker run -it --name ${CONTAINER} --net=host --ipc=host --privileged ${DOCKER_ARGS} "${HUB_REPO}/${IMAGE}:${VER}" bash -c "bash"
fi
