# ROS distribution to use
ARG ROS_DISTRO=noetic

##########################################
# Base Image for ros1 template workspace #
##########################################
FROM nvidia/cuda:11.3.1-devel-ubuntu20.04 as gpu

ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV NVIDIA_VISIBLE_DEVICES=all
FROM osrf/ros:${ROS_DISTRO}-desktop-full as base
ARG REPO
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

# Hangul 언어 설정 HOST PC 설정 확인 $locale

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

# # [230209] apt server to mirror kakao
RUN cd /etc/apt && \
    sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' sources.list && \
    sed -i 's/security.ubuntu.com/mirror.kakao.com/g' sources.list


# Install basic apt packages
RUN --mount=type=cache,target=/var/cache/apt,id=apt \
    apt-get update && apt-get upgrade -y \
    && apt-get install -q -y --no-install-recommends \
    build-essential libboost-all-dev \
    python3-catkin-tools \
    udev \
    usbutils \
    ccache \
    cmake \
    net-tools ssh \
    lld \
    curl \
    git \
    python3-pip \
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
    && rm -rf /var/lib/apt/lists/*


RUN python3 -m pip install --upgrade pip
# Install additional Python modules
RUN pip3 install --ignore-installed empy \
    catkin_pkg \
    numpy==1.23.5 \
    ruamel.yaml \
    networkx==2.8.8  \
    rospkg \
    opencv-python==4.6.0.66 \
    matplotlib \
    jupyter \
    setproctitle \
    pymodbus \
    open3d \
    colorlog \
    dynamixel-sdk \
    empy==3.3.4 \
    ultralytics
RUN pip3 install --ignore-installed    scikit-image \
    dill \
    pybullet \
    pandas \
    multiprocess \
    rosnumpy==0.0.5.2 \
    omegaconf \
    h5py \
    roboticstoolbox-python
    # zivid==2.10.1.2.10.1 \
RUN pip3 install \
    torch torchvision
RUN pip3 install torchaudio --extra-index-url https://download.pytorch.org/whl/cu113 


# Update the package list and install ROS1 packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-rqt

# Create catkin workspace with external dependencies
RUN mkdir -p /upstream_ws/src
WORKDIR /upstream_ws/src
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && catkin_init_workspace

# Build the base catkin workspace, installing dependencies first.
WORKDIR /upstream_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && rosdep update && apt-get update -y \
    && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
    && catkin_make -DCMAKE_BUILD_TYPE=Release  \
    && rm -rf /var/lib/apt/lists/*



# Remove display warnings
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
RUN chmod -R 0700 /tmp/runtime-root
ENV NO_AT_BRIDGE 1

# Set up the entrypoint
WORKDIR /upstream_ws
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

#############################################
# Overlay Image for ros1 template workspace #
#############################################
FROM base AS overlay

# Create an overlay catkin workspace
RUN mkdir -p /overlay_ws/src

WORKDIR /overlay_ws
COPY ./${REPO}/ ./src/${REPO}/

WORKDIR /overlay_ws/src/${REPO}/ui

WORKDIR /overlay_ws/src/${REPO}/ui/robot-api
RUN touch .env \
    && echo DATABASE_URL="file:./data/mydb.sqlite" > .env \
    && echo PORT=8000 >> .env \
    && echo JWT_SECRET="=jt6Bb@Tfei$(BwN$0A)8c/f<#~+k?v" >> .env 
WORKDIR /overlay_ws/src/${REPO}/ui/robot-web
RUN touch .env \
    && echo NEXT_PUBLIC_API_URL='http://localhost:8000' > .env \
    && echo NEXT_PUBLIC_ROBOT_SERIAL='MOROW00001' >> .env
WORKDIR /overlay_ws/src/${REPO}/ui
CMD ["./rebuid.sh" ]



WORKDIR /overlay_ws
RUN source /upstream_ws/devel/setup.bash 
    # && catkin_make -DCMAKE_BUILD_TYPE=Release \
    # && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y 

# Copy the VSCode settings
COPY ./.vscode /overlay_ws/.vscode

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

#####################
# Development Image #
#####################
FROM overlay as dev

# Dev container arguments
ARG USERNAME=devuser
ARG UID=${UID}
ARG GID=${GID}

# Install extra tools for development
RUN --mount=type=cache,target=/var/cache/apt,id=apt \
    apt-get update && apt-get install -y --no-install-recommends \
    gdb gdbserver nano \
    openssh-client \
    python3-pip \
    vim \
    wget \
    unzip \
    locales \
    whois \
    software-properties-common \
    apt-utils \
    terminator \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME} \
    && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the overlay workspace to the new user
RUN chown -R ${UID}:${GID} /overlay_ws/

WORKDIR /home/${USERNAME}
ENV NVM_VERSION v0.39.7
ENV NODE_VERSION 18.17.0
ENV NVM_DIR /home/${USERNAME}/.nvm
RUN mkdir -p $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default"
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
RUN curl -L https://npmjs.com/install.sh | bash
# RUN npm install -g pnpm \
#     && npm install -g pm2 \
#     && npm install -gnodemon \
#     && npm install -g ts-node


WORKDIR /overlay_ws
# Set the user and source entrypoint in the user's .bashrc file
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc
