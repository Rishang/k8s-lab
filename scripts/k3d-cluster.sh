#!/bin/bash

CLUSTER_NAME="k3s-default"


function create_cluster() { 
  echo "Creating cluster ${CLUSTER_NAME}"
  k3d cluster create ${CLUSTER_NAME} \
    --servers 1 \
    --agents 2 \
    -p "80:80@loadbalancer" \
    -p "443:443@loadbalancer" 
    # --image rancher/k3s:${KUBERNETES_VERSION}+k3s1 \
  
  k3d registry create registry.localhost --port 5000
}

function delete_cluster() {
  echo "Deleting cluster ${CLUSTER_NAME}"
  k3d cluster delete ${CLUSTER_NAME}
  k3d registry delete registry.localhost
}

case $1 in
  create)
    create_cluster
    ;;
  delete)
    delete_cluster
    ;;
  *)
    echo "Usage: $0 create | delete"
    ;;
esac