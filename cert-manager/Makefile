SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

CERT_MANAGER_VERSION=v1.9.1

.PHONY: deploy
deploy: ## Deploy
	cat *.yaml | kubectl apply -n cert-manager --prune --all -f -

.PHONY: format
format: ## Format
	exit 0

.PHONY: test
test: ## Test
	kubeconform -ignore-missing-schemas -strict cert-manager.yaml

.PHONY: upgrade
upgrade: ## Upgrade
	curl -L "https://github.com/jetstack/cert-manager/releases/download/$(CERT_MANAGER_VERSION)/cert-manager.yaml" > cert-manager.yaml
	#kubectl apply -l app.kubernetes.io/instance=cert-manager --prune -f cert-manager.yaml
