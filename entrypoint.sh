#!/bin/sh
# crond
/usr/sbin/crond -b -l 8
#crontab/etc/init.d/cron start
chmod +x /usr/bin/mosdns
/usr/bin/mosdns start --dir /etc/mosdns
#tail -f /dev/null
