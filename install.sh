#!/bin/sh

# download iso to 9front.iso

# Run qemu with installation arguments
qemu-system-x86_64 -hda 9front.qcow2.img -cdrom ./9front.iso -boot d -vga std -m 768

