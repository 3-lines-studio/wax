GO = go
OUTPUT ?= wax
LDFLAGS = -s -w -buildid=
GCFLAGS = all=-l
TEST_RACE_ENV = WAX_SKIP_BROWSER_TEST=1

include ../check.mk

.PHONY: build clean

build:
	CGO_ENABLED=0 $(GO) build -mod=readonly -trimpath -buildvcs=false -gcflags='$(GCFLAGS)' -ldflags='$(LDFLAGS)' -o $(OUTPUT) .

clean:
	rm -f $(OUTPUT)
