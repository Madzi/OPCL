Command line version of the ETH Oberon Plugin for Windows 95/98/NT/2000
release 2.4 Portable compiler and linker.

Compiler, linker and kernel by Team of the Institute for Computer Systems
of ETH Zuerich. Copyright 2000 ETH Zuerich Institut fuer Computersysteme,
ETH Zentrum, CH-8092 Zuerich. Refer to the "General ETH Oberon System
Source License" contract available at http://www.oberon.ethz.ch/

Command line wrapper and 'readme' by Eugene Shcherbatyuk.
Current maintainers:
	Alexander Iljin <ajsoft [a] yandex . ru>
	Oleg N. Cher <allot [a] bk . ru>
Contributors:
	Kemet (elbrusstudio —Œ¡¿ ¿ mail “Œ◊ ¿ ru)

Notes on usage

Merge Src\o2ethclc.Reg into your computer registry.
Test the work of compiler and linker using sample programs:

a) compile and link the compiler, linker and sample programs

+CompileAndLink.bat

b) merge Samples\HelloCon.Reg into your computer registry

c) run programs

Samples\HelloCon.exe
Samples\HelloGUI.exe
Samples\HelloDLL.exe

d) run compiler and linker with /? switch to read brief help information.

If you have GNU Make and tr installed, then you can simply run 'make' for
compilation and linking.

Known bugs and limitations

HALT and ASSERT statements are not handled properly. They cause
application errors. You can see that when linker will not find
some of the nessecary files in the current directory. Note, please,
linker will report, say, 'advapi32 not found' and cause windows
application error. That is not an error indeed. That is unhandled
exception caused by issuing HALT command within linker code.

History

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
