FROM ubuntu:22.04

# 安装基础工具、sudo、Docker CLI 和 Compose
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    uidmap passwd \
    sudo openssh-server openssh-client tmux\
    bash && mkdir -p /var/run/sshd \
    && rm -rf /var/lib/apt/lists/*

# 安装 Docker CLI 和 Compose 插件
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y \
    docker-ce-cli \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*
# 设置权限
# SSH 配置：禁止 root 登录、禁止密码登录、允许公钥认证
RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#HostKey/HostKey/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 默认用户参数
ENV UID=1000 \
    GID=1000 \
    USERNAME=dockeruser \
    GROUPNAME=dockeruser \
    DOCKER_GID=999
# 可通过 .env 文件或运行时覆盖

EXPOSE 22
USER root

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["bash"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
