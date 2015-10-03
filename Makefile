PACKAGES=geoip libmcrypt luajit mediainfo pcre newrelic nginx php
.PHONY: dist index clean archive $(PACKAGES)

repo: all dist index

dist:
	rm -Rf dist
	mkdir -p dist
	find . \( -name '*.sh' -not -name 'build.sh' -o -name '*.tar.gz' \) -exec sh -c 'mkdir -p dist/`dirname {}`; cp {} dist/{}' \;

index:
	mkdir -p dist
	cd dist && ../create-index > index

all: $(PACKAGES)

geoip:
	for makefile in `find geoip/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

libmcrypt:
	for makefile in `find libmcrypt/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

luajit:
	for makefile in `find luajit/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

mediainfo:
	for makefile in `find mediainfo/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

pcre:
	for makefile in `find pcre/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

newrelic:
	for makefile in `find newrelic/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

nginx:
	for makefile in `find nginx/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

php:
	for makefile in `find php/* -name Makefile`; do $(MAKE) -C `dirname $$makefile`; done

clean:
	rm -Rf dist
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile` clean; done

docker-clean:
	docker rm `docker ps -a -q`
