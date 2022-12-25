
function github_version() {
  repo=$1
  echo "${repo} => `curl -s https://api.github.com/repos/${repo}/releases/latest | jq -r ".tag_name"`"
}

echo
github_version kubernetes-sigs/kind
github_version metallb/metallb
github_version cilium/cilium
