SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

.PHONY: format format-cert-manager format-ingress-nginx format-kube-state-metrics format-kube-system
format: format-cert-manager format-ingress-nginx format-kube-state-metrics format-kube-system ## Format
	npx prettier --write *.md
format-cert-manager:
	$(MAKE) -C cert-manager format
format-ingress-nginx:
	$(MAKE) -C ingress-nginx format
format-kube-state-metrics:
	$(MAKE) -C kube-state-metrics format

.PHONY: test test-cert-manager test-ingress-nginx test-kube-state-metrics test-kube-system
test: test-cert-manager test-ingress-nginx test-kube-state-metrics test-kube-system ## Test
	npx prettier --check *.md
	shellcheck *.sh
test-cert-manager:
	$(MAKE) -C cert-manager test
test-ingress-nginx:
	$(MAKE) -C ingress-nginx test
test-kube-state-metrics:
	$(MAKE) -C kube-state-metrics test
