.PHONY: clean

NAME=composer

CWD=$(shell pwd)
OUTPUT=/tmp/out

all: $(NAME).sh

debug:
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
	 	-e "NAME=$(NAME)" \
		heroku/cedar

$(NAME).sh:
	docker run -i -t -v "$(CWD):$(OUTPUT)" \
		-e "NAME=$(NAME)" \
		heroku/cedar \
		sh $(OUTPUT)/build.sh "$(OUTPUT)"

clean::
	rm -f $(NAME).sh