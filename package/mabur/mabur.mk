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
# bd8f323 (2026-10-19, e89faf7 + the 8812EU build fix): Gilang's master merged -- the boot sensor trim and
# the phase-lock offset from the RCF (venc sensor_cal/sensor_steer), demand
# refresh (venc.gop_s 0: no periodic key frames, the GS asks on damage) --
# and our genlock retired ([genlock] in an old config is ignored). Keeps
# d9's tuned-centre readout. RC_VERSION 16 flag day: pair ONLY with
# sbc-groundstations efficient-link-nack-gs9, and flash with sysupgrade -n
# so the new defaults (gop_s 0) are taken.
# 20a1ccb (2026-10-20, d11): the backlog build. Drone radio comes up at 40 MHz
# and steps to 80 only for the 80 MHz rungs (radio.width_step), hops at 80 use
# the full channel set (radio.fast_hop_at_80 = false), 80 MHz on any primary,
# channels up to 233, the 10 MHz rung when the GS orders it (bw code 3), the
# recorder at nice 19 (record.core / low_priority), per-rung encoder fps
# ([[encoder.rung]] fps, off). RC_VERSION stays 16. The new keys are optional
# and default to the old behaviour, so flash with sysupgrade -n to take the
# new defaults. Pair with sbc-groundstations efficient-link-nack-gs10.
# 1229a24 (2026-10-20): 20a1ccb + a drone-only fix (a failed width switch
# falls back once instead of recursing). The GS image stays on 20a1ccb: the
# difference is drone code only, no wire or config change.
# f79e871 (2026-10-21, d12, a data build): every width switch and full-set
# hop logs devourer's time breakdown (a "set:" line); radio.lean_width
# (false) / radio.lean_verify (true) for the lean width switch. No wire
# change, RC_VERSION stays 16; the new keys are optional. Pair with
# sbc-groundstations efficient-link-nack-gs11.
# e38241a (2026-10-22, d13): f79e871 + radio.switch_rt_prio (0 = off) --
# width switches and hops at SCHED_FIFO with the RX thread, the test of
# whether d12's ~0.5 ms per USB transfer is CPU scheduling. Also carries the
# GS-only menu fix (4bca44c), which the drone does not build. Pair with
# sbc-groundstations efficient-link-nack-gs11.
# a711271 (2026-10-23, d14): e38241a + the stutter A/B switches, all at the
# old behaviour by default -- radio.carrier_sense ("on"; "off", "no_edcca",
# "no_primary" for the 40 MHz stall) and link.shed_max_level (3; 1 = a 2 s
# 30 fps tail instead of 6 s). GS-side pieces (fast fall, promote latency
# guard) ride the same commit; the drone does not build them. No wire change,
# RC_VERSION stays 16. Pair with sbc-groundstations efficient-link-nack-gs13.
# e474f41 (2026-10-24, d15): fresh configs and new defaults. S00mabur
# refreshes an /etc/mabur.toml edited under an older image once (backup in
# /root/mabur.toml.oldN, maburcal's calibration lines kept; /etc/mabur.keep
# opts out); code defaults now match the bundle; channel set
# [36, 100, 116, 132]; the 10 MHz rung's bitrate capped like MCS0/20
# (500 kb/s); top rung 40 Mb/s; radio.spur_warn (on) and radio.spur_ext
# (off). No wire change, RC_VERSION stays 16. Pair with sbc-groundstations
# efficient-link-nack-gs14.
# f67df19 (2026-10-24, d16): d15 + radio.wide_igi_floor (-1 = the image's
# default: off on the 8812EU image, 0x35 on the 8812CU/Wyvern one, which
# needs it for 40 MHz). Pair with sbc-groundstations efficient-link-nack-gs14.
# d3b3bdad (2026-10-30, d17): Gilang's master merged (phase lock pause on a
# frame-rate mismatch, release thread, uplink delivery %, burned DVR rework),
# the GS menu's Camera tab and Settings tab (maburcal, remove calibration),
# menu text without the see-through ring, top rung 45 Mb/s, fast width
# switch on (drone boost 60 + lean), a hand-set wide_igi_floor kept across
# images, the 40 MHz stall fix (IGI floor 0x35) on by default on every image,
# per-core CPU in the telemetry. GS-side pieces ride the same commit: the
# OSD sidecars written at last and split at arm/disarm, MCS3/80 FEC
# 0.5/0.25, the edge_per fade rule, the residual multi-rung drop, the
# penalty fix and the faster climb back. RC_VERSION 17: flash the drone and
# the GS together. Gilang's firmware also says 17 with a different layout
# (his MAVLink tunnel): never pair a drone and a GS across the two. The first
# start wipes /etc/mabur.toml to the image default (clean-slate epoch
# 2026-10-30: no calibration or floor carried, /etc/mabur.keep removed; old
# copy in /root/mabur.toml.oldN).
# 21c7f33d (2026-10-31, d17 rebuilt): + Gilang's three venc memory fixes
# (3bad2f7d, 078ed007, 33413023 + f901ee2a's comment): i6_vif_dev to the 52
# bytes libmi_vif.so copies (a non-zero stack word past it stopped the camera
# on a warm restart), MI_VENC_RcParam_t to 56 (every rate-control Get wrote 4
# bytes past its stack struct) and the CUS3A AE status to 65 (17 bytes past a
# 3A-thread local every tick); the rest pinned with _Static_assert.
# c60b1621 (2026-10-31, d18): the radio rests at 20 MHz (radio.home_width
# 20, was 40) so the 40 MHz stall fix's receiver-gain floor is off on the
# 20 MHz rungs (flight 0009: the uplink failed ~10 dB early and the drone sat
# 35 s in failsafe), and narrows at once while not linked
# (radio.narrow_unlinked). GS side (gs17): a hop order in a fade no longer
# raises the rung (hop.fade_keeps_rung). No wire change: d18 pairs with gs16
# and gs17 alike. The first start refreshes /etc/mabur.toml to the new
# default as usual (calibration and a hand-set floor carried, old copy in
# /root/mabur.toml.oldN); no new clean-slate epoch.
# 36515ba5 (2026-10-31, d18): + low_power.fps = 0: low power keeps the
# camera's frame rate and drops only the bitrate, so arm/disarm no longer
# rebind the encoder (flight 0010: a 100-150 ms pause at each disarm).
# 2fb591eb (2026-10-31, d18): + radio.igi_floor_auto: each drone learns its
# own 40 MHz stall floor (off -> 0x24 -> 0x2c -> 0x35 on a seen stall, saved
# to /etc/mabur.igi_floor; needs devourer 925530d's SetWideTxIgiFloor), and
# venc.sensor_crop / the Camera tab's "Crop 60": 1080p60 from the IMX415's
# unbinned 2816x1584 crop (waybeam's driver). No wire change; a gs16 GS
# just does not show the fifth preset.
MABUR_VERSION = 2fb591ebf74bb4dfd415050d267bd2189180f1d4
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
	# The board's flight-controller UART ([msp] serial, Config.in). The grep
	# fails the build if the bundle's serial line ever changes shape, rather
	# than shipping the wrong port silently.
	$(SED) 's|^serial\([[:space:]]*\)= "[^"]*"|serial\1= "$(call qstrip,$(BR2_PACKAGE_MABUR_MSP_SERIAL))"|' $(TARGET_DIR)/etc/mabur.toml
	grep -q '^serial[[:space:]]*= "$(call qstrip,$(BR2_PACKAGE_MABUR_MSP_SERIAL))"' $(TARGET_DIR)/etc/mabur.toml
endef

$(eval $(cmake-package))
