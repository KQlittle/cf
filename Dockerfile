FROM alpine:latest
RUN apk update \
    && apk --no-cache add jq coreutils openssl bash curl bind-tools
WORKDIR /root
COPY main.sh /root
COPY ddns.sh /root
RUN sed -i 's|#!/bin/sh|#!/bin/bash|' /root/main.sh /root/ddns.sh
RUN chmod a+x main.sh ddns.sh
CMD ["/root/main.sh"]

