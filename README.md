# linux_on_android
Simplest possible linux_on_android on rooted android 5.0

Most code is stolen from other LoA-projects, of course. I do not know shit. 

Needs busybox and starts with terminal command "linuksi".

Firstly you root the phone (Kingroot works).

And then you make a separate EXT3-partition and mount it at /data/sdext2.

And then you dump a complete linux system on that partition.

And then you copy "linuksi" to /system/bin/ ,
           and "uusboot.sh" to /data/sdext2/ ,
           and "init.sh" to /data/sdext2/root/.
           
"onnanoko" is the default user.
