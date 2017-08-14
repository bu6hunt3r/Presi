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

There's one rather promising string, let's pick "Well done jumping...". You could encode the first keyword for example by hand, or use your python coding skill's...
Remember that strings are represented in 'natural' order in memory 
	$ python -c 'a="Well"; print a.encode("hex")'
	57656c6c

Then use some grep mechanisms to get absolute loc of it relative to base address...(should be 0x400000)

	$ od -A x -t x1 ./jumparound | grep "57 65 6c 6c"                                                                         git:master
	0006e0 01 00 02 00 00 00 00 00 57 65 6c 6c 20 64 6f 6e

Add the actual offset to hex representation at left:

	$ rax2 -k 0x6e0+9                                                                                                        git:master*
	0x6e9

We still have the problem that we don't know where this string gets xrefr'd...
The binary isn't stripped, so we should have good chances to grab some info by just declaring, that we're intersted in main's contents.
Let's grab contents of main function with objdump:

	$ objdump -D ./jumparound -M intel
	0000000000400626 <main>:
	  400626:       55                      push   rbp
	  400627:       48 89 e5                mov    rbp,rsp
	  40062a:       48 83 ec 10             sub    rsp,0x10
	  40062e:       c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0
	  400635:       83 7d fc 00             cmp    DWORD PTR [rbp-0x4],0x0
	  400639:       75 0c                   jne    400647 <main+0x21>
	  40063b:       bf 38 07 40 00          mov    edi,0x400738
	  400640:       e8 cb fd ff ff          call   400410 <puts@plt>
	  400645:       eb 0a                   jmp    400651 <main+0x2b>
	  400647:       b8 00 00 00 00          mov    eax,0x0
	  40064c:       e8 f5 fe ff ff          call   400546 <print_flag>
	  400651:       c9                      leave  
	  400652:       c3                      ret    
	  400653:       66 2e 0f 1f 84 00 00    nop    WORD PTR cs:[rax+rax*1+0x0]
	  40065a:       00 00 00 
	  40065d:       0f 1f 00                nop    DWORD PTR [rax]

Or do it in batch mode with gdb if you like:

	$ gdb --batch -ex "disassemble main" ./jumparound                                                                        git:master*
	Dump of assembler code for function main:
	   0x0000000000400626 <+0>:     push   rbp
	   0x0000000000400627 <+1>:     mov    rbp,rsp
	   0x000000000040062a <+4>:     sub    rsp,0x10
	   0x000000000040062e <+8>:     mov    DWORD PTR [rbp-0x4],0x0
	   0x0000000000400635 <+15>:    cmp    DWORD PTR [rbp-0x4],0x0
	   0x0000000000400639 <+19>:    jne    0x400647 <main+33>
	   0x000000000040063b <+21>:    mov    edi,0x400738
	   0x0000000000400640 <+26>:    call   0x400410 <puts@plt>
	   0x0000000000400645 <+31>:    jmp    0x400651 <main+43>
	   0x0000000000400647 <+33>:    mov    eax,0x0
	   0x000000000040064c <+38>:    call   0x400546 <print_flag>
	   0x0000000000400651 <+43>:    leave  
	   0x0000000000400652 <+44>:    ret    

So we see, that after some conditions are met function "print_flag" gets called. But disassembly dump of that func is just a mess of hex digits (At least in my eyes)...

	gdb --batch -ex "disassemble print_flag" ./jumparound
	Dump of assembler code for function print_flag:
	   0x0000000000400546 <+0>:     push   rbp
	   0x0000000000400547 <+1>:     mov    rbp,rsp
	   0x000000000040054a <+4>:     sub    rsp,0x90
	   0x0000000000400551 <+11>:    movabs rax,0x6867666564636261
	   0x000000000040055b <+21>:    mov    QWORD PTR [rbp-0x30],rax
	   0x000000000040055f <+25>:    movabs rax,0x706f6e6d6c6b6a69
	   0x0000000000400569 <+35>:    mov    QWORD PTR [rbp-0x28],rax
	   0x000000000040056d <+39>:    movabs rax,0x7877767574737271
	   0x0000000000400577 <+49>:    mov    QWORD PTR [rbp-0x20],rax
	   0x000000000040057b <+53>:    movabs rax,0x3534333231307a79
	   0x0000000000400585 <+63>:    mov    QWORD PTR [rbp-0x18],rax
	   0x0000000000400589 <+67>:    mov    DWORD PTR [rbp-0x10],0x39383736
	   0x0000000000400590 <+74>:    mov    WORD PTR [rbp-0xc],0x6161
	   0x0000000000400596 <+80>:    mov    rax,QWORD PTR [rip+0x173]        # 0x400710
	   0x000000000040059d <+87>:    mov    QWORD PTR [rbp-0x60],rax
	   0x00000000004005a1 <+91>:    mov    rax,QWORD PTR [rip+0x170]        # 0x400718
	   0x00000000004005a8 <+98>:    mov    QWORD PTR [rbp-0x58],rax
	   0x00000000004005ac <+102>:   mov    rax,QWORD PTR [rip+0x16d]        # 0x400720


	
