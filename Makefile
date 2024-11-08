.EXPORT_ALL_VARIABLES:
SHELL=/usr/bin/env bash
CLUSTER_NAME=local
KIND_CLUSTER_NAME=kind-$(CLUSTER_NAME)

# ---- versions ----
KUBERNETES_VERSION=v1.30.0
METALLB_VERSION=v0.14.5
CILIUM_VERSION=v1.15.5

@use_context: use-context

cluster:
	bash ./scripts/kind-cluster.sh
	$(MAKE) init

remove-cluster:
	kind delete cluster -n ${CLUSTER_NAME}

use-context:
	@if kubectl config current-context | grep -q minikube; then \
		echo "Current context is minikube. No need to change the context."; \
	else \
		if kubectl config current-context | grep -q $(KIND_CLUSTER_NAME); then \
			echo "Current context is already set to kind."; \
		else \
			echo "Setting context to kind."; \
			kubectl config use-context $(KIND_CLUSTER_NAME); \
		fi \
	fi

init: @use_context
	@echo "Initializing cluster"
	kubectl create namespace test
	kubectl create namespace monitoring
	kubectl create namespace ops
	bash ./scripts/lb.sh

cilium: @use_context
	helm repo add cilium https://helm.cilium.io/
	helm repo update
	helm install cilium cilium/cilium --version ${CILIUM_VERSION} \
		--namespace kube-system \
		--set prometheus.enabled=true --set envoy.enabled=true \
		--set operator.prometheus.enabled=true \
		--set hubble.enabled=true \
		--set hubble.metrics.enableOpenMetrics=true \
		--set hubble.relay.enabled=true \
		--set hubble.ui.enabled=true \
		--set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
	kubectl -n kube-system delete daemonset kindnet || kubectl -n kube-system delete daemonset kube-proxy

ingress-nginx: @use_context
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm install ingress-nginx --namespace ingress --create-namespace ingress-nginx/ingress-nginx

install-helm: @use_context
	bash ./test/helm/helm.sh
