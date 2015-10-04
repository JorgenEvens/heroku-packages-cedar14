NAME=ffmpeg
VERSION=2.8
DEPS=deps deps/yasm.tar.gz

include ../../generic.mk

deps:
	mkdir -p deps

deps/yasm.tar.gz:
	cd ../../yasm/v1.2.0; make; cp yasm-*.tar.gz $(CWD)/deps/yasm.tar.gz

clean-all: clean
	$(MAKE) -C ../../yasm/v1.2.0 clean

clean::
	rm -Rf deps