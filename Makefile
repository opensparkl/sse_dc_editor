# Copyright (c) 2016 SPARKL Limited. All Rights Reserved.
# Author <jacoby@sparkl.com> Jacoby Thwaites
# Makefile with targets used when this is a git submodule in
# the sse_core repo.
SHELL := /bin/bash
ROOT := $(shell git rev-parse --show-toplevel)
APP := $(shell basename `pwd`)

BUILD_DIR := dist
PLACE_DIR := ../../apps/sse_yaws/priv/docroot
PLACE_NAME := sse_dc_editor

COMPILE := $(BUILD_DIR)/compile
.PHONY: compile
compile: $(COMPILE)

$(COMPILE):
	@npm run fast
	@touch $@

.PHONY: deps
deps: $(BUILD_DIR)
	@npm install
	@rm -f $(PLACE_DIR)/$(PLACE_NAME)
	@cd $(PLACE_DIR) && ln -s $(realpath $(BUILD_DIR)) $(PLACE_NAME)

$(BUILD_DIR):
	@mkdir -p $@

.PHONY: eunit
eunit:
	@cd xsl/test && ./test.sh

.PHONY: rel
rel:
	@npm run build

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)/*

.PHONY: clean_deps
clean_deps:
	@rm -rf node_modules

.PHONY: %
%:
	@echo "No target '$*'"
