FROM ubuntu:22.04

# 安装 ssh 客户端
RUN apt-get update && apt-get install -y \
    openssh-client \
    bash \
    && rm -rf /var/lib/apt/lists/*


# 创建普通用户
ARG USERNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

# 创建 .ssh 目录
RUN mkdir -p /home/${USERNAME}/.ssh && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh && \
    chmod 700 /home/${USERNAME}/.ssh

# 拷贝默认启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT ["/entrypoint.sh"]