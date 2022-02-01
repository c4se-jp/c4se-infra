```
curl -L https://github.com/jetstack/cert-manager/releases/download/v1.7.0/cert-manager.yaml > cert-manager.yaml
```

```sh
cat *.yaml | \
kubectl apply \
  -n cert-manager \
  --prune --all \
  -f -
```
