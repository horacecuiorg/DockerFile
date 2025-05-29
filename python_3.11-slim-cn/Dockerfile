# 使用官方 Python 3.11 slim 镜像
FROM python:3.11-slim

# 设置非交互式模式，避免 tzdata 等软件包安装时阻塞
ENV DEBIAN_FRONTEND=noninteractive


# 彻底清理默认源并设置阿里云 APT 源为 Bookworm 版本
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/apt/sources.list.d/* && \
    echo "deb http://mirrors.aliyun.com/debian bookworm main contrib non-free\n\
          deb http://mirrors.aliyun.com/debian bookworm-updates main contrib non-free\n\
          deb http://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free" \
    > /etc/apt/sources.list

# 配置 pip 使用阿里云镜像源
RUN python -m pip install --upgrade pip && \
    pip install --upgrade flask requests python-dotenv httpx && \
    mkdir -p /root/.pip && \
    echo "[global]\nindex-url = https://mirrors.aliyun.com/pypi/simple/\ntrusted-host = mirrors.aliyun.com" > /root/.pip/pip.conf

# 可选：指定工作目录
#WORKDIR /app

# 可选：复制当前目录代码（如果此 Dockerfile 和代码在同一目录）
# COPY . .

# 可选：设置容器启动命令（例如运行 FastAPI、Django 等）
# CMD ["python", "main.py"]
