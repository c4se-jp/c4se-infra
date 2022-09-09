SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

.PHONY: deploy
deploy: ## Deploy
	cat *.yaml | kubectl apply -n kube-system -f -

.PHONY: format
format: ## Format
	npx prettier --write .

.PHONY: test
test: ## Test
	npx prettier --check .
	yamllint *.yaml
	kubeconform -ignore-missing-schemas -strict *.yaml
