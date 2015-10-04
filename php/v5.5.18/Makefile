NAME=php5-fpm
VERSION=5.5.18
DEPS=deps deps/libmcrypt.tar.gz deps/pcre.tar.gz
DOCKER_ENV= \
	-e "PHP_VERSION=$(VERSION)"

include ../../generic.mk

deps:
	mkdir -p deps

deps/libmcrypt.tar.gz:
	cd ../../libmcrypt/v2.5.8; make; cp libmcrypt-*.tar.gz $(CWD)/deps/libmcrypt.tar.gz

deps/pcre.tar.gz:
	cd ../../pcre/v8.37; make; cp pcre-*.tar.gz $(CWD)/deps/pcre.tar.gz

clean:
	$(MAKE) -C ../../libmcrypt/v2.5.8 clean
	$(MAKE) -C ../../pcre/v8.37 clean
	rm -Rf deps
	rm -Rf php5-fpm*.tar.gz
	rm -Rf php5-fpm-*.sh