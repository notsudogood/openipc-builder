################################################################################
#
# mabur
#
################################################################################

# Efficient-link build: PINNED, not tracking a branch, so the drone and the
# ground station (sbc-groundstations, same branch name) carry the identical
# mabur commit -- a mismatched pair has no control link and no video (mabur
# CLAUDE.md, "Deploy is two devices"). The commit is gilankpam/mabur c8f9863 +
# the efficient-link plan (docs/efficient-link-plan.md) on notsudogood/mabur
# branch claude/wifi-fpv-link-architecture-1bms9l, with gilankpam/mabur
# slice-salvage 4c66e11 merged in (2026-10-10, mabur 68d22ce): H.265 row
# slices ([venc] slices = 4), the software NACK answers ([nack]; re-sends on
# the voice queue), link pairing (/etc/mabur.key, missing = built-in default)
# and the channel set ([radio] channels). RC_VERSION 15: pair only with a GS
# on the same commit. The merge also changed /etc/mabur.toml's keys (vtx_id,
# channel and follow_gs are gone) and the parser rejects unknown ones, so an
# edited copy kept in the overlay fails boot: restore it with
# `cp /rom/etc/mabur.toml /etc/mabur.toml` and re-apply edits. Genlock as
# before (T_GENLOCK now tagged), off unless [genlock] enable = true.
# dfb1aaa (2026-10-11): per-rung airtime budget and bitrate cap
# ([[encoder.rung]]) and the encoder floor lowered to 300 kbps. Includes the
# GS-only d0425d1 (the GS image runs that commit; no wire change, RC_VERSION
# stays 15, so the pair still links). The new keys are optional: an edited
# /etc/mabur.toml from the previous build still boots and behaves as before
# until the [[encoder.rung]] tables are added to it.
# 057decf (2026-10-13): drone core-placement knobs for the 40+ Mb/s CPU bench --
# fec.worker_core ("rest" default | "hot") and radio.tx_threads_hot (0
# default); both default to the old placement, so an edited /etc/mabur.toml
# boots and behaves as before. Also carries the GS-only load diet (3b1d509);
# no wire change, RC_VERSION 15.
# 2ed0441 (2026-10-13, drone CPU cut): the start-code scans jump between zero
# bytes (memchr) instead of testing every byte, the sub-block CRC16 runs
# 8 bytes per step (slicing-by-8), and fec.worker_spin (default unchanged)
# bounds the FEC worker's idle spin. Same output; an edited /etc/mabur.toml
# boots unchanged. No wire change, RC_VERSION 15.
# fc033f6 (2026-10-14): merges gilang/master (slice-by-slice streamed decode
# on the GS) and adds the 80 MHz linkbench tooling; linkbench-tx now ships
# in /usr/bin (below). WIRE FLAG DAY: FrameHdr byte 3 is slice_rows (was a
# constant codec id) and RC_VERSION stays 15, so a mismatched pair does not
# refuse, it misassembles. Pair ONLY with sbc-groundstations
# efficient-link-nack-gs7. An edited /etc/mabur.toml boots unchanged.
# 9f2029e (2026-10-17): 80 MHz top rungs (VHT MCS3/80 at 35 Mb/s, MCS4/80 at
# 50 Mb/s); the default /etc/mabur.toml is now radio.width = 80 on channels
# [36, 132]. maburcal keeps a no-dip rate at its pre-calibration power. An
# old /etc/mabur.toml still boots (it stays at 40 MHz, and an 80 MHz rung
# then flies at 40): flash with sysupgrade -n to take the new defaults.
# Pair with sbc-groundstations efficient-link-nack-gs8.
MABUR_SITE = https://github.com/notsudogood/mabur
# e246f8c (2026-10-18): diagnosis build for the 80 MHz hop fault -- maburd
# logs the radio's real tuned centre and the FastRetune time after every
# retune, re-reads it every 5 s (stats rfc= / rf_bad=). No config change:
# flash WITHOUT -n to keep the bench /etc/mabur.toml.
MABUR_VERSION = e246f8c66b955497dafc2762d47dbe7e7eadaf55
MABUR_SITE_METHOD = git
MABUR_LICENSE = MIT
MABUR_SUPPORTS_IN_SOURCE_BUILD = NO

# devourer comes from its own package, NOT from mabur's git submodule
# (MABUR_GIT_SUBMODULES is deliberately unset). The submodule records a fixed
# SHA that lags the fork's master, and the in-tree cross-build
# (tools/build-arm.sh) does not use the submodule either -- it points
# DEVOURER_DIR at a sibling checkout. Sourcing devourer separately keeps the
# buildroot build consistent with that and lets both trees float.
MABUR_DEPENDENCIES = libusb host-pkgconf devourer

