#!/bin/bash
# Monitor certificate validity date
# V20250515

WARN=10
CRIT=30
HOST=<MyDomain.ch>

# Calculate cert left days validity
DAYS_LEFT=$(echo | openssl s_client -servername "$HOST" -connect "$HOST:443" 2>/dev/null \
  | openssl x509 -noout -enddate \
  | cut -d= -f2 \
  | xargs -I{} date -d "{}" +%s \
  | awk -v now=$(date +%s) '{print int(($1 - now) / 86400)}')

# Checkmk check output
if [ $DAYS_LEFT -le $CRIT ]
then
 STATUS="2"
elif [ $DAYS_LEFT  -le $WARN ]
then
 STATUS="1"
elif [ $DAYS_LEFT -gt $WARN ]
then
 STATUS="0"
fi

echo "$STATUS \" Certificate validity: $HOST \" count=$DAYS_LEFT $DAYS_LEFT valid days left. WARN/CRIT $WARN/$CRIT days"
