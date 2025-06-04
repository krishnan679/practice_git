#!/bin/bash
echo "<table border=1>" > Service_status-`date +%F`
for service in `systemctl --all | grep service | awk '{print$1}' | grep -v ●`
do
	for check in `systemctl is-active $service 2> /dev/null` 
	do
		if [ $check == 'active' ];then
			for enabl in `systemctl is-enabled $service 2> /dev/null`
			do
				if [ $enabl = 'enabled' ];then
					echo "<tr><th>$service</th><td style=background-color:MediumSeaGreen>active</td><td style=background-color:MediumSeaGreen>enabled</td></tr>" >> Service_status-`date +%F`
				else
					echo "<tr><th>$service</th><td style=background-color:MediumSeaGreen>active</td><td style=background-color:red>disabled</td></tr>" >> Service_status-`date +%F`
				fi
			done
		else
			echo "<tr><th>$service</th><td style=background-color:red>inactive or dead or mask</td><td style=background-color:red>disabled</td></tr>" >> Service_status-`date +%F`
		fi
	done
done
echo "</table>" >> Service_status-`date +%F`
