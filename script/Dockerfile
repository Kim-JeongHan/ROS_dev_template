ARG IMAGE
ARG TAG

FROM roboetech/${IMAGE}:${TAG}

ARG USERNAME
ARG UID=1000
ARG GID=1000
ARG WORKDIR=catkin_ws

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid ${UID} --gid ${GID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME} \
    && chown -R ${UID}:${GID} /home/${USERNAME}

USER ${USERNAME}
RUN mkdir -p /home/${USERNAME}/${WORKDIR}/src \
    && source /opt/ros/${ROS_DISTRO}/setup.bash \
    && catkin_init_workspace /home/${USERNAME}/${WORKDIR}/src
WORKDIR /home/${USERNAME}
RUN python3.11 -m venv vdx311
RUN echo -e "source /entrypoint.sh\n\source /opt/.nvm/nvm.sh" >> /home/${USERNAME}/.bashrc


