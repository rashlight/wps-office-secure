# Firejail profile for WPS Presentation
# Description: Use WPS Presentation to edit and play presentations.
# This file is overwritten after every install/update

# Persistent local customizations
include wpp.local
# Persistent global definitions
include globals.local

include disable-exec.inc

include whitelist-runuser-common.inc
include whitelist-var-common.inc

apparmor
net none
seccomp
# Drop syscalls from memory-deny-write-execute without breakage
seccomp.drop pkey_mprotect,memfd_create,shmat
