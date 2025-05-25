FROM ghcr.io/horacecuiorg/dockerfile/ubuntu2204:basesoft

ENV DEBIAN_FRONTEND=noninteractive

# 复制 entrypoint 脚本以及构建上下文中的所有文件到镜像的根目录
COPY . /
# 使 entrypoint 脚本可执行
RUN chmod +x /entrypoint.sh
# 设置 ENTRYPOINT 为我们的脚本
# 这样每次容器启动时都会先执行 entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# 默认命令
CMD ["bash"]
