NAME=php-fpm
VERSION=7.0.0RC5
DEPS=deps deps/libmcrypt.tar.gz deps/pcre.tar.gz
DOCKER_ENV= \
	-e "PHP_VERSION=$(VERSION)" \
	-e "PHP_API=20151012" \
	-e "PHP_URL=https://downloads.php.net/~ab/php-7.0.0RC5.tar.bz2"

include ../../generic.mk

deps:
	mkdir -p deps

deps/libmcrypt.tar.gz:
	cd ../../libmcrypt/v2.5.8; make; cp libmcrypt-*.tar.gz $(CWD)/deps/libmcrypt.tar.gz

deps/pcre.tar.gz:
	cd ../../pcre/v8.37; make; cp pcre-*.tar.gz $(CWD)/deps/pcre.tar.gz

clean-all: clean
	$(MAKE) -C ../../libmcrypt/v2.5.8 clean
	$(MAKE) -C ../../pcre/v8.37 clean

clean::
	rm -Rf deps
	rm -Rf $(NAME)*.{tar.gz,sh}