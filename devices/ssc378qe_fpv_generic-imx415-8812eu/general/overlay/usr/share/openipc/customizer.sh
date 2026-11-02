#!/bin/sh
#
# Run once by S30customizer, guarded by /etc/custom.ok in the overlay -- so
# it re-runs whenever the overlay is wiped, which `sysupgrade -n` does.

# Set custom upgrade url -- THIS fork's release, not upstream OpenIPC's: no
# upstream ssc378qe image carries maburd, so a sysupgrade pulling one would
# silently replace the video link.
fw_setenv upgrade 'https://github.com/notsudogood/openipc-builder/releases/download/efficient-link-i6c-a1/ssc378qe_fpv_generic-imx415-8812eu-nor.tgz'

# The sensor, pinned: OpenIPC's infinity6c load_sigmastar re-probes it over
# I2C on every boot of an FPV image, and on the SSC338Q that probe was
# racy enough (5 of 8 boots empty) to leave maburd without a sensor driver.
# This board is defined by its IMX415.
fw_setenv sensor imx415

# None of the SSC338Q images' U-Boot tuning (bootargs, baseaddr) is applied
# here: those lines carry that SoC's memory map and partition layout, and
# this U-Boot has not been measured. bootdelay 0 and verify no are safe on
# any OpenIPC U-Boot and worth ~1.4 s.
fw_setenv bootdelay 0
fw_setenv verify no

exit 0
