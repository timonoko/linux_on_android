# This is resides in /data/sdext2/ at the base of mounted linux-filesystem partition

error_exit() {
    echo "Error: $1"
}

cd /
mnt=/data/sdext2

###########################################
# Mount all required partitions           #
###########################################
mount -o gid=5,mode=620 -t devpts devpts $mnt/dev/pts 
if [ $? -ne 0 ];then error_exit "Unable to mount $mnt/dev/pts!"; fi
mount -t proc proc $mnt/proc
if [ $? -ne 0 ];then error_exit "Unable to mount $mnt/proc!"; fi
mount -t sysfs sysfs $mnt/sys
if [ $? -ne 0 ];then error_exit "Unable to mount $mnt/sys!"; fi
mount -o bind /sdcard $mnt/sdcard
if [ $? -ne 0 ];then error_exit "Unable to bind $mnt/sdcard!"; fi
mount -o bind /storage/sdcard1 $mnt/sdcard1
if [ $? -ne 0 ];then error_exit "Unable to bind $mnt/sdcard1!"; fi
mount -o bind /storage/usbotg  $mnt/usbotg
if [ $? -ne 0 ];then error_exit "Unable to bind $mnt/usbotg!"; fi


###########################################
# Sets up network forwarding              #k
###########################################
sysctl -w net.ipv4.ip_forward=1
if [ $? -ne 0 ];then error_exit "Unable to forward network!"; fi

# If NOT $mnt/root/DONOTDELETE.txt exists we setup hosts and resolv.conf now
if [ ! -f $mnt/root/DONOTDELETE.txt ]; then
	echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf
	if [ $? -ne 0 ];then error_exit "Unable to write resolv.conf file!"; fi
	echo "nameserver 8.8.4.4" >> $mnt/etc/resolv.conf
	echo "127.0.0.1 localhost" > $mnt/etc/hosts
	if [ $? -ne 0 ];then error_exit "Unable to write hosts file!"; fi
fi

###########################################
# Chroot into ubuntu                      #
###########################################
chroot $mnt /root/init.sh 

###########################################
# Shut down ubuntu                        #
###########################################
echo "Shutting down Linux ARM"
#for pid in `lsof | grep $mnt | sed -e's/  / /g' | cut -d' ' -f2`; do kill -9 $pid >/dev/null 2>&1; done

for pid in `lsof | grep $mnt | sed -e's/  / /g' | cut -d' ' -f2`; do kill -9 $pid >/dev/null 2>&1; done


echo umount $mnt/usbotg
umount $mnt/usbotg
echo umount $mnt/sdcard
umount $mnt/sdcard
echo umount $mnt/sdcard1
umount $mnt/sdcard1
echo umount $mnt/dev/pts
umount $mnt/dev/pts
echo umount $mnt/proc
umount $mnt/proc
echo umount $mnt/sys
umount $mnt/sys
