.PHONY: all build clean install test

PREFIX ?= /usr/local
BIN_DIR ?= $(PREFIX)/bin
VERSION ?= 0.20230525.2

all: build

build: test

clean:

install:
	install -d -m 0755 $(BIN_DIR)
	set -e; for file in $(wildcard $(CURDIR)/bin/*); do \
		sed -e 's/@@VERSION@@/$(VERSION)/g' "$${file}" > "$(BIN_DIR)/$$(basename "$${file}")"; \
		chmod 0755 "$(BIN_DIR)/$$(basename "$${file}")"; \
	done

test:
	shellcheck $(wildcard $(CURDIR)/bin/*)
	bats tests
