#!/bin/bash

# 悪意のあるサーバーVMセットアップスクリプト
echo "Setting up malicious server VM..."

# 現在のIPアドレスを取得
LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
echo "Local IP: $LOCAL_IP"

# Apache2をインストール
sudo apt update
sudo apt install -y apache2

# 偽のGoogleページを作成
sudo cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>警告 - DNS攻撃を検出しました</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #ff4444;
            color: white;
            text-align: center;
            padding: 50px;
            margin: 0;
        }
        .warning-box {
            background-color: #cc0000;
            border: 3px solid #fff;
            border-radius: 10px;
            padding: 30px;
            max-width: 600px;
            margin: 0 auto;
            box-shadow: 0 0 20px rgba(0,0,0,0.5);
        }
        h1 {
            font-size: 2.5em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        .blink {
            animation: blink 1s infinite;
        }
        @keyframes blink {
            0%, 50% { opacity: 1; }
            51%, 100% { opacity: 0; }
        }
        .details {
            background-color: rgba(0,0,0,0.3);
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="warning-box">
        <h1 class="blink">⚠️ 警告 ⚠️</h1>
        <h2>DNSキャッシュポイズニング攻撃が成功しました！</h2>
        <p>あなたは現在、<strong>偽のWebサイト</strong>にアクセスしています。</p>
        
        <div class="details">
            <h3>攻撃の詳細:</h3>
            <ul>
                <li>本来のgoogle.comではなく、攻撃者が用意した偽のサーバーです</li>
                <li>DNSの応答が改ざんされています</li>
                <li>実際の攻撃では、個人情報を盗む悪意のあるサイトが表示される可能性があります</li>
                <li>ユーザーは正規のサイトだと信じてしまう危険性があります</li>
            </ul>
        </div>
        
        <h3>教育目的のデモンストレーション</h3>
        <p>これはDNSpooq脆弱性（CVE-2020-25686）のデモです。<br>
        実際の環境では絶対に悪用しないでください。</p>
        
        <div class="details">
            <strong>現在のサーバーIP:</strong> <span id="server-ip"></span><br>
            <strong>アクセス時刻:</strong> <span id="access-time"></span>
        </div>
    </div>
    
    <script>
        // サーバーIPを表示（クライアント側で取得される情報）
        document.getElementById('server-ip').textContent = window.location.hostname || 'Unknown';
        document.getElementById('access-time').textContent = new Date().toLocaleString('ja-JP');
    </script>
</body>
</html>
EOF

# Apache2を起動・有効化
sudo systemctl enable apache2
sudo systemctl start apache2

# ポート80が開放されていることを確認
sudo ufw allow 80

echo "Malicious server setup completed!"
echo "Server is running on IP: $LOCAL_IP"
echo "Test with: curl http://$LOCAL_IP"