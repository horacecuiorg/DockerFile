FROM gitea/runner-images:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH  # amd64 and  arm64

# 安装必要软件
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    git unzip zip tar vim nano htop iproute2 iputils-ping net-tools \
    xz-utils openssh-client openssh-server\
    sudo bash tmux\
    build-essential software-properties-common \
    python3 python3-pip python3-venv && mkdir -p /var/run/sshd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# 允许 runner 用户在使用 sudo 时不需要密码
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 440 /etc/sudoers.d/ubuntu

# 设置工作目录为用户主目录
#WORKDIR /home/ubuntu

# 设置 ubuntu 用户为默认用户
USER ubuntu
