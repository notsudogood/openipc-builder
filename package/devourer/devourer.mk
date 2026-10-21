################################################################################
#
# devourer
#
################################################################################

# Tracks the fork's master HEAD rather than a fixed SHA, deliberately: the
# drone binary is expected to be built from current mabur + current devourer,
# and this repo is not a release artifact.
#
# The branch name cannot be handed to buildroot directly. Its git backend does
# `git init .` in dl/devourer/git -- which points HEAD at refs/heads/master --
# and then `git fetch origin 'master:master'`, which git refuses ("refusing to
# fetch into branch 'refs/heads/master' checked out at ..."). `master` therefore
# never becomes a local ref and the download aborts with "Commit 'master' does
# not exist in this repository". So resolve the branch to a commit id here and
# hand buildroot a plain SHA, which it handles fine.
#
# This also fixes the old download-cache footgun: buildroot keys dl/ on the
# version STRING, so a literal "master" meant dl/devourer/devourer-master.tar.gz
# was reused forever. A SHA that moves with the branch produces a new tarball.
#
# Feedback-repair build, rollout phase 2: PINNED to notsudogood/devourer branch
# claude/wifi-fpv-link-architecture-1bms9l -- gilankpam/devourer master
# 56eabe4 (what the phase-1 images ran) plus per-packet hardware TX queue
# selection (TxMode::hw_queue), which the turnaround bench drives. The GS image
# built from this branch pins the same commit, so both ends run one radio
# driver.
DEVOURER_SITE = https://github.com/notsudogood/devourer
# 3524f4c (2026-10-20, d11): the batched channel set (FastSetChannel; width
# switches and full-set hops in ~60 USB round trips instead of ~190 on the
# 8822E, parity-proven offline incl. spur channels and 10 MHz), 80 MHz on any
# primary of its block, VHT 1SS rates following the HT power diffs.
# 097c527 (2026-10-21, d12, a data build): LastChannelSetStats -- each
# channel set's time split into lock wait, priming read, write batches,
# single round trips and post-set re-asserts -- and the lean width switch
# (tuning.lean_width, off unless mabur's radio.lean_width).
DEVOURER_VERSION = 097c527e8417bc4a1fab0d0818e528a85b5dc724
DEVOURER_SITE_METHOD = git
DEVOURER_LICENSE = GPL-2.0
DEVOURER_LICENSE_FILES = LICENSE

# Source-only. No configure/build/install steps are defined on purpose: the
# tree is consumed by mabur's CMakeLists (add_subdirectory), never built or
# installed standalone. Chip-family selection and the log-level floor are
# passed by mabur.mk, since they are compile-time options of the resulting
# maburd, not of anything this package produces.
DEVOURER_INSTALL_TARGET = NO
DEVOURER_INSTALL_STAGING = NO

$(eval $(generic-package))
