#!/bin/bash

/etc/init.d/jenkins start

while [ $(pgrep -U jenkins -f jenkins.war | grep -c .) -gt 0 ]
do
  sleep 1
done
