FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    cmake \
    ninja-build \
    g++ \
    make \
    unzip \
    zip \
    pkg-config \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

ARG PX4_VERSION=main
ENV PX4_HOME=/opt/PX4-Autopilot

WORKDIR /opt

RUN git clone --branch ${PX4_VERSION} --depth=1 https://github.com/PX4/PX4-Autopilot.git ${PX4_HOME} --recursive && \
    bash ${PX4_HOME}/Tools/setup/ubuntu.sh

RUN apt-get install gcc-arm-none-eabi -y

WORKDIR ${PX4_HOME}

