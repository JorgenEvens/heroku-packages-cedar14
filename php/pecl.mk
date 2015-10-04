PHP_NAME?=php5-fpm
DEPS=build.sh deps deps/$(PHP_NAME).tar.gz
DOCKER_ENV= \
	-e "GIT_URL=$(GIT_URL)" \
	-e "PHP_NAME=$(PHP_NAME)" \
	-e "PHP_VERSION=$(PHP_VERSION)"
PKG_PREFIX=$(PHP_NAME)-

include ../../generic.mk

deps:
	mkdir -p deps

build.sh:
	cp ../pecl.sh build.sh

deps/$(PHP_NAME).tar.gz:
	cd ../v$(PHP_VERSION); make; cp $(PHP_NAME)-$(PHP_VERSION).tar.gz $(CWD)/deps/$(PHP_NAME).tar.gz

clean-all: clean
	$(MAKE) -C ../v$(PHP_VERSION) clean

clean::
	rm -Rf deps
	rm -Rf build.sh
	rm -Rf $(PKG_PREFIX)$(NAME)*.{tar.gz,sh}