# local-kube

All small poc's regarding kubernetes, in local kind kubernetes cluster.

## pre-requirements

- docker
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- kubectl
- helm
- make
- bash
- lens
- zsh (optional)
- kubectx (optional)
- kubens (optional)

## Getting started

run:
- `make cluster` to create a local kind cluster
- `make remove-cluster` to remove the local kind cluster
  
### references

- [k8s-lab](https://codeberg.org/drpdishant/k8s-lab)
