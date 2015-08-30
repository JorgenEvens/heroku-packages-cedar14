all:
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

clean:
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile` clean; done