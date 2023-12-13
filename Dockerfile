FROM alpine:latest

# 更新 apt 软件包索引并安装 jq 和 coreutils
RUN apk update \
    && apk --no-cache add jq coreutils openssh

# 查看已安装的软件包
RUN apk info jq \
    && apk info coreutils openssh

# 设置工作目录
WORKDIR /root

# 将本地环境复制到容器中
COPY main.sh /root
COPY ddns.sh /root

RUN chmod a+x main.sh

# 定义容器启动时执行的命令
CMD ["./main.sh"]
