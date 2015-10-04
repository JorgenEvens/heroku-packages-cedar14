.PHONY: clean

CWD=$(shell pwd)
OUTPUT=/tmp/out

all: $(NAME)-$(VERSION).tar.gz

debug: $(DEPS)
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
	 	-e "NAME=$(NAME)" \
		-e "VERSION=$(VERSION)" \
		$(DOCKER_ENV) \
		heroku/cedar

$(NAME)-$(VERSION).tar.gz: $(DEPS)
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
		-e "NAME=$(NAME)" \
		-e "VERSION=$(VERSION)" \
		$(DOCKER_ENV) \
		heroku/cedar \
		sh $(OUTPUT)/build.sh "$(OUTPUT)"

clean:
	rm -f $(NAME)-*.{tar.gz,sh}