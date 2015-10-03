.PHONY: clean

NAME=pcre
VERSION=8.37

CWD=$(shell pwd)
OUTPUT=/tmp/out

all: $(NAME)-$(VERSION).tar.gz

debug:
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
	 	-e "NAME=$(NAME)" \
		-e "VERSION=$(VERSION)" \
		heroku/cedar

$(NAME)-$(VERSION).tar.gz:
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
		-e "NAME=$(NAME)" \
		-e "VERSION=$(VERSION)" \
		heroku/cedar \
		sh $(OUTPUT)/build.sh "$(OUTPUT)"

clean:
	rm -f $(NAME)-*.{tar.gz,sh}