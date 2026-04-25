FROM ubuntu:24.04

ARG MUJOCO_VERSION=3.2.6

ENV DEBIAN_FRONTEND=noninteractive
ENV MUJOCO_HOME=/opt/mujoco/mujoco-${MUJOCO_VERSION}
ENV LD_LIBRARY_PATH=/opt/mujoco/mujoco-${MUJOCO_VERSION}/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    wget \
    tar \
    git \
    ca-certificates \
    libgl1 \
    libglfw3 \
    libglew2.2 \
    && rm -rf /var/lib/apt/lists/*

# Install MuJoCo native binaries
RUN mkdir -p /opt/mujoco && \
    wget https://github.com/google-deepmind/mujoco/releases/download/${MUJOCO_VERSION}/mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz \
      -O /tmp/mujoco.tar.gz && \
    tar -xzf /tmp/mujoco.tar.gz -C /opt/mujoco && \
    rm /tmp/mujoco.tar.gz

# Install Python bindings
RUN python3 -m pip install --no-cache-dir --break-system-packages \
    mujoco==${MUJOCO_VERSION}

WORKDIR /workspace

CMD ["bash"]