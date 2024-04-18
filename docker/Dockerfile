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
    && rm -rf /var/lib/apt/lists/*

# TODO : dependecy install
# RUN python3 -m pip install --upgrade pip
# # Install additional Python modules
# RUN pip3 install --ignore-installed empy \
#     catkin_pkg \
#     numpy==1.23.5 



# Remove display warnings
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
RUN chmod -R 0700 /tmp/runtime-root
ENV NO_AT_BRIDGE 1


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


#####################################
# cpu dev Image for roboe workspace #
#####################################
FROM cpu as cpu-dev

ARG USERNAME
ARG UID=${UID}
ARG GID=${GID}


# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME} \
    && chown -R ${UID}:${GID} /home/${USERNAME}

WORKDIR /home/${USERNAME}
# RUN mkdir -p /home/${USERNAME}/catkin_ws/src 
    # && catkin_init_workspace /home/${USERNAME}/catkin_ws/src

WORKDIR /home/${USERNAME}/catkin_ws
# TODO : Install Roboe git
# RUN repo init -u ssh://xn--id-tf2j006a@gerrit.roboetech.com:29418/manifest -b roboe_m_release -m roboe_m_release.xml 

# Copy the VSCode settings
COPY ./.vscode /overlay_ws/.vscode
USER ${USERNAME}

######################################
# cpu prod Image for roboe workspace #
######################################
FROM cpu as cpu-prod

WORKDIR /opt
# TODO : Install Roboe git
# RU


#####################################
# gpu dev Image for roboe workspace #
#####################################
FROM gpu as gpu-dev

ARG USERNAME=devuser
ARG UID=${UID}
ARG GID=${GID}


# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME} \
    && chown -R ${UID}:${GID} /home/${USERNAME}

WORKDIR /home/${USERNAME}
# RUN mkdir -p /home/${USERNAME}/catkin_ws/src \
#     && catkin_init_workspace /home/${USERNAME}/catkin_ws/src

WORKDIR /home/${USERNAME}/catkin_ws
# TODO : Install Roboe git
# RUN repo init -u ssh://xn--id-tf2j006a@gerrit.roboetech.com:29418/manifest -b roboe_m_release -m roboe_m_release.xml 

# Copy the VSCode settings
COPY ./.vscode /overlay_ws/.vscode
USER ${USERNAME}

######################################
# gpu prod Image for roboe workspace #
######################################
FROM gpu as gpu-prod

WORKDIR /opt
# TODO : Install Roboe git
# RUN
