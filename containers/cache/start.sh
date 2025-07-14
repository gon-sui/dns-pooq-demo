#!/bin/bash

# 動的IPを取得してログに出力
IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
echo "Starting cache sniffer on IP: $IP"

# Pythonスクリプトを実行
exec python3 /app/cache.py