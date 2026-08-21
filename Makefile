GO = go
OUTPUT ?= wax
LDFLAGS = -s -w -buildid=

.PHONY: build check clean fix fmt

build:
	CGO_ENABLED=0 $(GO) build -mod=readonly -trimpath -buildvcs=false -ldflags='$(LDFLAGS)' -o $(OUTPUT) .

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
	$(GO) test -race ./...
	$(MAKE) build

clean:
	rm -f $(OUTPUT)
