#!/bin/sh
# crond
/usr/sbin/crond -b -l 8
#crontab/etc/init.d/cron start
/usr/bin/mosdns start --dir /etc/mosdns
#tail -f /dev/null
