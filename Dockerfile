# Dockerfile for building custom Ubuntu ISO
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub2-common \
    mtools \
    dosfstools \
    isolinux \
    syslinux-efi \
    syslinux-utils \
    git \
    curl \
    wget \
    nano \
    vim \
    rsync \
    schroot \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /build

# Copy build scripts
COPY build-scripts/ /build/scripts/

# Make scripts executable
RUN chmod +x /build/scripts/*.sh

# Default command
CMD ["/build/scripts/build-iso.sh"]
