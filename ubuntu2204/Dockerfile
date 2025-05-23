FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=20.11.1
ARG TARGETARCH

# 安装必要软件
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    wget \
    vim \
    nano \
    git \
    openssh-client \
    sudo \
    iputils-ping \
    xz-utils \
    bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=$TARGETARCH && \
    case "$ARCH" in \
      amd64) ARCH_NAME="x64" ;; \
      arm64) ARCH_NAME="arm64" ;; \
      *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH_NAME}.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1 && \
    node -v && npm -v

# 更新
RUN apt-get update && apt-get upgrade -y 


# 创建一个新用户 ubuntu，并赋予 sudo 权限
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# 允许 ubuntu 用户在使用 sudo 时不需要密码
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 440 /etc/sudoers.d/ubuntu

# 设置工作目录为用户主目录
WORKDIR /home/ubuntu

# 设置 ubuntu 用户为默认用户
USER ubuntu
# 默认进入 shell
CMD ["/bin/bash"]

# 构建镜像
# docker build -t ubuntu22.04 .
# 构建多平台镜像load
# docker buildx build --platform linux/amd64,linux/arm64 --load -t ubuntu22.04 .
# 构建多平台镜像push
# docker buildx build --platform linux/amd64,linux/arm64 --push -t ubuntu22.04 .
# 运行容器
# docker run -it --rm ubuntu22.04