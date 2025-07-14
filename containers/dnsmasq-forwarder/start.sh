#!/bin/sh

# 動的IPを取得してログに出力
IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
echo "Starting dnsmasq on IP: $IP"

# dnsmasqをフォアグラウンドで起動
exec dnsmasq --no-daemon --log-facility=-