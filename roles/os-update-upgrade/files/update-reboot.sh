#!/usr/bin/env bash
  
##: A simple update and reboot script before ansible-playbook comes to play.
##: Tomas Andriekus

cd && yum update -y

CURRENT_KERNEL="$(rpm -q kernel-$(uname -r))"
test -z "$CURRENT_KERNEL" && exit 0     # Current kernel is a custom kernel

LATEST_KERNEL="$(rpm -q kernel | tail -1)"
test -z "$LATEST_KERNEL" && exit 0      # No kernel package installed

LATEST_KERNEL_INSTALLTIME=$(rpm -q kernel --qf "%{INSTALLTIME}\n" | tail -1)
test -z "$LATEST_KERNEL_INSTALLTIME" && exit 1      # Error reading INSTALLTIME

test "$CURRENT_KERNEL" = "$LATEST_KERNEL" && exit 0 # Latest kernel running, no reboot needed

BOOTTIME="$(sed -n '/^btime /s///p' /proc/stat)"
test -z "$BOOTTIME" && exit 1           # Error reading BOOTTIME

test "$LATEST_KERNEL_INSTALLTIME" -lt "$BOOTTIME" && exit 1  # Latest kernel not running, but system was restarted already
                                                             # User switched back to an old kernel
#printf "\n$(date +"%y-%m-%d") Update command successfull - rebooting" >> /var/log/ansible.log && sleep 2 && /sbin/shutdown -r
