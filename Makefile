# ######################################################################################################################
# LICENSE
# ######################################################################################################################

#
# This file is part of pokas.
#
# The pokas is free software: you can redistribute it and/or modify it under the terms of the GNU Affero
# General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# The pokas is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with pokas. If not, see
# <https://www.gnu.org/licenses/>.
#

# ######################################################################################################################
# VARIABLES
# ######################################################################################################################

#
# Make
#

SHELL := /bin/bash

#
# Directories
#

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(abspath ${ROOT_DIR}/build)
CMD_DIR := $(abspath ${ROOT_DIR}/cmd)
CONFIGS_DIR := $(abspath ${ROOT_DIR}/configs)
DEV_DIR := $(abspath ${ROOT_DIR}/dev)
DIST_DIR := $(abspath ${ROOT_DIR}/dist)
DOCS_DIR := $(abspath ${ROOT_DIR}/docs)
EXAMPLES_DIR := $(abspath ${ROOT_DIR}/examples)
INTERNAL_DIR := $(abspath ${ROOT_DIR}/internal)
PKG_DIR := $(abspath ${ROOT_DIR}/pkg)
SCRIPTS_DIR := $(abspath ${ROOT_DIR}/scripts)
TEST_DIR := $(abspath ${ROOT_DIR}/test)
VENDOR_DIR := $(abspath ${ROOT_DIR}/vendor)

#
# Project: General
#

PROJECT_BUILD_DATE ?= $(shell date --rfc-3339=seconds)
PROJECT_COMMIT ?= $(shell git rev-parse HEAD)
PROJECT_NAME ?= $(error PROJECT_NAME is not set)
PROJECT_VERSION ?= $(strip \
	$(if \
		$(shell git rev-list --tags --max-count=1), \
		$(shell git describe --tags `git rev-list --tags --max-count=1`), \
		$(shell git rev-parse --short HEAD) \
	) \
)

#
# Project: Go
#

PROJECT_GO_LDFLAGS := "-X \"main.BuildTime=${PROJECT_BUILD_DATE}\" -X \"main.Commit=${PROJECT_COMMIT}\" -X \"main.Version=${PROJECT_VERSION}"\"
PROJECT_GO_PLATFORMS ?= "darwin/amd64,darwin/arm64,linux/amd64,linux/arm64"

# ######################################################################################################################
# TARGETS
# ######################################################################################################################

.PHONY: all
all: lint scan build test

.PHONY: build
build:
	@for command in `ls -1 ${CMD_DIR}/`; do \
		for platform in `echo ${PROJECT_GO_PLATFORMS} | tr ',' ' '`; do \
			export GOOS=`echo $$platform | cut -d/ -f1`; \
			export GOARCH=`echo $$platform | cut -d/ -f2`; \
			echo "Building $$command for $$platform"; \
			go build \
				-ldflags="${PROJECT_BUILD_LDFLAGS}" \
				-mod="vendor" \
				-o "${BUILD_DIR}/$$command-${PROJECT_VERSION}-$${GOOS}_$${GOARCH}" \
				"${CMD_DIR}/$$command/main.go"; \
		done; \
	done

.PHONY: clean
clean:
	@rm -f coverage.txt
	@rm -rf ${BUILD_DIR}/*
	@rm -rf ${DIST_DIR}/*

.PHONY: lint
lint:
	@go fmt "${CMD_DIR}/..."
	@go fmt "${INTERNAL_DIR}/..."
	@go fmt "${PKG_DIR}/..."

.PHONY: lock
lock:
	@go mod vendor
	@go mod tidy

.PHONY: release
release:
	@for command in `ls -1 ${CMD_DIR}/`; do \
		for platform in `echo ${PROJECT_GO_PLATFORMS} | tr ',' ' '`; do \
			export GOOS=`echo $$platform | cut -d/ -f1`; \
			export GOARCH=`echo $$platform | cut -d/ -f2`; \
			echo "Releasing $$command for $$platform"; \
			tar -czvf \
				"${DIST_DIR}/${PROJECT_NAME}-${PROJECT_VERSION}-$${GOOS}_$${GOARCH}.tgz" \
				-C "${BUILD_DIR}/" \
				--transform="flags=r;s|$${command}-.*|$$command|" \
				"${PROJECT_NAME}-${PROJECT_VERSION}-$${GOOS}_$${GOARCH}"; \
		done; \
	done

.PHONY: scan
scan:
	@gosec ./...

.PHONY: reset
reset: clean
	@rm -rf "${VENDOR_DIR}/"*

.PHONY: test
test:
	@go test \
		-v \
		-count=1 \
		-race \
		-coverprofile=coverage.txt \
		-covermode=atomic \
		./...
