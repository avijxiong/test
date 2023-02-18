FROM irinesistiana/mosdns:v4.5.3
LABEL maintainer="None"
ARG TAG
ARG REPOSITORY

ADD https://mirror.apad.pro/dns/easymosdns.tar.gz /easymosdns
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
RUN apk add --no-cache ca-certificates \
	&& apk add --no-cache curl \
	&&  echo '15 7 * * *  0 5 * * * /etc/mosdns/rules/update-cdn'>/var/spool/cron/crontabs/root \
	&&  ln -sf /dev/stdout /etc/mosdns/log.txt \
	&&  mv easymosdns /etc/mosdns \
	&&  chmod +x /etc/mosdns/local -R \
	&&  chmod +x /etc/mosdns/remote -R \
	&&  chmod +x /etc/mosdns/rules/update* \
	&&  chmod +x /etc/mosdns/tools/adblock* \
	&&  chmod +x /etc/mosdns/tools/ecs* \
	&&  chmod +x /etc/mosdns/tools/ipv4* \
	&&  chmod +x /etc/mosdns/tools/socks5-reload

  	
# 设置时区为上海
RUN apk -U add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata



VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
#CMD /usr/bin/mosdns start --dir /etc/mosdns
CMD sh entrypoint.sh
#ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
