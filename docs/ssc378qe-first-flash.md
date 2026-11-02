# SSC378QE air unit (IMX415 + RTL8812EU) — first flash

Board `ssc378qe_fpv_generic-imx415-8812eu`, release tag
`efficient-link-i6c-a1`. **Built blind, never booted**: the SoC is
SigmaStar's Infinity6C (one CPU core, kernel 5.10, musl), the encoder is
upstream waybeam_venc's Maruko backend running as its own process, and
maburd reads its frames over shared memory. The design, what it lacks
against the SSC338Q images, and what will decide whether it is any good are
in the mabur repo: `docs/ssc378qe-target.md`. The ground station is
unchanged.

## 0 — Before flashing: what to read off the stock firmware

```sh
HOST=root@<board-ip>
ssh $HOST 'cat /proc/cpuinfo | head -12; cat /proc/mtd; lsusb; fw_printenv | grep -E "^(sensor|soc|mtdparts|bootargs|upgrade)="; ls /dev/ttyS*; uname -a; cat /etc/os-release'
```

What each answers, and what this image assumed:

| Question | This image assumes | If different |
|---|---|---|
| `lsusb` shows `0bda:a81a` (8812EU) | yes | `0bda:c812` is an 8812CU: not this image (it would fail at `CreateRtlDevice`) |
| `/proc/mtd` NOR size (`mtd` sizes add to 0x1000000 = 16 MB) | 16 MB | an 8 MB part needs `BR2_OPENIPC_FLASH_SIZE="8"` in the defconfig |
| `fw_printenv sensor` | imx415 | the customizer pins imx415 at first boot anyway |
| the flight-controller UART | `/dev/ttyS2` | edit `[msp] serial` in `/etc/mabur.toml` after the flash |
| `uname -a` on OpenIPC-based stock firmware: 5.10.61 | yes | a different kernel means the stock U-Boot env (mtdparts, LX_MEM) may not fit this image: stop and compare `bootargs` |
| `cat /etc/os-release` names OpenIPC | yes | a vendor firmware has no `sysupgrade`; flashing needs U-Boot + TFTP, not covered here |

Back up first, as for every board:

```sh
ssh $HOST 'fw_printenv' > env-backup-$(date +%Y%m%d%H%M).txt
for n in 0 1 2 3; do ssh $HOST "dd if=/dev/mtd$n bs=64k 2>/dev/null" > mtd$n-backup.bin; done
```

## 1 — Flash kernel + rootfs (not U-Boot)

```sh
mkdir -p ~/fpv-i6c && cd ~/fpv-i6c
curl -fLO https://github.com/notsudogood/openipc-builder/releases/download/efficient-link-i6c-a1/ssc378qe_fpv_generic-imx415-8812eu-nor.tgz
F=ssc378qe_fpv_generic-imx415-8812eu-nor.tgz
mkdir -p ${F%.tgz} && tar xzf $F -C ${F%.tgz} && cd ${F%.tgz}
md5sum -c uImage.ssc378qe.md5sum rootfs.squashfs.ssc378qe.md5sum
scp -O uImage.ssc378qe rootfs.squashfs.ssc378qe *.md5sum $HOST:/tmp/
ssh $HOST "cd /tmp && md5sum -c uImage.ssc378qe.md5sum && md5sum -c rootfs.squashfs.ssc378qe.md5sum && sysupgrade -f --kernel=/tmp/uImage.ssc378qe --rootfs=/tmp/rootfs.squashfs.ssc378qe"
```

`sysupgrade` reboots the board. The overlay (and any `/etc/wpa_supplicant`
or network setup the stock firmware kept there) survives; the first boot
runs the customizer, which sets the upgrade URL and pins the sensor.

Do **not** flash `u-boot-ssc378qe-nor-padded.bin` if the release carries
one: the stock U-Boot boots this image, and this board's U-Boot has never
been built or tested here.

## 2 — First boot

```sh
ssh $HOST 'grep -E "video: external encoder|MI modules|CreateRadio|radio" /tmp/mabur.log | head -8; echo ---; grep -E "Frame-SHM|sliceSplit|sensor|ERROR" /tmp/waybeam.log | head -12; echo ---; curl -s 127.0.0.1/api/v1/version; echo; ls -la /dev/shm/; dmesg | grep -iE "usb|imx415|mi\b" | tail -12'
```

Expected:

- maburd: `video: external encoder -- frames from frame-shm /mabur_f,
  control at http://127.0.0.1:80`, the MI modules live, the radio up on
  the 8812EU.
- waybeam: `> [maruko] Frame-SHM output: mabur_f (384 KB slots)`, a
  `sliceSplit ... requested=3` line, no `ERROR`. A `dlopen` or
  `MI_SYS_Init` error here is the SDK-library mismatch the design note
  warns about.
- `/dev/shm/mabur_f` exists.
- The goggles link and show a picture.

Then the only number that matters on this SoC, with the link at the
highest rung it reaches:

```sh
ssh $HOST 'top -b -n 3 -d 5 | grep -E "^CPU|maburd|waybeam"'
```

Read the busy % of the one core (ignore the load average: the SDK's
kernel threads sit in D-state and inflate it). Above ~85 % the link will
shed to 30 fps under scene bursts; the first lever is waybeam's
`isp.aeEngine` -> `"custom"` in `/etc/waybeam.json` (restart with
`/etc/init.d/S01waybeam restart`), the second is a lower top-rung
`max_kbps` in `/etc/mabur.toml`.

## 3 — Back to the stock image

`sysupgrade` from the stock image's own release URL (saved in
`env-backup-*.txt` as `upgrade=`), or the mtd backups via `flashcp`
(`docs/flash-uboot.md` has the readback discipline; it applies to mtd2/mtd3
too).
