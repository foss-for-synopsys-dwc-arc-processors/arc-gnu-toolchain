FROM debian:11-slim

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    autotools-dev \
    bc \
    bison \
    build-essential \
    ca-certificates \
    curl \
    flex \
    gawk \
    git \
    gperf \
    libexpat1-dev \
    libglib2.0-dev \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libncurses-dev \
    libpixman-1-dev \
    libtool \
    locales \
    meson \
    ninja-build \
    patchutils \
    pkg-config \
    python3 \
    texinfo \
    zlib1g-dev

RUN sed -i 's/# \(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    /usr/sbin/locale-gen

RUN useradd -ms /bin/bash arc-user && \
    chown -R arc-user:arc-user /home/arc-user

USER arc-user
WORKDIR /home/arc-user
ENV LC_ALL en_US.UTF-8
