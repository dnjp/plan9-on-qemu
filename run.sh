#!/bin/sh

function install() {

	echo -n 'Would you like to install 9front or 9legacy distribution? [9front, 9legacy, 9ants] '
	read distro

	
	echo -n 'Specify in GB how large of an image should be created (ex. 30G): '
	read img_size

	iso_file=''
	image_name=''

	case $distro in
		9front)
			# download iso to 9front.iso
			curl -L http://9front.org/iso/9front-7781.38dcaeaa222c.amd64.iso.gz -o plan9.iso.gz
			gunzip 9front.iso.gz
			stat 9front.iso
			iso_file='plan9.iso'
			image_name='9front.qcow2.img'
			;;
		9legacy)
			curl -L http://9legacy.org/download/9legacy.iso.bz2 -o 9legacy.iso.bz2
			bunzip2 9legacy.iso.bz2
			stat 9legacy.iso
			iso_file='9legacy.iso'
			image_name='9legacy.qcow2.img'
			;;
		9ants)
			curl -L http://files.9gridchan.org/9ants5.64.iso.gz -o 9ants.iso.gz
			gunzip 9ants.iso.gz
			stat 9ants.iso
			iso_file='9ants.iso'
			image_name='9ants.qcow2.img'
			;;
	esac

	qemu-img create -f qcow2 $image_name $img_size

	# Run qemu with installation arguments
	qemu-system-x86_64 -hda $image_name -cdrom $iso_file -boot d -vga std -m 768
}

function run() {

	echo -n 'Do you want to boot 9front or 9legacy? [9front, 9legacy, 9ants] '
	read opt

	image_name=''

	case $opt in
		9front)
			image_name='9front.qcow2.img'
			;;
		9legacy)
			image_name='9legacy.qcow2.img'
			;;
		9ants)
			image_name='9ants.qcow2.img'
			;;
	esac

	echo -n 'How much memory in GB should be used for this machine? (ex. 4G) '
	read mem

	# -m option configures memory. feel free to change to match your preferences
	qemu-system-x86_64 -m $mem $image_name
}


echo -n 'Would you like to install or run Plan 9? [run, install] '
read action

case $action in
	install)
		install
		;;
	run)
		run
		;;
esac
