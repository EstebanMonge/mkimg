#!/bin/bash

### Print help
function show_help () {
        echo "Usage: $0 [ht] [p backup path]"
        echo "t: test mode only print the final command"
        echo "p: changes default backup path"
        echo "h: print this help"
        exit
}

### Determine if options are used

while getopts p:ht option
do
case "${option}"
in
        p) backup_path=${OPTARG};;
        t) test_flag=true;;
        h) show_help
esac
done

if [[ ! $backup_path ]]
then
        backup_path='/Backup_Linux/os_backups'
fi


### Determine tool paths
if [[ -f /usr/bin/dd ]]
then
        dd_path=/usr/bin/dd
else
        dd_path=/bin/dd
fi

if [[ -f /usr/bin/gzip ]]
then
        gzip_path=/usr/bin/gzip
else
        gzip_path=/bin/gzip
fi

### Determine device to backup
rootvg=$(df -PTh /| grep -oP '(?<=mapper/).*(?=-)')
rootvg=${rootvg/--/-}
hostname=$(hostname -s)
if [[ ! -d $backup_path/$hostname ]]
then
        mkdir $backup_path/$hostname
fi

### Start to backup device
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

        if [[ $test_flag ]]
        then
                echo "$dd_path if=$device conv=sync,noerror bs=64K | $gzip_path -c > $backup_path/$hostname/$devicefile.img.gz"
        else
                $dd_path if=$device conv=sync,noerror bs=64K | $gzip_path -c > $backup_path/$hostname/$devicefile.img.gz
        fi
done
