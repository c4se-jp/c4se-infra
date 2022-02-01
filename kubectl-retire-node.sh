#!/bin/bash

# kubectl get no --no-headers | awk '{print $1}' | xargs -t -I{} ./kubectl-retire-node.sh {}

set -eux
kubectl cordon "$1"
kubectl drain --force --ignore-daemonsets --delete-emptydir-data --grace-period=300 "$1" || true
kubectl delete no "$1"
