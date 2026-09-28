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
# Feedback-repair data-gathering build: PINNED to the gilankpam/devourer master
# commit the 2026-09-27 buildroot-snapshot GS image was built against, and to
# the same commit as the GS image built from this branch, so both ends run one
# radio driver.
DEVOURER_SITE = https://github.com/gilankpam/devourer
DEVOURER_VERSION = 56eabe4ae32f03992deeee8d0b666a7ce81fc81f
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
