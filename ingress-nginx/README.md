```sh
curl -L https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml > deploy.yaml
```

```sh
cat *.yaml | \
kubectl apply \
  -n ingress-nginx \
  --prune --all \
  -f -
```
