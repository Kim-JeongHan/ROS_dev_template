# ROS distribution to use
ARG ROS_DISTRO=noetic

##########################################
# Base Image for ros1 template workspace #
##########################################
FROM osrf/ros:${ROS_DISTRO}-desktop-full as base
ARG REPO
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

# Hangul Language Settings HOST Check PC Settings $locale
ENV LANG=en_US.UTF-8
ENV LC_CTYPE="en_US.UTF-8"
ENV LC_NUMERIC=ko_KR.UTF-8
ENV LC_TIME=ko_KR.UTF-8
ENV LC_COLLATE="en_US.UTF-8"
ENV LC_MONETARY=ko_KR.UTF-8
ENV LC_MESSAGES="en_US.UTF-8"
ENV LC_PAPER=ko_KR.UTF-8
ENV LC_NAME=ko_KR.UTF-8
ENV LC_ADDRESS=ko_KR.UTF-8
ENV LC_TELEPHONE=ko_KR.UTF-8
ENV LC_MEASUREMENT=ko_KR.UTF-8
ENV LC_IDENTIFICATION=ko_KR.UTF-8

# Change ubuntu apt server to kakao
RUN cd /etc/apt && \
    sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' sources.list && \
    sed -i 's/security.ubuntu.com/mirror.kakao.com/g' sources.list

# Install basic apt packages
RUN --mount=type=cache,target=/var/cache/apt,id=apt \
    apt-get update && apt-get upgrade -y \
    && apt-get install -q -y --no-install-recommends \
    build-essential libboost-all-dev  \
    python3-catkin-tools \
    udev \
    usbutils \
    ccache \
    cmake \
    net-tools ssh \
    lld \
    curl \
    git \
    git libcanberra-gtk-module libcanberra-gtk3-module fuse3 libqt5svg5-dev \
    libosmesa6-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglfw3 \
    mesa-utils \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    psmisc \
    python3-pip \
    python-is-python3 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip
RUN pip3 install --ignore-installed empy \
    catkin_pkg

# Install Additional ROS packages
RUN --mount=type=cache,target=/var/cache/apt,id=apt \
    apt-get update && apt-get upgrade -y \
    && apt-get install -q -y --no-install-recommends \
    ros-${ROS_DISTRO}-rviz

# Remove display warnings
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
RUN chmod -R 0700 /tmp/runtime-root
ENV NO_AT_BRIDGE 1

# TO-DO
# 1. VENV ENV SHOULD BE APPLIED
# 2. catkin_ws Directory Setting
#   2.1 dev: /home/${USER}/catkin_ws
#   2.2 prod: /opt/catkin_ws
# # ROS directory will be /opt/ros/noetic
# 3. Build will be performed using catkin_make then catkin build could be used
# 4. NVM (npm, pm2, pnpm) should be considered about move or remove installation
#
#

COPY ./docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
#################################
# gpu Image for roboe workspace #
#################################
FROM nvidia/cuda:11.3.1-devel-ubuntu20.04
FROM base as gpu
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV NVIDIA_VISIBLE_DEVICES=all
#################################
# cpu Image for roboe workspace #
#################################
FROM base as cpu

######################################
# cpu prod Image for roboe workspace #
######################################
FROM cpu as cpu-prod

WORKDIR /opt
# TODO : TBD

#####################################
# cpu dev Image for roboe workspace #
#####################################
FROM cpu as cpu-dev

ARG PYTHON_VERSION

RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y  python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3.11-tk \
    virtualenv \
    terminator

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
    && update-alternatives --set python3 /usr/bin/${PYTHON_VERSION}


ENV NVM_VERSION v0.39.7
ENV NODE_VERSION 18.17.0
ENV NVM_DIR /opt/.nvm
RUN mkdir -p $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
RUN curl -L https://npmjs.com/install.sh | bash

# Copy the VSCode settings
COPY ./.vscode /opt/.vscode
######################################
# gpu prod Image for roboe workspace #
######################################
FROM gpu as gpu-prod

WORKDIR /opt
# TODO : Install Roboe git
# RUN


#####################################
# gpu dev Image for roboe workspace #
#####################################
FROM gpu as gpu-dev

ARG PYTHON_VERSION

RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y  python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3.11-tk \
    virtualenv \
    terminator

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
    && update-alternatives --set python3 /usr/bin/${PYTHON_VERSION}

ENV NVM_VERSION v0.39.7
ENV NODE_VERSION 18.17.0
ENV NVM_DIR /opt/.nvm
RUN mkdir -p $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
RUN curl -L https://npmjs.com/install.sh | bash

# Copy the VSCode settings
COPY ./.vscode /opt/.vscode


