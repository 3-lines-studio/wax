#!/bin/sh
set -eu

rm -rf dist
mkdir -p dist

build() {
    os=$1
    arch=$2
    name=$3
    GOOS=$os GOARCH=$arch make build OUTPUT="dist/$name"
    sha256sum "dist/$name" > "dist/$name.sha256"
}

build linux amd64 wax-linux-x86_64
build linux arm64 wax-linux-aarch64
build darwin arm64 wax-darwin-aarch64

cd dist
sha256sum wax-linux-x86_64 wax-linux-aarch64 wax-darwin-aarch64 > SHA256SUMS
