repo: all index dist

dist:
	rm -Rf dist
	mkdir -p dist
	find . -name '*.sh' -not -name 'build.sh' -o -name '*.tar.gz' -exec sh -c 'mkdir -p dist/`dirname {}`; cp {} dist/{}' \;

index:
	mkdir -p dist
	./create-index > dist/index

all:
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

clean:
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile` clean; done