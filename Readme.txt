OPCL (Oberon Portable Compiler and Linker)
==========================================

OPCL is a command-line version of the Enhanced OP2 Compiler for i386 target
and Linker for Microsoft Windows Platform (32 bit). OPCL is based on
source code of ETH Oberon PlugIn for Windows 95/98/NT/2000, Release 2.5.

Enhanced OP2 compiler is based on OP2 and extends it by supporting dialects
Oberon, Oberon-2, Oberon-X, Active Oberon (subset) and Embedded Assembler.

Front-end authors: Regis Crelier, Patrik Reali (additions).

Back-end authors:
i386:  Patrik Reali, Institut fuer Computersysteme ETH Zuerich,
SPARC: G. Feldmann (additions).

Compiler, linker and kernel by Team of the Institute for Computer Systems
of ETH Zuerich. Copyright 2000 ETH Zuerich Institut fuer Computersysteme,
ETH Zentrum, CH-8092 Zuerich. Refer to the "General ETH Oberon System
Source License" contract available at http://www.oberon.ethz.ch/

Command-line wrapper and 'readme' by Eugene Shcherbatyuk.
Current maintainers:
	Alexander Iljin (ajsoft [at] yandex [dot] ru)
	Oleg N. Cher (allot [at] bk [dot] ru)
Contributors:
	Kemet (elbrusstudio [at] mail [dot] ru)

Notes on usage
==============

Merge Bin\O2ETHCLC.Reg into your computer registry.
Test the work of compiler and linker using sample programs:

a) compile and link the compiler, linker and sample programs

+CompileAndLink.bat

b) run programs

Samples\HelloCon.exe
Samples\HelloGUI.exe
Samples\HelloDLL.exe

c) run compiler and linker with /? switch to read brief help information.

If you have GNU Make and tr installed, then you can simply run 'make' for
compilation and linking.

Known bugs and limitations
==========================

HALT and ASSERT statements are not handled properly. They cause
application errors. You can see that when linker will not find
some of the nessecary files in the current directory. Note, please,
linker will report, say, 'advapi32 not found' and cause windows
application error. That is not an error indeed. That is unhandled
exception caused by issuing HALT command within linker code.

History
=======

10 Feb 2012
- SourceForge hosting: https://sourceforge.net/projects/opcl
- Update compiler and linker to ETH PlugIn Oberon Release 2.5 (7.2.2009).

23 Jan 2012, v0.3
- Show line and column in errors messages (postpone errors also supported).
  Now you can use Syn Text Editor - http://sourceforge.net/projects/syn/
  with syntax scheme "Modula 3". Try this regular expression
    line\s+$[LineNumber]\s+col\s+$[ColNumber]\s
  for setting an error marker to necessary position.
- Add MoveWindow sample application by Alexander Iljin.
- Fix memory allocation bug in OPL.AllocCaseTab.
  Add Test/TestAllocMemError.Mod that crashes compiler without this fix.
  WARNING: this bug is present in official ETH Oberon 2.4, 2.5 and 2.6.
- Add support '_' in identifiers.
- GitHub hosting: https://github.com/Oleg-N-Cher/OPCL

03 Dec 2010, v0.2
- Add full sources, made compiler and linker self-compilable
- Add Makefiles for GNU Make and +CompileAndLink.bat files
- Add Linker '/d' option
- Add HelloDLL.* sample projects
- EOL converted to Windows CRLF, removed binary file headers
- Fix inline assembler (OPA.Mod) LF and comment handling
- Update documentation
- GitHub hosting: https://github.com/AlexIljin/OPCL

?? Nov 2002, v0.1
- Initial release by Eugene Shcherbatyuk.


Friendly projects
=================

ETH PlugIn Oberon for Windows 9x/ME/NT/2000/XP
----------------------------------------------
Oberon is both the name of a programming language and operating system 
developed at ETH Zuerich. This particular distribution contains an 
implementation of ETH PlugIn Oberon Release 2.5 for Windows 9x/ME/NT/2000/XP.
Copyright (C) 1990-2004 Institut fuer Computersysteme ETH Zuerich.

ftp://ftp.ethoberon.ethz.ch/ETHOberon/Win95NT/PlugIn
https://github.com/AlexIljin/WinOberon (latest version 2.6 Prerelease)

Component Pascal compiler
-------------------------
Minimalistic cross-platform compiler for Component Pascal language,
subset of BlackBox Component Builder 1.6 RC5 (forked subsystem Dev),
capable to produce stand-alone software from command-line. 

http://cp-dev.sourceforge.net

Ofront (Oberon2 to C translator)
--------------------------------
Ofront is a tool that translates Oberon-2 programs into semantically
equivalent C programs. Ofront for Windows is primarily intended as
a cross development tool for embedded systems, Unix platforms and the like.
Instead Ofront allows to reuse libraries written in C or other foreign
languages with very little effort and without any run-time overhead.

Ofront for Windows is a version of Ofront for the Microsoft Windows Platform.
It runs as a subsystem of BlackBox Component Builder from Oberon microsystems.

Ofront for Linux is a version of Ofront for i386 based Linux systems.
It has been tested under Debian/etch/testing with Kernel 2.6.19.

http://www.software-templ.com/shareware.html
