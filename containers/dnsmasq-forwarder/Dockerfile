FROM alpine:3.16

# 脆弱性のあるdnsmasq 2.82をインストール
RUN apk add --no-cache \
    wget \
    build-base \
    linux-headers \
    nettle-dev

# dnsmasq 2.82をソースからビルド
RUN wget http://www.thekelleys.org.uk/dnsmasq/dnsmasq-2.82.tar.gz && \
    tar -xzf dnsmasq-2.82.tar.gz && \
    cd dnsmasq-2.82 && \
    make && \
    make install && \
    cd .. && \
    rm -rf dnsmasq-2.82*

# 設定ファイルのコピー
COPY dnsmasq.conf /etc/dnsmasq.conf

# 起動スクリプトのコピー
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 53/udp

CMD ["/start.sh"]