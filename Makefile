.EXPORT_ALL_VARIABLES:
SHELL=/usr/bin/env bash
CLUSTER_NAME=local
KIND_CLUSTER_NAME=kind-$(CLUSTER_NAME)

# ---- versions ----
KUBERNETES_VERSION=v1.27.3
METALLB_VERSION=v0.13.11
CILIUM_VERSION=v1.14.2

@use_context: use-context

cluster:
	bash ./scripts/kind-cluster.sh
	$(MAKE) init

remove-cluster:
	kind delete cluster -n ${CLUSTER_NAME}

use-context:
	@((kubectl config current-context | grep -q ${KIND_CLUSTER_NAME}) || kubectl config use-context ${KIND_CLUSTER_NAME})

init: @use_context
	@echo "Initializing cluster"
	kubectl create namespace test
	kubectl create namespace monitoring
	kubectl create namespace ops
	bash ./scripts/lb.sh

cilium: @use_context
	helm repo add cilium https://helm.cilium.io/
	helm install cilium cilium/cilium --version ${CILIUM_VERSION} --namespace kube-system
	kubectl -n kube-system delete daemonset kindnet

ingress-nginx: @use_context
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm install ingress-nginx --namespace ingress --create-namespace ingress-nginx/ingress-nginx

install-helm: @use_context
	bash ./test/helm/helm.sh
