# docker-linux-2.6.26-build
Docker env for building linux kernel 2.6.26, mainly for debugging the Linux kernel in 32-bit 386 environment.

Tested on macOS M1 and debian bookworm amd64.

## build docker image
``` bash
docker build -t linux-2.6.26-builder:1.0.0 .
```

## run image
``` bash
docker run --privileged --name linux-builder -itd linux-2.6.26-builder:1.0.0 /bin/bash
```

## compile linux image

First connect to docker container
``` bash
docker exec -it linux-builder /bin/bash
```

We have already compiled the linux kernel source code when creating the docker image. 
The compiled target file is in the following path:
- /home/linux/vmlinux: the uncompressed Linux kernel executable in the ELF.
- /home/linux/arch/x86/boot/bzImage: the compressed Linux kernel image that is bootable by the system’s bootloader.

If you want to compile the kernel source code again, you can run the command below
```
cd /home/linux
make ARCH=i386 menuconfig # change build config if needed or just ignore this
make ARCH=i386 V=1
```

## run kernel image with qemu
``` bash
qemu-system-i386 -kernel /home/linux/arch/x86/boot/bzImage -initrd /home/initrd/myinitrd.img -append "root=/dev/ram init=/init console=ttyS0" -nographic
```

If you are interested in the generation of myinitrd.img, just view the Dockerfile.

## debug kernel with qemu

Run qemu in debug mode first
``` bash
qemu-system-i386 -kernel /home/linux/arch/x86/boot/bzImage -initrd /home/initrd/myinitrd.img -append "root=/dev/ram init=/init console=ttyS0" -nographic -S -s
```

Then connect to docker container in another shell, and then debug vmlinux with gdb.
``` bash
docker exec -it linux-builder /bin/bash

gdb /home/linux/vmlinux
```
