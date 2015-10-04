PACKAGES= \
	geoip \
	libmcrypt \
	luajit \
	pcre \
	mediainfo \
	newrelic \
	nginx \
	php \
	phantomjs \
	wkhtmltopdf \
	yasm \
	ffmpeg

.PHONY: dist index clean archive $(PACKAGES)
DOLLAR=$$$$

define GENPACKAGE

$(1):
	for makefile in `find $(1)/* -name Makefile`; do $(MAKE) -C `dirname $(DOLLAR)makefile`; done

endef

repo: all dist index

dist:
	rm -Rf dist
	mkdir -p dist
	find . \( \
		\( -name '*.sh' -not -name 'build.sh' -not -name 'pecl.sh' \) \
		-o \( -name '*.tar.gz' -not -path "*/deps/*" \) \) \
		-exec sh -c 'mkdir -p dist/`dirname {}`; cp {} dist/{}' \;

archive: dist.tar.gz

dist.tar.gz: dist
	tar -caf dist.tar.gz dist

index:
	mkdir -p dist
	cd dist && ../create-index > index

all: $(PACKAGES)

$(foreach pkg,$(PACKAGES),$(eval $(call GENPACKAGE,$(pkg))))

clean:
	rm -Rf dist
	for makefile in `find */* -name Makefile`; do $(MAKE) -C `dirname $$makefile` clean; done

docker-clean:
	docker rm `docker ps -a -q`
