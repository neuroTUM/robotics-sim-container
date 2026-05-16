FROM ubuntu:24.04

ARG MUJOCO_VERSION=3.2.6
ARG ROS_DISTRO=jazzy

ENV DEBIAN_FRONTEND=noninteractive
ENV MUJOCO_HOME=/opt/mujoco/mujoco-${MUJOCO_VERSION}
ENV LD_LIBRARY_PATH=/opt/mujoco/mujoco-${MUJOCO_VERSION}/lib
ENV ROS_DISTRO=${ROS_DISTRO}

# Base system dependencies, Python tooling, GUI/OpenGL libraries, and RViz runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    wget \
    curl \
    tar \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    locales \
    software-properties-common \
    build-essential \
    cmake \
    pkg-config \
    bash-completion \
    sudo \
    vim \
    nano \
    \
    # MuJoCo / OpenGL / GLFW \
    libgl1 \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libegl1 \
    libegl-mesa0 \
    libgles2 \
    libglfw3 \
    libglew2.2 \
    mesa-utils \
    \
    # X11 / Qt / RViz GUI support \
    x11-apps \
    xauth \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxkbcommon-x11-0 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

# Locale setup required/recommended by ROS 2
RUN locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Enable Ubuntu Universe repository
RUN add-apt-repository universe

# Add ROS 2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME}) main" \
    > /etc/apt/sources.list.d/ros2.list

# Install ROS 2 Jazzy desktop stack, including RViz
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rqt \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init || true && \
    rosdep update

# Install uv system-wide
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    cp /root/.local/bin/uv /usr/local/bin/uv && \
    cp /root/.local/bin/uvx /usr/local/bin/uvx && \
    uv --version

# Install MuJoCo native binaries
RUN mkdir -p /opt/mujoco && \
    wget https://github.com/google-deepmind/mujoco/releases/download/${MUJOCO_VERSION}/mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz \
      -O /tmp/mujoco.tar.gz && \
    tar -xzf /tmp/mujoco.tar.gz -C /opt/mujoco && \
    rm /tmp/mujoco.tar.gz

# Install Python bindings
RUN python3 -m pip install --no-cache-dir --break-system-packages \
    mujoco==${MUJOCO_VERSION}

# Automatically source ROS 2 in interactive bash shells
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/bash.bashrc

# Helpful defaults for GUI apps inside Docker
ENV QT_X11_NO_MITSHM=1
ENV MUJOCO_GL=glfw

WORKDIR /workspace

CMD ["bash"]