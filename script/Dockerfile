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

### VISION ###
# Install Ensenso SDK & Ueye driver
RUN mkdir ~/catkin_ws/dev/Ensenso && \
    cd ~/catkin_ws/dev/Ensenso && \
    wget -O ensenso-sdk-3.6.1617-x64.deb https://download.optonic.com/s/ensensosdk/download?files=ensenso-sdk-3.6.1617-x64.deb && \
    wget -O ids-software-suite-linux-64-4.96.1-archive.tgz https://download.ensenso.com/s/idsdrivers/download?files=ids-software-suite-linux-64-4.96.1-archive.tgz && \
    tar xvfz ids-software-suite-linux-64-4.96.1-archive.tgz && \
    sudo dpkg -i ensenso-sdk-3.6.1617-x64.deb
USER root
RUN chmod +x ~/catkin_ws/dev/Ensenso/ueye_4.96.1.2054_amd64.run && \
    echo y | ~/catkin_ws/dev/Ensenso/ueye_4.96.1.2054_amd64.run

RUN echo "export ENSENSO_INSTALL=/opt/ensenso" >> ~/.bashrc && \
    /bin/bash -c 'source ~/.bashrc'

# Install Zivid driver
RUN mkdir -p ~/catkin_ws/dev/Zivid && \
    cd ~/catkin_ws/dev/Zivid && \
    wget \
    https://downloads.zivid.com/sdk/releases/2.10.0+8ce7dae3-2/u20/zivid-telicam-driver_3.0.1.1-3_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.10.0+8ce7dae3-2/u20/zivid_2.10.0+8ce7dae3-2_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.10.0+8ce7dae3-2/u20/zivid-studio_2.10.0+8ce7dae3-2_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.10.0+8ce7dae3-2/u20/zivid-tools_2.10.0+8ce7dae3-2_amd64.deb && \
    sudo apt install ./*.deb && \
    pip install zivid==2.10.0.2.10.0
WORKDIR ~/catkin_ws/src/vision/zivid-ros/SRC/python_zivid/zivid-python
RUN pip install .

# Change base prompt terminal color
RUN echo 'PS1="\033[1;36m\]\u\[\033[1;31m\][D]\[\033[1;32m\]$CONTAINER:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] "' >> /home/${USERNAME}/.bashrc




