CWD=$(shell pwd)
OUTPUT="/tmp/out"

all: deps
	docker run -i -v "$(CWD):$(OUTPUT)" -e "PHP_VERSION=5.5.18" heroku/cedar sh $(OUTPUT)/build.sh "$(OUTPUT)"

debug: deps
	docker run -i -t -v "$(CWD):$(OUTPUT)" -e "PHP_VERSION=5.5.18" heroku/cedar

deps:
	mkdir -p deps
	cd ../../libmcrypt/v2.5.8; make; cp libmcrypt-*.tar.gz $(CWD)/deps/libmcrypt.tar.gz
	cd ../../pcre/v8.37; make; cp pcre-*.tar.gz $(CWD)/deps/pcre.tar.gz

clean:
	$(MAKE) -C ../../libmcrypt/v2.5.8 clean
	$(MAKE) -C ../../pcre/v8.37 clean
	rm -Rf deps
	rm -Rf php5-fpm*.tar.gz
	rm -Rf php5-fpm-*.sh