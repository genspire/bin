#!/bin/bash

TOGGLE=`synclient |grep TouchpadOff | gawk '{ print $3 }'`
echo "toggle: $TOGGLE"
if [ "$TOGGLE" = "0" ]
then
  echo "Turning off touchpad"
  /usr/bin/synclient TouchpadOff=1
else 
  echo "Turning on touchpad"
  /usr/bin/synclient TouchpadOff=0
fi

