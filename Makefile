.PHONY: all build clean install test

PREFIX ?= /usr/local
BIN_DIR ?= $(PREFIX)/bin
VERSION ?= $(shell git describe --tags HEAD | sed -e 's/^v//g' -e 's/[^-.0-9A-Z_a-z]/_/g')

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
