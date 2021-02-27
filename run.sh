#!/bin/sh

img_size=50G
mem=4G
iso_file='9front.iso'
out_file='9front.iso.gz'
image_name='9front.qcow2.img'
image_url='http://9front.org/iso/9front-8013.d9e940a768d1.amd64.iso.gz'
unpack_cmd='gunzip'

install() {
	# download iso
	if [ ! -f "$out_file" ]; then
		echo 'downloading iso...'
		curl -L $image_url -o $out_file 
	fi

	# unpack iso
	if [ ! -f "$iso_file" ]; then
		echo 'unpacking iso...'
		eval $unpack_cmd $out_file && \
		stat $iso_file 
	fi

	# create qemu image
	if [ ! -f "$image_name" ]; then
		echo "creating a $img_size qemu image..."
		qemu-img create -f qcow2 $image_name $img_size
	fi
	
	if [ -f "$image_name" ]; then
		echo "installing from $iso_file..."
		qemu-system-x86_64 -hda $image_name -cdrom $iso_file -boot d -vga std -m 768
	fi
}

run() {
	# -m option configures memory. feel free to change to match your preferences
	# qemu-system-x86_64 -m $mem $image_name
	
	
#	qemu-system-x86_64 -cpu host -enable-kvm -m 1024  \
#		-net nic,model=virtio,macaddr=52:54:00:00:EE:03 \
#		-netdev user,hostfwd=tcp::17019-:17019,hostfwd=tcp::17020-:17020,\		
#		hostfwd=tcp::12567-:567 -device virtio-scsi-pci,id=scsi  \
#		-drive if=none,id=vd0,file=9front.qcow2.img -device scsi-hd,drive=vd0	

		
	# works
	# qemu-system-x86_64 -m $mem -hda $image_name -net nic \
    		# -net user,hostfwd=tcp:127.0.0.1:17567-:567,hostfwd=tcp:127.0.0.1:17010-:17010
		# -net vde


	# qemu-system-x86_64 \
	    # -cpu host -enable-kvm -m $mem \
	    # -netdev tap,id=eth,ifname=tap0,script=no,downscript=no \
	    # -device e1000,netdev=eth,mac=52:54:00:00:EE:03 \
	    # -device virtio-scsi-pci,id=scsi -drive \
	    # if=none,id=vd0,file=$image_name \
	    # -device scsi-hd,drive=vd0


	SDL_VIDEO_X11_DGAMOUSE=0 

#use kvm and forward cpu features to guest system
# "tap0" created on host, connected to vm
# specify a processor architecture to emulate. 
# specify memory
# You need at least one virtio-scsi-controller and for each block device a -drive and -device scsi-hd pair.

	# qemu-system-x86_64 -m $mem -hda $image_name -net nic \
		# -net user,hostfwd=tcp:127.0.0.1:17567-:567,hostfwd=tcp:127.0.0.1:17019-:17019

	# this works
	# qemu-system-x86_64 \
		# -cpu host \
		# -enable-kvm \
		# -m $mem \
		# -netdev tap,id=eth,ifname=tap0,script=no,downscript=no \
		# -device e1000,netdev=eth,mac=52:54:00:00:EE:03 \
		# -device virtio-scsi-pci,id=scsi \
		# -drive if=none,id=vd0,file=$image_name \
		# -device scsi-hd,drive=vd0 
		
	qemu-system-x86_64 -cpu host -enable-kvm -m $mem \
		-net nic,model=virtio,macaddr=52:54:00:00:EE:03 \
		-net user,hostfwd=tcp::17019-:17019 -net vde -device virtio-scsi-pci,id=scsi \
		-soundhw sb16 -usb -drive if=none,id=vd0,file=$image_name \
		-device scsi-hd,drive=vd0		
}

action=""
if [ -z "$1" ]; then
	echo -n 'Would you like to install or run Plan 9? [run, install] '
	read action
else
	action="$1"
fi

case $action in
	install) install;;
	run) run;;
esac
