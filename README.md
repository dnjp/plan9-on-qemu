# 9front and Drawterm

## Edit plan9.ini File

```
% 9fs 9fat
% cd /n/9fat
```

Backup plan9.ini

```
% cp plan9.ini plan9.ini.bak
```

Get IP address

```
% ip/ipconfig
% cat /net/ndb
```

Edit plan9.ini

```
% sam plan9.ini
```

Add the following to the end of the plan9.ini file

```
# -A authentication, -a announce stream to listen on
nobootprompt=local!/dev/sdC0/fs -m <mem> -A -a tcp!*!564
user=glenda
auth=<your ip address>
cpu=<your ip address>
authdom=<choose name>
service=cpu
```

## Setup auth server

Write the host owner name and password key to NVRAM

```
% auth/wrkey
# authid: glenda
# authdom: <same as plan9.ini>
# secstore key: <enter password>
# password: <enter same password>
% auth/keyfs
% auth/changeuser glenda
# Password: <same as used above>
# POP secret: doesn't matter
# Expiration Date: never
# Post id: glenda
# User's full name: <whatever you want>
% auth/enable glenda
```

## Configure ndb

Edit ndb config file

```
% cd /lib/ndb
% sam ./local
```

Add properties to `sys=somehost ether=...`

```
sys=<keep value> ether=<keep value> authdom=<same as plan9.ini> auth=<your ip address> ip=<your ip>
```

Setup ipnet below `sys` line

```
ipnet=<give a name> ip=<your ip, replace last number with 0> ipmask=<same as /net/ndb>
	ipgw=<same as /net/ndb>
	auth=<your ip>
	authdom=<same as plan9.ini>
	fs=<your ip>
	cpu=<your ip>
	dns=<same as /net/ndb>
```

## Clean up

Sync the disk and reboot

```
% echo sync >> /srv/hjfs.cmd
% fshalt -r
```

## SSH Configuration


