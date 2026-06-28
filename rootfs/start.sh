#!/bin/bash
set -x

# Start Xvfb
Xvfb :0 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
sleep 2

# Start x11vnc
x11vnc -display :0 -forever -shared -rfbport 5900 -nopw -bg -o /tmp/x11vnc.log
sleep 1

# Start noVNC
/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5800 &
sleep 1

# Start pulseaudio
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# Fix permissions
mkdir -p /steam /home/user
chown -R user:user /steam /home/user

echo "All services started"

# Keep container running and start steam
su - user -c "export DISPLAY=:0; export HOME=/home/user; exec steam" &

# Keep container alive
exec tail -f /dev/null
