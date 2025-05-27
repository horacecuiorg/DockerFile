FROM ghcr.io/horacecuiorg/dockerfile/ubuntu2204:basesoft

LABEL org.opencontainers.image.source https://github.com/horacecuiorg/dockerfile

ENV DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=20.11.1

# 添加组和用户：
# - 创建 group: 1001 和 54322
# - 创建 user: cuiyinhu，uid=1101，gid=1101
# - 将用户加入 sudo、1001 和 54322 组
# 准备 SSH 环境
RUN groupadd -g 1001 group1001 && \
    groupadd -g 54322 group54322 && \
    groupadd -g 1101 cuiyinhu && \
    useradd -m -u 1101 -g 1101 -G sudo,1001,54322 -s /bin/bash cuiyinhu && \
    echo 'cuiyinhu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/cuiyinhu && \
    chmod 0440 /etc/sudoers.d/cuiyinhu && \
    mkdir -p /home/cuiyinhu/.ssh && \
    chmod 700 /home/cuiyinhu/.ssh && \
    chown cuiyinhu:cuiyinhu /home/cuiyinhu/.ssh

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

# 默认暴露 22 端口
EXPOSE 22
USER root
# 默认切换到该用户 取消，由于需要root运行/usr/sbin/sshd
#USER cuiyinhu  
WORKDIR /home/cuiyinhu

# 默认进入 shell
#CMD ["/bin/bash"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
