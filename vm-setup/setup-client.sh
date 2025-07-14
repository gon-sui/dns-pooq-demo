#!/bin/bash

# クライアントVMセットアップスクリプト
echo "Setting up client VM..."

# 現在のIPアドレスを取得
LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
NETWORK_BASE=$(echo $LOCAL_IP | cut -d. -f1-3)
echo "Local IP: $LOCAL_IP"
echo "Network base: $NETWORK_BASE"

# デスクトップ環境とVNCをインストール
sudo apt update
sudo apt install -y ubuntu-desktop-minimal
sudo apt install -y tightvncserver novnc websockify firefox

# VNCサーバーの設定
mkdir -p ~/.vnc

# VNCパスワードを設定（password）
echo "password" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# VNCスタートアップスクリプトを作成
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

# DNS設定を動的に更新するスクリプト
cat > /home/ubuntu/update_dns.sh << 'EOF'
#!/bin/bash

# forwarderコンテナのIPを自動検出
FORWARDER_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+' | sed 's/\.[0-9]*$/.2/')

echo "Setting DNS to forwarder: $FORWARDER_IP"

# DNSサーバーを設定
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

# resolv.confを更新
echo "nameserver $FORWARDER_IP" | sudo tee /etc/resolv.conf

echo "DNS updated to use forwarder at $FORWARDER_IP"
EOF

chmod +x /home/ubuntu/update_dns.sh

# VNCとnoVNCを起動するスクリプト
cat > /home/ubuntu/start_vnc.sh << 'EOF'
#!/bin/bash

# VNCサーバーを起動
vncserver :1 -geometry 1024x768 -depth 24

# noVNCを起動
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &

echo "VNC server started on :1"
echo "Web access: http://$(hostname -I | awk '{print $1}'):6080"
echo "VNC password: password"
EOF

chmod +x /home/ubuntu/start_vnc.sh

echo "Client VM setup completed!"
echo "To start VNC: ./start_vnc.sh"
echo "To update DNS: ./update_dns.sh"