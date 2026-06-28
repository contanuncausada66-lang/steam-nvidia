FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV DISPLAY=:0
ENV HOME=/home/user
ENV XDG_CACHE_HOME=/steam/xdg/cache
ENV XDG_CONFIG_HOME=/steam/xdg/config
ENV XDG_DATA_HOME=/steam/xdg/data

# Step 1: Basic packages
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
      sudo wget curl ca-certificates gnupg2 \
      xvfb x11vnc \
      pulseaudio dbus dbus-x11 \
      pciutils file zenity procps \
      python3 python3-pip git net-tools && \
    rm -rf /var/lib/apt/lists/*

# Step 2: XFCE desktop
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      xfce4 xfce4-terminal && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Create user
RUN useradd -m -s /bin/bash user && \
    echo "user ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir -p /steam /home/user

# Step 4: Install websockify + noVNC
RUN pip3 install --break-system-packages websockify && \
    git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    ln -sf /opt/noVNC/vnc.html /opt/noVNC/index.html

# Step 5: Steam 32-bit dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
      make xz-utils \
      libc6-i386 libgl1:i386 libxtst6:i386 libxrandr2:i386 \
      libglib2.0-0:i386 libgtk2.0-0:i386 libpulse0:i386 \
      libva2:i386 libbz2-1.0:i386 libvdpau1:i386 libva-x11-2:i386 \
      libcurl4-gnutls-dev:i386 libopenal1:i386 libsm6:i386 libice6:i386 \
      libasound2-plugins:i386 libsdl2-image-2.0-0:i386 && \
    rm -rf /var/lib/apt/lists/*

# Step 6: Mesa/Vulkan
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      libgl1-mesa-glx:i386 libgl1-mesa-dri:i386 \
      libegl1:i386 libvulkan1:i386 \
      mesa-vulkan-drivers:i386 mesa-utils vulkan-tools && \
    rm -rf /var/lib/apt/lists/*

# Step 7: Install Steam
RUN mkdir -p /src && cd /src && \
    wget http://repo.steampowered.com/steam/archive/precise/steam_latest.tar.gz && \
    tar xzvf steam_latest.tar.gz && \
    cd /src/steam-launcher && \
    make install && \
    rm -f /var/lib/dpkg/statoverride && \
    apt-get remove -y make && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/*

COPY rootfs/ /rootfs/
RUN chmod +x /rootfs/start.sh

EXPOSE 5800 5900

CMD ["/rootfs/start.sh"]
