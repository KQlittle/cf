FROM alpine:latest
RUN apk update \
    && apk --no-cache add jq coreutils openssl bash curl bind-tools
WORKDIR /root
COPY ddns.sh /root
RUN sed -i 's|#!/bin/sh|#!/bin/bash|' /root/ddns.sh
RUN chmod a+x ddns.sh
CMD ["/root/ddns.sh"]

