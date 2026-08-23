#!/bin/sh
set -eu

repo="${WAX_REPO:-3-lines-studio/wax}"
if [ -n "${WAX_BASE_URL:-}" ]; then
    base="$WAX_BASE_URL"
elif [ -n "${WAX_VERSION:-}" ]; then
    base="https://github.com/$repo/releases/download/$WAX_VERSION"
else
    base="https://github.com/$repo/releases/latest/download"
fi

prefix="${WAX_PREFIX:-${PREFIX:-$HOME/.local}}"
bindir="$prefix/bin"

os=$(uname -s | tr '[:upper:]' '[:lower:]')
case $os in
    linux | darwin) ;;
    *) echo "install: unsupported os: $os" >&2; exit 1 ;;
esac

arch=$(uname -m)
case $arch in
    x86_64 | amd64) arch=x86_64 ;;
    aarch64 | arm64) arch=aarch64 ;;
    *) echo "install: unsupported arch: $arch" >&2; exit 1 ;;
esac

if [ "$os" = "darwin" ] && [ "$arch" != "aarch64" ]; then
    echo "install: unsupported platform: $os-$arch" >&2
    exit 1
fi

download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$1" -O "$2"
    else
        echo "install: curl or wget is required" >&2
        return 1
    fi
}

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    elif command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$1" | awk '{print $NF}'
    else
        echo "install: sha256sum, shasum, or openssl is required" >&2
        return 1
    fi
}

name="wax-$os-$arch"
url="$base/$name"
umask 077
tmpdir="${TMPDIR:-/tmp}/wax-install-$$"
if ! mkdir "$tmpdir"; then
    echo "install: cannot create temporary directory: $tmpdir" >&2
    exit 1
fi
tmp="$tmpdir/wax"
trap 'rm -rf "$tmpdir"' 0 HUP INT TERM

echo "downloading $name"
download "$url" "$tmp" || { echo "install: download failed: $url" >&2; exit 1; }
download "$url.sha256" "$tmp.sha256" || { echo "install: checksum fetch failed: $url.sha256" >&2; exit 1; }

want=$(awk '{print $1}' "$tmp.sha256")
got=$(sha256 "$tmp")
if [ "$want" != "$got" ]; then
    echo "install: checksum mismatch (want $want, got $got)" >&2
    exit 1
fi

mkdir -p "$bindir"
cp "$tmp" "$bindir/wax"
chmod 0755 "$bindir/wax"

case ":$PATH:" in
    *":$bindir:"*) ;;
    *) echo "install: $bindir is not on PATH — add it, e.g. export PATH=\"\$HOME/.local/bin:\$PATH\"" >&2 ;;
esac

echo "installed wax ($name) to $bindir/wax"
