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

USER runner
WORKDIR /home/runner

# 默认进入 shell
CMD ["/bin/bash"]
