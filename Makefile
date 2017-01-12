##
##  it's a makefie :-)
##

all:
	##  nothing to make

clean:
	rm -f *~
	rm -f *-init*.ksh
	rm -f *-label.ksh
	rm -f *-adddisk.ksh
	rm -f *-mirror.ksh
	rm -f *-newvol.ksh
	rm -f *-backout.ksh
	rm -f *-brkmir.ksh
	rm -f *-rmplex.ksh
	rm -f *-rmdisk.ksh
	rm -f *-stopvols.ksh
	rm -f *-rmvols.ksh

bundle:
	rm -f Bundle.tar 2>/dev/null
	tar cf Bundle.tar *-adddisk.ksh *-init*.ksh *-mirror.ksh *-newvol.ksh *-brkmir.ksh *-backout.ksh *-rmplex.ksh *-rmdisk.ksh *-label.ksh *-stopvols.ksh *-rmvols.ksh *.fmt  2>/dev/null
	gzip -f Bundle.tar
