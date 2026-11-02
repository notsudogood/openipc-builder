################################################################################
#
# waybeam-venc
#
################################################################################

# Upstream OpenIPC waybeam_venc, Maruko backend (SigmaStar Infinity6C ==
# SSC378QE). Pinned to the commit the mabur fork's external-encoder mode
# was read against (mabur drone/src/ext_venc.h; docs/ssc378qe-target.md):
# 0.84.0, 2026-09-06. Its frame-shm ring is format version 2, which that
# maburd accepts; a later waybeam that bumps the ring version needs a mabur
# change first, so move this pin and mabur's together.
WAYBEAM_VENC_VERSION = 0c880d8bc874f803b569aa1bf028de82bb6e6045
WAYBEAM_VENC_SITE = https://github.com/OpenIPC/waybeam_venc
WAYBEAM_VENC_SITE_METHOD = git
WAYBEAM_VENC_LICENSE = MIT
WAYBEAM_VENC_LICENSE_FILES = LICENSE
# The MI libraries it dlopens come from the osdrv package (installed at
# target-finalize when majestic is off -- see that package's .mk), NOT from
# waybeam's own vendor-libs/maruko: those were pulled from an older OpenIPC
# image and are linked against uClibc names this musl image does not have.
WAYBEAM_VENC_DEPENDENCIES = sigmastar-osdrv-infinity6c

# waybeam's Makefile normally downloads its own toolchain; MARUKO_CC and an
# empty TOOLCHAIN_TARGET point it at Buildroot's instead (both are plain
# `:=` assignments there, so the command line overrides them). STAB=0 leaves
# out the image-stabilisation framing module: a single-core SoC has no CPU
# to spare for it, and maburd never enables it.
define WAYBEAM_VENC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) build SOC_BUILD=maruko \
		MARUKO_CC="$(TARGET_CC)" TOOLCHAIN_TARGET= STAB=0
endef

# /etc/waybeam.json is this image's own (files/waybeam.json): frame-shm
# output into /mabur_f, 1920x1080 at 60 fps, three H.265 row slices, no RTP,
# no discovery, no audio, no IMU. Its video0.fps / video0.size / sliceCount
# must agree with maburd's /etc/mabur.toml [venc] fps / size / slices
# (mabur.mk sets slices to 3 on this image); maburd stamps the slice
# geometry it was configured with onto every frame it forwards.
define WAYBEAM_VENC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/out/maruko/waybeam $(TARGET_DIR)/usr/bin/waybeam
	$(INSTALL) -D -m 0644 $(WAYBEAM_VENC_PKGDIR)/files/waybeam.json $(TARGET_DIR)/etc/waybeam.json
	$(INSTALL) -D -m 0755 $(WAYBEAM_VENC_PKGDIR)/files/S01waybeam $(TARGET_DIR)/etc/init.d/S01waybeam
endef

$(eval $(generic-package))
