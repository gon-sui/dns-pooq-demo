#!/bin/bash

# Docker Hubにログイン
echo "Docker Hubにログインしてください"
docker login

# dnsmasq-forwarderイメージをビルド・プッシュ
echo "Building dnsmasq-forwarder..."
cd dnsmasq-forwarder
docker build -t gonkori/dnspooq-dnsmasq:latest .
docker push gonkori/dnspooq-dnsmasq:latest
cd ..

# cacheイメージをビルド・プッシュ
echo "Building cache..."
cd cache
docker build -t gonkori/dnspooq-cache:latest .
docker push gonkori/dnspooq-cache:latest
cd ..

echo "イメージのプッシュが完了しました！"
echo "dnsmasq: gonkori/dnspooq-dnsmasq:latest"
echo "cache: gonkori/dnspooq-cache:latest"