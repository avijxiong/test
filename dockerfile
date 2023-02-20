FROM irinesistiana/mosdns:v4.5.3
LABEL maintainer="None"
COPY entrypoint.sh /
RUN ln -sf /sbin/openrc-init /sbin/init
RUN wget https://mirror.apad.pro/dns/easymosdns.tar.gz \
	&&  tar xvzf  easymosdns.tar.gz  -C /etc/mosdns --strip-components=1 \
	&&  sed -i "s/bin\/bash/bin\/sh/g" `grep bin/bash -rl /etc/mosdns` \
	&&  chmod +x entrypoint.sh \
	&&  apk add --no-cache ca-certificates \
	&&  apk add --no-cache openrc \
	&&  echo '15 7 * * *  0 5 * * * /etc/mosdns/rules/update-cdn'>/var/spool/cron/crontabs/root \
	&&  chmod 600 /var/spool/cron/crontabs/root \
	&&  chmod +x /usr/bin/mosdns \
	&&  ln -sf /dev/stdout /etc/mosdns/mosdns.log \
	&&  apk -U add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&&  echo "Asia/Shanghai" > /etc/timezone \
	&&  apk del tzdata
	



VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
CMD sh entrypoint.sh

