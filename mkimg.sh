#!/bin/bash

backup_path='/Backup_Linux/os_backups'
rootvg=$(df -PTh /| grep -oP '(?<=mapper/).*(?=-)')
hostname=$(hostname -s)
if [[ ! -d $backup_path/$hostname ]]
then
        mkdir $backup_path/$hostname
fi
for partition in $(pvs|grep -w $rootvg|awk '{print $1}')
do
        if [[ $partition == *mapper* ]]
        then
                devicefile=${partition#*/*/*/}
        else
                devicefile=${partition#*/*/}
        fi
        device=${partition/[[:digit:]]/}
        devicefile=${devicefile//[[:digit:]]/}
        /usr/bin/dd if=$device conv=sync,noerror bs=64K | /usr/bin/gzip -c > $backup_path/$hostname/$devicefile.img.gz
done

