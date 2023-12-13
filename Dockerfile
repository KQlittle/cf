FROM alpine:latest

# 更新 apk 软件包索引并安装 jq、coreutils 和 openssh
RUN apk update \
    && apk --no-cache add jq coreutils openssl bash curl

# 查看已安装的软件包
RUN apk info jq \
    && apk info coreutils openssl bash curl

# 设置工作目录
WORKDIR /root

# 将本地环境复制到容器中
COPY main.sh /root
COPY ddns.sh /root

RUN sed -i 's|#!/bin/sh|#!/bin/bash|' /root/main.sh /root/ddns.sh

RUN chmod a+x main.sh ddns.sh

# 定义容器启动时执行的命令
CMD ["/root/main.sh"]

