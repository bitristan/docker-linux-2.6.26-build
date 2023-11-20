FROM i386/ubuntu:14.04

# fix debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

# use aliyun source
COPY sources.list /etc/apt/sources.list
RUN apt-get clean

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y libncurses5-dev
RUN apt-get install -y git
RUN apt-get install -y qemu
RUN apt-get install -y gdb

RUN git clone --branch v2.6.26 --depth 1 https://github.com/torvalds/linux /home/linux

WORKDIR /home/linux
RUN git checkout -b v2.6.26

COPY fix.patch /home/linux/fix.patch
RUN git apply fix.patch
RUN git config --local user.name test
RUN git config --local user.email test@example.com
RUN git add .
RUN git commit -m "fix compile issue."
RUN rm fix.patch

RUN make ARCH=i386 defconfig
RUN make ARCH=i386 V=1

RUN mkdir /home/initrd
COPY init.c /home/initrd/

WORKDIR /home/initrd
RUN gcc -static -o init init.c
RUN mkdir rootfs
RUN cp init rootfs
RUN mkdir rootfs/dev
RUN mknod rootfs/dev/ram b 1 0
RUN mknod rootfs/dev/console c 5 1
RUN cd rootfs && find . | cpio -o -H newc | gzip > ../myinitrd.img
RUN rm -rf rootfs

WORKDIR /
