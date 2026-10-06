#!/bin/sh
#
# Run once by S30customizer, guarded by /etc/custom.ok in the overlay -- so
# it re-runs whenever the overlay is wiped, which `sysupgrade -n` does.

# Set custom upgrade url -- THIS fork's release, not upstream OpenIPC's: the
# upstream ssc338q_fpv_openipc-urllc-aio image carries no maburd, so a
# sysupgrade pulling it would silently replace the video link.
fw_setenv upgrade 'https://github.com/notsudogood/openipc-builder/releases/download/feedback-repair-listen/ssc338q_fpv_openipc-urllc-aio-nor.tgz'

# Boot-time settings, shipped in the image so a device does not need them
# typed in by hand.  Measured in docs/boot-time-findings-2026-09-07.md
# (mabur repo); all four are safe on the stock U-Boot as well as our fork.
#
# NOTE: these take effect on the NEXT boot.  S30customizer runs long after
# U-Boot has read the environment, so the first boot after a flash is still
# the slow one.
#
#   bootdelay=0   1.195 s on the rebuilt U-Boot (free on the stock one).
#                 The recovery window survives: spamming CR during boot
#                 still reaches the OpenIPC # prompt at bootdelay=0.
#   verify=no     0.250 s -- skips the bootm CRC over the 2 MB image.
#   baseaddr      0.300 s -- reads the kernel one uImage header below its
#                 0x20008000 load address, so bootm prints "XIP Kernel
#                 Image" and skips the copy.  Also the scratch address for
#                 uknor/urnor/ubnor; 0x20007FC0 + 16 MiB is well inside
#                 LX_MEM.
#   bootargs      0.84 s -- quiet loglevel=1.  Single quotes are required so
#                 ${rootmtd}, ${memlx} and ${memsz} reach the environment as
#                 literals for U-Boot to expand at boot.  dmesg is
#                 unaffected; only console transmission is suppressed.
fw_setenv bootdelay 0
fw_setenv verify no
fw_setenv baseaddr 0x20007FC0
fw_setenv bootargs 'console=ttyS0,115200 quiet loglevel=1 panic=20 root=/dev/mtdblock3 init=/init mtdparts=NOR_FLASH:256k(boot),64k(env),2048k(kernel),${rootmtd}(rootfs),-(rootfs_data) LX_MEM=${memlx} mma_heap=mma_heap_name0,miu=0,sz=${memsz}'

exit 0
