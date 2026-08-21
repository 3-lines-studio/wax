# wax

Fetch a web page as Markdown for AX and other LLM tools.

Wax uses HTTP first. When the page has little useful text, it renders the page with an installed Chromium browser and converts the final HTML to Markdown.

## Install

```sh
curl -fsSL https://github.com/3-lines-studio/wax/releases/latest/download/install.sh | sh
```

This installs Wax to `~/.local/bin`. Override the location with `WAX_PREFIX` or pin a release with `WAX_VERSION=v0.1.0`.

Prebuilt binaries support Linux on x86-64 and ARM64, and macOS on Apple silicon. Chromium, Chromium Browser, or Google Chrome is required only when a page needs rendering.

## Build

Building requires Go 1.27 or newer.

```sh
make build
```

Run all checks and the optimized build with:

```sh
make check
```

Apply Go fixes, tidy modules, and format the code with:

```sh
make fix
```

Build all release binaries and checksums with:

```sh
scripts/package.sh
```

## Use

```sh
wax https://example.com
```

Markdown goes to stdout. Errors go to stderr.
