
function _reloader() {
  # ref: https://github.com/stakater/Reloader
  
  # Reloader can watch changes in ConfigMap and Secret and do rolling upgrades on Pods
  # with their associated DeploymentConfigs, Deployments, Daemonsets Statefulsets and Rollouts.
  
  helm repo add stakater https://stakater.github.io/stakater-charts
  helm repo update

  helm install reloader -n ops --create-namespace stakater/reloader
}

function _external_secrets() {
  # ref: https://external-secrets.io/

  # External Secrets Operator is a Kubernetes operator that integrates
  # external secret management systems like AWS secret management, Hashcorp Vault etc.

  helm repo add external-secrets https://charts.external-secrets.io
  helm repo update

  helm install external-secrets external-secrets/external-secrets \
    -n ops --create-namespace --set installCRDs=true
}

function _kube_prometheus() {
  # ref: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

  helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    -n monitoring --create-namespace
}

function _cert_manager() {
  # ref: https://cert-manager.io/docs/

  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  
  helm install cert-manager jetstack/cert-manager \
    -n cert-manager --create-namespace \
    --set installCRDs=true \
    # --version v1.10.1
}

function _devtron() {
  # ref: https://docs.devtron.ai/

  helm repo add devtron https://helm.devtron.ai
  helm install devtron devtron/devtron-operator \
    --create-namespace --namespace devtroncd \
    --set components.devtron.service.type=NodePort \
    --set installer.modules={cicd} \
    --set argo-cd.enabled=true \
    # --version 0.22.47
}

function _longhorn () {
  # ref: https://longhorn.io/

  helm repo add longhorn https://charts.longhorn.io
  helm install longhorn longhorn/longhorn \
    --namespace longhorn-system \
    --create-namespace \
    # --version 1.3.2
}

_kube_prometheus
# _devtron
_cert_manager