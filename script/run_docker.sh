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
    echo "[INFO}Installing repo"
    mkdir -p ${HOME}/.bin
    PATH="${HOME}/.bin:${PATH}"
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
    chmod a+x ~/.bin/repo
fi

if apt list | grep -q "nvidia-docker2"; then
    echo "[INFO}nvidia-docker2 is already installed"
else
    echo "[INFO}Installing nvidia-docker2"
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt update && sudo apt install -y nvidia-docker2
    sudo systemctl restart docker
    sudo rm -rf /etc/apt/sources.list.d/nvidia-docker.list
fi


DOCKER_VOLUMES="
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume="${XAUTHORITY:-$HOME/.Xauthority}:/root/.Xauthority" \
--volume="/dev:/dev" \
--volume="${HOME}/.ssh:/home/linux/.ssh:ro" \
--volume="${HOME}/.gitconfig:/home/linux/.gitconfig:ro" \
--volume="${HERE}/.catkin/build:/home/linux/${WORKDIR}/build" \
--volume="${HERE}/.catkin/devel:/home/linux/${WORKDIR}/devel" \
--volume="${HERE}/.catkin/install:/home/linux/${WORKDIR}/install" \
--volume="${HERE}/${REPO}:/home/linux/${WORKDIR}/src/${REPO}" \
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
    echo "[INFO}Attaching to the existing container"
    docker start ${CONTAINER}
    docker attach ${CONTAINER}
else
    echo "[INFO}Running the command"
    if echo ${CONTAINER} | grep -q "cpu"; then
        docker run -it --name ${CONTAINER} --net=host --ipc=host --privileged ${DOCKER_ARGS} "${HUB_REPO}/${IMAGE}:${VER}" bash -c "bash"
    else
        docker run -it --name ${CONTAINER} --net=host --gpus=all --ipc=host --privileged ${DOCKER_ARGS} "${HUB_REPO}/${IMAGE}:${VER}" bash -c "bash"
    fi
fi
