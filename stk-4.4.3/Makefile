### Do not edit -- Generated by 'configure --with-whatever' from Makefile.in

RM = /bin/rm

all :
	cd src && $(MAKE)
	cd projects/demo && $(MAKE) libdemo
	cd projects/effects && $(MAKE) libeffects
	cd projects/ragamatic && $(MAKE) libragamat
	cd projects/examples && $(MAKE) -f libMakefile

clean : 
	$(RM) -f *~
	cd src && $(MAKE) clean
	cd projects/demo && $(MAKE) clean
	cd projects/effects && $(MAKE) clean
	cd projects/ragamatic && $(MAKE) clean
	cd projects/examples && $(MAKE) clean

distclean: clean
	$(RM) -rf config.log config.status autom4te.cache Makefile
	cd src && $(MAKE) distclean
	cd projects/demo && $(MAKE) distclean
	cd projects/effects && $(MAKE) distclean
	cd projects/ragamatic && $(MAKE) distclean
	cd projects/examples && $(MAKE) distclean

