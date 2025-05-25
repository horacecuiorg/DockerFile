FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    git unzip zip tar vim nano htop iproute2 iputils-ping net-tools \
    build-essential software-properties-common \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm && \
    rm -rf /var/lib/apt/lists/*

# 复制 entrypoint 脚本以及构建上下文中的所有文件到镜像的根目录
COPY . /
# 使 entrypoint 脚本可执行
RUN chmod +x /entrypoint.sh
# 设置 ENTRYPOINT 为我们的脚本
# 这样每次容器启动时都会先执行 entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# 默认命令
CMD ["bash"]
