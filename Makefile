MAKEFLAGS += --no-print-directory
VERSION=0.0.1#$(shell git tag -l --sort=-v:refname| sed 's/v//g'| head -n 1)
GIT_TAG=$(shell git describe --tags)
PROJECT='urlshortener'

.PHONY:
.SILENT:
.DEFAULT_GOAL := help

linter-install: ## Install linter
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(shell go env GOPATH)/bin v2.0.2

test: ## Run all the tests
	go test -race -timeout=10m ./...

fmt: ## Run goimports on all go files
	find . -name '*.go' -not -wholename './vendor/*' | while read -r file; do goimports -w "$$file"; done
	go fmt ./...

lint: ## Run all the linters
	golangci-lint run -v

ci: lint test ## Run all the tests and code checks

install: ## install project and it's dependancies
	go mod tidy

build: ## build docker image
	docker build -t $(PROJECT):$(VERSION) .

run: ## build docker image
	docker compose up -d

execute: build run ## build and run docker image

version: ## display version
	@echo $(VERSION)

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	$(eval PADDING=$(shell grep -x -E '^[a-zA-Z_-]+:.*?##[\s]?.*$$' Makefile | awk '{ print length($$1)-1 }' | sort -n | tail -n 1))
	clear
	echo '╔──────────────────────────────────────────────────╗'
	echo '║ ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗  ║'
	echo '║ ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗ ║'
	echo '║ ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝ ║'
	echo '║ ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗ ║'
	echo '║ ██║  ██║███████╗███████╗██║     ███████╗██║  ██║ ║'
	echo '║ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝ ║'
	echo '╟──────────────────────────────────────────────────╝'
	@grep -E '^[a-zA-Z_-]+:.*?##[\s]?.*$$' Makefile | awk 'BEGIN {FS = ":.*?##"}; {gsub(/(^ +| +$$)/, "", $$2);printf "╟─[ \033[36m%-$(PADDING)s\033[0m %s\n", $$1, "] "$$2}'
	echo '╚──────────────────────────────────────────────────>'
	echo ''
