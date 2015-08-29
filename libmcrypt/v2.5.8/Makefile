CWD=$(shell pwd)
OUTPUT=/tmp/out

all:
	docker run -i -v "$(CWD):$(OUTPUT)" heroku/cedar sh $(OUTPUT)/build.sh "$(OUTPUT)"

debug:
	docker run -i -t -v "$(CWD):$(OUTPUT)" heroku/cedar

clean:
	rm -f libmcrypt-*.{tar.gz,sh}