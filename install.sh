#!/bin/sh

# download iso to 9front.iso
curl -L http://9front.org/iso/9front-7781.38dcaeaa222c.amd64.iso.gz -o plan9.iso

# Run qemu with installation arguments
qemu-system-x86_64 -hda 9front.qcow2.img -cdrom ./9front.iso -boot d -vga std -m 768

