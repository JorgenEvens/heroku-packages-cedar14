CWD=$(shell pwd)
OUTPUT="/tmp/out"

all: deps
	docker run -i -v "$(CWD):$(OUTPUT)" heroku/cedar sh $(OUTPUT)/build.sh "$(OUTPUT)"

debug: deps
	docker run -i -t -v "$(CWD):$(OUTPUT)" heroku/cedar

deps:
	mkdir -p deps
	cd ../../luajit/v2.0.4; make; cp luajit-*.tar.gz $(CWD)/deps/luajit.tar.gz
	cd ../../geoip/v1.6.6; make; cp geoip-*.tar.gz $(CWD)/deps/geoip.tar.gz

clean:
	$(MAKE) -C ../../luajit/v2.0.4 clean
	$(MAKE) -C ../../geoip/v1.6.6 clean
	rm -Rf deps
	rm -Rf nginx-*.tar.gz
	rm -Rf nginx-*.sh