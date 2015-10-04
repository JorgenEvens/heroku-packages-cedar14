NAME=nginx
VERSION=1.8.0

DEPS=deps deps/luajit.tar.gz deps/geoip.tar.gz

include ../../generic.mk

deps:
	mkdir -p deps

deps/luajit.tar.gz:
	cd ../../luajit/v2.0.4; make; cp luajit-*.tar.gz $(CWD)/deps/luajit.tar.gz

deps/geoip.tar.gz:
	cd ../../geoip/v1.6.6; make; cp geoip-*.tar.gz $(CWD)/deps/geoip.tar.gz

clean:
	$(MAKE) -C ../../luajit/v2.0.4 clean
	$(MAKE) -C ../../geoip/v1.6.6 clean
	rm -Rf deps
	rm -Rf nginx-*.tar.gz
	rm -Rf nginx-*.sh