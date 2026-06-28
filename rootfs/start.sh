#!/bin/bash
set -e

# Start Xvfb
Xvfb :0 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2

# Start x11vnc
x11vnc -display :0 -forever -shared -rfbport 5900 -nopw -bg -o /tmp/x11vnc.log

# Start noVNC
/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5800 &
NOVNC_PID=$!
sleep 1

# Start pulseaudio
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# Fix permissions
mkdir -p /steam /home/user
chown -R user:user /steam /home/user

# Start Steam as user
su - user -c "export DISPLAY=:0; export HOME=/home/user; export LD_LIBRARY_PATH='/steam/xdg/data/Steam/ubuntu12_32'; exec steam" &
STEAM_PID=$!

echo "==========================================="
echo "  Steam NVIDIA Container Started!"
echo "  NoVNC: http://localhost:5800"
echo "  VNC:   localhost:5900"
echo "==========================================="

# Wait for any process to exit
wait -n $XVFB_PID $NOVNC_PID $STEAM_PID
