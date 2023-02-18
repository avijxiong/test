#!/bin/sh
# crond
/usr/sbin/crond -b -l 8
#crontab/etc/init.d/cron start
chmod +x /usr/bin/mosdns
chmod +x /etc/mosdns/cache -R
chmod +x /etc/mosdns/local -R
chmod +x /etc/mosdns/remote -R
chmod +x /etc/mosdns/rules/update*
chmod +x /etc/mosdns/tools/adblock*
chmod +x /etc/mosdns/tools/ecs*
chmod +x /etc/mosdns/tools/ipv4*
chmod +x /etc/mosdns/tools/socks5-reload
/usr/bin/mosdns start --dir /etc/mosdns
#tail -f /dev/null
