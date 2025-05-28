FROM python:3.11-slim

# 设置构建时的代理（可选）
# ARG http_proxy
# ARG https_proxy

# 替换 APT 源为阿里云
RUN sed -i 's@http://deb.debian.org@http://mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's@http://security.debian.org@http://mirrors.aliyun.com@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 配置 pip 使用阿里云源
RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://mirrors.aliyun.com/pypi/simple" >> /root/.pip/pip.conf && \
    echo "trusted-host = mirrors.aliyun.com" >> /root/.pip/pip.conf

# 测试 pip & apt
RUN pip install --upgrade pip && pip install requests

# 设置时区和默认编码
ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
