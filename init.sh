#!/bin/bash
unset LD_PRELOAD

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:
export TERM=linux

# Executed only once
if [ ! -f /root/DONOTDELETE.txt ]
	then
	echo "Starting first boot setup......."
	chmod a+rw  /dev/null 
	chmod a+rw  /dev/ptmx
	chmod 1777 /tmp
	chmod 1777 /dev/shm
	chmod +s /usr/bin/sudo
	groupadd -g 3001 android_bt 
	groupadd -g 3002 android_bt-net 
	groupadd -g 3003 android_inet
	groupadd -g 3004 android_net-raw
	mkdir /var/run/dbus
	chown messagebus.messagebus /var/run/dbus
	chmod 755 /var/run/dbus
	usermod -a -G android_bt,android_bt-net,android_inet,android_net-raw messagebus
	echo "shm /dev/shm tmpfs nodev,nosuid,noexec 0 0" >> /etc/fstab
	adduser "ubuntu"
	cd /root
	tar cf - .vnc |(cd /home/ubuntu ; tar xf -)
	chown -R ubuntu.ubuntu /home/ubuntu
	usermod -a -G admin ubuntu
	usermod -a -G android_bt,android_bt-net,android_inet,android_net-raw ubuntu
	mknod -m 666 /dev/ptyp0 c 2 0 #NOKO
	mknod -m 666 /dev/ptyp1 c 2 1 #NOKO
	mknod -m 666 /dev/ptyp2 c 2 2 #NOKO
	mknod -m 666 /dev/ptyp3 c 2 3 #NOKO
	mknod -m 666 /dev/ptyp4 c 2 4 #NOKO
	mknod -m 666 /dev/ttyp0 c 3 0 #NOKO
	mknod -m 666 /dev/ttyp1 c 3 1 #NOKO
	mknod -m 666 /dev/ttyp2 c 3 2 #NOKO
	mknod -m 666 /dev/ttyp3 c 3 3 #NOKO
	mknod -m 666 /dev/ttyp4 c 3 4 #NOKO
        echo "boot set" >> /root/DONOTDELETE.txt
fi

# Tidy up previous LXDE and DBUS sessions 
rm /tmp/.X* > /dev/null 2>&1
rm /tmp/.X11-unix/X* > /dev/null 2>&1
rm /root/.vnc/localhost* > /dev/null 2>&1
rm /var/run/dbus/pid > /dev/null 2>&1

# Something uncomprehensible, but vital        
dpkg-divert --local --rename --add /sbin/initctl > /dev/null 2>&1
ln -s /bin/true /sbin/initctl > /dev/null 2>&1

# start VNC, DBUS, SSH, TELNET, FTP servers                 
su ubuntu -l -c "vncserver :0 -geometry 1366x768 -depth 16"
dbus-daemon --system --fork > /dev/null 2>&1
/etc/init.d/ssh start
/usr/sbin/inetd /etc/inetd.conf # telnet and ftp enabled in /etc/inetd.conf

# Login, some of these might work
telnet 127.0.0.1 -l "ubuntu"
# ssh 127.0.0.1 -l "ubuntu" 
# bash -l "ubuntu"

# When exit from the login session Kill Everything
killall -9 inetd
su ubuntu -l -c "vncserver -kill :0"
/etc/init.d/ssh stop
