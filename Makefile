#Copyright (c) 2012 Megam Systems.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
###############################################################################
# Makefile to compile gulpd.
# lists all the dependencies for test, prod and we can run a go build aftermath.
###############################################################################
                            

yup_go = $(HOME)/code/megam/workspace/gulp

export GOPATH=$(yup_go)

define HG_ERROR

FATAL: you need mercurial (hg) to download gulp dependencies.
       Check README.md for details
endef

define GIT_ERROR

FATAL: you need git to download gulp dependencies.
       Check README.md for details
endef

define BZR_ERROR

FATAL: you need bazaar (bzr) to download gulp dependencies.
       Check README.md for details
endef

.PHONY: all check-path get hg git bzr get-test get-prod test client

all: check-path get test

# It does not support GOPATH with multiple paths.
check-path:
ifndef GOPATH
	@echo "FATAL: you must declare GOPATH environment variable, for more"
	@echo "       details, please check README.md file and/or"
	@echo "       http://golang.org/cmd/go/#GOPATH_environment_variable"
	@exit 1
endif
ifneq ($(subst ~,$(HOME),$(GOPATH))/src/github.com/indykish/gulp, $(PWD))
	@echo "FATAL: you must clone gulp inside your GOPATH To do so,"
	@echo "       you can run go get github.com/indykish/gulp/..."
	@echo "       or clone it manually to the dir $(GOPATH)/src/github.com/indykish/gulp"
	@exit 1
endif

get: hg git bzr get-test get-prod

hg:
	$(if $(shell hg), , $(error $(HG_ERROR)))

git:
	$(if $(shell git), , $(error $(GIT_ERROR)))

bzr:
	$(if $(shell bzr), , $(error $(BZR_ERROR)))

get-test:
	@/bin/echo -n "Installing test dependencies... "
	@go list -f '{{range .TestImports}}{{.}} {{end}}' ./... | tr ' ' '\n' |\
		grep '^.*\..*/.*$$' | grep -v 'github.com/indykish/gulp' |\
		sort | uniq | xargs go get -u >/tmp/.get-test 2>&1 || (cat /tmp/.get-test && exit 1)	
	@/bin/echo "ok"
	@rm -f /tmp/.get-test

get-prod:
	@/bin/echo -n "Installing production dependencies... "
	@go list -f '{{range .Imports}}{{.}} {{end}}' ./... | tr ' ' '\n' |\
		grep '^.*\..*/.*$$' | grep -v 'github.com/indykish/gulp' |\
		sort | uniq | xargs go get -u >/tmp/.get-prod 2>&1 || (cat /tmp/.get-prod && exit 1)
	@/bin/echo "ok"
	@rm -f /tmp/.get-prod

_go_test:
	@go test -i ./...
	@go test ./...

_gulpd_dry:
	@go build -o gulpd ./cmd/gulpd
	@./gulpd start --dry --config ./config/gulpd.conf
	@rm -f gulpd

test: _go_test _gulpd_dry


client:
	@go build -o gulpd ./cmd/gulp
	@echo "Copy gulpd to your binary path"
