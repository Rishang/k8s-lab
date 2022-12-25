#!/usr/bin/bash
set -o errexit

# https://kind.sigs.k8s.io/docs/user/loadbalancer/

ip=`docker network inspect -f '{{.IPAM.Config}}' kind | awk '{print $1}' | grep -oE "[0-9./]+" | cut -d '/' -f1`

metallb_version="${METALLB_VERSION:=v0.13.7}"
echo -e "${!metallb_version@}: ${metallb_version}\n"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/config/manifests/metallb-native.yaml
kubectl wait --namespace metallb-system --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind
  namespace: metallb-system
spec:
  addresses:
  - ${ip}/24
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF
