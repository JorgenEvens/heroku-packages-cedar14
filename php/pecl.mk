.PHONY: clean

CWD=$(shell pwd)
OUTPUT="/tmp/out"
DEPS=build.sh deps deps/php5-fpm.tar.gz

all: php5-fpm-$(NAME)-$(VERSION).tar.gz

debug: $(DEPS)
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
		-e "NAME=$(NAME)" \
		-e "VERSION=$(VERSION)" \
		-e "GIT_URL=$(GIT_URL)" \
		-e "PHP_VERSION=$(PHP_VERSION)" \
		heroku/cedar

deps:
	mkdir -p deps

php5-fpm-$(NAME)-$(VERSION).tar.gz: $(DEPS)
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
		-e "NAME=$(NAME)" \
		-e "VERSION=$(VERSION)" \
		-e "GIT_URL=$(GIT_URL)" \
		-e "PHP_VERSION=$(PHP_VERSION)" \
		heroku/cedar \
		sh $(OUTPUT)/build.sh "$(OUTPUT)"

build.sh:
	cp ../pecl.sh build.sh

deps/php5-fpm.tar.gz:
	cd ../v$(PHP_VERSION); make; cp php5-fpm-$(PHP_VERSION).tar.gz $(CWD)/deps/php5-fpm.tar.gz

clean:
	$(MAKE) -C ../v$(PHP_VERSION) clean
	rm -Rf deps
	rm -Rf php5-fpm*.tar.gz
	rm -Rf php5-fpm-*.sh