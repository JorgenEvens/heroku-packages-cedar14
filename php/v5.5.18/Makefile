.PHONY: clean

CWD=$(shell pwd)
OUTPUT="/tmp/out"
PHP_VERSION=5.5.18

DEPS=deps deps/libmcrypt.tar.gz deps/pcre.tar.gz

all: php5-fpm-$(PHP_VERSION).tar.gz

debug: $(DEPS)
	docker run -i -t -v "$(CWD):$(OUTPUT)" -e "PHP_VERSION=$(PHP_VERSION)" heroku/cedar

deps:
	mkdir -p deps

php5-fpm-$(PHP_VERSION).tar.gz: $(DEPS)
	docker run -i -v "$(CWD):$(OUTPUT)" \
		-e "PHP_VERSION=$(PHP_VERSION)" \
		heroku/cedar \
		sh $(OUTPUT)/build.sh "$(OUTPUT)"

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