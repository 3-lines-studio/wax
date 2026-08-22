GO = go
OUTPUT ?= wax
LDFLAGS = -s -w -buildid=
GCFLAGS = all=-l

.PHONY: build check clean fix fmt

build:
	CGO_ENABLED=0 $(GO) build -mod=readonly -trimpath -buildvcs=false -gcflags='$(GCFLAGS)' -ldflags='$(LDFLAGS)' -o $(OUTPUT) .

fmt:
	$(GO) fmt ./...

fix:
	$(GO) fix ./...
	$(GO) mod tidy
	$(MAKE) fmt

check:
	test -z "$$(gofmt -l .)"
	$(GO) mod tidy -diff
	$(GO) vet ./...
	golangci-lint run ./...
	WAX_SKIP_BROWSER_TEST=1 $(GO) test -race ./...
	$(GO) test ./...
	$(MAKE) build

clean:
	rm -f $(OUTPUT)