# BUILD_SHARED_LIBS=OFF: devourer's add_library(devourer ...) has no explicit
# STATIC/SHARED, so it follows BUILD_SHARED_LIBS. Buildroot defaults that ON,
# which built libdevourer.so -- but the recipe installs only maburd, so on target
# maburd died with "error while loading shared libraries: libdevourer.so".
# Forcing it OFF links devourer (and mabur_common) statically into maburd, the
# same self-contained layout tools/build-arm.sh produces; the only remaining
# runtime deps are Buildroot's own libusb/libstdc++/libc, which are on the image.
# (maburd also dlopens the SigmaStar MI libraries from the vendor rootfs at
# runtime -- that is why it must stay a glibc DYNAMIC executable.)
#
# DEVOURER_LOG_MAX_LEVEL=WARN: compile out info/debug/trace. devourer logs one
# info line per TX frame ("bulk_send EP 5 OK N bytes"); at maburd's frame rate
# that floods RAM-backed /tmp/mabur.log until the next respawn truncates it.
#
# The DEVOURER_* chip selects mirror tools/build-arm.sh. Without them every
# Realtek family is compiled in -- including DEVOURER_8733B, which defaults ON
# upstream and must be OFF here. Keep the two lists in step. The one
# deliberate difference: the Jaguar3 die is the board's Kconfig radio choice
# (Config.in), where build-arm.sh is always the 8822E -- the bench drone's
# card. Exactly one of the two is ON.
#
# MABUR_BUILD_GS=OFF: this is the drone image; maburgs is not useful on the
# SSC338Q. MABUR_BUILD_LINKBENCH=ON (since d7) for linkbench-tx, the drone
# half of the 80 MHz bench (mabur docs/bw80-research-2026-10-12.md). It
# links its own copy of devourer: ~1 MB unpacked on a rootfs that was
# 5.5 MB in d6 (16 MB NOR).
MABUR_CONF_OPTS = \
	-DDEVOURER_DIR=$(DEVOURER_DIR) \
	-DMABUR_BUILD_TESTS=OFF \
	-DMABUR_BUILD_DRONE=ON \
	-DMABUR_BUILD_GS=OFF \
	-DMABUR_BUILD_LINKBENCH=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DDEVOURER_LOG_MAX_LEVEL=WARN \
	-DDEVOURER_JAGUAR1=OFF \
	-DDEVOURER_8814=OFF \
	-DDEVOURER_JAGUAR2_8822B=OFF \
	-DDEVOURER_JAGUAR2_8821C=OFF \
	-DDEVOURER_8733B=OFF \
	-DDEVOURER_KESTREL_8852B=OFF \
	-DDEVOURER_KESTREL_8852C=OFF

ifeq ($(BR2_PACKAGE_MABUR_RADIO_8812CU),y)
MABUR_CONF_OPTS += -DDEVOURER_JAGUAR3_8822C=ON -DDEVOURER_JAGUAR3_8822E=OFF
else
MABUR_CONF_OPTS += -DDEVOURER_JAGUAR3_8822C=OFF -DDEVOURER_JAGUAR3_8822E=ON
endif

# Config, init script and binary all come from the same floating master
# checkout, which is the whole point: an unknown key fails boot and the wrapper
# then respawns maburd forever at 2 s, so the three must never be mixed across
# commits. The json/toml either-or that used to live here is gone -- the TOML
# cutover landed on master and bundle/mabur.default.json no longer exists.
#
# Since 2026-09-08 that bundle file is not a neutral seed but a verbatim copy
# of the drone's own /etc/mabur.toml, so a fresh flash boots the flight
# configuration rather than something nobody has flown. Retune it in the mabur
# repo (tests/test_config.cpp pins it), not only on the device.
define MABUR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(MABUR_BUILDDIR)/drone/maburd $(TARGET_DIR)/usr/bin/maburd
	$(INSTALL) -D -m 0755 $(MABUR_BUILDDIR)/bench/linkbench/linkbench-tx $(TARGET_DIR)/usr/bin/linkbench-tx
	# Installed as S00mabur, not S96mabur: busybox rcS runs /etc/init.d/S*
	# strictly serially in lexical order, and maburd goes FIRST -- ahead of
	# seedrng, syslogd, fake-hwclock, sysctl, customizer, mdev, network, ntpd,
	# dropbear and crond, none of which video needs (devtmpfs makes the
	# device nodes; mdev only adds SD-card automount rules). The MI modules
	# are no longer loaded by an init script at all: maburd runs
	# load_sigmastar itself (a constant in drone/src/main.cpp) under its USB port reset,
	# so the insmod chain lands under the radio bring-up instead of ahead of
	# maburd's exec. Measured 2026-09-09: first AU on the GS 5.40 -> 4.37 s
	# of uptime (mabur docs/boot-time-findings-2026-09-07.md, "rcS, stamped").
	$(INSTALL) -D -m 0755 $(@D)/bundle/S96mabur $(TARGET_DIR)/etc/init.d/S00mabur
	$(INSTALL) -D -m 0644 $(@D)/bundle/mabur.default.toml $(TARGET_DIR)/etc/mabur.toml
endef

$(eval $(cmake-package))
