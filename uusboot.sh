# This is resides in /data/sdext2/ at the base of mounted linux-filesystem partition

error_exit() {
    echo "Error: $1"
}

cd /
mnt=/data/sdext2

# Mount all required partitions           #
mount -o gid=5,mode=620 -t devpts devpts $mnt/dev/pts 
mount -t proc proc $mnt/proc
mount -t sysfs sysfs $mnt/sys
mount -o bind /sdcard $mnt/sdcard
mount -o bind /storage/sdcard1 $mnt/sdcard1
mount -o bind /storage/usbotg  $mnt/usbotg

# Sets up network forwarding 
sysctl -w net.ipv4.ip_forward=1

# If NOT $mnt/root/DONOTDELETE.txt exists we setup hosts and resolv.conf now
if [ ! -f $mnt/root/DONOTDELETE.txt ]; then
	echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf
	echo "nameserver 8.8.4.4" >> $mnt/etc/resolv.conf
	echo "127.0.0.1 localhost" > $mnt/etc/hosts
fi

# Chroot into ubuntu
chroot $mnt /root/init.sh 

# Shut down ubuntu
echo "Shutting down Linux ARM"
for pid in `lsof | grep $mnt | sed -e's/  / /g' | cut -d' ' -f2`; do kill -9 $pid >/dev/null 2>&1; done
umount $mnt/usbotg
umount $mnt/sdcard
umount $mnt/sdcard1
umount $mnt/dev/pts
umount $mnt/proc
umount $mnt/sys
