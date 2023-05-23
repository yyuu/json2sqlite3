.PHONY: all build clean install test

PREFIX ?= /usr/local
BIN_DIR ?= $(PREFIX)/bin

all: build

build: test

clean:

install:
	install -d -m 0755 $(BIN_DIR)
	install -m 0755 $(wildcard $(CURDIR)/bin/*) $(BIN_DIR)/

test:
	shellcheck $(wildcard $(CURDIR)/bin/*)
	bats tests
