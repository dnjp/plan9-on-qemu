# Running 9front in Qemu

This guide assumes you are running a x86-64 Linux machine and that you have an
up to date version of Qemu and curl installed.

In the shell examples below, any snippet starting with `$: ` means that it
should be executed on your Linux machine. Any snippet starting with `%: ` should
be executed in the 9front VM.

## Installation

To download the 9front ISO and star the installer in Qemu, execute the
[install script](./install.sh) script:

```
$: ./install.sh
```

Stick with the default options up until 9front boots up. When asked what input
device you would like to use, enter `ps2intellimouse`.

You are now ready to install 9front. To do so, follow the install guide from the
[9front FQA](http://fqa.9front.org/fqa4.html#4.1)

When the installation is complete and you are kicked back out to the tty,
shutdown the Qemu machine.

Now you can simply execute the [run script](./run.sh) to boot up 9front:

```
$: ./run.sh
```

## Setting Resolution

- obtain a list of vesa bios modes

```
%: @{rfork n; aux/realemu; aux/vga -p}
```

- configure one of the valid modes

```
%: @{rfork n; aux/realemu; aux/vga -m vesa -l 1024x768x16}
```

You will likely want to persist this setting so that it is the same when you
reboot the VM. To do that, modify the `vgasize` option in the `plan9.ini` file.

## Modifying plan9.ini

- Mount 9fat partition:

```
%: 9fs 9fat
```

- Bind the local hard drive kernel device over /dev

```
%: bind -b '#S' /dev
```

- Specify the full path to the corresponding 9fat

```
%: 9fs 9fat /dev/sdXX/9fat
```

- Edit the file `/n/9fat/plan9.ini` to configure your desired boot settings

## Configure Rio

Open up your `$home/lib/profile` with either `sam` or `acme`:

```
%: sam $home/lib/profile
```

If you're using sam, you will right click on the blue bar at the top and select
the file you want to edit and then right click on the pale yellow buffer below
it to bring that file into focus.

Find the line that starts the rio window manager and add the `-s` option. The
original will look something like this:

```
rio -i riostart
```

To make rio autoscroll, add the `-s` option. If you'd prefer a black background,
you can add the `-b` option. With both applied, the new command should look like
this:

```
rio -b -s -i riostart
```

To automatically start DHCP when rio starts, add this line above the `switch`
statement:

```
ip/ipconfig
```

You might want to change the default font as well. The best way to do that is to
play around with the system fonts in acme. First, launch acme:

```
%: acme
```

To get a feel for how to use acme, I'd recommend watching the intro by
[Russ Cox](https://www.youtube.com/watch?v=dP1xVpMPn8M).

Once familiar with how to use acme, open the directory `/lib/font/bit/` and try
changing the font by executing something like the following in an acme buffer:

```
Font /lib/font/bit/terminus/unicode.14.font
```

Once you've found one you've liked, update your font selection in
`$home/lib/profile`.

When you are finished editing your `profile`, click on the blue bar to bring it
into focus and enter `w` to write the file followed by `q` to quit, like this:

```
w
q
```

When rio starts up you will see it has two windows open - one in the upper left
showing system stats and a terminal window. The terminal window is a bit small
for my taste, so let's make it bigger.

Open up `$home/bin/rc/riostart` with sam:

```
%: sam $home/bin/rc/riostart
```

Open up the the file in your editors buffer. You will see that there are two
lines starting with `window`. The first sets the location and size for the
stats window. The second is the location and size of our initial terminal
window. This is the line we want to edit.

Replace the contents of the second `window` line with the following:

```
window 200,200,850,600
```

Save and exit sam as you did before.

Reboot the VM with the `fshalt` command:

```
%: fshalt -r
```

## Setup Git

First, we need to obtain [git9](https://github.com/oridb/git9) a git implementation for Plan 9 by Ori
Bernstein ([oridb](https://github.com/oridb)). We will do this in two parts. First, we'll get a bootstrap
version which will give us the `git` command and then we will setup the git9
repository in a place that you can easily update it in the future.

Get the bootstrap version:

```
%: cd /tmp
%: hget https://github.com/oridb/git9/archive/master.tar.gz | tar xvz
%: cd git9-master
%: mk all
%: mk install
```

Now we'll get the version from git which you can easily update:

```
%: cd $home/src
%: git/clone https://github.com/oridb/git9
%: cd git9
%: mk all
%: mk install
```

At this point, you should have a quick read of the man page for git and gitfs
that come with git9:

```
%: man 1 git
%: man 4 gitfs
```

Once you're familiarized with how git on Plan 9 works, let's get your git config
setup:

```
%: mkdir -p $home/lib/git
%: touch $home/lib/git/config
%: sam $home/lib/git/config
```

Add the following contents using your own information using tabs for
indentation:

```
[user]
  name = Your Name
  email = yourname@address.com
```

The last part of this process is to setup your ssh keys with your git provider.
First we'll generate the public and private keys:

```
%: mkdir $home/lib/ssh
%: auth/rsagen -t 'service=ssh' > $home/lib/ssh/key
%: auth/rsa2ssh $home/lib/ssh/key > $home/lib/ssh/key.pub
```

Now that the keys exist, we need to add them to `factotum` so that you can
authenticate using those keys:

```
%: cat $home/lib/ssh/key >/mnt/factotum/ctl
%: ssh git@github.com
```
You should get a success message saying that you have authenticated to Github in
this case. You may also get an error message saying that Github does not provide
shell access which is to be expected.

Assuming that was successful, add both of those commands to `$home/lib/profile`
so that you will be automatically authenticated.

The man pages for git9 should give you most of the information that you need.
The only other thing you may need to know is how to push to a repository using
git+ssh instead of https. You can do that with a command like this:

```
%: git/push -u git+ssh://git@github.com/youruser/yourrepo
```

## Install Go

You will probably want to write programs in a language other than C while you're
working on Plan 9. Go is a popular option and many programs for Plan 9 are
written in Go.

To install Go we will have to bootstrap the installation with an earlier version
of Go already compiled for Plan 9. The process consists of obtaining the
bootstap version and the target version, and telling the target version to use
the bootstrapped version in order to build the toolchain.

To get started we will first make the directory to temporarily house the
installation:

```
%: ramfs
%: cd /tmp
```

Then we'll download both the bootstrap and target versions of Go:

```
%: hget
http://www.9legacy.org/download/go/go1.14.1-plan9-amd64-bootstrap.tbz | bunzip2
-c | tar x

%: hget https://golang.org/dl/go1.14.7.src.tar.gz | gunzip -c | tar x
```

Now we'll make the directory which will contain our target installation and bind
the version we downloaded to that target directory:

```
%: mkdir -p /sys/lib/go/amd64-1.14.7

# bind downloaded go source to system go source
%: bind -c go /sys/lib/go/amd64-1.14.7
```

# change directories to the new location so GOROOT gets set properly when building

In order to ensure that the GOROOT is set correctly, we will change to the
target directory when building Go and tell it where to locate our bootstrap
installation:

```
%: cd /sys/lib/go/amd64-1.14.7/src

%: GOROOT_BOOTSTRAP=/tmp/go-plan9-amd64-bootstrap
```

Next, configure loopback addresses so that the standard library tests will pass:

```
%: ip/ipconfig -P loopback /dev/null 127.1
%: ip/ipconfig -P loopback /dev/null ::1
```

Now that we have everything in place, it's time to start the install. Now's the
time to go get some lunch or do something else because it will take quite a
while:

```
%: ./make.rc
```

If the install was successful, we can now persist the installation and do some
cleanup:

```
%: unmount /sys/lib/go/amd64-1.14.7
%: dircp /tmp/go /sys/lib/amd64-1.14.7
%: unmount /tmp
%: cp /sys/lib/amd64-1.14.7/bin/* /amd64/bin
```

Next you will want to add a line like the following to your `profile` so that
you can run executables in your GOPATH. 

```
bind -a $home/go/bin /bin
```

This is the equivalent of

```
export PATH=$PATH:/some/path
```

