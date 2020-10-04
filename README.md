# Running Plan 9 in Qemu

This guide assumes you are running a x86-64 Linux machine and that you have an
up to date version of Qemu and curl installed. You may want to clone
[the repo](https://github.com/danieljamespost/plan9-on-qemu) containing useful
scripts to help you get started.

In the shell examples below, any snippet starting with `$: ` means that it
should be executed on your Linux machine. Any snippet starting with `%: ` should
be executed in the Plan 9 VM.

## Installation

The
[install script](https://github.com/danieljamespost/plan9-on-qemu/blob/master/run.sh)
script can setup [9front](http://9front.org/),
[9front-ANTS](http://ants.9gridchan.org/), or the
[9legacy](http://9legacy.org/) distribution.

Execute the install script and answer the prompts to install your selected distibution:

```
$: ./run.sh
```

Stick with the default options up until Plan 9 boots up. When asked what input
device you would like to use, enter `ps2intellimouse`.

You are now ready to install Plan 9. To do so, follow the install guide from the
[9front FQA](http://fqa.9front.org/fqa4.html#4.1)

When the installation is complete and you are kicked back out to the tty,
shutdown the Qemu machine.

Now you can simply execute the [run script](https://github.com/danieljamespost/plan9-on-qemu/blob/master/run.sh) and select "run" to boot up your selected image.

## Setting Resolution

Obtain a list of vesa bios modes

```
%: @{rfork n; aux/realemu; aux/vga -p}
```

Configure one of the valid modes

```
%: @{rfork n; aux/realemu; aux/vga -m vesa -l 1024x768x16}
```

You will likely want to persist this setting so that it is the same when you
reboot the VM. To do that, modify the `vgasize` option in the `plan9.ini` file.

## Modifying plan9.ini

Bind the local hard drive kernel device over /dev

```
%: bind -b '#S' /dev
```

Specify the full path to the corresponding 9fat

```
%: 9fs 9fat /dev/<your hd>/9fat
```

Edit the file `/n/9fat/plan9.ini` to configure your desired boot settings.

If the above does not work on your system, give
[this script](https://github.com/danieljamespost/plan9-on-qemu/blob/master/run.sh)
a try.


## Create your own user

"glenda" is the default user on Plan 9. However, you will likely want
to create a user for yourself.

To do so, we will first connect to the Fossil file server console and
create the new user:

```
%: con -l /srv/fscons
```

Once connected, your prompt will change to simply "prompt: ". First,
create your user:

```
prompt: uname <username> <username>
```

Then you can add your user to the groups that make sense. To give your
user system priveledges, add yourself to the `sys` group:

```
prompt: uname <username> +sys
```

```
prompt: uname sys +<username>
```

If you want access to `/adm` then add your user to the adm group:

```
prompt: uname adm +<username>
```

Type `CTL+\` and then type `q` at the prompt:

```
>>> q
```

Now that the file system knows about our new user, we need to configure
and enable the new user. First we'll start keyfs so we can change
authentication information:

```
%: auth/keyfs
```

Then we will configure the user:

```
%: auth/changeuser <username>
```

All that's left is to enable the user:

```
%: auth/enable <username>
```

If the above fails, make sure that the auth/cpu kernel is running in
your plan9.ini. To be sure, set `server=cpu` in the plan9.ini.

## Setup keyboard

If you use a fairly standard layout, you're desired settings can most
easily be changed with kbmap:

```
%: kbmap
```

Right click your desired setting and then type "q" to quit.

If you're using a layout like [Colemak](https://colemak.com/)
(your truly), then you can add the layout I have
[here](https://github.com/danieljamespost/plan9-on-qemu/blob/master/extra/colemak)
to kbmap:

```
%: hget https://github.com/danieljamespost/plan9-on-qemu/blob/master/extra/colemak > /sys/lib/kbmap/colemak
```

Then just run `kbmap` as above and select "colemak".

To persist these settings add something like the following to your
`$home/lib/profile` directly above `rio` in the `terminal` case statement:


```
cat /sys/lib/kbmap/colemak > /dev/kbmap
```

## Configure Rio

Open up your `$home/lib/profile` with either `sam` or `acme`

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

If `$home/bin/rc/riostart` does not exist, create a mostly empty script
that looks like this for now:

```
#!/bin/rc

```

Then make it executable with `chmod +x $home/bin/rc/riostart`


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

# Ports

There are ports of some unix tools and other applications that run on
Plan 9 in the front ports. All you have to do is clone the ports tree
into your system:

```
% hg clone http://code.9front.org/hg/ports /sys/ports
```

Then to install a port, for example `media-fonts`, you would do this:

```
%: cd /sys/ports/media-fonts
%: mk nuke
%: mk build
%: mkdir /lib/font/ttf
%: mk install
```


## Setup Git

 [git9](https://github.com/oridb/git9) is a git implementation for Plan
 9 by Ori
Bernstein ([oridb](https://github.com/oridb)) that works quite well on
Plan 9. There are two ways to install git9 - using 9front Ports or via
git for the most up to date changes.

Using 9front Ports, the installation is very straight forward:

```
%: cd /sys/ports/dev-vcs/git9
%: mk install
```

For the git install, we'll first  get a bootstrap version which will
give us the `git` command and then we will setup the git9 repository in
a place that you can easily update it in the future.

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
%: ssh git@git.sr.ht
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

For [Sourcehut](https://sourcehut.org/), you'll need to use ssh/git+ssh for read/write:

```
%: git/clone ssh://git@git.sr.ht/~youruser/yourrepo
%: git/clone git+ssh://git@git.sr.ht:~youruser/yourrepo
```

An example configuration might look like this:

```
[remote "origin"]
    url = git+ssh://git@git.sr.ht:~youruser/yourrepo
    fetch = +refs/heads/*:refs/remotes/origin/*
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
%: dircp /tmp/go /sys/lib/go/amd64-1.14.7
%: cp /sys/lib/go/amd64-1.14.7/bin/* /amd64/bin
%: unmount /tmp
```

Next you will want to add a line like the following to your `profile` so that
you can run executables in your GOPATH.

```
bind -a $home/go/bin /bin
```

This is the equivalent of `export PATH=$PATH:/some/path` on Unix.

# Next Steps

I will continue to keep this post updated with relevant information to make sure
it's always up to date. If there is anything that you feel is missing, feel free
to file an issue in Github.

You may want to take a look at the [Plan 9
Wiki](https://9p.io/wiki/plan9/plan_9_wiki/) which contains useful articles and
links which should help you get more familiar with Plan 9.
