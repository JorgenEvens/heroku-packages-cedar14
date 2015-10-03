.PHONY: deps clean

CWD=$(shell pwd)
OUTPUT="/tmp/out"
PHP_VERSION=5.5.18
PHP_API_VERSION=20121212

all:
	docker run -i -v "$(CWD):$(OUTPUT)" -e "PHP_VERSION=$(PHP_VERSION)" heroku/cedar sh $(OUTPUT)/build.sh "$(OUTPUT)"

debug:
	docker run -i -t -v "$(CWD):$(OUTPUT)" -e "PHP_VERSION=$(PHP_VERSION)" heroku/cedar

deps:
	mkdir -p deps
	cd ../v$(PHP_VERSION); make; cp php5-fpm-$(PHP_VERSION).tar.gz $(CWD)/deps/php5-fpm.tar.gz

clean:
	$(MAKE) -C ../latest clean
	rm -Rf deps
	rm -Rf php5-fpm*.tar.gz
	rm -Rf php5-fpm-*.sh