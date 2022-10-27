SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

INGRESS_NGINX_VERSION=v1.4.0

.PHONY: deploy
deploy: ## Deploy
	cat deploy.yaml | kubectl apply -n ingress-nginx -l app.kubernetes.io/instance=ingress-nginx --prune -f -

.PHONY: format
format: ## Format
	exit 0

.PHONY: test
test: ## Test
	kubeconform -ignore-missing-schemas -strict deploy.yaml

.PNONY: upgrade
upgrade: ## Upgrade
	curl -L "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$(INGRESS_NGINX_VERSION)/deploy/static/provider/cloud/deploy.yaml" > deploy.yaml
