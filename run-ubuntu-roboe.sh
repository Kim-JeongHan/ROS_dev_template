#!/bin/bash

USER_UID=$(id -u)
TAG='focal-noetic-dev'
IMAGE='roboe:imageV1' # 220811
TTY='--device=/dev/ttyACM0'
USER='roboe'

xhost +local:docker

echo "IMAGE=" $IMAGE
echo "TAG=" $TAG
echo "USER_UID=" $USER_UID
echo "USER=" $USER
echo "IPADDR=" $(hostname -I | cut -d' ' -f1)
echo "TTY=" $TTY

docker run -it \
    --init \
    --ipc=host \
    --shm-size=32G \
    --privileged \
    --net=host \
    -e DISPLAY=$DISPLAY \
    -e XDG_RUNTIME_DIR=/run/user/$USER_UID \
    -e QT_GRAPHICSSYSTEM=native \
    -e CONTAINER_NAME=$TAG \
    -e USER=$USER \
    --env=UDEV=1 \
    --env=LIBUSB_DEBUG=1 \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v /run/user/$USER_UID:/run/user/$USER_UID \
    -v /dev:/dev \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v /home/$USER/workspace:/workspace \
    --gpus all \
    $IMAGE \
    terminator
    # --name=$TAG \
export containerId=$(docker ps -l -q)