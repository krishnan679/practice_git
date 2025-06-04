#!/bin/bash
root_value=`df -hT | grep -w / | awk '{print$6}' | awk -F'%' '{print$1}'`
if [ $root_value -gt 85 ];then
	sudo dnf clean all > /dev/null
	echo "The cache memory of root is cleared,please check the space in /"
else
	echo "The root partition below 85%"
fi
