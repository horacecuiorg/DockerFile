FROM alpine:3.19

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/bin:$PATH
ARG NODE_VERSION=23.11.1
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

# ... 其他部分 ...
RUN apk add --no-cache curl xz tar && \
    case "$TARGETARCH" in \
      amd64) ARCH_NAME="x64" ;; \
      arm64) ARCH_NAME="arm64" ;; \
      *) echo "Unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac && \
    echo "Downloading Node.js for arch: $ARCH_NAME" && \
    echo https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH_NAME}.tar.xz && \
    curl -fsSL -o /tmp/node.tar.xz https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH_NAME}.tar.xz && \
    ls -al /tmp/node.tar.xz && \
    xz -d /tmp/node.tar.xz && \
    tar -xf /tmp/node.tar -C /usr/local --strip-components=1

# 创建 alpine 用户并赋予 sudo 权限
RUN useradd -m -s /bin/sh alpine && \
    echo "alpine:alpine" | chpasswd && \
    adduser alpine wheel && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

# 设置工作目录
WORKDIR /home/alpine

# 设置默认用户
USER alpine

CMD ["/bin/sh"]
