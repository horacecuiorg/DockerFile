FROM alpine:3.19

ENV DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=20.11.1
ARG TARGETARCH  # amd64 or arm64

# 安装必要软件
RUN apk update && apk add --no-cache \
    bash \
    curl \
    wget \
    vim \
    nano \
    git \
    openssh \
    sudo \
    iputils \
    xz \
    ca-certificates \
    shadow

# cloudflared
RUN case "$TARGETARCH" in \
      amd64) ARCH="amd64" ;; \
      arm64) ARCH="arm64" ;; \
      *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/cloudflared \
      "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}" && \
    chmod +x /usr/local/bin/cloudflared && \
    cloudflared --version

# Node.js 安装（官方 tarball）
RUN case "$TARGETARCH" in \
      amd64) ARCH_NAME="x64" ;; \
      arm64) ARCH_NAME="arm64" ;; \
      *) echo "Unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH_NAME}.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1 && \
    node -v && npm -v

# 创建 alpine 用户并赋予 sudo 权限
RUN useradd -m -s /bin/bash alpine && \
    echo "alpine:alpine" | chpasswd && \
    adduser alpine wheel && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

# 设置工作目录
WORKDIR /home/alpine

# 设置默认用户
USER alpine

CMD ["/bin/bash"]
