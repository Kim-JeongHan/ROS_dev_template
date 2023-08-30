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

# Install basic apt packages
RUN --mount=type=cache,target=/var/cache/apt,id=apt \
    apt-get update && apt-get upgrade -y \
    && apt-get install -q -y --no-install-recommends \
    build-essential libboost-all-dev \
    udev \
    usbutils \
    ccache \
    cmake \
    lld \
    git libcanberra-gtk-module libcanberra-gtk3-module fuse3 libqt5svg5-dev \
    python3-pip python3-opencv python3-tk python3-pyqt5.qtwebengine \
    && rm -rf /var/lib/apt/lists/*

# Install additional Python modules
RUN pip3 install matplotlib transforms3d \
    pytest pytest-cov pytest-mock pytest-xdist

# Update the package list and install ROS1 packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-rqt

# Create catkin workspace with external dependencies
RUN mkdir -p /upstream_ws/src
WORKDIR /upstream_ws/src
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && catkin_init_workspace \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ROBOTIS-GIT/turtlebot3.git \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

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
RUN source /upstream_ws/devel/setup.bash \
    && catkin_make -DCMAKE_BUILD_TYPE=Release \
    && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y 

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
    git \
    openssh-client \
    python3-pip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# install developer tools
RUN python3 -m pip install --no-cache-dir \
    pre-commit==3.0.4

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME} \
    && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the overlay workspace to the new user
RUN chown -R ${UID}:${GID} /overlay_ws/



# Set the user and source entrypoint in the user's .bashrc file
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc
