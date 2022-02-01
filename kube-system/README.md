```sh
cat *.yaml | \
kubectl apply \
  -n kube-system \
  -f -
```
