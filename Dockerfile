# COMMAND
# [build  ] ~$ docker build -t roboe:imageV1 .
# [test   ] ~$ docker run --rm -it -h roboe_dev roboe:imageV1 bash
FROM osrf/ros:noetic-desktop-full
# USER root

LABEL name="david.roboe"
LABEL email="jisung.ko@roboetech.com"

ENV LANG en_US.UTF-8

# install utillity
RUN apt update
RUN apt install -y \
    tmux \
    curl \
    wget \ 
    vim \
    git \
    sudo \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    mesa-utils \
    unzip \
    locales \
    ntp \
    whois \ 
    net-tools \
    ssh \
    software-properties-common \
    apt-utils \
    python3-pip
    
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set noninteractive mode 
ARG DEBIAN_FRONTEND=noninteractive

# Set root password 
RUN echo "root:210901" | chpasswd

# clean up first
RUN apt autoremove --purge --yes
RUN rm -rf /var/lib/apt/list/* 
RUN rm -rf /etc/ros/rosdep/sources.list.d/20-default.list

RUN rosdep init 
RUN apt install -y ros-noetic-rqt* python3-rosinstall-generator python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

# hostname
RUN echo "roboedev" > /etc/hostname

# HOST_USER from build arguemnt

ARG UNAME=roboe
ARG UID=1000
ARG GID=1000
ARG HOME=/home/${UNAME}
RUN useradd -rm -d ${HOME} -s /bin/bash -g root -G sudo,audio,video,plugdev -u ${UID} ${UNAME}
RUN mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} 

USER ${UNAME}
WORKDIR ${HOME}
RUN sudo rosdep fix-permissions
RUN rosdep update


## python 3.6설치
USER root
RUN add-apt-repository ppa:deadsnakes/ppa 
RUN apt update
RUN apt install -y python3.6 python3.6-dev 

# ModuleNotFoundError: No module named 'distutils.cmd' 
RUN apt -y --reinstall install python3.6-distutils python3-catkin-tools
# AttributeError: type object 'OpenGL_accelerate.arraydatatype.HandlerRegistry' has no attribute 'reduce_cython'

# RUN sudo ln -sf /usr/bin/python3.6 /usr/bin/python
# RUN sudo ln -sf /usr/bin/python3.6 /usr/bin/python3

RUN pip install virtualenv

USER ${UNAME}
RUN /bin/bash -c "virtualenv vdx36 --python=python3.6"
RUN ~/vdx36/bin/pip install --upgrade --force-reinstall numpy
RUN ~/vdx36/bin/pip install --upgrade --force-reinstall netifaces
RUN echo "source ~/vdx36/bin/activate" >> ~/.bashrc
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "export ROS_HOSTNAME=localhost" >> ~/.bashrc
RUN echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc
RUN echo 'alias cw="cd ~/catkin_ws"' >> ~/.bashrc
RUN echo 'alias cs="cd ~/catkin_ws/src"' >> ~/.bashrc
RUN echo 'alias cm="cd ~/catkin_ws && catkin_make"' >> ~/.bashrc
RUN echo 'alias cdev="cd ~/catkin_ws/dev"' >> ~/.bashrc
RUN echo 'alias sb="source ~/.bashrc"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

RUN mkdir -p /home/${UNAME}/catkin_ws/src
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd /home/${UNAME}/catkin_ws/src; catkin_init_workspace'
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd /home/${UNAME}/catkin_ws; catkin_make'
RUN echo "source /home/${UNAME}/catkin_ws/devel/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
RUN ~/vdx36/bin/pip install empy catkin_pkg numpy PyYAML rospkg opencv-python matplotlib

# USER ${UNAME}
# RUN mkdir -p -m 0700 /home/${UNAME}/.ssh \
#   && ssh-keyscan github.com >> /home/${UNAME}/.ssh/known_hosts
# ADD id_rsa /home/${UNAME}/.ssh/id_rsa
# USER root
# RUN chown roboe:root /home/${UNAME}/.ssh/id_rsa
# RUN chmod 600 /home/${UNAME}/.ssh/id_rsa
# RUN chmod 644 /home/${UNAME}/.ssh/known_hosts

# RUN ssh-keygen -t rsa -C "jisung.ko@roboetech.com"
RUN sudo apt -y install openssh-client
RUN mkdir -p -m 0700 /home/${UNAME}/.ssh
RUN ssh-keygen -q -t rsa -C "jisung.ko@roboetech.com"

WORKDIR /home/${UNAME}/catkin_ws/src
RUN git clone git@github.com:roboetech/roboenet.git
# RUN git clone -b noetic-devel --single-branch https://github.com/doosan-robotics/doosan-robot
# RUN git clone https://github.com/wjwwood/serial.git
# RUN rosdep install --from-paths doosan-robot --ignore-src --rosdistro noetic -r -y


# WORKDIR /home/${UNAME}/catkin_ws/src/roboenet
# RUN sh install.sh all
# RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd /home/roboe/catkin_ws; catkin_make'

# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# RUN sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
# RUN sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
# RUN sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
# RUN sudo apt update 
# RUN sudo DEBIAN_FRONTEND=noninteractive apt install -y cuda-11-3

# RUN echo 'export PATH=/usr/local/cuda-11.3/bin:$PATH' >> ~/.bashrc
# RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.3/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# ADD cudnn-11.3-linux-x64-v8.2.1.32.tgz /home/${UNAME}/catkin_ws/etc/
# RUN sudo cp ~/catkin_ws/etc/cuda/include/* /usr/local/cuda-11.3/include
# RUN sudo cp -P ~/catkin_ws/etc/cuda/lib64/* /usr/local/cuda-11.3/lib64
# RUN sudo chmod a+r /usr/local/cuda-11.3/lib64/libcudnn*

# RUN sudo DEBIAN_FRONTEND=noninteractive apt -y install terminator