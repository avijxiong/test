FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG CGO_ENABLED=0
ARG TAG
ARG REPOSITORY

WORKDIR /root
RUN apk add --update git \
	&& git clone https://github.com/${REPOSITORY} mosdns \
	&& cd ./mosdns \
	&& git fetch --all --tags \
	&& git checkout tags/${TAG} \
	&& go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns


FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="none"

COPY --from=builder /root/mosdns/mosdns /usr/bin/
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
RUN apk add --no-cache ca-certificates \
	&& apk add --no-cache curl \
	&&  echo '15 7 * * *  0 5 * * * /etc/mosdns/rules/update-cdn'>/var/spool/cron/crontabs/root \
	&&  chmod 600 /var/spool/cron/crontabs/root \
	&&  chmod +x /usr/bin/mosdns \
	&&  ln -sf /dev/stdout /etc/mosdns/log.txt \
	&&  wget https://mirror.apad.pro/dns/easymosdns.tar.gz \
	&&  tar xzf easymosdns.tar.gz \
	&&  mv easymosdns /etc/mosdns
RUN /etc/mosdns/tools/config-reset
  	
# 设置时区为上海
RUN apk -U add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata



VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
#CMD /usr/bin/mosdns start --dir /etc/mosdns
CMD sh entrypoint.sh
#ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
