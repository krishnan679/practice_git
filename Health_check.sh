#!/bin/bash
Hostname=`uname -n`
IP_address=`hostname -I | awk '{print$1}'`
OS_release=`cat /etc/os-release | awk '/PRETTY/' | awk -F'=' '{print$2}' | awk -F'"' '{print $2}'`
Serial_number=`sudo dmidecode -s system-serial-number`
SYS_version=`sudo dmidecode -s system-version`
Hardware_model=`sudo dmidecode -s system-product-name`
cpu_count=`nproc`
Memory=`free -h | grep Mem | awk '{print$7}'`
No_of_disk=`lsblk | grep -i disk | wc -l`
Disk_size=`lsblk -d | grep disk | awk '{print$4}' | awk -F'G' '{print$1}' | awk '{ sum += $1 } END { print sum "G" }'`
#Disk_size=`lsblk -d | grep disk | awk '{print$4}' | awk -F'G' '{print$1}' | tr '\n' ',' | awk -F',' '{ for(i=1; i<=NF; i++) sum += $i } END { print sum }'`
File_system=`df -hT | grep -Eiv 'tmpfs|Filesystem' | awk 'BEGIN{ print "<td><table border=1><tr><th>Filesystem</th><th>Type</th><th>Size</th><th>Used</th><th>Avail</th><th>Use%</th><th>Mounted on</th></tr>" } { print "<tr>"; for (i=1;i <=NF ;i++)print "<td>" $i "</td>" } END{print "</tr></table></td>"}'`
NIC_info=`ip a | awk '/state UP/' | awk -F': ' '{print$2}' | awk '{ print "<table border=1><tr>"; for (i=1; i<=NF; i++)print "<td>" $i "<td>" } END{ print "</tr></table>" }'`
LOG_File=`sudo cat /var/log/syslog | grep -Ei 'failed|error' | wc -l`
echo "<table border=1>" > Health_check.html
echo "<tr><td>HOST NAME</td><td>$Hostname</td></tr>" >> Health_check.html
echo "<tr><td>IP ADDRESS</td><td>$IP_address</td></tr>" >> Health_check.html
echo "<tr><td>OS RELEASE</td><td>$OS_release</td></tr>" >> Health_check.html
echo "<tr><td>Hardware Details</td><td>" >> Health_check.html
sudo dmidecode | grep -A2 'System Information' | grep VirtualBox > /dev/null
if [ $? -eq 0 ];then
	echo "<table border=1><th>virtual machine</th>" >> Health_check.html
	echo "<tr><td>VMWARE TOOL VERSION</td><td>$SYS_version</td></tr>" >> Health_check.html
	echo "<tr><td>VMWARE TOOL STATUS</td><td>..........</td></tr>" >> Health_check.html
	echo "<tr><td>MULTIPATH</td><td>.............</td></tr></table></td></tr>" >> Health_check.html
else
	echo "<table border=1><th>physical machine</th>" >> Health_check.html
	echo "<tr><td>SERIAL NUMBER</td><td>$Serial_number</td</tr>" >> Health_check.html
	echo "<tr><td>HARDWARE MODEL</td><td>$Hardware_model</td></tr></table></td></tr>" >> Health_check.html
fi
echo "<tr><td>CPU COUNT</td><td>$cpu_count</td></tr>" >> Health_check.html
echo "<tr><td>MEMORY</td><td>$Memory</td></tr>" >> Health_check.html
echo "<tr><td>DISK</td><td><table border=1><tr><td>No of Disks</td><td>$No_of_disk</td></tr><tr><td>Disk Size</td><td>$Disk_size</td></tr></table></td></tr>" >> Health_check.html
echo "<tr><td>FILE SYSTEM DETAILS</td>$File_system</tr>" >> Health_check.html
echo "<tr><td>NIC Information</td><td>$NIC_info</td></tr>" >> Health_check.html
echo "<tr><td>HBA Card Details</td><td>.........</td></tr>" >> Health_check.html
echo "<tr><td>FIRMWARE Details</td><td>.........</td></tr>" >> Health_check.html
echo "<tr><td>SERVICE STATUS</td><td>" >> Health_check.html
echo "<table border=1>" >> Health_check.html
for service in `systemctl --state=running | grep service | awk '{print$1}'`
do
        for check in `systemctl is-active $service`
        do
                if [ $check = 'active' ];then
                        for enabl in `systemctl is-enabled $service`
                        do
                                if [ $enabl = 'enabled' ];then
                                        echo "<tr><td>$service</td><td style=background-color:#00ff7f>service is active and enabled</td></tr>" >> Health_check.html
                                else
                                        echo "<tr><td>$service</td><td>service is active and disabled</td></tr>" >> Health_check.html
                                fi
                        done
                else
                        echo "<tr><td>$service</td><td style=background-color:red>service is dead or mask</td></tr>" >> Health_check.html
                fi
        done
done
echo "</table></td></tr>" >> Health_check.html
echo "<tr><td>log file ERROR Message</td><td>$LOG_File</td></tr>" >> Health_check.html
