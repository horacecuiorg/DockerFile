FROM ghcr.io/horacecuiorg/dockerfile/ubuntu2204:basesoft

LABEL org.opencontainers.image.source https://github.com/horacecuiorg/dockerfile

ENV DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=20.11.1

# 添加组和用户：
# 准备 SSH 环境
RUN groupadd -g 118 group118 && \
    groupadd -g 4 group4 && \
    groupadd -g 100 group100 && \
    groupadd -g 999 group999 && \
    useradd -m -u 1001 -g 118 -G sudo,4,100,999 -s /bin/bash runner && \
    echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/runner && \
    chmod 0440 /etc/sudoers.d/runner && \
    mkdir -p /home/runner/.ssh && \
    chmod 700 /home/runner/.ssh && \
    chown runner:118 /home/cuiyinhu/.ssh

# 复制本地公钥文件到容器内（通过构建上下文）
COPY id_rsa.pub /home/cuiyinhu/.ssh/authorized_keys

RUN ls -al /home/cuiyinhu/.ssh/ && \
    cat /home/cuiyinhu/.ssh/authorized_keys

# 设置权限
# SSH 配置：禁止 root 登录、禁止密码登录、允许公钥认证
RUN chmod 600 /home/cuiyinhu/.ssh/authorized_keys && \
    chown cuiyinhu:cuiyinhu /home/cuiyinhu/.ssh/authorized_keys&& \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#HostKey/HostKey/' /etc/ssh/sshd_config && \
    ssh-keygen -A


USER runner
WORKDIR /home/runner

# 默认进入 shell
CMD ["/bin/bash"]
