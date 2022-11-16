#!/usr/bin/bash
USERNAME="jhogklint"

LOCK_FILE="/tmp/monitor_changed.lock"

i=0
while [ -f $LOCK_FILE ]; do sleep 1; i=$((i+1)); done
[ $i -gt 5 ] && exit 0
touch $LOCK_FILE
trap "rm -f $LOCK_FILE" EXIT
sleep 10

echo "$BASHPID $(date) monitor_changed running" >> /home/$USERNAME/tmp/udev.log
if [ -f /home/$USERNAME/local/bin/setmonitor.sh ]
then
    /home/$USERNAME/local/bin/setmonitor.sh 2>&1 >> /home/$USERNAME/tmp/udev.log
fi
echo "$BASHPID $(date) monitor_changed exiting" >> /home/$USERNAME/tmp/udev.log

