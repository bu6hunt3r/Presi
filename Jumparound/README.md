# SHA CTF 2017
## Jumparound - binary - 4pts
### The classical path
#### Recon
First we do some initial recon. Same procedure on every chall.

	$ file jumparound
	jumparound: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=48fcbfdfe7cdc20098799bdb89a48cc6f8c31c57, not stripped

We could search for interesting ascii-encoded strings in binary with help of strings:

	$ strings jumparound
	/lib64/ld-linux-x86-64.so.2
	libc.so.6
	puts
	printf
	__libc_start_main
	__gmon_start__
	GLIBC_2.2.5
	fffff.
	abcdefghH
	ijklmnopH
	qrstuvwxH
	yz012345H
	
	[...snip...] 

	Well done jumping, the flag is %s
	J@MN
	Too bad, you should jump higher!
	
	[...snip...]

But there's the disadvantage, that we actually don't know the absolute location of any of the found strings relative to binary's position in Access Memory.
