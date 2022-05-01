BUILD_DIR = "build"
CMD_DIR = "cmd"
DIST_DIR = "dist"
INTERNAL_DIR = "internal"
PKG_DIR = "pkg"
SCRIPTS_DIR = "scripts"
VENDOR_DIR = "vendor"

.PHONY: build build-linux build-macos build-windows clean lint lock release release-linux release-macos release-windows scan test

default:
	$(MAKE) lint

build: build-linux build-macos build-windows

build-linux:
	@${SCRIPTS_DIR}/build.sh -p "linux/amd64"
	@${SCRIPTS_DIR}/build.sh -p "linux/arm64"

build-macos:
	@${SCRIPTS_DIR}/build.sh -p "darwin/amd64"
	@${SCRIPTS_DIR}/build.sh -p "darwin/arm64"

build-windows:
	@${SCRIPTS_DIR}/build.sh -p "windows/amd64"

clean:
	go clean
	rm -rf ${BUILD_DIR}/*
	rm -rf ${DIST_DIR}/*
	rm -f coverage.txt

lint:
	gofumpt -l -w .
	go vet ./...
	golangci-lint run --enable-all ./...

lock:
	go mod tidy
	go mod vendor

release: clean release-linux release-macos release-windows

release-linux:
	@${SCRIPTS_DIR}/build.sh -r -p "linux/amd64"
	@${SCRIPTS_DIR}/build.sh -r -p "linux/arm64"

release-macos:
	@${SCRIPTS_DIR}/build.sh -r -p "darwin/amd64"
	@${SCRIPTS_DIR}/build.sh -r -p "darwin/arm64"

release-windows:
	@${SCRIPTS_DIR}/build.sh -r -p "windows/amd64"

reset: clean
	rm -rf ${VENDOR_DIR}/*
	rm -f go.sum

scan:
	gosec ./...

test:
	go test -v -count=1 -race -coverprofile=coverage.txt -covermode=atomic ./...
