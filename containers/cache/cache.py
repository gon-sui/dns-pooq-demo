#!/usr/bin/env python3
import socket
import subprocess
import sys
from scapy.all import *

def get_local_ip():
    """動的IPアドレスを取得"""
    try:
        # デフォルトゲートウェイ経由でIPを取得
        result = subprocess.run(['ip', 'route', 'get', '8.8.8.8'], 
                              capture_output=True, text=True)
        for line in result.stdout.split('\n'):
            if 'src' in line:
                return line.split('src')[1].split()[0]
    except:
        pass
    
    # フォールバック方法
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def packet_handler(packet):
    """DNSパケットを処理"""
    if packet.haslayer(DNS) and packet[DNS].qr == 0:  # DNS Query
        query = packet[DNS].qd.qname
        if packet.haslayer(UDP):
            src_port = packet[UDP].sport
            txid = packet[DNS].id
            print(f"Source port: {src_port}, TXID: {txid}, Query: {query}")

def main():
    local_ip = get_local_ip()
    print(f"Starting cache sniffer on IP: {local_ip}")
    print("Sniffing...")
    
    # DNSパケットをスニッフィング
    sniff(filter="udp port 53", prn=packet_handler, store=0)

if __name__ == "__main__":
    main()