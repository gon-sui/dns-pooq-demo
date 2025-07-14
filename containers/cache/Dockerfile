FROM python:3.9-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    tcpdump \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Pythonパッケージをインストール
RUN pip install scapy

# 作業ディレクトリを設定
WORKDIR /app

# キャッシュスクリプトをコピー
COPY cache.py /app/cache.py
COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

# 起動スクリプトを実行
CMD ["/app/start.sh"]