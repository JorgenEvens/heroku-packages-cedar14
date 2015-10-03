.PHONY: dist index clean
repo: all dist index

dist:
	rm -Rf dist
	mkdir -p dist
	find . \( -name '*.sh' -not -name 'build.sh' -o -name '*.tar.gz' \) -exec sh -c 'mkdir -p dist/`dirname {}`; cp {} dist/{}' \;

index:
	mkdir -p dist
	cd dist && ../create-index > index

all:
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

clean:
	rm -Rf dist
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile` clean; done

docker-clean:
	docker rm `docker ps -a -q`
